import 'dart:io';

import '../../../app/widgets/ui_kit.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/operations/trace_cleanup_operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/persistence/operation_store.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/cleanup_preview.dart';
import '../../tweaks/application/tweak_controller.dart';

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({
    required this.controller,
    this.cleanupScanner = const CleanupScanner(),
    this.journal,
    this.shaderCacheDirectories = defaultShaderCacheDirectories,
    this.crashReportDirectories = defaultCrashReportDirectories,
    this.browserCacheDirectories = defaultBrowserCacheDirectories,
    this.listRunningBrowsers = runningBrowsers,
    super.key,
  });

  final TweakController controller;
  final CleanupScanner cleanupScanner;
  final OperationStore? journal;
  final List<Directory> Function() shaderCacheDirectories;
  final List<Directory> Function() crashReportDirectories;
  final List<Directory> Function() browserCacheDirectories;
  final Future<List<String>> Function() listRunningBrowsers;

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  String? _busy;
  String? _message;
  bool _success = false;

  Future<void> _run(
    String id, {
    bool confirm = true,
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    final strings = AppLocalizations.of(context);
    if (confirm) {
      final confirmed = await confirmAction(
        context,
        title: strings.confirmSystemRepair,
        message: strings.systemRepairWarning,
        confirmLabel: strings.continueAction,
      );
      if (confirmed != true || !mounted) return;
    }
    if (!mounted) return;
    setState(() {
      _busy = id;
      _message = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[
          OperationRequest(
            operationId: id,
            desiredValue: true,
            parameters: parameters,
          ),
        ],
      );
      _success =
          plan.status == PlanStatus.completed &&
          plan.items.length == 1 &&
          plan.items.single.status == PlanItemStatus.verified;
      _message = _success
          ? switch (id) {
              'diagnostics.etw.capture' => strings.etwTraceSaved(
                plan.items.single.written?.message ?? '',
              ),
              'diagnostics.trace.cleanup' => strings.cleanupTracesCompleted,
              'cleanup.shader_cache' => strings.cleanupShaderCacheCompleted,
              'cleanup.crash_reports' => strings.cleanupCrashReportsCompleted,
              'cleanup.browser_cache' => strings.cleanupBrowserCacheCompleted,
              _ => strings.systemRepairVerified,
            }
          : plan.items.single.error ?? strings.operationFailed;
    } catch (error) {
      _success = false;
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _openJournal() async {
    final journal = widget.journal;
    if (journal == null || _busy != null) return;
    final strings = AppLocalizations.of(context);
    setState(() {
      _busy = 'journal';
      _message = null;
    });
    try {
      // shortcut: shows the latest 100 plans; add paging if older history is needed.
      final plans = journal.database
          .select('SELECT id FROM plans ORDER BY created_at DESC LIMIT 100')
          .map((row) => journal.load(row['id'] as String)!)
          .toList();
      final selected = await showDialog<OperationPlan>(
        context: context,
        builder: (context) => ContentDialog(
          constraints: const BoxConstraints(maxWidth: 680),
          title: Text(strings.openRecoveryHistory),
          content: SizedBox(
            height: 420,
            child: ListView(
              children: [
                if (plans.isEmpty) Text(strings.noSearchResults),
                for (final plan in plans) ...[
                  Text(
                    '${plan.createdAt.toLocal()} · ${plan.status.name}\n${plan.id}',
                  ),
                  for (final item in plan.items) ...[
                    Text(
                      '${item.operationId}${item.request.target == null ? '' : ' / ${item.request.target}'} · ${item.status.name}',
                    ),
                    if (item.error != null) SelectableText(item.error!),
                  ],
                  if (widget.controller.canRestoreManualPlan(plan))
                    Button(
                      onPressed: () => Navigator.pop(context, plan),
                      child: Text(strings.manualRestoreTitle),
                    ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.close),
            ),
          ],
        ),
      );
      if (selected == null || !mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ContentDialog(
          title: Text(strings.manualRestoreTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.manualRestoreWarning),
                for (final item in selected.items)
                  Text(
                    '${item.operationId}${item.request.target == null ? '' : ' / ${item.request.target}'}: ${item.written?.value} → ${item.snapshot?.expectedAfterRollback.value ?? item.snapshot?.expectedAfterRollback.kind.name}',
                  ),
              ],
            ),
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.continueAction),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      final restored = await widget.controller.restoreManualPlan(selected.id);
      _success = restored.status == PlanStatus.rolledBack;
      _message = _success
          ? strings.operationCompleted
          : restored.items
                .map((item) => item.error)
                .whereType<String>()
                .join('\n');
    } catch (error) {
      _success = false;
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _previewAndCleanup({bool userTemp = false}) async {
    if (_busy != null) return;
    final strings = AppLocalizations.of(context);
    setState(() {
      _busy = userTemp ? 'cleanup.user_temp' : 'diagnostics.trace.cleanup';
      _message = null;
    });
    try {
      final directory = userTemp
          ? defaultUserTempDirectory()
          : defaultTraceDirectory();
      final preview = await widget.cleanupScanner.scanDirectory(
        directory,
        category: userTemp ? 'UserTemp' : 'ZapTweaks traces',
        reason: userTemp
            ? strings.cleanupUserTempDescription
            : 'User-requested diagnostic trace cleanup',
      );
      if (!mounted) return;
      if (!preview.complete) {
        setState(() {
          _success = false;
          _message = preview.errors.join('\n');
        });
        return;
      }
      if (preview.candidates.isEmpty) {
        setState(() {
          _success = true;
          _message = userTemp
              ? strings.cleanupUserTempNone
              : strings.noDiagnosticTraces;
        });
        return;
      }
      final selected = <String>{};
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, updateDialog) => ContentDialog(
            constraints: const BoxConstraints(maxWidth: 680),
            title: Text(
              userTemp
                  ? strings.cleanupUserTemp
                  : strings.cleanupDiagnosticTraces,
            ),
            content: SizedBox(
              width: 600,
              height: 320,
              child: ListView(
                children: <Widget>[
                  Text(
                    userTemp
                        ? strings.cleanupPreviewCount(
                            preview.candidates.length,
                            preview.totalBytes,
                          )
                        : strings.cleanupTracePreview(
                            preview.candidates.length,
                            preview.totalBytes,
                          ),
                  ),
                  Text(strings.cleanupPermanentWarning),
                  if (userTemp) Text(strings.cleanupUserTempSelectionHint),
                  const SizedBox(height: 12),
                  for (final item in preview.candidates) ...<Widget>[
                    Text('${item.category} — ${item.size} bytes'),
                    if (userTemp)
                      Checkbox(
                        checked: selected.contains(item.path),
                        content: Expanded(child: Text(item.path)),
                        onChanged: (value) => updateDialog(() {
                          if (value == true) {
                            selected.add(item.path);
                          } else {
                            selected.remove(item.path);
                          }
                        }),
                      )
                    else
                      SelectableText(item.path),
                    Text(item.reason),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              Button(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: userTemp && selected.isEmpty
                    ? null
                    : () => Navigator.pop(context, true),
                child: Text(strings.delete),
              ),
            ],
          ),
        ),
      );
      if (!mounted || confirmed != true) return;
      await _run(
        userTemp ? 'cleanup.user_temp' : 'diagnostics.trace.cleanup',
        confirm: false,
        parameters: <String, Object?>{
          'preview': preview.candidates
              .where((item) => !userTemp || selected.contains(item.path))
              .map((item) => item.toJson())
              .toList(),
        },
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _success = false;
          _message = error.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  /// Preview, confirm and delete the files of a fixed list of folders (shader caches, crash reports, browser caches).
  /// [blocker] returns a message when the cleanup must not start now (a browser is open).
  Future<void> _previewFixedRootsCleanup({
    required String id,
    required String title,
    required String description,
    required String none,
    required List<Directory> Function() roots,
    Future<String?> Function()? blocker,
  }) async {
    if (_busy != null) return;
    final strings = AppLocalizations.of(context);
    setState(() {
      _busy = id;
      _message = null;
    });
    try {
      final blocked = await blocker?.call();
      if (blocked != null) {
        if (mounted) {
          setState(() {
            _success = false;
            _message = blocked;
          });
        }
        return;
      }
      final candidates = <CleanupCandidate>[];
      final errors = <String>[];
      for (final root in roots()) {
        final preview = await widget.cleanupScanner.scanDirectory(
          root,
          category: title,
          reason: description,
        );
        candidates.addAll(preview.candidates);
        errors.addAll(preview.errors);
      }
      if (!mounted) return;
      // Like the other cleanups, an incomplete preview is never offered: a program holding files open must be closed first.
      if (errors.isNotEmpty || candidates.isEmpty) {
        setState(() {
          _success = errors.isEmpty;
          _message = errors.isEmpty
              ? none
              : <String>[
                  ...errors.take(5),
                  if (errors.length > 5) '… (+${errors.length - 5})',
                ].join('\n');
        });
        return;
      }
      final byRoot = <String, List<CleanupCandidate>>{};
      for (final item in candidates) {
        byRoot.putIfAbsent(item.rootCanonical, () => []).add(item);
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => ContentDialog(
          constraints: const BoxConstraints(maxWidth: 680),
          title: Text(title),
          content: SizedBox(
            width: 600,
            height: 320,
            child: ListView(
              children: <Widget>[
                Text(
                  strings.cleanupPreviewCount(
                    candidates.length,
                    candidates.fold(0, (sum, item) => sum + item.size),
                  ),
                ),
                Text(strings.cleanupPermanentWarning),
                const SizedBox(height: 12),
                for (final MapEntry(key: root, value: items)
                    in byRoot.entries) ...<Widget>[
                  SelectableText(root),
                  Text(
                    strings.cleanupPreviewCount(
                      items.length,
                      items.fold(0, (sum, item) => sum + item.size),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            Button(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.delete),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
      await _run(
        id,
        confirm: false,
        parameters: <String, Object?>{
          'preview': candidates.map((item) => item.toJson()).toList(),
        },
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _success = false;
          _message = error.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    // The result stays above the list, visible after acting on a card further down.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_message != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: InfoBar(
              title: Text(
                _success ? strings.operationCompleted : strings.operationFailed,
              ),
              content: Text(_message!),
              severity: _success
                  ? InfoBarSeverity.success
                  : InfoBarSeverity.error,
            ),
          ),
        Expanded(child: _cards(strings)),
      ],
    );
  }

  Widget _cards(AppLocalizations strings) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        _repairCard(
          strings.openRecoveryHistory,
          strings.manualRestoreWarning,
          'journal',
          actionLabel: strings.openRecoveryHistory,
          onRun: widget.journal == null ? null : _openJournal,
          available: widget.journal != null,
        ),
        _repairCard(
          strings.repairComponentStore,
          strings.repairComponentStoreDescription,
          'recovery.dism.restore_health',
        ),
        _repairCard(
          strings.repairSystemFiles,
          strings.repairSystemFilesDescription,
          'recovery.sfc.scan_now',
        ),
        _repairCard(
          strings.captureEtwTrace,
          strings.captureEtwTraceDescription,
          'diagnostics.etw.capture',
          onRun: () => _run(
            'diagnostics.etw.capture',
            confirm: false,
            parameters: const <String, Object?>{'durationSeconds': 15},
          ),
          actionLabel: strings.startCapture,
        ),
        _repairCard(
          strings.cleanupDiagnosticTraces,
          strings.cleanupDiagnosticTracesDescription,
          'diagnostics.trace.cleanup',
          onRun: _previewAndCleanup,
          actionLabel: strings.cleanupPreview,
        ),
        _repairCard(
          strings.cleanupUserTemp,
          strings.cleanupUserTempDescription,
          'cleanup.user_temp',
          onRun: () => _previewAndCleanup(userTemp: true),
          actionLabel: strings.cleanupSelectFiles,
        ),
        _repairCard(
          strings.cleanupShaderCache,
          strings.cleanupShaderCacheDescription,
          'cleanup.shader_cache',
          onRun: () => _previewFixedRootsCleanup(
            id: 'cleanup.shader_cache',
            title: strings.cleanupShaderCache,
            description: strings.cleanupShaderCacheDescription,
            none: strings.cleanupShaderCacheNone,
            roots: widget.shaderCacheDirectories,
          ),
          actionLabel: strings.cleanupPreview,
        ),
        _repairCard(
          strings.cleanupCrashReports,
          strings.cleanupCrashReportsDescription,
          'cleanup.crash_reports',
          onRun: () => _previewFixedRootsCleanup(
            id: 'cleanup.crash_reports',
            title: strings.cleanupCrashReports,
            description: strings.cleanupCrashReportsDescription,
            none: strings.cleanupCrashReportsNone,
            roots: widget.crashReportDirectories,
          ),
          actionLabel: strings.cleanupPreview,
        ),
        _repairCard(
          strings.cleanupBrowserCache,
          strings.cleanupBrowserCacheDescription,
          'cleanup.browser_cache',
          onRun: () => _previewFixedRootsCleanup(
            id: 'cleanup.browser_cache',
            title: strings.cleanupBrowserCache,
            description: strings.cleanupBrowserCacheDescription,
            none: strings.cleanupBrowserCacheNone,
            roots: widget.browserCacheDirectories,
            blocker: () async {
              final open = await widget.listRunningBrowsers();
              return open.isEmpty
                  ? null
                  : strings.cleanupBrowserRunning(open.join(', '));
            },
          ),
          actionLabel: strings.cleanupPreview,
        ),
        InfoBar(
          title: Text(strings.cleanupRecycleUnavailable),
          severity: InfoBarSeverity.info,
        ),
      ],
    );
  }

  Widget _repairCard(
    String title,
    String description,
    String id, {
    VoidCallback? onRun,
    String? actionLabel,
    bool available = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: SettingsCard(
      title: title,
      description: description,
      trailing: _busy == id
          ? const SizedBox(
              width: 20,
              height: 20,
              child: ProgressRing(strokeWidth: 2),
            )
          : Button(
              onPressed: _busy == null && available
                  ? onRun ?? () => _run(id)
                  : null,
              child: Text(
                actionLabel ?? AppLocalizations.of(context).runRepair,
              ),
            ),
    ),
  );
}
