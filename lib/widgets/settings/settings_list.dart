import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../providers/session_provider.dart';

class SettingsList extends StatefulWidget {
  const SettingsList({super.key});

  @override
  State<SettingsList> createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  bool _highSensitivity = true;
  bool _notifications = true;
  String _exportQuality = '1080p / 60fps';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        _SectionLabel(label: 'PREFERENCES', text: text, colors: colors, appColors: appColors),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: colors.outlineVariant, width: AppTheme.borderDefault),
          ),
          child: Column(
            children: [
              // Export Quality
              _SelectItem(
                icon: Icons.high_quality_rounded,
                label: 'Export Quality',
                value: _exportQuality,
                appColors: appColors,
                colors: colors,
                text: text,
                onTap: () => _showQualitySheet(context, appColors, colors, text),
              ),
              _Divider(colors: colors),
              // AI Auto-Cut Sensitivity
              _ToggleItem(
                icon: Icons.tune_rounded,
                label: 'AI Auto-Cut Sensitivity',
                sublabel: _highSensitivity ? 'High' : 'Medium',
                value: _highSensitivity,
                appColors: appColors,
                colors: colors,
                text: text,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _highSensitivity = v);
                },
              ),
              _Divider(colors: colors),
              // Notification Preferences
              _ToggleItem(
                icon: Icons.notifications_outlined,
                label: 'Notification Preferences',
                sublabel: _notifications ? 'Enabled' : 'Disabled',
                value: _notifications,
                appColors: appColors,
                colors: colors,
                text: text,
                isLast: true,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => _notifications = v);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showQualitySheet(
    BuildContext context,
    AppColorsExtension appColors,
    ColorScheme colors,
    TextTheme text,
  ) {
    final isPro = context.read<SessionProvider>().isPro;
    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (_) => _QualitySheet(
        selectedQuality: _exportQuality,
        isPro: isPro,
        onSelected: (q) {
          if (q == '4K Ultra / 60fps' && !isPro) {
            Navigator.pop(context);
            context.push('/paywall');
            return;
          }
          setState(() => _exportQuality = q);
          Navigator.pop(context);
        },
        appColors: appColors,
        colors: colors,
        text: text,
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final TextTheme text;
  final ColorScheme colors;
  final AppColorsExtension appColors;

  const _SectionLabel({
    required this.label,
    required this.text,
    required this.colors,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
          label,
          style: text.labelSmall?.copyWith(
            color: colors.primary,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final ColorScheme colors;
  const _Divider({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: colors.outlineVariant,
      indent: AppTheme.spacingXl + AppTheme.spacingMd,
      endIndent: 0,
    );
  }
}

class _SelectItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;
  final VoidCallback onTap;

  const _SelectItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.appColors,
    required this.colors,
    required this.text,
    required this.onTap,
  });

  @override
  State<_SelectItem> createState() => _SelectItemState();
}

class _SelectItemState extends State<_SelectItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed
            ? widget.colors.outlineVariant.withOpacity(0.5)
            : Colors.transparent,
        child: _ItemRow(
          icon: widget.icon,
          label: widget.label,
          sublabel: widget.value,
          appColors: widget.appColors,
          colors: widget.colors,
          text: widget.text,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.value,
                style: widget.text.bodySmall?.copyWith(color: widget.colors.primary),
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Icon(
                Icons.chevron_right_rounded,
                color: widget.appColors.subtleText,
                size: AppTheme.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool value;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.value,
    required this.appColors,
    required this.colors,
    required this.text,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return _ItemRow(
      icon: icon,
      label: label,
      sublabel: sublabel,
      appColors: appColors,
      colors: colors,
      text: text,
      isLast: isLast,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: colors.primary,
        activeTrackColor: colors.primary.withOpacity(0.35),
        inactiveTrackColor: appColors.cardSurfaceLight,
        inactiveThumbColor: appColors.subtleText,
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Widget trailing;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;
  final bool isLast;

  const _ItemRow({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.trailing,
    required this.appColors,
    required this.colors,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.spacingMd,
        right: AppTheme.spacingMd,
        top: AppTheme.spacingSm,
        bottom: isLast ? AppTheme.spacingSm : AppTheme.spacingXs,
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(AppTheme.opacitySubtle),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(icon, size: AppTheme.iconSm + 4, color: colors.primary),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          // Labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  sublabel,
                  style: text.bodySmall?.copyWith(color: appColors.subtleText),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ─── Quality Sheet ────────────────────────────────────────────────────────────

class _QualitySheet extends StatelessWidget {
  final String selectedQuality;
  final bool isPro;
  final ValueChanged<String> onSelected;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;

  const _QualitySheet({
    required this.selectedQuality,
    required this.isPro,
    required this.onSelected,
    required this.appColors,
    required this.colors,
    required this.text,
  });

  static const List<Map<String, String>> _options = [
    {'label': '720p / 30fps', 'sub': 'Lightweight, fast upload'},
    {'label': '1080p / 60fps', 'sub': 'Best for TikTok & Reels'},
    {'label': '4K Ultra / 60fps', 'sub': 'PRO · Maximum quality'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text('Export Quality', style: text.titleMedium),
          const SizedBox(height: AppTheme.spacingMd),
          ..._options.map((o) {
            final isSelected = o['label'] == selectedQuality;
            final is4K = o['label'] == '4K Ultra / 60fps';
            final locked = is4K && !isPro;
            return GestureDetector(
              onTap: () => onSelected(o['label']!),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withOpacity(AppTheme.opacitySubtle)
                      : appColors.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: locked
                        ? appColors.accentGradientStart.withOpacity(0.45)
                        : isSelected
                            ? colors.primary
                            : colors.outline,
                    width: isSelected ? AppTheme.borderSelected : AppTheme.borderDefault,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o['label']!, style: text.titleSmall),
                          Text(
                            o['sub']!,
                            style: text.bodySmall?.copyWith(color: appColors.subtleText),
                          ),
                        ],
                      ),
                    ),
                    if (locked)
                      Icon(Icons.lock_rounded,
                          color: appColors.accentGradientStart, size: AppTheme.iconSm + 2)
                    else if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          color: colors.primary, size: AppTheme.iconMd),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppTheme.spacingSm),
        ],
      ),
    );
  }
}
