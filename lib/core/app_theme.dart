import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors from Images
  static const Color primaryGreen = Color(0xFF1B5E20); 
  static const Color secondaryGreen = Color(0xFF2E7D32);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color bgGrey = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color borderGrey = Color(0xFFE5E7EB);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: bgGrey,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      surface: Colors.white,
      onSurface: textDark,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textGrey,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
      prefixIconColor: textGrey,
      labelStyle: const TextStyle(color: textGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: borderGrey, width: 0.5),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: textDark),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: primaryGreen,
      unselectedItemColor: textGrey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color(0xFF0F172A), // Dark navy as seen in Bottom Nav images (sometimes)
    ),
  );
}
