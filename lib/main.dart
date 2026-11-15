import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyumba_mtaani/l10n/app_localizations.dart';
import 'package:nyumba_mtaani/config/theme/app_theme.dart';
import 'package:nyumba_mtaani/app/router.dart';
import 'package:nyumba_mtaani/providers/theme_provider.dart';
import 'package:nyumba_mtaani/providers/language_provider.dart';
import 'package:nyumba_mtaani/core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferences? prefs;
  try {
    await dotenv.load(fileName: ".env");
    
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );

    prefs = await SharedPreferences.getInstance();
  } catch (e, st) {
    AppLogger.error('Initialization error', e, st);
  }

  runApp(
    ProviderScope(
      overrides: [
        if (prefs != null) sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final localeCode = ref.watch(languageProvider);
    final dynamicScheme = ref.watch(dynamicColorSchemeProvider);

    return dynamicScheme.when(
      data: (colorScheme) => MaterialApp.router(
        title: 'Nyumba Mtaani',
        theme: AppTheme.themeData(colorScheme, Brightness.light),
        darkTheme: AppTheme.themeData(colorScheme, Brightness.dark),
        themeMode: themeMode,
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => MaterialApp.router(
        title: 'Nyumba Mtaani',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        locale: Locale(localeCode),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
