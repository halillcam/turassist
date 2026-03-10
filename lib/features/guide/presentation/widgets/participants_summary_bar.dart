import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class ParticipantsSummaryBar extends StatelessWidget {
  const ParticipantsSummaryBar({
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Row(
        children: [
          _SummaryItem(label: 'TOPLAM', value: '$total', color: Colors.white),
          _divider(),
          _SummaryItem(label: 'GELEN', value: '$arrived', color: AppColors.success),
          _divider(),
          _SummaryItem(label: 'BEKLEYEN', value: '$pending', color: AppColors.error),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 32, color: AppColors.slate700);
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
