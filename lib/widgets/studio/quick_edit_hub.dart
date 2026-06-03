import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';

// ---------------------------------------------------------------------------
// Tool enum
// ---------------------------------------------------------------------------

enum _EditTool { trim, speed, audio, captions }

// ---------------------------------------------------------------------------
// Public widget — owns the selected-tool state
// ---------------------------------------------------------------------------

class QuickEditHub extends StatefulWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;
  /// Called when the Trim panel's range slider changes.
  /// Provides (startSec, endSec) derived from the slider positions and
  /// a fixed 8.0 s reference duration.
  final void Function(double startSec, double endSec)? onTrimChanged;

  const QuickEditHub({
    super.key,
    required this.appColors,
    required this.colors,
    this.onTrimChanged,
  });

  @override
  State<QuickEditHub> createState() => _QuickEditHubState();
}

class _QuickEditHubState extends State<QuickEditHub> {
  _EditTool _active = _EditTool.trim;

  void _select(_EditTool tool) {
    HapticFeedback.selectionClick();
    if (_active != tool) setState(() => _active = tool);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.appColors.accentGradientStart,
                    widget.appColors.accentGradientEnd,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text('Quick Edit', style: text.titleSmall),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // ── Radio button row ──────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _EditToolButton(
                icon: Icons.content_cut_rounded,
                label: 'Trim',
                sublabel: 'Manual cuts',
                isActive: _active == _EditTool.trim,
                appColors: widget.appColors,
                colors: widget.colors,
                onTap: () => _select(_EditTool.trim),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _EditToolButton(
                icon: Icons.speed_rounded,
                label: 'Speed',
                sublabel: 'Pacing',
                isActive: _active == _EditTool.speed,
                appColors: widget.appColors,
                colors: widget.colors,
                onTap: () => _select(_EditTool.speed),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _EditToolButton(
                icon: Icons.music_note_rounded,
                label: 'Audio',
                sublabel: 'Sync sounds',
                isActive: _active == _EditTool.audio,
                appColors: widget.appColors,
                colors: widget.colors,
                onTap: () => _select(_EditTool.audio),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _EditToolButton(
                icon: Icons.closed_caption_rounded,
                label: 'Captions',
                sublabel: 'AI text',
                isActive: _active == _EditTool.captions,
                appColors: widget.appColors,
                colors: widget.colors,
                onTap: () => _select(_EditTool.captions),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // ── Sub-panel (animated swap) ─────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _buildPanel(_active),
        ),
      ],
    );
  }

  Widget _buildPanel(_EditTool tool) {
    switch (tool) {
      case _EditTool.trim:
        return _TrimPanel(
          key: const ValueKey(_EditTool.trim),
          appColors: widget.appColors,
          colors: widget.colors,
          onTrimChanged: widget.onTrimChanged,
        );
      case _EditTool.speed:
        return _SpeedPanel(
          key: const ValueKey(_EditTool.speed),
          appColors: widget.appColors,
          colors: widget.colors,
        );
      case _EditTool.audio:
        return _AudioPanel(
          key: const ValueKey(_EditTool.audio),
          appColors: widget.appColors,
          colors: widget.colors,
        );
      case _EditTool.captions:
        return _CaptionsPanel(
          key: const ValueKey(_EditTool.captions),
          appColors: widget.appColors,
          colors: widget.colors,
        );
    }
  }
}

// ---------------------------------------------------------------------------
// Radio button widget
// ---------------------------------------------------------------------------

class _EditToolButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool isActive;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _EditToolButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.isActive,
    required this.appColors,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_EditToolButton> createState() => _EditToolButtonState();
}

class _EditToolButtonState extends State<_EditToolButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingMd,
            horizontal: AppTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? widget.colors.primary.withOpacity(0.15)
                : widget.appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.isActive
                  ? widget.colors.primary.withOpacity(0.55)
                  : widget.colors.outline,
              width: widget.isActive ? AppTheme.borderSelected : AppTheme.borderDefault,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.appColors.glowPurple.withOpacity(0.20),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: widget.isActive
                      ? LinearGradient(
                          colors: [
                            widget.appColors.accentGradientStart,
                            widget.appColors.accentGradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.isActive ? null : widget.appColors.cardSurfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall + 2),
                ),
                child: Icon(
                  widget.icon,
                  size: AppTheme.iconMd,
                  color: widget.isActive
                      ? widget.colors.onPrimary
                      : widget.appColors.subtleText,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs + 2),
              Text(
                widget.label,
                style: text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: widget.isActive
                      ? widget.colors.primary
                      : widget.colors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.sublabel,
                style: text.labelSmall?.copyWith(
                  fontSize: 9,
                  color: widget.appColors.subtleText,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-panel: TRIM — dual slider handles on track edges
// ---------------------------------------------------------------------------

class _TrimPanel extends StatefulWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final void Function(double startSec, double endSec)? onTrimChanged;

  const _TrimPanel({
    super.key,
    required this.appColors,
    required this.colors,
    this.onTrimChanged,
  });

  @override
  State<_TrimPanel> createState() => _TrimPanelState();
}

class _TrimPanelState extends State<_TrimPanel> {
  double _start = 0.0;
  double _end = 1.0;

  static const double _kReferenceDuration = 8.0; // seconds

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final totalSec = _kReferenceDuration;
    final startSec = (_start * totalSec).toStringAsFixed(1);
    final endSec = (_end * totalSec).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: widget.appColors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: widget.colors.primary.withOpacity(0.25),
          width: AppTheme.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.content_cut_rounded,
                  size: AppTheme.iconSm, color: widget.colors.primary),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                'Trim Handles',
                style: text.labelMedium?.copyWith(
                  color: widget.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _TimeChip(
                label: '${startSec}s → ${endSec}s',
                appColors: widget.appColors,
                colors: widget.colors,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Track with draggable range
          Stack(
            alignment: Alignment.center,
            children: [
              // Full track background
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: widget.colors.outline,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Selected range fill
              LayoutBuilder(builder: (ctx, constraints) {
                return Positioned(
                  left: _start * constraints.maxWidth,
                  right: (1.0 - _end) * constraints.maxWidth,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.appColors.accentGradientStart,
                          widget.appColors.accentGradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ],
          ),

          // RangeSlider for the two handles
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 0,
              thumbColor: widget.colors.primary,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              overlayColor: widget.appColors.glowPurple.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: RangeSlider(
              values: RangeValues(_start, _end),
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() {
                  _start = v.start;
                  _end = v.end;
                });
                widget.onTrimChanged?.call(
                  _start * _kReferenceDuration,
                  _end * _kReferenceDuration,
                );
              },
              activeColor: widget.colors.primary,
              inactiveColor: widget.colors.outline,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'IN: ${startSec}s',
                style: text.labelSmall?.copyWith(
                  color: widget.appColors.subtleText,
                  fontSize: 10,
                ),
              ),
              Text(
                'OUT: ${endSec}s',
                style: text.labelSmall?.copyWith(
                  color: widget.appColors.subtleText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-panel: SPEED — clickable text pills
// ---------------------------------------------------------------------------

class _SpeedPanel extends StatefulWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;

  const _SpeedPanel({super.key, required this.appColors, required this.colors});

  @override
  State<_SpeedPanel> createState() => _SpeedPanelState();
}

class _SpeedPanelState extends State<_SpeedPanel> {
  int _selected = 1; // default: 1.0x (Normal)

  static const _speeds = ['0.5x', '1.0x\n(Normal)', '1.5x', '2.0x\nFast-Cut'];
  static const _labels = ['0.5x', '1.0x (Normal)', '1.5x', '2.0x Fast-Cut'];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: widget.appColors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: widget.colors.primary.withOpacity(0.25),
          width: AppTheme.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed_rounded,
                  size: AppTheme.iconSm, color: widget.colors.primary),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                'Playback Speed',
                style: text.labelMedium?.copyWith(
                  color: widget.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _TimeChip(
                label: _labels[_selected],
                appColors: widget.appColors,
                colors: widget.colors,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Speed pills
          Row(
            children: [
              for (int i = 0; i < _speeds.length; i++) ...[
                if (i > 0) const SizedBox(width: AppTheme.spacingSm),
                Expanded(child: _SpeedPill(
                  label: _speeds[i],
                  isSelected: _selected == i,
                  appColors: widget.appColors,
                  colors: widget.colors,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = i);
                  },
                )),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeedPill extends StatefulWidget {
  final String label;
  final bool isSelected;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _SpeedPill({
    required this.label,
    required this.isSelected,
    required this.appColors,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_SpeedPill> createState() => _SpeedPillState();
}

class _SpeedPillState extends State<_SpeedPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm + 2),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      widget.appColors.accentGradientStart,
                      widget.appColors.accentGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isSelected ? null : widget.appColors.cardSurfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.isSelected
                  ? widget.colors.primary.withOpacity(0.6)
                  : widget.colors.outline,
              width: widget.isSelected ? AppTheme.borderSelected : AppTheme.borderDefault,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.appColors.glowPurple.withOpacity(0.30),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: text.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: widget.isSelected
                  ? widget.colors.onPrimary
                  : widget.colors.onSurface,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-panel: AUDIO — sync audio track layer
// ---------------------------------------------------------------------------

class _AudioPanel extends StatefulWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;

  const _AudioPanel({super.key, required this.appColors, required this.colors});

  @override
  State<_AudioPanel> createState() => _AudioPanelState();
}

class _AudioPanelState extends State<_AudioPanel> {
  bool _trackAdded = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: widget.appColors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: widget.colors.primary.withOpacity(0.25),
          width: AppTheme.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note_rounded,
                  size: AppTheme.iconSm, color: widget.colors.primary),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                'Audio Track',
                style: text.labelMedium?.copyWith(
                  color: widget.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),

          // Audio layer tile
          _AudioTrackTile(
            appColors: widget.appColors,
            colors: widget.colors,
            isAdded: _trackAdded,
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _trackAdded = !_trackAdded);
            },
          ),

          if (_trackAdded) ...[
            const SizedBox(height: AppTheme.spacingMd),
            _VolumeRow(appColors: widget.appColors, colors: widget.colors),
          ],
        ],
      ),
    );
  }
}

class _AudioTrackTile extends StatefulWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final bool isAdded;
  final VoidCallback onTap;

  const _AudioTrackTile({
    required this.appColors,
    required this.colors,
    required this.isAdded,
    required this.onTap,
  });

  @override
  State<_AudioTrackTile> createState() => _AudioTrackTileState();
}

class _AudioTrackTileState extends State<_AudioTrackTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: widget.isAdded
                ? widget.colors.primary.withOpacity(0.12)
                : widget.appColors.cardSurfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.isAdded
                  ? widget.colors.primary.withOpacity(0.5)
                  : widget.colors.outline,
              width: widget.isAdded ? AppTheme.borderSelected : AppTheme.borderDefault,
            ),
            boxShadow: widget.isAdded
                ? [
                    BoxShadow(
                      color: widget.appColors.glowPurple.withOpacity(0.18),
                      blurRadius: 10,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: widget.isAdded
                      ? LinearGradient(
                          colors: [
                            widget.appColors.accentGradientStart,
                            widget.appColors.accentGradientEnd,
                          ],
                        )
                      : null,
                  color: widget.isAdded ? null : widget.appColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall + 2),
                ),
                child: Icon(
                  widget.isAdded ? Icons.check_rounded : Icons.add_rounded,
                  color: widget.isAdded
                      ? widget.colors.onPrimary
                      : widget.appColors.subtleText,
                  size: AppTheme.iconMd,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎵 Sync Viral Sound / Voiceover',
                      style: text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.isAdded
                            ? widget.colors.primary
                            : widget.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.isAdded ? 'Audio track added — drag to position' : 'Tap to add audio layer',
                      style: text.labelSmall?.copyWith(
                        fontSize: 10,
                        color: widget.appColors.subtleText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeRow extends StatefulWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;

  const _VolumeRow({required this.appColors, required this.colors});

  @override
  State<_VolumeRow> createState() => _VolumeRowState();
}

class _VolumeRowState extends State<_VolumeRow> {
  double _volume = 0.75;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(Icons.volume_up_rounded,
            size: AppTheme.iconSm, color: widget.appColors.subtleText),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbColor: widget.colors.primary,
              activeTrackColor: widget.colors.primary,
              inactiveTrackColor: widget.colors.outline,
              overlayColor: widget.appColors.glowPurple.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _volume,
              onChanged: (v) => setState(() => _volume = v),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          '${(_volume * 100).round()}%',
          style: text.labelSmall?.copyWith(
            fontSize: 10,
            color: widget.appColors.subtleText,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-panel: CAPTIONS — AI toggle + 3 style squares
// ---------------------------------------------------------------------------

class _CaptionsPanel extends StatefulWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;

  const _CaptionsPanel({super.key, required this.appColors, required this.colors});

  @override
  State<_CaptionsPanel> createState() => _CaptionsPanelState();
}

class _CaptionsPanelState extends State<_CaptionsPanel> {
  bool _aiEnabled = false;
  int _styleIndex = 0;

  static const _styles = ['Dynamic', 'Pop', 'Minimal'];
  static const _styleIcons = [
    Icons.flash_on_rounded,
    Icons.star_rounded,
    Icons.remove_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: widget.appColors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: widget.colors.primary.withOpacity(0.25),
          width: AppTheme.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI toggle row
          Row(
            children: [
              Icon(Icons.closed_caption_rounded,
                  size: AppTheme.iconSm, color: widget.colors.primary),
              const SizedBox(width: AppTheme.spacingXs),
              Expanded(
                child: Text(
                  'Auto-Generate AI Captions',
                  style: text.labelMedium?.copyWith(
                    color: widget.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _aiEnabled = !_aiEnabled);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: _aiEnabled
                        ? LinearGradient(
                            colors: [
                              widget.appColors.accentGradientStart,
                              widget.appColors.accentGradientEnd,
                            ],
                          )
                        : null,
                    color: _aiEnabled ? null : widget.colors.outline,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: _aiEnabled
                        ? [
                            BoxShadow(
                              color: widget.appColors.glowPurple.withOpacity(0.35),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment:
                        _aiEnabled ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Style selector (only visible when AI is enabled)
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _aiEnabled
                ? Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Caption Style',
                          style: text.labelSmall?.copyWith(
                            color: widget.appColors.subtleText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Row(
                          children: [
                            for (int i = 0; i < _styles.length; i++) ...[
                              if (i > 0)
                                const SizedBox(width: AppTheme.spacingSm),
                              Expanded(
                                child: _StyleSquare(
                                  icon: _styleIcons[i],
                                  label: _styles[i],
                                  isSelected: _styleIndex == i,
                                  appColors: widget.appColors,
                                  colors: widget.colors,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _styleIndex = i);
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _StyleSquare extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _StyleSquare({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.appColors,
    required this.colors,
    required this.onTap,
  });

  @override
  State<_StyleSquare> createState() => _StyleSquareState();
}

class _StyleSquareState extends State<_StyleSquare> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingMd,
            horizontal: AppTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            gradient: widget.isSelected
                ? LinearGradient(
                    colors: [
                      widget.appColors.accentGradientStart,
                      widget.appColors.accentGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isSelected ? null : widget.appColors.cardSurfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.isSelected
                  ? widget.colors.primary.withOpacity(0.6)
                  : widget.colors.outline,
              width: widget.isSelected ? AppTheme.borderSelected : AppTheme.borderDefault,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: widget.appColors.glowPurple.withOpacity(0.30),
                      blurRadius: 12,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: AppTheme.iconMd,
                color: widget.isSelected
                    ? widget.colors.onPrimary
                    : widget.appColors.subtleText,
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                widget.label,
                style: text.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: widget.isSelected
                      ? widget.colors.onPrimary
                      : widget.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helper chip
// ---------------------------------------------------------------------------

class _TimeChip extends StatelessWidget {
  final String label;
  final AppColorsExtension appColors;
  final ColorScheme colors;

  const _TimeChip({
    required this.label,
    required this.appColors,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: colors.primary.withOpacity(0.25),
          width: AppTheme.borderDefault,
        ),
      ),
      child: Text(
        label,
        style: text.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
