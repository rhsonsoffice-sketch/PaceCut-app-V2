import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/statistics.dart';
import '../models/template_preset.dart';

// ---------------------------------------------------------------------------
// FFmpegService — all device-local video processing commands.
//
// Design decisions:
//   • Each public method is fully self-contained: builds the command, wires
//     the statistics callback, executes, and returns a typed result.
//   • Progress is surfaced as a StreamController<double> (0.0 → 1.0) so the
//     UI can drive a CircularProgressIndicator without polling.
//   • Output files are written to getTemporaryDirectory() so they are cleaned
//     up by the OS and never appear in the user's gallery until explicitly
//     saved by ImageGallerySaver.
//   • The statistics callback uses totalDuration (ms) from the first stat
//     packet to normalise progress — this avoids needing a separate probe.
// ---------------------------------------------------------------------------

class FFmpegResult {
  final bool success;
  final String? outputPath;
  final String? errorMessage;

  const FFmpegResult({
    required this.success,
    this.outputPath,
    this.errorMessage,
  });
}

class FFmpegService {
  // ─────────────────────────────────────────────────────────────────────────
  // TRIM
  // Executes: -i input -ss startSec -to endSec -c:v copy -c:a copy output
  // Stream emits progress 0.0 → 1.0 driven by statistics callback.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<FFmpegResult> trimVideo({
    required String inputPath,
    required double startSec,
    required double endSec,
    StreamController<double>? progressController,
  }) async {
    final tmpDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tmpDir.path}/pacecut_trim_$ts.mp4';

    // Duration of the clip in milliseconds — used to normalise progress
    final clipDurationMs = ((endSec - startSec) * 1000).round();
    int _firstTimeMs = -1;

    if (progressController != null && !progressController.isClosed) {
      FFmpegKitConfig.enableStatisticsCallback((Statistics stats) {
        final timeMs = stats.getTime();
        if (timeMs <= 0) return;
        if (_firstTimeMs < 0) _firstTimeMs = timeMs;
        final elapsed = timeMs - _firstTimeMs;
        final progress = clipDurationMs > 0
            ? (elapsed / clipDurationMs).clamp(0.0, 0.95)
            : 0.5;
        if (!progressController.isClosed) {
          progressController.add(progress);
        }
      });
    }

    final command =
        '-i "$inputPath" -ss $startSec -to $endSec -c:v copy -c:a copy "$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    // Disable stats callback after execution
    FFmpegKitConfig.enableStatisticsCallback((_) {});

    if (progressController != null && !progressController.isClosed) {
      progressController.add(1.0);
    }

    if (ReturnCode.isSuccess(returnCode)) {
      return FFmpegResult(success: true, outputPath: outputPath);
    } else {
      final logs = await session.getAllLogsAsString();
      return FFmpegResult(
        success: false,
        errorMessage: logs ?? 'FFmpeg trim failed (unknown error)',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMPRESS & EXPORT
  // Executes H.264 re-encode at CRF 24, ultrafast preset.
  // qualityLabel drives the scale filter:
  //   "4K Ultra" → scale=2160:-2   (≈ 4K portrait)
  //   "1080p HD"  → scale=1080:-2  (default)
  // Stream emits progress 0.0 → 1.0.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<FFmpegResult> compressAndExport({
    required String inputPath,
    required String qualityLabel,
    StreamController<double>? progressController,
  }) async {
    final tmpDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tmpDir.path}/pacecut_export_$ts.mp4';

    // Resolve scale and CRF per quality
    final scale = qualityLabel.contains('4K') ? 2160 : 1080;
    const crf = 24;
    const preset = 'ultrafast';

    // Probe total duration for progress normalisation
    final totalDurationMs = await _probeDurationMs(inputPath);
    int _firstTimeMs = -1;

    if (progressController != null && !progressController.isClosed) {
      FFmpegKitConfig.enableStatisticsCallback((Statistics stats) {
        final timeMs = stats.getTime();
        if (timeMs <= 0) return;
        if (_firstTimeMs < 0) _firstTimeMs = timeMs;
        final elapsed = timeMs - _firstTimeMs;
        final progress = totalDurationMs > 0
            ? (elapsed / totalDurationMs).clamp(0.0, 0.95)
            : 0.5;
        if (!progressController.isClosed) {
          progressController.add(progress);
        }
      });
    }

    // scale=-2 keeps aspect ratio and avoids odd-dimension codec errors
    final command = '-i "$inputPath" '
        '-vf "scale=$scale:-2" '
        '-c:v libx264 -crf $crf -preset $preset '
        '-c:a aac -b:a 128k '
        '-movflags +faststart '
        '"$outputPath"';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    FFmpegKitConfig.enableStatisticsCallback((_) {});

    if (progressController != null && !progressController.isClosed) {
      progressController.add(1.0);
    }

    if (ReturnCode.isSuccess(returnCode)) {
      return FFmpegResult(success: true, outputPath: outputPath);
    } else {
      final logs = await session.getAllLogsAsString();
      return FFmpegResult(
        success: false,
        errorMessage: logs ?? 'FFmpeg export failed (unknown error)',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: probe video duration via ffprobe-equivalent FFmpeg command.
  // Returns duration in milliseconds, or 0 on failure.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<int> _probeDurationMs(String inputPath) async {
    try {
      // Execute a null-output pass just to read the stream info
      final session = await FFmpegKit.execute(
        '-i "$inputPath" -f null -',
      );
      final logs = await session.getAllLogsAsString() ?? '';
      // Parse "Duration: HH:MM:SS.ss" from stderr output
      final match = RegExp(r'Duration:\s+(\d+):(\d+):(\d+\.\d+)')
          .firstMatch(logs);
      if (match != null) {
        final h = int.parse(match.group(1)!);
        final m = int.parse(match.group(2)!);
        final s = double.parse(match.group(3)!);
        return ((h * 3600 + m * 60 + s) * 1000).round();
      }
    } catch (_) {}
    return 0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APPLY TEMPLATE
  // Executes the per-template FFmpeg filter command built by
  // TemplatePreset.buildCommand().
  //
  // Web fallback: FFmpegKit is unavailable on web. When kIsWeb == true the
  // method immediately returns a successful FFmpegResult with outputPath set
  // to the original inputPath so the caller can navigate without processing.
  //
  // Device (iOS / Android): runs the full filter chain (fps, tblend, zoompan,
  // scale) and caps the clip at the template's capSec duration.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<FFmpegResult> applyTemplate({
    required String inputPath,
    required TemplatePreset template,
    StreamController<double>? progressController,
  }) async {
    // ── Web fallback ──────────────────────────────────────────────────────
    // Flutter Web has no native plugin registrar — FFmpegKit's late field is
    // uninitialised. Return the source path unchanged so the UI keeps working.
    if (kIsWeb) {
      if (progressController != null && !progressController.isClosed) {
        progressController.add(1.0);
      }
      return FFmpegResult(success: true, outputPath: inputPath);
    }

    // ── Device path ───────────────────────────────────────────────────────
    final tmpDir = await getTemporaryDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${tmpDir.path}/pacecut_tpl_${template.id}_$ts.mp4';

    final command = template.buildCommand(inputPath, outputPath);
    // buildCommand() returns null only on web — guarded above, so this is
    // always non-null here.
    if (command == null) {
      return FFmpegResult(success: false, errorMessage: 'No command for this platform');
    }

    // Probe total duration for progress normalisation
    final totalDurationMs = await _probeDurationMs(inputPath);
    int firstTimeMs = -1;

    if (progressController != null && !progressController.isClosed) {
      FFmpegKitConfig.enableStatisticsCallback((Statistics stats) {
        final timeMs = stats.getTime();
        if (timeMs <= 0) return;
        if (firstTimeMs < 0) firstTimeMs = timeMs;
        final elapsed = timeMs - firstTimeMs;
        final progress = totalDurationMs > 0
            ? (elapsed / totalDurationMs).clamp(0.0, 0.95)
            : 0.5;
        if (!progressController.isClosed) {
          progressController.add(progress);
        }
      });
    }

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    FFmpegKitConfig.enableStatisticsCallback((_) {});

    if (progressController != null && !progressController.isClosed) {
      progressController.add(1.0);
    }

    if (ReturnCode.isSuccess(returnCode)) {
      return FFmpegResult(success: true, outputPath: outputPath);
    } else {
      final logs = await session.getAllLogsAsString();
      return FFmpegResult(
        success: false,
        errorMessage: logs ?? 'Template render failed (unknown error)',
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cleanup: delete a temp file after it has been saved to the gallery.
  // ─────────────────────────────────────────────────────────────────────────
  static Future<void> deleteTempFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
