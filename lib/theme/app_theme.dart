import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF151D30);
  static const Color surfaceLight = Color(0xFF1E2942);
  static const Color primary = Color(0xFF00F5D4); // Electric Turquoise
  static const Color secondary = Color(0xFF7B2CBF); // Neon Purple
  static const Color accent = Color(0xFFFF007F); // Neon Pink
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color divider = Color(0xFF334155);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00F5D4), Color(0xFF7B2CBF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF151D30), Color(0xFF1A243C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: accent,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: GoogleFonts.outfit(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.outfit(color: textSecondary, fontSize: 14),
        titleLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        headlineMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 24),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF222F4D), width: 1),
        ),
      ),
    );
  }
}
