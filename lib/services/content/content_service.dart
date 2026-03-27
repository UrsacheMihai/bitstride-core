import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/exercise/exercise.dart';
import '../translation/translation_service.dart';
import '../db/firestore_service.dart';

// Handle data operations and service integration for the Content Service.
class ContentService {
  final TranslationService _trans = TranslationService();
  final FirestoreService _firestore = FirestoreService();

  Future<Course> _loadCourseFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw);
    return Course.fromJson(json);
  }

  Future<List<Challenge>> _loadChallengesFromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw);
    return (json['challenges'] as List?)
            ?.map((c) => Challenge.fromJson(c))
            .toList() ??
        [];
  }

  Future<Course> _translateCourse(Course c, String lang) async {
    if (c.id.isNotEmpty) {
      final translationJson = await _firestore.getCourseTranslation(c.id, lang);
      if (translationJson != null) {
        return _mergeCourseTranslation(c, translationJson);
      }
    }

    final translatedTitle = await _trans.translateText(c.title, lang);
    final translatedLessons = await Future.wait(
      c.lessons.map((l) async {
        final t = await _trans.translateText(l.title, lang);
        final d = await _trans.translateText(l.description, lang);
        final tBlocks = await Future.wait(
          l.contentBlocks.map((block) async {
            // Translate fallback content blocks dynamically.
            if (block.type == 'text' || block.type == 'heading') {
              final tc = await _trans.translateText(block.content, lang);
              return ContentBlock(type: block.type, content: tc);
            }
            if (block.type == 'quiz') {
              try {
                final Map<String, dynamic> quizData = jsonDecode(block.content);
                final String question = quizData['question']?.toString() ?? '';
                final List<dynamic> options = quizData['options'] as List<dynamic>? ?? [];
                final tQuestion = await _trans.translateText(question, lang);
                final List<String> tOptions = [];
                for (final opt in options) {
                  final tOpt = await _trans.translateText(opt.toString(), lang);
                  tOptions.add(tOpt);
                }
                final newQuizData = {
                  'question': tQuestion,
                  'options': tOptions,
                  'correctIndex': quizData['correctIndex'] ?? 0,
                };
                return ContentBlock(type: 'quiz', content: jsonEncode(newQuizData));
              } catch (_) {}
            }
            return block;
          }),
        );
        return l.copyWith(title: t, description: d, contentBlocks: tBlocks);
      }),
    );
    return c.copyWith(title: translatedTitle, lessons: translatedLessons);
  }
}