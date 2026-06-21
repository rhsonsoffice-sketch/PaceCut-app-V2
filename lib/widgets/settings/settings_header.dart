import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ──────────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 3,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    appColors.accentGradientStart,
                    appColors.accentGradientEnd,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'ACCOUNT',
              style: text.titleSmall?.copyWith(
                color: colors.primary,
                letterSpacing: 1.8,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text('Settings', style: text.headlineMedium?.copyWith(fontSize: 28)),
        const SizedBox(height: AppTheme.spacingLg),

        // ── Brand logo ────────────────────────────────────────────────────
        Center(
          child: Image(
            image: const AssetImage('assets/images/settings_logo.png'),
            width: 120,
            height: 120,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
