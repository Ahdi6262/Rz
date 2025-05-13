import 'package:flutter/material.dart';

// Primary color for the app
const Color primaryColor = Color(0xFF6200EE);
const Color secondaryColor = Color(0xFF03DAC6);
const Color errorColor = Color(0xFFCF6679);

// Dark theme colors
const Color darkBackgroundColor = Color(0xFF121212);
const Color darkSurfaceColor = Color(0xFF1E1E1E);
const Color darkTextColor = Color(0xFFEFEFFF);
const Color darkSecondaryTextColor = Color(0xFFB0B0B0);
const Color darkDividerColor = Color(0xFF2C2C2C);

// Light theme colors (not used in this MVP, but defined for future use)
const Color lightBackgroundColor = Color(0xFFFAFAFA);
const Color lightSurfaceColor = Color(0xFFFFFFFF);
const Color lightTextColor = Color(0xFF1E1E1E);
const Color lightSecondaryTextColor = Color(0xFF757575);
const Color lightDividerColor = Color(0xFFE0E0E0);

// Color scheme for dark theme
final ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: primaryColor,
  onPrimary: Colors.white,
  secondary: secondaryColor,
  onSecondary: Colors.black,
  error: errorColor,
  onError: Colors.white,
  background: darkBackgroundColor,
  onBackground: darkTextColor,
  surface: darkSurfaceColor,
  onSurface: darkTextColor,
);

// Color scheme for light theme (not used in this MVP, but defined for future use)
final ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: primaryColor,
  onPrimary: Colors.white,
  secondary: secondaryColor,
  onSecondary: Colors.black,
  error: errorColor,
  onError: Colors.white,
  background: lightBackgroundColor,
  onBackground: lightTextColor,
  surface: lightSurfaceColor,
  onSurface: lightTextColor,
);

// Animation durations
const Duration fastAnimationDuration = Duration(milliseconds: 200);
const Duration normalAnimationDuration = Duration(milliseconds: 300);
const Duration slowAnimationDuration = Duration(milliseconds: 500);

// Border radius values
const double smallBorderRadius = 4.0;
const double defaultBorderRadius = 8.0;
const double largeBorderRadius = 16.0;
const double xlargeBorderRadius = 24.0;

// Padding and margin values
const double smallSpacing = 4.0;
const double defaultSpacing = 8.0;
const double mediumSpacing = 16.0;
const double largeSpacing = 24.0;
const double xlargeSpacing = 32.0;
const double xxlargeSpacing = 48.0;

// Tab indicator color
const Color activeTabColor = Color(0xFFF1F1F1);
