import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class GuideStatsRow extends StatelessWidget {
  const GuideStatsRow({
    super.key,
    required this.total,
    required this.arrived,
    required this.pending,
  });

  final int total;
  final int arrived;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'TOPLAM', value: '$total', color: Colors.white),
        const SizedBox(width: 12),
        _StatCard(label: 'GELEN', value: '$arrived', color: AppColors.success),
        const SizedBox(width: 12),
        _StatCard(label: 'BEKLEYEN', value: '$pending', color: AppColors.error),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.slate700),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
