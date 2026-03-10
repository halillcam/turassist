import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/colors.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementListItem extends StatelessWidget {
  const AnnouncementListItem({super.key, required this.announcement});

  final AnnouncementEntity announcement;

  @override
  Widget build(BuildContext context) {
    final hasSender = announcement.senderName.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('dd MMM yyyy • HH:mm', 'tr_TR').format(announcement.createdAt),
            style: const TextStyle(
              color: AppColors.slate500,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasSender) ...[
            const SizedBox(height: 6),
            Text(
              announcement.senderName,
              style: const TextStyle(
                color: AppColors.slate300,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            announcement.message,
            style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.45),
          ),
        ],
      ),
    );
  }
}
