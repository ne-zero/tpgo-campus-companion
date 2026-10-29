import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// main colour and typography system for tp go
class AppTheme {
  static const Color lightBackground =
      Color(0xFFF5F7FC);

  static const Color lightSurface =
      Colors.white;

  static const Color lightText =
      Color(0xFF080C3F);

  static const Color lightMutedText =
      Color(0xFF59607F);

  // dark mode uses navy instead of pure black
  static const Color darkBackground =
      Color(0xFF0D1424);

  static const Color darkSurface =
      Color(0xFF172136);

  static const Color darkSurfaceAlt =
      Color(0xFF202B43);

  static const Color darkText =
      Color(0xFFF5F7FF);

  static const Color darkMutedText =
      Color(0xFFB2BCD4);

  static const Color darkBorder =
      Color(0xFF303B55);

  // colour themes users can choose
  static const Map<String, Color> accentPresets = {
    'Indigo': Color(0xFF2637FF),
    'Violet': Color(0xFF6B3DFF),
    'Emerald': Color(0xFF0F9D58),
    'Sunset': Color(0xFFE8590C),
    'Rose': Color(0xFFD6336C),
  };

  static TextTheme _buildTextTheme(
    Color primaryText,
    Color secondaryText,
  ) {
    final headingFont =
        GoogleFonts.plusJakartaSansTextTheme();

    final bodyFont =
        GoogleFonts.interTextTheme();

    return TextTheme(
      displayLarge:
          headingFont.displayLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: primaryText,
      ),
      headlineLarge:
          headingFont.headlineLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: primaryText,
      ),
      headlineMedium:
          headingFont.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: primaryText,
      ),
      headlineSmall:
          headingFont.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: primaryText,
      ),
      titleLarge:
          headingFont.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: primaryText,
      ),
      titleMedium:
          headingFont.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      titleSmall:
          headingFont.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
      bodyLarge:
          bodyFont.bodyLarge?.copyWith(
        color: primaryText,
      ),
      bodyMedium:
          bodyFont.bodyMedium?.copyWith(
        color: secondaryText,
      ),
      bodySmall:
          bodyFont.bodySmall?.copyWith(
        color: secondaryText,
      ),
      labelLarge:
          bodyFont.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: primaryText,
      ),
    );
  }

  // light theme
  static ThemeData lightTheme(
    Color accentColor,
  ) {
    final baseScheme =
        ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
    );

    final colorScheme =
        baseScheme.copyWith(
      primary: accentColor,
      surface: lightSurface,
      surfaceContainer:
          const Color(0xFFF0F2F8),
      surfaceContainerHighest:
          const Color(0xFFE9ECF5),
      onSurface: lightText,
      onSurfaceVariant:
          lightMutedText,
      outline:
          const Color(0xFFD6DBE8),
      outlineVariant:
          const Color(0xFFE6E9F2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      scaffoldBackgroundColor:
          lightBackground,

      colorScheme: colorScheme,

      textTheme: _buildTextTheme(
        lightText,
        lightMutedText,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor:
            lightBackground,
        foregroundColor:
            lightText,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            GoogleFonts.plusJakartaSans(
          fontWeight:
              FontWeight.w900,
          fontSize: 20,
          color: lightText,
        ),
      ),

      cardTheme:
          const CardThemeData(
        color: lightSurface,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
      ),

      dialogTheme:
          const DialogThemeData(
        backgroundColor:
            lightSurface,
        surfaceTintColor:
            Colors.transparent,
      ),

      bottomSheetTheme:
          const BottomSheetThemeData(
        backgroundColor:
            lightSurface,
        modalBackgroundColor:
            lightSurface,
        surfaceTintColor:
            Colors.transparent,
      ),

      dividerTheme:
          const DividerThemeData(
        color:
            Color(0xFFE6E9F2),
        thickness: 1,
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            const Color(0xFFF4F6FA),

        hintStyle:
            const TextStyle(
          color:
              Color(0xFF9299AE),
        ),

        labelStyle:
            const TextStyle(
          color: lightMutedText,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(0xFFDCE1EC),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              BorderSide(
            color: accentColor,
            width: 1.6,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color: Colors.red,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              accentColor,
          foregroundColor:
              Colors.white,
          textStyle:
              GoogleFonts
                  .plusJakartaSans(
            fontWeight:
                FontWeight.w800,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          foregroundColor:
              accentColor,
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              accentColor,
          side: BorderSide(
            color: accentColor,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),

      switchTheme:
          SwitchThemeData(
        thumbColor:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return accentColor;
            }

            return null;
          },
        ),
        trackColor:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return accentColor
                  .withValues(
                alpha: 0.35,
              );
            }

            return null;
          },
        ),
      ),

      progressIndicatorTheme:
          ProgressIndicatorThemeData(
        color: accentColor,
      ),

      floatingActionButtonTheme:
          FloatingActionButtonThemeData(
        backgroundColor:
            accentColor,
        foregroundColor:
            Colors.white,
      ),

      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(
        backgroundColor:
            Colors.transparent,
        selectedItemColor:
            accentColor,
        unselectedItemColor:
            const Color(
          0xFF9299AE,
        ),
        selectedIconTheme:
            const IconThemeData(
          size: 25,
        ),
        unselectedIconTheme:
            const IconThemeData(
          size: 23,
        ),
        selectedLabelStyle:
            const TextStyle(
          fontWeight:
              FontWeight.w800,
          fontSize: 11,
        ),
        unselectedLabelStyle:
            const TextStyle(
          fontWeight:
              FontWeight.w600,
          fontSize: 10.5,
        ),
      ),

      navigationBarTheme:
          NavigationBarThemeData(
        backgroundColor:
            Colors.white,
        indicatorColor:
            accentColor.withValues(
          alpha: 0.12,
        ),
        iconTheme:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return IconThemeData(
                color: accentColor,
              );
            }

            return const IconThemeData(
              color:
                  Color(0xFF9299AE),
            );
          },
        ),
      ),

      chipTheme:
          ChipThemeData(
        selectedColor:
            accentColor.withValues(
          alpha: 0.15,
        ),
        checkmarkColor:
            accentColor,
        side: BorderSide(
          color:
              colorScheme.outlineVariant,
        ),
      ),
    );
  }

  // dark theme
  static ThemeData darkTheme(
    Color accentColor,
  ) {
    final baseScheme =
        ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
    );

    final colorScheme =
        baseScheme.copyWith(
      // selected colour now works in dark mode too
      primary: accentColor,

      surface:
          darkSurface,

      surfaceContainer:
          darkSurfaceAlt,

      surfaceContainerHighest:
          const Color(
        0xFF28344F,
      ),

      onSurface:
          darkText,

      onSurfaceVariant:
          darkMutedText,

      outline:
          const Color(
        0xFF46516B,
      ),

      outlineVariant:
          darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness:
          Brightness.dark,

      scaffoldBackgroundColor:
          darkBackground,

      colorScheme:
          colorScheme,

      textTheme:
          _buildTextTheme(
        darkText,
        darkMutedText,
      ),

      dividerColor:
          darkBorder,

      appBarTheme:
          AppBarTheme(
        backgroundColor:
            darkBackground,
        foregroundColor:
            darkText,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            GoogleFonts
                .plusJakartaSans(
          fontWeight:
              FontWeight.w900,
          fontSize: 20,
          color: darkText,
        ),
      ),

      cardTheme:
          const CardThemeData(
        color: darkSurface,
        surfaceTintColor:
            Colors.transparent,
        elevation: 0,
      ),

      dialogTheme:
          const DialogThemeData(
        backgroundColor:
            darkSurface,
        surfaceTintColor:
            Colors.transparent,
        titleTextStyle:
            TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight:
              FontWeight.w900,
        ),
        contentTextStyle:
            TextStyle(
          color:
              darkMutedText,
          fontSize: 14,
          height: 1.4,
        ),
      ),

      bottomSheetTheme:
          const BottomSheetThemeData(
        backgroundColor:
            darkSurface,
        modalBackgroundColor:
            darkSurface,
        surfaceTintColor:
            Colors.transparent,
      ),

      dividerTheme:
          const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor:
            darkSurfaceAlt,

        hintStyle:
            const TextStyle(
          color:
              Color(0xFF8E99B3),
        ),

        labelStyle:
            const TextStyle(
          color:
              darkMutedText,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                darkBorder,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              BorderSide(
            // uses selected colour
            color: accentColor,
            width: 1.6,
          ),
        ),

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(0xFFFF6B6B),
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
          // uses selected colour
          backgroundColor:
              accentColor,
          foregroundColor:
              Colors.white,
          textStyle:
              GoogleFonts
                  .plusJakartaSans(
            fontWeight:
                FontWeight.w800,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),

      textButtonTheme:
          TextButtonThemeData(
        style:
            TextButton.styleFrom(
          foregroundColor:
              accentColor,
        ),
      ),

      outlinedButtonTheme:
          OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              accentColor,
          side: BorderSide(
            color: accentColor,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),

      switchTheme:
          SwitchThemeData(
        thumbColor:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return accentColor;
            }

            return null;
          },
        ),

        trackColor:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return accentColor
                  .withValues(
                alpha: 0.35,
              );
            }

            return null;
          },
        ),
      ),

      progressIndicatorTheme:
          ProgressIndicatorThemeData(
        color: accentColor,
      ),

      floatingActionButtonTheme:
          FloatingActionButtonThemeData(
        backgroundColor:
            accentColor,
        foregroundColor:
            Colors.white,
      ),

      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(
        backgroundColor:
            Colors.transparent,

        // selected nav follows colour theme
        selectedItemColor:
            accentColor,

        unselectedItemColor:
            const Color(
          0xFF8994AE,
        ),

        selectedIconTheme:
            const IconThemeData(
          size: 25,
        ),

        unselectedIconTheme:
            const IconThemeData(
          size: 23,
        ),

        selectedLabelStyle:
            const TextStyle(
          fontWeight:
              FontWeight.w800,
          fontSize: 11,
        ),

        unselectedLabelStyle:
            const TextStyle(
          fontWeight:
              FontWeight.w600,
          fontSize: 10.5,
        ),
      ),

      navigationBarTheme:
          NavigationBarThemeData(
        backgroundColor:
            darkSurface,

        indicatorColor:
            accentColor.withValues(
          alpha: 0.22,
        ),

        iconTheme:
            WidgetStateProperty
                .resolveWith(
          (states) {
            if (states.contains(
              WidgetState.selected,
            )) {
              return IconThemeData(
                color:
                    accentColor,
              );
            }

            return const IconThemeData(
              color:
                  Color(0xFF8994AE),
            );
          },
        ),
      ),

      chipTheme:
          ChipThemeData(
        backgroundColor:
            darkSurfaceAlt,
        selectedColor:
            accentColor.withValues(
          alpha: 0.22,
        ),
        checkmarkColor:
            accentColor,
        labelStyle:
            const TextStyle(
          color:
              darkText,
        ),
        side:
            const BorderSide(
          color:
              darkBorder,
        ),
      ),
    );
  }
}