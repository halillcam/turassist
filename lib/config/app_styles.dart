import 'package:flutter/material.dart';

import 'colors.dart';

/// Uygulama genelinde tekrar eden TextStyle, BoxDecoration ve ButtonStyle sabitleri.
///
/// Ekranlarda inline tanımlamak yerine bu sınıftaki sabitler kullanılır;
/// stil güncellemeleri tek bir yerden etkili olur.
abstract class AppStyles {
  // ══════════════════════════════════════════════════════
  // Text Styles
  // ══════════════════════════════════════════════════════

  /// Ana ekran başlığı — AppBar title stili (18 px, bold, -0.3 spacing)
  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  /// Büyük sayfa başlığı (24 px, bold, -0.5 spacing) — dashboard tur adı gibi
  static const TextStyle pageTitleLarge = TextStyle(
    color: AppColors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  /// Bölüm başlığı (18 px, bold) — ana içerik grupları için
  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Kart başlığı (16 px, w600) — liste item başlıkları için
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Küçük kart başlığı (14 px, bold)
  static const TextStyle cardTitleSmall = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  /// Gövde metni (14 px, normal, h:1.5)
  static const TextStyle bodyText = TextStyle(color: AppColors.white, fontSize: 14, height: 1.5);

  /// Soluk gövde metni — açıklamalar ve ipuçları için (14 px, slate400)
  static const TextStyle bodyMuted = TextStyle(
    color: AppColors.slate400,
    fontSize: 14,
    height: 1.5,
  );

  /// Alt başlık (12 px, slate400) — ikincil bilgiler
  static const TextStyle subtitle = TextStyle(color: AppColors.slate400, fontSize: 12);

  /// Küçük etiket (11 px, w500, 0.5 spacing) — stat badge label
  static const TextStyle statLabel = TextStyle(
    color: AppColors.slate400,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  /// İstatistik rakamı (32 px, bold) — dashboard büyük sayılar
  static const TextStyle statValueLarge = TextStyle(
    color: AppColors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  /// Birincil renk küçük etiket (12 px, bold) — primary badge içi
  static const TextStyle primaryBadgeText = TextStyle(
    color: AppColors.primary,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  /// Üst bar label (kaps. harfler, 11 px, 1.5 spacing) — "YENİ DUYURU" gibi
  static const TextStyle sectionLabel = TextStyle(
    color: AppColors.slate300,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );

  // ══════════════════════════════════════════════════════
  // Box Decorations
  // ══════════════════════════════════════════════════════

  /// Standart koyu kart: cardDark, radius 12, border slate700
  static BoxDecoration get cardBox => BoxDecoration(
    color: AppColors.cardDark,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.slate700),
  );

  /// Büyük koyu kart: cardDark, radius 16, border slate700
  static BoxDecoration get cardBoxLarge => BoxDecoration(
    color: AppColors.cardDark,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.slate700),
  );

  /// Slate800 içerik kartı: arka plan slate800, radius 10
  static BoxDecoration get searchBox =>
      BoxDecoration(color: AppColors.slate800, borderRadius: BorderRadius.circular(10));

  /// AppBar alt çizgi: backgroundDark zemin, slate800 border-bottom
  static BoxDecoration get appBarBox => BoxDecoration(
    color: AppColors.backgroundDark,
    border: Border(bottom: BorderSide(color: AppColors.slate800, width: 1)),
  );

  /// Yuvarlak icon container (40×40, slate800 bg, radius 10)
  static BoxDecoration get roundIconBox =>
      BoxDecoration(color: AppColors.slate800, borderRadius: BorderRadius.circular(10));

  /// Circle avatar placeholder (slate700, daire)
  static const BoxDecoration avatarPlaceholder = BoxDecoration(
    color: AppColors.slate700,
    shape: BoxShape.circle,
  );

  /// Bottom sheet handle bar dekorasyonu (slate600, radius 2)
  static BoxDecoration get handleBar =>
      BoxDecoration(color: AppColors.slate600, borderRadius: BorderRadius.circular(2));

  /// Başarı durumu badge (10% opacity green bg, rounded)
  static BoxDecoration arrivedBadge({double radius = 20}) => BoxDecoration(
    color: AppColors.success.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.success.withOpacity(0.2)),
  );

  /// Hata durumu badge (10% opacity red bg, rounded)
  static BoxDecoration notArrivedBadge({double radius = 20}) => BoxDecoration(
    color: AppColors.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.error.withOpacity(0.2)),
  );

  // ══════════════════════════════════════════════════════
  // Button Styles
  // ══════════════════════════════════════════════════════

  /// Ana eylem butonu: primary renk, radius 12
  static ButtonStyle primaryButton({double radius = 12, double fontSize = 16}) =>
      ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
        disabledForegroundColor: AppColors.white.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        elevation: 0,
        textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      );

  /// Gölgeli birincil buton — QR gibi büyük CTA butonları için
  static ButtonStyle primaryButtonElevated({double radius = 14}) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    elevation: 6,
    shadowColor: AppColors.primary.withOpacity(0.4),
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  /// Tehlike butonu: error renk, radius 12
  static ButtonStyle dangerButton({double radius = 12}) => ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: AppColors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    elevation: 0,
  );

  // ══════════════════════════════════════════════════════
  // Common Widget Helpers
  // ══════════════════════════════════════════════════════

  /// Bottom sheet handle çubuğu widget'ı (40×4 px, slatе600, üstte margin)
  static Widget get handleBarWidget => Container(
    width: 40,
    height: 4,
    margin: const EdgeInsets.only(bottom: 20),
    decoration: handleBar,
  );

  /// Standart yatay bölücü (slate800, 1 px)
  static Widget get sectionDivider => Container(height: 1, color: AppColors.slate800);
}
