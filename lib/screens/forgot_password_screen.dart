import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../config/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen e-posta adresinizi girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firebase password reset
      // await FirebaseAuth.instance
      //     .sendPasswordResetEmail(email: _emailController.text.trim());

      setState(() {
        _emailSent = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Şifre sıfırlama bağlantısı ${_emailController.text} adresine gönderildi',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
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
                  Colors.black.withValues(alpha: 0.4),
                  AppColors.darkBackground.withValues(alpha: 0.6),
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
                        color: AppColors.primary.withValues(alpha: 0.2),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
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
                      'ŞİFREMİ UNUTTUM',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Endişelenme, seni geri getirelim.',
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
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
                        color: Color.fromARGB(216, 44, 36, 27),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
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
                            // Açıklama Metni
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: Color(0xFFf48525), size: 20),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Kayıtlı e-posta adresini gir, şifre sıfırlama bağlantısı göndereceğiz.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFFCCCCCC),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            if (!_emailSent) ...[
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
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                    enabled: !_isLoading,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.black.withValues(alpha: 0.2),
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
                                          color: Colors.white.withValues(alpha: 0.1),
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
                                          color: Colors.white.withValues(alpha: 0.1),
                                          width: 1,
                                        ),
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Gönder Butonu
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _resetPassword,
                                  icon: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.send),
                                  label: Text(
                                    _isLoading ? 'Gönderiliyor...' : 'Sıfırlama Bağlantısı Gönder',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                    disabledBackgroundColor: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Başarılı Mesaj
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green.withValues(alpha: 0.1),
                                        border: Border.all(
                                          color: Colors.green.withValues(alpha: 0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        size: 40,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'E-posta Gönderildi!',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_emailController.text} adresine şifre sıfırlama bağlantısı gönderdik.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFFCCCCCC),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'E-postanı kontrol et ve linke tıkla.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _emailSent = false;
                                            _emailController.clear();
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          elevation: 8,
                                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                        ),
                                        child: const Text(
                                          'Başka Bir E-posta Dene',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                            text: 'Hatırladın mı? ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                          TextSpan(
                            text: 'Giriş Yap',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pop(context);
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
}
