import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../core/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.initials, required this.user});

  final String initials;
  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final phone = user?.phone ?? '';

    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.fullName ?? 'Kullanıcı',
          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(user?.email ?? '', style: const TextStyle(color: AppColors.slate400, fontSize: 14)),
        if (phone.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(phone, style: const TextStyle(color: AppColors.slate500, fontSize: 13)),
        ],
      ],
    );
  }
}
