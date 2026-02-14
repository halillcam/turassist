import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../controllers/login_controller.dart';
import '../../widgets/index.dart';

/// Şifre sıfırlama ekranı.
///
/// Kullanıcıdan e-posta adresi alır ve Firebase üzerinden
/// şifre sıfırlama bağlantısı gönderir.
/// Başarılı gönderim sonrası bilgilendirme kartı gösterir.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ─── Sabitler ───
  static const _backgroundImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAEguWPisfnT_X33mMr6kxaDGyh7ETatkfoerLRdOhHquvoz3v8SqwlcJLO_aQLBpcnlI12Z-aIGHXwtwNXtPsYUl37S2oS_UABCvjTvs2IcHMul2t0xMptYFhCCN2AnqsqviOFEqsanRRw5D-GD5VlV3yoGrT1D6Om4oxmPo59B7MQR6MOuuTeh5oPDhbLx87BxiLP9CDxd-D7J-0Lvyh90cCvis7IoTDz0rt0P_YoN0YNZ2j9hui_2pYSTwbWxEAMFTgh9iZbRTpt';

  // ─── Controller & State ───
  final LoginController _loginController = Get.put(LoginController());
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxBool _emailSent = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    _buildBackButton(),
                    const SizedBox(height: 40),
                    _buildHeaderIcon(),
                    const SizedBox(height: 32),
                    _buildTitle(),
                    const SizedBox(height: 40),
                    Obx(() => _emailSent.value ? _buildSuccessCard() : _buildFormCard()),
                    const SizedBox(height: 24),
                    _buildBackToLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Arka Plan ───

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(_backgroundImageUrl), fit: BoxFit.cover),
        ),
        child: Container(color: Colors.black.withOpacity(0.65)),
      ),
    );
  }

  // ─── Geri Butonu ───

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: GestureDetector(
        onTap: () => Get.back(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // ─── Başlık İkonu ───

  Widget _buildHeaderIcon() {
    return Container(
      width: 100,
      height: 100,
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
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 48),
    );
  }

  // ─── Başlık Metni ───

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Şifremi Unuttum',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'E-posta adresinizi girin, size şifre sıfırlama\nbağlantısı göndereceğiz.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  // ─── Form Kartı ───

  Widget _buildFormCard() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthInputField(
                label: 'E-posta Adresi',
                hint: 'eposta@ornek.com',
                prefixIcon: Icons.mail,
                controller: _emailController,
                validator: _validateEmail,
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(
        () => ElevatedButton(
          onPressed: _loginController.isLoading.value ? null : _handleResetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            shadowColor: AppColors.primary.withOpacity(0.4),
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _loginController.isLoading.value
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sıfırlama Bağlantısı Gönder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── Başarı Kartı ───

  Widget _buildSuccessCard() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            _buildSuccessIcon(),
            const SizedBox(height: 20),
            const Text(
              'E-posta Gönderildi!',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Şifre sıfırlama bağlantısı ${_emailController.text} adresine gönderildi.\n'
              'Lütfen e-posta kutunuzu kontrol edin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 12),
            _buildSpamWarning(),
            const SizedBox(height: 24),
            _buildRetryButton(),
            const SizedBox(height: 16),
            _buildGoToLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.success.withOpacity(0.15)),
      child: const Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 32),
    );
  }

  Widget _buildSpamWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'E-postayı bulamıyorsanız spam/gereksiz klasörünü kontrol edin.',
              style: TextStyle(color: AppColors.warning.withOpacity(0.9), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => _emailSent.value = false,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Tekrar Gönder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildGoToLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Get.offAllNamed('/login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Giriş Yap',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.login_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Alt Bağlantı ───

  Widget _buildBackToLoginLink() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.6), size: 18),
          const SizedBox(width: 8),
          Text(
            'Giriş ekranına dön',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ─── Yardımcı Metotlar ───

  /// E-posta alanı doğrulama kuralı.
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'E-posta adresi gerekli';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  /// Şifre sıfırlama isteği gönderir.
  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      await _loginController.forgotPassword(_emailController.text.trim());
      _emailSent.value = true;
    }
  }
}
