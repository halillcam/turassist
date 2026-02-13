import 'package:flutter/material.dart';

class SocialButtonsRow extends StatelessWidget {
  final VoidCallback onGoogleTap;

  const SocialButtonsRow({super.key, required this.onGoogleTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onGoogleTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.1),
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDtLUNkaQ6gN6ipqmczk6u31A2QZdhC7bpvLfTODMKyHZQZqXqpWvT-qveLKkjN3WeKYPUAaMcl98_4a1VECPsJCPetAzrRUnjM1uA94pY0MCPEq1d8PsAqXV6p4CIV_K8iLM1Q8HuDHKXEIpEvJgmppnno5Z9IZu9WWdKGu_KhIgPRMSZm5MlyEI4gQaCNH3eFR018LIrT8ZPohWeZHtRl0sW1BOsdJllgOKPOFKVHJcAozH2DK1ccz4A9pfSK53MYPDeUr6AxnTnK',
              width: 20,
              height: 20,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.mail, size: 20);
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Google ile Kayıt Ol',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
