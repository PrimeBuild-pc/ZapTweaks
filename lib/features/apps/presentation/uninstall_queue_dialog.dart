import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';
import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/plans/restore_point.dart';
import '../../../l10n/app_localizations.dart';
import '../application/leftover_scanner.dart';
import '../application/running_processes.dart';
import '../application/uninstall_command.dart';
import '../application/uninstall_queue.dart';
import '../domain/app_package.dart';
import 'leftover_review_dialog.dart';

typedef PlanExecutor =
    Future<OperationPlan> Function(List<OperationRequest> requests);

enum _Phase { preview, restorePoint, restoreFailed, running, finished }

/// Preview → restore point → one-at-a-time uninstall. Nothing runs before
/// the user presses Start, and nothing runs without a restore point unless
/// the queue is a simulation.
class UninstallQueueDialog extends StatefulWidget {
  const UninstallQueueDialog({
    required this.apps,
    required this.execute,
    required this.listProcesses,
    this.environment,
    this.fileExists,
    this.scanLeftovers,
    super.key,
  });

  final List<AppPackage> apps;
  final PlanExecutor execute;
  final Future<List<RunningProcess>> Function() listProcesses;
  final Map<String, String>? environment;
  final bool Function(String path)? fileExists;

  /// Leftover scan for one uninstalled program (read-only).
  final Future<List<Leftover>> Function(LeftoverQuery query)? scanLeftovers;

  @override
  State<UninstallQueueDialog> createState() => _UninstallQueueDialogState();
}

class _UninstallQueueDialogState extends State<UninstallQueueDialog> {
  late final UninstallQueue _queue;
  _Phase _phase = _Phase.preview;
  bool _simulate = false;
  String? _error;
  Map<String, List<String>> _busyFolders = const {};

  @override
  void initState() {
    super.initState();
    final environment = widget.environment ?? Platform.environment;
    _queue = UninstallQueue.build(
      widget.apps,
      environment: environment,
      fileExists: widget.fileExists ?? (path) => File(path).existsSync(),
    )..addListener(_changed);
    // A failed process list only hides the "still running" warning.
    widget.listProcesses().catchError((Object _) => const <Never>[]).then((
      processes,
    ) {
      if (!mounted) return;
      setState(
        () => _busyFolders = <String, List<String>>{
          for (final app in widget.apps)
            if (app.installLocation != null)
              app.packageId: processesUnder(
                processes,
                expandEnvironment(app.installLocation!, environment) ?? '',
              ),
        },
      );
    });
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _queue.removeListener(_changed);
    super.dispose();
  }

  Future<void> _start({bool enableProtection = false}) async {
    if (_simulate) return _run();
    setState(() {
      _phase = _Phase.restorePoint;
      _error = null;
    });
    final error = await createRestorePoint(
      widget.execute,
      description: 'ZapTweaks before uninstall',
      enableProtection: enableProtection,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _phase = _Phase.restoreFailed;
        _error = error;
      });
      return;
    }
    await _run();
  }

  Future<void> _run() async {
    setState(() => _phase = _Phase.running);
    await _queue.run((item) async {
      if (_simulate) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return null;
      }
      final plan = await widget.execute(<OperationRequest>[item.request]);
      final result = plan.items.single;
      return result.status == PlanItemStatus.verified
          ? null
          : result.error ?? result.status.name;
    });
    if (mounted) setState(() => _phase = _Phase.finished);
  }

  Future<void> _reviewLeftovers() => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => LeftoverReviewDialog(
      execute: widget.execute,
      load: () async => <Leftover>[
        for (final item in _queue.items.where(
          (i) => i.status == QueueStatus.done,
        ))
          ...await widget.scanLeftovers!(
            LeftoverQuery(
              name: item.app.name,
              publisher: item.app.publisher,
              installLocation: item.app.installLocation == null
                  ? null
                  : expandEnvironment(
                      item.app.installLocation!,
                      widget.environment ?? Platform.environment,
                    ),
              uninstallKey: item.app.packageId,
            ),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    final runnable = _queue.items.any((i) => i.status == QueueStatus.waiting);
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
      title: Text(strings.uninstallQueueTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_phase == _Phase.preview) ...<Widget>[
            Text(strings.uninstallRestorePointNote),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Checkbox(
                  checked: _simulate,
                  onChanged: (value) =>
                      setState(() => _simulate = value ?? false),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _simulate = !_simulate),
                    child: Text(strings.uninstallSimulate),
                  ),
                ),
              ],
            ),
          ],
          if (_phase == _Phase.restorePoint)
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: ProgressRing(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(strings.restorePointCreating),
              ],
            ),
          if (_phase == _Phase.restoreFailed)
            InfoBar(
              title: Text(strings.restorePointFailed),
              content: _error == null ? null : Text(_error!),
              severity: InfoBarSeverity.error,
              isLong: true,
            ),
          if (_simulate && _phase == _Phase.finished)
            InfoBar(
              title: Text(strings.queueSimulated),
              severity: InfoBarSeverity.info,
            ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _queue.items.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final item = _queue.items[index];
                final busy = _busyFolders[item.app.packageId] ?? const [];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.app.name,
                              style: theme.typography.bodyStrong,
                            ),
                            Text(
                              _mode(strings, item),
                              style: theme.typography.caption,
                            ),
                            if (item.manualCommandLine != null)
                              SelectableText(
                                item.manualCommandLine!,
                                style: theme.typography.caption,
                              ),
                            if (busy.isNotEmpty)
                              Text(
                                strings.uninstallRunningWarning(
                                  busy.join(', '),
                                ),
                                style: theme.typography.caption?.copyWith(
                                  color: StatusBadge.critical,
                                ),
                              ),
                            if (item.message != null &&
                                item.status == QueueStatus.failed)
                              Text(
                                item.message!,
                                style: theme.typography.caption,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _status(strings, item.status),
                      if (item.status == QueueStatus.waiting &&
                          _phase != _Phase.finished) ...<Widget>[
                        const SizedBox(width: 8),
                        Button(
                          onPressed: () => _queue.skip(index),
                          child: Text(strings.queueSkip),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: <Widget>[
        if (_phase == _Phase.preview) ...<Widget>[
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(StatusBadge.critical),
            ),
            onPressed: runnable ? _start : null,
            child: Text(strings.uninstallStart),
          ),
        ],
        if (_phase == _Phase.restoreFailed) ...<Widget>[
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => _start(enableProtection: true),
            child: Text(strings.restorePointEnableAndRetry),
          ),
        ],
        if (_phase == _Phase.running)
          Button(onPressed: _queue.stop, child: Text(strings.queueStop)),
        if (_phase == _Phase.finished &&
            !_simulate &&
            widget.scanLeftovers != null &&
            _queue.items.any((i) => i.status == QueueStatus.done))
          Button(
            onPressed: _reviewLeftovers,
            child: Text(strings.leftoverSearch),
          ),
        if (_phase == _Phase.finished)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.close),
          ),
      ],
    );
  }

  static String _mode(AppLocalizations strings, QueueItem item) =>
      switch (item.plan) {
        UninstallCommand(:final silent) =>
          silent ? strings.uninstallModeSilent : strings.uninstallModeWindowed,
        UninstallManual(:final reason) => switch (reason) {
          UninstallManualReason.noUninstaller =>
            strings.uninstallManualNoUninstaller,
          UninstallManualReason.unsafeCommand => strings.uninstallManualUnsafe,
          UninstallManualReason.notFound => strings.uninstallManualNotFound,
        },
      };

  static Widget _status(AppLocalizations strings, QueueStatus status) =>
      switch (status) {
        QueueStatus.waiting => StatusBadge(strings.queueWaiting),
        QueueStatus.running => StatusBadge(
          strings.queueRunning,
          tone: BadgeTone.caution,
        ),
        QueueStatus.done => StatusBadge(
          strings.queueDone,
          tone: BadgeTone.positive,
        ),
        QueueStatus.failed => StatusBadge(
          strings.queueFailed,
          tone: BadgeTone.critical,
        ),
        QueueStatus.skipped => StatusBadge(strings.queueSkipped),
      };
}
