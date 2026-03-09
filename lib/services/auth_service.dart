import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

/// Kimlik doğrulama ve kullanıcı yönetimi servisi.
///
/// Sorumlulukları:
/// - Firebase Auth ile kayıt, giriş ve çıkış işlemleri
/// - Tur sorumlusu (rehber) girişi (guides koleksiyonu tabanlı)
/// - Şifre sıfırlama
/// - Kullanıcı profili okuma
/// - Şirket bazlı yetki kontrolü
/// - Rehber adı çözümleme (users → guides → fallback)
class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== KULLANICI BİLGİLERİ ====================

  /// Şu anki oturum açmış kullanıcının Firebase UID'sini döndürür.
  ///
  /// Kullanıcı giriş yapmamışsa boş string döner.
  String getCurrentUserId() {
    return _auth.currentUser?.uid ?? '';
  }

  /// Firestore'dan anlık kullanıcı profilini getirir.
  ///
  /// Kullanıcı giriş yapmamışsa veya kayıt bulunamazsa [null] döner.
  Future<UserModel?> getUserProfile() async {
    try {
      final userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('AuthService.getUserProfile Error: $e');
      return null;
    }
  }

  // ==================== KAYIT ====================

  /// Yeni müşteri hesabı oluşturur ve Firestore'a kaydeder.
  ///
  /// Mobile App'te kullanıcılar yalnızca 'customer' rolünde kayıt olabilir.
  /// Admin / yönetici rolleri yalnızca web yönetim panelinden oluşturulabilir.
  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String name,
    required String surname,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final userId = cred.user!.uid;

      final newUser = UserModel(
        uid: userId,
        fullName: '$name $surname',
        email: email,
        phone: '',
        role: 'customer', // Mobil uygulamada yalnızca customer rolü oluşturulabilir
        companyId: '',
        registeredCompanies: [],
        tcNo: '',
        selectedCity: '',
        profileImage: null,
        isDeleted: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(newUser.toJson());
      return newUser;
    } catch (e) {
      debugPrint('AuthService.registerUser Error: $e');
      throw Exception("Kayıt başarısız: ${e.toString()}");
    }
  }

  // ==================== GİRİŞ ====================

  /// E-posta ve şifre ile giriş yapar; admin rolleri için hata fırlatır.
  ///
  /// Admin ve super_admin rolleri yalnızca web panelinde kullanılabilir.
  /// Bu rollerle giriş denemesi oturum kapatılarak Exception fırlatılır.
  Future<UserModel?> loginAndCheckAuth(String email, String password, String companyId) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userId = cred.user!.uid;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('Kullanıcı profili bulunamadı. Lütfen tekrar kayıt olun.');
      }

      final user = UserModel.fromFirestore(doc);

      if (user.role == 'admin' || user.role == 'super_admin') {
        await _auth.signOut();
        throw Exception(
          'Admin hesaplar web panelinde kullanılır. Lütfen web admin panelini ziyaret edin.',
        );
      }

      return user;
    } on FirebaseException catch (e) {
      debugPrint('AuthService.loginAndCheckAuth FirebaseException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService.loginAndCheckAuth Error: $e');
      rethrow;
    }
  }

  /// Guide girişini Firebase Auth üzerinden yapar.
  ///
  /// Guide hesapları Firebase Auth'da `GUIDE-ID@guide.turassist` formatındaki
  /// sentetik e-posta ile tutulur. Kullanıcı yalnızca Guide ID girer;
  /// bu metot otomatik olarak sentetik e-postayı üretir ve Auth'a gönderir.
  /// Giriş başarılıysa kullanıcı profili `users` Firestore koleksiyonundan
  /// okunarak döndürülür.
  Future<UserModel?> guideLogin(String guideId, String password) async {
    final syntheticEmail = '${guideId.trim()}@guide.turassist';
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: syntheticEmail,
        password: password,
      );
      final userId = cred.user!.uid;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('guide-profile-not-found');
      }

      final user = UserModel.fromFirestore(doc);
      if (user.role != 'guide') {
        await _auth.signOut();
        throw Exception('not-a-guide');
      }

      return user;
    } on FirebaseException catch (e) {
      debugPrint('AuthService.guideLogin FirebaseException: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService.guideLogin Error: $e');
      rethrow;
    }
  }

  /// Customer (fiziksel satış müşterisi) girişini Firebase Auth üzerinden yapar.
  ///
  /// Müşteri hesapları `@customer.turassist` domainli sentetik e-posta ile
  /// Firebase Auth'da tutulur. Firestore `users` koleksiyonunda profili varsa
  /// oradan okur; yoksa Firebase Auth verisinden minimal bir [UserModel] oluşturur.
  Future<UserModel?> customerLogin(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final userId = cred.user!.uid;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }

      // Firestore profili henüz oluşturulmamış sentetik müşteri hesapları
      // için Firebase Auth bilgilerinden minimal bir model döndür.
      return UserModel(
        uid: userId,
        fullName: cred.user!.displayName ?? 'Müşteri',
        email: email,
        phone: '',
        role: 'customer',
        companyId: '',
        registeredCompanies: [],
        tcNo: '',
        selectedCity: '',
        profileImage: null,
        isDeleted: false,
        createdAt: DateTime.now(),
      );
    } on FirebaseException catch (e) {
      debugPrint('AuthService.customerLogin FirebaseException: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService.customerLogin Error: $e');
      rethrow;
    }
  }

  // ==================== ÇIKIŞ & SIFIRLA ====================

  /// Mevcut Firebase oturumunu kapatır.
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService.logout Error: $e');
      throw Exception("Çıkış başarısız");
    }
  }

  /// Verilen e-posta adresine şifre sıfırlama bağlantısı gönderir.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('AuthService.resetPassword Error: $e');
      throw Exception("Şifre sıfırlama hatası");
    }
  }

  // ==================== YETKİ KONTROLÜ ====================

  /// Kullanıcının belirtilen şirkete erişim yetkisi olup olmadığını kontrol eder.
  ///
  /// Super admin tüm şirketlere erişebilir.
  Future<bool> isAuthorizedForCompany(String userId, String companyId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return false;

    final user = UserModel.fromFirestore(userDoc);
    if (user.role == 'super_admin') return true;
    return user.registeredCompanies.contains(companyId);
  }

  // ==================== REHBERİ ÇÖZÜMLEME ====================

  /// UID'ye göre rehberin veya kullanıcının tam adını çözer.
  ///
  /// Önce 'users', bulamazsa 'guides' koleksiyonunu sorgular.
  /// Her ikisinde de bulunamazsa [defaultName] parametresi döner.
  Future<String> getGuideFullName(String uid, {String defaultName = 'Tur Sorumlusu'}) async {
    if (uid.isEmpty) return defaultName;

    // 1. Önce users koleksiyonunu dene (Firebase Auth kullanıcıları)
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      final name = userDoc.data()?['fullName']?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    }

    // 2. guides koleksiyonuna bak (Auth'suz rehberler)
    final guideDoc = await _firestore.collection('guides').doc(uid).get();
    if (guideDoc.exists) {
      final name = guideDoc.data()?['fullName']?.toString().trim() ?? '';
      if (name.isNotEmpty) return name;
    }

    return defaultName;
  }
}
