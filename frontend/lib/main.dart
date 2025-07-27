import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/language_service.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/audio_service.dart';
import 'services/theme_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const KisanApp());
}

class KisanApp extends StatelessWidget {
  const KisanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageService()),
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => LocationService()),
        ChangeNotifierProvider(create: (context) => AudioService()),
        ChangeNotifierProvider(create: (context) => ThemeService()),
      ],
      child: Consumer2<LanguageService, ThemeService>(
        builder: (context, languageService, themeService, child) {
          return MaterialApp(
            title: 'Kisan AI',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            locale: Locale(languageService.selectedLanguage == 'kn' ? 'kn' : 'en'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('kn', 'IN'), // Kannada
            ],
            home: AuthWrapper(),
          );
        },
      ),
    );
  }
}

// Auth Wrapper to manage authentication state
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isAuthenticated) {
          // User is signed in, go directly to dashboard
          return SplashScreen(isAuthenticated: true);
        }
        
        // User is not signed in, show normal splash -> language -> auth flow
        return SplashScreen(isAuthenticated: false);
      },
    );
  }
}
