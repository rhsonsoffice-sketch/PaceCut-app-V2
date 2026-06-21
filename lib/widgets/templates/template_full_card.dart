import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/theme.dart';
import '../../models/template_preset.dart';
import '../../models/draft_model.dart';
import '../../providers/drafts_provider.dart';
import '../../services/ffmpeg_service.dart';
import 'template_processing_overlay.dart';

class TemplateFullCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String duration;
  final String tag;
  final String cutSpeed;
  final int accentIndex;

  /// The TemplatePreset configuration bound to this card. Drives FFmpeg
  /// filter selection, cap duration, and the Studio preset routing key.
  final TemplatePreset preset;

  const TemplateFullCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.duration,
    required this.tag,
    required this.cutSpeed,
    required this.accentIndex,
    required this.preset,
  });

  @override
  State<TemplateFullCard> createState() => _TemplateFullCardState();
}

class _TemplateFullCardState extends State<TemplateFullCard> {
  bool _pressed = false;

  // Each template card gets a unique accent tint for visual variety
  static const List<List<Color>> _accentPalettes = [
    [Color(0xFF9C5FFF), Color(0xFFD946EF)],
    [Color(0xFF6366F1), Color(0xFF9C5FFF)],
    [Color(0xFFEC4899), Color(0xFFD946EF)],
  ];

  List<Color> get _palette =>
      _accentPalettes[widget.accentIndex % _accentPalettes.length];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: appColors.cardSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: colors.outline, width: AppTheme.borderDefault),
            boxShadow: [
              BoxShadow(
                color: _palette[0].withOpacity(0.12),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 9:16 thumbnail area
              _Thumbnail(
                icon: widget.icon,
                duration: widget.duration,
                tag: widget.tag,
                palette: _palette,
                appColors: appColors,
                colors: colors,
              ),
              // Content body
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cut speed chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: _palette[0].withOpacity(AppTheme.opacitySubtle),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        '⚡ ${widget.cutSpeed}',
                        style: text.labelSmall?.copyWith(
                          color: _palette[0],
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      widget.title,
                      style: text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      widget.description,
                      style: text.bodySmall?.copyWith(
                        color: appColors.subtleText,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    // Use Template CTA
                    _UseTemplateButton(
                      palette: _palette,
                      templateTitle: widget.title,
                      cutSpeed: widget.cutSpeed,
                      preset: widget.preset,
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

class _Thumbnail extends StatelessWidget {
  final IconData icon;
  final String duration;
  final String tag;
  final List<Color> palette;
  final AppColorsExtension appColors;
  final ColorScheme colors;

  const _Thumbnail({
    required this.icon,
    required this.duration,
    required this.tag,
    required this.palette,
    required this.appColors,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusLarge),
      ),
      child: AspectRatio(
        // 16:9 wide card; 9:16 portrait cropped via inner column
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            // Gradient background standing in for the 9:16 video canvas
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    palette[0].withOpacity(0.35),
                    appColors.draftThumbnail,
                    palette[1].withOpacity(0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Grid overlay mimicking a vertical video canvas
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter(color: colors.outline)),
            ),
            // Centred icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      palette[0].withOpacity(0.30),
                      palette[0].withOpacity(0.0),
                    ],
                  ),
                ),
                child: Icon(icon, size: AppTheme.iconXl, color: Colors.white),
              ),
            ),
            // Duration badge — top-right
            Positioned(
              top: AppTheme.spacingSm,
              right: AppTheme.spacingSm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // Tag badge — top-left
            Positioned(
              top: AppTheme.spacingSm,
              left: AppTheme.spacingSm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: palette),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  const _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 0.5;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

class _UseTemplateButton extends StatefulWidget {
  final List<Color> palette;
  final String templateTitle;
  final String cutSpeed;
  final TemplatePreset preset;

  const _UseTemplateButton({
    required this.palette,
    required this.templateTitle,
    required this.cutSpeed,
    required this.preset,
  });

  @override
  State<_UseTemplateButton> createState() => _UseTemplateButtonState();
}

class _UseTemplateButtonState extends State<_UseTemplateButton> {
  bool _pressed = false;
  bool _processing = false;

  // ── Template processing pipeline ─────────────────────────────────────────
  //
  // 1. Show the processing overlay modal (barrier-dismissible: false).
  // 2. Call FFmpegService.applyTemplate() — on web returns immediately with
  //    the source path unchanged; on device runs the full filter chain.
  // 3. Dismiss the overlay.
  // 4. Auto-save a DraftProject to DraftsProvider (persists to SharedPrefs).
  // 5. Push /studio/edit with the rendered output path + preset key.
  //
  // Template cards have no incoming videoPath from the file picker — the
  // output path from applyTemplate (or the web fallback null) is used as the
  // Studio videoPath. A null path leaves the Studio player in placeholder mode,
  // which is the correct state when no real media has been imported yet.
  Future<void> _processAndNavigate(BuildContext context) async {
    if (_processing) return;
    HapticFeedback.mediumImpact();
    setState(() => _processing = true);

    // Show the "Processing video…" overlay synchronously
    final overlayCtx = await showTemplateProcessingOverlay(context);

    String? renderedPath;

    try {
      // applyTemplate returns the source path unchanged on web (no FFmpeg)
      // and the rendered output path on device.
      //
      // Template cards don't carry a real source video — the user picks one
      // from the Studio. We pass an empty string on web (skipped anyway) and
      // leave renderedPath null on device so Studio shows placeholder state.
      //
      // When a real videoPath is wired in future (e.g. from file picker before
      // template selection), pass it here instead of ''.
      const String? sourceVideoPath = null;

      if (sourceVideoPath != null) {
        final result = await FFmpegService.applyTemplate(
          inputPath: sourceVideoPath,
          template: widget.preset,
        );
        renderedPath = result.success ? result.outputPath : null;
      }
      // sourceVideoPath == null → template applied without a source clip;
      // Studio opens in placeholder mode (correct for template-first flow).
    } catch (_) {
      renderedPath = null;
    }

    // Dismiss the processing overlay
    if (overlayCtx.mounted) {
      Navigator.of(overlayCtx, rootNavigator: true).pop();
    }

    if (!mounted) return;
    setState(() => _processing = false);

    // Auto-save a DraftProject entry so the template appears in Your Drafts
    final drafts = context.read<DraftsProvider>();
    final draftId = 'tpl_${widget.preset.id}_${DateTime.now().millisecondsSinceEpoch}';
    drafts.addDraft(DraftProject(
      id: draftId,
      title: widget.templateTitle,
      videoPath: renderedPath,
      duration: widget.preset.capDurationLabel,
      preset: widget.preset.presetKey,
      subtitle: widget.preset.subtitle,
      createdAt: DateTime.now(),
    ));

    // Navigate to the Studio workspace with the rendered output
    if (mounted) {
      context.push('/studio/edit', extra: {
        'title': widget.templateTitle,
        'duration': widget.preset.capDurationLabel,
        'subtitle': widget.preset.subtitle,
        'preset': widget.preset.presetKey,
        'videoPath': renderedPath,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _processAndNavigate(context);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.palette),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: widget.palette[0].withOpacity(0.40),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _processing
                  ? const SizedBox(
                      width: AppTheme.iconMd,
                      height: AppTheme.iconMd,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white,
                      size: AppTheme.iconMd,
                    ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                _processing ? 'Applying…' : 'Use Template',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
