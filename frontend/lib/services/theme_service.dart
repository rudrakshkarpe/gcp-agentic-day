import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isLightMode => !_isDarkMode;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  
  ThemeService() {
    _loadThemeFromPrefs();
  }
  
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      
      switch (themeIndex) {
        case 0:
          _themeMode = ThemeMode.system;
          break;
        case 1:
          _themeMode = ThemeMode.light;
          break;
        case 2:
          _themeMode = ThemeMode.dark;
          break;
      }
      
      _updateDarkModeStatus();
      notifyListeners();
    } catch (e) {
      print('Failed to load theme preference: $e');
    }
  }
  
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int themeIndex = 0;
      
      switch (_themeMode) {
        case ThemeMode.system:
          themeIndex = 0;
          break;
        case ThemeMode.light:
          themeIndex = 1;
          break;
        case ThemeMode.dark:
          themeIndex = 2;
          break;
      }
      
      await prefs.setInt(_themeKey, themeIndex);
    } catch (e) {
      print('Failed to save theme preference: $e');
    }
  }
  
  void _updateDarkModeStatus() {
    if (_themeMode == ThemeMode.system) {
      // Get system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _isDarkMode = brightness == Brightness.dark;
    } else {
      _isDarkMode = _themeMode == ThemeMode.dark;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      _updateDarkModeStatus();
      await _saveThemeToPrefs();
      notifyListeners();
    }
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.system);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
  
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }
  
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }
  
  String getThemeName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  IconData getThemeIcon() {
    if (_themeMode == ThemeMode.system) {
      return Icons.brightness_auto;
    } else if (_isDarkMode) {
      return Icons.dark_mode;
    } else {
      return Icons.light_mode;
    }
  }
  
  // Update dark mode status when system theme changes
  void updateSystemBrightness(Brightness brightness) {
    if (_themeMode == ThemeMode.system) {
      bool newDarkMode = brightness == Brightness.dark;
      if (_isDarkMode != newDarkMode) {
        _isDarkMode = newDarkMode;
        notifyListeners();
      }
    }
  }
}
