import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _userNotificationsSubscription;
  StreamSubscription<RemoteMessage>? _fcmForegroundSubscription;
  StreamSubscription<String>? _fcmTokenRefreshSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _testCheckedInTicketsSubscription;
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _testTourAnnouncementSubscriptions =
      <String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{};
  final Set<String> _shownNotificationIds = <String>{};

  DateTime _sessionStartedAt = DateTime.now();
  bool _initialized = false;
  static const String _testFallbackTag = 'TEST_LOCAL_NOTIFICATION_FALLBACK';

  Future<void> initialize() async {
    if (_initialized) return;

    _sessionStartedAt = DateTime.now();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings: settings);
    await _requestPermissions();
    await _setupFirebaseMessaging();
    _listenAuthState();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    try {
      await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    } catch (_) {}

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _setupFirebaseMessaging() async {
    try {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (_) {}

    _fcmForegroundSubscription?.cancel();
    _fcmForegroundSubscription = FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? message.data['title']?.toString() ?? 'TurAssist';
      final body = message.notification?.body ?? message.data['body']?.toString() ?? '';
      if (body.trim().isEmpty) return;

      _showSystemNotification(
        (message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString()).hashCode &
            0x7fffffff,
        title,
        body,
      );
    });
  }

  void _listenAuthState() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      await _subscribeToUserNotifications(user?.uid);
      await _syncFcmToken(user?.uid);
      await _startTestAnnouncementFallback(user?.uid);
    });

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    _subscribeToUserNotifications(currentUid);
    _syncFcmToken(currentUid);
    _startTestAnnouncementFallback(currentUid);

    _fcmTokenRefreshSubscription?.cancel();
    _fcmTokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        _saveFcmToken(uid, token);
      }
    });
  }

  // TEST ETIKETI:
  // Blaze/Firebase Functions push aktif edilene kadar geçici local notification fallback.
  // App açık/arka plandayken Firestore stream ile duyuruları dinler.
  Future<void> _startTestAnnouncementFallback(String? userId) async {
    await _testCheckedInTicketsSubscription?.cancel();
    _testCheckedInTicketsSubscription = null;
    await _cancelAllTestAnnouncementSubscriptions();

    if (userId == null || userId.isEmpty) {
      return;
    }

    final ticketQuery = FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .where('isScanned', isEqualTo: true);

    _testCheckedInTicketsSubscription = ticketQuery.snapshots().listen((snapshot) {
      _syncTestTourAnnouncementListeners(snapshot.docs);
    });
  }

  void _syncTestTourAnnouncementListeners(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final activeTourIds = <String>{};
    for (final doc in docs) {
      final data = doc.data();
      final status = data['status']?.toString().toLowerCase() ?? '';
      if (status == 'cancelled') continue;

      final tourId = data['tourId']?.toString().trim() ?? '';
      if (tourId.isNotEmpty) {
        activeTourIds.add(tourId);
      }
    }

    final toRemove = _testTourAnnouncementSubscriptions.keys
        .where((tourId) => !activeTourIds.contains(tourId))
        .toList();

    for (final tourId in toRemove) {
      _testTourAnnouncementSubscriptions[tourId]?.cancel();
      _testTourAnnouncementSubscriptions.remove(tourId);
    }

    for (final tourId in activeTourIds) {
      if (_testTourAnnouncementSubscriptions.containsKey(tourId)) continue;
      _testTourAnnouncementSubscriptions[tourId] = FirebaseFirestore.instance
          .collection('tours')
          .doc(tourId)
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen((announcementSnapshot) {
            _handleTestAnnouncementSnapshot(tourId, announcementSnapshot);
          });
    }
  }

  Future<void> _handleTestAnnouncementSnapshot(
    String tourId,
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;

      final data = change.doc.data();
      if (data == null) continue;

      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt != null && createdAt.isBefore(_sessionStartedAt)) {
        continue;
      }

      final message = data['notification']?.toString().trim() ?? '';
      if (message.isEmpty) continue;

      final notificationKey = 'test_fallback_ann_${tourId}_${change.doc.id}';
      if (_shownNotificationIds.contains(notificationKey)) continue;
      _shownNotificationIds.add(notificationKey);

      await _showSystemNotification(
        notificationKey.hashCode & 0x7fffffff,
        'Tur Bildirim (Test)',
        message,
      );
    }
  }

  Future<void> _cancelAllTestAnnouncementSubscriptions() async {
    for (final sub in _testTourAnnouncementSubscriptions.values) {
      await sub.cancel();
    }
    _testTourAnnouncementSubscriptions.clear();
  }

  Future<void> _syncFcmToken(String? userId) async {
    if (userId == null || userId.isEmpty) return;
    String? token;
    try {
      token = await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return;
    }
    if (token == null || token.isEmpty) return;
    await _saveFcmToken(userId, token);
  }

  Future<void> _saveFcmToken(String userId, String token) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _subscribeToUserNotifications(String? userId) async {
    await _userNotificationsSubscription?.cancel();
    _userNotificationsSubscription = null;
    _shownNotificationIds.clear();

    if (userId == null || userId.isEmpty) {
      return;
    }

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(100);

    _userNotificationsSubscription = query.snapshots().listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type != DocumentChangeType.added) continue;

          final doc = change.doc;
          if (_shownNotificationIds.contains(doc.id)) continue;
          _shownNotificationIds.add(doc.id);

          final data = doc.data();
          if (data == null) continue;

          final isRead = data['isRead'] == true;
          if (isRead) continue;

          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          if (createdAt != null && createdAt.isBefore(_sessionStartedAt)) {
            continue;
          }

          final title = (data['title']?.toString().trim().isNotEmpty ?? false)
              ? data['title'].toString()
              : 'TurAssist';
          final message = data['message']?.toString() ?? '';

          _showSystemNotification(doc.id.hashCode & 0x7fffffff, title, message);
        }
      },
      onError: (_) {
        _userNotificationsSubscription?.cancel();
        _userNotificationsSubscription = null;
      },
    );
  }

  Future<void> _showSystemNotification(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'turassist_announcements',
      'TurAssist Duyurular',
      channelDescription: 'Tur sorumlusu duyuruları ve tur bildirimleri ($_testFallbackTag)',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }
}
