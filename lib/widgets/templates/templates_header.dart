import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class TemplatesHeader extends StatelessWidget {
  const TemplatesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section accent bar + label row
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
              'VIRAL TEMPLATES',
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
        Text(
          'Viral Templates',
          style: text.headlineMedium?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          'Choose a high-retention layout.',
          style: text.bodyMedium?.copyWith(color: appColors.subtleText),
        ),
      ],
    );
  }
}
