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
}