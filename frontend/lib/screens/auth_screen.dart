import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../services/language_service.dart';
import 'email_auth_screen.dart';
import 'phone_auth_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToEmailAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmailAuthScreen(),
      ),
    );
  }

  void _navigateToPhoneAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhoneAuthScreen(),
      ),
    );
  }

  void _showLanguageDialog() {
    final languageService = Provider.of<LanguageService>(context, listen: false);
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
                  ? TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'NotoSansKannada')
                  : TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.language, color: AppTheme.primaryGreen),
              title: Text('English'),
              subtitle: Text('Switch to English'),
              trailing: currentLanguage == 'en' 
                  ? Icon(Icons.check, color: AppTheme.primaryGreen)
                  : null,
              onTap: () {
                Navigator.pop(context);
                languageService.changeLanguage('en');
              },
            ),
            ListTile(
              leading: Icon(Icons.translate, color: AppTheme.primaryGreen),
              title: Text('ಕನ್ನಡ', style: TextStyle(fontFamily: 'NotoSansKannada')),
              subtitle: Text('ಕನ್ನಡಕ್ಕೆ ಬದಲಾಯಿಸಿ', style: TextStyle(fontFamily: 'NotoSansKannada')),
              trailing: currentLanguage == 'kn' 
                  ? Icon(Icons.check, color: AppTheme.primaryGreen)
                  : null,
              onTap: () {
                Navigator.pop(context);
                languageService.changeLanguage('kn');
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

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final isKannada = languageService.selectedLanguage == 'kn';
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Container
          Container(
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
          ),
          
          // Language Toggle Button
          Positioned(
            top: 50,
            right: 20,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(Icons.language, size: 20, color: Colors.white),
                  onPressed: _showLanguageDialog,
                ),
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.08),
                        
                        // App Icon
                        Container(
                          width: screenHeight * 0.15,
                          height: screenHeight * 0.15,
                          constraints: BoxConstraints(
                            minWidth: 100,
                            minHeight: 100,
                            maxWidth: 140,
                            maxHeight: 140,
                          ),
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
                            size: screenHeight * 0.075,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.04),
                    
                        // Welcome Title
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isKannada ? 'ಸ್ವಾಗತ' : 'Welcome',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.04,
                              fontWeight: FontWeight.bold,
                              fontFamily: isKannada ? 'NotoSansKannada' : null,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.01),
                        
                        // Subtitle
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isKannada 
                              ? 'ನಿಮ್ಮ ಕೃಷಿ ಸಹಾಯಕ' 
                              : 'Your Agricultural Assistant',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: screenHeight * 0.022,
                              fontFamily: isKannada ? 'NotoSansKannada' : null,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.06),
                    
                        // Choose authentication method title
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            isKannada 
                              ? 'ಪ್ರವೇಶ ವಿಧಾನವನ್ನು ಆರಿಸಿ'
                              : 'Choose Sign In Method',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.w600,
                              fontFamily: isKannada ? 'NotoSansKannada' : null,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.04),
                    
                        // Email Authentication Option
                        _buildAuthOption(
                          title: isKannada ? 'ಇಮೇಲ್ ಬಳಸಿ' : 'Continue with Email',
                          subtitle: isKannada ? 'ಇಮೇಲ್ ಮತ್ತು ಪಾಸ್‌ವರ್ಡ್' : 'Email & Password',
                          icon: Icons.email,
                          onTap: _navigateToEmailAuth,
                          isKannada: isKannada,
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Phone Authentication Option
                        _buildAuthOption(
                          title: isKannada ? 'ಫೋನ್ ಬಳಸಿ' : 'Continue with Phone',
                          subtitle: isKannada ? 'ಫೋನ್ ನಂಬರ್ ಮತ್ತು OTP' : 'Phone Number & OTP',
                          icon: Icons.phone,
                          onTap: _navigateToPhoneAuth,
                          isKannada: isKannada,
                        ),
                        
                        SizedBox(height: screenHeight * 0.04),
                    
                        // Development Mode Notice
                        Container(
                          width: screenWidth,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white70,
                                size: screenHeight * 0.03,
                              ),
                              SizedBox(height: 8),
                              Text(
                                isKannada 
                                  ? 'ಪರೀಕ್ಷೆಗಾಗಿ ಇಮೇಲ್: test@kisan.com\nಪಾಸ್‌ವರ್ಡ್: test123'
                                  : 'For testing:\nEmail: test@kisan.com\nPassword: test123',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: screenHeight * 0.015,
                                  height: 1.4,
                                  fontFamily: isKannada ? 'NotoSansKannada' : null,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.03),
                        
                        // Terms and conditions
                        Container(
                          width: screenWidth,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            isKannada 
                              ? 'ಮುಂದುವರಿಸುವ ಮೂಲಕ, ನೀವು ನಮ್ಮ ನಿಯಮಗಳು ಮತ್ತು ಷರತ್ತುಗಳನ್ನು ಒಪ್ಪುತ್ತೀರಿ'
                              : 'By continuing, you agree to our Terms and Conditions',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: screenHeight * 0.014,
                              height: 1.4,
                              fontFamily: isKannada ? 'NotoSansKannada' : null,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(height: screenHeight * 0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isKannada,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth,
      constraints: BoxConstraints(
        minHeight: 70,
        maxHeight: screenHeight * 0.12,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: screenHeight * 0.05,
                  height: screenHeight * 0.05,
                  constraints: BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                    maxWidth: 48,
                    maxHeight: 48,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: screenHeight * 0.025,
                  ),
                ),
                
                SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.bold,
                          fontFamily: isKannada ? 'NotoSansKannada' : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 2),
                      
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: screenHeight * 0.015,
                          fontFamily: isKannada ? 'NotoSansKannada' : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
