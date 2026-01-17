import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Default to dark for "Space" feel
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.white,
        onPrimary: AppColors.black,
        surface: AppColors.surface,
        onSurface: AppColors.white,
        background: AppColors.background,
        onBackground: AppColors.white,
        outline: AppColors.greyMedium,
      ),
      
      // Typography: Geometric, Clean, High Contrast
      textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.greyDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32), // More rounded
          side: const BorderSide(color: AppColors.greyMedium, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        shape: CircleBorder(),
      ),
      
      // Interaction Patterns
      splashFactory: InkRipple.splashFactory, // Fluid "Water Drop" Ripple
      highlightColor: Colors.white.withOpacity(0.1), // Subtle white highlight
      splashColor: Colors.white.withOpacity(0.1), // Subtle white splash
    );
  }
}
