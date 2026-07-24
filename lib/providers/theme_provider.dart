import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers.dart';

const String _themeKey = 'rumour_isDarkMode';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs)
      : super(
          _prefs.getBool(_themeKey) == false
              ? ThemeMode.light
              : ThemeMode.dark,
        );

  bool get isDark => state == ThemeMode.dark;

  Future<void> toggle() async {
    final next = isDark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    await _prefs.setBool(_themeKey, next == ThemeMode.dark);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.read(sharedPreferencesProvider));
});
