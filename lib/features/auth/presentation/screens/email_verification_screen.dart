import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/app_routes.dart';
import '../../../../config/colors.dart';
import '../../../../core/session/session_cleanup_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/logout_use_case.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  static const _autoCheckInterval = Duration(seconds: 5);
  static const _resendCooldownSeconds = 60;

  final RxBool _isResending = false.obs;
  final RxBool _isChecking = false.obs;
  final RxInt _resendCooldown = 0.obs;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;
  final LogoutUseCase _logoutUseCase = LogoutUseCase(AuthRepositoryImpl(), SessionCleanupService());

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _autoCheckTimer = Timer.periodic(_autoCheckInterval, (_) => _checkEmailVerified(silent: true));
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = _currentUser?.email;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_rounded, color: AppColors.primary, size: 80),
              const SizedBox(height: 24),
              const Text(
                'E-postanızı Doğrulayın',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                email == null
                    ? 'E-posta adresinize bir doğrulama bağlantısı gönderdik.'
                    : '$email adresine doğrulama bağlantısı gönderdik.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.6)),
              ),
              const SizedBox(height: 32),
              Obx(
                () => ElevatedButton(
                  onPressed: _isChecking.value ? null : () => _checkEmailVerified(silent: false),
                  child: _isChecking.value
                      ? const CircularProgressIndicator()
                      : const Text('Doğruladım, Giriş Yap'),
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => OutlinedButton(
                  onPressed: _isResending.value || _resendCooldown.value > 0
                      ? null
                      : _resendVerificationEmail,
                  child: Text(
                    _resendCooldown.value > 0
                        ? 'Tekrar göndermek için ${_resendCooldown.value}s bekleyin'
                        : 'Doğrulama E-postasını Tekrar Gönder',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _signOutAndGoToLogin,
                child: const Text('Farklı bir hesap ile giriş yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkEmailVerified({required bool silent}) async {
    if (_currentUser == null) return;
    _isChecking.value = true;
    try {
      await _currentUser!.reload();
      if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
        Get.offAllNamed(AppRoutes.login);
        if (!silent) {
          Get.snackbar('Başarılı', 'E-posta doğrulandı. Giriş yapabilirsiniz.');
        }
      } else if (!silent) {
        Get.snackbar('Bekleniyor', 'E-posta henüz doğrulanmadı.');
      }
    } finally {
      _isChecking.value = false;
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_currentUser == null) return;
    _isResending.value = true;
    try {
      await _currentUser!.sendEmailVerification();
      _resendCooldown.value = _resendCooldownSeconds;
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_resendCooldown.value <= 1) {
          timer.cancel();
          _resendCooldown.value = 0;
        } else {
          _resendCooldown.value -= 1;
        }
      });
      Get.snackbar('Gönderildi', 'Doğrulama e-postası tekrar gönderildi.');
    } finally {
      _isResending.value = false;
    }
  }

  Future<void> _signOutAndGoToLogin() async {
    await _logoutUseCase.execute(redirectRoute: AppRoutes.login);
  }
}
