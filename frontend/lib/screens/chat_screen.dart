import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../config/app_theme.dart';
import '../models/message.dart';
import '../services/language_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../services/audio_service.dart';
import '../widgets/enhanced_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String selectedLanguage;
  
  const ChatScreen({Key? key, required this.selectedLanguage}) : super(key: key);
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ChatService _chatService = ChatService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    // Use WidgetsBinding to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      
      if (userId == null) return;
      
      try {
        final history = await _chatService.getChatHistory(userId);
        if (history.isNotEmpty && mounted) {
          setState(() {
            _messages.addAll(history);
          });
        }
      } catch (e) {
        // Silently handle history loading errors
        print('Failed to load chat history: $e');
      }
    });
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(Message(
        content: widget.selectedLanguage == 'kn'
            ? 'ನಮಸ್ಕಾರ! ಕೃಷಿ ಮಿತ್ರ ಗೆ ಸ್ವಾಗತ। ನಿಮಗೆ ಹೇಗೆ ಸಹಾಯ ಮಾಡಬಹುದು?'
            : 'Hello! Welcome to Kisan AI. How can I help you today?',
        role: MessageRole.assistant,
      ));
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    final authService = context.read<AuthService>();
    final languageService = context.read<LanguageService>();
    
    final userId = authService.userId;
    if (userId == null) {
      _showErrorSnackBar('Please sign in to send messages');
      return;
    }

    _messageController.clear();

    setState(() {
      _messages.add(Message(
        content: userMessage,
        role: MessageRole.user,
      ));
      _isLoading = true;
    });

    try {
      final response = await _chatService.sendTextMessage(
        message: userMessage,
        userId: userId,
        language: languageService.selectedLanguage,
      );

      setState(() {
        _messages.add(Message(
          content: response.textResponse,
          role: MessageRole.assistant,
          audioUrl: response.audioResponseBase64,
          toolsUsed: response.toolsUsed,
          confidence: response.confidence,
        ));
        _isLoading = false;
      });

      // Auto-play audio response if available
      if (response.audioResponseBase64 != null && response.audioResponseBase64!.isNotEmpty) {
        final audioService = context.read<AudioService>();
        try {
          await audioService.playAudioFromBase64(response.audioResponseBase64!);
        } catch (e) {
          print('Failed to auto-play audio response: $e');
          // Don't show error to user for auto-play failures
        }
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = languageService.selectedLanguage == 'kn' 
          ? 'ಸಂದೇಶ ಕಳುಹಿಸುವಲ್ಲಿ ದೋಷ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.'
          : 'Failed to send message. Please try again.';

      if (e is ChatException) {
        if (e.message.contains('Network error')) {
          errorMessage = languageService.selectedLanguage == 'kn'
              ? 'ನೆಟ್‌ವರ್ಕ್ ದೋಷ. ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ.'
              : 'Network error. Please check your internet connection.';
        }
      }

      _showErrorSnackBar(errorMessage);
    }
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        final currentLanguage = languageService.selectedLanguage;
        
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              currentLanguage == 'kn' ? 'ಕೃಷಿ ಮಿತ್ರ' : 'Kisan AI',
              style: currentLanguage == 'kn'
                  ? AppTheme.kannadaHeading.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    )
                  : TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
            ),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2,
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(Icons.language, size: 20),
                  onPressed: () {
                    _showLanguageDialog();
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  _showInfoDialog();
                },
              ),
            ],
          ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return EnhancedMessageBubble(
                  message: message,
                  showTimestamp: true,
                );
              },
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'ಟೈಪ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',
                    style: AppTheme.kannadaCaption.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          
          // Input area
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Voice button with recording functionality
                  _buildVoiceButton(currentLanguage),
                  
                  SizedBox(width: 12),
                  
                  // Text input
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: currentLanguage == 'kn'
                            ? 'ನಿಮ್ಮ ಪ್ರಶ್ನೆ ಟೈಪ್ ಮಾಡಿ...'
                            : 'Type your question...',
                        hintStyle: currentLanguage == 'kn'
                            ? AppTheme.kannadaBody.copyWith(
                                color: Colors.grey[500],
                              )
                            : TextStyle(
                                color: Colors.grey[500],
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: AppTheme.primaryGreen),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: AppTheme.kannadaBody,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  // Send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }


  void _showLanguageDialog() {
    final languageService = context.read<LanguageService>();
    final currentLanguage = languageService.selectedLanguage;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.language, color: AppTheme.primaryGreen),
            SizedBox(width: 8),
            Text(
              currentLanguage == 'kn' ? 'ಭಾಷೆ ಬದಲಾಯಿಸಿ' : 'Change Language',
              style: currentLanguage == 'kn'
                  ? AppTheme.kannadaHeading.copyWith(fontSize: 18)
                  : TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.language, color: AppTheme.accentBlue),
              title: Text('English'),
              subtitle: Text('Switch to English'),
              trailing: currentLanguage == 'en' 
                  ? Icon(Icons.check, color: AppTheme.primaryGreen)
                  : null,
              onTap: () {
                Navigator.pop(context);
                languageService.changeLanguage('en');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Language changed to English'),
                    backgroundColor: AppTheme.primaryGreen,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.translate, color: AppTheme.accentBlue),
              title: Text('ಕನ್ನಡ'),
              subtitle: Text('ಕನ್ನಡಕ್ಕೆ ಬದಲಾಯಿಸಿ'),
              trailing: currentLanguage == 'kn' 
                  ? Icon(Icons.check, color: AppTheme.primaryGreen)
                  : null,
              onTap: () {
                Navigator.pop(context);
                languageService.changeLanguage('kn');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ಭಾಷೆ ಕನ್ನಡಕ್ಕೆ ಬದಲಾಯಿಸಲಾಗಿದೆ'),
                    backgroundColor: AppTheme.primaryGreen,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              currentLanguage == 'kn' ? 'ರದ್ದುಮಾಡಿ' : 'Cancel',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    final languageService = context.read<LanguageService>();
    final currentLanguage = languageService.selectedLanguage;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.agriculture, color: AppTheme.primaryGreen),
            SizedBox(width: 8),
            Text(
              currentLanguage == 'kn' ? 'ಕೃಷಿ ಮಿತ್ರ ಬಗ್ಗೆ' : 'About Kisan AI',
              style: currentLanguage == 'kn'
                  ? AppTheme.kannadaHeading.copyWith(fontSize: 18)
                  : TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          currentLanguage == 'kn'
              ? 'AI ಆಧಾರಿತ ಕೃಷಿ ಸಲಹೆಗಾರ ಅಪ್ಲಿಕೇಶನ್\n\n• ಸಸ್ಯ ರೋಗ ನಿರ್ಣಯ\n• ಮಾರುಕಟ್ಟೆ ಬೆಲೆ ಮಾಹಿತಿ\n• ಸರ್ಕಾರಿ ಯೋಜನೆಗಳು\n• ಧ್ವನಿ ಸಂಭಾಷಣೆ'
              : 'AI-powered Agricultural Assistant\n\n• Plant Disease Diagnosis\n• Market Price Information\n• Government Schemes\n• Voice Conversations',
          style: currentLanguage == 'kn'
              ? AppTheme.kannadaBody
              : TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              currentLanguage == 'kn' ? 'ಸರಿ' : 'OK',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceButton(String currentLanguage) {
    return Consumer<AudioService>(
      builder: (context, audioService, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording duration display
            if (audioService.isRecording)
              Container(
                margin: EdgeInsets.only(bottom: 4),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[400],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  audioService.formatDuration(audioService.recordingDuration),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            
            // Voice button
            GestureDetector(
              onTap: () async {
                if (audioService.isRecording) {
                  await _stopRecordingAndSend();
                } else {
                  await _startRecording();
                }
              },
              onLongPress: () async {
                await _startRecording();
              },
              onLongPressEnd: (_) async {
                if (audioService.isRecording) {
                  await _stopRecordingAndSend();
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: audioService.isRecording ? 56 : 48,
                height: audioService.isRecording ? 56 : 48,
                decoration: BoxDecoration(
                  color: audioService.isRecording 
                      ? Colors.red[400] 
                      : AppTheme.lightGreen,
                  borderRadius: BorderRadius.circular(audioService.isRecording ? 28 : 24),
                  boxShadow: audioService.isRecording
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 24,
                            spreadRadius: 6,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppTheme.lightGreen.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                ),
                child: audioService.recordingState == AudioRecordingState.processing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: Icon(
                          audioService.isRecording ? Icons.stop : Icons.mic,
                          key: ValueKey(audioService.isRecording),
                          color: audioService.isRecording 
                              ? Colors.white 
                              : AppTheme.primaryGreen,
                          size: audioService.isRecording ? 24 : 26,
                        ),
                      ),
              ),
            ),
            
            // Hint text
            if (!audioService.isRecording)
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  currentLanguage == 'kn' ? 'ಹಿಡಿದುಕೊಳ್ಳಿ' : 'Hold',
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey[500],
                    fontFamily: currentLanguage == 'kn' ? 'NotoSansKannada' : null,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _startRecording() async {
    final audioService = context.read<AudioService>();
    final languageService = context.read<LanguageService>();
    
    final success = await audioService.startRecording();
    if (!success && audioService.errorMessage != null) {
      // Show permission-specific error dialog instead of just snackbar
      if (audioService.errorMessage!.contains('Settings') || audioService.errorMessage!.contains('Privacy')) {
        _showPermissionDialog();
      } else {
        _showErrorSnackBar(
          languageService.selectedLanguage == 'kn'
              ? 'ರೆಕಾರ್ಡಿಂಗ್ ಪ್ರಾರಂಭಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: ${audioService.errorMessage}'
              : 'Failed to start recording: ${audioService.errorMessage}'
        );
      }
    }
  }

  void _showPermissionDialog() {
    final languageService = context.read<LanguageService>();
    final audioService = context.read<AudioService>();
    final currentLanguage = languageService.selectedLanguage;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.mic_off, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              currentLanguage == 'kn' 
                  ? 'ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿ' 
                  : 'Microphone Permission',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          currentLanguage == 'kn'
              ? 'ಧ್ವನಿ ಸಂದೇಶಗಳಿಗಾಗಿ ಮೈಕ್ರೊಫೋನ್ ಪ್ರವೇಶದ ಅಗತ್ಯವಿದೆ. ದಯವಿಟ್ಟು ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಮೈಕ್ರೊಫೋನ್ ಅನುಮತಿಯನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.'
              : 'Microphone access is needed for voice messages. Please enable microphone permission in Settings.',
          style: TextStyle(fontSize: 16),
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
            onPressed: () async {
              Navigator.pop(context);
              await audioService.openDeviceSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: Text(
              currentLanguage == 'kn' ? 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು' : 'Settings',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _stopRecordingAndSend() async {
    final audioService = context.read<AudioService>();
    final authService = context.read<AuthService>();
    final languageService = context.read<LanguageService>();
    
    final userId = authService.userId;
    if (userId == null) {
      _showErrorSnackBar('Please sign in to send voice messages');
      return;
    }

    final audioFile = await audioService.stopRecording();
    if (audioFile == null) {
      _showErrorSnackBar(
        languageService.selectedLanguage == 'kn'
            ? 'ಆಡಿಯೋ ರೆಕಾರ್ಡಿಂಗ್ ವಿಫಲವಾಗಿದೆ'
            : 'Audio recording failed'
      );
      return;
    }

    setState(() {
      _messages.add(Message(
        content: languageService.selectedLanguage == 'kn' 
            ? '🎤 ಧ್ವನಿ ಸಂದೇಶ (${audioService.formatDuration(audioService.recordingDuration)})'
            : '🎤 Voice message (${audioService.formatDuration(audioService.recordingDuration)})',
        role: MessageRole.user,
        type: MessageType.voice,
      ));
      _isLoading = true;
    });

    try {
      final response = await _chatService.sendVoiceMessage(
        audioFile: audioFile,
        userId: userId,
        language: languageService.selectedLanguage,
      );

      setState(() {
        _messages.add(Message(
          content: response.textResponse,
          role: MessageRole.assistant,
          audioUrl: response.audioResponseBase64,
          toolsUsed: response.toolsUsed,
          confidence: response.confidence,
        ));
        _isLoading = false;
      });

      // Auto-play audio response
      if (response.audioResponseBase64 != null && response.audioResponseBase64!.isNotEmpty) {
        try {
          await audioService.playAudioFromBase64(response.audioResponseBase64!);
        } catch (e) {
          print('Failed to auto-play voice response audio: $e');
          // Don't show error to user for auto-play failures
        }
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = languageService.selectedLanguage == 'kn' 
          ? 'ಧ್ವನಿ ಸಂದೇಶ ಕಳುಹಿಸುವಲ್ಲಿ ದೋಷ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.'
          : 'Failed to send voice message. Please try again.';

      if (e is ChatException) {
        if (e.message.contains('Network error')) {
          errorMessage = languageService.selectedLanguage == 'kn'
              ? 'ನೆಟ್‌ವರ್ಕ್ ದೋಷ. ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಪರಿಶೀಲಿಸಿ.'
              : 'Network error. Please check your internet connection.';
        }
      }

      _showErrorSnackBar(errorMessage);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
