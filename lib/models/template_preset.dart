import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// TemplatePreset — local configuration model for each PaceCut AI template.
//
// Each preset declares:
//   • intervalSec  — cut rhythm (how often a new cut is placed)
//   • capSec       — maximum output duration (hard cap)
//   • presetKey    — matches the existing Studio routing preset keys
//   • _filterDevice — full FFmpeg -vf filter string run on native iOS/Android
//   • _filterWeb   — empty string; web fallback skips re-encoding entirely
//
// The buildCommand() method assembles a complete FFmpeg execution string
// ready to pass directly to FFmpegKit.execute().
//
// Filter design notes:
//   hookMaster   → fps=25 keeps constant frame rate; trim to capSec via -t flag
//   vlogSpeedUp  → tblend=all_mode=average simulates motion blur between frames
//   dialoguePuncher → zoompan adds a subtle push-in zoom for speech segments
// ---------------------------------------------------------------------------

class TemplatePreset {
  final String id;
  final String displayName;

  /// Cut rhythm in seconds (e.g. 0.8 → one cut every 0.8s).
  final double intervalSec;

  /// Maximum output clip duration in seconds.
  final double capSec;

  /// Studio preset routing key — matches existing 'preset' map key in
  /// app_router.dart and StudioScreen._subtitleForPreset().
  final String presetKey;

  /// Human-readable subtitle shown in Studio and on Draft cards.
  final String subtitle;

  /// FFmpeg -vf filter string for native devices (iOS / Android).
  final String _filterDevice;

  const TemplatePreset._({
    required this.id,
    required this.displayName,
    required this.intervalSec,
    required this.capSec,
    required this.presetKey,
    required this.subtitle,
    required String filterDevice,
  }) : _filterDevice = filterDevice;

  // ── Static preset definitions ────────────────────────────────────────────

  /// 0.8s interval · 7s cap · fps normalisation filter
  static const hookMaster = TemplatePreset._(
    id: 'template_hook_master',
    displayName: 'The 0.8s Hook Master',
    intervalSec: 0.8,
    capSec: 7.0,
    presetKey: 'retention_booster',
    subtitle: 'Template: Hook Master (0.8s cuts)',
    filterDevice: 'fps=25,scale=1080:-2',
  );

  /// 1.2s interval · 12s cap · motion-blur tblend filter
  static const vlogSpeedUp = TemplatePreset._(
    id: 'template_vlog_speed_up',
    displayName: 'Vlog Speed-Up',
    intervalSec: 1.2,
    capSec: 12.0,
    presetKey: 'viral_fast_cut',
    subtitle: 'Template: Vlog Speed-Up (1.2s cuts · motion blur)',
    filterDevice: 'fps=25,tblend=all_mode=average,scale=1080:-2',
  );

  /// 0.5s interval · 15s cap · zoompan push-in filter
  static const dialoguePuncher = TemplatePreset._(
    id: 'template_dialogue_puncher',
    displayName: 'Dialogue Puncher',
    intervalSec: 0.5,
    capSec: 15.0,
    presetKey: 'dialogue_punch_up',
    subtitle: 'Template: Dialogue Puncher (0.5s cuts · zoom)',
    // zoompan: slow push-in zoom (z factor 1.0→1.05 over the clip duration)
    filterDevice:
        "fps=25,zoompan=z='min(zoom+0.001,1.05)':d=1:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1920,scale=1080:-2",
  );

  // ── All presets in display order ─────────────────────────────────────────
  static const List<TemplatePreset> all = [
    hookMaster,
    vlogSpeedUp,
    dialoguePuncher,
  ];

  // ── Command builder ──────────────────────────────────────────────────────

  /// Builds the complete FFmpeg command string for this template.
  ///
  /// On web ([kIsWeb] == true) FFmpeg is unavailable; returns null so the
  /// caller can skip processing and use the source path directly.
  ///
  /// [inputPath]  — absolute path to the source video file.
  /// [outputPath] — absolute path where the rendered output should be written.
  String? buildCommand(String inputPath, String outputPath) {
    if (kIsWeb) return null;
    // -t capSec trims to the template's maximum duration.
    // -vf applies the template's visual filter chain.
    // -c:v libx264 with CRF 22 / ultrafast for fast device rendering.
    // -c:a aac copies audio at 128k.
    // -movflags +faststart for progressive streaming.
    return '-i "$inputPath" '
        '-t $capSec '
        '-vf "$_filterDevice" '
        '-c:v libx264 -crf 22 -preset ultrafast '
        '-c:a aac -b:a 128k '
        '-movflags +faststart '
        '"$outputPath"';
  }

  /// Duration string shown on Draft cards, e.g. "00:07".
  String get capDurationLabel {
    final s = capSec.toInt();
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
