import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'palette.dart';

abstract class TbpTypography {
  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.spaceMono(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: TbpPalette.black,
      letterSpacing: -1.0,
    ),
    displayMedium: GoogleFonts.spaceMono(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: TbpPalette.black,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600, // Slightly bolder for legibility on gradient
      color: TbpPalette.black,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: TbpPalette.black,
    ),
    labelLarge: GoogleFonts.spaceMono(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: TbpPalette.white,
    ),
  );
}
