import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import '../theme/theme.dart';
import '../services/ffmpeg_service.dart';
import '../providers/drafts_provider.dart';
import '../models/draft_model.dart';
import '../widgets/studio/studio_app_bar.dart';
import '../widgets/studio/video_preview_player.dart';
import '../widgets/studio/timeline_cuts.dart';
import '../widgets/studio/quick_edit_hub.dart';

class StudioScreen extends StatefulWidget {
  final String? draftTitle;
  final String? draftDuration;
  final String? draftSubtitle;
  final String? preset;
  final String? videoPath;

  const StudioScreen({
    super.key,
    this.draftTitle,
    this.draftDuration,
    this.draftSubtitle,
    this.preset,
    this.videoPath,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  VideoPlayerController? _controller;
  bool _controllerReady = false;
  // Retention Booster: track whether we have applied the 0.8s auto-seek
  bool _retentionSeekApplied = false;

  // ── Trim state ────────────────────────────────────────────────────────────
  // startSec/endSec are updated live from QuickEditHub's Trim sub-panel.
  // _trimmedVideoPath is set after FFmpeg finishes a trim operation and is
  // the path handed to StudioAppBar for the compress-and-export pipeline.
  double _trimStartSec = 0.0;
  double _trimEndSec = 8.0;
  String? _trimmedVideoPath; // non-null after a successful trim
  bool _isTrimming = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath != null) {
      _initController(widget.videoPath!);
    }
  }

  Future<void> _initController(String path) async {
    final ctrl = VideoPlayerController.file(File(path));
    _controller = ctrl;
    await ctrl.initialize();
    if (!mounted) return;

    // Retention Booster preset: auto-seek to 0.8s on first load
    if (widget.preset == 'retention_booster') {
      await ctrl.seekTo(const Duration(milliseconds: 800));
      _retentionSeekApplied = true;
    }

    ctrl.addListener(_onVideoUpdate);
    setState(() => _controllerReady = true);

    // Persist (or update) a draft entry so this project appears in Your Drafts
    // on the Home Screen immediately after a video is loaded.
    if (mounted) {
      _persistDraft(path, ctrl.value.duration);
    }
  }

  /// Saves or updates a DraftProject in the DraftsProvider.
  /// Uses the draftTitle from extra when available, falling back to the
  /// file name extracted from [path].
  void _persistDraft(String path, Duration duration) {
    final drafts = context.read<DraftsProvider>();

    // Derive a human-readable title: prefer the passed draftTitle, fall back
    // to the filename.
    final filename = path.split('/').last;
    final title = (widget.draftTitle?.isNotEmpty ?? false)
        ? widget.draftTitle!
        : filename;

    final durationStr = _formatDuration(duration)
        .replaceAll('.', ':')
        .split(':')
        .take(2)
        .join(':'); // e.g. "00:08"

    final preset = widget.preset;
    final subtitle = _subtitleForPreset(preset);

    // Re-use a stable id so repeated visits update rather than duplicate.
    final id = widget.draftTitle != null
        ? 'draft_${widget.draftTitle.hashCode}'
        : const Uuid().v4();

    drafts.addDraft(DraftProject(
      id: id,
      title: title,
      videoPath: path,
      duration: durationStr,
      preset: preset,
      subtitle: subtitle,
      createdAt: DateTime.now(),
    ));
  }

  static String _subtitleForPreset(String? preset) {
    switch (preset) {
      case 'viral_fast_cut':
        return 'Pacing: Aggressive (0.5s cuts)';
      case 'retention_booster':
        return 'Pacing: Hook Loop (0.8s)';
      case 'dialogue_punch_up':
        return 'Pacing: Dynamic (auto-zoom)';
      default:
        return 'Pacing: Standard';
    }
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    // When Retention Booster hits 5.0s, loop back to 0.8s to simulate hook cycle
    if (widget.preset == 'retention_booster' &&
        _retentionSeekApplied &&
        _controller!.value.isPlaying) {
      final pos = _controller!.value.position;
      if (pos >= const Duration(seconds: 5)) {
        _controller!.seekTo(const Duration(milliseconds: 800));
      }
    }
    setState(() {});
  }

  void _togglePlay() {
    HapticFeedback.lightImpact();
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (ctrl.value.isPlaying) {
      ctrl.pause();
    } else {
      ctrl.play();
    }
    setState(() {});
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$m:$s.$ms';
  }

  // ── Trim callbacks ────────────────────────────────────────────────────────

  /// Called by QuickEditHub whenever the RangeSlider moves.
  void _onTrimChanged(double startSec, double endSec) {
    setState(() {
      _trimStartSec = startSec;
      _trimEndSec = endSec;
      // Invalidate any previous trimmed file so the export uses the
      // updated range next time the user taps Export.
      _trimmedVideoPath = null;
    });
  }

  /// Executes the FFmpeg trim command and reloads the player with the result.
  /// Called when the user taps "Apply Trim" in the trim panel or implicitly
  /// triggered by [StudioAppBar] before compression if _trimmedVideoPath is null.
  Future<String?> _applyTrim() async {
    final src = widget.videoPath;
    if (src == null) return null;
    if (_isTrimming) return _trimmedVideoPath;

    setState(() => _isTrimming = true);
    HapticFeedback.mediumImpact();

    final result = await FFmpegService.trimVideo(
      inputPath: src,
      startSec: _trimStartSec,
      endSec: _trimEndSec,
    );

    if (!mounted) return null;

    if (result.success && result.outputPath != null) {
      // Reload the video player with the trimmed clip
      _controller?.removeListener(_onVideoUpdate);
      await _controller?.dispose();
      _controller = null;
      _controllerReady = false;
      _retentionSeekApplied = false;
      setState(() {
        _trimmedVideoPath = result.outputPath;
        _isTrimming = false;
      });
      await _initController(result.outputPath!);
    } else {
      setState(() => _isTrimming = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Trim failed — check video format.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    return _trimmedVideoPath;
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoUpdate);
    _controller?.dispose();
    // Clean up any FFmpeg temp trim file from device storage
    if (_trimmedVideoPath != null) {
      FFmpegService.deleteTempFile(_trimmedVideoPath!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final ctrl = _controller;
    final isPlaying = ctrl?.value.isPlaying ?? false;
    final currentTime = ctrl != null && ctrl.value.isInitialized
        ? _formatDuration(ctrl.value.position)
        : '00:00.0';
    final totalDuration = ctrl != null && ctrl.value.isInitialized
        ? _formatDuration(ctrl.value.duration)
        : (widget.draftDuration != null ? '00:${widget.draftDuration}.0' : '00:08.0');
    final progress = ctrl != null &&
            ctrl.value.isInitialized &&
            ctrl.value.duration.inMilliseconds > 0
        ? ctrl.value.position.inMilliseconds / ctrl.value.duration.inMilliseconds
        : 0.30;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              StudioAppBar(
                title: widget.draftTitle?.replaceAll('.mp4', '') ?? 'PaceCut Studio',
                // Export uses the trimmed output when available, falling back
                // to the original imported file.
                videoPath: _trimmedVideoPath ?? widget.videoPath,
                onApplyTrim: widget.videoPath != null ? _applyTrim : null,
                isTrimming: _isTrimming,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spacingMd),
                      VideoPreviewPlayer(
                        controller: _controllerReady ? ctrl : null,
                        isPlaying: isPlaying,
                        onTogglePlay: _togglePlay,
                        currentTime: currentTime,
                        totalDuration: totalDuration,
                        progress: progress.clamp(0.0, 1.0),
                        appColors: appColors,
                        colors: colors,
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      TimelineCuts(
                        appColors: appColors,
                        colors: colors,
                        preset: widget.preset,
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      QuickEditHub(
                        appColors: appColors,
                        colors: colors,
                        onTrimChanged: _onTrimChanged,
                      ),
                      const SizedBox(height: AppTheme.spacingXl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
