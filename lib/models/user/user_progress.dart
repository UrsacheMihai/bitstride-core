// User Progress data model and statistics calculation
class UserProgress {
  final String uid;
  String displayName;
  String email;
  int xp;
  int streak;
  Map<String, bool> completedExercises;
  Map<String, bool> completedChallenges;
  Map<String, String> earnedBadges;
  Map<String, int> exerciseBestXp;
  DateTime lastActiveDate;

  Map<String, int> exerciseAttempts;

  UserProgress({
    this.uid = 'local_user',
    this.displayName = 'Learner',
    this.email = '',
    this.xp = 0,
    this.streak = 0,
    Map<String, bool>? completedExercises,
    Map<String, bool>? completedChallenges,
    Map<String, String>? earnedBadges,
    Map<String, int>? exerciseBestXp,
    DateTime? lastActiveDate,
    Map<String, int>? exerciseAttempts,
  })  : completedExercises = completedExercises ?? {},
        completedChallenges = completedChallenges ?? {},
        earnedBadges = earnedBadges ?? {},
        exerciseBestXp = exerciseBestXp ?? {},
        lastActiveDate = lastActiveDate ?? DateTime.now(),
        exerciseAttempts = exerciseAttempts ?? {};

  int get level {
    int req = 100;
    int currentLevel = 1;
    int totalXp = xp;
    while (totalXp >= req) {
      totalXp -= req;
      currentLevel++;
      req = (req * 1.5).floor();
    }
    return currentLevel;
  }

  int get xpInCurrentLevel {
    int req = 100;
    int totalXp = xp;
    while (totalXp >= req) {
      totalXp -= req;
      req = (req * 1.5).floor();
    }
    return totalXp;
  }

  int get xpForNextLevel {
    int req = 100;
    int totalXp = xp;
    while (totalXp >= req) {
      totalXp -= req;
      req = (req * 1.5).floor();
    }
    return req;
  }

  int get totalCompleted =>
      completedExercises.length + completedChallenges.length;

  void recordAttempt(String exerciseId) {
    exerciseAttempts[exerciseId] = (exerciseAttempts[exerciseId] ?? 0) + 1;
  }
  
  int submitExerciseRun(String exerciseId, int currentRunXp, bool allPassed) {
    int previousBest = exerciseBestXp[exerciseId] ?? 0;
    int awarded = 0;
    if (currentRunXp > previousBest) {
      awarded = currentRunXp - previousBest;
      xp += awarded;
      exerciseBestXp[exerciseId] = currentRunXp;
    }
    if (allPassed && !completedExercises.containsKey(exerciseId)) {
      completedExercises[exerciseId] = true;
    }
    return awarded;
  }

  int markChallengeDone(String challengeId, int earnedXp) {
    if (!completedChallenges.containsKey(challengeId)) {
      completedChallenges[challengeId] = true;
      xp += earnedXp;
      return earnedXp;
    }
    return 0;
  }

  void unlockBadge(String badgeId, String badgeName) {
    if (!earnedBadges.containsKey(badgeId)) {
      earnedBadges[badgeId] = badgeName;
    }
  }

  void updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActiveDay =
        DateTime(lastActiveDate.year, lastActiveDate.month, lastActiveDate.day);
    final diff = today.difference(lastActiveDay).inDays;
    if (diff == 1) {
      streak++;
    } else if (diff > 1) {
      streak = 1;
    } else if (streak == 0) {
      streak = 1;
    }
    lastActiveDate = now;
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'email': email,
      'xp': xp,
      'streak': streak,
      'completed_exercises': completedExercises,
      'completed_challenges': completedChallenges,
      'earned_badges': earnedBadges,
      'exercise_best_xp': exerciseBestXp,
      'last_active': lastActiveDate.toIso8601String(),
      'level': level,
      'total_completed': totalCompleted,
      'exercise_attempts': exerciseAttempts,
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      uid: json['uid'] ?? 'local_user',
      displayName: json['display_name'] ?? 'Learner',
      email: json['email'] ?? '',
      xp: json['xp'] ?? 0,
      streak: json['streak'] ?? 0,
      completedExercises:
          Map<String, bool>.from(json['completed_exercises'] ?? {}),
      completedChallenges:
          Map<String, bool>.from(json['completed_challenges'] ?? {}),
      earnedBadges: Map<String, String>.from(json['earned_badges'] ?? {}),
      exerciseBestXp: Map<String, int>.from(json['exercise_best_xp'] ?? {}),
      lastActiveDate: json['last_active'] != null
          ? DateTime.parse(json['last_active'])
          : DateTime.now(),
      exerciseAttempts: Map<String, int>.from(json['exercise_attempts'] ?? {}),
    );
  }
}
