import 'package:fluent_ui/fluent_ui.dart';

import '../core/services/app_locale_service.dart';
import '../features/tweaks/application/tweak_controller.dart';
import '../l10n/app_localizations.dart';

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
    final strings = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(strings.settings, style: FluentTheme.of(context).typography.title),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(strings.language),
                      const SizedBox(height: 3),
                      Text(strings.languageDescription),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ComboBox<String>(
                  value: controller.localeCode,
                  items: <ComboBoxItem<String>>[
                    for (final code in AppLocaleService.supportedCodes)
                      ComboBoxItem<String>(
                        value: code,
                        child: Text(AppLocaleService.nativeNames[code]!),
                      ),
                  ],
                  onChanged: (code) {
                    if (code != null) {
                      controller.setLocaleCode(code);
                    }
                  },
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(strings.startWithWindows),
                      SizedBox(height: 3),
                      Text(strings.startWithWindowsDescription),
                    ],
                  ),
                ),
                ToggleSwitch(
                  checked: controller.startWithWindows,
                  onChanged: (enabled) =>
                      controller.setStartWithWindows(enabled),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Button(
                  onPressed: () =>
                      _runOperation(context, controller.openLogFolder),
                  child: Text(strings.openLogFolder),
                ),
                Button(
                  onPressed: () =>
                      _runOperation(context, controller.redetectSystemState),
                  child: Text(strings.redetectSystemState),
                ),
                Button(
                  onPressed: () =>
                      _runOperation(context, controller.exportProfile),
                  child: Text(strings.exportProfile),
                ),
                Button(
                  onPressed: () =>
                      _runOperation(context, controller.importProfile),
                  child: Text(strings.importProfile),
                ),
                Button(
                  onPressed: () =>
                      _runOperation(context, controller.resetAppSettings),
                  child: Text(strings.resetAppSettings),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.updates,
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(strings.automaticUpdateNotifications),
                          SizedBox(height: 3),
                          Text(strings.automaticUpdateDescription),
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
                    title: Text(
                      '${strings.updateAvailable}: ${update.version}',
                    ),
                    content: Text(strings.updateAvailableDescription),
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
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: ProgressRing(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text(strings.checking),
                              ],
                            )
                          : Text(strings.checkNow),
                    ),
                    if (update != null) ...<Widget>[
                      Button(
                        onPressed: onViewRelease,
                        child: Text(strings.viewRelease),
                      ),
                      FilledButton(
                        onPressed: update.installerUrl == null
                            ? null
                            : onInstallUpdate,
                        child: Text(strings.updateNow),
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
                      Text(strings.applicationVersion),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(strings.dryRunMode),
                      SizedBox(height: 3),
                      Text(strings.dryRunDescription),
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

  Future<void> _runOperation(
    BuildContext context,
    Future<dynamic> Function() action,
  ) async {
    final result = await action();
    if (!context.mounted) return;
    final strings = AppLocalizations.of(context);
    displayInfoBar(
      context,
      builder: (_, close) => InfoBar(
        title: Text(result.success ? strings.done : strings.operationFailed),
        content: Text(result.message ?? ''),
        severity: result.success
            ? InfoBarSeverity.success
            : InfoBarSeverity.error,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      ),
    );
  }
}
