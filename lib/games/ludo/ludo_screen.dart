import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/services/practice_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/pressable_scale.dart';
import 'logic/ludo_engine.dart';
import 'models/ludo_token.dart';
import 'widgets/ludo_board_widget.dart';
import 'widgets/dice_widget.dart';

class LudoScreen extends ConsumerStatefulWidget {
  const LudoScreen({super.key});

  @override
  ConsumerState<LudoScreen> createState() => _LudoScreenState();
}

class _LudoScreenState extends ConsumerState<LudoScreen> {
  int _playerCount = 4;
  bool _vsAI = true;
  late LudoEngine _engine;
  bool _isRollingDice = false;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _engine = LudoEngine(playerCount: _playerCount, vsAI: _vsAI);
    _isRollingDice = false;
    _checkAITurn();
  }

  Future<void> _onRollDice() async {
    if (_engine.hasRolledDice || _engine.isGameOver || _isRollingDice) return;
    if (_engine.currentPlayer.isAI) return;

    setState(() => _isRollingDice = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _engine.rollDice();
      _isRollingDice = false;
    });

    _checkAITurn();
  }

  void _onTokenTap(LudoToken token) {
    if (!_engine.hasRolledDice || _engine.isGameOver) return;
    if (_engine.currentPlayer.isAI) return;

    setState(() {
      final moved = _engine.moveToken(token);
      if (moved && _engine.isGameOver) {
        _recordWin();
        _showVictoryDialog();
      }
    });

    _checkAITurn();
  }

  Future<void> _checkAITurn() async {
    if (!mounted || _engine.isGameOver) return;
    if (!_engine.currentPlayer.isAI) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || _engine.isGameOver || !_engine.currentPlayer.isAI) return;

    // AI rolls dice if not rolled yet
    if (!_engine.hasRolledDice) {
      setState(() => _isRollingDice = true);
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      setState(() {
        _engine.rollDice();
        _isRollingDice = false;
      });

      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
    }

    // AI moves token if dice was rolled
    if (_engine.hasRolledDice) {
      final aiToken = _engine.chooseAITokenMove();
      if (aiToken != null) {
        setState(() {
          final moved = _engine.moveToken(aiToken);
          if (moved && _engine.isGameOver) {
            _recordWin();
            _showVictoryDialog();
          }
        });
      }
    }

    if (mounted) setState(() {});

    // Recurse if next turn is ALSO AI
    if (mounted && !_engine.isGameOver && _engine.currentPlayer.isAI) {
      _checkAITurn();
    }
  }

  Future<void> _recordWin() async {
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    await ref.read(statsServiceProvider).recordResult(
          gameType: 'ludo',
          todayKey: todayKey,
          won: _engine.winner?.isAI == false,
        );
    await ref.read(practiceServiceProvider).incrementSolvedCount('ludo');
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final winner = _engine.winner;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Game Over!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 64),
              const SizedBox(height: 12),
              Text(
                '${winner?.name ?? "Player"} wins the match!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: winner?.displayColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _startNewGame());
              },
              child: const Text('Play Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: const Text('Home'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final currentPlayer = _engine.currentPlayer;
    final moveableTokens = _engine.getMovableTokens();

    String statusText = 'Tap dice to roll';
    if (_engine.hasRolledDice) {
      if (moveableTokens.isEmpty) {
        statusText = 'No legal moves for ${_engine.lastDiceRoll}';
      } else {
        statusText = 'Select a glowing token';
      }
    } else if (currentPlayer.isAI) {
      statusText = 'AI is thinking...';
    }

    return AppScaffold(
      title: 'Ludo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Mode & Player Count Selectors (Responsive Wrap)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Mode: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    FilterChip(
                      label: Text(_vsAI ? 'Vs AI' : 'Pass & Play'),
                      selected: _vsAI,
                      onSelected: (val) {
                        setState(() {
                          _vsAI = val;
                          _startNewGame();
                        });
                      },
                    ),
                  ],
                ),
                DropdownButton<int>(
                  value: _playerCount,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _playerCount = val;
                        _startNewGame();
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2 Players')),
                    DropdownMenuItem(value: 3, child: Text('3 Players')),
                    DropdownMenuItem(value: 4, child: Text('4 Players')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Turn Indicator Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: currentPlayer.displayColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: currentPlayer.displayColor, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentPlayer.displayColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${currentPlayer.name}\'s Turn',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ludo Board Widget
            LudoBoardWidget(
              engine: _engine,
              moveableTokens: moveableTokens,
              onTokenTap: _onTokenTap,
            ),

            const SizedBox(height: 16),

            // Dice & Actions Control Row (Responsive Wrap)
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DiceWidget(
                  diceValue: _engine.lastDiceRoll,
                  isRolling: _isRollingDice,
                  canRoll: !_engine.hasRolledDice &&
                      !_engine.isGameOver &&
                      !currentPlayer.isAI,
                  playerColor: currentPlayer.displayColor,
                  onRoll: _onRollDice,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _engine.lastDiceRoll > 0
                          ? 'Rolled: ${_engine.lastDiceRoll}'
                          : 'Roll the dice',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _engine.hasRolledDice ? 'Tap a token' : 'Tap dice to roll',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                PressableScale(
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Restart Game',
                    onPressed: () => setState(() => _startNewGame()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
