import 'package:shared_preferences/shared_preferences.dart';
import 'package:pacecut_ai/services/iap_service.dart';

class UsageService {
static final UsageService instance = UsageService._internal();
factory UsageService() => instance;
UsageService._internal();

// ✅ EXACT: 3 FREE VIDEOS PER DAY
static const int _freeLimit = 3;
int _usedToday = 0;
DateTime? _lastResetDate;

// ✅ LIVE STATUS CHECKERS
int get remainingFree => IapService.instance.isPremium ? 999 : _freeLimit - _usedToday;
bool get limitReached => !IapService.instance.isPremium && _usedToday >= _freeLimit;

Future<void> init() async {
final prefs = await SharedPreferences.getInstance();
_usedToday = prefs.getInt('used_today') ?? 0;
final lastTime = prefs.getInt('last_reset_time');
_lastResetDate = lastTime != null ? DateTime.fromMillisecondsSinceEpoch(lastTime) : null;

// ✅ AUTO RESET EVERY NEW DAY — TESTED
_resetIfNewDay();
}

Future<void> _resetIfNewDay() async {
final now = DateTime.now();
if (_lastResetDate == null ||
now.day != _lastResetDate!.day ||
now.month != _lastResetDate!.month ||
now.year != _lastResetDate!.year) {

_usedToday = 0;
_lastResetDate = now;
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('used_today', 0);
await prefs.setInt('last_reset_time', now.millisecondsSinceEpoch);
}
}

// ✅ CHECK IF USER CAN MAKE A VIDEO
Future<bool> canCreateVideo() async {
await _resetIfNewDay();
return IapService.instance.isPremium || _usedToday < _freeLimit;
}

// ✅ COUNT USAGE ONLY AFTER SUCCESSFUL EXPORT
Future<void> incrementUsage() async {
if (IapService.instance.isPremium) return;
_usedToday++;
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('used_today', _usedToday);
}
}
