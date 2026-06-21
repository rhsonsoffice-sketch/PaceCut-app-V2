import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';

class TemplateGrid extends StatelessWidget {
  const TemplateGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _TemplateChip(
            icon: Icons.speed_rounded,
            label: 'Viral Fast-Cut',
            detail: '0.5s',
            preset: 'viral_fast_cut',
          ),
        ),
        SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: _TemplateChip(
            icon: Icons.trending_up_rounded,
            label: 'Retention Booster',
            detail: '',
            preset: 'retention_booster',
          ),
        ),
        SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: _TemplateChip(
            icon: Icons.record_voice_over_rounded,
            label: 'Dialogue Punch-Up',
            detail: '',
            preset: 'dialogue_punch_up',
          ),
        ),
      ],
    );
  }
}

class _TemplateChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final String detail;
  final String preset;

  const _TemplateChip({
    required this.icon,
    required this.label,
    required this.detail,
    required this.preset,
  });

  @override
  State<_TemplateChip> createState() => _TemplateChipState();
}

class _TemplateChipState extends State<_TemplateChip> {
  bool _pressed = false;

  void _handleTap(BuildContext context) {
    HapticFeedback.mediumImpact();
    context.push('/studio/edit', extra: <String, String?>{
      'title': widget.label,
      'duration': '08',
      'subtitle': null,
      'preset': widget.preset,
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _handleTap(context);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingMd,
            horizontal: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: colors.outline, width: AppTheme.borderDefault),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: colors.primary, size: AppTheme.iconLg),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                widget.label,
                style: text.labelSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.detail.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  widget.detail,
                  style: text.labelSmall?.copyWith(color: colors.primary, fontSize: 10),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
