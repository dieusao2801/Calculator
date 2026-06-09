import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/settings/presentation/providers/settings_controller.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Section "Phản hồi" trong Settings — 2 toggle sound + vibration.
class SoundVibrationSection extends ConsumerWidget {
  const SoundVibrationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final ctl = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.gap16,
            AppDimens.gap16,
            AppDimens.gap16,
            AppDimens.gap8,
          ),
          child: Text(
            t.settings.feedback_section_title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        SwitchListTile(
          value: settings.soundEnabled,
          title: Text(t.settings.sound.title),
          subtitle: Text(t.settings.sound.subtitle),
          onChanged: ctl.setSoundEnabled,
        ),
        SwitchListTile(
          value: settings.vibrationEnabled,
          title: Text(t.settings.vibration.title),
          subtitle: Text(t.settings.vibration.subtitle),
          onChanged: ctl.setVibrationEnabled,
        ),
      ],
    );
  }
}
