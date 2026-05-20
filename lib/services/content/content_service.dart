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

  Course _mergeCourseTranslation(Course c, Map<String, dynamic> transJson) {
    final title = transJson['title'] ?? c.title;
    final lessonsJson = transJson['lessons'] as List?;

    final Map<String, Map<String, dynamic>> lessonTransMap = {};
    if (lessonsJson != null) {
      for (final l in lessonsJson) {
        if (l is Map) {
          final id = l['id'] ?? '';
          lessonTransMap[id] = Map<String, dynamic>.from(l);
        }
      }
    }

    final mergedLessons = c.lessons.map((lesson) {
      final tData = lessonTransMap[lesson.id];
      if (tData == null) return lesson;

      final lTitle = tData['title'] ?? lesson.title;
      final lDesc = tData['description'] ?? lesson.description;

      final blocksJson = tData['content_blocks'] as List?;
      List<ContentBlock>? mergedBlocks;
      if (blocksJson != null) {
        mergedBlocks = [];
        for (int i = 0; i < lesson.contentBlocks.length; i++) {
          final originalBlock = lesson.contentBlocks[i];
          if (i < blocksJson.length) {
            final tBlockJson = blocksJson[i];
            // Merge localized content blocks including headings and quizzes.
            if (tBlockJson is Map &&
                (originalBlock.type == 'text' ||
                    originalBlock.type == 'heading' ||
                    originalBlock.type == 'quiz')) {
              mergedBlocks.add(ContentBlock(
                type: originalBlock.type,
                content: tBlockJson['content'] ?? originalBlock.content,
              ));
            } else {
              mergedBlocks.add(originalBlock);
            }
          } else {
            mergedBlocks.add(originalBlock);
          }
        }
      }

      return lesson.copyWith(
        title: lTitle,
        description: lDesc,
        contentBlocks: mergedBlocks,
      );
    }).toList();

    return c.copyWith(title: title, lessons: mergedLessons);
  }

  Future<List<Challenge>> translateChallenges(
      List<Challenge> challenges, String lang) async {
    if (lang == 'en') return challenges;
    return Future.wait(
      challenges.map((c) async {
        final t = await _trans.translateText(c.title, lang);
        final d = await _trans.translateText(c.description, lang);
        return c.copyWith(title: t, description: d);
      }),
    );
  }

  Future<List<Course>> loadAllCourses(String lang) async {
    try {
      final courses = await _firestore.loadCourses();
      if (courses.isNotEmpty) {
        if (lang == 'en') return courses;
        return Future.wait(courses.map((c) => _translateCourse(c, lang)));
      }
    } catch (_) {}
    try {
      final courses = await Future.wait([
        _loadCourseFromAsset('assets/content/cpp_basics_course.json'),
        _loadCourseFromAsset('assets/content/python_basics_course.json'),
      ]);
      if (lang == 'en') return courses;
      return Future.wait(courses.map((c) => _translateCourse(c, lang)));
    } catch (_) {
      return [];
    }
  }

  Future<List<Challenge>> loadAllChallenges(String lang) async {
    try {
      final challenges = await _firestore.loadAllChallenges();
      if (challenges.isNotEmpty) {
        return lang == 'en'
            ? challenges
            : await translateChallenges(challenges, lang);
      }
    } catch (_) {}
    try {
      final challenges = await _loadChallengesFromAsset(
          'assets/content/practice_challenges.json');
      return lang == 'en'
          ? challenges
          : await translateChallenges(challenges, lang);
    } catch (_) {
      return [];
    }
  }
}
