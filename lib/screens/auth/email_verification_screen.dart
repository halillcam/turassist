import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';

/// Kayıt sonrası e-posta doğrulama ekranı.
///
/// Kullanıcıya doğrulama maili gönderildiğini gösterir.
/// - Her 5 saniyede bir otomatik olarak doğrulama durumunu kontrol eder.
/// - "Doğruladım" butonuyla manuel kontrol yapılabilir.
/// - Doğrulama maili 60 saniye cooldown ile tekrar gönderilebilir.
/// - Doğrulama tamamlanınca kullanıcı login ekranına yönlendirilir.
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  // ─── Sabitler ───
  static const _autoCheckInterval = Duration(seconds: 5);
  static const _resendCooldownSeconds = 60;

  // ─── State ───
  final RxBool _isResending = false.obs;
  final RxBool _isChecking = false.obs;
  final RxInt _resendCooldown = 0.obs;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  // ─── Lifecycle ───

  @override
  void initState() {
    super.initState();
    _startAutoCheck();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  /// Periyodik olarak e-posta doğrulama durumunu kontrol eder.
  void _startAutoCheck() {
    _autoCheckTimer = Timer.periodic(_autoCheckInterval, (_) {
      _checkEmailVerified(silent: true);
    });
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildMailIcon(),
              const SizedBox(height: 40),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildSubtitle(),
              const SizedBox(height: 16),
              _buildSpamWarning(),
              const Spacer(flex: 2),
              _buildVerifyButton(),
              const SizedBox(height: 16),
              _buildResendButton(),
              const SizedBox(height: 16),
              _buildSwitchAccountLink(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // ─── UI Bileşenleri ───

  Widget _buildMailIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(Icons.mark_email_unread_rounded, color: Colors.white, size: 56),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'E-postanızı Doğrulayın',
      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSubtitle() {
    final email = _currentUser?.email;
    final message = email != null
        ? '$email adresine bir doğrulama bağlantısı gönderdik.\n\n'
              'Lütfen e-posta kutunuzu kontrol edin ve bağlantıya tıklayarak hesabınızı doğrulayın.'
        : 'E-posta adresinize bir doğrulama bağlantısı gönderdik.';

    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 15, height: 1.6),
    );
  }

  Widget _buildSpamWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'E-postayı bulamıyorsanız spam/gereksiz klasörünü kontrol edin.',
              style: TextStyle(color: AppColors.warning.withOpacity(0.9), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// "Doğruladım, Giriş Yap" butonu.
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(
        () => ElevatedButton(
          onPressed: _isChecking.value ? null : () => _checkEmailVerified(silent: false),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: _isChecking.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Doğruladım, Giriş Yap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Doğrulama e-postasını tekrar gönder butonu (cooldown destekli).
  Widget _buildResendButton() {
    return Obx(() {
      final isCoolingDown = _resendCooldown.value > 0;
      final isDisabled = _isResending.value || isCoolingDown;

      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          onPressed: isDisabled ? null : _resendVerificationEmail,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isCoolingDown ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: _isResending.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  isCoolingDown
                      ? 'Tekrar göndermek için ${_resendCooldown.value}s bekleyin'
                      : 'Doğrulama E-postasını Tekrar Gönder',
                  style: TextStyle(
                    color: isCoolingDown
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      );
    });
  }

  /// "Farklı bir hesap ile giriş yap" bağlantısı.
  Widget _buildSwitchAccountLink() {
    return GestureDetector(
      onTap: _signOutAndGoToLogin,
      child: Text(
        'Farklı bir hesap ile giriş yap',
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 14,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  // ─── İş Mantığı (Business Logic) ───

  /// Firebase üzerinden e-posta doğrulama durumunu kontrol eder.
  ///
  /// [silent] true ise, doğrulanmamış durumda snackbar göstermez.
  /// Doğrulanmışsa oturumu kapatıp login ekranına yönlendirir.
  Future<void> _checkEmailVerified({required bool silent}) async {
    try {
      _isChecking.value = true;
      await _currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        _autoCheckTimer?.cancel();
        Get.snackbar(
          'Başarılı',
          'E-posta adresiniz doğrulandı! Hoşgeldiniz.',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        await FirebaseAuth.instance.signOut();
        Get.offAllNamed('/login');
      } else if (!silent) {
        Get.snackbar(
          'Uyarı',
          'E-posta adresiniz henüz doğrulanmadı. Lütfen e-postanızı kontrol edin.',
          backgroundColor: AppColors.warning,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      if (!silent) {
        Get.snackbar(
          'Hata',
          'Doğrulama kontrolü sırasında bir hata oluştu.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      _isChecking.value = false;
    }
  }

  /// Doğrulama e-postasını tekrar gönderir ve cooldown başlatır.
  Future<void> _resendVerificationEmail() async {
    try {
      _isResending.value = true;
      await _currentUser?.sendEmailVerification();

      Get.snackbar(
        'Başarılı',
        'Doğrulama e-postası tekrar gönderildi.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      _startResendCooldown();
    } catch (e) {
      Get.snackbar(
        'Hata',
        'E-posta gönderilemedi. Lütfen daha sonra tekrar deneyin.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isResending.value = false;
    }
  }

  /// Tekrar gönder butonu için geri sayım başlatır.
  void _startResendCooldown() {
    _resendCooldown.value = _resendCooldownSeconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _resendCooldown.value--;
      if (_resendCooldown.value <= 0) timer.cancel();
    });
  }

  /// Oturumu kapatıp login ekranına yönlendirir.
  Future<void> _signOutAndGoToLogin() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/login');
  }
}
