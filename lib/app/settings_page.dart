import 'package:fluent_ui/fluent_ui.dart';

import '../core/services/app_locale_service.dart';
import '../features/tweaks/application/tweak_controller.dart';
import '../l10n/app_localizations.dart';
import 'widgets/ui_kit.dart';

class SettingsPage extends StatefulWidget {
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
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// Set while a maintenance action runs, so the buttons show a spinner
  /// instead of looking unresponsive.
  bool _isRunningOperation = false;

  TweakController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final update = controller.availableUpdate;
    final strings = AppLocalizations.of(context);

    Widget action(String label, Future<dynamic> Function() run) => Button(
      onPressed: _isRunningOperation ? null : () => _runOperation(context, run),
      child: Text(label),
    );

    final String updateStatus;
    if (update != null) {
      updateStatus = '${strings.updateAvailable}: ${update.version}';
    } else if (controller.isCheckingForUpdates) {
      updateStatus = strings.checkingForUpdates;
    } else if (controller.isUpToDate) {
      updateStatus = strings.upToDate(controller.appVersion);
    } else {
      updateStatus = controller.updateStatusMessage ?? strings.checkNow;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PageTitle(strings.settings),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: <Widget>[
              SettingsSection(
                title: strings.settingsGeneral,
                children: <Widget>[
                  SettingsCard(
                    icon: FluentIcons.locale_language,
                    title: strings.language,
                    description: strings.languageDescription,
                    trailing: ComboBox<String>(
                      value: controller.localeCode,
                      items: <ComboBoxItem<String>>[
                        for (final code in AppLocaleService.supportedCodes)
                          ComboBoxItem<String>(
                            value: code,
                            child: Text(AppLocaleService.nativeNames[code]!),
                          ),
                      ],
                      onChanged: (code) {
                        if (code != null) controller.setLocaleCode(code);
                      },
                    ),
                  ),
                  SettingsCard(
                    icon: FluentIcons.color,
                    title: strings.appearance,
                    description: strings.appearanceDescription,
                    trailing: ComboBox<String>(
                      value: controller.themeMode,
                      items: <ComboBoxItem<String>>[
                        ComboBoxItem<String>(
                          value: 'system',
                          child: Text(strings.themeSystem),
                        ),
                        ComboBoxItem<String>(
                          value: 'light',
                          child: Text(strings.themeLight),
                        ),
                        ComboBoxItem<String>(
                          value: 'dark',
                          child: Text(strings.themeDark),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) controller.setThemeMode(value);
                      },
                    ),
                  ),
                  SettingsCard(
                    icon: FluentIcons.power_button,
                    title: strings.startWithWindows,
                    description: strings.startWithWindowsDescription,
                    trailing: ToggleSwitch(
                      checked: controller.startWithWindows,
                      onChanged: (enabled) =>
                          controller.setStartWithWindows(enabled),
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: strings.settingsModes,
                children: <Widget>[
                  ExpertModeCard(controller: controller),
                  SettingsCard(
                    icon: FluentIcons.test_beaker,
                    title: strings.dryRunMode,
                    description: strings.dryRunDescription,
                    trailing: ToggleSwitch(
                      checked: controller.isDryRunMode,
                      onChanged: controller.setDryRunMode,
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: strings.updates,
                children: <Widget>[
                  SettingsCard(
                    icon: FluentIcons.ringer,
                    title: strings.automaticUpdateNotifications,
                    description: strings.automaticUpdateDescription,
                    trailing: ToggleSwitch(
                      checked: controller.automaticUpdateChecksEnabled,
                      onChanged: controller.setAutomaticUpdateChecksEnabled,
                    ),
                  ),
                  SettingsCard(
                    icon: FluentIcons.sync,
                    title: updateStatus,
                    description: update != null
                        ? strings.updateAvailableDescription
                        : null,
                    trailing: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        if (update != null) ...<Widget>[
                          Button(
                            onPressed: widget.onViewRelease,
                            child: Text(strings.viewRelease),
                          ),
                          FilledButton(
                            onPressed: update.installerUrl == null
                                ? null
                                : widget.onInstallUpdate,
                            child: Text(strings.updateNow),
                          ),
                        ],
                        Button(
                          onPressed: controller.isCheckingForUpdates
                              ? null
                              : widget.onCheckForUpdates,
                          child: controller.isCheckingForUpdates
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: ProgressRing(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(strings.checking),
                                  ],
                                )
                              : Text(strings.checkNow),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: strings.settingsMaintenance,
                children: <Widget>[
                  SettingsCard(
                    icon: FluentIcons.folder_open,
                    title: strings.openLogFolder,
                    description: strings.openLogFolderDescription,
                    trailing: action(
                      strings.openLogFolder,
                      controller.openLogFolder,
                    ),
                  ),
                  SettingsCard(
                    icon: FluentIcons.refresh,
                    title: strings.redetectSystemState,
                    description: strings.redetectSystemStateDescription,
                    trailing: action(
                      strings.redetectSystemState,
                      controller.redetectSystemState,
                    ),
                  ),
                  SettingsCard(
                    icon: FluentIcons.save,
                    title: strings.profileTitle,
                    description: strings.profileDescription,
                    trailing: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        action(strings.exportProfile, controller.exportProfile),
                        action(strings.importProfile, controller.importProfile),
                      ],
                    ),
                  ),
                  SettingsCard(
                    icon: FluentIcons.reset,
                    title: strings.resetAppSettings,
                    description: strings.resetAppSettingsDescription,
                    trailing: _isRunningOperation
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: ProgressRing(strokeWidth: 2),
                          )
                        : action(
                            strings.resetAppSettings,
                            controller.resetAppSettings,
                          ),
                  ),
                ],
              ),
              SettingsSection(
                title: strings.settingsAbout,
                children: <Widget>[
                  SettingsCard(
                    icon: FluentIcons.info,
                    title: 'ZapTweaks v${controller.appVersion}',
                    description: strings.aboutDescription,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _runOperation(
    BuildContext context,
    Future<dynamic> Function() action,
  ) async {
    setState(() => _isRunningOperation = true);
    final dynamic result;
    try {
      result = await action();
    } finally {
      if (mounted) {
        setState(() => _isRunningOperation = false);
      }
    }
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

/// Expert mode switch, shown on Home and in Settings so it is easy to find.
class ExpertModeCard extends StatelessWidget {
  const ExpertModeCard({required this.controller, super.key});

  final TweakController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => SettingsCard(
        icon: FluentIcons.developer_tools,
        title: strings.expertMode,
        description: strings.expertModeDescription,
        trailing: ToggleSwitch(
          checked: controller.expertModeEnabled,
          onChanged: controller.setExpertModeEnabled,
          content: Text(
            controller.expertModeEnabled
                ? strings.expertModeOn
                : strings.expertModeOff,
          ),
        ),
      ),
    );
  }
}
