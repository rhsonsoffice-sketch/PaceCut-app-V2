import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/theme.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Image.asset(
          'assets/images/hero_logo.png',
          width: 140,
          height: 140,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(
              begin: const Offset(0.75, 0.75),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          'MAKE VIRAL VIDEOS IN SECONDS',
          style: text.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.brandPurple,
            letterSpacing: 0.8,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .slideY(begin: 0.15, end: 0, duration: 500.ms, curve: Curves.easeOut),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          'Auto‑pacing, fast‑cuts, hooks — done for you',
          style: text.bodyMedium?.copyWith(
            fontSize: 16,
            color: colors.onSurface,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 300.ms),
      ],
    );
  }
}
