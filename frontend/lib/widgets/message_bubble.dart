import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../config/app_theme.dart';
import '../services/audio_service.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) _buildAvatar(),
          if (!message.isUser) SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.all(16),
              decoration: message.isUser
                  ? AppTheme.userMessageDecoration
                  : AppTheme.assistantMessageDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image preview for image messages
                  if (message.hasImage && message.imageUrl != null)
                    _buildImagePreview(),
                  
                  // Message content
                  if (message.content.isNotEmpty)
                    Text(
                      message.displayContent,
                      style: AppTheme.kannadaBody.copyWith(
                        color: message.isUser ? Colors.white : AppTheme.onSurface,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  
                  // Processing indicator
                  if (message.isProcessing)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗುತ್ತಿದೆ...',
                            style: AppTheme.kannadaCaption.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Audio playback controls
                  if (message.hasAudio && !message.isProcessing)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: _buildAudioControls(context),
                    ),
                  
                  // Message metadata
                  if (!message.isProcessing)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: _buildMessageMetadata(),
                    ),
                ],
              ),
            ),
          ),
          if (message.isUser) SizedBox(width: 8),
          if (message.isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: message.isUser ? AppTheme.primaryGreen : AppTheme.lightGreen,
      child: Icon(
        message.isUser ? Icons.person : Icons.smart_toy,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: message.imageUrl!.startsWith('http')
            ? Image.network(
                message.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.grey),
                        Text('Image load failed'),
                      ],
                    ),
                  );
                },
              )
            : Image.file(
                File(message.imageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.grey),
                        Text('Image not found'),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildAudioControls(BuildContext context) {
    return Consumer<AudioService>(
      builder: (context, audioService, child) {
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isUser 
                ? Colors.white.withOpacity(0.2)
                : AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (audioService.isPlaying) {
                    audioService.stopPlayback();
                  } else {
                    // Play audio from base64 string
                    if (message.audioUrl != null && message.audioUrl!.isNotEmpty) {
                      audioService.playAudioFromBase64(message.audioUrl!);
                    }
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    audioService.isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '🔊 ಆಡಿಯೋ ಸಂದೇಶ',
                style: AppTheme.kannadaCaption.copyWith(
                  color: message.isUser ? Colors.white70 : AppTheme.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageMetadata() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timestamp
        Text(
          _formatTime(message.timestamp),
          style: AppTheme.kannadaCaption.copyWith(
            color: message.isUser ? Colors.white70 : AppTheme.secondaryText,
            fontSize: 12,
          ),
        ),
        
        // Tools used indicator
        if (message.hasTools) ...[
          SizedBox(width: 8),
          Icon(
            Icons.build,
            size: 12,
            color: message.isUser ? Colors.white70 : AppTheme.secondaryText,
          ),
        ],
        
        // Confidence indicator
        if (message.confidence != null && message.confidence! > 0) ...[
          SizedBox(width: 8),
          Icon(
            message.confidence! > 0.8 
                ? Icons.check_circle
                : message.confidence! > 0.6
                    ? Icons.help
                    : Icons.warning,
            size: 12,
            color: message.isUser ? Colors.white70 : AppTheme.secondaryText,
          ),
        ],
        
        // Message type indicator
        if (message.type != MessageType.text) ...[
          SizedBox(width: 8),
          Icon(
            message.type == MessageType.voice 
                ? Icons.mic
                : Icons.camera_alt,
            size: 12,
            color: message.isUser ? Colors.white70 : AppTheme.secondaryText,
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'ಈಗ';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ನಿಮಿಷಗಳ ಹಿಂದೆ';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} ಗಂಟೆಗಳ ಹಿಂದೆ';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
