import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/game_mode_toggle.dart';
import '../services/practice_service.dart';
import '../services/puzzle_progression.dart';
import '../services/date_service.dart';
import '../providers/settings_provider.dart';

mixin PracticeModeMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  String get gameType;
  GameMode _mode = GameMode.practice;
  String _dayKey = DateService.todayKey();
  String get dailyDateKey => _dayKey;
  GameMode get mode => _mode;
  int _practiceSolvedCount = 0;
  int get practiceSolvedCount => _practiceSolvedCount;
  String difficulty = 'Medium';
  int _generation = 0;
  bool _finishing = false;
  bool _advanceReserved = false;
  Timer? _advanceTimer;
  Timer? _saveTimer;
  SharedPreferences? _prefs;
  String? _sessionKey;
  String? _sessionId;
  String? _sessionMode;
  Map<String, dynamic> captureProgress() => {};
  void restoreProgress(Map<String, dynamic> data) {}
  void startSession() {
    _saveTimer?.cancel();
    _prefs = ref.read(sharedPreferencesProvider);
    _sessionKey = 'session_v1_$gameType';
    _sessionId = puzzleRequest.id;
    _sessionMode = mode.name;
    try {
      final raw = _prefs!.getString(_sessionKey!);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        if (data['id'] == puzzleRequest.id && data['mode'] == mode.name) {
          restoreProgress(Map<String, dynamic>.from(data['progress']));
        }
      }
    } catch (_) {
      /* An invalid older save must not prevent play. */
    }
    _saveTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _saveSession(),
    );
  }

  void _saveSession() {
    if (_prefs == null || _sessionKey == null || _finishing) return;
    final data = captureProgress();
    if (data.isEmpty) return;
    _prefs!.setString(
      _sessionKey!,
      jsonEncode({'id': _sessionId, 'mode': _sessionMode, 'progress': data}),
    );
  }

  int puzzleSeed() => mode == GameMode.daily
      ? stableSeed('$gameType:$_dayKey:$difficulty')
      : stableSeed(
          '${ref.read(puzzleProgressionProvider).seed(gameType)}:$difficulty',
        );
  PuzzleRequest get puzzleRequest => PuzzleRequest(
    gameType,
    puzzleSeed(),
    PuzzleDifficulty.values.byName(difficulty.toLowerCase()),
  );
  void onPracticeModeChanged(GameMode mode) {}
  void loadDailyPuzzle() {}
  void loadPracticePuzzle() {}
  Future<void> initPracticeMode() async {
    _practiceSolvedCount = ref
        .read(practiceServiceProvider)
        .getSolvedCount(gameType);
    difficulty =
        ref.read(sharedPreferencesProvider).getString('difficulty_$gameType') ??
        'Medium';
    if (!['Easy', 'Medium', 'Hard'].contains(difficulty)) difficulty = 'Medium';
  }

  Future<void> recordPracticeWin() async => finishPuzzle();
  void recordPracticeLoss() => finishPuzzle(won: false);
  Future<void> finishPuzzle({bool won = true}) async {
    if (_finishing || !mounted) return;
    _finishing = true;
    _saveTimer?.cancel();
    if (_sessionKey != null) _prefs?.remove(_sessionKey!);
    final generation = _generation;
    if (ref.read(settingsProvider).hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    try {
      if (mode == GameMode.practice && won) {
        final count = await ref
            .read(practiceServiceProvider)
            .recordSolved(gameType, puzzleRequest.id);
        if (!mounted || generation != _generation) return;
        setState(() => _practiceSolvedCount = count);
      }
      if (!mounted || generation != _generation) return;
      await ref.read(puzzleProgressionProvider).advance(gameType);
      _advanceReserved = true;
      if (!mounted || generation != _generation) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            won
                ? 'Nicely solved. Next puzzle coming up!'
                : 'Fresh puzzle coming up.',
          ),
          duration: const Duration(milliseconds: 1300),
        ),
      );
      _advanceTimer?.cancel();
      _advanceTimer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted && generation == _generation) nextPuzzle();
      });
    } catch (_) {
      _finishing = false;
      if (mounted) {
        showPuzzleHint('Your save could not be written. Use Next to retry.');
      }
    }
  }

  Future<void> nextPuzzle() async {
    _advanceTimer?.cancel();
    _saveTimer?.cancel();
    final generation = ++_generation;
    try {
      if (!_advanceReserved) {
        await ref.read(puzzleProgressionProvider).advance(gameType);
      }
      _advanceReserved = false;
      if (!mounted || generation != _generation) return;
      setState(() {
        _mode = GameMode.practice;
        _finishing = false;
        onPracticeModeChanged(_mode);
      });
    } catch (_) {
      if (mounted) {
        showPuzzleHint('Unable to save. Your current puzzle is still here.');
      }
    }
  }

  bool shouldShowNextButton(bool isSolved) => isSolved;
  void showPuzzleHint(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  }

  Widget buildPracticeModeToggle() => Column(
    children: [
      GameModeToggle(
        mode: mode,
        practiceSolvedCount: practiceSolvedCount,
        onModeChanged: (value) {
          if (value == mode) return;
          _advanceTimer?.cancel();
          _generation++;
          _advanceReserved = false;
          setState(() {
            _dayKey = DateService.todayKey();
            _mode = value;
            _finishing = false;
            onPracticeModeChanged(value);
          });
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: difficulty,
                isExpanded: true,
                items: ['Easy', 'Medium', 'Hard']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) {
                  if (value == null || value == difficulty) return;
                  _advanceTimer?.cancel();
                  _generation++;
                  _advanceReserved = false;
                  ref
                      .read(sharedPreferencesProvider)
                      .setString('difficulty_$gameType', value);
                  setState(() {
                    difficulty = value;
                    _finishing = false;
                    onPracticeModeChanged(mode);
                  });
                },
              ),
            ),
            TextButton.icon(
              onPressed: nextPuzzle,
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('Next'),
            ),
          ],
        ),
      ),
    ],
  );
  @override
  void dispose() {
    _saveSession();
    _saveTimer?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }
}
