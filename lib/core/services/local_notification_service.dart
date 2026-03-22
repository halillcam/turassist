import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
  final Set<String> _shownNotificationIds = <String>{};
  DateTime _sessionStartedAt = DateTime.now();
  bool _initialized = false;
  static const bool _enableFcmTokenSync = true;

  bool get _shouldMirrorFirestoreNotificationsLocally {
    return !_supportsFirebaseMessaging || !_enableFcmTokenSync;
  }

  bool get _supportsFirebaseMessaging {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

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
    if (_supportsFirebaseMessaging && _enableFcmTokenSync) {
      try {
        await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
      } catch (_) {}
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _setupFirebaseMessaging() async {
    if (!_supportsFirebaseMessaging) {
      await _fcmForegroundSubscription?.cancel();
      _fcmForegroundSubscription = null;
      return;
    }

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
      await _syncCurrentFcmToken(user?.uid);
    });

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    _subscribeToUserNotifications(currentUid);
    _syncCurrentFcmToken(currentUid);

    _fcmTokenRefreshSubscription?.cancel();
    if (!_supportsFirebaseMessaging || !_enableFcmTokenSync) {
      _fcmTokenRefreshSubscription = null;
      return;
    }

    _fcmTokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && uid.isNotEmpty) {
        _saveFcmToken(uid, token);
      }
    });
  }

  Future<void> _syncCurrentFcmToken(String? userId) async {
    if (!_supportsFirebaseMessaging || !_enableFcmTokenSync) {
      return;
    }
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.trim().isNotEmpty) {
        await _saveFcmToken(userId, token.trim());
      }
    } catch (_) {}
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

          if (!_shouldMirrorFirestoreNotificationsLocally) {
            continue;
          }

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
      channelDescription: 'Tur sorumlusu duyuruları ve tur bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id: id, title: title, body: body, notificationDetails: details);
  }

  Future<void> clearUserSession() async {
    await _subscribeToUserNotifications(null);
    _shownNotificationIds.clear();
  }
}
