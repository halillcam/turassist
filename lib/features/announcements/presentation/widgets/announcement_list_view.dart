import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../domain/entities/announcement_entity.dart';
import 'announcement_list_item.dart';

class AnnouncementListView extends StatelessWidget {
  const AnnouncementListView({super.key, required this.announcements, required this.emptyMessage});

  final List<AnnouncementEntity> announcements;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (announcements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            style: const TextStyle(color: AppColors.slate400, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: announcements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return AnnouncementListItem(announcement: announcements[index]);
      },
    );
  }
}
