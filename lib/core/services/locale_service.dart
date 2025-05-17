import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'locale';
  final SharedPreferences _prefs;
  Locale _locale;

  LocaleService(this._prefs)
      : _locale = Locale(_prefs.getString(_localeKey) ?? 'en');

  Locale get locale => _locale;

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    await _prefs.setString(_localeKey, languageCode);
    notifyListeners();
  }
}
