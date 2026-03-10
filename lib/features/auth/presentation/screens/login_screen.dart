import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../../../widgets/index.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_surface_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _controller = Get.put(AuthController());
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _identityController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: false,
      child: Column(
        children: [
          const LoginHeader(),
          const SizedBox(height: 48),
          AuthSurfaceCard(child: _buildForm()),
          const SizedBox(height: 28),
          _buildGuideLink(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giriş Yap',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AuthInputField(
            label: 'Guide ID veya E-posta',
            hint: 'GUIDE-4821 veya eposta@ornek.com',
            prefixIcon: Icons.mail,
            controller: _identityController,
            validator: _controller.validateLoginIdentity,
          ),
          const SizedBox(height: 16),
          Obx(
            () => AuthInputField(
              label: 'Şifre',
              hint: 'Şifrenizi girin',
              prefixIcon: Icons.lock,
              controller: _passwordController,
              validator: _controller.validatePassword,
              obscureText: _controller.obscureText.value,
              suffixIcon: _controller.obscureText.value ? Icons.visibility_off : Icons.visibility,
              onSuffixIconPressed: _controller.togglePasswordVisibility,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Get.toNamed('/forgot-password'),
              child: const Text('Şifremi Unuttum'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Obx(
              () => ElevatedButton(
                onPressed: _controller.isLoading.value ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: _controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Giriş Yap'),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const DividerWithText(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Obx(
              () => ElevatedButton(
                onPressed: _controller.isGoogleLoading.value ? null : _controller.signInWithGoogle,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: _controller.isGoogleLoading.value
                    ? const CircularProgressIndicator(color: AppColors.slate900)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          GoogleIconWidget(),
                          SizedBox(width: 12),
                          Text('Google ile Giriş Yap', style: TextStyle(color: AppColors.slate900)),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Hesabın yok mu? ',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                children: [
                  TextSpan(
                    text: 'Kayıt Ol',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed('/signup'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Tur Sorumlusu musunuz? ', style: TextStyle(color: Colors.white.withOpacity(0.7))),
        GestureDetector(
          onTap: () => Get.toNamed('/guide-login'),
          child: const Text(
            'Buradan giriş yapın',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    _controller.login(_identityController.text.trim(), _passwordController.text, 'default');
  }
}
