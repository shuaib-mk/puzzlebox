import 'dart:math';
import 'package:chess/chess.dart' as chess_lib;

enum AIDifficulty { easy, medium, hard }

class ChessAI {
  static final _random = Random();

  /// Piece evaluation values (in centipawns)
  static const Map<String, int> _pieceValues = {
    'p': 100,
    'n': 320,
    'b': 330,
    'r': 500,
    'q': 900,
    'k': 20000,
  };

  /// Positional bonus tables (White perspective)
  static const List<int> _pawnTable = [
     0,  0,  0,  0,  0,  0,  0,  0,
    50, 50, 50, 50, 50, 50, 50, 50,
    10, 10, 20, 30, 30, 20, 10, 10,
     5,  5, 10, 25, 25, 10,  5,  5,
     0,  0,  0, 20, 20,  0,  0,  0,
     5, -5,-10,  0,  0,-10, -5,  5,
     5, 10, 10,-20,-20, 10, 10,  5,
     0,  0,  0,  0,  0,  0,  0,  0
  ];

  static const List<int> _knightTable = [
    -50,-40,-30,-30,-30,-30,-40,-50,
    -40,-20,  0,  0,  0,  0,-20,-40,
    -30,  0, 10, 15, 15, 10,  0,-30,
    -30,  5, 15, 20, 20, 15,  5,-30,
    -30,  0, 15, 20, 20, 15,  0,-30,
    -30,  5, 10, 15, 15, 10,  5,-30,
    -40,-20,  0,  5,  5,  0,-20,-40,
    -50,-40,-30,-30,-30,-30,-40,-50
  ];

  static const List<int> _bishopTable = [
    -20,-10,-10,-10,-10,-10,-10,-20,
    -10,  0,  0,  0,  0,  0,  0,-10,
    -10,  0,  5, 10, 10,  5,  0,-10,
    -10,  5,  5, 10, 10,  5,  5,-10,
    -10,  0, 10, 10, 10, 10,  0,-10,
    -10, 10, 10, 10, 10, 10, 10,-10,
    -10,  5,  0,  0,  0,  0,  5,-10,
    -20,-10,-10,-10,-10,-10,-10,-20
  ];

  /// Finds the best move for the current turn based on difficulty.
  static chess_lib.Move? getBestMove(chess_lib.Chess game, AIDifficulty difficulty) {
    final List<chess_lib.Move> moves = game.generate_moves({'verbose': true});
    if (moves.isEmpty) return null;

    if (difficulty == AIDifficulty.easy) {
      // 30% chance smart capture, 70% random
      if (_random.nextDouble() < 0.3) {
        final captures = moves.where((m) => m.captured != null).toList();
        if (captures.isNotEmpty) {
          return captures[_random.nextInt(captures.length)];
        }
      }
      return moves[_random.nextInt(moves.length)];
    }

    final depth = (difficulty == AIDifficulty.medium) ? 2 : 3;
    final isMaximizing = (game.turn == chess_lib.Color.WHITE);

    chess_lib.Move bestMove = moves[0];
    int bestValue = isMaximizing ? -999999 : 999999;
    int alpha = -999999;
    int beta = 999999;

    // Order captures first for faster alpha-beta pruning
    moves.sort((a, b) {
      final aVal = a.captured != null ? 10 : 0;
      final bVal = b.captured != null ? 10 : 0;
      return bVal.compareTo(aVal);
    });

    for (final move in moves) {
      game.make_move(move);
      final eval = _minimax(game, depth - 1, alpha, beta, !isMaximizing);
      game.undo_move();

      if (isMaximizing) {
        if (eval > bestValue) {
          bestValue = eval;
          bestMove = move;
        }
        alpha = max(alpha, bestValue);
      } else {
        if (eval < bestValue) {
          bestValue = eval;
          bestMove = move;
        }
        beta = min(beta, bestValue);
      }

      if (beta <= alpha) break;
    }

    return bestMove;
  }

  static int _minimax(
    chess_lib.Chess game,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
  ) {
    if (depth == 0 || game.in_checkmate || game.in_stalemate || game.in_draw) {
      return _evaluateBoard(game);
    }

    final List<chess_lib.Move> moves = game.generate_moves({'verbose': true});

    if (isMaximizing) {
      int maxEval = -999999;
      for (final move in moves) {
        game.make_move(move);
        final eval = _minimax(game, depth - 1, alpha, beta, false);
        game.undo_move();
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 999999;
      for (final move in moves) {
        game.make_move(move);
        final eval = _minimax(game, depth - 1, alpha, beta, true);
        game.undo_move();
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static int _evaluateBoard(chess_lib.Chess game) {
    if (game.in_checkmate) {
      return (game.turn == chess_lib.Color.WHITE) ? -900000 : 900000;
    }
    if (game.in_stalemate || game.in_draw) return 0;

    int totalEval = 0;
    final files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

    for (int rankIndex = 0; rankIndex < 8; rankIndex++) {
      final rank = 8 - rankIndex;
      for (int fileIndex = 0; fileIndex < 8; fileIndex++) {
        final file = files[fileIndex];
        final piece = game.get('$file$rank');
        final i = rankIndex * 8 + fileIndex; // 0..63 table index
        if (piece == null) continue;

        final pType = piece.type.name.toLowerCase();
        final baseVal = _pieceValues[pType] ?? 0;
        int posBonus = 0;

        if (pType == 'p') {
          posBonus = _pawnTable[piece.color == chess_lib.Color.WHITE ? i : 63 - i];
        } else if (pType == 'n') {
          posBonus = _knightTable[piece.color == chess_lib.Color.WHITE ? i : 63 - i];
        } else if (pType == 'b') {
          posBonus = _bishopTable[piece.color == chess_lib.Color.WHITE ? i : 63 - i];
        }

        final score = baseVal + posBonus;
        if (piece.color == chess_lib.Color.WHITE) {
          totalEval += score;
        } else {
          totalEval -= score;
        }
      }
    }

    return totalEval;
  }
}
