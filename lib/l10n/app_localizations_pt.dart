// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'BitStride';

  @override
  String get loading => 'Carregando...';

  @override
  String get login => 'Entrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutConfirm => 'Tem certeza que deseja sair?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get settings => 'Configurações';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get disableMotion => 'Desativar Animações';

  @override
  String get disableMotionSubtitle =>
      'Substitui mascotes GIF por ícones estáticos';

  @override
  String get language => 'Idioma';

  @override
  String get displayName => 'Nome de Exibição';

  @override
  String get changeName => 'Alterar Nome';

  @override
  String get enterDisplayName => 'Digite o nome de exibição';

  @override
  String get badges => 'Emblemas';

  @override
  String earnedBadges(int count) {
    return '$count obtidos';
  }

  @override
  String get stats => 'Estatísticas';

  @override
  String get exercisesCompleted => 'Exercícios concluídos';

  @override
  String get challengesSolved => 'Desafios resolvidos';

  @override
  String get currentStreak => 'Sequência atual';

  @override
  String days(int count) {
    return '$count dias';
  }

  @override
  String get totalXP => 'XP Total';

  @override
  String get learn => 'Aprender';

  @override
  String get practice => 'Praticar';

  @override
  String get leaderboard => 'Classificação';

  @override
  String get profile => 'Perfil';

  @override
  String level(int lvl) {
    return 'Nível $lvl';
  }

  @override
  String xpTotal(int xp) {
    return '$xp XP total';
  }

  @override
  String get runCode => 'Executar Código';

  @override
  String get submit => 'Enviar';

  @override
  String get hint => 'Dica';

  @override
  String get solution => 'Solução';

  @override
  String get correct => 'Correto!';

  @override
  String get incorrect => 'Incorreto';

  @override
  String get nextLesson => 'Próxima Lição';

  @override
  String get backToLessons => 'Voltar às Lições';

  @override
  String get difficulty => 'Dificuldade';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Médio';

  @override
  String get hard => 'Difícil';

  @override
  String get problemDescription => 'Descrição do Problema';

  @override
  String get providedFiles => 'Arquivos Fornecidos:';

  @override
  String get example => 'Exemplo:';

  @override
  String get input => 'Entrada:';

  @override
  String get output => 'Saída:';

  @override
  String get submitCode => 'Enviar Código';

  @override
  String get running => 'Executando...';

  @override
  String get allLevels => 'Todos os Níveis';

  @override
  String get noChallenges => 'Nenhum desafio corresponde aos seus filtros';

  @override
  String get noCourses => 'Nenhum curso disponível ainda';

  @override
  String get lesson => 'Lição';

  @override
  String get learnTab => 'Aprender';

  @override
  String get practiceTab => 'Praticar';

  @override
  String get dayStreak => 'Dias Seguidos!';

  @override
  String get keepPracticing => 'Continue praticando para manter sua sequência';

  @override
  String get current => 'Atual';

  @override
  String get xpLabel => 'XP';

  @override
  String get done => 'Concluído';

  @override
  String get keepLearning => 'Continue Aprendendo';

  @override
  String get searchChallenges => 'Buscar desafios...';

  @override
  String get category => 'Categoria';

  @override
  String get method => 'Método';

  @override
  String get allCategories => 'Todas';

  @override
  String get allMethods => 'Todos';

  @override
  String get markAsRead => 'Marcar como Lido';

  @override
  String get lessonCompleted => 'Lição marcada como concluída!';

  @override
  String get theoryOnly => 'Lição Teórica';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get resetPasswordTitle => 'Redefinir Senha';

  @override
  String get resetPasswordDesc =>
      'Digite seu e-mail para receber um link de redefinição';

  @override
  String get sendResetLink => 'Enviar Link de Redefinição';

  @override
  String get resetEmailSent => 'E-mail de redefinição enviado!';

  @override
  String get theoryBadge => 'Teoria';

  @override
  String get codeBadge => 'Código';

  @override
  String get clearFilters => 'Limpar Filtros';

  @override
  String resultsFound(int count) {
    return '$count resultados encontrados';
  }

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Inscrever-se';

  @override
  String get noAccount => 'Não tem uma conta? Inscreva-se';

  @override
  String get haveAccount => 'Já tem uma conta? Entrar';

  @override
  String get visualizeTab => 'Visualizar';

  @override
  String get applyFilters => 'Aplicar Filtros';

  @override
  String get quizQuestion => 'Pergunta do Quiz';

  @override
  String get multipleChoice => 'Múltipla Escolha';

  @override
  String get perfectScore => 'Pontuação perfeita!';

  @override
  String get lessonFinished => 'Lição concluída!';

  @override
  String get theoryRead => 'Teoria lida';

  @override
  String get quizScore => 'Pontuação do quiz';

  @override
  String get codeTests => 'Testes de código';

  @override
  String get totalXpScore => 'Pontuação total de XP';

  @override
  String gainedXp(int count) {
    return 'Você ganhou +$count XP!';
  }

  @override
  String get answerAllQuizzes => 'Responda a todos os quizzes para terminar';

  @override
  String get runCodeOnce => 'Execute o código pelo menos uma vez para terminar';

  @override
  String get finishLesson => 'Terminar lição';

  @override
  String get continueBtn => 'Continuar';

  @override
  String get redoNoXp => 'Refazer - Nenhum XP novo concedido';

  @override
  String get mixedBadge => 'Misto';

  @override
  String testsPassed(int passed, int total, int percentage) {
    return '$passed / $total testes aprovados ($percentage%)';
  }

  @override
  String testHidden(int index) {
    return 'Teste $index (oculto)';
  }

  @override
  String testIndex(int index) {
    return 'Teste $index';
  }

  @override
  String expectedAndGot(String expected, String got) {
    return 'Esperado: $expected\nObtido: $got';
  }

  @override
  String get quizExplanation => 'Explicação';

  @override
  String get quizExplanationHint =>
      'Insira a explicação para respostas incorretas...';

  @override
  String get quizOptionExplanationHint =>
      'Explicação se incorreta (cada uma pode diferir)...';

  @override
  String get ideThemeTitle => 'Tema do editor IDE';
}
