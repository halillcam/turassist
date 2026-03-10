import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.slate800.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.forum_outlined, color: AppColors.slate500, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Henüz mesaj yok',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
        ],
      ),
    );
  }
}
