import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/message.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:8084'; // Updated to match backend port
  String? _sessionId;
  
  // Generate session ID once per chat session
  String get sessionId => _sessionId ??= const Uuid().v4();
  
  // Reset session ID (called when starting a new chat session)
  void resetSession() {
    _sessionId = null;
  }

  Future<ChatResponse> sendTextMessage({
    required String message,
    required String userId,
    required String language,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/chat_endpoint');
      
      // Use form data format to match backend expectations
      var request = http.MultipartRequest('POST', url);
      request.fields['text'] = message;
      // Note: Backend doesn't use user_id, session_id, language - but we keep for future
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } else {
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
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/chat_endpoint');
      
      var request = http.MultipartRequest('POST', url);
      
      // Add audio file with the exact field name backend expects
      request.files.add(
        await http.MultipartFile.fromPath('audio_file', audioFile.path),
      );
      // Note: Backend doesn't use additional fields but we keep for consistency

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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
  }) async {
    try {
      // Since backend doesn't have dedicated image endpoint, 
      // we'll send a text message describing the image analysis request
      String imageAnalysisPrompt = 'Please analyze the plant image I am sharing. ';
      if (message.isNotEmpty) imageAnalysisPrompt += message + ' ';
      if (plantType.isNotEmpty) imageAnalysisPrompt += 'Plant type: $plantType. ';
      if (symptomsDescription.isNotEmpty) imageAnalysisPrompt += 'Symptoms: $symptomsDescription. ';
      imageAnalysisPrompt += 'Please provide diagnosis, treatment recommendations, and prevention tips.';
      
      // For now, send as text message since backend doesn't support images yet
      final chatResponse = await sendTextMessage(
        message: imageAnalysisPrompt,
        userId: userId,
        language: 'en', // Default language for image analysis
      );
      
      // Convert ChatResponse to ImageChatResponse format
      return ImageChatResponse(
        diagnosis: chatResponse.textResponse,
        audioResponseBase64: chatResponse.audioResponseBase64,
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
    return ImageChatResponse(
      diagnosis: json['diagnosis'] ?? '',
      diseaseName: json['disease_name'],
      severity: json['severity'],
      treatment: json['treatment'] != null 
          ? List<String>.from(json['treatment'])
          : [],
      organicRemedies: json['organic_remedies'] != null 
          ? List<String>.from(json['organic_remedies'])
          : [],
      chemicalTreatment: json['chemical_treatment'] != null 
          ? List<String>.from(json['chemical_treatment'])
          : [],
      prevention: json['prevention'] != null 
          ? List<String>.from(json['prevention'])
          : [],
      confidence: json['confidence']?.toDouble(),
      audioResponseBase64: json['audio_response_base64'] ?? json['audio_url'],
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
