import 'package:flutter/material.dart';

class AppTheme {
  static const EdgeInsets paddingSmall = EdgeInsets.all(8.0);
  static const EdgeInsets paddingMedium = EdgeInsets.all(16.0);
  static const EdgeInsets paddingLarge = EdgeInsets.all(24.0);

  static ThemeData themeData(ColorScheme? colorScheme, Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color primaryColor = colorScheme?.primary ?? const Color(0xFF006D77);
    
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: brightness,
    ).copyWith(
      primary: primaryColor,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: isLight ? Colors.white : scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: isLight ? Colors.white : scheme.surface,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? const Color(0xFFFAFAFA) : scheme.surfaceContainerHighest.withValues(alpha: 0.15),
        hintStyle: TextStyle(
          color: isLight ? Colors.grey[400] : Colors.grey[500],
          fontSize: 14,
        ),
        prefixIconColor: isLight ? Colors.grey[400] : Colors.grey[400],
        suffixIconColor: isLight ? Colors.grey[400] : Colors.grey[400],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: isLight ? const Color(0xFFF9F9F9) : scheme.surfaceContainerHighest.withValues(alpha: 0.1),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: isLight ? Colors.grey[100] : Colors.grey[800],
      ),
    );
  }

  static ThemeData get lightTheme => themeData(null, Brightness.light);
  static ThemeData get darkTheme => themeData(null, Brightness.dark);
}
