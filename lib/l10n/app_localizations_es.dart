// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'BitStride';

  @override
  String get loading => 'Cargando...';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutConfirm => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get settings => 'Ajustes';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get disableMotion => 'Desactivar animaciones';

  @override
  String get disableMotionSubtitle =>
      'Reemplaza las mascotas GIF con iconos estáticos';

  @override
  String get language => 'Idioma';

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get changeName => 'Cambiar nombre';

  @override
  String get enterDisplayName => 'Ingresa un nombre para mostrar';

  @override
  String get badges => 'Insignias';

  @override
  String earnedBadges(int count) {
    return '$count obtenidas';
  }

  @override
  String get stats => 'Estadísticas';

  @override
  String get exercisesCompleted => 'Ejercicios completados';

  @override
  String get challengesSolved => 'Desafíos resueltos';

  @override
  String get currentStreak => 'Racha actual';

  @override
  String days(int count) {
    return '$count días';
  }

  @override
  String get totalXP => 'XP Total';

  @override
  String get learn => 'Aprender';

  @override
  String get practice => 'Practicar';

  @override
  String get leaderboard => 'Clasificación';

  @override
  String get profile => 'Perfil';

  @override
  String level(int lvl) {
    return 'Nivel $lvl';
  }

  @override
  String xpTotal(int xp) {
    return '$xp XP total';
  }

  @override
  String get runCode => 'Ejecutar código';

  @override
  String get submit => 'Enviar';

  @override
  String get hint => 'Pista';

  @override
  String get solution => 'Solución';

  @override
  String get correct => '¡Correcto!';

  @override
  String get incorrect => 'Incorrecto';

  @override
  String get nextLesson => 'Siguiente lección';

  @override
  String get backToLessons => 'Volver a lecciones';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difícil';

  @override
  String get problemDescription => 'Descripción del problema';

  @override
  String get providedFiles => 'Archivos proporcionados:';

  @override
  String get example => 'Ejemplo:';

  @override
  String get input => 'Entrada:';

  @override
  String get output => 'Salida:';

  @override
  String get submitCode => 'Enviar código';

  @override
  String get running => 'Ejecutando...';

  @override
  String get allLevels => 'Todos los niveles';

  @override
  String get noChallenges => 'Ningún desafío coincide con tus filtros';

  @override
  String get noCourses => 'Aún no hay cursos disponibles';

  @override
  String get lesson => 'Lección';

  @override
  String get learnTab => 'Aprender';

  @override
  String get practiceTab => 'Practicar';

  @override
  String get dayStreak => '¡Racha de días!';

  @override
  String get keepPracticing => 'Sigue practicando para mantener tu racha';

  @override
  String get current => 'Actual';

  @override
  String get xpLabel => 'XP';

  @override
  String get done => 'Hecho';

  @override
  String get keepLearning => 'Sigue aprendiendo';

  @override
  String get searchChallenges => 'Buscar desafíos...';

  @override
  String get category => 'Categoría';

  @override
  String get method => 'Método';

  @override
  String get allCategories => 'Todas';

  @override
  String get allMethods => 'Todos';

  @override
  String get markAsRead => 'Marcar como leído';

  @override
  String get lessonCompleted => '¡Lección marcada como completada!';

  @override
  String get theoryOnly => 'Lección teórica';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get resetPasswordTitle => 'Restablecer contraseña';

  @override
  String get resetPasswordDesc =>
      'Ingresa tu correo electrónico para recibir un enlace de restablecimiento';

  @override
  String get sendResetLink => 'Enviar enlace de restablecimiento';

  @override
  String get resetEmailSent => '¡Correo de restablecimiento enviado!';

  @override
  String get theoryBadge => 'Teoría';

  @override
  String get codeBadge => 'Código';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String resultsFound(int count) {
    return '$count resultados encontrados';
  }

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get noAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get haveAccount => '¿Ya tienes una cuenta? Iniciar sesión';

  @override
  String get visualizeTab => 'Visualizar';

  @override
  String get applyFilters => 'Aplicar Filtros';

  @override
  String get quizQuestion => 'Pregunta del Cuestionario';

  @override
  String get multipleChoice => 'Opción Múltiple';

  @override
  String get perfectScore => '¡Puntuación perfecta!';

  @override
  String get lessonFinished => '¡Lección completada!';

  @override
  String get theoryRead => 'Teoría leída';

  @override
  String get quizScore => 'Puntuación del cuestionario';

  @override
  String get codeTests => 'Pruebas de código';

  @override
  String get totalXpScore => 'Puntuación total de XP';

  @override
  String gainedXp(int count) {
    return '¡Ganaste +$count XP!';
  }

  @override
  String get answerAllQuizzes => 'Responde todas las preguntas para terminar';

  @override
  String get runCodeOnce => 'Ejecuta el código al menos una vez para terminar';

  @override
  String get finishLesson => 'Terminar lección';

  @override
  String get continueBtn => 'Continuar';

  @override
  String get redoNoXp => 'Repetir - No se otorgan nuevos XP';

  @override
  String get mixedBadge => 'Mixto';

  @override
  String testsPassed(int passed, int total, int percentage) {
    return '$passed / $total pruebas superadas ($percentage%)';
  }

  @override
  String testHidden(int index) {
    return 'Prueba $index (oculta)';
  }

  @override
  String testIndex(int index) {
    return 'Prueba $index';
  }

  @override
  String expectedAndGot(String expected, String got) {
    return 'Esperado: $expected\nObtenido: $got';
  }

  @override
  String get quizExplanation => 'Explicación';

  @override
  String get quizExplanationHint =>
      'Introduce la explicación para las respuestas incorrectas...';

  @override
  String get quizOptionExplanationHint =>
      'Explicación si es incorrecta (cada una puede diferir)...';

  @override
  String get ideThemeTitle => 'Tema del editor IDE';
}
