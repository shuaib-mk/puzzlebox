import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chess/chess.dart' as chess_lib;
import '../../core/widgets/app_scaffold.dart';
import '../../core/services/practice_service.dart';
import '../../core/services/stats_service.dart';
import '../../core/widgets/pressable_scale.dart';
import 'models/chess_puzzle.dart';
import 'logic/chess_puzzles_data.dart';
import 'logic/chess_ai.dart';
import 'widgets/chess_board_widget.dart';
import 'widgets/pawn_promotion_dialog.dart';

enum ChessGameMode { dailyPuzzle, vsAI, passAndPlay }

class ChessScreen extends ConsumerStatefulWidget {
  const ChessScreen({super.key});

  @override
  ConsumerState<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends ConsumerState<ChessScreen> {
  ChessGameMode _mode = ChessGameMode.dailyPuzzle;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;

  late chess_lib.Chess _game;
  String? _selectedSquare;
  List<String> _validMoves = [];
  Map<String, String>? _lastMove;
  bool _isFlipped = false;
  final List<String> _fenHistory = [];

  // Daily puzzle state
  late ChessPuzzle _currentPuzzle;
  int _currentPuzzleIndex = 0;
  int _puzzleStepIndex = 0;
  bool _puzzleCompleted = false;

  @override
  void initState() {
    super.initState();
    _startDailyPuzzle();
  }

  void _startDailyPuzzle() {
    final now = DateTime.now();
    _currentPuzzleIndex = now.difference(DateTime(2026, 1, 1)).inDays;
    if (_currentPuzzleIndex < 0) _currentPuzzleIndex = 0;
    _loadPuzzle(ChessPuzzlesData.getPuzzleAtIndex(_currentPuzzleIndex));
  }

  void _startNextPuzzle() {
    _currentPuzzleIndex++;
    _loadPuzzle(ChessPuzzlesData.getPuzzleAtIndex(_currentPuzzleIndex));
  }

  void _loadPuzzle(ChessPuzzle puzzle) {
    _currentPuzzle = puzzle;
    _game = chess_lib.Chess.fromFEN(_currentPuzzle.fen);
    _selectedSquare = null;
    _validMoves = [];
    _lastMove = null;
    _isFlipped = (_game.turn == chess_lib.Color.BLACK);
    _puzzleStepIndex = 0;
    _puzzleCompleted = false;
    _fenHistory.clear();
    _fenHistory.add(_game.fen);
  }

  void _startVsAIGame() {
    _game = chess_lib.Chess();
    _selectedSquare = null;
    _validMoves = [];
    _lastMove = null;
    _isFlipped = false;
    _puzzleCompleted = false;
    _fenHistory.clear();
    _fenHistory.add(_game.fen);

    if (_isFlipped && _game.turn == chess_lib.Color.WHITE) {
      _makeAIMove();
    }
  }

  void _startPassAndPlayGame() {
    _game = chess_lib.Chess();
    _selectedSquare = null;
    _validMoves = [];
    _lastMove = null;
    _isFlipped = false;
    _puzzleCompleted = false;
    _fenHistory.clear();
    _fenHistory.add(_game.fen);
  }

  /// Calculates missing White pieces on current board (captured White pieces)
  String _getCapturedWhiteText() {
    final Map<String, int> initialCount = {'p': 8, 'n': 2, 'b': 2, 'r': 2, 'q': 1};
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    for (int rank = 1; rank <= 8; rank++) {
      for (final file in files) {
        final p = _game.get('$file$rank');
        if (p != null && p.color == chess_lib.Color.WHITE) {
          final t = p.type.name.toLowerCase();
          if (initialCount.containsKey(t) && initialCount[t]! > 0) {
            initialCount[t] = initialCount[t]! - 1;
          }
        }
      }
    }
    final List<String> captured = [];
    final symbols = {'p': '♙', 'n': '♘', 'b': '♗', 'r': '♖', 'q': '♕'};
    initialCount.forEach((t, missing) {
      for (int i = 0; i < missing; i++) {
        captured.add(symbols[t]!);
      }
    });
    return captured.join(' ');
  }

  /// Calculates missing Black pieces on current board (captured Black pieces)
  String _getCapturedBlackText() {
    final Map<String, int> initialCount = {'p': 8, 'n': 2, 'b': 2, 'r': 2, 'q': 1};
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
    for (int rank = 1; rank <= 8; rank++) {
      for (final file in files) {
        final p = _game.get('$file$rank');
        if (p != null && p.color == chess_lib.Color.BLACK) {
          final t = p.type.name.toLowerCase();
          if (initialCount.containsKey(t) && initialCount[t]! > 0) {
            initialCount[t] = initialCount[t]! - 1;
          }
        }
      }
    }
    final List<String> captured = [];
    final symbols = {'p': '♟', 'n': '♞', 'b': '♝', 'r': '♜', 'q': '♛'};
    initialCount.forEach((t, missing) {
      for (int i = 0; i < missing; i++) {
        captured.add(symbols[t]!);
      }
    });
    return captured.join(' ');
  }

  void _onSquareTap(String square) {
    if (_puzzleCompleted || _game.in_checkmate || _game.in_stalemate) return;

    if (_mode == ChessGameMode.vsAI) {
      final isPlayerTurn = (_isFlipped && _game.turn == chess_lib.Color.BLACK) ||
          (!_isFlipped && _game.turn == chess_lib.Color.WHITE);
      if (!isPlayerTurn) return;
    }

    // Deselect if tapping same square
    if (_selectedSquare == square) {
      setState(() {
        _selectedSquare = null;
        _validMoves = [];
      });
      return;
    }

    // Execute move if destination is valid
    if (_selectedSquare != null && _validMoves.contains(square)) {
      _executeMove(_selectedSquare!, square);
      return;
    }

    // Select piece on square if matching turn
    final piece = _game.get(square);
    if (piece != null && piece.color == _game.turn) {
      final List<chess_lib.Move> allLegalMoves =
          _game.generate_moves({'verbose': true});
      final validDestinations = <String>[];
      for (final m in allLegalMoves) {
        if (chess_lib.Chess.algebraic(m.from) == square) {
          validDestinations.add(chess_lib.Chess.algebraic(m.to));
        }
      }

      setState(() {
        _selectedSquare = square;
        _validMoves = validDestinations;
      });
    } else {
      setState(() {
        _selectedSquare = null;
        _validMoves = [];
      });
    }
  }

  Future<void> _executeMove(String from, String to) async {
    final piece = _game.get(from);
    final isPawn = piece?.type == chess_lib.PieceType.PAWN;
    final isPromotionRank = (piece?.color == chess_lib.Color.WHITE && to.endsWith('8')) ||
        (piece?.color == chess_lib.Color.BLACK && to.endsWith('1'));

    String? promotionPiece;
    if (isPawn && isPromotionRank) {
      promotionPiece = await PawnPromotionDialog.show(
        context,
        piece?.color == chess_lib.Color.WHITE,
      );
      if (promotionPiece == null) return;
    }

    // Find native legal Move object
    final List<chess_lib.Move> legalMoves = _game.generate_moves({'verbose': true});
    chess_lib.Move? targetMove;
    for (final m in legalMoves) {
      final fromAlg = chess_lib.Chess.algebraic(m.from);
      final toAlg = chess_lib.Chess.algebraic(m.to);
      if (fromAlg == from && toAlg == to) {
        if (promotionPiece != null) {
          if (m.promotion?.name.toLowerCase() == promotionPiece.toLowerCase()) {
            targetMove = m;
            break;
          }
        } else {
          targetMove = m;
          break;
        }
      }
    }

    if (targetMove == null) return;

    final sanMove = _game.move_to_san(targetMove);

    // Make native move
    _game.make_move(targetMove);
    _fenHistory.add(_game.fen);

    _lastMove = {'from': from, 'to': to};
    _selectedSquare = null;
    _validMoves = [];

    if (_mode == ChessGameMode.dailyPuzzle) {
      _handleDailyPuzzleMove(sanMove);
    } else if (_mode == ChessGameMode.vsAI) {
      setState(() {});
      _checkEndState();
      if (!_game.in_checkmate && !_game.in_stalemate && !_game.in_draw) {
        Future.delayed(const Duration(milliseconds: 350), _makeAIMove);
      }
    } else {
      setState(() {});
      _checkEndState();
    }
  }

  void _handleDailyPuzzleMove(String playedSan) {
    final expectedSan = _currentPuzzle.solutionMoves[_puzzleStepIndex];

    if (playedSan == expectedSan || _matchSanBase(playedSan, expectedSan)) {
      _puzzleStepIndex++;
      setState(() {});

      if (_puzzleStepIndex >= _currentPuzzle.solutionMoves.length) {
        _puzzleCompleted = true;
        _recordPuzzleWin();
        _showVictoryDialog('Puzzle Solved!', 'Great tactics! You solved puzzle #${_currentPuzzleIndex + 1}.');
      } else {
        // Play opponent response move automatically
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          final responseSan = _currentPuzzle.solutionMoves[_puzzleStepIndex];
          _game.move(responseSan);
          _fenHistory.add(_game.fen);
          _puzzleStepIndex++;
          _lastMove = null;
          setState(() {});
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not the best move! Resetting board...'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _loadPuzzle(_currentPuzzle));
      });
    }
  }

  bool _matchSanBase(String a, String b) {
    final cleanA = a.replaceAll('#', '').replaceAll('+', '');
    final cleanB = b.replaceAll('#', '').replaceAll('+', '');
    return cleanA == cleanB;
  }

  void _makeAIMove() {
    if (!mounted || _game.in_checkmate || _game.in_stalemate) return;
    final bestMove = ChessAI.getBestMove(_game, _aiDifficulty);
    if (bestMove != null) {
      final from = chess_lib.Chess.algebraic(bestMove.from);
      final to = chess_lib.Chess.algebraic(bestMove.to);

      _game.make_move(bestMove);
      _fenHistory.add(_game.fen);

      _lastMove = {'from': from, 'to': to};
      setState(() {});
      _checkEndState();
    }
  }

  void _checkEndState() {
    if (_game.in_checkmate) {
      final winner = _game.turn == chess_lib.Color.WHITE ? 'Black' : 'White';
      _recordPuzzleWin();
      _showVictoryDialog('Checkmate!', '$winner wins the match!');
    } else if (_game.in_stalemate || _game.in_draw) {
      _showVictoryDialog('Draw!', 'The game ended in a stalemate/draw.');
    }
  }

  Future<void> _recordPuzzleWin() async {
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    await ref.read(statsServiceProvider).recordResult(
          gameType: 'chess',
          todayKey: todayKey,
          won: true,
        );
    await ref.read(practiceServiceProvider).recordSolved('chess', _currentPuzzle.id);
  }

  void _showVictoryDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 56),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Next Puzzle ➔'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  if (_mode == ChessGameMode.dailyPuzzle) {
                    _startNextPuzzle();
                  } else if (_mode == ChessGameMode.vsAI) {
                    _startVsAIGame();
                  } else {
                    _startPassAndPlayGame();
                  }
                });
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Home'),
            ),
          ],
        );
      },
    );
  }

  void _undoMove() {
    if (_fenHistory.length <= 1) return;
    setState(() {
      _fenHistory.removeLast();
      if (_mode == ChessGameMode.vsAI && _fenHistory.length > 1) {
        _fenHistory.removeLast(); // Undo AI move as well
      }
      _game = chess_lib.Chess.fromFEN(_fenHistory.last);
      _lastMove = null;
      _selectedSquare = null;
      _validMoves = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Chess',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Game Mode Switcher Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<ChessGameMode>(
                segments: const [
                  ButtonSegment(
                    value: ChessGameMode.dailyPuzzle,
                    label: Text('Daily Puzzles'),
                    icon: Icon(Icons.extension_outlined),
                  ),
                  ButtonSegment(
                    value: ChessGameMode.vsAI,
                    label: Text('Vs AI'),
                    icon: Icon(Icons.smart_toy_outlined),
                  ),
                  ButtonSegment(
                    value: ChessGameMode.passAndPlay,
                    label: Text('Pass & Play'),
                    icon: Icon(Icons.people_alt_outlined),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _mode = newSelection.first;
                    if (_mode == ChessGameMode.dailyPuzzle) {
                      _startDailyPuzzle();
                    } else if (_mode == ChessGameMode.vsAI) {
                      _startVsAIGame();
                    } else {
                      _startPassAndPlayGame();
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Mode header info card
            if (_mode == ChessGameMode.dailyPuzzle)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.secondary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Puzzle #${_currentPuzzleIndex + 1}: ${_currentPuzzle.title}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _currentPuzzle.difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _currentPuzzle.description,
                            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _startNextPuzzle()),
                          icon: const Icon(Icons.skip_next_rounded, size: 18),
                          label: const Text('Next ➔', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            if (_mode == ChessGameMode.vsAI)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AI Difficulty:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<AIDifficulty>(
                    value: _aiDifficulty,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _aiDifficulty = val;
                          _startVsAIGame();
                        });
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: AIDifficulty.easy,
                        child: Text('Easy (Novice)'),
                      ),
                      DropdownMenuItem(
                        value: AIDifficulty.medium,
                        child: Text('Medium (Club)'),
                      ),
                      DropdownMenuItem(
                        value: AIDifficulty.hard,
                        child: Text('Hard (Master)'),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // Captured pieces top tray
            Row(
              children: [
                const Text('Captured: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    _isFlipped ? _getCapturedWhiteText() : _getCapturedBlackText(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Chess Board Widget
            ChessBoardWidget(
              game: _game,
              selectedSquare: _selectedSquare,
              validMoves: _validMoves,
              lastMove: _lastMove,
              isFlipped: _isFlipped,
              onSquareTap: _onSquareTap,
            ),

            const SizedBox(height: 8),
            // Captured pieces bottom tray
            Row(
              children: [
                const Text('Captured: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    _isFlipped ? _getCapturedBlackText() : _getCapturedWhiteText(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bottom control actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PressableScale(
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.undo_rounded),
                    tooltip: 'Undo Move',
                    onPressed: _undoMove,
                  ),
                ),
                PressableScale(
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.flip_camera_android_rounded),
                    tooltip: 'Flip Board',
                    onPressed: () => setState(() => _isFlipped = !_isFlipped),
                  ),
                ),
                PressableScale(
                  child: IconButton.filledTonal(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Restart Puzzle',
                    onPressed: () {
                      setState(() {
                        if (_mode == ChessGameMode.dailyPuzzle) {
                          _loadPuzzle(_currentPuzzle);
                        } else if (_mode == ChessGameMode.vsAI) {
                          _startVsAIGame();
                        } else {
                          _startPassAndPlayGame();
                        }
                      });
                    },
                  ),
                ),
                if (_mode == ChessGameMode.dailyPuzzle)
                  PressableScale(
                    child: IconButton.filledTonal(
                      icon: const Icon(Icons.lightbulb_outline_rounded),
                      tooltip: 'Show Hint',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hint: ${_currentPuzzle.hint}'),
                            duration: const Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
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
