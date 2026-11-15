import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyumba_mtaani/providers/theme_provider.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LanguageNotifier(prefs);
});

class LanguageNotifier extends StateNotifier<String> {
  final SharedPreferences? _prefs;
  static const _key = 'selected_language';

  LanguageNotifier(this._prefs) : super(_loadInitialLanguage(_prefs));

  static String _loadInitialLanguage(SharedPreferences? prefs) {
    if (prefs == null) return 'en';
    return prefs.getString(_key) ?? 'en';
  }

  void setLanguage(String languageCode) {
    state = languageCode;
    if (_prefs != null) {
      _prefs!.setString(_key, languageCode);
    }
  }

  bool get isSwahili => state == 'sw';
}
