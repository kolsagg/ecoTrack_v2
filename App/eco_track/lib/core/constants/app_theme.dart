import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_constants.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
        primary: AppConstants.primaryColor,
        secondary: AppConstants.secondaryColor,
        surface: AppConstants.surfaceColor,
        error: AppConstants.errorColor,
        onPrimary: AppConstants.textOnPrimaryColor,
        onSecondary: AppConstants.textOnPrimaryColor,
        onSurface: AppConstants.textPrimaryColor,
        onError: AppConstants.textOnPrimaryColor,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.textOnPrimaryColor,
        elevation: AppConstants.elevationMedium,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppConstants.textOnPrimaryColor,
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: AppConstants.fontWeightMedium,
          fontFamily: AppConstants.fontFamily,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppConstants.cardColor,
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.spacingSmall),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.textOnPrimaryColor,
          elevation: AppConstants.elevationMedium,
          minimumSize: const Size(
            double.infinity,
            AppConstants.buttonHeightLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          ),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeRegular,
            fontWeight: AppConstants.fontWeightMedium,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          minimumSize: const Size(
            double.infinity,
            AppConstants.buttonHeightLarge,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          ),
          side: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeRegular,
            fontWeight: AppConstants.fontWeightMedium,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeRegular,
            fontWeight: AppConstants.fontWeightMedium,
            fontFamily: AppConstants.fontFamily,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: BorderSide(
            color: AppConstants.textHintColor.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: BorderSide(
            color: AppConstants.textHintColor.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: const BorderSide(
            color: AppConstants.primaryColor,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: const BorderSide(
            color: AppConstants.errorColor,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          borderSide: const BorderSide(
            color: AppConstants.errorColor,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingMedium,
        ),
        hintStyle: const TextStyle(
          color: AppConstants.textHintColor,
          fontSize: AppConstants.fontSizeRegular,
          fontFamily: AppConstants.fontFamily,
        ),
        labelStyle: const TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: AppConstants.fontSizeRegular,
          fontFamily: AppConstants.fontFamily,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.surfaceColor,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: AppConstants.elevationMedium,
        selectedLabelStyle: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: AppConstants.fontWeightMedium,
          fontFamily: AppConstants.fontFamily,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: AppConstants.fontWeightRegular,
          fontFamily: AppConstants.fontFamily,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.textOnPrimaryColor,
        elevation: AppConstants.elevationMedium,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConstants.fontSizeHeadline,
          fontWeight: AppConstants.fontWeightBold,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        displayMedium: TextStyle(
          fontSize: AppConstants.fontSizeTitle,
          fontWeight: AppConstants.fontWeightBold,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        displaySmall: TextStyle(
          fontSize: AppConstants.fontSizeXXLarge,
          fontWeight: AppConstants.fontWeightSemiBold,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        headlineLarge: TextStyle(
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: AppConstants.fontWeightSemiBold,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        headlineMedium: TextStyle(
          fontSize: AppConstants.fontSizeLarge,
          fontWeight: AppConstants.fontWeightMedium,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        headlineSmall: TextStyle(
          fontSize: AppConstants.fontSizeRegular,
          fontWeight: AppConstants.fontWeightMedium,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.fontSizeRegular,
          fontWeight: AppConstants.fontWeightRegular,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: AppConstants.fontWeightRegular,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        bodySmall: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: AppConstants.fontWeightRegular,
          color: AppConstants.textSecondaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        labelLarge: TextStyle(
          fontSize: AppConstants.fontSizeRegular,
          fontWeight: AppConstants.fontWeightMedium,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        labelMedium: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: AppConstants.fontWeightMedium,
          color: AppConstants.textSecondaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        labelSmall: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: AppConstants.fontWeightMedium,
          color: AppConstants.textSecondaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppConstants.textSecondaryColor,
        size: AppConstants.iconSizeMedium,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: AppConstants.textOnPrimaryColor,
        size: AppConstants.iconSizeMedium,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppConstants.textHintColor.withValues(alpha: 0.2),
        thickness: 1.0,
        space: 1.0,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeRegular,
          fontWeight: AppConstants.fontWeightMedium,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: AppConstants.fontWeightRegular,
          color: AppConstants.textSecondaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppConstants.backgroundColor,
        selectedColor: AppConstants.primaryLightColor,
        labelStyle: const TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          fontWeight: AppConstants.fontWeightMedium,
          color: AppConstants.textPrimaryColor,
          fontFamily: AppConstants.fontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusCircular,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
      ),
    );
  }

  // Dark Theme (Future implementation)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      // Dark theme will be implemented later
    );
  }
}
