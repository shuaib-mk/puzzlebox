import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/game_mode_toggle.dart';
import '../models/letter_state.dart';
import '../providers/daily_five_provider.dart';

const _rows = [
  ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
  ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
];

/// On-screen QWERTY keyboard with per-letter colour feedback.
class KeyboardWidget extends ConsumerWidget {
  final GameMode mode;

  const KeyboardWidget({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(dailyFiveProvider(mode));
    final hapticsOn = ref.watch(
      settingsProvider.select((s) => s.hapticsEnabled),
    );
    final soundOn = ref.watch(settingsProvider.select((s) => s.soundEnabled));

    void onKey(String key) {
      if (hapticsOn) HapticFeedback.lightImpact();
      if (soundOn) SystemSound.play(SystemSoundType.click);
      if (key == '⌫') {
        ref.read(dailyFiveProvider(mode).notifier).deleteLetter();
      } else if (key == 'ENTER') {
        ref.read(dailyFiveProvider(mode).notifier).submitGuess();
      } else {
        ref.read(dailyFiveProvider(mode).notifier).addLetter(key);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _rows.map((row) {
          return Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final state = game.keyStates[key.toLowerCase()];
                return Expanded(
                  flex: key == 'ENTER' || key == '⌫' ? 15 : 10,
                  child: _KeyButton(
                    label: key,
                    state: state,
                    onTap: () => onKey(key),
                    isWide: key == 'ENTER' || key == '⌫',
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String label;
  final LetterState? state;
  final VoidCallback onTap;
  final bool isWide;

  const _KeyButton({
    required this.label,
    required this.state,
    required this.onTap,
    this.isWide = false,
  });

  Color _bg(BuildContext context, bool isDark) {
    switch (state) {
      case LetterState.correct:
        return AppColors.correct;
      case LetterState.present:
        return isDark ? AppColors.present : AppColors.presentLight;
      case LetterState.absent:
        return isDark ? AppColors.absent : AppColors.absentLight;
      default:
        return isDark
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.secondaryContainer;
    }
  }

  Color _fg(BuildContext context, bool isDark) {
    if (state == LetterState.correct ||
        state == LetterState.present ||
        state == LetterState.absent) {
      return Colors.white;
    }
    return isDark
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = isWide ? 58.0 : 36.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 3),
        width: w,
        height: 56,
        decoration: BoxDecoration(
          color: _bg(context, isDark),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: label == 'ENTER' ? 11 : 16,
              fontWeight: FontWeight.w700,
              color: _fg(context, isDark),
            ),
          ),
        ),
      ),
    );
  }
}
