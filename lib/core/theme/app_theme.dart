import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    final scaffoldColor = _tintedSurface(
      base: const Color(0xFFF8FAFC),
      tint: colorScheme.primary,
      alpha: 10,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scaffoldColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark(Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    final scaffoldColor = _tintedSurface(
      base: const Color(0xFF0D1117),
      tint: colorScheme.primary,
      alpha: 22,
    );

    return _base(colorScheme).copyWith(
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scaffoldColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
    );
  }

  static ThemeData _base(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardColor = _tintedSurface(
      base: colorScheme.surface,
      tint: colorScheme.primary,
      alpha: isDark ? 34 : 20,
    );
    final inputColor = _tintedSurface(
      base: colorScheme.surface,
      tint: colorScheme.primary,
      alpha: isDark ? 28 : 14,
    );
    final outlineColor = colorScheme.primary.withAlpha(isDark ? 92 : 70);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        color: cardColor,
        elevation: isDark ? 0 : 1,
        margin: EdgeInsets.zero,
        shadowColor: colorScheme.primary.withAlpha(isDark ? 20 : 28),
        surfaceTintColor: colorScheme.primary.withAlpha(isDark ? 18 : 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: outlineColor),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.primary.withAlpha(isDark ? 58 : 38),
      ),
      iconTheme: IconThemeData(color: colorScheme.primary),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return BorderSide(
              color: selected ? colorScheme.primary : outlineColor,
            );
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return inputColor;
          }),
        ),
      ),
    );
  }

  static Color _tintedSurface({
    required Color base,
    required Color tint,
    required int alpha,
  }) {
    return Color.alphaBlend(tint.withAlpha(alpha), base);
  }
}
