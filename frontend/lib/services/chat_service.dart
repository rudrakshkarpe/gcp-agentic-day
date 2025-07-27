import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:8084'; // Updated to match backend_v1 port
  static const bool useMockData = true; // Set to false to use real API
  String? _sessionId;
  
  // Generate session ID once per chat session
  String get sessionId => _sessionId ??= const Uuid().v4();
  
  // Reset session ID (called when starting a new chat session)
  void resetSession() {
    _sessionId = null;
  }

  // Mock responses for testing
  static const String mockAudioBase64 = ""; // Empty for now, can add actual base64 audio data if needed
  
  static final List<String> mockTextResponses = [
    "ನಮಸ್ಕಾರ! ನಾನು ಕಿಸಾನ್ ಏಐ ಸಹಾಯಕ. ನಿಮ್ಮ ಕೃಷಿ ಸಂಬಂಧಿ ಪ್ರಶ್ನೆಗಳಿಗೆ ಉತ್ತರಿಸಲು ನಾನು ಇಲ್ಲಿದ್ದೇನೆ.",
    "ಈ ಋತುವಿನಲ್ಲಿ ಟೊಮೇಟೊ ಬೆಳೆಗೆ ನೀರಾವರಿ ದಿನಕ್ಕೆ ಎರಡು ಬಾರಿ ಮಾಡಿ. ಮಣ್ಣಿನ ತೇವಾಂಶ ಪರೀಕ್ಷಿಸಿ.",
    "ಬೆಂಗಳೂರಿನಲ್ಲಿ ಇಂದು ಮಳೆಯ ಸಾಧ್ಯತೆ ಇದೆ. ಕೃಷಿ ಕೆಲಸಗಳನ್ನು ಅದಕ್ಕೆ ತಕ್ಕಂತೆ ಯೋಜಿಸಿ.",
    "ಧಾನ್ಯ ಬೆಲೆಗಳು ಈ ವಾರ ಸ್ಥಿರವಾಗಿವೆ. ಮಾರುಕಟ್ಟೆಯಲ್ಲಿ ಉತ್ತಮ ಬೇಡಿಕೆ ಇದೆ.",
    "ಎಲೆಗಳ ಮೇಲೆ ಕಂದು ಬಣ್ಣದ ಚುಕ್ಕೆಗಳು ಕಾಣಿಸಿದರೆ ಅದು ಶಿಲೀಂಧ್ರ ಸೋಂಕು. ಸಾವಯವ ಔಷಧಿ ಬಳಸಿ.",
  ];

  static final List<String> mockImageResponses = [
    "ಈ ಸಸ್ಯದಲ್ಲಿ ಎಲೆ ಕಲೆ ರೋಗ (Leaf Spot Disease) ಕಾಣಿಸುತ್ತಿದೆ. ಚಿಕಿತ್ಸೆ: ನೀಮ್ ಎಣ್ಣೆ ಸಿಂಪಡಿಸಿ ಮತ್ತು ಬಾಧಿತ ಎಲೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ.",
    "ಟೊಮೇಟೊ ಬ್ಲೈಟ್ ರೋಗದ ಲಕ್ಷಣಗಳು ಕಾಣಿಸುತ್ತಿವೆ. ತಕ್ಷಣ ಕಾಪರ್ ಸಲ್ಫೇಟ್ ದ್ರಾವಣ ಸಿಂಪಡಿಸಿ.",
    "ಸಸ್ಯದ ಬೆಳವಣಿಗೆ ಚೆನ್ನಾಗಿದೆ. ಆದರೆ ಹೆಚ್ಚು ಸಾರಜನಕ ಗೊಬ್ಬರ ಬೇಕಾಗಿದೆ. ಉರಿಯಾ ದ್ರಾವಣ ಚಿಮುಕಿಸಿ.",
    "ಬಿಸಿಲಿನ ಸುಟ್ಟಗೆ (Sun Scorch) ಕಾರಣ ಎಲೆಗಳು ಒಣಗಿವೆ. ನೆರಳು ಜಾಲಿ ಹಾಕಿ ಸಸ್ಯಗಳನ್ನು ರಕ್ಷಿಸಿ.",
    "ಕೀಟಗಳ ಆಕ್ರಮಣ ಕಾಣಿಸುತ್ತಿದೆ. ಸಾವಯವ ಕೀಟನಾಶಕ ಅಥವಾ ಬೇವಿನ ಎಣ್ಣೆ ಬಳಸಿ.",
  ];

  String _getRandomMockResponse(List<String> responses) {
    final random = DateTime.now().millisecondsSinceEpoch % responses.length;
    return responses[random];
  }

  Future<ChatResponse> sendTextMessage({
    required String message,
    required String userId,
    required String language,
    String? userName,
    String? userCity,
    String? userState,
    String? userCountry,
  }) async {
    // Return mock response if enabled
    if (useMockData) {
      print('Using mock response for text message: $message');
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      return ChatResponse(
        textResponse: _getRandomMockResponse(mockTextResponses),
        audioResponseBase64: mockAudioBase64.isEmpty ? null : mockAudioBase64,
        toolsUsed: ['weather_agent', 'plant_health_support'],
        conversationId: sessionId,
        confidence: 0.95,
      );
    }

    try {
      final url = Uri.parse('$baseUrl/api/chat_endpoint');
      
      // Create JSON payload matching KisanChatSchema
      final requestBody = {
        'text': message,
        'audio_file': null,
        'image': null,
        'name': userName ?? '',
        'city': userCity ?? 'Bangalore',
        'state': userState ?? '',
        'country': userCountry ?? '',
        'preferred_language': language,
      };
      
      print('Sending text message payload: ${jsonEncode(requestBody)}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw ChatException(
          'Failed to send message: ${response.statusCode}',
          response.body,
        );
      }
    } on SocketException {
      throw ChatException(
        'Network error',
        'Please check your internet connection',
      );
    } catch (e) {
      throw ChatException(
        'Unexpected error',
        e.toString(),
      );
    }
  }

  Future<VoiceChatResponse> sendVoiceMessage({
    required File audioFile,
    required String userId,
    required String language,
    String? userName,
    String? userCity,
    String? userState,
    String? userCountry,
  }) async {
    // Return mock response if enabled
    if (useMockData) {
      print('Using mock response for voice message');
      await Future.delayed(const Duration(milliseconds: 1200)); // Simulate network delay
      
      return VoiceChatResponse(
        transcript: "ನನ್ನ ಬೆಳೆಗೆ ಏನು ಮಾಡಬೇಕು?", // Mock transcript
        textResponse: _getRandomMockResponse(mockTextResponses),
        audioResponseBase64: mockAudioBase64.isEmpty ? null : mockAudioBase64,
        toolsUsed: ['speech_to_text', 'plant_health_support'],
        conversationId: sessionId,
        confidence: 0.92,
      );
    }

    try {
      final url = Uri.parse('$baseUrl/api/chat_endpoint');
      
      // Read audio file and encode as base64
      final audioBytes = await audioFile.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);
      
      // Create JSON payload matching KisanChatSchema
      final requestBody = {
        'text': '', // Empty string for voice-only messages since text is required
        'audio_file': audioBase64,
        'image': null,
        'name': userName ?? '',
        'city': userCity ?? 'Bangalore',
        'state': userState ?? '',
        'country': userCountry ?? '',
        'preferred_language': language,
      };
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return VoiceChatResponse.fromJson(data);
      } else {
        throw ChatException(
          'Failed to send voice message: ${response.statusCode}',
          response.body,
        );
      }
    } on SocketException {
      throw ChatException(
        'Network error',
        'Please check your internet connection',
      );
    } catch (e) {
      throw ChatException(
        'Unexpected error',
        e.toString(),
      );
    }
  }

  Future<ImageChatResponse> sendImageMessage({
    required File imageFile,
    required String userId,
    required String message,
    String plantType = '',
    String symptomsDescription = '',
    String? userName,
    String? userCity,
    String? userState,
    String? userCountry,
    String language = 'en',
  }) async {
    // Return mock response if enabled
    if (useMockData) {
      print('Using mock response for image message: $message');
      await Future.delayed(const Duration(milliseconds: 1000)); // Simulate network delay
      
      final mockResponse = _getRandomMockResponse(mockImageResponses);
      return ImageChatResponse(
        diagnosis: mockResponse,
        diseaseName: "Leaf Spot Disease",
        severity: "Moderate",
        treatment: [
          "ನೀಮ್ ಎಣ್ಣೆ ಸಿಂಪಡಿಸಿ",
          "ಬಾಧಿತ ಎಲೆಗಳನ್ನು ತೆಗೆದುಹಾಕಿ",
          "ಮಣ್ಣಿನ ಒಳ್ಳೆಯ ನಿರ್ವಹಣೆ ಮಾಡಿ"
        ],
        organicRemedies: [
          "ಬೇವಿನ ಎಣ್ಣೆ",
          "ಮೆಂತೆ ದ್ರಾವಣ",
          "ಜೇನುತುಪ್ಪ ಮಿಶ್ರಣ"
        ],
        chemicalTreatment: [
          "ಕಾಪರ್ ಸಲ್ಫೇಟ್",
          "ಮ್ಯಾಂಕೋಜೆಬ್ ಸಿಂಪಡಿಸಿ"
        ],
        prevention: [
          "ನಿಯಮಿತ ಪರಿಶೀಲನೆ",
          "ಸರಿಯಾದ ಅಂತರ ಇರಿಸಿ",
          "ನೀರಾವರಿ ನಿಯಂತ್ರಣ"
        ],
        confidence: 0.88,
        audioResponseBase64: mockAudioBase64.isEmpty ? null : mockAudioBase64,
      );
    }

    try {
      final url = Uri.parse('$baseUrl/api/chat_endpoint');
      
      // Read image file and encode as base64
      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);
      
      // Create JSON payload matching KisanChatSchema
      final requestBody = {
        'text': message,
        'audio_file': null, // Fixed: null instead of empty string
        'image': imageBase64, // Fixed: actual base64 image data
        'name': userName ?? '',
        'city': userCity ?? 'Bangalore',
        'state': userState ?? '',
        'country': userCountry ?? '',
        'preferred_language': language, // Fixed: use the language parameter
      };
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ImageChatResponse.fromJson(data);
      } else {
        throw ChatException(
          'Failed to analyze image: ${response.statusCode}',
          response.body,
        );
      }
    } on SocketException {
      throw ChatException(
        'Network error',
        'Please check your internet connection',
      );
    } catch (e) {
      throw ChatException(
        'Failed to analyze image',
        e.toString(),
      );
    }
  }

  Future<List<Message>> getChatHistory(String userId) async {
    // Since backend doesn't provide chat history endpoint,
    // we'll implement local storage in a future update
    // For now, return empty list
    try {
      // TODO: Implement local storage for chat history
      // This could use SharedPreferences or SQLite
      print('Chat history not available - backend does not support this feature yet');
      return [];
    } catch (e) {
      print('Failed to load chat history: $e');
      return [];
    }
  }
}

// Response models for different types of chat interactions
class ChatResponse {
  final String textResponse;
  final String? audioResponseBase64;
  final List<String> toolsUsed;
  final String? conversationId;
  final double? confidence;

  ChatResponse({
    required this.textResponse,
    this.audioResponseBase64,
    this.toolsUsed = const [],
    this.conversationId,
    this.confidence,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      textResponse: json['text_response'] ?? '',
      audioResponseBase64: json['audio_response_base64'],
      toolsUsed: const [], // Backend doesn't provide this yet
      conversationId: null, // Backend doesn't provide this yet
      confidence: null, // Backend doesn't provide this yet
    );
  }
}

class VoiceChatResponse {
  final String transcript;
  final String textResponse;
  final String? audioResponseBase64;
  final List<String> toolsUsed;
  final String? conversationId;
  final double? confidence;

  VoiceChatResponse({
    required this.transcript,
    required this.textResponse,
    this.audioResponseBase64,
    this.toolsUsed = const [],
    this.conversationId,
    this.confidence,
  });

  factory VoiceChatResponse.fromJson(Map<String, dynamic> json) {
    return VoiceChatResponse(
      transcript: '', // Backend doesn't return transcript separately
      textResponse: json['text_response'] ?? '',
      audioResponseBase64: json['audio_response_base64'],
      toolsUsed: const [], // Backend doesn't provide this yet
      conversationId: null, // Backend doesn't provide this yet
      confidence: null, // Backend doesn't provide this yet
    );
  }
}

class ImageChatResponse {
  final String diagnosis;
  final String? diseaseName;
  final String? severity;
  final List<String> treatment;
  final List<String> organicRemedies;
  final List<String> chemicalTreatment;
  final List<String> prevention;
  final double? confidence;
  final String? audioResponseBase64;

  ImageChatResponse({
    required this.diagnosis,
    this.diseaseName,
    this.severity,
    this.treatment = const [],
    this.organicRemedies = const [],
    this.chemicalTreatment = const [],
    this.prevention = const [],
    this.confidence,
    this.audioResponseBase64,
  });

  factory ImageChatResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns simple structure with text_response and audio_response_base64
    String textResponse = json['text_response'] ?? '';
    
    return ImageChatResponse(
      diagnosis: textResponse,
      diseaseName: null,
      severity: null,
      treatment: [],
      organicRemedies: [],
      chemicalTreatment: [],
      prevention: [],
      confidence: null,
      audioResponseBase64: json['audio_response_base64'],
    );
  }
}

class ChatException implements Exception {
  final String message;
  final String details;

  ChatException(this.message, this.details);

  @override
  String toString() => 'ChatException: $message\nDetails: $details';
}
