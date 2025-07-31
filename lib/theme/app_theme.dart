import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the school transportation application.
class AppTheme {
  AppTheme._();

  // Color specifications based on Trusted Transit Blue theme
  static const Color primaryLight = Color(0xFF1565C0); // Deep educational blue
  static const Color primaryVariantLight =
      Color(0xFF0D47A1); // Darker blue variant
  static const Color secondaryLight = Color(0xFF2E7D32); // Safety green
  static const Color secondaryVariantLight =
      Color(0xFF1B5E20); // Darker green variant
  static const Color accentLight = Color(0xFFFF8F00); // Attention amber
  static const Color backgroundLight = Color(0xFFFAFAFA); // Warm off-white
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white
  static const Color errorLight = Color(0xFFD32F2F); // Clear error red
  static const Color warningLight = Color(0xFFF57C00); // Moderate orange
  static const Color successLight = Color(0xFF388E3C); // Confirmation green
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onBackgroundLight =
      Color(0xFF212121); // High-contrast dark gray
  static const Color onSurfaceLight = Color(0xFF212121);
  static const Color onErrorLight = Color(0xFFFFFFFF);

  // Dark theme colors
  static const Color primaryDark =
      Color(0xFF42A5F5); // Lighter blue for dark theme
  static const Color primaryVariantDark = Color(0xFF1976D2);
  static const Color secondaryDark =
      Color(0xFF66BB6A); // Lighter green for dark theme
  static const Color secondaryVariantDark = Color(0xFF4CAF50);
  static const Color accentDark =
      Color(0xFFFFB74D); // Softer amber for dark theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color warningDark = Color(0xFFFF9800);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryDark = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF000000);

  // Card and dialog colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D2D);
  static const Color dialogLight = Color(0xFFFFFFFF);
  static const Color dialogDark = Color(0xFF2D2D2D);

  // Shadow colors for elevation system
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x1AFFFFFF);

  // Divider and border colors
  static const Color dividerLight = Color(0xFFE0E0E0); // Minimal borders
  static const Color dividerDark = Color(0xFF424242);

  // Text colors with proper emphasis levels
  static const Color textPrimaryLight =
      Color(0xFF212121); // High-contrast dark gray
  static const Color textSecondaryLight = Color(0xFF757575); // Medium gray
  static const Color textDisabledLight = Color(0xFFBDBDBD); // Light gray

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);

  /// Light theme optimized for school transportation app
  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: primaryLight,
          onPrimary: onPrimaryLight,
          primaryContainer: primaryVariantLight,
          onPrimaryContainer: onPrimaryLight,
          secondary: secondaryLight,
          onSecondary: onSecondaryLight,
          secondaryContainer: secondaryVariantLight,
          onSecondaryContainer: onSecondaryLight,
          tertiary: accentLight,
          onTertiary: Color(0xFFFFFFFF),
          tertiaryContainer: accentLight.withValues(alpha: 0.1),
          onTertiaryContainer: accentLight,
          error: errorLight,
          onError: onErrorLight,
          surface: surfaceLight,
          onSurface: onSurfaceLight,
          onSurfaceVariant: textSecondaryLight,
          outline: dividerLight,
          outlineVariant: dividerLight.withValues(alpha: 0.5),
          shadow: shadowLight,
          scrim: shadowLight,
          inverseSurface: surfaceDark,
          onInverseSurface: onSurfaceDark,
          inversePrimary: primaryDark),
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      dividerColor: dividerLight,

      // AppBar theme for institutional credibility
      appBarTheme: AppBarTheme(
          backgroundColor: primaryLight,
          foregroundColor: onPrimaryLight,
          elevation: 2.0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w600, color: onPrimaryLight),
          iconTheme: IconThemeData(color: onPrimaryLight)),

      // Card theme for glanceable status cards - Fixed for Flutter 3.10+
      cardTheme: CardThemeData(
          color: cardLight,
          elevation: 2.0,
          shadowColor: shadowLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          clipBehavior: Clip.antiAlias,
          surfaceTintColor: Colors.transparent),

      // Bottom navigation for adaptive navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceLight,
          selectedItemColor: primaryLight,
          unselectedItemColor: textSecondaryLight,
          type: BottomNavigationBarType.fixed,
          elevation: 8.0),

      // FAB theme for contextual actions
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryLight,
          foregroundColor: onPrimaryLight,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0))),

      // Button themes for trust-building interactions
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: onPrimaryLight,
              backgroundColor: primaryLight,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryLight,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: primaryLight, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryLight,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w500))),

      // Typography using Inter font family
      textTheme: _buildTextTheme(isLight: true),

      // Input decoration for form elements
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceLight,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: dividerLight)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: dividerLight)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: primaryLight, width: 2.0)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: errorLight)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: errorLight, width: 2.0)),
          labelStyle:
              GoogleFonts.inter(color: textSecondaryLight, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textDisabledLight, fontSize: 16, fontWeight: FontWeight.w400),
          prefixIconColor: textSecondaryLight,
          suffixIconColor: textSecondaryLight),

      // Switch theme for settings
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return Color(0xFFBDBDBD);
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight.withValues(alpha: 0.5);
        }
        return Color(0xFFE0E0E0);
      })),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryLight;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(onPrimaryLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),

      // Radio theme
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryLight;
        }
        return textSecondaryLight;
      })),

      // Progress indicator theme
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryLight, linearTrackColor: primaryLight.withValues(alpha: 0.2), circularTrackColor: primaryLight.withValues(alpha: 0.2)),

      // Slider theme
      sliderTheme: SliderThemeData(activeTrackColor: primaryLight, thumbColor: primaryLight, overlayColor: primaryLight.withValues(alpha: 0.2), inactiveTrackColor: primaryLight.withValues(alpha: 0.3), trackHeight: 4.0),

      // Tab bar theme - Fixed for Flutter 3.10+
      tabBarTheme: TabBarThemeData( 
        labelColor: primaryLight,
        unselectedLabelColor: textSecondaryLight,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryLight, width: 2.0),
          insets: EdgeInsets.symmetric(horizontal: 8.0),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        dividerColor: dividerLight,
        dividerHeight: 1.0,
        labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
        tabAlignment: TabAlignment.center,
        overlayColor:
            WidgetStateProperty.all(primaryLight.withValues(alpha: 0.1)),
        splashFactory: InkRipple.splashFactory,
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      ),

      // Tooltip theme
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: onSurfaceLight.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), textStyle: GoogleFonts.inter(color: surfaceLight, fontSize: 12, fontWeight: FontWeight.w400), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),

      // SnackBar theme for feedback
      snackBarTheme: SnackBarThemeData(backgroundColor: onSurfaceLight, contentTextStyle: GoogleFonts.inter(color: surfaceLight, fontSize: 14, fontWeight: FontWeight.w400), actionTextColor: accentLight, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),

      // List tile theme for progressive disclosure
      listTileTheme: ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), tileColor: surfaceLight, selectedTileColor: primaryLight.withValues(alpha: 0.1), iconColor: textSecondaryLight, textColor: textPrimaryLight),

      // Divider theme
      dividerTheme: DividerThemeData(color: dividerLight, thickness: 1.0, space: 1.0),
      dialogTheme: DialogThemeData(backgroundColor: dialogLight));

  /// Dark theme optimized for school transportation app
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: primaryDark,
          onPrimary: onPrimaryDark,
          primaryContainer: primaryVariantDark,
          onPrimaryContainer: onPrimaryDark,
          secondary: secondaryDark,
          onSecondary: onSecondaryDark,
          secondaryContainer: secondaryVariantDark,
          onSecondaryContainer: onSecondaryDark,
          tertiary: accentDark,
          onTertiary: Color(0xFF000000),
          tertiaryContainer: accentDark.withValues(alpha: 0.2),
          onTertiaryContainer: accentDark,
          error: errorDark,
          onError: onErrorDark,
          surface: surfaceDark,
          onSurface: onSurfaceDark,
          onSurfaceVariant: textSecondaryDark,
          outline: dividerDark,
          outlineVariant: dividerDark.withValues(alpha: 0.5),
          shadow: shadowDark,
          scrim: shadowDark,
          inverseSurface: surfaceLight,
          onInverseSurface: onSurfaceLight,
          inversePrimary: primaryLight),
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      dividerColor: dividerDark,

      // AppBar theme for dark mode
      appBarTheme: AppBarTheme(
          backgroundColor: surfaceDark,
          foregroundColor: onSurfaceDark,
          elevation: 2.0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w600, color: onSurfaceDark),
          iconTheme: IconThemeData(color: onSurfaceDark)),

      // Card theme for dark mode - Fixed for Flutter 3.10+
      cardTheme: CardThemeData(
          color: cardDark,
          elevation: 2.0,
          shadowColor: shadowDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          clipBehavior: Clip.antiAlias,
          surfaceTintColor: Colors.transparent),

      // Bottom navigation for dark mode
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryDark,
          unselectedItemColor: textSecondaryDark,
          type: BottomNavigationBarType.fixed,
          elevation: 8.0),

      // FAB theme for dark mode
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryDark,
          foregroundColor: onPrimaryDark,
          elevation: 4.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0))),

      // Button themes for dark mode
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              foregroundColor: onPrimaryDark,
              backgroundColor: primaryDark,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              foregroundColor: primaryDark,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              side: BorderSide(color: primaryDark, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w500))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: primaryDark,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              textStyle: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w500))),

      // Typography for dark mode
      textTheme: _buildTextTheme(isLight: false),

      // Input decoration for dark mode
      inputDecorationTheme: InputDecorationTheme(
          fillColor: surfaceDark,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: dividerDark)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: dividerDark)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: primaryDark, width: 2.0)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: errorDark)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: errorDark, width: 2.0)),
          labelStyle:
              GoogleFonts.inter(color: textSecondaryDark, fontSize: 16, fontWeight: FontWeight.w400),
          hintStyle: GoogleFonts.inter(color: textDisabledDark, fontSize: 16, fontWeight: FontWeight.w400),
          prefixIconColor: textSecondaryDark,
          suffixIconColor: textSecondaryDark),

      // Switch theme for dark mode
      switchTheme: SwitchThemeData(thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return Color(0xFF616161);
      }), trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark.withValues(alpha: 0.5);
        }
        return Color(0xFF424242);
      })),

      // Checkbox theme for dark mode
      checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryDark;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(onPrimaryDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),

      // Radio theme for dark mode
      radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryDark;
        }
        return textSecondaryDark;
      })),

      // Progress indicator theme for dark mode
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primaryDark, linearTrackColor: primaryDark.withValues(alpha: 0.2), circularTrackColor: primaryDark.withValues(alpha: 0.2)),

      // Slider theme for dark mode
      sliderTheme: SliderThemeData(activeTrackColor: primaryDark, thumbColor: primaryDark, overlayColor: primaryDark.withValues(alpha: 0.2), inactiveTrackColor: primaryDark.withValues(alpha: 0.3), trackHeight: 4.0),

      // Tab bar theme for dark mode - Fixed for Flutter 3.10+
      tabBarTheme: TabBarThemeData( 
        labelColor: primaryDark,
        unselectedLabelColor: textSecondaryDark,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: primaryDark, width: 2.0),
          insets: EdgeInsets.symmetric(horizontal: 8.0),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
        dividerColor: dividerDark,
        dividerHeight: 1.0,
        labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
        tabAlignment: TabAlignment.center,
        overlayColor:
            WidgetStateProperty.all(primaryDark.withValues(alpha: 0.1)),
        splashFactory: InkRipple.splashFactory,
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      ),

      // Tooltip theme for dark mode
      tooltipTheme: TooltipThemeData(decoration: BoxDecoration(color: onSurfaceDark.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), textStyle: GoogleFonts.inter(color: surfaceDark, fontSize: 12, fontWeight: FontWeight.w400), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),

      // SnackBar theme for dark mode
      snackBarTheme: SnackBarThemeData(backgroundColor: onSurfaceDark, contentTextStyle: GoogleFonts.inter(color: surfaceDark, fontSize: 14, fontWeight: FontWeight.w400), actionTextColor: accentDark, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0))),

      // List tile theme for dark mode
      listTileTheme: ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), tileColor: surfaceDark, selectedTileColor: primaryDark.withValues(alpha: 0.1), iconColor: textSecondaryDark, textColor: textPrimaryDark),

      // Divider theme for dark mode
      dividerTheme: DividerThemeData(color: dividerDark, thickness: 1.0, space: 1.0),
      dialogTheme: DialogThemeData(backgroundColor: dialogDark));

  /// Helper method to build text theme using Inter font family
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textPrimary = isLight ? textPrimaryLight : textPrimaryDark;
    final Color textSecondary =
        isLight ? textSecondaryLight : textSecondaryDark;
    final Color textDisabled = isLight ? textDisabledLight : textDisabledDark;

    return TextTheme(
        // Display styles for large headings
        displayLarge: GoogleFonts.inter(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.25),
        displayMedium: GoogleFonts.inter(
            fontSize: 45, fontWeight: FontWeight.w700, color: textPrimary),
        displaySmall: GoogleFonts.inter(
            fontSize: 36, fontWeight: FontWeight.w600, color: textPrimary),

        // Headline styles for section headers
        headlineLarge: GoogleFonts.inter(
            fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary),
        headlineMedium: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary),

        // Title styles for card headers and important text
        titleLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0),
        titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.15),
        titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.1),

        // Body styles for main content
        bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            letterSpacing: 0.5),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            letterSpacing: 0.25),
        bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            letterSpacing: 0.4),

        // Label styles for buttons and small text
        labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
            letterSpacing: 0.1),
        labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
            letterSpacing: 0.5),
        labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textDisabled,
            letterSpacing: 0.5));
  }

  /// Helper method to get data text style using JetBrains Mono
  static TextStyle getDataTextStyle({
    required bool isLight,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    final Color textColor = isLight ? textPrimaryLight : textPrimaryDark;
    return GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
        letterSpacing: 0);
  }

  /// Helper method to get success color based on theme
  static Color getSuccessColor(bool isLight) {
    return isLight ? successLight : successDark;
  }

  /// Helper method to get warning color based on theme
  static Color getWarningColor(bool isLight) {
    return isLight ? warningLight : warningDark;
  }

  /// Helper method to get accent color based on theme
  static Color getAccentColor(bool isLight) {
    return isLight ? accentLight : accentDark;
  }
}
