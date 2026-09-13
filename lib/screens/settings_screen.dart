import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Text(
            'Settings',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Make Puzzlebox feel like yours.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          const _Label('COLOR THEME'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              4,
              (i) => ChoiceChip(
                label: Text(['Ocean', 'Orchard', 'Clay', 'Iris'][i]),
                selected: state.palette == i,
                onSelected: (_) => notifier.setPalette(i),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _Label('APPEARANCE'),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.settings_brightness),
              ),
            ],
            selected: {state.themeMode},
            onSelectionChanged: (v) => notifier.setThemeMode(v.first),
          ),
          const SizedBox(height: 24),
          const _Label('DEFAULT DIFFICULTY'),
          DropdownButtonFormField<String>(
            initialValue: state.defaultDifficulty,
            items: [
              'Easy',
              'Medium',
              'Hard',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) {
              if (v != null) notifier.setDefaultDifficulty(v);
            },
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Haptic feedback'),
            subtitle: const Text('Tactile feedback on important actions'),
            value: state.hapticsEnabled,
            onChanged: notifier.setHapticsEnabled,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Sound effects'),
            subtitle: const Text('Subtle sounds during play'),
            value: state.soundEnabled,
            onChanged: notifier.setSoundEnabled,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily Five hard mode'),
            subtitle: const Text('Use revealed clues in later guesses'),
            value: state.hardModeEnabled,
            onChanged: notifier.setHardModeEnabled,
          ),
          const SizedBox(height: 28),
          const _Label('SUPPORT Q04TI'),
          const SizedBox(height: 8),
          Text(
            'Puzzlebox is free. If you enjoy it, optional support helps q04ti keep making games.',
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.45),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language_rounded),
            title: const Text('q04ti.dev'),
            subtitle: const Text('Website and projects'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _open(context, 'https://q04ti.dev'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.favorite_rounded),
            title: const Text('Buy q04ti a coffee'),
            subtitle: const Text('Optional support — thank you'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _open(context, 'https://buymeacoffee.com/q04ti'),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    if (!await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        ) &&
        context.mounted) {
      await Clipboard.setData(ClipboardData(text: url));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Link copied')));
      }
    }
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: 1.1,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}
