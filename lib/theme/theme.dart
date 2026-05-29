import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color cardSurface;
  final Color cardSurfaceLight;
  final Color glowPurple;
  final Color subtleText;
  final Color draftThumbnail;
  final Color success;
  final Color accentGradientStart;
  final Color accentGradientEnd;

  const AppColorsExtension({
    required this.cardSurface,
    required this.cardSurfaceLight,
    required this.glowPurple,
    required this.subtleText,
    required this.draftThumbnail,
    required this.success,
    required this.accentGradientStart,
    required this.accentGradientEnd,
  });

  @override
  AppColorsExtension copyWith({
    Color? cardSurface,
    Color? cardSurfaceLight,
    Color? glowPurple,
    Color? subtleText,
    Color? draftThumbnail,
    Color? success,
    Color? accentGradientStart,
    Color? accentGradientEnd,
  }) =>
      AppColorsExtension(
        cardSurface: cardSurface ?? this.cardSurface,
        cardSurfaceLight: cardSurfaceLight ?? this.cardSurfaceLight,
        glowPurple: glowPurple ?? this.glowPurple,
        subtleText: subtleText ?? this.subtleText,
        draftThumbnail: draftThumbnail ?? this.draftThumbnail,
        success: success ?? this.success,
        accentGradientStart: accentGradientStart ?? this.accentGradientStart,
        accentGradientEnd: accentGradientEnd ?? this.accentGradientEnd,
      );

  @override
  AppColorsExtension lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardSurfaceLight: Color.lerp(cardSurfaceLight, other.cardSurfaceLight, t)!,
      glowPurple: Color.lerp(glowPurple, other.glowPurple, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      draftThumbnail: Color.lerp(draftThumbnail, other.draftThumbnail, t)!,
      success: Color.lerp(success, other.success, t)!,
      accentGradientStart: Color.lerp(accentGradientStart, other.accentGradientStart, t)!,
      accentGradientEnd: Color.lerp(accentGradientEnd, other.accentGradientEnd, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  // Bright purple brand color (#A855F7) — used for headline text and primary CTA
  static const Color brandPurple = Color(0xFFA855F7);

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  // 20% larger than spacingLg — used for the enlarged Create New Project card padding
  static const double spacingCardLg = 29.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXl = 20.0;

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  static const double opacityDisabled = 0.38;
  static const double opacityHint = 0.6;
  static const double opacitySubtle = 0.12;
  static const double opacityGlow = 0.35;

  static const double borderDefault = 1.0;
  static const double borderSelected = 1.5;

  static const _appColors = AppColorsExtension(
    cardSurface: Color(0xFF1E1A2E),
    cardSurfaceLight: Color(0xFF2A2540),
    glowPurple: Color(0xFF9C5FFF),
    subtleText: Color(0xFF8E8A9E),
    draftThumbnail: Color(0xFF302B45),
    success: Color(0xFF4ADE80),
    accentGradientStart: Color(0xFF9C5FFF),
    accentGradientEnd: Color(0xFFD946EF),
  );

  static final ThemeData darkTheme = _buildTheme(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF9C5FFF),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF7C3AED),
      onPrimaryContainer: Colors.white,
      secondary: Color(0xFFD946EF),
      onSecondary: Colors.white,
      surface: Color(0xFF12101C),
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFF8E8A9E),
      outline: Color(0xFF3A3550),
      outlineVariant: Color(0xFF2A2540),
      error: Color(0xFFEF4444),
      onError: Colors.white,
      surfaceContainerLow: Color(0xFF1A1726),
      surfaceContainerHighest: Color(0xFF2A2540),
    ),
    appColors: _appColors,
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required AppColorsExtension appColors,
  }) {
    final textTheme = _buildTextTheme(colorScheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: appColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: appColors.subtleText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelSmall,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      extensions: [appColors],
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
        height: 1.15,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: colorScheme.onSurface,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
