import 'package:flutter/material.dart';

class AppThemeLight {
  static Color _primary = const Color(0xffC59653);
  static Color _secondary = const Color(0xFFFAF1E6);

  static void updateTheme({required Color primary, required Color secondary}) {
    _primary = primary;
    _secondary = secondary;
  }

  // App theme colors
  static Color get primary => _primary;
  static Color get primaryLight => _secondary;
  static Color get primaryRich => _primary;
  static Color get secondary => _secondary;
  static Color get accent => _secondary;
  static Color get highlighted => _secondary;
  // Text colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textPrimaryDark = Color(0xff795C2C);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textWhite = Colors.white;

  // Background colors
  static Color get light => _secondary;
  static const Color dark = Color(0xFF272727);
  static Color get primaryBackground => _secondary;

  // Background Container colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = AppThemeLight.white.withValues(alpha: 0.1);

  // Button colors
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderPrimary = Color(0xFFD9D9D9);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}

class AppThemeDark {
  static Color _primary = const Color(0xff00F59B);
  static Color _secondary = const Color(0xFF131A26);

  static void updateTheme({required Color primary, required Color secondary}) {
    _primary = primary;
    _secondary = secondary;
  }

  // App theme colors
  static Color get primary => _primary;
  static Color get primaryLight => _secondary;
  static Color get primaryRich => _primary;
  static Color get secondary => _secondary;
  static Color get accent => _secondary;
  static Color get highlighted => _secondary;
  // Text colors
  static const Color textPrimary = white;
  static const Color textPrimaryDark = Color(0xff795C2C);
  static const Color textSecondary = Color(0xFF04AED4);
  static const Color textWhite = Colors.white;

  // Background colors
  static Color primaryBackground = Color(0xFF070A10);

  // Background Container colors
  static const Color lightContainer = Color(0xFFF6F6F6);
  static Color darkContainer = AppThemeLight.white.withValues(alpha: 0.1);

  // Button colors
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Border colors
  static const Color borderPrimary = Color(0xFF0D556E);
  static const Color borderSecondary = Color(0xFFE6E6E6);

  // Error and validation colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1976D2);

  // Neutral Shades
  static const Color black = Color(0xFF232323);
  static const Color darkerGrey = Color(0xFF4F4F4F);
  static const Color darkGrey = Color(0xFF939393);
  static const Color grey = Color(0xFFE0E0E0);
  static const Color softGrey = Color(0xFFF4F4F4);
  static const Color lightGrey = Color(0xFFF9F9F9);
  static const Color white = Color(0xFFFFFFFF);
}
