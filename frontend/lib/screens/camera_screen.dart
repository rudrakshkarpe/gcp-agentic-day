import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../config/app_theme.dart';
import '../services/language_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';

class CameraScreen extends StatefulWidget {
  final String selectedLanguage;
  
  const CameraScreen({Key? key, required this.selectedLanguage}) : super(key: key);
  
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _selectedImage;
  final TextEditingController _promptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    final languageService = context.read<LanguageService>();
    final currentLanguage = languageService.selectedLanguage;
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              currentLanguage == 'kn' ? 'ಚಿತ್ರದ ಮೂಲ ಆಯ್ಕೆಮಾಡಿ' : 'Select Image Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: currentLanguage == 'kn' ? 'ಕ್ಯಾಮೆರಾ' : 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: currentLanguage == 'kn' ? 'ಗ್ಯಾಲರಿ' : 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.lightGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lightGreen),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close the modal
    
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _proceedToChat() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      _showErrorSnackBar('Please add a description or question about the image');
      return;
    }

    // Navigate to chat screen with image and prompt
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreenWithImage(
          selectedLanguage: widget.selectedLanguage,
          imageFile: _selectedImage!,
          imagePrompt: prompt,
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
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
              currentLanguage == 'kn' ? 'ಚಿತ್ರ ಅಪ್‌ಲೋಡ್' : 'Upload Picture',
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
          ),
          body: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                      ),
                      SizedBox(height: 16),
                      Text(
                        currentLanguage == 'kn' ? 'ಚಿತ್ರ ಲೋಡ್ ಆಗುತ್ತಿದೆ...' : 'Loading image...',
                        style: currentLanguage == 'kn'
                            ? AppTheme.kannadaBody
                            : TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image selection area
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedImage != null
                                  ? AppTheme.primaryGreen
                                  : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      currentLanguage == 'kn'
                                          ? 'ಚಿತ್ರ ಆಯ್ಕೆ ಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ'
                                          : 'Tap to select an image',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      currentLanguage == 'kn'
                                          ? 'ಕ್ಯಾಮೆರಾ ಅಥವಾ ಗ್ಯಾಲರಿಯಿಂದ'
                                          : 'From camera or gallery',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // Prompt input area
                      Text(
                        currentLanguage == 'kn'
                            ? 'ಚಿತ್ರದ ಬಗ್ಗೆ ನಿಮ್ಮ ಪ್ರಶ್ನೆ ಅಥವಾ ವಿವರಣೆ'
                            : 'Your question or description about the image',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _promptController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: currentLanguage == 'kn'
                                ? 'ಉದಾಹರಣೆ: ಈ ಸಸ್ಯದಲ್ಲಿ ಏನು ಸಮಸ್ಯೆ ಇದೆ? ಅಥವಾ ಈ ಬೆಳೆಯ ಆರೋಗ್ಯ ಹೇಗಿದೆ?'
                                : 'Example: What\'s wrong with this plant? Or How healthy is this crop?',
                            hintStyle: currentLanguage == 'kn'
                                ? AppTheme.kannadaBody.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  )
                                : TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: currentLanguage == 'kn'
                              ? AppTheme.kannadaBody
                              : TextStyle(fontSize: 16),
                        ),
                      ),

                      SizedBox(height: 40),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppTheme.primaryGreen),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                currentLanguage == 'kn' ? 'ರದ್ದುಮಾಡಿ' : 'Cancel',
                                style: TextStyle(
                                  color: AppTheme.primaryGreen,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _proceedToChat,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    currentLanguage == 'kn' ? 'ಚಾಟ್‌ಗೆ ಕಳುಹಿಸಿ' : 'Send to Chat',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

// Extended ChatScreen that handles images
class ChatScreenWithImage extends StatefulWidget {
  final String selectedLanguage;
  final File imageFile;
  final String imagePrompt;
  
  const ChatScreenWithImage({
    Key? key,
    required this.selectedLanguage,
    required this.imageFile,
    required this.imagePrompt,
  }) : super(key: key);
  
  @override
  _ChatScreenWithImageState createState() => _ChatScreenWithImageState();
}

class _ChatScreenWithImageState extends State<ChatScreenWithImage> {
  @override
  void initState() {
    super.initState();
    // Automatically send the image message when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendImageMessage();
    });
  }

  Future<void> _sendImageMessage() async {
    try {
      // Navigate to chat screen first, then send image message there
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreenWithImageIntegration(
            selectedLanguage: widget.selectedLanguage,
            imageFile: widget.imageFile,
            imagePrompt: widget.imagePrompt,
          ),
        ),
      );
    } catch (e) {
      // If there's an error, show it and go back
      _showErrorDialog('Failed to process image: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              widget.selectedLanguage == 'kn' 
                  ? 'ಚಿತ್ರ ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ...' 
                  : 'Analyzing image...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: widget.selectedLanguage == 'kn' ? 'NotoSansKannada' : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat screen that integrates image sending
class ChatScreenWithImageIntegration extends StatefulWidget {
  final String selectedLanguage;
  final File imageFile;
  final String imagePrompt;
  
  const ChatScreenWithImageIntegration({
    Key? key,
    required this.selectedLanguage,
    required this.imageFile,
    required this.imagePrompt,
  }) : super(key: key);
  
  @override
  _ChatScreenWithImageIntegrationState createState() => _ChatScreenWithImageIntegrationState();
}

class _ChatScreenWithImageIntegrationState extends State<ChatScreenWithImageIntegration> {
  @override
  void initState() {
    super.initState();
    // Navigate to regular chat screen and pass the image data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            selectedLanguage: widget.selectedLanguage,
            initialImageFile: widget.imageFile,
            initialImagePrompt: widget.imagePrompt,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
