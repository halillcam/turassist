import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../../../widgets/auth_input_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_surface_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController _controller = Get.put(AuthController());
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RxBool _emailSent = false.obs;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildHero(),
          const SizedBox(height: 32),
          Obx(() => _emailSent.value ? _buildSuccessCard() : _buildFormCard()),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 20),
        const Text(
          'Şifremi Unuttum',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'E-posta adresinizi girin, size şifre sıfırlama bağlantısı göndereceğiz.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return AuthSurfaceCard(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AuthInputField(
              label: 'E-posta Adresi',
              hint: 'eposta@ornek.com',
              prefixIcon: Icons.mail,
              controller: _emailController,
              validator: _controller.validateEmail,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(
                () => ElevatedButton(
                  onPressed: _controller.isLoading.value ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: _controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sıfırlama Bağlantısı Gönder'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard() {
    return AuthSurfaceCard(
      child: Column(
        children: [
          const Icon(Icons.mark_email_read_rounded, color: AppColors.success, size: 42),
          const SizedBox(height: 16),
          const Text(
            'E-posta Gönderildi!',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Şifre sıfırlama bağlantısı ${_emailController.text.trim()} adresine gönderildi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.7), height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Get.offAllNamed('/login'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Giriş Yap'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    final sent = await _controller.forgotPassword(_emailController.text.trim());
    _emailSent.value = sent;
  }
}
