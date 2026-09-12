import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzlebox/core/providers/settings_provider.dart';
import 'package:puzzlebox/core/services/practice_service.dart';
import 'package:puzzlebox/core/services/puzzle_progression.dart';
import 'package:puzzlebox/core/theme/app_theme.dart';
import 'package:puzzlebox/games/pips/pips_screen.dart';

void main() {
  testWidgets(
    'Pips validates sums, records one win and advances automatically',
    (tester) async {
      tester.view.physicalSize = const Size(500, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'difficulty_pips': 'Easy',
        'installation_puzzle_seed': 42,
      });
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(theme: AppTheme.light, home: const PipsScreen()),
        ),
      );
      await tester.pump();
      final strings = tester
          .widgetList<Text>(find.byType(Text))
          .map((w) => w.data ?? '')
          .toList();
      final targets = strings
          .where((s) => s.startsWith('Target: '))
          .map((s) => int.parse(s.substring(8)))
          .toList();
      final dominoes = strings
          .where((s) => RegExp(r'^\d \| \d$').hasMatch(s))
          .map((s) => int.parse(s[0]) + int.parse(s[4]))
          .toList();
      expect(targets.length, 4);
      expect(dominoes.length, 4);
      final used = <int>{};
      for (var slot = 0; slot < 4; slot++) {
        final tile = List.generate(
          4,
          (i) => i,
        ).firstWhere((i) => !used.contains(i) && dominoes[i] == targets[slot]);
        used.add(tile);
        await tester.tap(find.byKey(ValueKey('pips_domino_$tile')));
        await tester.pump();
        await tester.tap(find.byKey(ValueKey('pips_slot_$slot')));
        await tester.pump();
        if (slot < 3) expect(PracticeService(prefs).getSolvedCount('pips'), 0);
      }
      await tester.pump();
      expect(PracticeService(prefs).getSolvedCount('pips'), 1);
      await tester.tap(find.byKey(const ValueKey('pips_slot_3')));
      await tester.pump();
      expect(PracticeService(prefs).getSolvedCount('pips'), 1);
      expect(PuzzleProgression(prefs).index('pips'), 1);
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pump();

      expect(PuzzleProgression(prefs).index('pips'), 1);
      expect(
        tester
            .widgetList<Text>(find.byType(Text))
            .where((w) => RegExp(r'^\d \| \d$').hasMatch(w.data ?? ''))
            .length,
        4,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
