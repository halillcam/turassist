import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF137fec); // Mavi (Auth ekranlarından)
  static const Color primaryDark = Color(0xFFd66e12); // Koyu turuncu
  static const Color primaryLight = Color(0xFFFF8A5B);

  // Background Colors - Android/City Selection
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color backgroundDark = Color(0xFF101922);

  // Dark Colors
  static const Color darkBackground = Color(0xFF221810); // HTML'deki background-dark
  static const Color darkSurface = Color(0xFF2c241b); // HTML'deki surface-dark
  static const Color darkCard = Color(0xFF3A3A3A);
  static const Color cardDark = Color(0xFF1a2632); // Tour detail card bg
  static const Color greenAccent = Color(0xFF22c55e); // Neler dahil icon color

  // Slate Colors
  static const Color slate900 = Color(0xFF0f172a);
  static const Color slate800 = Color(0xFF1e293b);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748b);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate300 = Color(0xFFcbd5e1);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate100 = Color(0xFFf1f5f9);

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
