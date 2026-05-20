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
      String email, String password, String name) async {
    await _auth.signUpWithEmail(
      email: email,
      password: password,
      displayName: name,
    );
  }

  Future<void> signInWithGoogle() async {
    await _auth.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.resetPassword(email);
  }

  Future<void> _saveProgress() async {
    await _localDb.saveUserProgress(_userProgress);
    if (_auth.uid != null) {
      try {
        await _cloudDb.saveUserProgress(_auth.uid!, _userProgress);
      } catch (_) {}
    }
  }

  Future<void> _saveSettings() async {
    await _localDb.saveSettings(_settings);
    if (_auth.uid != null) {
      try {
        await _cloudDb.saveSettings(_auth.uid!, _settings);
      } catch (_) {}
    }
  }

  Future<int> submitExerciseRun(String exerciseId, int runXp, bool allPassed,
      {String language = 'cpp', bool perfect = true}) async {
    _userProgress.recordAttempt(exerciseId);
    final awarded =
        _userProgress.submitExerciseRun(exerciseId, runXp, allPassed);
    _checkBadges(language: language, perfect: perfect);
    await _saveProgress();
    notifyListeners();
    return awarded;
  }

  Future<int> completeChallenge(String challengeId, int xpReward,
      {String? language, bool perfect = false}) async {
    _userProgress.recordAttempt(challengeId);
    final awarded = _userProgress.markChallengeDone(challengeId, xpReward);
    _checkBadges(language: language, perfect: perfect);
    await _saveProgress();
    notifyListeners();
    return awarded;
  }

  void _checkBadges({String? language, bool perfect = false}) {
    final t = _userProgress.totalCompleted;
    if (t >= 1) _userProgress.unlockBadge('first_stride', 'First Stride');
    if (_userProgress.completedChallenges.isNotEmpty) {
      _userProgress.unlockBadge('challenge_accepted', 'Challenge Accepted');
    }
    if (t >= 5) _userProgress.unlockBadge('five_stages', 'Getting Warmed Up');
    if (t >= 10) _userProgress.unlockBadge('ten_down', 'Ten Down');
    if (t >= 25) _userProgress.unlockBadge('twenty_five', 'Quarter Century');
    final l = _userProgress.level;
    if (l >= 5) _userProgress.unlockBadge('level_5', 'Dedicated Scholar');
    if (l >= 10) _userProgress.unlockBadge('level_10', 'Master Scholar');
    if (l >= 15) _userProgress.unlockBadge('level_15', 'Grandmaster');
    final s = _userProgress.streak;
    if (s >= 3) _userProgress.unlockBadge('streak_3', '3-Day Streak');
    if (s >= 7) _userProgress.unlockBadge('streak_7', '7-Day Streak');
    if (s >= 15) _userProgress.unlockBadge('streak_15', '15-Day Streak');
    if (s >= 30) _userProgress.unlockBadge('streak_30', '30-Day Streak');
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour < 4)
      _userProgress.unlockBadge('night_owl', 'Night Owl');
    if (hour >= 5 && hour < 8)
      _userProgress.unlockBadge('early_bird', 'Early Bird');
    final weekday = DateTime.now().weekday;
    if (weekday == 6 || weekday == 7)
      _userProgress.unlockBadge('weekend_warrior', 'Weekend Warrior');
    if (perfect) _userProgress.unlockBadge('perfectionist', 'Perfectionist');
    if (language == 'python') {
      _userProgress.unlockBadge('python_novice', 'Python Novice');
      if (t >= 5) _userProgress.unlockBadge('python_pro', 'Python Pro');
    } else if (language == 'cpp') {
      _userProgress.unlockBadge('cpp_novice', 'C++ Novice');
      if (t >= 5) _userProgress.unlockBadge('cpp_pro', 'C++ Pro');
    }

    int completedChallengesCount = 0;
    for (final challenge in _challenges) {
      if (isChallengeCompleted(challenge.id)) {
        completedChallengesCount++;
      }
    }
    if (completedChallengesCount >= 5) {
      _userProgress.unlockBadge('algo_master', 'Algorithm Master');
    }

    int completedTheoryCount = 0;
    for (final course in _courses) {
      for (final lesson in course.lessons) {
        final hasContent = lesson.contentBlocks.isNotEmpty;
        final hasCode = lesson.tests.isNotEmpty ||
            lesson.initialCode.trim().isNotEmpty ||
            (lesson.initialCodeCpp?.trim().isNotEmpty ?? false) ||
            (lesson.initialCodePython?.trim().isNotEmpty ?? false);
        if (hasContent && !hasCode && isExerciseCompleted(lesson.id)) {
          completedTheoryCount++;
        }
      }
    }
    if (completedTheoryCount >= 3) {
      _userProgress.unlockBadge('theory_titan', 'Theory Titan');
    }

    int perfectExercises = 0;
    for (final id in _userProgress.completedExercises.keys) {
      if ((_userProgress.exerciseAttempts[id] ?? 0) == 1) {
        perfectExercises++;
      }
    }
    for (final id in _userProgress.completedChallenges.keys) {
      if ((_userProgress.exerciseAttempts[id] ?? 0) == 1) {
        perfectExercises++;
      }
    }
    if (perfectExercises >= 5) {
      _userProgress.unlockBadge('perfect_five', 'Flawless Five');
    }

    if (_userProgress.earnedBadges.containsKey('cpp_novice') &&
        _userProgress.earnedBadges.containsKey('python_novice')) {
      _userProgress.unlockBadge('polyglot', 'Polyglot Coder');
    }
  }

  bool isExerciseCompleted(String id) {
    return _userProgress.completedExercises.containsKey(id);
  }

  bool isChallengeCompleted(String id) {
    return _userProgress.completedChallenges.containsKey(id);
  }

  Future<void> toggleDarkMode() async {
    _settings['dark_mode'] = !isDarkMode;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleMotion() async {
    _settings['disable_motion'] = !motionDisabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _settings['language'] = lang;
    await _saveSettings();
    _isLoading = true;
    notifyListeners();
    await refreshContent();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setCodeTheme(String theme) async {
    _settings['code_theme'] = theme;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateDisplayName(String name) async {
    _userProgress.displayName = name;
    await _auth.currentUser?.updateDisplayName(name);
    await _saveProgress();
    notifyListeners();
  }

  void _syncJudgeConfig() {
    JudgeConfig.setBaseUrl(judgeUrl);
  }

  Future<void> setJudgeUrl(String url) async {
    _settings['judge_url'] = url;
    _syncJudgeConfig();
    await _saveSettings();
    notifyListeners();
  }
}
