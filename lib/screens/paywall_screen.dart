import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme.dart';
import '../widgets/paywall/paywall_hero.dart';
import '../widgets/paywall/paywall_pricing_cards.dart';
import '../widgets/paywall/paywall_cta.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  // 0 = Weekly, 1 = Monthly (default selected for best-value UX)
  int _selectedPlan = 1;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Radial ambient glow behind hero
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      appColors.glowPurple.withOpacity(0.22),
                      colors.surface.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top dismiss bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  child: Row(
                    children: [
                      _DismissButton(),
                      const Spacer(),
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: appColors.glowPurple.withOpacity(AppTheme.opacityHint),
                        size: AppTheme.iconMd,
                      ),
                    ],
                  ),
                ),
                // Scrollable body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spacingMd,
                      AppTheme.spacingSm,
                      AppTheme.spacingMd,
                      AppTheme.spacingXxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const PaywallHero(),
                        const SizedBox(height: AppTheme.spacingLg),
                        PaywallPricingCards(
                          selected: _selectedPlan,
                          onSelectionChanged: (i) => setState(() => _selectedPlan = i),
                        ),
                        const SizedBox(height: AppTheme.spacingLg),
                        PaywallCta(selectedPlan: _selectedPlan),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissButton extends StatefulWidget {
  @override
  State<_DismissButton> createState() => _DismissButtonState();
}

class _DismissButtonState extends State<_DismissButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        context.pop();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.outline,
              width: AppTheme.borderDefault,
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            color: appColors.subtleText,
            size: AppTheme.iconSm + 2,
          ),
        ),
      ),
    );
  }
}
