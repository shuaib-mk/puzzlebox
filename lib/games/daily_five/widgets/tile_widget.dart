import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/letter_state.dart';

/// A single animated tile that flips to reveal its [LetterState].
///
/// Pass [animationDelay] to stagger the flip within a row.
class TileWidget extends StatefulWidget {
  final String letter;
  final LetterState state;
  final bool shouldAnimate;
  final Duration animationDelay;
  final double size;

  const TileWidget({
    super.key,
    required this.letter,
    required this.state,
    this.shouldAnimate = false,
    this.animationDelay = Duration.zero,
    this.size = 58,
  });

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnim;

  LetterState _displayState = LetterState.empty;
  String _displayLetter = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _flipAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -90.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 90.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _displayState = widget.state;
    _displayLetter = widget.letter;
  }

  @override
  void didUpdateWidget(TileWidget old) {
    super.didUpdateWidget(old);

    final wasEmpty =
        old.state == LetterState.empty || old.state == LetterState.filled;
    final isNowResult =
        widget.state == LetterState.correct ||
        widget.state == LetterState.present ||
        widget.state == LetterState.absent;

    if (wasEmpty && isNowResult && widget.shouldAnimate) {
      Future.delayed(widget.animationDelay, () {
        if (!mounted) return;
        _controller.forward(from: 0).then((_) {
          if (mounted) {
            setState(() {
              _displayState = widget.state;
              _displayLetter = widget.letter;
            });
          }
        });
      });
    } else {
      _displayState = widget.state;
      _displayLetter = widget.letter;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _bgColor(LetterState s, bool isDark) {
    switch (s) {
      case LetterState.correct:
        return AppColors.correct;
      case LetterState.present:
        return isDark ? AppColors.present : AppColors.present;
      case LetterState.absent:
        return isDark ? AppColors.absent : AppColors.absentLight;
      default:
        return Colors.transparent;
    }
  }

  Color _borderColor(LetterState s, bool isDark) {
    switch (s) {
      case LetterState.correct:
      case LetterState.present:
      case LetterState.absent:
        return Colors.transparent;
      case LetterState.filled:
        return AppColors.filledTileBorder;
      default:
        return isDark
            ? AppColors.darkEmptyTileBorder
            : AppColors.emptyTileBorder;
    }
  }

  Color _textColor(LetterState s) {
    switch (s) {
      case LetterState.correct:
      case LetterState.present:
      case LetterState.absent:
        return Theme.of(context).colorScheme.onSurface;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _flipAnim,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateX(_flipAnim.value * 3.14159265 / 180),
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 80),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _bgColor(_displayState, isDark),
          border: Border.all(
            color: _borderColor(_displayState, isDark),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            _displayLetter,
            style: TextStyle(
              fontSize: widget.size * 0.48,
              fontWeight: FontWeight.w800,
              color:
                  (_displayState == LetterState.correct ||
                      _displayState == LetterState.present ||
                      _displayState == LetterState.absent)
                  ? _textColor(_displayState)
                  : onSurface,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
