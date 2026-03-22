import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class AnnouncementComposeCard extends StatelessWidget {
  const AnnouncementComposeCard({
    super.key,
    required this.controller,
    required this.maxLength,
    required this.isSubmitting,
    required this.canSend,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final int maxLength;
  final bool isSubmitting;
  final bool canSend;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final textLength = controller.text.trim().length;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate900.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QR okutan katılımcılara duyuru gönder',
            style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Duyuru sadece tura check-in yapan katılımcılara iletilir.',
            style: TextStyle(color: AppColors.slate400, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: 5,
            maxLength: maxLength,
            style: const TextStyle(color: AppColors.white, fontSize: 15, height: 1.5),
            decoration: InputDecoration(
              hintText: 'Mesajınızı yazın...',
              hintStyle: const TextStyle(color: AppColors.slate500),
              filled: true,
              fillColor: AppColors.slate800.withOpacity(0.55),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$textLength / $maxLength',
              style: const TextStyle(color: AppColors.slate500, fontSize: 11),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isSubmitting || !canSend ? null : onSend,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('Duyuruyu Gönder'),
            ),
          ),
        ],
      ),
    );
  }
}
