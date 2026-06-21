import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../../theme/theme.dart';
import '../../services/ffmpeg_service.dart';

class StudioAppBar extends StatefulWidget {
  final String title;
  final String? videoPath;
  /// Triggers a device-local FFmpeg trim before the export dialog opens.
  /// Returns the trimmed file path on success, or null.
  final Future<String?> Function()? onApplyTrim;
  /// True while a trim operation is already running (disables Export button).
  final bool isTrimming;

  const StudioAppBar({
    super.key,
    required this.title,
    this.videoPath,
    this.onApplyTrim,
    this.isTrimming = false,
  });

  @override
  State<StudioAppBar> createState() => _StudioAppBarState();
}

class _StudioAppBarState extends State<StudioAppBar> {
  bool _exportPressed = false;
  bool _backPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final canExport = !widget.isTrimming;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.outlineVariant,
            width: AppTheme.borderDefault,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── Back button ──────────────────────────────────────────────────
          GestureDetector(
            onTapDown: (_) => setState(() => _backPressed = true),
            onTapUp: (_) {
              setState(() => _backPressed = false);
              HapticFeedback.lightImpact();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            onTapCancel: () => setState(() => _backPressed = false),
            child: AnimatedScale(
              scale: _backPressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: appColors.cardSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: colors.outline, width: AppTheme.borderDefault),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: AppTheme.iconSm,
                  color: colors.onSurface,
                ),
              ),
            ),
          ),

          // ── Centered title ───────────────────────────────────────────────
          Expanded(
            child: Text(
              'PaceCut Studio',
              style: text.titleMedium?.copyWith(letterSpacing: 0.3),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Export button ────────────────────────────────────────────────
          GestureDetector(
            onTapDown: canExport ? (_) => setState(() => _exportPressed = true) : null,
            onTapUp: canExport
                ? (_) {
                    setState(() => _exportPressed = false);
                    HapticFeedback.mediumImpact();
                    _handleExportTap(context, appColors, colors, text);
                  }
                : null,
            onTapCancel: () => setState(() => _exportPressed = false),
            child: AnimatedScale(
              scale: _exportPressed ? 0.94 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: AnimatedOpacity(
                opacity: canExport ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingXs + 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appColors.accentGradientStart,
                        appColors.accentGradientEnd,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.glowPurple.withOpacity(0.45),
                        blurRadius: 14,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.isTrimming)
                        SizedBox(
                          width: AppTheme.iconSm,
                          height: AppTheme.iconSm,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                          ),
                        )
                      else
                        Icon(
                          Icons.upload_rounded,
                          size: AppTheme.iconSm,
                          color: colors.onPrimary,
                        ),
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        widget.isTrimming ? 'Trimming…' : 'Export',
                        style: text.labelLarge?.copyWith(
                          color: colors.onPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Export tap handler
  //
  // Flow:
  //  1. If no video imported → snackbar nudge.
  //  2. Show quality picker sheet.
  //  3. On quality selection:
  //     a. If the user has adjusted the trim slider → run FFmpeg trim first.
  //     b. Open _FfmpegExportDialog which runs compress + gallery save.
  // ─────────────────────────────────────────────────────────────────────────
  void _handleExportTap(
    BuildContext context,
    AppColorsExtension appColors,
    ColorScheme colors,
    TextTheme text,
  ) {
    if (widget.videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Import a video first to export.'),
          backgroundColor: appColors.cardSurfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: appColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (sheetCtx) => _ExportQualitySheet(
        appColors: appColors,
        colors: colors,
        text: text,
        onQualitySelected: (quality) {
          Navigator.pop(sheetCtx);
          _startFfmpegExport(context, appColors, colors, text, quality);
        },
      ),
    );
  }

  Future<void> _startFfmpegExport(
    BuildContext context,
    AppColorsExtension appColors,
    ColorScheme colors,
    TextTheme text,
    String qualityLabel,
  ) async {
    // If the user adjusted the trim sliders and we do not have a trimmed file
    // yet, apply the trim now before compression.
    String? sourcePath = widget.videoPath;
    if (widget.onApplyTrim != null) {
      final trimmed = await widget.onApplyTrim!();
      if (trimmed != null) sourcePath = trimmed;
    }
    if (!mounted || sourcePath == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FfmpegExportDialog(
        appColors: appColors,
        colors: colors,
        text: text,
        qualityLabel: qualityLabel,
        videoPath: sourcePath!,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quality picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _ExportQualitySheet extends StatelessWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;
  final void Function(String quality) onQualitySelected;

  const _ExportQualitySheet({
    required this.appColors,
    required this.colors,
    required this.text,
    required this.onQualitySelected,
  });

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
          const SizedBox(height: AppTheme.spacingLg),
          Text('Export Project', style: text.titleMedium),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'FFmpeg will compress and save your video locally.',
            style: text.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          _QualityOption(
            icon: Icons.hd_rounded,
            label: '1080p HD',
            sublabel: 'CRF 24 · ultrafast · Best for TikTok & Reels',
            appColors: appColors,
            colors: colors,
            text: text,
            onTap: () => onQualitySelected('1080p HD'),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          _QualityOption(
            icon: Icons.four_k_rounded,
            label: '4K Ultra',
            sublabel: 'CRF 24 · ultrafast · Maximum quality output',
            appColors: appColors,
            colors: colors,
            text: text,
            onTap: () => onQualitySelected('4K Ultra'),
          ),
          const SizedBox(height: AppTheme.spacingXl),
        ],
      ),
    );
  }
}

class _QualityOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;
  final VoidCallback onTap;

  const _QualityOption({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.appColors,
    required this.colors,
    required this.text,
    required this.onTap,
  });

  @override
  State<_QualityOption> createState() => _QualityOptionState();
}

class _QualityOptionState extends State<_QualityOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: widget.appColors.cardSurfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.colors.outline,
              width: AppTheme.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.appColors.accentGradientStart,
                      widget.appColors.accentGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(widget.icon, color: widget.colors.onPrimary, size: AppTheme.iconMd),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.label, style: widget.text.titleSmall),
                    Text(widget.sublabel, style: widget.text.bodySmall),
                  ],
                ),
              ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Real FFmpeg compress-and-export progress dialog
//
// Flow:
//  1. FFmpegService.compressAndExport() runs in the background with a real
//     statistics callback feeding _progressController.
//  2. The stream drives a real CircularProgressIndicator(value: _progress).
//  3. On success: ImageGallerySaver.saveFile(outputPath) saves to camera roll.
//  4. Temp file is deleted via FFmpegService.deleteTempFile().
// ─────────────────────────────────────────────────────────────────────────────
class _FfmpegExportDialog extends StatefulWidget {
  final AppColorsExtension appColors;
  final ColorScheme colors;
  final TextTheme text;
  final String qualityLabel;
  final String videoPath;

  const _FfmpegExportDialog({
    required this.appColors,
    required this.colors,
    required this.text,
    required this.qualityLabel,
    required this.videoPath,
  });

  @override
  State<_FfmpegExportDialog> createState() => _FfmpegExportDialogState();
}

class _FfmpegExportDialogState extends State<_FfmpegExportDialog> {
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();

  double _progress = 0.0;
  String _statusLabel = 'Initialising FFmpeg…';
  bool _done = false;
  bool _error = false;
  String? _outputPath;

  @override
  void initState() {
    super.initState();
    _progressController.stream.listen((p) {
      if (mounted) {
        setState(() {
          _progress = p;
          _statusLabel = _labelForProgress(p);
        });
      }
    });
    _runFfmpegExport();
  }

  String _labelForProgress(double p) {
    if (p < 0.05) return 'Initialising FFmpeg…';
    if (p < 0.25) return 'Analysing video stream…';
    if (p < 0.50) return 'Applying CRF 24 compression…';
    if (p < 0.75) return 'Encoding H.264 frames…';
    if (p < 0.90) return 'Muxing audio track…';
    if (p < 1.00) return 'Finalising output…';
    return 'Saving to Camera Roll…';
  }

  Future<void> _runFfmpegExport() async {
    // ── Step 1: FFmpeg compress ──────────────────────────────────────────
    final result = await FFmpegService.compressAndExport(
      inputPath: widget.videoPath,
      qualityLabel: widget.qualityLabel,
      progressController: _progressController,
    );

    if (!mounted) return;

    if (!result.success || result.outputPath == null) {
      setState(() {
        _done = true;
        _error = true;
        _statusLabel = 'FFmpeg error — see logs.';
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _showResultSnackbar(false);
      return;
    }

    _outputPath = result.outputPath;

    // ── Step 2: Save to gallery ──────────────────────────────────────────
    setState(() => _statusLabel = 'Saving to Camera Roll…');

    bool saved = false;
    try {
      final saveResult = await ImageGallerySaver.saveFile(_outputPath!);
      saved = saveResult is Map ? (saveResult['isSuccess'] == true) : false;
    } catch (_) {
      saved = false;
    }

    // ── Step 3: Cleanup temp file ────────────────────────────────────────
    await FFmpegService.deleteTempFile(_outputPath!);

    if (!mounted) return;
    setState(() {
      _done = true;
      _error = !saved;
      _statusLabel = saved ? 'Saved to Camera Roll!' : 'Export done (grant Photos access).';
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    _showResultSnackbar(saved);
  }

  void _showResultSnackbar(bool saved) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? '✓ Saved to Camera Roll (${widget.qualityLabel})'
              : 'Export finished. Grant Photos access if video did not save.',
        ),
        backgroundColor:
            saved ? widget.appColors.cardSurfaceLight : widget.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.appColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Progress ring or completion badge ────────────────────────
            SizedBox(
              width: 72,
              height: 72,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: _done
                    ? Container(
                        key: const ValueKey('done'),
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              widget.appColors.accentGradientStart,
                              widget.appColors.accentGradientEnd,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.appColors.glowPurple.withOpacity(0.45),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _error
                              ? Icons.warning_amber_rounded
                              : Icons.check_rounded,
                          color: widget.colors.onPrimary,
                          size: AppTheme.iconLg,
                        ),
                      )
                    : Stack(
                        key: const ValueKey('progress'),
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              // Real value driven by FFmpeg statistics callback
                              value: _progress > 0 ? _progress : null,
                              strokeWidth: 5,
                              backgroundColor:
                                  widget.colors.outline.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.appColors.glowPurple,
                              ),
                            ),
                          ),
                          Text(
                            _progress > 0
                                ? '${(_progress * 100).round()}%'
                                : '…',
                            style: widget.text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: widget.colors.onSurface,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Text(
              _done
                  ? (_error ? 'Export Finished' : 'Saved to Camera Roll!')
                  : 'FFmpeg Processing…',
              style: widget.text.titleMedium,
            ),

            const SizedBox(height: AppTheme.spacingXs),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _statusLabel,
                key: ValueKey(_statusLabel),
                style: widget.text.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Slim linear progress track
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                minHeight: 6,
                backgroundColor: widget.colors.outline.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.appColors.glowPurple,
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingSm),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.qualityLabel,
                  style: widget.text.labelSmall?.copyWith(
                    color: widget.colors.onSurface
                        .withOpacity(AppTheme.opacityHint),
                  ),
                ),
                Text(
                  'CRF 24 · ultrafast',
                  style: widget.text.labelSmall?.copyWith(
                    color: widget.colors.onSurface
                        .withOpacity(AppTheme.opacityHint),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
