// Test user progress model functionalities.
import 'package:flutter_test/flutter_test.dart';
import 'package:bitstride_core/models/user/user_progress.dart';

// Run user progress tests.
void main() {
  // Group user progress tests.
  group('UserProgress Tests', () {
    // Test default constructor values.
    test('default constructor sets correct initial values', () {
      final progress = UserProgress();
      expect(progress.uid, 'local_user');
      expect(progress.displayName, 'Learner');
      expect(progress.xp, 0);
      expect(progress.streak, 0);
      expect(progress.completedExercises, isEmpty);
      expect(progress.completedChallenges, isEmpty);
      expect(progress.earnedBadges, isEmpty);
      expect(progress.exerciseBestXp, isEmpty);
      expect(progress.exerciseAttempts, isEmpty);
    });

    // Test record attempt functionality.
    test('recordAttempt increments attempt count', () {
      final progress = UserProgress();
      progress.recordAttempt('ex1');
      expect(progress.exerciseAttempts['ex1'], 1);
      progress.recordAttempt('ex1');
      expect(progress.exerciseAttempts['ex1'], 2);
    });

    // Test submitting exercise run.
    test('submitExerciseRun awards xp and marks completed', () {
      final progress = UserProgress();
      final xpAwarded = progress.submitExerciseRun('ex1', 50, true);
      expect(xpAwarded, 50);
      expect(progress.xp, 50);
      expect(progress.completedExercises['ex1'], true);
    });
  });
}
