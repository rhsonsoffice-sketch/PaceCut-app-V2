import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/draft_model.dart';

/// Manages the "Your Drafts" list with full local persistence.
///
/// On first launch (no saved data), the list is seeded with 2 mock drafts
/// so the Home Screen looks active and fully functioning immediately.
/// Every mutation is flushed to shared_preferences as a JSON array.
class DraftsProvider extends ChangeNotifier {
  static const _kDrafts = 'drafts_list_v1';

  List<DraftProject> _drafts = [];

  /// Most-recent drafts first.
  List<DraftProject> get drafts => List.unmodifiable(_drafts);

  // ── Lifecycle ────────────────────────────────────────────────────────────

  /// Must be called once at app startup before the widget tree reads this
  /// provider.  Loads persisted drafts or seeds the default mock data.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kDrafts);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _drafts = list
            .map((e) => DraftProject.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Corrupted data — fall through to seed defaults.
        _drafts = _seedDrafts();
        await _persist(prefs);
      }
    } else {
      _drafts = _seedDrafts();
      await _persist(prefs);
    }
    notifyListeners();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Prepends [draft] to the list (most-recent first) and persists.
  /// If a draft with the same [id] already exists it is replaced in-place.
  Future<void> addDraft(DraftProject draft) async {
    final existingIdx = _drafts.indexWhere((d) => d.id == draft.id);
    if (existingIdx >= 0) {
      _drafts[existingIdx] = draft;
    } else {
      _drafts.insert(0, draft);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  /// Removes the draft with the given [id] and persists.
  Future<void> removeDraft(String id) async {
    _drafts.removeWhere((d) => d.id == id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await _persist(prefs);
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<void> _persist(SharedPreferences prefs) async {
    final encoded = jsonEncode(_drafts.map((d) => d.toJson()).toList());
    await prefs.setString(_kDrafts, encoded);
  }

  /// Two mock drafts that make the Home Screen look active out of the box.
  /// videoPath is null — the Studio will show the placeholder player.
  static List<DraftProject> _seedDrafts() => [
        DraftProject(
          id: 'seed_draft_001',
          title: 'TikTok_Hook_Draft1.mp4',
          videoPath: null,
          duration: '00:08',
          preset: 'viral_fast_cut',
          subtitle: 'Pacing: Aggressive (0.4s cuts)',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        DraftProject(
          id: 'seed_draft_002',
          title: 'Insta_Reel_V3.mp4',
          videoPath: null,
          duration: '00:15',
          preset: 'retention_booster',
          subtitle: 'Pacing: Dynamic (0.8s cuts)',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}
