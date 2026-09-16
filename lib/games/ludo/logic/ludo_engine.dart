import 'dart:math';
import '../models/ludo_player.dart';
import '../models/ludo_token.dart';

class LudoEngine {
  final List<LudoPlayer> players;
  int currentTurnIndex = 0;
  int lastDiceRoll = 0;
  bool hasRolledDice = false;
  int consecutiveSixes = 0;
  bool isGameOver = false;
  LudoPlayer? winner;

  static final Random _random = Random();

  LudoEngine({required int playerCount, required bool vsAI})
      : players = _createPlayers(playerCount, vsAI);

  static List<LudoPlayer> _createPlayers(int count, bool vsAI) {
    final colors = [
      LudoColor.red,
      LudoColor.green,
      LudoColor.yellow,
      LudoColor.blue,
    ];
    return List.generate(count, (i) {
      return LudoPlayer(
        color: colors[i],
        isAI: vsAI ? (i > 0) : false,
      );
    });
  }

  LudoPlayer get currentPlayer => players[currentTurnIndex];

  /// 52 main track coordinates starting from Red start (6, 1)
  static const List<(int, int)> trackCoordinates = [
    (6, 1), (6, 2), (6, 3), (6, 4), (6, 5), (5, 6), (4, 6), (3, 6), (2, 6), (1, 6), (0, 6),
    (0, 7), (0, 8),
    (1, 8), (2, 8), (3, 8), (4, 8), (5, 8), (6, 9), (6, 10), (6, 11), (6, 12), (6, 13), (6, 14),
    (7, 14), (8, 14),
    (8, 13), (8, 12), (8, 11), (8, 10), (8, 9), (9, 8), (10, 8), (11, 8), (12, 8), (13, 8), (14, 8),
    (14, 7), (14, 6),
    (13, 6), (12, 6), (11, 6), (10, 6), (9, 6), (8, 5), (8, 4), (8, 3), (8, 2), (8, 1), (8, 0),
    (7, 0), (6, 0),
  ];

  static const Map<LudoColor, int> startTrackIndices = {
    LudoColor.red: 0,
    LudoColor.green: 13,
    LudoColor.yellow: 26,
    LudoColor.blue: 39,
  };

  static const Set<int> safeTrackIndices = {0, 8, 13, 21, 26, 34, 39, 47};

  static const Map<LudoColor, List<(int, int)>> homeStretchCoordinates = {
    LudoColor.red: [(7, 1), (7, 2), (7, 3), (7, 4), (7, 5)],
    LudoColor.green: [(1, 7), (2, 7), (3, 7), (4, 7), (5, 7)],
    LudoColor.yellow: [(7, 13), (7, 12), (7, 11), (7, 10), (7, 9)],
    LudoColor.blue: [(13, 7), (12, 7), (11, 7), (10, 7), (9, 7)],
  };

  static const Map<LudoColor, (int, int)> homeTargetCoordinates = {
    LudoColor.red: (7, 6),
    LudoColor.green: (6, 7),
    LudoColor.yellow: (7, 8),
    LudoColor.blue: (8, 7),
  };

  static const Map<LudoColor, List<(int, int)>> yardCoordinates = {
    LudoColor.red: [(1, 1), (1, 4), (4, 1), (4, 4)],
    LudoColor.green: [(1, 10), (1, 13), (4, 10), (4, 13)],
    LudoColor.yellow: [(10, 10), (10, 13), (13, 10), (13, 13)],
    LudoColor.blue: [(10, 1), (10, 4), (13, 1), (13, 4)],
  };

  /// Gets (row, col) grid position for a token
  (int, int) getTokenGridPosition(LudoToken token) {
    if (token.isInYard) {
      return yardCoordinates[token.color]![token.id];
    }
    if (token.isFinished) {
      return homeTargetCoordinates[token.color]!;
    }
    if (token.stepPosition >= 0 && token.stepPosition <= 50) {
      final startIndex = startTrackIndices[token.color]!;
      final absIndex = (startIndex + token.stepPosition) % 52;
      return trackCoordinates[absIndex];
    }
    // Home stretch 51..55
    final stretchIndex = (token.stepPosition - 51).clamp(0, 4);
    return homeStretchCoordinates[token.color]![stretchIndex];
  }

  /// Roll dice (1-6)
  int rollDice() {
    if (hasRolledDice || isGameOver) return lastDiceRoll;
    lastDiceRoll = _random.nextInt(6) + 1;
    hasRolledDice = true;

    if (lastDiceRoll == 6) {
      consecutiveSixes++;
      if (consecutiveSixes == 3) {
        // Penalty for 3 consecutive sixes: forfeit turn
        hasRolledDice = false;
        consecutiveSixes = 0;
        _advanceTurn();
        return lastDiceRoll;
      }
    } else {
      consecutiveSixes = 0;
    }

    // Auto-advance turn if player has 0 moveable tokens
    final moveable = getMovableTokens();
    if (moveable.isEmpty) {
      if (lastDiceRoll != 6) {
        _advanceTurn();
      } else {
        hasRolledDice = false;
      }
    }

    return lastDiceRoll;
  }

  List<LudoToken> getMovableTokens() {
    if (!hasRolledDice || isGameOver) return [];
    final player = currentPlayer;
    final List<LudoToken> moveable = [];

    for (final token in player.tokens) {
      if (token.isFinished) continue;

      if (token.isInYard) {
        if (lastDiceRoll == 6) moveable.add(token);
      } else {
        final targetStep = token.stepPosition + lastDiceRoll;
        if (targetStep <= 56) moveable.add(token);
      }
    }

    return moveable;
  }

  /// Move selected token
  bool moveToken(LudoToken token) {
    if (!hasRolledDice || isGameOver) return false;
    if (token.color != currentPlayer.color) return false;

    final moveable = getMovableTokens();
    if (!moveable.contains(token)) return false;

    bool extraTurn = (lastDiceRoll == 6);

    if (token.isInYard) {
      token.stepPosition = 0; // Exit yard onto start tile
    } else {
      token.stepPosition += lastDiceRoll;
      if (token.stepPosition == 56) {
        extraTurn = true; // Extra turn for reaching home!
      }
    }

    // Check capture if on main track
    if (token.stepPosition >= 0 && token.stepPosition <= 50) {
      final startIndex = startTrackIndices[token.color]!;
      final absIndex = (startIndex + token.stepPosition) % 52;

      if (!safeTrackIndices.contains(absIndex)) {
        for (final p in players) {
          if (p.color == token.color) continue;
          for (final oppToken in p.tokens) {
            if (oppToken.stepPosition >= 0 && oppToken.stepPosition <= 50) {
              final oppStart = startTrackIndices[oppToken.color]!;
              final oppAbs = (oppStart + oppToken.stepPosition) % 52;
              if (oppAbs == absIndex) {
                // Capture opponent token!
                oppToken.stepPosition = -1; // Send back to yard
                extraTurn = true;
              }
            }
          }
        }
      }
    }

    hasRolledDice = false;

    // Check win condition
    if (currentPlayer.hasWon) {
      isGameOver = true;
      winner = currentPlayer;
      return true;
    }

    if (!extraTurn) {
      _advanceTurn();
    }

    return true;
  }

  void _advanceTurn() {
    currentTurnIndex = (currentTurnIndex + 1) % players.length;
    hasRolledDice = false;
  }

  /// AI Bot turn execution
  LudoToken? chooseAITokenMove() {
    final moveable = getMovableTokens();
    if (moveable.isEmpty) return null;

    // 1. Capture opponent token if possible
    for (final token in moveable) {
      final targetStep = token.isInYard ? 0 : token.stepPosition + lastDiceRoll;
      if (targetStep <= 50) {
        final startIndex = startTrackIndices[token.color]!;
        final absIndex = (startIndex + targetStep) % 52;
        if (!safeTrackIndices.contains(absIndex)) {
          for (final p in players) {
            if (p.color == token.color) continue;
            for (final oppToken in p.tokens) {
              if (oppToken.stepPosition >= 0 && oppToken.stepPosition <= 50) {
                final oppStart = startTrackIndices[oppToken.color]!;
                final oppAbs = (oppStart + oppToken.stepPosition) % 52;
                if (oppAbs == absIndex) return token;
              }
            }
          }
        }
      }
    }

    // 2. Reach home (step 56)
    for (final token in moveable) {
      if (!token.isInYard && token.stepPosition + lastDiceRoll == 56) {
        return token;
      }
    }

    // 3. Exit Yard if rolled 6
    for (final token in moveable) {
      if (token.isInYard) return token;
    }

    // 4. Move token closest to home
    moveable.sort((a, b) => b.stepPosition.compareTo(a.stepPosition));
    return moveable.first;
  }
}
