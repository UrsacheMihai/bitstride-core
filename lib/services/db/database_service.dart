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

}