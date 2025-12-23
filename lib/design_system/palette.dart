import 'package:flutter/material.dart';

abstract class TbpPalette {
  // User requested gradient: linear-gradient(90deg, #C6ADC5 0%, #B0B4E1 100%);
  static const Color lilac = Color(0xFFC6ADC5);
  static const Color periwinkle = Color(0xFFB0B4E1);

  // User requested accents
  static const Color darkViolet = Color(0xFF2E003E);
  static const Color fuchsia = Color(0xFFFF00FF);
  // Using a very light lavender for background to support dark violet text
  static const Color lightBackground = Color(0xFFF5F0F5);
  // Menu background from screenshot ref
  static const Color menuBackground = Color(0xFF14001A);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [lilac, periwinkle],
    stops: [0.0, 1.0],
  );

  // Black for text/contrast
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  
  // Brutalist accents (kept from plan, but secondary to the user's gradient)
  static const Color error = Color(0xFFFF0033);
}
