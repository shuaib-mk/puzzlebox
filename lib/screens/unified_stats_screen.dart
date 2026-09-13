import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/stats_service.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/services/practice_service.dart';
import '../core/services/engagement_service.dart';

class UnifiedStatsScreen extends ConsumerWidget {
  final bool embedded;
  const UnifiedStatsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsService = ref.read(statsServiceProvider);
    ref.watch(engagementRevisionProvider);
    final engagement = ref.read(engagementServiceProvider).load();
    final practice = ref.read(practiceServiceProvider);

    final games = [
      {'type': 'daily_five', 'name': 'Daily Five', 'emoji': '🟩'},
      {'type': 'connections', 'name': 'Connections', 'emoji': '🟨'},
      {'type': 'spelling_bee', 'name': 'Spelling Bee', 'emoji': '🐝'},
      {'type': 'crossword', 'name': 'The Crossword', 'emoji': '📰'},
      {'type': 'mini_crossword', 'name': 'The Mini', 'emoji': '✏️'},
      {'type': 'strands', 'name': 'Strands', 'emoji': '🔦'},
      {'type': 'sudoku', 'name': 'Sudoku', 'emoji': '🔢'},
      {'type': 'pips', 'name': 'Pips', 'emoji': '🎲'},
      {'type': 'tiles', 'name': 'Tiles', 'emoji': '🧱'},
      {'type': 'letter_boxed', 'name': 'Letter Boxed', 'emoji': '🔤'},
      {'type': 'vertex', 'name': 'Vertex', 'emoji': '🔗'},
    ];

    final content = SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your progress',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            engagement.currentStreak == 0
                ? 'Solve a puzzle today to start your streak.'
                : '🔥 ${engagement.currentStreak} day streak · Best ${engagement.bestStreak}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          // Header summary cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Solved',
                  value: '${engagement.totalCompleted}',
                  icon: Icons.extension_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Streak',
                  value: '${engagement.currentStreak}',
                  icon: Icons.local_fire_department_outlined,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Play time',
                  value: _time(engagement.totalSeconds),
                  icon: Icons.timer_outlined,
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
          Text(
            'ACHIEVEMENTS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Badge(
                icon: Icons.flag_rounded,
                title: 'First win',
                unlocked: engagement.totalCompleted >= 1,
              ),
              _Badge(
                icon: Icons.workspace_premium_rounded,
                title: 'Ten solved',
                unlocked: engagement.totalCompleted >= 10,
              ),
              _Badge(
                icon: Icons.local_fire_department_rounded,
                title: '7-day streak',
                unlocked: engagement.bestStreak >= 7,
              ),
              _Badge(
                icon: Icons.psychology_rounded,
                title: 'Hard earned',
                unlocked: engagement.hardWins >= 1,
              ),
            ],
          ),
          if (engagement.history.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'RECENT WINS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...engagement.history.reversed.take(5).map((item) {
              final game = games
                  .cast<Map<String, String>>()
                  .where((g) => g['type'] == item['game'])
                  .firstOrNull;
              final seconds = item['seconds'] as int? ?? 0;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(child: Icon(Icons.check_rounded)),
                title: Text(game?['name'] ?? item['game'] as String),
                subtitle: Text(
                  '${item['difficulty']} • ${seconds > 0 ? '${seconds}s' : 'Completed'}',
                ),
              );
            }),
          ],
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
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Daily ${st.gamesPlayed}  •  Unlimited ${practice.getSolvedCount(g['type']!)}',
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
    );
    if (embedded) return SafeArea(child: content);
    return AppScaffold(
      title: 'Statistics',
      showBackButton: true,
      body: content,
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool unlocked;
  const _Badge({
    required this.icon,
    required this.title,
    required this.unlocked,
  });
  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: unlocked ? 1 : .38,
    duration: const Duration(milliseconds: 250),
    child: Container(
      width: 102,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: unlocked
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

String _time(int seconds) {
  if (seconds < 60) return '${seconds}s';
  final minutes = seconds ~/ 60;
  return minutes < 60 ? '${minutes}m' : '${minutes ~/ 60}h ${minutes % 60}m';
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
