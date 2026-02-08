import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';

class TermsCheckbox extends StatelessWidget {
  final RxBool isChecked;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  const TermsCheckbox({Key? key, required this.isChecked, this.onTermsTap, this.onPrivacyTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => isChecked.toggle(),
            child: Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 4, right: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(4),
                color: isChecked.value ? Color(0xFF137fec) : Colors.transparent,
              ),
              child: isChecked.value ? Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: '',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                children: [
                  TextSpan(
                    text: 'Kullanım Koşullarını',
                    style: TextStyle(
                      color: Color(0xFF137fec),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                  ),
                  TextSpan(text: ' ve '),
                  TextSpan(
                    text: 'Gizlilik Politikasını',
                    style: TextStyle(
                      color: Color(0xFF137fec),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                  ),
                  TextSpan(text: ' kabul ediyorum.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
