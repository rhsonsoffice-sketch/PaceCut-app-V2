import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/session_provider.dart';

class ProUpgradeCard extends StatefulWidget {
  const ProUpgradeCard({super.key});

  @override
  State<ProUpgradeCard> createState() => _ProUpgradeCardState();
}

class _ProUpgradeCardState extends State<ProUpgradeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final isPro = context.watch<SessionProvider>().isPro;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/paywall');
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            gradient: LinearGradient(
              colors: [
                appColors.accentGradientStart.withOpacity(0.18),
                appColors.accentGradientEnd.withOpacity(0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: appColors.accentGradientStart.withOpacity(0.55),
              width: AppTheme.borderSelected,
            ),
            boxShadow: [
              BoxShadow(
                color: appColors.glowPurple.withOpacity(AppTheme.opacityGlow),
                blurRadius: 24,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Crown icon
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingSm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            appColors.accentGradientStart,
                            appColors.accentGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: AppTheme.iconMd,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                appColors.accentGradientStart,
                                appColors.accentGradientEnd,
                              ],
                            ).createShader(bounds),
                            child: Text(
                              'PaceCut PRO',
                              style: text.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            isPro
                                ? '4K Export & Watermarks Unlocked'
                                : 'Unlock 4K Export & AI Captions',
                            style: text.bodySmall?.copyWith(
                              color: appColors.subtleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Active badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: appColors.accentGradientEnd.withOpacity(AppTheme.opacitySubtle),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: appColors.accentGradientEnd.withOpacity(0.4),
                          width: AppTheme.borderDefault,
                        ),
                      ),
                      child: Text(
                        isPro ? 'PRO ✓' : 'FREE',
                        style: text.labelSmall?.copyWith(
                          color: appColors.accentGradientEnd,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                // Feature pills
                Wrap(
                  spacing: AppTheme.spacingSm,
                  runSpacing: AppTheme.spacingSm,
                  children: [
                    _FeaturePill(label: '4K Export', appColors: appColors),
                    _FeaturePill(label: 'AI Captions', appColors: appColors),
                    _FeaturePill(label: 'No Watermark', appColors: appColors),
                    _FeaturePill(label: 'All Templates', appColors: appColors),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                // Manage Subscription CTA
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/paywall');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          appColors.accentGradientStart,
                          appColors.accentGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.glowPurple.withOpacity(0.40),
                          blurRadius: 14,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.white, size: AppTheme.iconMd),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          isPro ? 'Manage Subscription' : 'Upgrade to PRO',
                          style: text.labelLarge?.copyWith(
                            color: colors.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  final AppColorsExtension appColors;

  const _FeaturePill({required this.label, required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: appColors.accentGradientStart.withOpacity(AppTheme.opacitySubtle),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        '✓  $label',
        style: TextStyle(
          color: appColors.accentGradientStart,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
