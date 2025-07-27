import 'package:flutter/material.dart';

class AppTheme {
  // Modern Agricultural Colors - Light Theme
  static const Color primaryGreen = Color(0xFF2E7D32);     // Rich forest green
  static const Color darkGreen = Color(0xFF1B5E20);        // Deep forest
  static const Color lightGreen = Color(0xFF4CAF50);       // Fresh leaf green
  static const Color accentOrange = Color(0xFFFF6F00);     // Vibrant sunset orange
  static const Color accentBlue = Color(0xFF1976D2);       // Sky blue
  static const Color accentPurple = Color(0xFF7B1FA2);     // Royal purple
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color backgroundColor = Color(0xFFF8F9FA);   // Soft off-white
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF6C757D);

  // Dark Theme Colors
  static const Color darkPrimaryGreen = Color(0xFF4CAF50);     // Lighter green for dark mode
  static const Color darkAccentGreen = Color(0xFF66BB6A);     // Even lighter green
  static const Color darkBackground = Color(0xFF0A0A0A);      // Very dark background
  static const Color darkSurface = Color(0xFF1A1A1A);        // Dark surface
  static const Color darkCard = Color(0xFF2A2A2A);           // Dark card background
  static const Color darkOnSurface = Color(0xFFE0E0E0);      // Light text on dark
  static const Color darkSecondaryText = Color(0xFFB0B0B0);  // Secondary text on dark
  static const Color darkBorder = Color(0xFF404040);         // Dark borders
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),  // Primary green
    Color(0xFF4CAF50),  // Light green
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFF6F00),  // Orange
    Color(0xFFFFB74D),  // Light orange
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFFF1F8E9),  // Very light green
    Color(0xFFFFF3E0),  // Very light orange
  ];

  // Text Styles with Kannada Font
  static const TextStyle kannadaHeading = TextStyle(
    fontFamily: 'NotoSansKannada',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: onSurface,
  );

  static const TextStyle kannadaSubheading = TextStyle(
    fontFamily: 'NotoSansKannada',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  static const TextStyle kannadaBody = TextStyle(
    fontFamily: 'NotoSansKannada',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: onSurface,
  );

  static const TextStyle kannadaCaption = TextStyle(
    fontFamily: 'NotoSansKannada',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: secondaryText,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: kannadaHeading.copyWith(
          color: Colors.white,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryGreen,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: kannadaHeading,
        headlineMedium: kannadaSubheading,
        bodyLarge: kannadaBody,
        bodyMedium: kannadaBody.copyWith(fontSize: 14),
        bodySmall: kannadaCaption,
        labelLarge: kannadaBody.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          textStyle: kannadaBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: kannadaBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: primaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryText),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryText),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorRed),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: kannadaBody.copyWith(color: secondaryText),
        labelStyle: kannadaBody.copyWith(color: secondaryText),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),

      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkGreen,
        contentTextStyle: kannadaBody.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: secondaryText.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryGreen,
        brightness: Brightness.dark,
        background: darkBackground,
        surface: darkSurface,
        onSurface: darkOnSurface,
      ),
      scaffoldBackgroundColor: darkBackground,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkPrimaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: kannadaHeading.copyWith(
          color: Colors.white,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimaryGreen,
        unselectedItemColor: darkSecondaryText,
        type: BottomNavigationBarType.fixed,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Text Theme
      textTheme: TextTheme(
        headlineLarge: kannadaHeading.copyWith(color: darkOnSurface),
        headlineMedium: kannadaSubheading.copyWith(color: darkOnSurface),
        bodyLarge: kannadaBody.copyWith(color: darkOnSurface),
        bodyMedium: kannadaBody.copyWith(color: darkOnSurface, fontSize: 14),
        bodySmall: kannadaCaption.copyWith(color: darkSecondaryText),
        labelLarge: kannadaBody.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryGreen,
          foregroundColor: Colors.white,
          textStyle: kannadaBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimaryGreen,
          textStyle: kannadaBody.copyWith(
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(color: darkPrimaryGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkPrimaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorRed),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: kannadaBody.copyWith(color: darkSecondaryText),
        labelStyle: kannadaBody.copyWith(color: darkSecondaryText),
        fillColor: darkSurface,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),

      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkPrimaryGreen,
        contentTextStyle: kannadaBody.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
    );
  }

  // Custom Chat Bubble Decorations
  static BoxDecoration userMessageDecoration = BoxDecoration(
    color: primaryGreen,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(4),
    ),
  );

  static BoxDecoration assistantMessageDecoration = BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(4),
      bottomRight: Radius.circular(16),
    ),
  );

  // Voice Recording Animation Colors
  static const List<Color> recordingColors = [
    primaryGreen,
    lightGreen,
    accentOrange,
  ];
}
