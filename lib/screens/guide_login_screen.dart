import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:turassist/config/colors.dart';

class GuideLoginScreen extends StatefulWidget {
  const GuideLoginScreen({super.key});

  @override
  _GuideLoginScreenState createState() => _GuideLoginScreenState();
}

class _GuideLoginScreenState extends State<GuideLoginScreen> {
  final TextEditingController guideIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        title: const Text(
          'Tur Sorumlusu Girişi',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.person_outline, size: 40, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Tur Sorumlusu ID',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: guideIdController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'ID girin',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Şifre',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Şifrenizi girin',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.darkCard,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    child: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate credentials and login
                    if (guideIdController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                      Get.toNamed('/guide-dashboard', arguments: guideIdController.text);
                    } else {
                      Get.snackbar('Hata', 'Lütfen ID ve Şifre giriniz');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    guideIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
