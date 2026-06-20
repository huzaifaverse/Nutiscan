import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF1E2A5E);
  static const Color green = Color(0xFF1A7A4A);
  static const Color mint = Color(0xFF7BDFA6);
  static const Color amber = Color(0xFFF4A821);
  static const Color alertRed = Color(0xFFE53935);
  static const Color neutralLight = Color(0xFFF5F7FA);
  static const Color white = Color(0xFFFFFFFF);

  static const Color scoreA = Color(0xFF1A7A4A);
  static const Color scoreB = Color(0xFF7BDFA6);
  static const Color scoreC = Color(0xFFF4A821);
  static const Color scoreD = Color(0xFFE53935);
  static const Color scoreE = Color(0xFF8B0000);

  static Color scoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A': return scoreA;
      case 'B': return scoreB;
      case 'C': return scoreC;
      case 'D': return scoreD;
      default:  return scoreE;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        primary: AppColors.navy,
        secondary: AppColors.green,
        surface: AppColors.neutralLight,
        background: AppColors.neutralLight,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.neutralLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          color: AppColors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.dmSerifDisplay(color: AppColors.navy),
        displayMedium: GoogleFonts.dmSerifDisplay(color: AppColors.navy),
        headlineLarge: GoogleFonts.dmSerifDisplay(color: AppColors.navy, fontSize: 28),
        headlineMedium: GoogleFonts.dmSerifDisplay(color: AppColors.navy, fontSize: 22),
        headlineSmall: GoogleFonts.dmSerifDisplay(color: AppColors.navy, fontSize: 18),
        titleLarge: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: AppColors.navy),
        bodyLarge: GoogleFonts.dmSans(color: const Color(0xFF333333)),
        bodyMedium: GoogleFonts.dmSans(color: const Color(0xFF555555)),
        bodySmall: GoogleFonts.dmSans(color: const Color(0xFF888888), fontSize: 11),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 10),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
