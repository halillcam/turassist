import 'package:flutter/material.dart';

import '../../../../config/colors.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
    super.key,
    required this.showPasswordAction,
    required this.notificationsEnabled,
    required this.onEditProfile,
    required this.onChangePassword,
    required this.onToggleNotifications,
  });

  final bool showPasswordAction;
  final bool notificationsEnabled;
  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;
  final ValueChanged<bool> onToggleNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Profili Düzenle',
            onTap: onEditProfile,
          ),
          const _DividerLine(),
          if (showPasswordAction) ...[
            _MenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Şifre Değiştir',
              onTap: onChangePassword,
            ),
            const _DividerLine(),
          ],
          _NotificationItem(enabled: notificationsEnabled, onChanged: onToggleNotifications),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.slate500, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!enabled),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (enabled ? AppColors.primary : AppColors.slate600).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  enabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                  color: enabled ? AppColors.primary : AppColors.slate500,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bildirimler',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled ? 'Bildirimler açık' : 'Bildirimler kapalı',
                      style: TextStyle(
                        color: enabled ? AppColors.primary : AppColors.slate500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
                inactiveThumbColor: AppColors.slate500,
                inactiveTrackColor: AppColors.slate700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(height: 1, color: AppColors.slate700.withOpacity(0.4)),
    );
  }
}
