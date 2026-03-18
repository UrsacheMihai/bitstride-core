// Provide global application state, authentication, and progress tracking.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user/user_progress.dart';
import '../../models/exercise/exercise.dart';
import '../../services/auth/auth_service.dart';
import '../../services/db/database_service.dart';
import '../../services/db/firestore_service.dart';
import '../../services/content/content_service.dart';
import '../../services/judge/judge_config.dart';

// Manage state and provide providers for App State.
class AppState extends ChangeNotifier {

  final AuthService _auth = AuthService();
  final DatabaseService _localDb = DatabaseService();
  final FirestoreService _cloudDb = FirestoreService();
  final ContentService _content = ContentService();

  UserProgress _userProgress = UserProgress();
  List<Course> _courses = [];
  List<Challenge> _challenges = [];
  
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  bool _isAuthenticated = false;
  DateTime? _lastRefresh;

  UserProgress get userProgress => _userProgress;
  List<Course> get courses => _courses;
  List<Challenge> get challenges => _challenges;
  
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _auth.currentUser;
  
  bool get isDarkMode => _settings['dark_mode'] ?? true;
  bool get motionDisabled => _settings['disable_motion'] == true;
  String get language => _settings['language'] ?? 'en';
  String get codeTheme => _settings['code_theme'] ?? 'Dracula';
  
  String get judgeUrl => _settings['judge_url'] ?? 'http://localhost:2001';

  Future<void> initialize() async {
    await _localDb.init();
    _settings = await _localDb.loadSettings();
    notifyListeners();
    _auth.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadUserData(user);
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _userProgress = UserProgress();
        _settings = await _localDb.loadSettings();
      }
      await refreshContent();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> refreshContent() async {
    String lang = _settings['language'] ?? 'en';
    _courses = await _content.loadAllCourses(lang);
    _challenges = await _content.loadAllChallenges(lang);
    try {
      final community = await _cloudDb.loadApprovedUserChallenges();
      _challenges = [
        ..._challenges,
        ...await _content.translateChallenges(community, lang)
      ];
    } catch (_) {}
    _lastRefresh = DateTime.now();
    notifyListeners();
  }

  Future<void> refreshIfStale() async {
    if (_lastRefresh == null ||
        DateTime.now().difference(_lastRefresh!).inMinutes >= 5) {
      await refreshContent();
    }
  }

  Future<void> _loadUserData(User user) async {
    try {
      _userProgress = await _cloudDb.loadUserProgress(user.uid);
      _settings = await _cloudDb.loadSettings(user.uid);
    } catch (_) {
      _userProgress = await _localDb.loadUserProgress();
      _settings = await _localDb.loadSettings();
    }
    _userProgress.displayName = user.displayName ?? _userProgress.displayName;
    _userProgress.email = user.email ?? '';
    _userProgress.updateStreak();
    _syncJudgeConfig();
    await _saveProgress();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmail(email: email, password: password);
  }

  Future<void> signUpWithEmail(
}