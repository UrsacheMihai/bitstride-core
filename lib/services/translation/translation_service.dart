// Translate text strings for multilingual support.

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

// Handle data operations and service integration for the Translation Service.
class TranslationService {
  final GoogleTranslator _translator = GoogleTranslator();
  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String> translateText(String text, String targetLang) async {
    if (targetLang == 'en' || text.trim().isEmpty) return text;
    await _initPrefs();
    final cacheKey = 'trans_${targetLang}_${text.hashCode}';
    final cached = _prefs!.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) return cached;
    String result = text;
    try {
      if (kIsWeb) {
        result = await _translateViaProxy(text, targetLang);
      } else {
        final translation = await _translator.translate(text, to: targetLang);
        result = translation.text;
      }
    } catch (_) {
      return text;
    }
    if (result.isNotEmpty) {
      await _prefs!.setString(cacheKey, result);
    }
    return result;
  }

  Future<String> _translateViaProxy(String text, String targetLang) async {
    final langMap = {
      'ro': 'ro-RO',
      'fr': 'fr-FR',
      'es': 'es-ES',
      'pt': 'pt-PT',
    };
    final langCode = langMap[targetLang] ?? targetLang;
    final url = Uri.parse(
      'https://api.mymemory.translated.net/get'
      '?q=${Uri.encodeComponent(text)}&langpair=en|$langCode',
    );
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final translated = json['responseData']?['translatedText'] as String?;
      if (translated != null && translated.isNotEmpty) return translated;
    }
    return text;
  }
}
