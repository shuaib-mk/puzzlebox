import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/game_mode_toggle.dart';
import '../models/daily_five_state.dart';
import '../models/letter_state.dart';
import '../providers/daily_five_provider.dart';
import 'tile_widget.dart';

/// The 6×5 board of [TileWidget]s with row-shake on invalid submission.
class GameBoard extends ConsumerStatefulWidget {
  final GameMode mode;

  const GameBoard({super.key, required this.mode});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard> {
  int _lastShakeCount = 0;
  final List<GlobalKey<_ShakeRowState>> _rowKeys = List.generate(
    DailyFiveState.maxGuesses,
    (_) => GlobalKey<_ShakeRowState>(),
  );

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(dailyFiveProvider(widget.mode));

    // Trigger shake on active row when shakeCount increases
    if (game.shakeCount > _lastShakeCount) {
      _lastShakeCount = game.shakeCount;
      final activeRow = game.currentRow < DailyFiveState.maxGuesses
          ? game.currentRow
          : DailyFiveState.maxGuesses - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rowKeys[activeRow].currentState?.shake();
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tile size: fill width with 4px gaps between 5 tiles, max 64
        final tileSize = min(
          (constraints.maxWidth - 16) / 5,
          (constraints.maxHeight - 24) / 6,
        ).clamp(0.0, 64.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(DailyFiveState.maxGuesses, (row) {
            final isCurrentRow =
                row == game.currentRow - 1 &&
                game.board[row][0].state != LetterState.empty &&
                game.board[row][0].state != LetterState.filled;
            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: _ShakeRow(
                key: _rowKeys[row],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(DailyFiveState.wordLength, (col) {
                    final tile = game.board[row][col];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: col < DailyFiveState.wordLength - 1 ? 4 : 0,
                      ),
                      child: TileWidget(
                        key: ValueKey('tile_${row}_$col'),
                        letter: tile.letter,
                        state: tile.state,
                        shouldAnimate: isCurrentRow,
                        animationDelay: Duration(milliseconds: col * 100),
                        size: tileSize,
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Row wrapper that provides a horizontal shake animation on demand.
class _ShakeRow extends StatefulWidget {
  final Widget child;
  const _ShakeRow({super.key, required this.child});

  @override
  State<_ShakeRow> createState() => _ShakeRowState();
}

class _ShakeRowState extends State<_ShakeRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _anim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  void shake() => _ctrl.forward(from: 0);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) =>
          Transform.translate(offset: Offset(_anim.value, 0), child: child),
      child: widget.child,
    );
  }
}
