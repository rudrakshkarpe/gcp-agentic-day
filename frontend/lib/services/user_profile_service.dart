import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static const String _nameKey = 'user_name';
  static const String _cityKey = 'user_city';
  static const String _stateKey = 'user_state';
  static const String _countryKey = 'user_country';
  static const String _languageKey = 'user_preferred_language';

  // Get user profile data with defaults
  static Future<Map<String, String?>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'name': prefs.getString(_nameKey),
      'city': prefs.getString(_cityKey) ?? 'Bangalore',
      'state': prefs.getString(_stateKey),
      'country': prefs.getString(_countryKey),
      'preferred_language': prefs.getString(_languageKey) ?? 'en',
    };
  }

  // Save user profile data
  static Future<void> saveUserProfile({
    String? name,
    String? city,
    String? state,
    String? country,
    String? preferredLanguage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (name != null) await prefs.setString(_nameKey, name);
    if (city != null) await prefs.setString(_cityKey, city);
    if (state != null) await prefs.setString(_stateKey, state);
    if (country != null) await prefs.setString(_countryKey, country);
    if (preferredLanguage != null) await prefs.setString(_languageKey, preferredLanguage);
  }

  // Clear user profile data
  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_cityKey);
    await prefs.remove(_stateKey);
    await prefs.remove(_countryKey);
    await prefs.remove(_languageKey);
  }

  // Get individual profile fields
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  static Future<String> getUserCity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cityKey) ?? 'Bangalore';
  }

  static Future<String?> getUserState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_stateKey);
  }

  static Future<String?> getUserCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_countryKey);
  }

  static Future<String> getPreferredLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }
}
