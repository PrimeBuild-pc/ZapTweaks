import 'dart:math' as math;

import 'package:fluent_ui/fluent_ui.dart';

import '../../../../core/models/tweak_descriptor.dart';
import '../../application/tweak_controller.dart';
import '../widgets/tweak_switch_tile.dart';

class TweaksPage extends StatefulWidget {
  const TweaksPage({
    super.key,
    required this.controller,
    required this.category,
    required this.onSafetyPrompt,
  });

  final TweakController controller;
  final String category;
  final Future<bool> Function(String title, String message) onSafetyPrompt;

  static const Set<String> _networkReconnectHintToggleIds = <String>{
    'network_ecn_disabled',
    'network_timestamps_disabled',
    'network_rss_enabled',
  };

  @override
  State<TweaksPage> createState() => _TweaksPageState();
}

class _TweaksPageState extends State<TweaksPage> {
  bool _bannerDismissed = false;

  static const Set<String> _presetHiddenCategories = <String>{
    'Tools',
    'Refresh & Recovery',
    'Setup',
  };

  @override
  Widget build(BuildContext context) {
    final tweaks = widget.controller.categoryTweaks(widget.category);
    final availableTweaks = tweaks
        .where(widget.controller.isDescriptorAvailable)
        .toList(growable: false);

    if (availableTweaks.isEmpty) {
      return const Center(
        child: Text('No tweaks available for your hardware configuration'),
      );
    }

    final showPresets =
        widget.controller.categoryHasToggleableItems(widget.category) &&
        !_presetHiddenCategories.contains(widget.category);
    final showBulkActions = widget.controller.categoryHasToggleableItems(
      widget.category,
      systemOnly: true,
    );
    const categoriesWithoutHardwareBanner = <String>{
      'Visuals',
      'Privacy',
      'Advanced',
      'Windows',
      'Networking',
      'Gaming',
    };
    final showHardwareBanner =
        showBulkActions &&
        !categoriesWithoutHardwareBanner.contains(widget.category);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        if (showPresets) ...<Widget>[
          _buildPresetsCard(context),
          const SizedBox(height: 12),
        ],
        if (showHardwareBanner) ...<Widget>[
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
                  Text('CPU: ${widget.controller.hardwareProfile.cpuName}'),
                  Text(
                    widget.controller.hardwareProfile.gpuNames.isEmpty
                        ? 'GPU: Unknown'
                        : 'GPU: ${widget.controller.hardwareProfile.gpuNames.join(' | ')}',
                  ),
                  Text('RAM: ${widget.controller.hardwareProfile.ramInstalledLabel}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (showBulkActions) ...<Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton(
                child: const Text('Enable all visible'),
                onPressed: () async {
                  await widget.controller.setAllInCategory(
                    widget.category,
                    true,
                    confirmRestorePoint: () => widget.onSafetyPrompt(
                      'Create restore point',
                      'This batch operation requires a restore point before execution.',
                    ),
                  );
                },
              ),
              Button(
                child: const Text('Disable all visible'),
                onPressed: () async {
                  await widget.controller.setAllInCategory(
                    widget.category,
                    false,
                    confirmRestorePoint: () => widget.onSafetyPrompt(
                      'Create restore point',
                      'This batch operation requires a restore point before execution.',
                    ),
                  );
                },
              ),
              if (widget.controller.needsRestart)
                FilledButton(
                  child: const Text('Restart now'),
                  onPressed: () async {
                    await widget.controller.restartSystem();
                    if (mounted) {
                      setState(() => _bannerDismissed = false);
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (widget.controller.needsRestart && !_bannerDismissed)
          InfoBar(
            title: const Text('Restart required'),
            content: const Text(
              'A system restart is required to fully apply one or more changes.',
            ),
            severity: InfoBarSeverity.warning,
            isLong: true,
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Button(
                  child: const Text('Restart Now'),
                  onPressed: () async {
                    await widget.controller.restartSystem();
                    if (!mounted) {
                      return;
                    }

                    setState(() => _bannerDismissed = false);
                  },
                ),
                const SizedBox(width: 8),
                Button(
                  child: const Text('Later'),
                  onPressed: () {
                    setState(() => _bannerDismissed = true);
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (widget.category == 'Tools')
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
          final available = widget.controller.isDescriptorAvailable(descriptor);
          final busy = widget.controller.busyTweaks.contains(descriptor.id);

          if (descriptor.isSystemToggle) {
            final needsReconnectHint =
                TweaksPage._networkReconnectHintToggleIds.contains(
                  descriptor.id,
                );
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TweakSwitchTile(
                title: descriptor.title,
                description: descriptor.description,
                value: widget.controller.toggleStates[descriptor.id] ?? false,
                enabled: available,
                isBusy: busy,
                busyDuration: widget.controller.busyDurationFor(descriptor.id),
                warning: descriptor.isAggressive
                  ? 'Aggressive tweak. A restore point is mandatory.'
                  : (needsReconnectHint
                      ? 'Network adapter reconnect or system restart may be required.'
                      : null),
                unavailableReason: available
                    ? null
                    : widget.controller.availabilityHint(descriptor),
                onChanged: (next) async {
                  final result = await widget.controller.toggleSystemTweak(
                    descriptor,
                    next,
                    confirmRestorePoint: () => widget.onSafetyPrompt(
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
                busyDuration: widget.controller.busyDurationFor(descriptor.id),
                warning: descriptor.isAggressive
                    ? 'Aggressive tweak. A restore point is mandatory.'
                    : null,
                unavailableReason: available
                    ? null
                    : widget.controller.availabilityHint(descriptor),
                onChanged: (_) async {
                  final result = await widget.controller.runScriptAction(
                    descriptor,
                    confirmRestorePoint: () => widget.onSafetyPrompt(
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
                        const SizedBox(height: 2),
                        if (widget.controller.wasScriptExecuted(descriptor.id))
                          Row(
                            children: <Widget>[
                              Icon(
                                FluentIcons.check_mark,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 6),
                              const Text('Ran'),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(descriptor.description),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (busy)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: ProgressRing(strokeWidth: 2),
                          ),
                        ),
                      FilledButton(
                        onPressed: busy || !available
                            ? null
                            : () async {
                                final warningMessage = scriptTweak
                                    .warningMessage
                                    ?.trim();

                                if (warningMessage != null &&
                                    warningMessage.isNotEmpty) {
                                  final accepted = await widget.onSafetyPrompt(
                                    'Action warning',
                                    warningMessage,
                                  );
                                  if (!accepted) {
                                    return;
                                  }
                                }

                                final result = await widget.controller.runScriptAction(
                                  descriptor,
                                  confirmRestorePoint: () => widget.onSafetyPrompt(
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
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPresetsCard(BuildContext context) {
    final presets = widget.controller.presetsForCategory(widget.category);
    final selectedPreset = widget.controller.selectedPresetForCategory(
      widget.category,
    );

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

                  final result = await widget.controller.applyPresetToCategory(
                    widget.category,
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
