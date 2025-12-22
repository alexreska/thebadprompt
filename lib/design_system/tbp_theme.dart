import 'package:flutter/material.dart';
import 'palette.dart';
import 'typography.dart';

abstract class TbpTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: TbpPalette.lilac, // Fallback color
      colorScheme: ColorScheme.fromSeed(
        seedColor: TbpPalette.lilac,
        background: TbpPalette.lilac,
      ),
      textTheme: TbpTypography.textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TbpPalette.black,
          foregroundColor: TbpPalette.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Brutalist: No rounded corners
          ),
          textStyle: TbpTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white24, // Translucent for the gradient
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: TbpPalette.black, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: TbpPalette.black, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: TbpPalette.black, width: 2),
        ),
      ),
    );
  }
}
