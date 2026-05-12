import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF8F5F2),

    textTheme: GoogleFonts.poppinsTextTheme(),

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF8A3D),
    ),

    useMaterial3: true,
  );
}