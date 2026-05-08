import 'package:flutter/material.dart';

/// Tema Material 3 grigio per l'app Buco.
/// Light + Dark, con lo stesso seed neutro.
class BucoTheme {
  BucoTheme._();

  static const _seed = Color(0xFF6F6F6F);

  static final ThemeData light = _build(
    ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
    scaffoldBg: const Color(0xFFF2F2F2),
    surface: Colors.white,
    appBarBg: const Color(0xFF6F6F6F),
    appBarFg: Colors.white,
  );

  static final ThemeData dark = _build(
    ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
    scaffoldBg: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    appBarBg: const Color(0xFF2A2A2A),
    appBarFg: Colors.white,
  );

  static ThemeData _build(
    ColorScheme cs, {
    required Color scaffoldBg,
    required Color surface,
    required Color appBarBg,
    required Color appBarFg,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        centerTitle: false,
        elevation: 2,
        titleTextStyle: TextStyle(
          color: appBarFg,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: appBarBg,
          foregroundColor: appBarFg,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: cs.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: cs.onSurface),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        contentTextStyle: TextStyle(color: cs.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
