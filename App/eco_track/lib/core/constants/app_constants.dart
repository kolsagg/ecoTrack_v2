import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'EcoTrack';
  static const String appVersion = '1.0.0';

  // Colors - Primary Palette (Green theme for eco-friendly app)
  static const Color primaryColor = Color(0xFF2E7D32); // #2E7D32 - Dark Green
  static const Color primaryLightColor = Color(
    0xFF4CAF50,
  ); // #4CAF50 - Light Green
  static const Color primaryDarkColor = Color(
    0xFF1B5E20,
  ); // #1B5E20 - Darker Green

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF2196F3); // #2196F3 - Blue
  static const Color accentColor = Color(
    0xFF64B5F6,
  ); // #64B5F6 - Light Blue Accent

  // Background Colors
  static const Color backgroundColor = Color(
    0xFFF5F5F5,
  ); // #F5F5F5 - Light Gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // #FFFFFF - White
  static const Color cardColor = Color(0xFFFFFFFF); // #FFFFFF - White

  // Text Colors
  static const Color textPrimaryColor = Color(
    0xFF212121,
  ); // #212121 - Dark Gray
  static const Color textSecondaryColor = Color(
    0xFF757575,
  ); // #757575 - Medium Gray
  static const Color textHintColor = Color(0xFF9E9E9E); // #9E9E9E - Light Gray
  static const Color textOnPrimaryColor = Color(0xFFFFFFFF); // #FFFFFF - White

  // Status Colors
  static const Color successColor = Color(0xFF4CAF50); // #4CAF50 - Green
  static const Color errorColor = Color(0xFFF44336); // #F44336 - Red
  static const Color warningColor = Color(0xFFFF9800); // #FF9800 - Orange
  static const Color infoColor = Color(0xFF2196F3); // #2196F3 - Blue

  // Chart Colors - Colors will be provided by backend as hex codes

  // Expense Category Colors
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFF4CAF50), // #4CAF50 - Green
    'transportation': Color(0xFF2196F3), // #2196F3 - Blue
    'entertainment': Color(0xFF9C27B0), // #9C27B0 - Purple
    'shopping': Color(0xFFE91E63), // #E91E63 - Pink
    'health': Color(0xFFF44336), // #F44336 - Red
    'education': Color(0xFF00BCD4), // #00BCD4 - Cyan
    'utilities': Color(0xFFFF9800), // #FF9800 - Orange
    'other': Color(0xFF757575), // #757575 - Gray
  };

  // Additional UI Colors
  static const Color dividerColor = Color(0xFFE0E0E0); // #E0E0E0 - Light Gray
  static const Color shadowColor = Color(
    0x1F000000,
  ); // #000000 with 12% opacity
  static const Color overlayColor = Color(
    0x80000000,
  ); // #000000 with 50% opacity
  static const Color disabledColor = Color(
    0xFFBDBDBD,
  ); // #BDBDBD - Disabled Gray
  static const Color focusColor = Color(0xFF64B5F6); // #64B5F6 - Focus Blue
  static const Color hoverColor = Color(
    0xFFF1F8E9,
  ); // #F1F8E9 - Hover Light Green

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF4CAF50), // #4CAF50 - Light Green
    Color(0xFF2E7D32), // #2E7D32 - Dark Green
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF64B5F6), // #64B5F6 - Light Blue
    Color(0xFF2196F3), // #2196F3 - Blue
  ];

  // Typography
  static const String fontFamily = 'Roboto';

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeRegular = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeTitle = 28.0;
  static const double fontSizeHeadline = 32.0;

  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  static const double borderRadiusCircular = 50.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationXHigh = 16.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  static const double buttonHeightXLarge = 56.0;

  // Input Field Heights
  static const double inputHeightSmall = 40.0;
  static const double inputHeightMedium = 48.0;
  static const double inputHeightLarge = 56.0;

  // App Bar Height
  static const double appBarHeight = 56.0;
  static const double appBarHeightLarge = 64.0;

  // Bottom Navigation Bar Height
  static const double bottomNavBarHeight = 60.0;

  // Card Properties
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 12.0;

  // Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Grid Properties
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 1.0;
  static const double gridSpacing = 16.0;

  // List Properties
  static const double listItemHeight = 72.0;
  static const double listItemPadding = 16.0;

  // Opacity Values
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.54;
  static const double opacityHigh = 0.87;

  // Z-Index Values
  static const int zIndexAppBar = 1000;
  static const int zIndexBottomNav = 1001;
  static const int zIndexFAB = 1002;
  static const int zIndexModal = 1100;
  static const int zIndexTooltip = 1200;

  // Hex Color Helper Methods
  static String getHexColor(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  // Convert hex string to Color (for backend hex codes)
  static Color hexToColor(String hexString) {
    // Remove # if present
    String hex = hexString.replaceFirst('#', '');

    // Add alpha channel if not present (6 chars = RGB, need ARGB)
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add full opacity
    }

    return Color(int.parse(hex, radix: 16));
  }

  // Chart color helper for backend hex codes
  static List<Color> parseChartColors(List<String> hexColors) {
    return hexColors.map((hex) => hexToColor(hex)).toList();
  }

  // Color Palette Documentation
  static const Map<String, String> colorPalette = {
    'Primary Dark Green': '#2E7D32',
    'Primary Light Green': '#4CAF50',
    'Primary Darker Green': '#1B5E20',
    'Secondary Blue': '#2196F3',
    'Accent Light Blue': '#64B5F6',
    'Background Light Gray': '#F5F5F5',
    'Surface White': '#FFFFFF',
    'Text Primary Dark Gray': '#212121',
    'Text Secondary Medium Gray': '#757575',
    'Text Hint Light Gray': '#9E9E9E',
    'Success Green': '#4CAF50',
    'Error Red': '#F44336',
    'Warning Orange': '#FF9800',
    'Info Blue': '#2196F3',
  };
}
