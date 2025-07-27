import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/language_service.dart';
import 'auth_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;

  void _selectLanguage(String language) {
    setState(() {
      selectedLanguage = language;
    });
    
    // Set the language in the service
    final languageService = Provider.of<LanguageService>(context, listen: false);
    languageService.changeLanguage(language);
    
    // Navigate to auth screen after selection
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AuthScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGreen,
              AppTheme.lightGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.agriculture,
                    size: 60,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Title
                Text(
                  'Choose Your Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 8),
                
                Text(
                  'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆರಿಸಿ',
                  style: AppTheme.kannadaHeading.copyWith(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 64),
                
                // Language Options
                _buildLanguageOption(
                  'English',
                  'Continue in English',
                  Icons.language,
                  'en',
                ),
                
                SizedBox(height: 20),
                
                _buildLanguageOption(
                  'ಕನ್ನಡ',
                  'ಕನ್ನಡದಲ್ಲಿ ಮುಂದುವರಿಸಿ',
                  Icons.translate,
                  'kn',
                ),
                
                SizedBox(height: 48),
                
                // Info text
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'You can change the language later in settings\nನೀವು ನಂತರ ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಭಾಷೆಯನ್ನು ಬದಲಾಯಿಸಬಹುದು',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    String language,
    String subtitle,
    IconData icon,
    String code,
  ) {
    final isSelected = selectedLanguage == code;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      height: 90,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectLanguage(code),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.white 
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryGreen 
                    : Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryGreen 
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.white70,
                    size: 20,
                  ),
                ),
                
                SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryGreen : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 1),
                      
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected 
                              ? AppTheme.primaryGreen.withOpacity(0.7) 
                              : Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
