import '../services/privacy_notice.dart';
import '../services/game_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

/// Common scaffold used by all game screens and the home screen.
class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final bool showBackButton;
  final bool showSettingsAction;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.showBackButton = false,
    this.showSettingsAction = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(
        title: Text(title.split(' — ').first),
        automaticallyImplyLeading: showBackButton,
        actions: [
          ...?actions,
          if (showSettingsAction)
            IconButton(
              icon: Icon(Icons.palette_outlined),
              tooltip: 'Appearance & settings',
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SingleChildScrollView(
                  child: SettingsSheet(helpText: rulesFor(title)),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: dividerColor),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 680),
            child: body,
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Top-right icon button used in AppBar actions.
class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onTap,
      tooltip: tooltip,
    );
  }
}

/// Settings bottom sheet accessible from every game screen.
class SettingsSheet extends ConsumerWidget {
  final String? helpText;
  const SettingsSheet({super.key, this.helpText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Made by q04ti',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text('Independent developer. Creator of Puzzlebox.'),
          const SizedBox(height: 6),
          const Text(
            'Designed and developed by q04ti. Free puzzles, made for everyone who loves to play.',
          ),
          const SizedBox(height: 20),
          if (helpText != null)
            ExpansionTile(
              title: const Text('How to play'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(helpText!, style: const TextStyle(height: 1.6)),
                ),
              ],
            ),
          Wrap(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.privacy_tip_outlined),
                label: const Text('Privacy'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Your data stays yours'),
                    content: const SingleChildScrollView(
                      child: Text(privacyNotice),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: 'Puzzlebox',
                  applicationVersion: '2.1.1',
                  applicationLegalese:
                      'Puzzlebox © 2026 q04ti. Third-party components retain their own licenses.',
                ),
                child: const Text('Open-source licenses'),
              ),
            ],
          ),
          Text(
            'Make it yours',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 4; i++)
                ChoiceChip(
                  label: Text(['Ocean', 'Orchard', 'Clay', 'Iris'][i]),
                  selected: settings.palette == i,
                  onSelected: (_) =>
                      ref.read(settingsProvider.notifier).setPalette(i),
                ),
            ],
          ),
          SizedBox(height: 16),
          _SettingRow(
            label: 'Dark Mode',
            subtitle: 'Switch app appearance',
            child: Switch(
              value: settings.themeMode == ThemeMode.dark,
              activeThumbColor: Theme.of(context).colorScheme.primary,
              onChanged: (v) {
                ref
                    .read(settingsProvider.notifier)
                    .setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          Divider(),
          _SettingRow(
            label: 'Haptic Feedback',
            subtitle: 'Vibrations on key taps',
            child: Switch(
              value: settings.hapticsEnabled,
              activeThumbColor: Theme.of(context).colorScheme.primary,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setHapticsEnabled(v);
              },
            ),
          ),
          Divider(),
          _SettingRow(
            label: 'Daily Five hard mode',
            subtitle: 'Must use revealed hints in subsequent guesses',
            child: Switch(
              value: settings.hardModeEnabled,
              activeThumbColor: Theme.of(context).colorScheme.primary,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setHardModeEnabled(v);
              },
            ),
          ),
          Divider(),
          _SettingRow(
            label: 'Sound Effects',
            subtitle: 'Play subtle audio feedback on taps',
            child: Switch(
              value: settings.soundEnabled,
              activeThumbColor: Theme.of(context).colorScheme.primary,
              onChanged: (v) {
                ref.read(settingsProvider.notifier).setSoundEnabled(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final Widget child;

  const _SettingRow({
    required this.label,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
