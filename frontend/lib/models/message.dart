import 'package:uuid/uuid.dart';

enum MessageType { text, voice, image }
enum MessageRole { user, assistant }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final MessageType type;
  final DateTime timestamp;
  final String? audioUrl;
  final String? imageUrl;
  final List<String> toolsUsed;
  final double? confidence;
  final bool isProcessing;

  Message({
    String? id,
    required this.content,
    required this.role,
    this.type = MessageType.text,
    DateTime? timestamp,
    this.audioUrl,
    this.imageUrl,
    this.toolsUsed = const [],
    this.confidence,
    this.isProcessing = false,
  }) : 
    id = id ?? Uuid().v4(),
    timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? Uuid().v4(),
      content: json['content'] ?? json['text'] ?? '',
      role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
      type: _parseMessageType(json['type']),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      audioUrl: json['audio_url'],
      imageUrl: json['image_url'],
      toolsUsed: json['tools_used'] != null 
          ? List<String>.from(json['tools_used'])
          : [],
      confidence: json['confidence']?.toDouble(),
      isProcessing: json['is_processing'] ?? false,
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type?.toLowerCase()) {
      case 'voice':
        return MessageType.voice;
      case 'image':
        return MessageType.image;
      default:
        return MessageType.text;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role == MessageRole.user ? 'user' : 'assistant',
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'audio_url': audioUrl,
      'image_url': imageUrl,
      'tools_used': toolsUsed,
      'confidence': confidence,
      'is_processing': isProcessing,
    };
  }

  Message copyWith({
    String? id,
    String? content,
    MessageRole? role,
    MessageType? type,
    DateTime? timestamp,
    String? audioUrl,
    String? imageUrl,
    List<String>? toolsUsed,
    double? confidence,
    bool? isProcessing,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      toolsUsed: toolsUsed ?? this.toolsUsed,
      confidence: confidence ?? this.confidence,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get hasAudio => audioUrl != null && audioUrl!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasTools => toolsUsed.isNotEmpty;

  String get displayContent {
    if (type == MessageType.voice && content.startsWith('🎤')) {
      return content;
    } else if (type == MessageType.image && content.startsWith('📷')) {
      return content;
    }
    return content;
  }
}

// Message factory methods for different types
class MessageFactory {
  static Message createTextMessage({
    required String content,
    required MessageRole role,
  }) {
    return Message(
      content: content,
      role: role,
      type: MessageType.text,
    );
  }

  static Message createVoiceMessage({
    required String content,
    required MessageRole role,
    String? audioUrl,
  }) {
    return Message(
      content: role == MessageRole.user 
          ? '🎤 $content'
          : content,
      role: role,
      type: MessageType.voice,
      audioUrl: audioUrl,
    );
  }

  static Message createImageMessage({
    required String content,
    required MessageRole role,
    String? imageUrl,
  }) {
    return Message(
      content: role == MessageRole.user
          ? '📷 $content'
          : content,
      role: role,
      type: MessageType.image,
      imageUrl: imageUrl,
    );
  }

  static Message createProcessingMessage() {
    return Message(
      content: 'ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗುತ್ತಿದೆ...',
      role: MessageRole.assistant,
      isProcessing: true,
    );
  }
}
