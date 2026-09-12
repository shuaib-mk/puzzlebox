import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/widgets/game_mode_toggle.dart';
import '../../core/mixins/practice_mode_mixin.dart';

class Domino {
  final int top;
  final int bottom;

  Domino(this.top, this.bottom);
}

class PipsScreen extends ConsumerStatefulWidget {
  const PipsScreen({super.key});

  @override
  ConsumerState<PipsScreen> createState() => _PipsScreenState();
}

class _PipsScreenState extends ConsumerState<PipsScreen>
    with PracticeModeMixin {
  @override
  String get gameType => 'pips';

  late List<int> _targets;
  final List<Map<int, Domino>> _history = [];
  late List<Domino> _availableDominoes;
  Domino? _selectedDomino;
  final Map<int, Domino> _gridSlots = {};
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    initPracticeMode();
    _loadPipsPuzzle();
  }

  @override
  void onPracticeModeChanged(GameMode mode) {
    _loadPipsPuzzle();
  }

  @override
  void loadDailyPuzzle() {
    _loadPipsPuzzle();
  }

  @override
  void loadPracticePuzzle() {
    _loadPipsPuzzle();
  }

  void _loadPipsPuzzle() {
    final rand = Random(puzzleSeed());
    final count = difficulty == 'Easy'
        ? 4
        : difficulty == 'Medium'
        ? 6
        : 8;
    _availableDominoes = List.generate(
      count,
      (_) => Domino(rand.nextInt(7), rand.nextInt(7)),
    );
    _targets = _availableDominoes.map((d) => d.top + d.bottom).toList()
      ..shuffle(rand);
    _availableDominoes.shuffle(rand);
    _history.clear();
    _selectedDomino = null;
    _gridSlots.clear();
    _isSolved = false;
    startSession();
    setState(() {});
  }

  void _onSlotTap(int index) {
    if (_isSolved) return;
    _history.add(Map<int, Domino>.from(_gridSlots));
    if (_selectedDomino == null && _gridSlots.containsKey(index)) {
      setState(() {
        _selectedDomino = _gridSlots.remove(index);
      });
      return;
    }
    if (_selectedDomino != null) {
      setState(() {
        _gridSlots[index] = _selectedDomino!;
        _selectedDomino = null;
      });
      _checkCompletion();
    }
  }

  void _checkCompletion() {
    if (_gridSlots.length == _availableDominoes.length &&
        _gridSlots.entries.every(
          (e) => e.value.top + e.value.bottom == _targets[e.key],
        )) {
      setState(() => _isSolved = true);

      if (mode == GameMode.daily) {
        ref
            .read(statsServiceProvider)
            .recordResult(gameType: 'pips', todayKey: dailyDateKey, won: true);
        _showResultDialog();
      } else {
        recordPracticeWin();
      }
    }
  }

  void _showResultDialog() {
    finishPuzzle();
  }

  @override
  Map<String, dynamic> captureProgress() => _isSolved
      ? {}
      : {
          'slots': _gridSlots.map(
            (k, v) => MapEntry('$k', _availableDominoes.indexOf(v)),
          ),
        };
  @override
  void restoreProgress(Map<String, dynamic> d) {
    for (final e in (d['slots'] as Map).entries) {
      _gridSlots[int.parse(e.key)] = _availableDominoes[e.value as int];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: mode == GameMode.daily ? 'Pips Logic' : 'Pips Logic — Unlimited',
      showBackButton: true,
      body: Column(
        children: [
          buildPracticeModeToggle(),
          Divider(height: 1),

          Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Match each domino to a target sum. Tap a placed domino to pick it up.',
            ),
          ),
          Wrap(
            spacing: 12,
            children: [
              TextButton.icon(
                icon: Icon(Icons.lightbulb_outline),
                label: Text('Hint'),
                onPressed: () {
                  final empty = List.generate(
                    _targets.length,
                    (i) => i,
                  ).where((i) => !_gridSlots.containsKey(i)).toList();
                  if (empty.isEmpty) {
                    showPuzzleHint(
                      'Check each placed domino: its two halves must add to the target.',
                    );
                    return;
                  }
                  final target = _targets[empty.first];
                  final matches = _availableDominoes
                      .where((d) => d.top + d.bottom == target)
                      .toList();
                  showPuzzleHint(
                    'Slot ${empty.first + 1} needs $target. Use ${matches.first.top} + ${matches.first.bottom}.',
                  );
                },
              ),
              TextButton.icon(
                icon: Icon(Icons.undo),
                label: Text('Undo'),
                onPressed: () {
                  if (_history.isEmpty || _isSolved) return;
                  setState(() {
                    _gridSlots.clear();
                    _gridSlots.addAll(_history.removeLast());
                    _selectedDomino = null;
                  });
                },
              ),
            ],
          ),

          // Domino Target Grid (2x2)
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _targets.length,
                itemBuilder: (context, index) {
                  final domino = _gridSlots[index];
                  return GestureDetector(
                    key: ValueKey('pips_slot_$index'),
                    onTap: () => _onSlotTap(index),
                    child: AnimatedContainer(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Target: ${_targets[index]}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: domino != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _PipsDisplay(count: domino.top),
                                      Divider(
                                        height: 16,
                                        indent: 20,
                                        endIndent: 20,
                                      ),
                                      _PipsDisplay(count: domino.bottom),
                                    ],
                                  )
                                : Center(
                                    child: Text(
                                      'Tap to Place',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          if (shouldShowNextButton(_isSolved))
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.arrow_forward_rounded),
                label: Text('Next Dominoes'),
                onPressed: nextPuzzle,
              ),
            ),

          // Available Domino Deck
          Text(
            'Available Domino Deck',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _availableDominoes.map((d) {
              final isSelected = _selectedDomino == d;
              final isPlaced = _gridSlots.containsValue(d);

              if (isPlaced) return SizedBox(width: 50);

              return GestureDetector(
                key: ValueKey('pips_domino_${_availableDominoes.indexOf(d)}'),
                onTap: () => setState(() => _selectedDomino = d),
                child: AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    '${d.top} | ${d.bottom}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _PipsDisplay extends StatelessWidget {
  final int count;
  const _PipsDisplay({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (_) => Container(
          margin: EdgeInsets.all(2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
