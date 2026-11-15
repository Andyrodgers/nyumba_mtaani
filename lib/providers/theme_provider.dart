import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences? _prefs;
  
  ThemeModeNotifier(this._prefs) : super(_loadInitialMode(_prefs));

  static const _key = 'theme_mode';

  static ThemeMode _loadInitialMode(SharedPreferences? prefs) {
    if (prefs == null) return ThemeMode.system;
    final savedMode = prefs.getString(_key);
    if (savedMode == 'light') return ThemeMode.light;
    if (savedMode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    if (_prefs != null) {
      await _prefs!.setString(_key, mode.name);
    }
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

/// Provider that extracts the ColorScheme from the app icon
final dynamicColorSchemeProvider = FutureProvider<ColorScheme>((ref) async {
  try {
    return await ColorScheme.fromImageProvider(
      provider: const AssetImage('assets/images/ic_nyumba.png'),
    );
  } catch (e) {
    return ColorScheme.fromSeed(seedColor: const Color(0xFF006D77));
  }
});
