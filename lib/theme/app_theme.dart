import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary (Deep Blue/Teal) and Secondary (Orange as requested)
  static const Color primaryLight = Color(0xFFe87722); // Orange from frontend
  static const Color primaryDark = Color(0xFF994700); // Darker orange from frontend
  
  static const Color secondaryOrange = Color(0xFFf27104);
  static const Color secondaryOrangeLight = Color(0xFFffb68d);

  // Dark Theme Backgrounds (As requested, true dark/black tones)
  static const Color darkBackground = Color(0xFF1c110b);
  static const Color darkSurface = Color(0xFF291d16);
  static const Color darkSurfaceHigh = Color(0xFF40322a);
  
  // Light Theme Backgrounds (Clean white/gray)
  static const Color lightBackground = Color(0xFFfcf8f9); // Match frontend bg
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceHigh = Color(0xFFf6f3f4);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryOrange,
        background: lightBackground,
        surface: lightSurface,
        onBackground: Color(0xFF212529),
        onSurface: Color(0xFF212529),
        error: Color(0xFFD32F2F),
      ),
      scaffoldBackgroundColor: lightBackground,
      cardColor: lightSurface,
      dividerColor: const Color(0xFFDEE2E6),
      textTheme: GoogleFonts.geistTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: const Color(0xFF212529),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.geist(
          color: const Color(0xFF212529),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: primaryLight,
        unselectedItemColor: Color(0xFFADB5BD),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryOrange,
        background: darkBackground,
        surface: darkSurface,
        onBackground: Color(0xFFf5ded3),
        onSurface: Color(0xFFf5ded3),
        error: Color(0xFFffb4ab),
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurfaceHigh,
      dividerColor: const Color(0xFF584236),
      textTheme: GoogleFonts.geistTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: const Color(0xFFf5ded3),
        displayColor: const Color(0xFFf5ded3),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: const Color(0xFFf5ded3),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.geist(
          color: const Color(0xFFf5ded3),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryDark,
        unselectedItemColor: Color(0xFFe0c0b0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
