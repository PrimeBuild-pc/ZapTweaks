import 'package:fluent_ui/fluent_ui.dart';

import '../features/tweaks/application/tweak_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.controller,
    required this.onCheckForUpdates,
    required this.onInstallUpdate,
    required this.onViewRelease,
  });

  final TweakController controller;
  final Future<void> Function() onCheckForUpdates;
  final Future<void> Function() onInstallUpdate;
  final Future<void> Function() onViewRelease;

  @override
  Widget build(BuildContext context) {
    final update = controller.availableUpdate;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text('Settings', style: FluentTheme.of(context).typography.title),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Updates',
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Automatic update notifications'),
                          SizedBox(height: 3),
                          Text(
                            'Check at startup and show a notification dot. Updates are never installed automatically.',
                          ),
                        ],
                      ),
                    ),
                    ToggleSwitch(
                      checked: controller.automaticUpdateChecksEnabled,
                      onChanged: controller.setAutomaticUpdateChecksEnabled,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (update != null)
                  InfoBar(
                    title: Text('Version ${update.version} is available'),
                    content: const Text(
                      'You can review the release notes or install it directly.',
                    ),
                    severity: InfoBarSeverity.success,
                    isLong: true,
                  )
                else if (controller.updateStatusMessage != null)
                  Text(controller.updateStatusMessage!),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Button(
                      onPressed: controller.isCheckingForUpdates
                          ? null
                          : onCheckForUpdates,
                      child: controller.isCheckingForUpdates
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: ProgressRing(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text('Checking...'),
                              ],
                            )
                          : const Text('Check now'),
                    ),
                    if (update != null) ...<Widget>[
                      Button(
                        onPressed: onViewRelease,
                        child: const Text('View release'),
                      ),
                      FilledButton(
                        onPressed: update.installerUrl == null
                            ? null
                            : onInstallUpdate,
                        child: const Text('Update now'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                const Icon(FluentIcons.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Application version'),
                      const SizedBox(height: 3),
                      Text('ZapTweaks v${controller.appVersion}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Dry-run mode'),
                      SizedBox(height: 3),
                      Text('Simulate commands without changing Windows.'),
                    ],
                  ),
                ),
                ToggleSwitch(
                  checked: controller.isDryRunMode,
                  onChanged: controller.setDryRunMode,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
