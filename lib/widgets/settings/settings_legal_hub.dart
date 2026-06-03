import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';

class SettingsLegalHub extends StatelessWidget {
  const SettingsLegalHub({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [appColors.accentGradientStart, appColors.accentGradientEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'LEGAL & INFO',
              style: text.labelSmall?.copyWith(
                color: colors.primary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: colors.outlineVariant, width: AppTheme.borderDefault),
          ),
          child: Column(
            children: [
              _LegalLinkItem(
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                appColors: appColors,
                colors: colors,
                text: text,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: colors.outlineVariant,
                indent: AppTheme.spacingXl + AppTheme.spacingMd,
              ),
              _LegalLinkItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                appColors: appColors,
                colors: colors,
                text: text,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: colors.outlineVariant,
                indent: AppTheme.spacingXl + AppTheme.spacingMd,
              ),
              _AppVersionItem(
                appColors: appColors,
                colors: colors,
                text: text,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        // Centered footer sign-off
        Center(
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [appColors.accentGradientStart, appColors.accentGradientEnd],
                ).createShader(bounds),
                child: Text(
                  'PaceCut AI',
                  style: text.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Made for creators who move fast.',
                style: text.bodySmall?.copyWith(color: appColors.subtleText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegalLinkItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;

  const _LegalLinkItem({
    required this.icon,
    required this.label,
    required this.appColors,
    required this.colors,
    required this.text,
  });

  @override
  State<_LegalLinkItem> createState() => _LegalLinkItemState();
}

class _LegalLinkItemState extends State<_LegalLinkItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed
            ? widget.colors.outlineVariant.withOpacity(0.5)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.colors.primary.withOpacity(AppTheme.opacitySubtle),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(widget.icon, size: AppTheme.iconSm + 4, color: widget.colors.primary),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Text(
                widget.label,
                style: widget.text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: AppTheme.iconSm + 2,
              color: widget.appColors.subtleText,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppVersionItem extends StatelessWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;

  const _AppVersionItem({
    required this.appColors,
    required this.colors,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(AppTheme.opacitySubtle),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(Icons.info_outline_rounded, size: AppTheme.iconSm + 4, color: colors.primary),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              'App Version',
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: appColors.cardSurfaceLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: colors.outline, width: AppTheme.borderDefault),
            ),
            child: Text(
              'v1.0.1',
              style: text.labelSmall?.copyWith(
                color: appColors.subtleText,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
