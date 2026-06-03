import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';


class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Row(
      children: [
        _ProfileIcon(colors: colors, appColors: appColors),
        const Expanded(child: Center(child: _BrandLogo())),
        _ProBadge(colors: colors, appColors: appColors, text: text),
      ],
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  final ColorScheme colors;
  final AppColorsExtension appColors;

  const _ProfileIcon({required this.colors, required this.appColors});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: appColors.cardSurface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.outline, width: AppTheme.borderDefault),
        ),
        child: Icon(Icons.person_outline_rounded, color: appColors.subtleText, size: AppTheme.iconMd),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_logo.png',
      width: 200,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}

class _ProBadge extends StatefulWidget {
  final ColorScheme colors;
  final AppColorsExtension appColors;
  final TextTheme text;

  const _ProBadge({required this.colors, required this.appColors, required this.text});

  @override
  State<_ProBadge> createState() => _ProBadgeState();
}

class _ProBadgeState extends State<_ProBadge> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.mediumImpact();
        context.push('/paywall');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [widget.appColors.accentGradientStart, widget.appColors.accentGradientEnd],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: widget.appColors.glowPurple.withOpacity(AppTheme.opacityGlow),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            'PRO',
            style: widget.text.labelMedium?.copyWith(
              color: widget.colors.onPrimary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
