import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Google Sign-In işlemlerini yöneten servis.
/// Firebase Auth + Firestore entegrasyonu ile çalışır.
/// google_sign_in v7.x API'sini kullanır.
class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  /// GoogleSignIn SDK'sını başlatır. Uygulama yaşam döngüsünde bir kez çağrılmalı.
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _googleSignIn.initialize();
    _initialized = true;
  }

  /// Google ile giriş yap.
  /// - Kullanıcı daha önce kayıtlıysa Firestore'dan bilgilerini çeker.
  /// - İlk kez giriş yapıyorsa Firestore'a 'customer' rolüyle kaydeder.
  /// - Admin/Super Admin hesaplarını mobil uygulamada engeller.
  Future<UserModel?> signInWithGoogle() async {
    try {
      // 1. SDK'yı başlat
      await _ensureInitialized();

      // 2. Google Sign-In akışını başlat (v7: authenticate)
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      // 3. Authentication token'ını al
      final GoogleSignInAuthentication googleAuth = account.authentication;

      // 4. Firebase credential oluştur (v7'de sadece idToken var)
      final OAuthCredential credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      // 5. Firebase Auth ile giriş yap
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase girişi başarısız oldu.');
      }

      // 6. Firestore'da kullanıcıyı kontrol et
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        // Mevcut kullanıcı — rolünü kontrol et
        final existingUser = UserModel.fromFirestore(userDoc);

        if (existingUser.role == 'admin' || existingUser.role == 'super_admin') {
          await _auth.signOut();
          await _googleSignIn.signOut();
          throw Exception(
            'Admin hesaplar web panelinde kullanılır. Lütfen web admin panelini ziyaret edin.',
          );
        }

        if (existingUser.isDeleted) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          throw Exception('Bu hesap silinmiştir.');
        }

        return existingUser;
      } else {
        // Yeni kullanıcı — Firestore'a customer olarak kaydet
        final newUser = UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'İsimsiz Kullanıcı',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          role: 'customer',
          companyId: '',
          registeredCompanies: [],
          tcNo: '',
          selectedCity: '',
          profileImage: firebaseUser.photoURL,
          isDeleted: false,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toJson());

        return newUser;
      }
    } on GoogleSignInException catch (e) {
      // Kullanıcı iptal ettiyse null dön
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('Google Sign-In iptal edildi.');
        return null;
      }
      debugPrint('Google Sign-In Hatası: ${e.code} - ${e.description}');
      throw Exception(_getGoogleSignInErrorMessage(e.code));
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Hatası: ${e.code} - ${e.message}');
      throw Exception(_getFirebaseAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Google Sign-In Hatası: $e');
      rethrow;
    }
  }

  /// Google hesabından çıkış yap (Firebase + Google oturumlarını kapatır).
  Future<void> signOut() async {
    try {
      // Web'de (Chrome) google_sign_in v7 için önce initialize zorunlu.
      await _ensureInitialized();
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Google Sign-Out Hatası: $e');
      rethrow;
    }
  }

  /// Mevcut kullanıcının Google ile giriş yapıp yapmadığını kontrol eder.
  bool isGoogleUser() {
    final user = _auth.currentUser;
    if (user == null) return false;
    return user.providerData.any((provider) => provider.providerId == 'google.com');
  }

  /// Firebase Auth hata kodlarını Türkçe mesajlara çevirir.
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Bu e-posta adresi başka bir giriş yöntemiyle kayıtlı. Lütfen o yöntemle giriş yapın.';
      case 'invalid-credential':
        return 'Geçersiz kimlik bilgisi. Lütfen tekrar deneyin.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'operation-not-allowed':
        return 'Google ile giriş şu an devre dışı.';
      case 'network-request-failed':
        return 'İnternet bağlantısı bulunamadı. Lütfen bağlantınızı kontrol edin.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }

  /// GoogleSignIn hata kodlarını Türkçe mesajlara çevirir.
  String _getGoogleSignInErrorMessage(GoogleSignInExceptionCode code) {
    switch (code) {
      case GoogleSignInExceptionCode.interrupted:
        return 'Giriş işlemi kesintiye uğradı. Lütfen tekrar deneyin.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Google giriş arayüzü kullanılamıyor.';
      default:
        return 'Google ile giriş sırasında bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
