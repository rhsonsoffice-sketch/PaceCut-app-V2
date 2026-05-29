import 'package:flutter/material.dart';
import '../../theme/theme.dart';

// ---------------------------------------------------------------------------
// Preset definitions — drives cut block layout + highlight behaviour
// ---------------------------------------------------------------------------

enum _TimelinePreset { standard, viralFastCut, retentionBooster, dialoguePunchUp }

_TimelinePreset _resolvePreset(String? raw) {
  switch (raw) {
    case 'viral_fast_cut':
      return _TimelinePreset.viralFastCut;
    case 'retention_booster':
      return _TimelinePreset.retentionBooster;
    case 'dialogue_punch_up':
      return _TimelinePreset.dialoguePunchUp;
    default:
      return _TimelinePreset.standard;
  }
}

class _SegmentDef {
  final String label;
  final String timestamps;
  final double width;
  final bool highlight; // neon-purple glow for retention booster hook

  const _SegmentDef({
    required this.label,
    required this.timestamps,
    required this.width,
    this.highlight = false,
  });
}

List<_SegmentDef> _segmentsFor(_TimelinePreset preset) {
  switch (preset) {
    // Frequent 0.5 s rapid cuts — 9 compact blocks
    case _TimelinePreset.viralFastCut:
      return [
        const _SegmentDef(label: 'Cut 1', timestamps: '0.0s–0.5s', width: 52),
        const _SegmentDef(label: 'Cut 2', timestamps: '0.5s–1.0s', width: 52),
        const _SegmentDef(label: 'Cut 3', timestamps: '1.0s–1.5s', width: 52),
        const _SegmentDef(label: 'Cut 4', timestamps: '1.5s–2.0s', width: 52),
        const _SegmentDef(label: 'Cut 5', timestamps: '2.0s–2.5s', width: 52),
        const _SegmentDef(label: 'Cut 6', timestamps: '2.5s–3.0s', width: 52),
        const _SegmentDef(label: 'Cut 7', timestamps: '3.0s–3.5s', width: 52),
        const _SegmentDef(label: 'Cut 8', timestamps: '3.5s–4.0s', width: 52),
        const _SegmentDef(label: 'Cut 9', timestamps: '4.0s–5.0s', width: 80),
      ];
    // Hook segment (0.0–0.8 s) glows neon purple
    case _TimelinePreset.retentionBooster:
      return [
        const _SegmentDef(
          label: 'Hook',
          timestamps: '0.0s–0.8s',
          width: 80,
          highlight: true,
        ),
        const _SegmentDef(label: 'Cut 2', timestamps: '0.8s–2.5s', width: 170),
        const _SegmentDef(label: 'Cut 3', timestamps: '2.5s–5.0s', width: 250),
      ];
    // Dialogue: medium uniform cuts
    case _TimelinePreset.dialoguePunchUp:
      return [
        const _SegmentDef(label: 'Intro', timestamps: '0.0s–1.2s', width: 110),
        const _SegmentDef(label: 'Zoom 1', timestamps: '1.2s–2.4s', width: 110),
        const _SegmentDef(label: 'Zoom 2', timestamps: '2.4s–3.6s', width: 110),
        const _SegmentDef(label: 'Outro', timestamps: '3.6s–5.0s', width: 120),
      ];
    // Default three-cut layout
    case _TimelinePreset.standard:
      return [
        const _SegmentDef(label: 'Cut 1', timestamps: '0.0s–0.8s', width: 80),
        const _SegmentDef(label: 'Cut 2', timestamps: '0.8s–2.5s', width: 170),
        const _SegmentDef(label: 'Cut 3', timestamps: '2.5s–5.0s', width: 250),
      ];
  }
}

String _presetBadgeLabel(_TimelinePreset preset) {
  switch (preset) {
    case _TimelinePreset.viralFastCut:
      return '0.5s Cuts';
    case _TimelinePreset.retentionBooster:
      return 'Hook Mode';
    case _TimelinePreset.dialoguePunchUp:
      return 'Dialogue';
    case _TimelinePreset.standard:
      return 'AI Cuts';
  }
}

// ---------------------------------------------------------------------------
// Gradient palettes per segment index (cycles)
// ---------------------------------------------------------------------------

const List<List<Color>> _kPalettes = [
  [Color(0xFF9C5FFF), Color(0xFF7C3AED)],
  [Color(0xFFB06EFF), Color(0xFF9C5FFF)],
  [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  [Color(0xFFCB8BFF), Color(0xFFB06EFF)],
];

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class TimelineCuts extends StatelessWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final String? preset;

  const TimelineCuts({
    super.key,
    required this.appColors,
    required this.colors,
    this.preset,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final resolvedPreset = _resolvePreset(preset);
    final segments = _segmentsFor(resolvedPreset);
    final badgeLabel = _presetBadgeLabel(resolvedPreset);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────────
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
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
            Text('Timeline', style: text.titleSmall),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(badgeLabel),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm + 2,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: resolvedPreset == _TimelinePreset.retentionBooster
                      ? appColors.glowPurple.withOpacity(0.25)
                      : colors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(
                    color: resolvedPreset == _TimelinePreset.retentionBooster
                        ? appColors.glowPurple.withOpacity(0.7)
                        : colors.primary.withOpacity(0.3),
                    width: AppTheme.borderDefault,
                  ),
                  boxShadow: resolvedPreset == _TimelinePreset.retentionBooster
                      ? [
                          BoxShadow(
                            color: appColors.glowPurple.withOpacity(0.35),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: Text(
                  badgeLabel,
                  style: text.labelSmall?.copyWith(
                    color: resolvedPreset == _TimelinePreset.retentionBooster
                        ? appColors.glowPurple
                        : colors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),

        // ── Timeline container ──────────────────────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: _TimelineContainer(
            key: ValueKey(resolvedPreset),
            segments: segments,
            preset: resolvedPreset,
            appColors: appColors,
            colors: colors,
            text: text,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Inner container (key-switched by preset for AnimatedSwitcher)
// ---------------------------------------------------------------------------

class _TimelineContainer extends StatelessWidget {
  final List<_SegmentDef> segments;
  final _TimelinePreset preset;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;

  const _TimelineContainer({
    super.key,
    required this.segments,
    required this.preset,
    required this.appColors,
    required this.colors,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: colors.outline, width: AppTheme.borderDefault),
      ),
      child: Column(
        children: [
          // Ruler
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMd,
              AppTheme.spacingSm,
              AppTheme.spacingMd,
              0,
            ),
            child: _RulerRow(segments: segments),
          ),
          const SizedBox(height: AppTheme.spacingXs),

          // Track + Playhead
          SizedBox(
            height: 72,
            child: Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingXs,
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < segments.length; i++) ...[
                        if (i > 0) const SizedBox(width: 3),
                        _CutSegment(
                          def: segments[i],
                          palette: segments[i].highlight
                              ? [appColors.glowPurple, appColors.glowPurple.withOpacity(0.6)]
                              : _kPalettes[i % _kPalettes.length],
                          isHighlight: segments[i].highlight,
                          appColors: appColors,
                          colors: colors,
                          text: text,
                        ),
                      ],
                    ],
                  ),
                ),
                // Neon playhead at ~30 % of track width
                Positioned(
                  left: MediaQuery.of(context).size.width * 0.28,
                  top: 0,
                  bottom: 0,
                  child: _Playhead(appColors: appColors),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spacingSm),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ruler — shows first, middle and last timestamp labels
// ---------------------------------------------------------------------------

class _RulerRow extends StatelessWidget {
  final List<_SegmentDef> segments;
  const _RulerRow({required this.segments});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final style = text.labelSmall?.copyWith(fontSize: 9, letterSpacing: 0.2);
    // Extract start of first, start of middle, start of last, end of last
    final first = segments.first.timestamps.split('–').first.trim();
    final mid = segments.length > 2
        ? segments[segments.length ~/ 2].timestamps.split('–').first.trim()
        : null;
    final lastEnd = segments.last.timestamps.split('–').last.trim();

    return Row(
      children: [
        Text(first, style: style),
        const Spacer(),
        if (mid != null) ...[Text(mid, style: style), const Spacer()],
        Text(lastEnd, style: style),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cut segment block
// ---------------------------------------------------------------------------

class _CutSegment extends StatefulWidget {
  final _SegmentDef def;
  final List<Color> palette;
  final bool isHighlight;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;

  const _CutSegment({
    required this.def,
    required this.palette,
    required this.isHighlight,
    required this.appColors,
    required this.colors,
    required this.text,
  });

  @override
  State<_CutSegment> createState() => _CutSegmentState();
}

class _CutSegmentState extends State<_CutSegment> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.def.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.palette,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: widget.isHighlight
                  ? widget.appColors.glowPurple
                  : widget.colors.onPrimary.withOpacity(0.15),
              width: widget.isHighlight ? AppTheme.borderSelected : AppTheme.borderDefault,
            ),
            boxShadow: widget.isHighlight
                ? [
                    BoxShadow(
                      color: widget.appColors.glowPurple.withOpacity(0.55),
                      blurRadius: 14,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingXs + 2,
            vertical: AppTheme.spacingXs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.def.label,
                style: widget.text.labelSmall?.copyWith(
                  color: widget.colors.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                widget.def.timestamps,
                style: widget.text.labelSmall?.copyWith(
                  color: widget.colors.onPrimary.withOpacity(0.75),
                  fontSize: 9,
                ),
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
// Neon playhead
// ---------------------------------------------------------------------------

class _Playhead extends StatelessWidget {
  final AppColorsExtension appColors;
  const _Playhead({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: appColors.glowPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: appColors.glowPurple.withOpacity(0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          appColors.glowPurple,
                          appColors.glowPurple.withOpacity(0.3),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appColors.glowPurple.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
