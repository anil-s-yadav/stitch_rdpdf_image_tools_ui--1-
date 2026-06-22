import 'package:flutter/material.dart';

/// Design system color tokens matching the Stitch design specification.
class AppColors {
  AppColors._();

  // ── Primary palette ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF004AC6);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);
  static const Color inversePrimary = Color(0xFFB4C5FF);
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);
  static const Color onPrimaryFixedVariant = Color(0xFF003EA8);

  // ── Secondary palette ────────────────────────────────────────────────
  static const Color secondary = Color(0xFF5C5F60);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFDEE0E2);
  static const Color onSecondaryContainer = Color(0xFF606365);
  static const Color secondaryFixed = Color(0xFFE1E2E4);
  static const Color secondaryFixedDim = Color(0xFFC5C6C8);
  static const Color onSecondaryFixed = Color(0xFF191C1E);
  static const Color onSecondaryFixedVariant = Color(0xFF444749);

  // ── Tertiary palette ─────────────────────────────────────────────────
  static const Color tertiary = Color(0xFF2C4BB9);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF4865D4);
  static const Color onTertiaryContainer = Color(0xFFEFF0FF);
  static const Color tertiaryFixed = Color(0xFFDDE1FF);
  static const Color tertiaryFixedDim = Color(0xFFB8C4FF);
  static const Color onTertiaryFixed = Color(0xFF001453);
  static const Color onTertiaryFixedVariant = Color(0xFF173BAB);

  // ── Error palette ────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // ── Surface / Background ─────────────────────────────────────────────
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceDim = Color(0xFFD3DAEA);
  static const Color surfaceBright = Color(0xFFF9F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color surfaceContainer = Color(0xFFE7EEFE);
  static const Color surfaceContainerHigh = Color(0xFFE2E8F8);
  static const Color surfaceContainerHighest = Color(0xFFDCE2F3);
  static const Color onSurface = Color(0xFF151C27);
  static const Color onSurfaceVariant = Color(0xFF434655);
  static const Color inverseSurface = Color(0xFF2A313D);
  static const Color inverseOnSurface = Color(0xFFEBF1FF);
  static const Color surfaceTint = Color(0xFF0053DB);
  static const Color surfaceVariant = Color(0xFFDCE2F3);
  static const Color background = Color(0xFFF9F9FF);
  static const Color onBackground = Color(0xFF151C27);

  // ── Outline ──────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);

  // ── Gradient ─────────────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFF1E3A8A);
  static const Color gradientEnd = Color(0xFF2563EB);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Success ──────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);

  // ── Dark Mode overrides ──────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainer = Color(0xFF2C2C2C);
  static const Color darkSurfaceContainerHigh = Color(0xFF383838);
  static const Color darkOnSurface = Color(0xFFE3E3E3);
  static const Color darkOnSurfaceVariant = Color(0xFFAAAAAA);
  static const Color darkOutline = Color(0xFF757575);
  static const Color darkBackground = Color(0xFF121212);
}
