import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'games/daily_five/logic/word_list.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Nunito',
    ], await rootBundle.loadString('assets/fonts/Nunito-OFL.txt'));
    yield LicenseEntryWithLineBreaks([
      'English word list (dwyl)',
    ], await rootBundle.loadString('assets/words/english-LICENSE.md'));
  });

  // Load word lists before the app starts
  await WordList.init();

  // Initialise SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const PuzzleboxApp(),
    ),
  );
}

class PuzzleboxApp extends ConsumerWidget {
  const PuzzleboxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Puzzlebox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light, settings.palette),
      darkTheme: AppTheme.build(Brightness.dark, settings.palette),
      themeMode: settings.themeMode,
      home: const HomeScreen(),
    );
  }
}
