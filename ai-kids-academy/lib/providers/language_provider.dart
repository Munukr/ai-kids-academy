import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';
import '../services/lesson_service.dart';

const _kLanguageKey = 'selected_language';
const _kLanguageChosenKey = 'language_chosen';

class LanguageProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  AppLanguage _language;
  bool _languageChosen;

  LanguageProvider(this._prefs)
      : _language = _resolveLanguage(_prefs.getString(_kLanguageKey)),
        _languageChosen = _prefs.getBool(_kLanguageChosenKey) ?? false;

  AppLanguage get language => _language;

  Locale get locale {
    switch (_language) {
      case AppLanguage.ru:
        return const Locale('ru');
      case AppLanguage.he:
        return const Locale('he');
      case AppLanguage.en:
        return const Locale('en');
    }
  }

  bool get isRtl => _language == AppLanguage.he;

  bool get languageChosen => _languageChosen;

  String get mascotName => AppStrings.mascotName(_language);

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language && _languageChosen) return;
    _language = language;
    _languageChosen = true;
    LessonService.clearCache();
    await _prefs.setString(_kLanguageKey, language.name);
    await _prefs.setBool(_kLanguageChosenKey, true);
    notifyListeners();
  }

  static AppLanguage _resolveLanguage(String? code) {
    switch (code) {
      case 'ru':
        return AppLanguage.ru;
      case 'he':
        return AppLanguage.he;
      case 'en':
        return AppLanguage.en;
      default:
        return AppLanguage.en;
    }
  }
}
