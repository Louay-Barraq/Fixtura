import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('es'),
    Locale('ar'),
  ];

  LocaleProvider() {
    loadSavedLocale();
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_language_code');
    if (code != null && supportedLocales.any((loc) => loc.languageCode == code)) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!supportedLocales.any((loc) => loc.languageCode == newLocale.languageCode)) return;
    _locale = newLocale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language_code', newLocale.languageCode);
  }

  String getLanguageName(Locale loc) {
    switch (loc.languageCode) {
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'ar':
        return 'العربية';
      case 'en':
      default:
        return 'English';
    }
  }

  String get currentLanguageName => getLanguageName(_locale);

  Future<void> setLanguageByName(String name) async {
    switch (name) {
      case 'Français':
        await setLocale(const Locale('fr'));
        break;
      case 'Español':
        await setLocale(const Locale('es'));
        break;
      case 'العربية':
        await setLocale(const Locale('ar'));
        break;
      case 'English':
      default:
        await setLocale(const Locale('en'));
        break;
    }
  }
}
