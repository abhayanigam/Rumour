import 'package:flutter/material.dart';

/// All design-system colours for Rumour.
/// Dark values are used by default; light overrides via the theme.
class AppColors {
  AppColors._();

  // ── Brand ───────────────────────────────────────────────────────
  static const Color accent = Color(0xFFC5FF00); // Lime green (matches Figma)
  static const Color accentDark = Color(0xFFADE000); // Pressed / darker lime
  static const Color splashBackground = Color(0xFF27272A); // Matches rumour.png icon bg

  // ── Dark Theme ─────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surface2Dark = Color(0xFF2C2C2E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color receivedBubbleDark = Color(0xFF2C2C2E);
  static const Color dividerDark = Color(0xFF38383A);
  static const Color iconBgDark = Color(0xFF1C1C1E);

  // ── Light Theme ────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFE5E5EA);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF6C6C70);
  static const Color receivedBubbleLight = Color(0xFFE5E5EA);
  static const Color dividerLight = Color(0xFFD1D1D6);
  static const Color iconBgLight = Color(0xFFE5E5EA);

  // ── Shared ─────────────────────────────────────────────────────
  static const Color sentBubble = Color(0xFFC5FF00);
  static const Color sentBubbleText = Color(0xFF000000);
  static const Color error = Color(0xFFFF3B30);
  static const Color transparent = Colors.transparent;

  // ── Helpers ────────────────────────────────────────────────────
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? backgroundDark
          : backgroundLight;

  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDark
          : surfaceLight;

  static Color surface2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surface2Dark
          : surface2Light;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textPrimaryDark
          : textPrimaryLight;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textSecondaryDark
          : textSecondaryLight;

  static Color receivedBubble(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? receivedBubbleDark
          : receivedBubbleLight;

  static Color iconBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? iconBgDark
          : iconBgLight;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? dividerDark
          : dividerLight;
}
