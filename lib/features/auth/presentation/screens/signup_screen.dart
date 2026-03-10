import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../../../widgets/index.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_surface_card.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController _controller = Get.put(AuthController());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    return AuthScaffold(
      child: Column(
        children: [
          const SignupHeader(),
          const SizedBox(height: 20),
          AuthSurfaceCard(child: _buildForm()),
          const SizedBox(height: 24),
          const DividerWithText(text: 'VEYA'),
          const SizedBox(height: 20),
          SocialButtonsRow(onGoogleTap: _controller.signInWithGoogle),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthInputField(
            label: 'Ad Soyad',
            hint: 'Adınız Soyadınız',
            prefixIcon: Icons.person,
            controller: _nameController,
            validator: _controller.validateFullName,
          ),
          const SizedBox(height: 16),
          AuthInputField(
            label: 'E-posta Adresi',
            hint: 'eposta@ornek.com',
            prefixIcon: Icons.mail,
            controller: _emailController,
            validator: _controller.validateEmail,
          ),
          const SizedBox(height: 16),
          Obx(
            () => AuthInputField(
              label: 'Şifre',
              hint: 'Şifrenizi oluşturun',
              prefixIcon: Icons.lock,
              controller: _passwordController,
              validator: _controller.validatePassword,
              obscureText: _controller.obscureText.value,
              suffixIcon: _controller.obscureText.value ? Icons.visibility_off : Icons.visibility,
              onSuffixIconPressed: _controller.togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 16),
          TermsCheckbox(isChecked: _termsAccepted),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Obx(
              () => ElevatedButton(
                onPressed: _controller.isLoading.value ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: _controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Hesap Oluştur'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Zaten bir hesabınız var mı? ',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                children: [
                  TextSpan(
                    text: 'Giriş Yap',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed('/login'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
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
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final fullName = _nameController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = fullName.split(' ');
    final name = parts.first;
    final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    _controller.register(_emailController.text.trim(), _passwordController.text, name, surname);
  }
}
