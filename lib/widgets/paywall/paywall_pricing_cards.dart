import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';

class PaywallPricingCards extends StatelessWidget {
  /// Currently selected plan index: 0 = Weekly, 1 = Monthly.
  final int selected;

  /// Called when the user taps a card.
  final ValueChanged<int> onSelectionChanged;

  const PaywallPricingCards({
    super.key,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section label
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
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
              'Choose Your Plan',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Weekly card
        _PricingCard(
          isSelected: selected == 0,
          badgeLabel: null,
          title: 'Weekly Access',
          price: '£2.99',
          period: '/ week',
          subtitle: 'Cancel anytime.',
          onTap: () {
            HapticFeedback.selectionClick();
            onSelectionChanged(0);
          },
          appColors: appColors,
          text: text,
          colors: colors,
        ),
        const SizedBox(height: AppTheme.spacingMd),
        // Monthly card
        _PricingCard(
          isSelected: selected == 1,
          badgeLabel: 'BEST VALUE',
          title: 'Monthly Pass',
          price: '£5.99',
          period: '/ month',
          subtitle: 'Best value — save over 50%.',
          onTap: () {
            HapticFeedback.selectionClick();
            onSelectionChanged(1);
          },
          appColors: appColors,
          text: text,
          colors: colors,
        ),
      ],
    );
  }
}

class _PricingCard extends StatefulWidget {
  final bool isSelected;
  /// Non-null label renders a badge (e.g. "BEST VALUE"). Null = no badge.
  final String? badgeLabel;
  final String title;
  final String price;
  final String period;
  final String subtitle;
  final VoidCallback onTap;
  final AppColorsExtension appColors;
  final TextTheme text;
  final ColorScheme colors;

  const _PricingCard({
    required this.isSelected,
    required this.badgeLabel,
    required this.title,
    required this.price,
    required this.period,
    required this.subtitle,
    required this.onTap,
    required this.appColors,
    required this.text,
    required this.colors,
  });

  @override
  State<_PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<_PricingCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    final appColors = widget.appColors;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: selected
                ? appColors.accentGradientStart.withOpacity(0.10)
                : appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: selected
                  ? appColors.accentGradientStart
                  : appColors.cardSurfaceLight,
              width: selected ? AppTheme.borderSelected : AppTheme.borderDefault,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: appColors.glowPurple.withOpacity(0.28),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Radio circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? appColors.accentGradientStart
                        : appColors.subtleText.withOpacity(0.5),
                    width: selected ? 2.0 : AppTheme.borderDefault,
                  ),
                  gradient: selected
                      ? LinearGradient(
                          colors: [
                            appColors.accentGradientStart,
                            appColors.accentGradientEnd,
                          ],
                        )
                      : null,
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                    : null,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // Plan info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.title,
                          style: widget.text.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (widget.badgeLabel != null) ...[
                          const SizedBox(width: AppTheme.spacingSm),
                          _PlanBadge(label: widget.badgeLabel!, appColors: appColors, text: widget.text),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: widget.text.bodySmall?.copyWith(
                        color: appColors.subtleText,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: selected
                          ? [appColors.accentGradientStart, appColors.accentGradientEnd]
                          : [Colors.white, Colors.white],
                    ).createShader(bounds),
                    child: Text(
                      widget.price,
                      style: widget.text.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    widget.period,
                    style: widget.text.labelSmall?.copyWith(
                      color: appColors.subtleText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final String label;
  final AppColorsExtension appColors;
  final TextTheme text;

  const _PlanBadge({required this.label, required this.appColors, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appColors.accentGradientStart, appColors.accentGradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: appColors.glowPurple.withOpacity(0.40),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        label,
        style: text.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 9,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
