import 'package:flutter/material.dart';

abstract class TbpPalette {
  // User requested gradient: linear-gradient(90deg, #C6ADC5 0%, #B0B4E1 100%);
  static const Color lilac = Color(0xFFC6ADC5);
  static const Color periwinkle = Color(0xFFB0B4E1);

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
