import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';

import '../../../../core/models/tweak_descriptor.dart';
import '../../application/tweak_controller.dart';
import '../widgets/tweak_switch_tile.dart';

class TweaksPage extends StatelessWidget {
  const TweaksPage({
    super.key,
    required this.controller,
    required this.category,
    required this.onSafetyPrompt,
  });

  final TweakController controller;
  final String category;
  final Future<bool> Function(String title, String message) onSafetyPrompt;

  @override
  Widget build(BuildContext context) {
    final tweaks = controller.categoryTweaks(category);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _buildPresetsCard(context),
        const SizedBox(height: 12),
        if (_supportsBulkActions(category)) ...<Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Detected hardware',
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  const SizedBox(height: 8),
                  Text('CPU: ${controller.hardwareProfile.cpuName}'),
                  Text(
                    controller.hardwareProfile.gpuNames.isEmpty
                        ? 'GPU: Unknown'
                        : 'GPU: ${controller.hardwareProfile.gpuNames.join(' | ')}',
                  ),
                  Text('RAM: ${controller.hardwareProfile.ramInstalledLabel}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (_supportsBulkActions(category)) ...<Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                child: const Text('Enable all visible'),
                onPressed: () async {
                  await controller.setAllInCategory(
                    category,
                    true,
                    confirmRestorePoint: () => onSafetyPrompt(
                      'Create restore point',
                      'This batch operation requires a restore point before execution.',
                    ),
                  );
                },
              ),
              Button(
                child: const Text('Disable all visible'),
                onPressed: () async {
                  await controller.setAllInCategory(
                    category,
                    false,
                    confirmRestorePoint: () => onSafetyPrompt(
                      'Create restore point',
                      'This batch operation requires a restore point before execution.',
                    ),
                  );
                },
              ),
              if (controller.needsRestart)
                FilledButton(
                  child: const Text('Restart now'),
                  onPressed: () async {
                    await controller.restartSystem();
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (controller.needsRestart)
          InfoBar(
            title: const Text('Restart required'),
            content: const Text(
              'A system restart is required to fully apply one or more changes.',
            ),
            severity: InfoBarSeverity.warning,
            isLong: true,
          ),
        const SizedBox(height: 8),
        if (category == 'Tools')
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: InfoBar(
              title: Text('Advanced actions included'),
              content: Text(
                'External tools, launcher actions, and script-driven utilities '
                'are grouped here for quick diagnostics and maintenance workflows.',
              ),
              severity: InfoBarSeverity.info,
              isLong: true,
            ),
          ),
        ..._orderedTweaks(tweaks).map((descriptor) {
          final available = controller.isDescriptorAvailable(descriptor);
          final busy = controller.busyTweaks.contains(descriptor.id);

          if (descriptor.isSystemToggle) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TweakSwitchTile(
                title: descriptor.title,
                description: descriptor.description,
                value: controller.toggleStates[descriptor.id] ?? false,
                enabled: available,
                isBusy: busy,
                busyDuration: controller.busyDurationFor(descriptor.id),
                warning: descriptor.isAggressive
                    ? 'Aggressive tweak. A restore point is mandatory.'
                    : null,
                unavailableReason: available
                    ? null
                    : controller.availabilityHint(descriptor),
                onChanged: (next) async {
                  final result = await controller.toggleSystemTweak(
                    descriptor,
                    next,
                    confirmRestorePoint: () => onSafetyPrompt(
                      'Create restore point',
                      'This aggressive tweak requires a restore point before execution.',
                    ),
                  );

                  if (!result.success && context.mounted) {
                    displayInfoBar(
                      context,
                      builder: (_, close) => InfoBar(
                        title: const Text('Operation failed'),
                        content: Text(result.message ?? 'Unknown error.'),
                        action: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: close,
                        ),
                        severity: InfoBarSeverity.error,
                      ),
                    );
                  }
                },
              ),
            );
          }

          final scriptTweak = descriptor.scriptTweak!;
          if (scriptTweak.hasState) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TweakSwitchTile(
                title: descriptor.title,
                description: descriptor.description,
                value: scriptTweak.isApplied,
                enabled: available,
                isBusy: busy,
                busyDuration: controller.busyDurationFor(descriptor.id),
                warning: descriptor.isAggressive
                    ? 'Aggressive tweak. A restore point is mandatory.'
                    : null,
                unavailableReason: available
                    ? null
                    : controller.availabilityHint(descriptor),
                onChanged: (_) async {
                  final result = await controller.runScriptAction(
                    descriptor,
                    confirmRestorePoint: () => onSafetyPrompt(
                      'Create restore point',
                      'This aggressive tweak requires a restore point before execution.',
                    ),
                  );

                  if (!result.success && context.mounted) {
                    displayInfoBar(
                      context,
                      builder: (_, close) => InfoBar(
                        title: const Text('Operation failed'),
                        content: Text(result.message ?? 'Unknown error.'),
                        action: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: close,
                        ),
                        severity: InfoBarSeverity.error,
                      ),
                    );
                  }
                },
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          descriptor.title,
                          style: FluentTheme.of(context).typography.bodyStrong,
                        ),
                        const SizedBox(height: 4),
                        Text(descriptor.description),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: busy || !available
                        ? null
                        : () async {
                            final requiresRemoteScriptConfirmation =
                                descriptor.id ==
                                'tool_fortnite_diagnostic_ping';

                            if (requiresRemoteScriptConfirmation) {
                              final accepted = await onSafetyPrompt(
                                'Run remote script command',
                                'This action executes a remote PowerShell command from '
                                    'alexanderthedad.com. Continue only if you trust the source.',
                              );
                              if (!accepted) {
                                return;
                              }
                            }

                            final result = await controller.runScriptAction(
                              descriptor,
                              confirmRestorePoint: () => onSafetyPrompt(
                                'Create restore point',
                                'This aggressive action requires a restore point before execution.',
                              ),
                            );

                            if (!result.success && context.mounted) {
                              displayInfoBar(
                                context,
                                builder: (_, close) => InfoBar(
                                  title: const Text('Operation failed'),
                                  content: Text(
                                    result.message ?? 'Unknown error.',
                                  ),
                                  action: IconButton(
                                    icon: const Icon(FluentIcons.clear),
                                    onPressed: close,
                                  ),
                                  severity: InfoBarSeverity.error,
                                ),
                              );
                            }
                          },
                    child: Text(scriptTweak.actionLabel),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  bool _supportsBulkActions(String category) {
    return category != 'Tools';
  }

  Widget _buildPresetsCard(BuildContext context) {
    final presets = controller.presetsForCategory(category);
    final selectedPreset = controller.selectedPresetForCategory(category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Text(
              'Presets',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(width: 12),
            if (presets.length == 1)
              Text(presets.first)
            else
              ComboBox<String>(
                value: selectedPreset,
                items: presets
                    .map(
                      (preset) => ComboBoxItem<String>(
                        value: preset,
                        child: Text(preset),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (nextPreset) async {
                  if (nextPreset == null || nextPreset == selectedPreset) {
                    return;
                  }

                  final result = await controller.applyPresetToCategory(
                    category,
                    nextPreset,
                  );

                  if (!result.success && context.mounted) {
                    displayInfoBar(
                      context,
                      builder: (_, close) => InfoBar(
                        title: const Text('Preset failed'),
                        content: Text(result.message ?? 'Unknown error.'),
                        action: IconButton(
                          icon: const Icon(FluentIcons.clear),
                          onPressed: close,
                        ),
                        severity: InfoBarSeverity.error,
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  List<TweakDescriptor> _orderedTweaks(List<TweakDescriptor> sourceTweaks) {
    final tweaks = List<TweakDescriptor>.from(sourceTweaks);

    const inspectorId = 'tool_nvidia_profile_inspector_folder';
    const nipId = 'tool_nvidia_profile_inspector_nip_profile';

    final inspectorIndex = tweaks.indexWhere((item) => item.id == inspectorId);
    final nipIndex = tweaks.indexWhere((item) => item.id == nipId);

    if (inspectorIndex == -1 || nipIndex == -1) {
      return tweaks;
    }

    final nipDescriptor = tweaks.removeAt(nipIndex);
    final insertAt = math.min(inspectorIndex + 1, tweaks.length);
    tweaks.insert(insertAt, nipDescriptor);
    return tweaks;
  }
}
