import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFf48525); // Turuncu (HTML'den)
  static const Color primaryDark = Color(0xFFd66e12); // Koyu turuncu
  static const Color primaryLight = Color(0xFFFF8A5B);

  // Dark Colors
  static const Color darkBackground = Color(0xFF221810); // HTML'deki background-dark
  static const Color darkSurface = Color(0xFF2c241b); // HTML'deki surface-dark
  static const Color darkCard = Color(0xFF3A3A3A);

  // Secondary Colors
  static const Color secondary = Color(0xFF4A90E2); // Mavi
  static const Color secondaryLight = Color(0xFF6BA3FF);
  static const Color secondaryDark = Color(0xFF3A7FD5);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF8B5FBF); // Mor
  static const Color tertiaryLight = Color(0xFFA877D4);
  static const Color tertiaryDark = Color(0xFF7A4FB0);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFCCCCCC);
  static const Color mediumGray = Color(0xFF666666);
  static const Color darkGray = Color(0xFF333333);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textTertiary = Color(0xFF999999);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE91E63);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );
}
