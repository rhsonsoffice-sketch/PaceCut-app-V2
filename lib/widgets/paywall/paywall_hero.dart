import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class PaywallHero extends StatelessWidget {
  const PaywallHero({super.key});

  static const _features = [
    'Uncap Render Quality to 4K Ultra-HD',
    'Remove All Watermarks Instantly',
    'Unlock AI-Powered Auto Captions',
    'Access Advanced Retention Templates',
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Crown badge icon container
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                appColors.accentGradientStart.withOpacity(0.20),
                appColors.accentGradientEnd.withOpacity(0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: appColors.accentGradientStart.withOpacity(0.45),
              width: AppTheme.borderSelected,
            ),
            boxShadow: [
              BoxShadow(
                color: appColors.glowPurple.withOpacity(AppTheme.opacityGlow),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: AppTheme.iconXl - 8,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        // Gradient headline
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              appColors.accentGradientStart,
              appColors.accentGradientEnd,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'Unlock PaceCut PRO',
            textAlign: TextAlign.center,
            style: text.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Everything you need to go viral.',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(
            color: appColors.subtleText,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        // Feature checklist card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: appColors.accentGradientStart.withOpacity(0.18),
              width: AppTheme.borderDefault,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _features
                .map((f) => _FeatureRow(label: f, appColors: appColors, text: text))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String label;
  final AppColorsExtension appColors;
  final TextTheme text;

  const _FeatureRow({
    required this.label,
    required this.appColors,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm - 2),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  appColors.accentGradientStart,
                  appColors.accentGradientEnd,
                ],
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd - 4),
          Expanded(
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
