import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';
import '../../../../widgets/auth_input_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_surface_card.dart';

class GuideLoginScreen extends StatefulWidget {
  const GuideLoginScreen({super.key});

  @override
  State<GuideLoginScreen> createState() => _GuideLoginScreenState();
}

class _GuideLoginScreenState extends State<GuideLoginScreen> {
  final AuthController _controller = Get.put(AuthController());
  final TextEditingController _guideIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _guideIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: AuthSurfaceCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tur Sorumlusu Girişi',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              AuthInputField(
                label: 'Guide ID',
                hint: 'Örnek: GUIDE-4821',
                prefixIcon: Icons.badge,
                controller: _guideIdController,
                validator: _controller.validateGuideId,
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
                  suffixIcon: _controller.obscureText.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconPressed: _controller.togglePasswordVisibility,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
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
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    _controller.guideLogin(_guideIdController.text.trim(), _passwordController.text);
  }
}
