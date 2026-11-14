import 'package:flutter/material.dart';

/// Central theme definition for the app: one seed color, light and dark
/// variants derived from it, and shared component shapes so every screen
/// (transcription, scan/OCR) looks like one product.
abstract final class AppTheme {
  static const seed = Colors.deepPurple;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final cs = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surfaceContainer,
        elevation: 0,
        height: 64,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: cs.primary,
        linearTrackColor: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      dividerTheme: DividerThemeData(color: cs.outlineVariant, space: 24),
    );
  }
}
