import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzlebox/core/providers/settings_provider.dart';
import 'package:puzzlebox/core/theme/app_theme.dart';
import 'package:puzzlebox/screens/home_screen.dart';
import 'package:puzzlebox/games/sudoku/sudoku_screen.dart';
import 'package:puzzlebox/games/connections/connections_screen.dart';
import 'package:puzzlebox/games/crossword/crossword_screen.dart';
import 'package:puzzlebox/games/strands/strands_screen.dart';
import 'package:puzzlebox/games/daily_five/logic/word_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Capture Puzzlebox appearance for visual review', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final loader = FontLoader('PuzzleSans')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/Nunito.ttf').readAsBytesSync(),
          ),
        ),
      );
    await loader.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    await tester.runAsync(WordList.init);
    final cases = <(String, Widget, int, Brightness)>[
      ('home-ocean', const HomeScreen(), 0, Brightness.light),
      ('home-orchard', const HomeScreen(), 1, Brightness.light),
      ('home-clay', const HomeScreen(), 2, Brightness.light),
      ('home-iris-dark', const HomeScreen(), 3, Brightness.dark),
      ('sudoku', const SudokuScreen(), 1, Brightness.light),
      ('connections', const ConnectionsScreen(), 2, Brightness.light),
      ('crossword', const CrosswordScreen(), 0, Brightness.light),
      ('strands', const StrandsScreen(), 3, Brightness.dark),
    ];
    for (final c in cases) {
      SharedPreferences.setMockInitialValues({'installation_puzzle_seed': 42});
      final prefs = await SharedPreferences.getInstance();
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.build(c.$4, c.$3),
              home: c.$2,
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('../previews/${c.$1}.png');
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }
  });
}
