import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';

// controls light, dark or system theme
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.light;
  }

  void setThemeMode(ThemeMode value) {
    state = value;
  }
}

// controls the selected app accent colour
class AccentColorNotifier extends Notifier<Color> {
  @override
  Color build() {
    return AppTheme.accentPresets['Indigo']!;
  }

  void setAccentColor(Color value) {
    state = value;
  }
}

// stores the selected language preference
class LanguageNotifier extends Notifier<String> {
  @override
  String build() {
    return 'English';
  }

  void setLanguage(String value) {
    state = value;
  }
}

// light / dark / system
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

// selected app colour theme
final accentColorProvider =
    NotifierProvider<AccentColorNotifier, Color>(
  AccentColorNotifier.new,
);

// selected language preference
final languageProvider =
    NotifierProvider<LanguageNotifier, String>(
  LanguageNotifier.new,
);