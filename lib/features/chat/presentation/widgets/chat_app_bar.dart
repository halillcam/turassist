import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/colors.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({super.key, required this.title, required this.messageCount});

  final String title;
  final int messageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.8),
        border: const Border(bottom: BorderSide(color: AppColors.slate800)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.forum_outlined, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'GRUP SOHBETİ • $messageCount MESAJ',
                  style: const TextStyle(
                    color: AppColors.slate500,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
