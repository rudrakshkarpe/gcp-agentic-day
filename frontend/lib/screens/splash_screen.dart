import 'package:flutter/material.dart';
import 'dart:async';
import '../config/app_theme.dart';
import 'language_selection_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool? isAuthenticated;
  
  const SplashScreen({Key? key, this.isAuthenticated}) : super(key: key);
  
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _currentImageIndex = 0;
  late Timer _imageTimer;
  
  final List<String> _backgroundImages = [
    'assets/images/pexels-binyaminmellish-169523.jpg',
    'assets/images/pexels-indrajeet-kundalkar-327512914-20687508.jpg',
    'assets/images/pexels-kelly-1179532-2382904.jpg',
    'assets/images/pexels-pixabay-247597.jpg',
    'assets/images/pexels-srihari-jaddu-1006683-3066025.jpg',
    'assets/images/pexels-vr-visualrepo-2147871274-29803637.jpg',
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _animationController.forward();
    _startImageSlideshow();
    _initialize();
  }
  
  void _startImageSlideshow() {
    _imageTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
  }

  Future<void> _initialize() async {
    // Wait for animation to start
    await Future.delayed(Duration(milliseconds: 500));
    
    // Wait for minimum splash time
    await Future.delayed(Duration(seconds: 2));
    
    // Navigate based on authentication state
    if (mounted) {
      if (widget.isAuthenticated == true) {
        // User is already authenticated, go directly to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        // User is not authenticated, go through normal flow
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Stack(
        children: [
          // Animated background slideshow
          AnimatedSwitcher(
            duration: Duration(milliseconds: 2000),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: Container(
              key: ValueKey(_currentImageIndex),
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                _backgroundImages[_currentImageIndex],
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Dark overlay for text readability
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Main content with animations
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    
                    // App Name in Kannada
                    Text(
                      'ಕೃಷಿ ಮಿತ್ರ',
                      style: AppTheme.kannadaHeading.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    // App Name in English
                    Text(
                      'Kisan AI Assistant',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    SizedBox(height: 48),
                    
                    // Loading indicator
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Loading text in Kannada
                    Text(
                      'ಪ್ರಾರಂಭಿಸಲಾಗುತ್ತಿದೆ...',
                      style: AppTheme.kannadaBody.copyWith(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
