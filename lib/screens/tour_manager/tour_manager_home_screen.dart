import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';

class TourManagerHomeScreen extends StatelessWidget {
  const TourManagerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Tur başlığı
                    _buildTourTitle(),
                    const SizedBox(height: 16),
                    // İstatistik kartları
                    _buildStatCards(),
                    const SizedBox(height: 16),
                    // Giriş durumu progress
                    _buildProgressCard(),
                    const SizedBox(height: 24),
                    // QR Tara butonu
                    _buildScanButton(),
                    const SizedBox(height: 28),
                    // Yönetim Araçları
                    _buildManagementTools(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(bottom: BorderSide(color: AppColors.slate800, width: 1)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.slate700),
                child: const Icon(Icons.person, color: AppColors.slate400, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'TurAssist',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Yönetici Portalı',
                  style: TextStyle(color: AppColors.slate400, fontSize: 12),
                ),
              ],
            ),
          ),
          // Notification bell
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined, color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 8),
          // Settings button
          GestureDetector(
            onTap: _showSettingsSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.slate800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings, color: AppColors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tur Başlığı ──
  Widget _buildTourTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Roma Gün Batımı Yürüyüşü',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 4),
      ],
    );
  }

  // ── İstatistik kartları ──
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(child: _statCard('TOPLAM KATILIMCI', '24', '%100 Doluluk', AppColors.success)),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'GİRİÅ YAPILDI',
            '18',
            '%75 Tamamlandı',
            AppColors.primary,
            suffix: '/24',
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, String badge, Color badgeColor, {String? suffix}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.slate400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              children: suffix != null
                  ? [
                      TextSpan(
                        text: suffix,
                        style: const TextStyle(
                          color: AppColors.slate400,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge,
            style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Giriş Durumu Progress ──
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Giriş Durumu',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '6 misafir bekleniyor',
                    style: TextStyle(color: AppColors.slate400, fontSize: 12),
                  ),
                ],
              ),
              const Text(
                '%75',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.75,
              minHeight: 10,
              backgroundColor: AppColors.slate700,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ── QR Tara Butonu ──
  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () {
          Get.toNamed('/qr-scanner');
        },
        icon: const Icon(Icons.qr_code_scanner, size: 28),
        label: const Text(
          'QR Kodu Tara',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
      ),
    );
  }

  // ── Yönetim Araçları ──
  Widget _buildManagementTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Yönetim Araçları',
          style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Katılımcıları Gör
        _managementTile(
          icon: Icons.checklist_rtl,
          iconColor: AppColors.success,
          iconBgColor: AppColors.primary.withOpacity(0.1),
          title: 'Katılımcıları Gör',
          subtitle: null,
          badges: [
            _badge(Icons.check_circle, '18 Giriş', AppColors.success),
            _badge(Icons.cancel, '6 Bekliyor', AppColors.error),
          ],
          showNotification: true,
          onTap: () {
            Get.toNamed('/tour-manager-customers');
          },
        ),
        const SizedBox(height: 12),
        // Duyuru Yap
        _managementTile(
          icon: Icons.campaign,
          iconColor: AppColors.warning,
          iconBgColor: AppColors.warning.withOpacity(0.12),
          title: 'Duyuru Yap',
          subtitle: 'Tüm katılımcılara bildirim gönder',
          onTap: () {
            Get.toNamed('/tour-manager-announcements');
          },
        ),
        const SizedBox(height: 12),
        // Sohbete Göz At
        _managementTile(
          icon: Icons.forum,
          iconColor: AppColors.success,
          iconBgColor: AppColors.success.withOpacity(0.12),
          title: 'Sohbete Göz At',
          subtitle: 'Gruptan 3 okunmamış mesaj',
          showDot: true,
          onTap: () {
            Get.toNamed('/tour-manager-chat');
          },
        ),
      ],
    );
  }

  Widget _managementTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    List<Widget>? badges,
    bool showNotification = false,
    bool showDot = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate700),
          ),
          child: Row(
            children: [
              // Icon with optional notification badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  if (showNotification)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardDark, width: 2),
                        ),
                        child: const Icon(Icons.person_off, color: AppColors.white, size: 8),
                      ),
                    ),
                  if (showDot)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardDark, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                      ),
                    ],
                    if (badges != null) ...[const SizedBox(height: 6), Row(children: badges)],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.slate400, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ── Settings Bottom Sheet ──
  void _showSettingsSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        decoration: const BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.slate600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Turu Bitir
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: Get.back,
                icon: const Icon(Icons.event_available, size: 20),
                label: const Text(
                  'Turu Bitir',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Turu bitirdiğinizde katılımcılardan değerlendirme istenir.',
              style: TextStyle(
                color: AppColors.slate500,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Çıkış Yap
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/login');
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.slate300,
                  side: BorderSide(color: AppColors.slate600),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
