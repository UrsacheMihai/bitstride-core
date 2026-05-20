import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user/user_progress.dart';

// Handle data operations and service integration for the Database Service.
class DatabaseService {
  static const String _userKey = 'bitstride_user_progress';
  static const String _settingsKey = 'bitstride_settings';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<UserProgress> loadUserProgress() async {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return UserProgress();
    return UserProgress.fromJson(jsonDecode(raw));
  }

  Future<void> saveUserProgress(UserProgress progress) async {
    await _prefs.setString(_userKey, jsonEncode(progress.toJson()));
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final raw = _prefs.getString(_settingsKey);
    if (raw == null) {
      return {
        'dark_mode': true,
        'language': 'en',
        'disable_motion': false,
      };
    }
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings));
  }

  Future<void> clearAll() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_settingsKey);
  }
}
