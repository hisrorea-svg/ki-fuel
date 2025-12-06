import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// مزود إدارة اللغة
class LocaleProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _localeKey = 'locale';

  Locale _locale = const Locale('ar');
  Box? _box;

  Locale get locale => _locale;

  /// تهيئة المزود وتحميل اللغة المحفوظة
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    final savedLocale = _box?.get(_localeKey, defaultValue: 'ar') as String;
    _locale = Locale(savedLocale);
    notifyListeners();
  }

  /// تغيير اللغة
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    await _box?.put(_localeKey, locale.languageCode);
    notifyListeners();
  }

  /// التبديل بين العربية والإنجليزية
  Future<void> toggleLocale() async {
    final newLocale = _locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await setLocale(newLocale);
  }

  /// هل اللغة الحالية عربية؟
  bool get isArabic => _locale.languageCode == 'ar';
}
