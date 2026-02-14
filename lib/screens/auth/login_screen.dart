import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../../controllers/login_controller.dart';
import '../../widgets/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _loginController = Get.put(LoginController());
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with overlay
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Geri butonu (profil üzerinden geldiyse)
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logo and Title
                    _buildHeader(),

                    const SizedBox(height: 60),

                    // Login Card with Glassmorphism
                    _buildLoginCard(),

                    const SizedBox(height: 32),

                    // Tour Manager Login Link
                    _buildTourManagerLink(),

                    const SizedBox(height: 16),

                    // Test butonları
                    _buildTestCitySelectionButton(),
                    const SizedBox(height: 8),
                    _buildTestTourDataButton(),
                    _buildTestTourManagerButton(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Başlık bölümü (Logo + Başlık)
  Widget _buildHeader() {
    return const LoginHeader();
  }

  // Giriş kartı (Glassmorphism)
  Widget _buildLoginCard() {
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
              Text(
                'Giriş Yap',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Email Field
              _buildEmailField(),
              const SizedBox(height: 16),

              // Password Field
              _buildPasswordField(),
              const SizedBox(height: 12),

              // Forgot Password Link
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    // Şifremi Unuttum ekranına yönlendir
                    Get.toNamed('/forgot-password');
                  },
                  child: Text(
                    'Şifremi Unuttum',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              _buildLoginButton(),
              const SizedBox(height: 24),

              // Divider
              _buildDivider(),
              const SizedBox(height: 20),

              // Google Sign In Button
              _buildGoogleSignInButton(),
              const SizedBox(height: 20),

              // Sign Up Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Hesabın yok mu? ',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Kayıt Ol',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed('/signup');
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
    );
  }

  // Email Input Field
  Widget _buildEmailField() {
    return AuthInputField(
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
    );
  }

  // Password Input Field
  Widget _buildPasswordField() {
    return Obx(
      () => AuthInputField(
        label: 'Şifre',
        hint: 'Şifrenizi girin',
        prefixIcon: Icons.lock,
        suffixIcon: _loginController.obscureText.value ? Icons.visibility_off : Icons.visibility,
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
    );
  }

  // Login Button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Obx(
        () => ElevatedButton(
          onPressed: _loginController.isLoading.value ? null : _handleLogin,
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  // Divider with "OR"
  Widget _buildDivider() {
    return const DividerWithText();
  }

  // Google Sign In Button
  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GoogleIconWidget(),
            const SizedBox(width: 12),
            Text(
              'Google ile Giriş Yap',
              style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Tour Manager Login Link (Bottom)
  Widget _buildTourManagerLink() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tur Sorumlusu musunuz? ',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed('/guide-login');
            },
            child: Row(
              children: [
                Text(
                  'Buradan giriş yapın',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 4),
                Icon(Icons.badge, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Login Fonksiyonu
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _loginController.login(
        _emailController.text.trim(),
        _passwordController.text,
        'default', // Default şirket ID
      );
    }
  }

  // Google Sign In Fonksiyonu
  void _handleGoogleSignIn() {
    _loginController.signInWithGoogle();
  }

  // ─── Test Butonları ───

  Widget _buildTestCitySelectionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Get.toNamed('/city-selection'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('TEST: Şehir Seçme Ekranına Git', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTestTourDataButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Get.toNamed('/test-tour'),
        icon: const Icon(Icons.science, color: Colors.white, size: 18),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        label: const Text(
          'TEST: Tur Verisi Ekle (Firestore)',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTestTourManagerButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Get.toNamed('/tour-manager-home'),
        icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.withOpacity(0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        label: const Text('TEST: Tur Sorumlusu Paneli', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
