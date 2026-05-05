// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'BitStride';

  @override
  String get loading => 'Chargement...';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get settings => 'Paramètres';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get disableMotion => 'Désactiver les animations';

  @override
  String get disableMotionSubtitle =>
      'Remplace les mascottes GIF par des icônes statiques';

  @override
  String get language => 'Langue';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get changeName => 'Changer le nom';

  @override
  String get enterDisplayName => 'Entrez le nom d\'affichage';

  @override
  String get badges => 'Badges';

  @override
  String earnedBadges(int count) {
    return '$count obtenus';
  }

  @override
  String get stats => 'Statistiques';

  @override
  String get exercisesCompleted => 'Exercices terminés';

  @override
  String get challengesSolved => 'Défis résolus';

  @override
  String get currentStreak => 'Série actuelle';

  @override
  String days(int count) {
    return '$count jours';
  }

  @override
  String get totalXP => 'XP Total';

  @override
  String get learn => 'Apprendre';

  @override
  String get practice => 'Pratiquer';

  @override
  String get leaderboard => 'Classement';

  @override
  String get profile => 'Profil';

  @override
  String level(int lvl) {
    return 'Niveau $lvl';
  }

  @override
  String xpTotal(int xp) {
    return '$xp XP total';
  }

  @override
  String get runCode => 'Exécuter le code';

  @override
  String get submit => 'Soumettre';

  @override
  String get hint => 'Indice';

  @override
  String get solution => 'Solution';

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get nextLesson => 'Leçon Suivante';

  @override
  String get backToLessons => 'Retour aux leçons';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get problemDescription => 'Description du problème';

  @override
  String get providedFiles => 'Fichiers Fournis :';

  @override
  String get example => 'Exemple :';

  @override
  String get input => 'Entrée :';

  @override
  String get output => 'Sortie :';

  @override
  String get submitCode => 'Soumettre le code';

  @override
  String get running => 'Exécution...';

  @override
  String get allLevels => 'Tous les niveaux';

  @override
  String get noChallenges => 'Aucun défi ne correspond à vos filtres';

  @override
  String get noCourses => 'Aucun cours disponible pour le moment';

  @override
  String get lesson => 'Leçon';

  @override
  String get learnTab => 'Apprendre';

  @override
  String get practiceTab => 'Pratiquer';

  @override
  String get dayStreak => 'Jours consécutifs!';

  @override
  String get keepPracticing =>
      'Continuez à pratiquer pour maintenir votre série';

  @override
  String get current => 'Actuel';

  @override
  String get xpLabel => 'XP';

  @override
  String get done => 'Terminé';

  @override
  String get keepLearning => 'Continuer à Apprendre';

  @override
  String get searchChallenges => 'Rechercher des défis...';

  @override
  String get category => 'Catégorie';

  @override
  String get method => 'Méthode';

  @override
  String get allCategories => 'Toutes';

  @override
  String get allMethods => 'Toutes';

  @override
  String get markAsRead => 'Marquer comme lu';

  @override
  String get lessonCompleted => 'Leçon marquée comme terminée!';

  @override
  String get theoryOnly => 'Leçon théorique';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordDesc =>
      'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get resetEmailSent => 'E-mail de réinitialisation envoyé!';

  @override
  String get theoryBadge => 'Théorie';

  @override
  String get codeBadge => 'Code';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String resultsFound(int count) {
    return '$count résultats trouvés';
  }

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get noAccount => 'Pas de compte? S\'inscrire';

  @override
  String get haveAccount => 'Vous avez déjà un compte? Se connecter';

  @override
  String get visualizeTab => 'Visualiser';

  @override
  String get applyFilters => 'Appliquer les filtres';

  @override
  String get quizQuestion => 'Question du Quiz';

  @override
  String get multipleChoice => 'Choix Multiple';

  @override
  String get perfectScore => 'Score parfait !';

  @override
  String get lessonFinished => 'Leçon terminée !';

  @override
  String get theoryRead => 'Théorie lue';

  @override
  String get quizScore => 'Score du quiz';

  @override
  String get codeTests => 'Tests de code';

  @override
  String get totalXpScore => 'Score total de XP';

  @override
  String gainedXp(int count) {
    return 'Vous avez gagné +$count XP !';
  }

  @override
  String get answerAllQuizzes => 'Répondez à tous les quiz pour terminer';

  @override
  String get runCodeOnce => 'Exécutez le code au moins une fois pour terminer';

  @override
  String get finishLesson => 'Terminer la leçon';

  @override
  String get continueBtn => 'Continuer';

  @override
  String get redoNoXp => 'Refaire - Pas de nouveaux XP attribués';

  @override
  String get mixedBadge => 'Mixte';

  @override
  String testsPassed(int passed, int total, int percentage) {
    return '$passed / $total tests réussis ($percentage%)';
  }

  @override
  String testHidden(int index) {
    return 'Test $index (masqué)';
  }

  @override
  String testIndex(int index) {
    return 'Test $index';
  }

  @override
  String expectedAndGot(String expected, String got) {
    return 'Attendu: $expected\nObtenu: $got';
  }

  @override
  String get quizExplanation => 'Explication';

  @override
  String get quizExplanationHint =>
      'Entrez l\'explication pour les mauvaises réponses...';

  @override
  String get quizOptionExplanationHint =>
      'Explication si incorrecte (chaque peut différer)...';

  @override
  String get ideThemeTitle => 'Thème de l\'éditeur IDE';
}
