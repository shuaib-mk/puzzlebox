import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/stats_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/game_mode_toggle.dart';
import '../../core/mixins/practice_mode_mixin.dart';

class TileItem {
  final int id;
  final String shape;
  final Color color;

  TileItem(this.id, this.shape, this.color);
}

class TilesScreen extends ConsumerStatefulWidget {
  const TilesScreen({super.key});

  @override
  ConsumerState<TilesScreen> createState() => _TilesScreenState();
}

class _TilesScreenState extends ConsumerState<TilesScreen>
    with PracticeModeMixin {
  @override
  String get gameType => 'tiles';

  int _roundCount = 1;
  int _comboChain = 0;
  int _score = 0;

  TileItem? _firstSelected;
  late List<TileItem> _tiles;

  @override
  void initState() {
    super.initState();
    initPracticeMode();
    _loadTiles();
  }

  @override
  void onPracticeModeChanged(GameMode mode) {
    _resetGame();
  }

  @override
  void loadDailyPuzzle() {
    _resetGame();
  }

  @override
  void loadPracticePuzzle() {
    _resetGame();
  }

  void _loadTiles() {
    final rand = Random(puzzleSeed());
    final shapes = ['◆', '●', '▲', '■', '★', '⬟', '✦', '✚', '◎', '◇', '△', '□']
      ..shuffle(rand);
    final count = difficulty == 'Easy'
        ? 4
        : difficulty == 'Medium'
        ? 6
        : 9;
    _tiles = [
      for (var i = 0; i < count; i++)
        for (var j = 0; j < 2; j++) TileItem(i * 2 + j, shapes[i], Colors.blue),
    ]..shuffle(rand);
    _firstSelected = null;
    startSession();
  }

  void _onTileTap(TileItem item) {
    setState(() {
      if (_firstSelected == null) {
        _firstSelected = item;
      } else {
        if (_firstSelected!.id != item.id &&
            _firstSelected!.shape == item.shape) {
          // Match!
          _comboChain++;
          _score += 100 * _comboChain;
          _tiles.removeWhere(
            (t) => t.id == _firstSelected!.id || t.id == item.id,
          );
          _firstSelected = null;

          if (_tiles.isEmpty) {
            if (mode == GameMode.daily && _roundCount == 1) {
              ref
                  .read(statsServiceProvider)
                  .recordResult(
                    gameType: 'tiles',
                    todayKey: dailyDateKey,
                    won: true,
                  );
            } else if (mode == GameMode.practice) {
              recordPracticeWin();
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Tiles Cleared! Round $_roundCount Complete! 🎉'),
              ),
            );

            if (mode == GameMode.daily) finishPuzzle();
          }
        } else {
          // Reset chain
          _comboChain = 0;
          _firstSelected = null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chain broken!'),
              duration: Duration(milliseconds: 800),
            ),
          );
        }
      }
    });
  }

  void _resetGame() {
    setState(() {
      _roundCount = 1;
      _score = 0;
      _comboChain = 0;
      _loadTiles();
    });
  }

  @override
  Map<String, dynamic> captureProgress() => _tiles.isEmpty
      ? {}
      : {
          'remaining': _tiles.map((t) => t.id).toList(),
          'score': _score,
          'combo': _comboChain,
        };
  @override
  void restoreProgress(Map<String, dynamic> d) {
    _tiles.removeWhere((t) => !(d['remaining'] as List).contains(t.id));
    _score = d['score'] as int;
    _comboChain = d['combo'] as int;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: mode == GameMode.daily
          ? 'Tiles Pattern Match'
          : 'Tiles Pattern Match — Unlimited',
      showBackButton: true,
      actions: [
        IconButton(
          icon: Icon(Icons.lightbulb_outline),
          tooltip: 'Hint',
          onPressed: () {
            if (_tiles.isEmpty) return;
            final shape = _firstSelected?.shape ?? _tiles.first.shape;
            final positions = _tiles
                .asMap()
                .entries
                .where((e) => e.value.shape == shape)
                .map((e) => e.key + 1);
            showPuzzleHint(
              'Match $shape at positions ${positions.join(" and ")} (reading left to right).',
            );
          },
        ),
      ],
      body: Column(
        children: [
          buildPracticeModeToggle(),
          Divider(height: 1),

          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Score, Chain & Round Banner
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Text(
                      'Round $_roundCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Score: $_score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Combo: 🔥 ${_comboChain}x',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.present,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tiles Grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: _tiles.isNotEmpty
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _tiles.length,
                      itemBuilder: (context, index) {
                        final tile = _tiles[index];
                        final isSelected = _firstSelected?.id == tile.id;

                        return GestureDetector(
                          onTap: () => _onTileTap(tile),
                          child: AnimatedContainer(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 160),
                            curve: Curves.easeOutCubic,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                tile.shape,
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Preparing Next Round...',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
