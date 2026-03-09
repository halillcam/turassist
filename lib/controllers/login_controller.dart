import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_routes.dart';
import '../config/colors.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/google_auth_service.dart';

/// Kimlik doğrulama işlemlerini yöneten ana controller.
///
/// Sorumlulukları:
/// - E-posta / şifre ile giriş ve kayıt
/// - Google Sign-In
/// - Tur sorumlusu (rehber) girişi
/// - Şifre sıfırlama
/// - Oturum kapatma
/// - Giriş sonrası doğru sayfaya yönlendirme
class LoginController extends GetxController {
  // ─── Servisler ───
  final FirebaseService _firebaseService = FirebaseService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  // ─── Reactive State ───
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool obscureText = true.obs;

  // ─── Şifre Görünürlüğü ───

  /// Şifre alanının görünürlüğünü değiştirir.
  void togglePasswordVisibility() => obscureText.value = !obscureText.value;

  // ─── Giriş İşlemleri ───

  /// E-posta veya Guide ID ile giriş yapar.
  ///
  /// İş akışı:
  /// 1. Guide ID tespiti: @ içermiyor ve yalnızca harf/rakam/tire ise guide girişi
  /// 2. Aksi halde normal Firebase Auth e-posta girişi
  /// 3. E-posta doğrulama kontrolü (yalnızca normal kullanıcılar için)
  /// 4. Başarılıysa role ve şehir seçimine göre yönlendirme
  Future<void> login(String emailOrGuideId, String password, String companyId) async {
    // Guide ID tespiti: @ yoksa ve yalnızca harf/rakam/tire içeriyorsa
    if (!emailOrGuideId.contains('@') && RegExp(r'^[A-Za-z0-9\-]+$').hasMatch(emailOrGuideId)) {
      await guideLogin(emailOrGuideId, password);
      return;
    }

    // Sentetik müşteri domain'i: doğrudan customerLogin akışına yönlendir
    if (emailOrGuideId.toLowerCase().endsWith('@customer.turassist')) {
      await customerDomainLogin(emailOrGuideId, password);
      return;
    }

    try {
      isLoading.value = true;

      final UserModel? user = await _firebaseService.loginAndCheckAuth(
        emailOrGuideId,
        password,
        companyId,
      );

      if (user == null) return;

      // Sentetik e-posta domain'leri için e-posta doğrulaması atlanır.
      // Firebase Auth'daki gerçek email kullanılır (Firestore'daki alana bağımlı değil).
      //   *@guide.turassist    → guide hesapları
      //   *@customer.turassist → fiziksel satış müşteri hesapları
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final authEmail = firebaseUser?.email ?? '';
      final isSyntheticEmail =
          authEmail.endsWith('@guide.turassist') || authEmail.endsWith('@customer.turassist');

      if (!isSyntheticEmail && !firebaseUser!.emailVerified) {
        Get.offAllNamed('/email-verification');
        return;
      }

      _showSuccess('Hoşgeldiniz ${user.fullName}');
      await _navigateAfterAuth(user);
    } catch (e) {
      _showError(_friendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Tur sorumlusu (rehber) girişi yapar.
  ///
  /// Rehberler kendi ID ve şifreleriyle giriş yapar.
  Future<void> guideLogin(String guideId, String password) async {
    try {
      isLoading.value = true;

      final UserModel? user = await _firebaseService.guideLogin(guideId, password);

      if (user == null) return;

      _showSuccess('Hoşgeldiniz ${user.fullName}');
      await _navigateAfterAuth(user);
    } catch (e) {
      _showError(_friendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Sentetik @customer.turassist domain hesabıyla giriş yapar.
  Future<void> customerDomainLogin(String email, String password) async {
    try {
      isLoading.value = true;

      final UserModel? user = await _firebaseService.customerLogin(email, password);

      if (user == null) return;

      _showSuccess('Hoşgeldiniz ${user.fullName}');
      await _navigateAfterAuth(user);
    } catch (e) {
      _showError(_friendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  /// Google hesabıyla giriş yapar.
  ///
  /// Kullanıcı Google Sign-In popup'ını iptal ederse sessizce döner.
  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;

      final UserModel? user = await _googleAuthService.signInWithGoogle();
      if (user == null) return; // Kullanıcı iptal etti

      _showSuccess('Hoşgeldiniz ${user.fullName}');
      await _navigateAfterAuth(user);
    } catch (e) {
      _showError(_friendlyErrorMessage(e));
    } finally {
      isGoogleLoading.value = false;
    }
  }

  // ─── Kayıt ───

  /// Yeni kullanıcı kaydı oluşturur.
  ///
  /// İş akışı:
  /// 1. Firebase Auth'da hesap oluştur ve Firestore'a kullanıcı bilgilerini kaydet
  /// 2. E-posta doğrulama bağlantısı gönder
  /// 3. Doğrulama ekranına yönlendir
  Future<void> register(String email, String password, String name, String surname) async {
    try {
      isLoading.value = true;

      final UserModel? user = await _firebaseService.registerUser(
        email: email,
        password: password,
        name: name,
        surname: surname,
      );

      if (user == null) return;

      // Doğrulama e-postası gönder
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      _showSuccess('Kayıt başarılı! Lütfen e-posta adresinizi doğrulayın.');
      Get.offAllNamed('/email-verification');
    } catch (e) {
      _showError(_friendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Şifre Sıfırlama ───

  /// Verilen e-posta adresine şifre sıfırlama bağlantısı gönderir.
  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _firebaseService.resetPassword(email);
      _showSuccess('Şifre sıfırlama linki $email adresine gönderildi.');
    } catch (e) {
      _showError(_friendlyErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Oturum Kapatma ───

  /// Hem Firebase hem Google oturumunu kapatır.
  ///
  /// Çıkış sonrası tur listesine yönlendirir (giriş zorunlu değil).
  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _googleAuthService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_guide_session');
      await prefs.remove('guide_id');
      await prefs.remove('guide_name');
      Get.offAllNamed('/tour-list');
    } catch (e) {
      _showError('Çıkış işlemi sırasında bir sorun oluştu. Lütfen tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Yönlendirme ───

  /// Giriş başarılı olduktan sonra kullanıcıyı doğru sayfaya yönlendirir.
  ///
  /// Yönlendirme mantığı:
  /// - Rehber → Rehber paneli
  /// - Admin/Super Admin → Hata mesajı (mobil kullanılamaz)
  /// - Müşteri → Şehir seçilmişse tur listesi, değilse şehir seçim ekranı
  Future<void> _navigateAfterAuth(UserModel user) async {
    final role = user.role.trim().toLowerCase();

    switch (role) {
      case 'guide':
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_guide_session', true);
        // Firestore tours.guideId → Firebase Auth UID formatında saklanır
        await prefs.setString('guide_id', user.uid);
        await prefs.setString('guide_name', user.fullName);
        Get.offAllNamed(AppRoutes.guideDashboard);
        return;

      case 'admin':
      case 'super_admin':
        _showError("Bu hesap mobil uygulamada kullanılamaz. Web admin panelini kullanınız.");
        Get.offAllNamed(AppRoutes.login);
        return;

      default:
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('is_guide_session');
        await prefs.remove('guide_id');
        await prefs.remove('guide_name');

        // Sentetik domain müşterileri (fiziksel satış) direkt Turlarım ekranına gider
        final authEmail = FirebaseAuth.instance.currentUser?.email ?? '';
        if (authEmail.endsWith('@customer.turassist')) {
          Get.offAllNamed(AppRoutes.myTours);
          return;
        }

        // Normal customer → şehir seçimi kontrol et
        final savedCity = prefs.getString('selected_city') ?? '';

        if (savedCity.isNotEmpty) {
          Get.offAllNamed(AppRoutes.tourList);
        } else {
          Get.offAllNamed(AppRoutes.citySelection);
        }
    }
  }

  // ─── Yardımcı Metotlar ───

  /// Firebase hata kodlarını kullanıcı dostu Türkçe mesajlara çevirir.
  ///
  /// Desteklenen hata kodları:
  /// - `user-not-found`, `wrong-password`, `invalid-credential`
  /// - `email-already-in-use`, `weak-password`, `invalid-email`
  /// - `too-many-requests`, `network-request-failed`, `user-disabled`
  /// - `operation-not-allowed`, `requires-recent-login`
  /// - Uygulama özel hata mesajları (admin, rehber)
  String _friendlyErrorMessage(dynamic error) {
    final msg = error.toString().toLowerCase();

    // Firebase Auth hata kodları
    if (msg.contains('user-not-found')) {
      return 'Bu Guide ID veya e-posta adresiyle kayıtlı bir hesap bulunamadı.';
    }
    if (msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'Guide ID/e-posta veya şifre hatalı. Lütfen tekrar deneyin.';
    }
    if (msg.contains('email-already-in-use')) {
      return 'Bu e-posta adresi zaten kullanılıyor.';
    }
    if (msg.contains('weak-password')) {
      return 'Şifre çok zayıf. En az 6 karakter kullanın.';
    }
    if (msg.contains('invalid-email')) {
      return 'Geçersiz e-posta adresi.';
    }
    if (msg.contains('too-many-requests')) {
      return 'Çok fazla deneme yapıldı. Lütfen birkaç dakika sonra tekrar deneyin.';
    }
    if (msg.contains('network-request-failed') || msg.contains('network')) {
      return 'İnternet bağlantınızı kontrol edin.';
    }
    if (msg.contains('user-disabled')) {
      return 'Bu hesap devre dışı bırakılmış. Lütfen yönetici ile iletişime geçin.';
    }
    if (msg.contains('operation-not-allowed')) {
      return 'Bu işlem şu an kullanılamıyor.';
    }
    if (msg.contains('requires-recent-login')) {
      return 'Güvenlik nedeniyle yeniden giriş yapmanız gerekiyor.';
    }

    // Uygulama özel mesajlar
    if (msg.contains('admin hesaplar')) {
      return 'Bu hesap mobil uygulamada kullanılamaz. Web admin panelini kullanınız.';
    }
    if (msg.contains('guide-profile-not-found') || msg.contains('tur sorumlusu bulunamadı')) {
      return 'Guide profili bulunamadı. Lütfen yönetici ile iletişime geçin.';
    }
    if (msg.contains('not-a-guide')) {
      return 'Bu hesap bir guide hesabı değil. Lütfen doğru giriş yöntemini seçin.';
    }
    if (msg.contains('şifre yanlış')) {
      return 'Guide ID veya şifre hatalı. Lütfen tekrar deneyin.';
    }

    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  /// Başarı snackbar'ı gösterir.
  void _showSuccess(String message) {
    Get.snackbar(
      'Başarılı',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success,
      colorText: Colors.white,
    );
  }

  /// Hata snackbar'ı gösterir.
  void _showError(String message) {
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
    );
  }
}
