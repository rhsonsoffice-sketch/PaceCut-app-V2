import 'dart:convert';

/// Represents a single saved video editing project in the "Your Drafts" list.
/// Serialized to/from JSON for local persistence via shared_preferences.
class DraftProject {
  final String id;
  final String title;

  /// Absolute path to the source video file on the device filesystem.
  /// May be null for seeded mock drafts (shown with placeholder thumbnail).
  final String? videoPath;

  /// Human-readable duration string, e.g. "00:08".
  final String duration;

  /// Pacing preset key: 'viral_fast_cut' | 'retention_booster' |
  /// 'dialogue_punch_up' | null (standard).
  final String? preset;

  /// Human-readable subtitle shown below the title on the draft card,
  /// e.g. "Pacing: Aggressive (0.4s cuts)".
  final String subtitle;

  final DateTime createdAt;

  const DraftProject({
    required this.id,
    required this.title,
    this.videoPath,
    required this.duration,
    this.preset,
    required this.subtitle,
    required this.createdAt,
  });

  // ── JSON serialization ───────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'videoPath': videoPath,
        'duration': duration,
        'preset': preset,
        'subtitle': subtitle,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DraftProject.fromJson(Map<String, dynamic> json) => DraftProject(
        id: json['id'] as String,
        title: json['title'] as String,
        videoPath: json['videoPath'] as String?,
        duration: json['duration'] as String,
        preset: json['preset'] as String?,
        subtitle: json['subtitle'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  factory DraftProject.fromJsonString(String raw) =>
      DraftProject.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  DraftProject copyWith({
    String? title,
    String? videoPath,
    String? duration,
    String? preset,
    String? subtitle,
  }) =>
      DraftProject(
        id: id,
        title: title ?? this.title,
        videoPath: videoPath ?? this.videoPath,
        duration: duration ?? this.duration,
        preset: preset ?? this.preset,
        subtitle: subtitle ?? this.subtitle,
        createdAt: createdAt,
      );
}
