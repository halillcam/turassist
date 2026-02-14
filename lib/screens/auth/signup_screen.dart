import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../controllers/login_controller.dart';
import '../../widgets/index.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final LoginController _loginController = Get.put(LoginController());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxBool _termsAccepted = false.obs;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with overlay (same as login screen)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAEguWPisfnT_X33mMr6kxaDGyh7ETatkfoerLRdOhHquvoz3v8SqwlcJLO_aQLBpcnlI12Z-aIGHXwtwNXtPsYUl37S2oS_UABCvjTvs2IcHMul2t0xMptYFhCCN2AnqsqviOFEqsanRRw5D-GD5VlV3yoGrT1D6Om4oxmPo59B7MQR6MOuuTeh5oPDhbLx87BxiLP9CDxd-D7J-0Lvyh90cCvis7IoTDz0rt0P_YoN0YNZ2j9hui_2pYSTwbWxEAMFTgh9iZbRTpt',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(color: Colors.black.withOpacity(0.65)),
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Header
                    const SignupHeader(),

                    const SizedBox(height: 20),

                    // Signup Card
                    BackdropFilter(
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
                            children: [
                              // Name Field
                              AuthInputField(
                                label: 'Ad Soyad',
                                hint: 'Adınız Soyadınız',
                                prefixIcon: Icons.person,
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ad Soyad gerekli';
                                  }
                                  if (value.length < 3) {
                                    return 'Ad Soyad en az 3 karakter olmalı';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Email Field
                              AuthInputField(
                                label: 'E-posta Adresi',
                                hint: 'eposta@ornek.com',
                                prefixIcon: Icons.mail,
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'E-posta adresi gerekli';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Geçerli bir e-posta adresi girin';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Password Field
                              Obx(
                                () => AuthInputField(
                                  label: 'Şifre',
                                  hint: 'Şifrenizi oluşturun',
                                  prefixIcon: Icons.lock,
                                  suffixIcon: _loginController.obscureText.value
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  obscureText: _loginController.obscureText.value,
                                  controller: _passwordController,
                                  onSuffixIconPressed: () {
                                    _loginController.obscureText.toggle();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Şifre gerekli';
                                    }
                                    if (value.length < 6) {
                                      return 'Şifre en az 6 karakter olmalı';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Terms Checkbox
                              TermsCheckbox(
                                isChecked: _termsAccepted,
                                onTermsTap: () {
                                  Get.snackbar(
                                    'Bilgi',
                                    'Kullanım Koşulları sayfasına yönlendirileceksiniz',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                onPrivacyTap: () {
                                  Get.snackbar(
                                    'Bilgi',
                                    'Gizlilik Politikası sayfasına yönlendirileceksiniz',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),

                              // Sign Up Button
                              _buildSignupButton(),
                              const SizedBox(height: 16),

                              // Login Link
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Zaten bir hesabınız var mı? ',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Giriş Yap',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Get.toNamed('/login');
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    const DividerWithText(text: 'VEYA'),

                    const SizedBox(height: 20),

                    // Social Buttons
                    SocialButtonsRow(onGoogleTap: _handleGoogleSignup),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(
        () => ElevatedButton(
          onPressed: _loginController.isLoading.value ? null : _handleSignup,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
            shadowColor: AppColors.primary.withOpacity(0.4),
            elevation: 12,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _loginController.isLoading.value
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Hesap Oluştur',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  void _handleSignup() {
    if (!_termsAccepted.value) {
      Get.snackbar(
        'Hata',
        'Lütfen şartları kabul edin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // İsim ve soyisim ayırma
      final fullName = _nameController.text.trim();
      final parts = fullName.split(RegExp(r'\s+'));
      final name = parts.first;
      final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      _loginController.register(
        _emailController.text.trim(),
        _passwordController.text,
        name,
        surname,
      );
    }
  }

  void _handleGoogleSignup() {
    _loginController.signInWithGoogle();
  }
}
