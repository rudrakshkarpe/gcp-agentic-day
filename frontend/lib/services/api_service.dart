import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/message.dart';
import '../models/api_response.dart';

class ApiService extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Health check endpoint
  Future<bool> checkHealth() async {
    try {
      _setError(null);
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  /// Send text message to AI
  Future<ChatResponse?> sendTextMessage({
    required String userId,
    required String message,
    String language = 'kn',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/chat/text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'message': message,
          'language': language,
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        _setError('ಸರ್ವರ್ ದೋಷ: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('Text message error: $e');
      _setError('ಸಂದೇಶ ಕಳುಹಿಸುವುದರಲ್ಲಿ ದೋಷ');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Send voice message to AI (simulated for demo)
  Future<VoiceResponse?> sendVoiceMessage({
    required String userId,
    required File audioFile,
    String language = 'kn-IN',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Simulate processing delay
      await Future.delayed(Duration(seconds: 2));
      
      // Return demo response
      return VoiceResponse(
        transcript: 'ಧನ್ಯವಾದಗಳು, ನಿಮ್ಮ ಧ್ವನಿ ಸಂದೇಶವನ್ನು ಸ್ವೀಕರಿಸಲಾಗಿದೆ',
        response: 'ನಮಸ್ಕಾರ! ಕೃಷಿ ಸಂಬಂಧಿ ಯಾವುದೇ ಸಹಾಯಕ್ಕಾಗಿ ನಾನು ಇಲ್ಲಿದ್ದೇನೆ.',
        conversationId: 'demo_conversation_${DateTime.now().millisecondsSinceEpoch}',
        audioUrl: null,
      );
    } catch (e) {
      debugPrint('Voice message error: $e');
      _setError('ಧ್ವನಿ ಸಂದೇಶ ಪ್ರಕ್ರಿಯೆಯಲ್ಲಿ ದೋಷ');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Send image for disease diagnosis (simulated for demo)
  Future<ImageDiagnosisResponse?> sendImageMessage({
    required String userId,
    required File imageFile,
    String plantType = '',
    String symptomsDescription = '',
    String message = 'ಈ ಸಸ್ಯದ ಸಮಸ್ಯೆಯನ್ನು ಗುರುತಿಸಿ',
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Simulate processing delay
      await Future.delayed(Duration(seconds: 3));
      
      // Return demo response
      return ImageDiagnosisResponse(
        diagnosis: 'ಸಸ್ಯದ ಎಲೆಗಳಲ್ಲಿ ಸಣ್ಣ ಕಲೆಗಳು ಕಂಡುಬರುತ್ತಿವೆ',
        treatment: [
          'ಸಾವಯವ ಕೀಟನಾಶಕವನ್ನು ಬಳಸಿ',
          'ನೀರಿನ ಪ್ರಮಾಣವನ್ನು ಕಡಿಮೆ ಮಾಡಿ',
          'ಮಣ್ಣಿನ ಒಳಚರಾ ಸುಧಾರಿಸಿ'
        ],
        confidence: 85.0,
      );
    } catch (e) {
      debugPrint('Image message error: $e');
      _setError('ಚಿತ್ರ ವಿಶ್ಲೇಷಣೆಯಲ್ಲಿ ದೋಷ');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get conversation history (demo data)
  Future<List<Message>> getConversationHistory(String userId) async {
    try {
      _setError(null);
      
      // Return demo conversation history
      await Future.delayed(Duration(seconds: 1));
      
      return [
        Message(
          id: '1',
          content: 'ನಮಸ್ಕಾರ! ಕಿಸಾನ್ AI ಗೆ ಸ್ವಾಗತ',
          role: MessageRole.assistant,
          timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        ),
        Message(
          id: '2',
          content: 'ಧನ್ಯವಾದಗಳು',
          role: MessageRole.user,
          timestamp: DateTime.now().subtract(Duration(minutes: 3)),
        ),
      ];
    } catch (e) {
      debugPrint('Get history error: $e');
      return [];
    }
  }

  /// Get market prices (demo data)
  Future<MarketPriceResponse?> getMarketPrices({
    required String commodity,
    String location = 'Karnataka',
  }) async {
    try {
      _setError(null);
      await Future.delayed(Duration(seconds: 2));
      
      return MarketPriceResponse(
        commodity: commodity,
        currentPrice: 2500.0,
        unit: 'ಪ್ರತಿ ಕ್ವಿಂಟಲ್',
        market: location,
        trend: 'ಸ್ಥಿರ',
        recommendation: 'ಮಾರಾಟಕ್ಕೆ ಉತ್ತಮ ಸಮಯ',
        updatedAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Market prices error: $e');
      return null;
    }
  }

  /// Search government schemes (demo data)
  Future<GovernmentSchemeResponse?> searchSchemes({
    required String query,
    String farmerCategory = 'small',
  }) async {
    try {
      _setError(null);
      await Future.delayed(Duration(seconds: 1));
      
      return GovernmentSchemeResponse(
        schemeName: 'ಪ್ರಧಾನ ಮಂತ್ರಿ ಕಿಸಾನ್ ಸಮ್ಮಾನ್ ನಿಧಿ',
        description: 'ಸಣ್ಣ ಮತ್ತು ಕನಿಷ್ಠ ರೈತರಿಗೆ ವಾರ್ಷಿಕ ಆರ್ಥಿಕ ಸಹಾಯ',
        benefits: [
          'ವಾರ್ಷಿಕ ₹6000 ನೇರ ಲಾಭ ವರ್ಗಾವಣೆ',
          'ಮೂರು ಸಮಾನ ಕಂತುಗಳಲ್ಲಿ ವಿತರಣೆ',
        ],
        eligibility: [
          '2 ಹೆಕ್ಟೇರ್ ವರೆಗಿನ ಭೂಮಿ ಇರುವ ರೈತ ಕುಟುಂಬಗಳು',
        ],
        applicationProcess: [
          'ಆನ್‌ಲೈನ್ ಅರ್ಜಿ ನೀಡಿ',
          'ಅಗತ್ಯ ದಾಖಲೆಗಳನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಿ',
        ],
      );
    } catch (e) {
      debugPrint('Schemes search error: $e');
      return null;
    }
  }

  /// Update user context (demo)
  Future<bool> updateUserContext({
    required String userId,
    Map<String, dynamic>? context,
  }) async {
    try {
      _setError(null);
      await Future.delayed(Duration(milliseconds: 500));
      return true;
    } catch (e) {
      debugPrint('Update context error: $e');
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}
