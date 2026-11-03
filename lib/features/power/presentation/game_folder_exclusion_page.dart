import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';
import '../../../core/operations/defender_exclusion_operation.dart';
import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/folder_picker.dart';
import '../../../platform/windows/game_folder_facts.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../application/defender_exclusion_records.dart';
import '../domain/game_folder_policy.dart';

/// Manual-only Defender exclusion for the folder of one game.
class GameFolderExclusionPage extends StatefulWidget {
  const GameFolderExclusionPage({required this.controller, super.key});
  final TweakController controller;

  @override
  State<GameFolderExclusionPage> createState() =>
      _GameFolderExclusionPageState();
}

class _GameFolderExclusionPageState extends State<GameFolderExclusionPage> {
  final _records = DefenderExclusionRecords.instance;
  DefenderStatus? _status;
  bool _statusFailed = false;
  bool _busy = false;
  String? _message;
  InfoBarSeverity _severity = InfoBarSeverity.info;

  @override
  void initState() {
    super.initState();
    _records.load();
    _readStatus();
  }

  Future<void> _readStatus() async {
    try {
      final status = await DefenderStatus.read(
        widget.controller.processRunner.runPowerShellForOutput,
      );
      if (mounted) setState(() => _status = status);
    } catch (_) {
      if (mounted) setState(() => _statusFailed = true);
    }
  }

  String? _statusBlocker(AppLocalizations strings) {
    final status = _status;
    if (_statusFailed) return strings.defenderStatusUnknown;
    if (status == null) return null;
    if (status.mode != 'Normal') return strings.defenderNotActive;
    if (!status.realTime) return strings.defenderRealTimeOff;
    if (status.localExclusionsIgnored) return strings.defenderExclusionsIgnored;
    return null;
  }

  static String refusalText(AppLocalizations strings, GameFolderRefusal r) =>
      switch (r) {
        GameFolderRefusal.notLocal => strings.gameFolderRefusedNotLocal,
        GameFolderRefusal.missing => strings.gameFolderRefusedMissing,
        GameFolderRefusal.notDirectory => strings.gameFolderRefusedNotDirectory,
        GameFolderRefusal.link => strings.gameFolderRefusedLink,
        GameFolderRefusal.driveRoot => strings.gameFolderRefusedDriveRoot,
        GameFolderRefusal.protectedFolder => strings.gameFolderRefusedProtected,
      };

  void _show(String message, InfoBarSeverity severity) => setState(() {
    _message = message;
    _severity = severity;
  });

  Future<void> _choose() async {
    final strings = AppLocalizations.of(context);
    final picked = pickFolder(title: strings.gameFolderExclusionPickerTitle);
    if (picked == null || !mounted) return;
    final check = checkGameFolder(picked, windowsGameFolderFacts());
    if (!check.allowed) {
      _show(refusalText(strings, check.refusal!), InfoBarSeverity.error);
      return;
    }
    if (check.warning != null &&
        !await confirmAction(
          context,
          title: strings.gameFolderExclusionLauncherTitle,
          message:
              '${check.path}\n\n${strings.gameFolderExclusionLauncherWarning}',
          confirmLabel: strings.gameFolderExclusionLauncherConfirm,
          destructive: true,
        )) {
      return;
    }
    if (!mounted) return;
    final confirmed = await confirmAction(
      context,
      title: strings.gameFolderExclusionConfirmTitle,
      message:
          '${check.path}\n\n${strings.gameFolderExclusionClaim}\n\n'
          '${strings.gameFolderExclusionSecurityWarning}',
      confirmLabel: strings.gameFolderExclusionConfirm,
    );
    if (!confirmed || !mounted) return;
    await _run(
      OperationRequest(
        operationId: DefenderGameFolderExclusionOperation.operationId,
        target: check.path,
        desiredValue: true,
        parameters: <String, Object?>{
          if (check.warning != null) 'acknowledgedWarning': check.warning!.name,
        },
      ),
      onDone: () => _records.add(check.path),
      success: strings.gameFolderExclusionAdded,
    );
  }

  Future<void> _remove(String path) => _run(
    OperationRequest(
      operationId: DefenderGameFolderExclusionOperation.operationId,
      target: path,
      desiredValue: false,
    ),
    onDone: () => _records.remove(path),
    success: AppLocalizations.of(context).gameFolderExclusionRemoved,
  );

  Future<void> _run(
    OperationRequest request, {
    required Future<void> Function() onDone,
    required String success,
  }) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[request],
      );
      if (plan.status != PlanStatus.completed) {
        throw StateError(plan.items.single.error ?? 'Operation failed.');
      }
      await onDone();
      if (mounted) _show(success, InfoBarSeverity.success);
    } catch (error) {
      if (mounted) _show('$error', InfoBarSeverity.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    final blocker = _statusBlocker(strings);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text(strings.gameFolderExclusionTitle, style: theme.typography.title),
        const SizedBox(height: 6),
        Text(strings.gameFolderExclusionDescription),
        const SizedBox(height: 12),
        InfoBar(
          title: Text(strings.gameFolderExclusionClaim),
          severity: InfoBarSeverity.warning,
        ),
        const SizedBox(height: 8),
        Text(strings.gameFolderExclusionSecurityWarning),
        const SizedBox(height: 16),
        if (blocker != null) ...<Widget>[
          InfoBar(title: Text(blocker), severity: InfoBarSeverity.error),
          const SizedBox(height: 12),
        ],
        Row(
          children: <Widget>[
            FilledButton(
              onPressed:
                  _busy ||
                      blocker != null ||
                      (_status == null && !_statusFailed)
                  ? null
                  : _choose,
              child: Text(strings.gameFolderExclusionChoose),
            ),
            if (_busy) ...<Widget>[
              const SizedBox(width: 12),
              const SizedBox(width: 20, height: 20, child: ProgressRing()),
            ],
          ],
        ),
        if (_message != null) ...<Widget>[
          const SizedBox(height: 12),
          InfoBar(title: Text(_message!), severity: _severity),
        ],
        const SizedBox(height: 24),
        SettingsSection(
          title: strings.gameFolderExclusionManaged,
          children: <Widget>[
            ValueListenableBuilder<List<String>>(
              valueListenable: _records.paths,
              builder: (context, paths, _) => paths.isEmpty
                  ? Text(strings.gameFolderExclusionNone)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          strings.gameFolderExclusionClaim,
                          style: theme.typography.caption,
                        ),
                        const SizedBox(height: 8),
                        for (final path in paths)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Card(
                              child: Row(
                                children: <Widget>[
                                  const Icon(FluentIcons.folder),
                                  const SizedBox(width: 10),
                                  Expanded(child: SelectableText(path)),
                                  Button(
                                    onPressed: _busy
                                        ? null
                                        : () => _remove(path),
                                    child: Text(
                                      strings.gameFolderExclusionRemove,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Reminder shown above every Gaming & Performance tab while ZapTweaks
/// keeps at least one Defender exclusion.
class DefenderExclusionReminder extends StatefulWidget {
  const DefenderExclusionReminder({super.key});

  @override
  State<DefenderExclusionReminder> createState() =>
      _DefenderExclusionReminderState();
}

class _DefenderExclusionReminderState extends State<DefenderExclusionReminder> {
  @override
  void initState() {
    super.initState();
    DefenderExclusionRecords.instance.load();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<String>>(
    valueListenable: DefenderExclusionRecords.instance.paths,
    builder: (context, paths, _) => paths.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: InfoBar(
              title: Text(
                AppLocalizations.of(
                  context,
                ).gameFolderExclusionReminder(paths.length),
              ),
              severity: InfoBarSeverity.warning,
            ),
          ),
  );
}
