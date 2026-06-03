import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's session state across cold starts via shared_preferences.
///
/// Keys:
///   _kSignedIn  → bool   — whether the user has completed sign-in
///   _kEmail     → String — the stored user email (non-null when signed in)
///   _kIsPro     → bool   — whether the user holds an active PRO subscription
class SessionProvider extends ChangeNotifier {
  static const _kSignedIn = 'session_signed_in';
  static const _kEmail = 'session_email';
  static const _kIsPro = 'session_is_pro';

  // Default simulated email for the mock "sign-in" flow.
  static const String defaultEmail = 'creator@pacecut.ai';

  bool _isSignedIn = false;
  String? _email;
  bool _isPro = false;

  bool get isSignedIn => _isSignedIn;
  bool get isPro => _isPro;

  /// Non-null when [isSignedIn] is true.
  String? get email => _email;

  /// Display name derived from the email (part before @).
  String get displayName {
    if (_email == null) return 'Guest';
    final parts = _email!.split('@');
    return parts.isNotEmpty ? parts[0] : 'Creator';
  }

  /// Must be called once at app startup (before runApp or inside main()).
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSignedIn = prefs.getBool(_kSignedIn) ?? false;
    _email = prefs.getString(_kEmail);
    _isPro = prefs.getBool(_kIsPro) ?? false;
    notifyListeners();
  }

  /// Simulates sign-in — in a real app this would call an auth backend.
  /// Persists the session so it survives hot restarts and cold starts.
  Future<void> signIn({String email = defaultEmail}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSignedIn, true);
    await prefs.setString(_kEmail, email);
    _isSignedIn = true;
    _email = email;
    notifyListeners();
  }

  /// Simulates a successful IAP/Apple Pay transaction.
  /// Sets PRO_MEMBER = true and auto signs-in with the default account if
  /// the user was previously a guest.
  Future<void> upgradeToPro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPro, true);
    _isPro = true;
    // Ensure the account is marked signed-in after purchasing
    if (!_isSignedIn) {
      await prefs.setBool(_kSignedIn, true);
      await prefs.setString(_kEmail, defaultEmail);
      _isSignedIn = true;
      _email = defaultEmail;
    }
    notifyListeners();
  }

  /// Reverts PRO status (used for testing / subscription cancellation simulation).
  Future<void> cancelPro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kIsPro);
    _isPro = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSignedIn);
    await prefs.remove(_kEmail);
    await prefs.remove(_kIsPro);
    _isSignedIn = false;
    _email = null;
    _isPro = false;
    notifyListeners();
  }
}
