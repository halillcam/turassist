import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../domain/entities/guide_dashboard_entity.dart';

class GuideDashboardHeader extends StatelessWidget {
  const GuideDashboardHeader({super.key, required this.dashboard});

  final GuideDashboardEntity dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dashboard.guideName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dashboard.tourTitle.isEmpty ? 'Atanmış tur yok' : dashboard.tourTitle,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: dashboard.progress,
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${dashboard.checkedInParticipants}/${dashboard.totalParticipants} misafir check-in yaptı',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
