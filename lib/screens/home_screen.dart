import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/services/practice_service.dart';
import '../core/services/engagement_service.dart';
import '../core/widgets/puzzle_pal.dart';
import '../core/widgets/pressable_scale.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/category_theme.dart';

import '../games/daily_five/widgets/daily_five_screen.dart';
import '../games/connections/connections_screen.dart';
import '../games/spelling_bee/spelling_bee_screen.dart';
import '../games/crossword/crossword_screen.dart';
import '../games/mini_crossword/mini_crossword_screen.dart';
import '../games/sudoku/sudoku_screen.dart';
import '../games/strands/strands_screen.dart';
import '../games/pips/pips_screen.dart';
import '../games/tiles/tiles_screen.dart';
import '../games/letter_boxed/letter_boxed_screen.dart';
import '../games/vertex/vertex_screen.dart';
import '../games/chess/chess_screen.dart';
import '../games/ludo/ludo_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  String _filter = 'All';
  String _query = '';

  late final AnimationController _animController;
  late final Animation<double> _heroAnimation;

  final List<(String, String, String, IconData, String, Widget)> _games = [
    (
      'daily_five',
      'Daily Five',
      'A word. Six guesses. Follow the clues.',
      Icons.grid_view_rounded,
      'Words',
      const DailyFiveScreen(),
    ),
    (
      'sudoku',
      'Sudoku',
      'Nine numbers. One satisfying solution.',
      Icons.apps_rounded,
      'Logic',
      const SudokuScreen(),
    ),
    (
      'connections',
      'Connections',
      'Find the thread connecting four words.',
      Icons.category_outlined,
      'Words',
      const ConnectionsScreen(),
    ),
    (
      'spelling_bee',
      'Spelling Bee',
      'Seven letters, a growing collection of words.',
      Icons.hive_outlined,
      'Words',
      const SpellingBeeScreen(),
    ),
    (
      'mini_crossword',
      'The Mini',
      'A small crossing of words and ideas.',
      Icons.dashboard_outlined,
      'Words',
      const MiniCrosswordScreen(),
    ),
    (
      'crossword',
      'Crossword',
      'Follow the clues. Fill every crossing.',
      Icons.border_all_rounded,
      'Words',
      const CrosswordScreen(),
    ),
    (
      'strands',
      'Strands',
      'Trace neighboring letters. Uncover a theme.',
      Icons.gesture_rounded,
      'Words',
      const StrandsScreen(),
    ),
    (
      'pips',
      'Pips',
      'Find a home for every domino by its sum.',
      Icons.casino_outlined,
      'Logic',
      const PipsScreen(),
    ),
    (
      'tiles',
      'Tiles',
      'Spot pairs and build a matching streak.',
      Icons.layers_outlined,
      'Patterns',
      const TilesScreen(),
    ),
    (
      'letter_boxed',
      'Letter Boxed',
      'Chain real words around all four sides.',
      Icons.crop_square_rounded,
      'Words',
      const LetterBoxedScreen(),
    ),
    (
      'vertex',
      'Vertex',
      'Connect the dots. Balance every number.',
      Icons.polyline_outlined,
      'Patterns',
      const VertexScreen(),
    ),
    (
      'chess',
      'Chess',
      'Tactics puzzles, vs AI, and Pass & Play.',
      Icons.extension_rounded,
      'Logic',
      const ChessScreen(),
    ),
    (
      'ludo',
      'Ludo',
      'Roll the dice, race your tokens, and win.',
      Icons.casino_rounded,
      'Logic',
      const LudoScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _heroAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disableMotion = MediaQuery.of(context).disableAnimations;

    final solvedTotal = _games.fold<int>(
      0,
      (n, g) => n + ref.read(practiceServiceProvider).getSolvedCount(g.$1),
    );

    ref.watch(engagementRevisionProvider);
    final engagement = ref.read(engagementServiceProvider).load();

    final filteredGames = _games
        .where(
          (g) =>
              (_filter == 'All' || g.$5 == _filter) &&
              '${g.$2} ${g.$3}'.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return AppScaffold(
      title: 'puzzlebox',
      showSettingsAction: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Workbench Header Card ─────────────────────────────────
            ScaleTransition(
              scale: disableMotion ? const AlwaysStoppedAnimation(1.0) : _heroAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2638) : const Color(0xFFEFF6FF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(32),
                  ),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.12),
                      offset: const Offset(0, 6),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'DAILY WORKBENCH',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ready, set,\npuzzle!',
                                style: TextStyle(
                                  fontSize: 30,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '13 games. Always free. Play offline.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _FloatingMascot(disableMotion: disableMotion),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Streak & Solved Counters Row
                    Row(
                      children: [
                        // Solved Puzzles Badge
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF161E2E) : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colors.outlineVariant,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  color: colors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$solvedTotal',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Solved',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Streak Flame Badge
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2D1606) : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.streakFlame.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                _FlickeringStreakFlame(
                                  disableMotion: disableMotion,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${engagement.currentStreak} Days',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.streakFlame,
                                          height: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        engagement.currentStreak == 0
                                            ? 'Start today'
                                            : 'Active streak',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Section Title & Filter Workbench ───────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pick your playground',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
                Text(
                  '${_games.length} Games',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar
            SearchBar(
              hintText: 'Search puzzles...',
              leading: Icon(
                Icons.search_rounded,
                color: colors.onSurfaceVariant,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),

            // Category Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Words', 'Logic', 'Patterns'].map((filterName) {
                  final isSelected = _filter == filterName;
                  final categorySig = CategoryVisualSignature.of(filterName, context);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      showCheckmark: false,
                      avatar: filterName == 'All'
                          ? null
                          : Icon(
                              categorySig.badgeIcon,
                              size: 16,
                              color: isSelected ? Colors.white : categorySig.primaryColor,
                            ),
                      label: Text(filterName),
                      selectedColor: filterName == 'All'
                          ? colors.primary
                          : categorySig.primaryColor,
                      onSelected: (_) => setState(() => _filter = filterName),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // ── Game Cards List (Category Visual Signatures) ───────────────
            if (filteredGames.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No puzzles found for "$_query"',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(filteredGames.length, (index) {
                final game = filteredGames[index];
                final categorySig = CategoryVisualSignature.of(game.$5, context);
                final solvedCount = ref
                    .read(practiceServiceProvider)
                    .getSolvedCount(game.$1);

                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    final delay = (index * 0.05).clamp(0.0, 0.5);
                    final animation = CurvedAnimation(
                      parent: _animController,
                      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0),
                          curve: Curves.easeOutCubic),
                    );

                    return Transform.translate(
                      offset: disableMotion
                          ? Offset.zero
                          : Offset(0, 20 * (1.0 - animation.value)),
                      child: Opacity(
                        opacity: disableMotion ? 1.0 : animation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: PressableScale(
                      child: Material(
                        color: isDark ? AppColors.cardSlate : AppColors.cardPaper,
                        shape: RoundedRectangleBorder(
                          borderRadius: categorySig.cardRadius,
                          side: BorderSide(
                            color: categorySig.primaryColor.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          key: ValueKey('${game.$1}_card'),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => game.$6),
                            );
                            if (mounted) setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: categorySig.primaryColor.withValues(alpha: 0.08),
                                  offset: const Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Category Icon Tile Badge
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: ShapeDecoration(
                                    color: categorySig.lightBg,
                                    shape: categorySig.badgeShape,
                                  ),
                                  child: Icon(
                                    game.$4,
                                    color: categorySig.primaryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Title & Description
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          Text(
                                            game.$2,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: categorySig.primaryColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              game.$5,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                                color: categorySig.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        game.$3,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                      if (solvedCount > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                size: 13,
                                                color: categorySig.primaryColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$solvedCount solved',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: categorySig.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Arrow Indicator Button
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: categorySig.primaryColor.withValues(alpha: 0.1),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: categorySig.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),
            Center(
              child: Text(
                'No subscriptions • Offline-first • Free forever',
                style: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating Mascot Widget with gentle levitation micro-animation.
class _FloatingMascot extends StatefulWidget {
  final bool disableMotion;
  const _FloatingMascot({required this.disableMotion});

  @override
  State<_FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<_FloatingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _offsetAnim = Tween<double>(begin: -3, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disableMotion) {
      return const PuzzlePal(size: 90);
    }

    return AnimatedBuilder(
      animation: _offsetAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnim.value),
          child: child,
        );
      },
      child: const PuzzlePal(size: 90),
    );
  }
}

/// Flickering Streak Flame Widget with gentle glow animation.
class _FlickeringStreakFlame extends StatefulWidget {
  final bool disableMotion;
  const _FlickeringStreakFlame({required this.disableMotion});

  @override
  State<_FlickeringStreakFlame> createState() => _FlickeringStreakFlameState();
}

class _FlickeringStreakFlameState extends State<_FlickeringStreakFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(begin: 0.92, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.disableMotion) {
      return const Icon(
        Icons.local_fire_department_rounded,
        color: AppColors.streakFlame,
        size: 24,
      );
    }

    return ScaleTransition(
      scale: _scaleAnim,
      child: const Icon(
        Icons.local_fire_department_rounded,
        color: AppColors.streakFlame,
        size: 24,
      ),
    );
  }
}
