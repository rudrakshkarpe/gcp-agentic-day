import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  String _selectedLanguage = 'en';
  
  String get selectedLanguage => _selectedLanguage;
  
  void changeLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }
  
  // Helper methods for common text
  String getText(String englishText, String kannadaText) {
    return _selectedLanguage == 'kn' ? kannadaText : englishText;
  }
}
