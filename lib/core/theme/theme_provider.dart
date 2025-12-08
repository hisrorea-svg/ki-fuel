import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Provider for managing theme mode (light/dark)
class ThemeProvider extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _themeKey = 'isDarkMode';

  Box? _box;
  bool _isDarkMode = false; // Default to light mode

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Initialize the provider and load saved preference
  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
    _isDarkMode = _box?.get(_themeKey, defaultValue: false) ?? false;
    notifyListeners();
  }

  /// Toggle between light and dark mode
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _box?.put(_themeKey, _isDarkMode);
    notifyListeners();
  }

  /// Set a specific theme mode
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      _box?.put(_themeKey, _isDarkMode);
      notifyListeners();
    }
  }
}
