import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_theme.dart';
import '../models/message.dart';
import '../services/audio_service.dart';
import '../services/language_service.dart';
import 'package:provider/provider.dart';

class EnhancedMessageBubble extends StatelessWidget {
  final Message message;
  final bool showTimestamp;
  
  const EnhancedMessageBubble({
    Key? key,
    required this.message,
    this.showTimestamp = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final languageService = context.read<LanguageService>();
    final currentLanguage = languageService.selectedLanguage;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAvatar(false),
            SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showCopyDialog(context, currentLanguage),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryGreen : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMessageContent(context, isUser, currentLanguage),
                        if (message.hasAudio && !isUser) ...[
                          SizedBox(height: 8),
                          _buildAudioPlayButton(context),
                        ],
                        if (message.hasTools && !isUser) ...[
                          SizedBox(height: 8),
                          _buildToolsUsedIndicator(currentLanguage),
                        ],
                        if (showTimestamp) ...[
                          SizedBox(height: 4),
                          _buildTimestamp(currentLanguage),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!isUser) ...[
                  SizedBox(height: 4),
                  _buildCopyButton(context, currentLanguage),
                ],
              ],
            ),
          ),
          
          if (isUser) ...[
            SizedBox(width: 8),
            _buildAvatar(true),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? Colors.grey[300] : AppTheme.primaryGreen,
      child: Icon(
        isUser ? Icons.person : Icons.agriculture,
        color: isUser ? Colors.grey[600] : Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isUser, String currentLanguage) {
    // Check if content contains HTML tags
    bool containsHtml = message.content.contains('<') && message.content.contains('>');
    
    if (containsHtml && !isUser) {
      // Use custom HTML parser for AI responses
      return _buildFormattedText(message.content, isUser, currentLanguage);
    } else {
      // Use regular text for user messages and non-HTML content
      String formattedContent = _formatMessageText(message.content);
      
      return SelectableText(
        formattedContent,
        style: currentLanguage == 'kn' 
            ? AppTheme.kannadaBody.copyWith(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
                height: 1.4,
              )
            : TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
                height: 1.4,
              ),
        textAlign: TextAlign.left,
        showCursor: true,
        cursorColor: isUser ? Colors.white : AppTheme.primaryGreen,
        onSelectionChanged: (selection, cause) {
          // Optional: Handle selection changes
        },
      );
    }
  }

  Widget _buildFormattedText(String content, bool isUser, String currentLanguage) {
    List<TextSpan> spans = [];
    List<String> parts = _parseHtmlContent(content);
    
    TextStyle baseStyle = currentLanguage == 'kn' 
        ? AppTheme.kannadaBody.copyWith(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
            height: 1.4,
          )
        : TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
            height: 1.4,
          );
    
    TextStyle boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);
    
    bool isBold = false;
    
    for (String part in parts) {
      // Check if this part is an opening HTML tag
      if (part == '<b>' || part == '<strong>') {
        isBold = true;
        // Don't add the tag to spans - just change the formatting state
      } else if (part == '</b>' || part == '</strong>') {
        isBold = false;
        // Don't add the tag to spans - just change the formatting state
      } else if (part.isNotEmpty && !_isHtmlTag(part)) {
        // Only add actual text content, not HTML tags
        spans.add(TextSpan(
          text: part,
          style: isBold ? boldStyle : baseStyle,
        ));
      }
    }
    
    return SelectableText.rich(
      TextSpan(children: spans),
      showCursor: true,
      cursorColor: isUser ? Colors.white : AppTheme.primaryGreen,
    );
  }

  List<String> _parseHtmlContent(String content) {
    List<String> parts = [];
    String currentPart = '';
    bool inTag = false;
    
    for (int i = 0; i < content.length; i++) {
      if (content[i] == '<') {
        if (currentPart.isNotEmpty) {
          parts.add(currentPart);
          currentPart = '';
        }
        inTag = true;
        currentPart += content[i];
      } else if (content[i] == '>') {
        inTag = false;
        currentPart += content[i];
        parts.add(currentPart);
        currentPart = '';
      } else {
        currentPart += content[i];
      }
    }
    
    if (currentPart.isNotEmpty) {
      parts.add(currentPart);
    }
    
    return parts;
  }

  bool _isHtmlTag(String text) {
    // Check if the text is an HTML tag (starts with < and ends with >)
    return text.trim().startsWith('<') && text.trim().endsWith('>');
  }

  String _formatMessageText(String content) {
    // Handle bullet points and formatting
    content = content.replaceAll('•', '• ');
    content = content.replaceAll('*', '');
    
    // Remove HTML tags for plain text display
    content = content.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Add proper spacing for numbered lists
    content = content.replaceAllMapped(
      RegExp(r'(\d+\.)\s*'),
      (match) => '${match.group(1)} ',
    );
    
    // Handle line breaks properly
    content = content.replaceAll('\n\n', '\n');
    
    return content.trim();
  }

  Widget _buildAudioPlayButton(BuildContext context) {
    return Consumer<AudioService>(
      builder: (context, audioService, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.lightGreen.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                audioService.isPlaying ? Icons.volume_up : Icons.play_arrow,
                size: 16,
                color: AppTheme.primaryGreen,
              ),
              SizedBox(width: 4),
              Text(
                'Audio Response',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolsUsedIndicator(String currentLanguage) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.build,
            size: 12,
            color: AppTheme.accentBlue,
          ),
          SizedBox(width: 4),
          Text(
            currentLanguage == 'kn' ? 'ಉಪಕರಣಗಳು ಬಳಸಲಾಗಿದೆ' : 'Tools Used',
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.accentBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(String currentLanguage) {
    return Text(
      _formatTimestamp(message.timestamp, currentLanguage),
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[500],
      ),
    );
  }

  Widget _buildCopyButton(BuildContext context, String currentLanguage) {
    return GestureDetector(
      onTap: () => _copyToClipboard(context, currentLanguage),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.copy,
              size: 12,
              color: Colors.grey[600],
            ),
            SizedBox(width: 4),
            Text(
              currentLanguage == 'kn' ? 'ಕಾಪಿ' : 'Copy',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCopyDialog(BuildContext context, String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.copy, color: AppTheme.primaryGreen),
            SizedBox(width: 8),
            Text(
              currentLanguage == 'kn' ? 'ಸಂದೇಶ ಕಾಪಿ ಮಾಡಿ' : 'Copy Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          currentLanguage == 'kn' 
              ? 'ಈ ಸಂದೇಶವನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ಕಾಪಿ ಮಾಡಬೇಕೆ?'
              : 'Do you want to copy this message to clipboard?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              currentLanguage == 'kn' ? 'ರದ್ದುಮಾಡಿ' : 'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copyToClipboard(context, currentLanguage);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(
              currentLanguage == 'kn' ? 'ಕಾಪಿ' : 'Copy',
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String currentLanguage) {
    Clipboard.setData(ClipboardData(text: message.content));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              currentLanguage == 'kn' 
                  ? 'ಸಂದೇಶ ಕಾಪಿ ಮಾಡಲಾಗಿದೆ'
                  : 'Message copied to clipboard',
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryGreen,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, String currentLanguage) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inDays > 0) {
      return currentLanguage == 'kn' 
          ? '${diff.inDays} ದಿನಗಳ ಹಿಂದೆ'
          : '${diff.inDays} days ago';
    } else if (diff.inHours > 0) {
      return currentLanguage == 'kn' 
          ? '${diff.inHours} ಗಂಟೆಗಳ ಹಿಂದೆ'
          : '${diff.inHours} hours ago';
    } else if (diff.inMinutes > 0) {
      return currentLanguage == 'kn' 
          ? '${diff.inMinutes} ನಿಮಿಷಗಳ ಹಿಂದೆ'
          : '${diff.inMinutes} minutes ago';
    } else {
      return currentLanguage == 'kn' ? 'ಈಗ' : 'Now';
    }
  }
}
