import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/models/game_stats.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/game_mode_toggle.dart';
import '../models/daily_five_state.dart';
import '../providers/daily_five_provider.dart';

/// Win/Lose result modal shown after game completion.
class ResultModal extends ConsumerWidget {
  final GameMode mode;

  const ResultModal({super.key, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(dailyFiveProvider(mode));
    final stats = ref.watch(dailyFiveStatsProvider);
    final won = game.phase == GamePhase.won;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.surfaceContainerLow
            : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Text(
              game.isComplete
                  ? (won ? 'Brilliant!' : 'Another word awaits')
                  : 'Daily Five statistics',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            if (game.phase == GamePhase.lost) ...[
              SizedBox(height: 6),
              Text(
                'The word was ${game.answer}',
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(height: 24),

            // ── Stats Row ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatChip(label: 'Played', value: '${stats.gamesPlayed}'),
                _StatChip(
                  label: 'Win %',
                  value: '${stats.winPercentage.round()}',
                ),
                _StatChip(
                  label: 'Streak',
                  value: '${stats.currentStreak}',
                  icon: stats.currentStreak > 0 ? '🔥' : null,
                ),
                _StatChip(label: 'Best', value: '${stats.maxStreak}'),
              ],
            ),
            SizedBox(height: 24),

            // ── Distribution ─────────────────────────────────────────────
            _DistributionChart(
              stats: stats,
              lastGuess: won ? game.currentRow : null,
            ),
            SizedBox(height: 24),

            // ── Actions ──────────────────────────────────────────────────
            OutlinedButton.icon(
              icon: Icon(Icons.share_rounded, size: 20),
              label: Text('Share Result'),
              onPressed: !game.isComplete
                  ? null
                  : () {
                      final text = ref
                          .read(dailyFiveProvider(mode).notifier)
                          .buildShareString();
                      Share.share(text);
                    },
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String? icon;

  const _StatChip({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Text(icon!, style: TextStyle(fontSize: 18)),
              SizedBox(width: 2),
            ],
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DistributionChart extends StatelessWidget {
  final GameStats stats;
  final int? lastGuess; // highlight this row

  const _DistributionChart({required this.stats, this.lastGuess});

  @override
  Widget build(BuildContext context) {
    final maxVal = stats.distribution.values.fold(0, (a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guess Distribution',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8),
        ...List.generate(DailyFiveState.maxGuesses, (i) {
          final count = stats.distribution[i + 1] ?? 0;
          final isHighlight = lastGuess == i + 1;
          final fraction = maxVal == 0 ? 0.0 : count / maxVal;
          return Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  child: Text(
                    '${i + 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth = (fraction * constraints.maxWidth).clamp(
                        28.0,
                        constraints.maxWidth,
                      );
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        width: barWidth,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isHighlight
                              ? AppColors.correct
                              : AppColors.absentLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
