// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BitStride';

  @override
  String get loading => 'Loading...';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get disableMotion => 'Disable Motion';

  @override
  String get disableMotionSubtitle => 'Replaces GIF mascots with static icons';

  @override
  String get language => 'Language';

  @override
  String get displayName => 'Display Name';

  @override
  String get changeName => 'Change Name';

  @override
  String get enterDisplayName => 'Enter display name';

  @override
  String get badges => 'Badges';

  @override
  String earnedBadges(int count) {
    return '$count earned';
  }

  @override
  String get stats => 'Stats';

  @override
  String get exercisesCompleted => 'Exercises completed';

  @override
  String get challengesSolved => 'Challenges solved';

  @override
  String get currentStreak => 'Current streak';

  @override
  String days(int count) {
    return '$count days';
  }

  @override
  String get totalXP => 'Total XP';

  @override
  String get learn => 'Learn';

  @override
  String get practice => 'Practice';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get profile => 'Profile';

  @override
  String level(int lvl) {
    return 'Level $lvl';
  }

  @override
  String xpTotal(int xp) {
    return '$xp XP total';
  }

  @override
  String get runCode => 'Run Code';

  @override
  String get submit => 'Submit';

  @override
  String get hint => 'Hint';

  @override
  String get solution => 'Solution';

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get nextLesson => 'Next Lesson';

  @override
  String get backToLessons => 'Back to Lessons';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get problemDescription => 'Problem Description';

  @override
  String get providedFiles => 'Provided Files:';

  @override
  String get example => 'Example:';

  @override
  String get input => 'Input:';

  @override
  String get output => 'Output:';

  @override
  String get submitCode => 'Submit Code';

  @override
  String get running => 'Running...';

  @override
  String get allLevels => 'All Levels';

  @override
  String get noChallenges => 'No challenges match your filters';

  @override
  String get noCourses => 'No courses available yet';

  @override
  String get lesson => 'Lesson';

  @override
  String get learnTab => 'Learn';

  @override
  String get practiceTab => 'Practice';

  @override
  String get dayStreak => 'Day Streak!';

  @override
  String get keepPracticing => 'Keep practicing to maintain your streak';

  @override
  String get current => 'Current';

  @override
  String get xpLabel => 'XP';

  @override
  String get done => 'Done';

  @override
  String get keepLearning => 'Keep Learning';

  @override
  String get searchChallenges => 'Search challenges...';

  @override
  String get category => 'Category';

  @override
  String get method => 'Method';

  @override
  String get allCategories => 'All';

  @override
  String get allMethods => 'All';

  @override
  String get markAsRead => 'Mark as Read';

  @override
  String get lessonCompleted => 'Lesson marked as completed!';

  @override
  String get theoryOnly => 'Theory Lesson';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDesc => 'Enter your email to receive a reset link';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetEmailSent => 'Password reset email sent!';

  @override
  String get theoryBadge => 'Theory';

  @override
  String get codeBadge => 'Code';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String resultsFound(int count) {
    return '$count results found';
  }

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get noAccount => 'Don\'t have an account? Sign Up';

  @override
  String get haveAccount => 'Already have an account? Sign In';

  @override
  String get visualizeTab => 'Visualize';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get quizQuestion => 'Quiz Question';

  @override
  String get multipleChoice => 'Multiple Choice';

  @override
  String get perfectScore => 'Perfect Score!';

  @override
  String get lessonFinished => 'Lesson Completed!';

  @override
  String get theoryRead => 'Theory Read';

  @override
  String get quizScore => 'Quiz Score';

  @override
  String get codeTests => 'Code Tests';

  @override
  String get totalXpScore => 'Total XP Score';

  @override
  String gainedXp(int count) {
    return 'You gained +$count XP!';
  }

  @override
  String get answerAllQuizzes => 'Answer all quizzes to finish';

  @override
  String get runCodeOnce => 'Run code at least once to finish';

  @override
  String get finishLesson => 'Finish Lesson';

  @override
  String get continueBtn => 'Continue';

  @override
  String get redoNoXp => 'Redo - No new XP awarded';

  @override
  String get mixedBadge => 'Mixed';

  @override
  String testsPassed(int passed, int total, int percentage) {
    return '$passed / $total tests passed ($percentage%)';
  }

  @override
  String testHidden(int index) {
    return 'Test $index (hidden)';
  }

  @override
  String testIndex(int index) {
    return 'Test $index';
  }

  @override
  String expectedAndGot(String expected, String got) {
    return 'Expected: $expected\nGot: $got';
  }

  @override
  String get quizExplanation => 'Explanation';

  @override
  String get quizExplanationHint =>
      'Enter explanation for incorrect answers...';

  @override
  String get quizOptionExplanationHint =>
      'Explanation if incorrect (each can differ)...';

  @override
  String get ideThemeTitle => 'IDE Editor Theme';
}
