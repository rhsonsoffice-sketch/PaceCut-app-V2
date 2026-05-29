import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/theme.dart';

class VideoPreviewPlayer extends StatelessWidget {
  /// When non-null, renders the real video. When null, shows the placeholder canvas.
  final VideoPlayerController? controller;
  final bool isPlaying;
  final VoidCallback onTogglePlay;
  final String currentTime;
  final String totalDuration;
  final double progress;
  final AppColorsExtension appColors;
  final ColorScheme colors;

  const VideoPreviewPlayer({
    super.key,
    required this.controller,
    required this.isPlaying,
    required this.onTogglePlay,
    required this.currentTime,
    required this.totalDuration,
    required this.progress,
    required this.appColors,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final playerWidth = constraints.maxWidth * 0.72;
          final playerHeight = playerWidth * (16 / 9);

          return Container(
            width: playerWidth,
            height: playerHeight,
            decoration: BoxDecoration(
              color: appColors.cardSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: colors.primary.withOpacity(AppTheme.opacityGlow),
                width: AppTheme.borderSelected,
              ),
              boxShadow: [
                BoxShadow(
                  color: appColors.glowPurple.withOpacity(0.25),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 1),
              child: Stack(
                children: [
                  // ── Video layer or placeholder ──────────────────────────────
                  Positioned.fill(child: _VideoOrPlaceholder(
                    controller: controller,
                    appColors: appColors,
                    colors: colors,
                    text: text,
                  )),

                  // ── Top timestamp bar ───────────────────────────────────────
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _TimestampChip(label: currentTime, colors: colors, text: text),
                          _TimestampChip(label: totalDuration, colors: colors, text: text),
                        ],
                      ),
                    ),
                  ),

                  // ── Bottom controls ─────────────────────────────────────────
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spacingMd,
                        AppTheme.spacingXl,
                        AppTheme.spacingMd,
                        AppTheme.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.75),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          // Real progress bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: colors.outline.withOpacity(0.5),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                appColors.glowPurple,
                              ),
                              minHeight: 3,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          _PlayPauseButton(
                            isPlaying: isPlaying,
                            onToggle: onTogglePlay,
                            appColors: appColors,
                            colors: colors,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal: renders real video or the dark placeholder canvas
// ─────────────────────────────────────────────────────────────────────────────
class _VideoOrPlaceholder extends StatelessWidget {
  final VideoPlayerController? controller;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;

  const _VideoOrPlaceholder({
    required this.controller,
    required this.appColors,
    required this.colors,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    if (ctrl != null && ctrl.value.isInitialized) {
      // Real video frame — fitted to fill the 9:16 container
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: ctrl.value.size.width,
          height: ctrl.value.size.height,
          child: VideoPlayer(ctrl),
        ),
      );
    }

    // Placeholder canvas
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  appColors.cardSurface,
                  appColors.cardSurfaceLight,
                  const Color(0xFF0E0C18),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: AppTheme.opacitySubtle,
            child: CustomPaint(painter: _GridPainter(color: colors.outline)),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    appColors.accentGradientStart,
                    appColors.accentGradientEnd,
                  ],
                ).createShader(bounds),
                child: Icon(
                  Icons.videocam_rounded,
                  size: AppTheme.iconXl,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Video Preview',
                style: text.labelMedium?.copyWith(
                  color: colors.onSurface.withOpacity(AppTheme.opacityHint),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TimestampChip extends StatelessWidget {
  final String label;
  final ColorScheme colors;
  final TextTheme text;

  const _TimestampChip({
    required this.label,
    required this.colors,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: colors.outlineVariant.withOpacity(0.5),
          width: AppTheme.borderDefault,
        ),
      ),
      child: Text(
        label,
        style: text.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onToggle;
  final AppColorsExtension appColors;
  final ColorScheme colors;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.onToggle,
    required this.appColors,
    required this.colors,
  });

  @override
  State<_PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<_PlayPauseButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onToggle();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                widget.appColors.accentGradientStart,
                widget.appColors.accentGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.appColors.glowPurple.withOpacity(0.55),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey(widget.isPlaying),
              size: AppTheme.iconLg,
              color: widget.colors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
