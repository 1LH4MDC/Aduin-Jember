import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 1. Definisi Palet Warna (Berdasarkan UI/UX)
  static const Color primaryColor = Color(0xFF0C344D); // Deep Blue Jember
  static const Color secondaryColor = Color(0xFF1A6B9A); // Light Blue Accent
  static const Color backgroundColor = Color(
    0xFFF5F7FA,
  ); // Light Grey (Background Form)
  static const Color errorColor = Color(
    0xFFD32F2F,
  ); // Merah (Untuk Gawat / Logout)
  static const Color textPrimary = Color(0xFF333333); // Teks Utama

  // 2. Konfigurasi Tema Global
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),

      // Menggunakan Google Fonts (Poppins memberikan kesan modern & clean)
      textTheme: GoogleFonts.poppinsTextTheme(),

      // Styling Bawaan untuk Text Field (Input Form)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Styling Bawaan untuk Tombol Utama (Elevated Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54), // Full width button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
