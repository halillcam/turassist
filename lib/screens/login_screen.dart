import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../config/colors.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPassword = false;
  String _selectedRole = 'explorer';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // Arka Plan: Dağ Görselinin Üzerine Gradient
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuD0SJf2qW71qkO76id6SolhwfFUj7lOPFUUIxEO5TCQ6y57NPruMV7o3QC8VW5LBe6bwI4udV3oZzhJT8P8XFNhUIYa3ctojdzDTgKGAIPfTAaJJuHASkpEnNU_ifm91r858ePLvXVAXX-jNVDUNo3BUSXZxraL5bOh8RSDnqt1Jqs_QlD-NVzl8Taa6pWAO06X5zoSdQ7Il-QoyIsCYzKZxR7JRF0RRNjTyYt_MbICRvJT3cTrl_k3DbMAoTaZw1RK15XM-QIApHo',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  AppColors.darkBackground.withOpacity(0.6),
                  AppColors.darkBackground,
                ],
              ),
            ),
          ),

          // Ana İçerik
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Logo Bölümü
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.2),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.landscape_rounded,
                        size: 36,
                        color: Color(0xFFf48525),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Başlık
                    const Text(
                      'MACERA HUB',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Senin yolunu seç ve başla.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFFCCCCCC),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Ana Card
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        color: Color.fromARGB(216, 44, 36, 27),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rol Seçimi - Segmented Control
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Row(
                                children: [
                                  // Gezgin Butonu
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = 'explorer';
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'explorer'
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.hiking,
                                              size: 20,
                                              color: _selectedRole == 'explorer'
                                                  ? Colors.white
                                                  : const Color(0xFF999999),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Gezgin',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: _selectedRole == 'explorer'
                                                    ? Colors.white
                                                    : const Color(0xFF999999),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Rehber Butonu
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedRole = 'guide';
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _selectedRole == 'guide'
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.map,
                                              size: 20,
                                              color: _selectedRole == 'guide'
                                                  ? Colors.white
                                                  : const Color(0xFF999999),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Rehber',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: _selectedRole == 'guide'
                                                    ? Colors.white
                                                    : const Color(0xFF999999),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Email Input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'E-POSTA ADRESİ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _emailController,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.2),
                                    hintText: 'gezgin@macera.com',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.mail_outline,
                                      color: const Color(0xFF666666),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.primary, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Şifre Input
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ŞİFRE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: !_showPassword,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.black.withOpacity(0.2),
                                    hintText: '••••••••',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: const Color(0xFF666666),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                      child: Icon(
                                        _showPassword ? Icons.visibility : Icons.visibility_off,
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.primary, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Şifremi Unuttum?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFf48525),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Maceraya Başla Butonu
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Giriş mantığı
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text(
                                  'Maceraya Başla',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 8,
                                  shadowColor: AppColors.primary.withOpacity(0.4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    'BUNLARLA DEVAM ET',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF666666),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.white.withOpacity(0.1), height: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Sosyal Butonlar (Sadece Google)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google
                                _buildSocialButton(
                                  customChild: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: Image.asset(
                                      'assets/images/google_icon.png',
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 20,
                                        );
                                      },
                                    ),
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Footer
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Hesabın yok mu? ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                          TextSpan(
                            text: 'Topluluğa Katıl',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    IconData? icon,
    Widget? customChild,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Center(child: customChild ?? Icon(icon, color: Colors.white, size: 20)),
      ),
    );
  }
}
