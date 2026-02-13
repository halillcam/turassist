import 'package:flutter/material.dart';

class AuthInputField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onSuffixIconPressed;

  const AuthInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    required this.controller,
    this.validator,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            obscureText: obscureText,
            keyboardType: _getKeyboardType(),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              prefixIcon: Icon(prefixIcon, color: Colors.white.withOpacity(0.5)),
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixIconPressed,
                      child: Icon(suffixIcon, color: Colors.white.withOpacity(0.5)),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    if (hint.contains('E-posta') || hint.contains('eposta')) {
      return TextInputType.emailAddress;
    }
    return TextInputType.text;
  }
}
