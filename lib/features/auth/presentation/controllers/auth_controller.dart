import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';
import '../../../../core/session/session_cleanup_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/sign_in_with_google_use_case.dart';

/// Auth feature'ın tüm presentation kararlarını taşır.
class AuthController extends GetxController {
  AuthController({AuthRepository? repository}) : _repository = repository ?? AuthRepositoryImpl() {
    _loginUseCase = LoginUseCase(_repository);
    _registerUseCase = RegisterUseCase(_repository);
    _forgotPasswordUseCase = ForgotPasswordUseCase(_repository);
    _googleUseCase = SignInWithGoogleUseCase(_repository);
    _logoutUseCase = LogoutUseCase(_repository, SessionCleanupService());
  }

  final AuthRepository _repository;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final ForgotPasswordUseCase _forgotPasswordUseCase;
  late final SignInWithGoogleUseCase _googleUseCase;
  late final LogoutUseCase _logoutUseCase;

  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool obscureText = true.obs;

  static final RegExp _guideIdPattern = RegExp(r'^[A-Za-z0-9\-]+$');
  static final RegExp _emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  void togglePasswordVisibility() => obscureText.value = !obscureText.value;

  String? validateLoginIdentity(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'E-posta veya Guide ID gerekli';
    }
    if (!input.contains('@') && _guideIdPattern.hasMatch(input)) {
      return null;
    }
    if (!_emailPattern.hasMatch(input)) {
      return 'Geçerli bir e-posta veya Guide ID girin';
    }
    return null;
  }

  String? validateGuideId(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Guide ID gerekli';
    }
    if (!_guideIdPattern.hasMatch(input)) {
      return 'Guide ID yalnızca harf, rakam ve tire içerebilir';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    if (!_emailPattern.hasMatch(input)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final input = value ?? '';
    if (input.isEmpty) {
      return 'Şifre gerekli';
    }
    if (input.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  String? validateFullName(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Ad Soyad gerekli';
    }
    if (input.length < 3) {
      return 'Ad Soyad en az 3 karakter olmalı';
    }
    return null;
  }

  Future<void> login(String identity, String password, String companyId) async {
    try {
      isLoading.value = true;
      final session = await _loginUseCase.execute(
        identity: identity,
        password: password,
        companyId: companyId,
      );
      if (session == null) {
        return;
      }

      _showSuccess('Hoşgeldiniz ${session.user.fullName}');
      await _handleAuthenticatedSession(session);
    } catch (error) {
      _showError(_friendlyErrorMessage(error));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> guideLogin(String guideId, String password) {
    return login(guideId, password, 'default');
  }

  Future<void> customerDomainLogin(String email, String password) {
    return login(email, password, 'default');
  }

  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      final session = await _googleUseCase.execute();
      if (session == null) {
        return;
      }

      _showSuccess('Hoşgeldiniz ${session.user.fullName}');
      await _handleAuthenticatedSession(session);
    } catch (error) {
      _showError(_friendlyErrorMessage(error));
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name, String surname) async {
    try {
      isLoading.value = true;
      final fullName = '$name $surname'.trim();
      final user = await _registerUseCase.execute(
        fullName: fullName,
        email: email,
        password: password,
      );
      if (user == null) {
        return;
      }

      _showSuccess('Kayıt başarılı! Lütfen e-posta adresinizi doğrulayın.');
      Get.offAllNamed(AppRoutes.emailVerification);
    } catch (error) {
      _showError(_friendlyErrorMessage(error));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _forgotPasswordUseCase.execute(email);
      _showSuccess('Şifre sıfırlama linki ${email.trim()} adresine gönderildi.');
      return true;
    } catch (error) {
      _showError(_friendlyErrorMessage(error));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout({String redirectRoute = AppRoutes.tourList}) async {
    try {
      isLoading.value = true;
      await _logoutUseCase.execute(redirectRoute: redirectRoute);
    } catch (error) {
      _showError('Çıkış işlemi sırasında bir sorun oluştu. Lütfen tekrar deneyin.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleAuthenticatedSession(AuthSessionEntity session) async {
    if (session.requiresEmailVerification) {
      Get.offAllNamed(AppRoutes.emailVerification);
      return;
    }

    if (session.user.isGuide) {
      await _repository.persistGuideSession(session.user);
      Get.offAllNamed(AppRoutes.guideDashboard);
      return;
    }

    await _repository.clearGuideSession();
    if (session.isSyntheticCustomer) {
      Get.offAllNamed(AppRoutes.myTours);
      return;
    }

    final savedCity = await _repository.getSelectedCity() ?? '';
    if (savedCity.isNotEmpty) {
      Get.offAllNamed(AppRoutes.tourList);
      return;
    }
    Get.offAllNamed(AppRoutes.citySelection);
  }

  String _friendlyErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();
    if (message.contains('user-not-found')) {
      return 'Bu Guide ID veya e-posta adresiyle kayıtlı bir hesap bulunamadı.';
    }
    if (message.contains('wrong-password') || message.contains('invalid-credential')) {
      return 'Guide ID/e-posta veya şifre hatalı. Lütfen tekrar deneyin.';
    }
    if (message.contains('email-already-in-use')) {
      return 'Bu e-posta adresi zaten kullanılıyor.';
    }
    if (message.contains('weak-password')) {
      return 'Şifre çok zayıf. En az 6 karakter kullanın.';
    }
    if (message.contains('invalid-email')) {
      return 'Geçersiz e-posta adresi.';
    }
    if (message.contains('too-many-requests')) {
      return 'Çok fazla deneme yapıldı. Lütfen birkaç dakika sonra tekrar deneyin.';
    }
    if (message.contains('network-request-failed') || message.contains('network')) {
      return 'İnternet bağlantınızı kontrol edin.';
    }
    if (message.contains('user-disabled')) {
      return 'Bu hesap devre dışı bırakılmış. Lütfen yönetici ile iletişime geçin.';
    }
    if (message.contains('operation-not-allowed')) {
      return 'Bu işlem şu an kullanılamıyor.';
    }
    if (message.contains('requires-recent-login')) {
      return 'Güvenlik nedeniyle yeniden giriş yapmanız gerekiyor.';
    }
    if (message.contains('admin hesaplar')) {
      return 'Bu hesap mobil uygulamada kullanılamaz. Web admin panelini kullanınız.';
    }
    if (message.contains('guide-profile-not-found') || message.contains('not-a-guide')) {
      return 'Guide profili bulunamadı. Lütfen yönetici ile iletişime geçin.';
    }
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Başarılı',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success.withOpacity(0.85),
      colorText: Colors.white,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Hata',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error.withOpacity(0.9),
      colorText: Colors.white,
    );
  }
}
