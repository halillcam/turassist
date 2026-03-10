import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class GuideEmptyState extends StatelessWidget {
  const GuideEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        children: [
          const Icon(Icons.travel_explore_outlined, color: AppColors.slate400, size: 42),
          const SizedBox(height: 16),
          const Text(
            'Aktif tur bulunamadı',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.slate400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
