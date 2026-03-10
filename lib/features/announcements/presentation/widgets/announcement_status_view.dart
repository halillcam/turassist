import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class AnnouncementStatusView extends StatelessWidget {
  const AnnouncementStatusView({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (errorMessage.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.errorLight, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
          ],
        ),
      ),
    );
  }
}
