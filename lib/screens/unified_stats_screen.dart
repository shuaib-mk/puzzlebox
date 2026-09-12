import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/stats_service.dart';
import '../core/widgets/app_scaffold.dart';

class UnifiedStatsScreen extends ConsumerWidget {
  const UnifiedStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsService = ref.read(statsServiceProvider);

    final games = [
      {'type': 'daily_five', 'name': 'Daily Five', 'emoji': '🟩'},
      {'type': 'connections', 'name': 'Connections', 'emoji': '🟨'},
      {'type': 'spelling_bee', 'name': 'Spelling Bee', 'emoji': '🐝'},
      {'type': 'crossword', 'name': 'The Crossword', 'emoji': '📰'},
      {'type': 'strands', 'name': 'Strands', 'emoji': '🔦'},
      {'type': 'sudoku', 'name': 'Sudoku', 'emoji': '🔢'},
      {'type': 'pips', 'name': 'Pips', 'emoji': '🎲'},
      {'type': 'tiles', 'name': 'Tiles', 'emoji': '🧱'},
    ];

    int totalPlayed = 0;
    int totalWon = 0;
    int maxStreakAcrossAll = 0;

    for (final g in games) {
      final st = statsService.loadStats(g['type']!);
      totalPlayed += st.gamesPlayed.toInt();
      totalWon += st.gamesWon.toInt();
      if (st.maxStreak > maxStreakAcrossAll) {
        maxStreakAcrossAll = st.maxStreak;
      }
    }

    final winPercent = totalPlayed == 0
        ? 0
        : ((totalWon / totalPlayed) * 100).round();

    return AppScaffold(
      title: 'Unified Statistics',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Played',
                    value: '$totalPlayed',
                    icon: Icons.extension_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Win %',
                    value: '$winPercent%',
                    icon: Icons.emoji_events_outlined,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Best Streak',
                    value: '$maxStreakAcrossAll',
                    icon: Icons.local_fire_department_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: 28),
            Text(
              'GAME BREAKDOWN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16),

            ...games.map((g) {
              final st = statsService.loadStats(g['type']!);
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Text(g['emoji']!, style: TextStyle(fontSize: 24)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g['name']!,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Played: ${st.gamesPlayed}  •  Streak: 🔥 ${st.currentStreak}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${st.winPercentage.round()}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
