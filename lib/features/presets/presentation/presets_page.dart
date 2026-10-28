import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:win32/win32.dart' show FOLDERID_Documents;

import '../../../app/widgets/ui_kit.dart';
import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/plans/restore_point.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/known_folder.dart';
import '../../apps/application/service_inventory.dart';
import '../../apps/application/windows_app_inventory_service.dart';
import '../../apps/domain/app_package.dart';
import '../../apps/domain/appx_candidate_policy.dart';
import '../../apps/domain/service_safety_policy.dart';
import '../../apps/presentation/service_list_page.dart' show serviceReasonLabel;
import '../application/preset_preview.dart';
import '../application/startup_inventory.dart';
import '../application/user_presets.dart';
import '../domain/preset_catalog.dart';

typedef InspectRequests =
    Future<List<({SupportResult support, OperationState before})>> Function(
      List<OperationRequest> requests,
    );

enum _Phase {
  idle,
  loading,
  preview,
  restorePoint,
  restoreFailed,
  applying,
  report,
}

/// Presets: full description first, then a preview computed on this PC,
/// a mandatory restore point, three plans (admin, user settings, user apps)
/// and an exact undo for everything but removed apps.
class PresetsPage extends StatefulWidget {
  const PresetsPage({
    required this.execute,
    required this.inspect,
    required this.rollback,
    this.loadFacts,
    this.folder,
    super.key,
  });

  final Future<OperationPlan> Function(List<OperationRequest> requests) execute;
  final InspectRequests inspect;
  final Future<OperationPlan> Function(OperationPlan plan) rollback;
  final Future<PresetFacts> Function(Preset preset)? loadFacts;
  final Directory? folder;

  @override
  State<PresetsPage> createState() => _PresetsPageState();
}

class _PresetsPageState extends State<PresetsPage> {
  Preset _preset = builtInPresets.first;
  List<({File file, Preset? preset, String? error})> _user = const [];
  List<PreviewLine>? _lines;
  final _excluded = <String>{};
  final _name = TextEditingController();
  bool _consent = false;
  _Phase _phase = _Phase.idle;
  String? _error;
  String? _info;
  List<OperationPlan> _undoable = const <OperationPlan>[];

  Directory get _folder =>
      widget.folder ??
      userPresetFolder(
        Platform.environment,
        documents: knownFolderPath(FOLDERID_Documents),
      );

  @override
  void initState() {
    super.initState();
    _reloadUser();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _reloadUser() => setState(() => _user = loadUserPresets(_folder));

  void _select(Preset preset) => setState(() {
    _preset = preset;
    _lines = null;
    _excluded.clear();
    _consent = false;
    _phase = _Phase.idle;
    _error = null;
    _info = null;
    _undoable = const <OperationPlan>[];
  });

  Future<PresetFacts> _defaultFacts(Preset preset) async {
    final runner = ProcessRunner.shared;
    final tweaks = <OperationRequest>[
      for (final item in preset.items)
        if (item is TweakPresetItem)
          OperationRequest(
            operationId: item.operationId,
            desiredValue: item.desiredValue,
          ),
    ];
    final results = await Future.wait<Object>(<Future<Object>>[
      WindowsAppInventoryService(processRunner: runner).scanCurrentUser(),
      listServices(runner),
      listStartupEntries(runner),
      widget.inspect(tweaks),
    ]);
    final apps = results[0] as AppInventoryResult;
    final states =
        results[3] as List<({SupportResult support, OperationState before})>;
    return PresetFacts(
      installedAppx: <String>{
        for (final app in apps.packages)
          if (app.canRemoveAppx &&
              app.scopes.contains(AppInstallScope.currentUser))
            app.packageId,
      },
      services: <String, ServiceEntry>{
        for (final service in results[1] as List<ServiceEntry>)
          service.name.toLowerCase(): service,
      },
      startup: results[2] as List<StartupEntry>,
      tweaks: <String, ({SupportResult support, OperationState before})>{
        for (var i = 0; i < tweaks.length; i++)
          tweaks[i].operationId: states[i],
      },
    );
  }

  Future<void> _preview() async {
    setState(() {
      _phase = _Phase.loading;
      _error = null;
      _info = null;
    });
    try {
      final facts = await (widget.loadFacts ?? _defaultFacts)(_preset);
      if (!mounted) return;
      setState(() {
        _lines = buildPresetPreview(_preset, facts);
        _phase = _Phase.preview;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = '$error';
          _phase = _Phase.idle;
        });
      }
    }
  }

  Future<void> _apply({bool enableProtection = false}) async {
    final plans = presetPlans(_lines!, excluded: _excluded);
    setState(() {
      _phase = _Phase.restorePoint;
      _error = null;
    });
    final error = await createRestorePoint(
      widget.execute,
      description: 'ZapTweaks before preset',
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
    setState(() => _phase = _Phase.applying);
    var ok = 0, failed = 0;
    final errors = <String>[];
    final undoable = <OperationPlan>[];
    for (final (requests, canUndo) in <(List<OperationRequest>, bool)>[
      (plans.admin, true),
      (plans.userSettings, true),
      (plans.userApps, false),
    ]) {
      if (requests.isEmpty) continue;
      try {
        final plan = await widget.execute(requests);
        for (final item in plan.items) {
          if (plan.status == PlanStatus.dryRunComplete ||
              item.status == PlanItemStatus.verified ||
              item.status == PlanItemStatus.pendingRestart) {
            ok++;
          } else {
            failed++;
            if (item.error != null) {
              errors.add(
                '${item.request.target ?? item.operationId}: ${item.error}',
              );
            }
          }
        }
        if (canUndo) undoable.add(plan);
      } catch (error) {
        failed += requests.length;
        errors.add('$error');
      }
    }
    if (!mounted) return;
    final strings = AppLocalizations.of(context);
    setState(() {
      _phase = _Phase.report;
      _undoable = undoable;
      _info = strings.presetReport(ok, failed);
      _error = errors.isEmpty ? null : errors.join('\n');
    });
  }

  Future<void> _undo() async {
    setState(() => _phase = _Phase.applying);
    final errors = <String>[];
    for (final plan in _undoable.reversed) {
      try {
        final result = await widget.rollback(plan);
        if (result.status != PlanStatus.rolledBack) {
          errors.addAll(
            result.items
                .where((i) => i.status == PlanItemStatus.rollbackConflict)
                .map((i) => '${i.request.target ?? i.operationId}: ${i.error}'),
          );
        }
      } catch (error) {
        errors.add('$error');
      }
    }
    if (!mounted) return;
    final strings = AppLocalizations.of(context);
    setState(() {
      _phase = _Phase.report;
      _undoable = const <OperationPlan>[];
      _info = strings.presetUndone;
      _error = errors.isEmpty ? null : errors.join('\n');
    });
  }

  void _save() {
    final strings = AppLocalizations.of(context);
    try {
      final file = saveUserPreset(_folder, _name.text.trim(), <String>[
        for (final item in _preset.items)
          if (!_excluded.contains(item.key)) item.key,
      ]);
      setState(() => _info = strings.presetSaved(file.path));
      _reloadUser();
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    } on FileSystemException catch (error) {
      setState(() => _error = error.message);
    }
  }

  Future<void> _open(String target) async {
    final result = await ProcessRunner.shared.launch('explorer', <String>[
      target,
    ]);
    if (!result.success && mounted) setState(() => _error = result.details);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    Widget presetButton(Preset preset) {
      final selected = identical(preset, _preset);
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: ListTile.selectable(
          selected: selected,
          onPressed: _busy ? null : () => _select(preset),
          title: Text(presetName(strings, preset)),
          trailing: preset.attention
              ? StatusBadge(strings.presetAttention, tone: BadgeTone.critical)
              : null,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 250,
            child: ListView(
              children: <Widget>[
                for (final preset in builtInPresets) presetButton(preset),
                const SizedBox(height: 12),
                Text(
                  strings.presetUserTitle,
                  style: theme.typography.bodyStrong,
                ),
                const SizedBox(height: 6),
                for (final entry in _user)
                  if (entry.preset != null)
                    presetButton(entry.preset!)
                  else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        strings.presetInvalidFile(
                          entry.file.uri.pathSegments.last,
                          entry.error!,
                        ),
                        style: theme.typography.caption,
                      ),
                    ),
                Button(
                  onPressed: () {
                    _folder.createSync(recursive: true);
                    _reloadUser();
                    _open(_folder.path);
                  },
                  child: Text(strings.presetOpenFolder),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(child: ListView(children: _details(strings, theme))),
        ],
      ),
    );
  }

  bool get _busy => const <_Phase>{
    _Phase.loading,
    _Phase.restorePoint,
    _Phase.applying,
  }.contains(_phase);

  List<Widget> _details(AppLocalizations strings, FluentThemeData theme) {
    final preset = _preset;
    final lines = _lines;
    final counts = lines == null
        ? null
        : (
            apply: lines.where((l) => l.status == PreviewStatus.apply).length,
            done: lines.where((l) => l.status == PreviewStatus.done).length,
            skipped: lines
                .where((l) => l.status == PreviewStatus.skipped)
                .length,
          );
    final planned = lines == null
        ? null
        : presetPlans(lines, excluded: _excluded);
    final nothingToDo =
        planned != null &&
        planned.admin.isEmpty &&
        planned.userSettings.isEmpty &&
        planned.userApps.isEmpty;
    return <Widget>[
      Row(
        children: <Widget>[
          Flexible(
            child: Text(
              presetName(strings, preset),
              style: theme.typography.title,
            ),
          ),
          if (preset.attention) ...<Widget>[
            const SizedBox(width: 12),
            StatusBadge(
              strings.presetAttention,
              tone: BadgeTone.critical,
              icon: FluentIcons.warning,
            ),
          ],
        ],
      ),
      const SizedBox(height: 6),
      if (preset.builtIn) Text(presetSummary(strings, preset)),
      if (preset.attention) ...<Widget>[
        const SizedBox(height: 10),
        InfoBar(
          title: Text(strings.presetAttention),
          content: Text(strings.presetAttentionNote),
          severity: InfoBarSeverity.warning,
        ),
      ],
      const SizedBox(height: 12),
      ..._description(strings, theme, preset),
      const SizedBox(height: 16),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Button(
            onPressed: _busy ? null : _preview,
            child: Text(strings.presetPreview),
          ),
          if (_phase == _Phase.loading) ...<Widget>[
            const SizedBox(width: 16, height: 16, child: ProgressRing()),
            Text(strings.presetPreviewLoading),
          ],
        ],
      ),
      if (_info != null) ...<Widget>[
        const SizedBox(height: 10),
        InfoBar(
          title: Text(_info!),
          severity: InfoBarSeverity.success,
          action: _undoable.isEmpty || _phase != _Phase.report
              ? null
              : Button(onPressed: _undo, child: Text(strings.presetUndo)),
        ),
      ],
      if (_error != null) ...<Widget>[
        const SizedBox(height: 10),
        InfoBar(
          title: Text(
            _phase == _Phase.restoreFailed
                ? strings.restorePointFailed
                : strings.operationFailed,
          ),
          content: Text(_error!),
          severity: InfoBarSeverity.error,
          action: _phase == _Phase.restoreFailed
              ? Button(
                  onPressed: () => _apply(enableProtection: true),
                  child: Text(strings.restorePointEnableAndRetry),
                )
              : null,
        ),
      ],
      if (lines != null && counts != null) ...<Widget>[
        const SizedBox(height: 16),
        Text(
          strings.presetCounts(counts.apply, counts.done, counts.skipped),
          style: theme.typography.bodyStrong,
        ),
        const SizedBox(height: 6),
        for (final line in lines)
          if (line.status != PreviewStatus.skipped)
            _previewRow(strings, theme, line),
        // Skipped lines (not installed, not on this PC) are many and rarely
        // interesting: folded so the actions stay in view.
        if (counts.skipped > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Expander(
              header: Text(
                '${strings.presetStatusSkipped} (${counts.skipped})',
              ),
              content: Column(
                children: <Widget>[
                  for (final line in lines)
                    if (line.status == PreviewStatus.skipped)
                      _previewRow(strings, theme, line),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (nothingToDo)
          Text(strings.presetNothingToDo)
        else ...<Widget>[
          Text(strings.presetApplyNote, style: theme.typography.caption),
          if (preset.attention) ...<Widget>[
            const SizedBox(height: 8),
            Checkbox(
              checked: _consent,
              content: Text(strings.presetConsent),
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _consent = value ?? false),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              FilledButton(
                onPressed:
                    _busy ||
                        _phase == _Phase.report ||
                        (preset.attention && !_consent)
                    ? null
                    : _apply,
                child: Text(strings.presetApply),
              ),
              if (_busy) ...<Widget>[
                const SizedBox(width: 12),
                const SizedBox(width: 16, height: 16, child: ProgressRing()),
                const SizedBox(width: 8),
                Text(
                  _phase == _Phase.restorePoint
                      ? strings.restorePointCreating
                      : strings.presetApplying,
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 20),
        Text(strings.presetSaveAs, style: theme.typography.bodyStrong),
        Text(strings.presetSaveNote, style: theme.typography.caption),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            SizedBox(
              width: 260,
              child: TextBox(
                controller: _name,
                placeholder: strings.presetName,
                maxLength: 60,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Button(
              onPressed: _name.text.trim().isEmpty ? null : _save,
              child: Text(strings.presetSaveAs),
            ),
          ],
        ),
      ],
    ];
  }

  List<Widget> _description(
    AppLocalizations strings,
    FluentThemeData theme,
    Preset preset,
  ) {
    final apps = preset.items.whereType<AppPresetItem>().toList();
    final services = preset.items.whereType<ServicePresetItem>().toList();
    final startup = preset.items.whereType<StartupPresetItem>().toList();
    final tweaks = preset.items.whereType<TweakPresetItem>().toList();
    final manual = preset.items.whereType<ManualPresetItem>().toList();
    Widget group(String title, List<Widget> rows) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Expander(
        header: Text('$title (${rows.length})'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ),
    );
    Widget row(String text, [String? caption]) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text),
          if (caption != null) Text(caption, style: theme.typography.caption),
        ],
      ),
    );
    return <Widget>[
      if (apps.isNotEmpty)
        group(strings.presetGroupApps, <Widget>[
          for (final app in apps)
            row(
              appxCandidatePolicy[app.packageName]?.name ?? app.packageName,
              appxCandidatePolicy[app.packageName]?.consequence,
            ),
        ]),
      if (services.isNotEmpty)
        group(strings.presetGroupServices, <Widget>[
          for (final service in services)
            row(
              '${service.name} → ${service.startType == 4 ? strings.serviceStartDisabled : strings.serviceStartManual}',
              serviceReasonLabel(
                strings,
                classifyService(
                  name: service.name,
                  binaryPath: null,
                  company: null,
                  systemRoot: r'C:\Windows',
                ).reason,
              ),
            ),
        ]),
      if (startup.isNotEmpty)
        group(strings.presetGroupStartup, <Widget>[
          for (final item in startup) row(item.rule.label),
        ]),
      if (tweaks.isNotEmpty)
        group(strings.presetGroupTweaks, <Widget>[
          for (final tweak in tweaks)
            row(tweakLabel(strings, tweak.operationId)),
        ]),
      if (manual.isNotEmpty)
        group(strings.presetGroupThirdParty, <Widget>[
          for (final item in manual)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(manualLabel(strings, item.step)),
                      AttributionBadge(item.step.author),
                    ],
                  ),
                  Text(
                    strings.presetManualWhy,
                    style: theme.typography.caption,
                  ),
                  Wrap(
                    children: <Widget>[
                      for (final link in item.step.links)
                        HyperlinkButton(
                          onPressed: () => _open(link),
                          child: Text(link),
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ]),
      Text(strings.presetGroupRestart, style: theme.typography.bodyStrong),
      Text(
        preset.items.every((i) => i is AppPresetItem || i is ManualPresetItem)
            ? strings.presetRestartNone
            : strings.presetRestartNeeded,
      ),
      const SizedBox(height: 8),
      Text(strings.presetGroupReversible, style: theme.typography.bodyStrong),
      if (apps.isNotEmpty) Text('• ${strings.presetReversibleApps}'),
      if (services.isNotEmpty || startup.isNotEmpty || tweaks.isNotEmpty)
        Text('• ${strings.presetReversibleSettings}'),
      if (manual.isNotEmpty) Text('• ${strings.presetReversibleManual}'),
    ];
  }

  Widget _previewRow(
    AppLocalizations strings,
    FluentThemeData theme,
    PreviewLine line,
  ) {
    final item = line.item;
    final name = switch (item) {
      AppPresetItem(:final packageName) =>
        appxCandidatePolicy[packageName]?.name ?? packageName,
      ServicePresetItem(:final name) => line.label ?? name,
      StartupPresetItem(:final rule) =>
        line.label == null ? rule.label : '${rule.label}: ${line.label}',
      TweakPresetItem(:final operationId) => tweakLabel(strings, operationId),
      ManualPresetItem(:final step) => manualLabel(strings, step),
    };
    final (status, tone) = switch (line.status) {
      PreviewStatus.apply => (strings.presetStatusApply, BadgeTone.positive),
      PreviewStatus.done => (strings.presetStatusDone, BadgeTone.neutral),
      PreviewStatus.skipped => (strings.presetStatusSkipped, BadgeTone.neutral),
      PreviewStatus.manual => (strings.presetStatusManual, BadgeTone.caution),
    };
    final reason = switch (line.reason) {
      SkipReason.notInstalled => strings.presetSkipNotInstalled,
      SkipReason.notFound => strings.presetSkipNotFound,
      SkipReason.unsupported => strings.presetSkipUnsupported,
      SkipReason.duplicate => strings.presetSkipDuplicate,
      SkipReason.hasDependents => strings.presetSkipHasDependents,
      null => null,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 32,
            child: line.status == PreviewStatus.apply
                ? Checkbox(
                    checked: !_excluded.contains(item.key),
                    onChanged: _busy || _phase == _Phase.report
                        ? null
                        : (value) => setState(
                            () => value == true
                                ? _excluded.remove(item.key)
                                : _excluded.add(item.key),
                          ),
                  )
                : null,
          ),
          SizedBox(width: 110, child: StatusBadge(status, tone: tone)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              reason == null ? name : '$name · $reason',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

String presetName(AppLocalizations strings, Preset preset) =>
    preset.name ??
    switch (preset.id) {
      'debloat' => strings.presetDebloatName,
      'clean' => strings.presetCleanName,
      'gaming' => strings.presetGamingName,
      'privacy' => strings.presetPrivacyName,
      _ => strings.presetCompetitiveName,
    };

String presetSummary(AppLocalizations strings, Preset preset) =>
    switch (preset.id) {
      'debloat' => strings.presetDebloatSummary,
      'clean' => strings.presetCleanSummary,
      'gaming' => strings.presetGamingSummary,
      'privacy' => strings.presetPrivacySummary,
      _ => strings.presetCompetitiveSummary,
    };

String tweakLabel(AppLocalizations strings, String operationId) =>
    switch (operationId) {
      'power_throttling_off' => strings.presetItemPowerThrottling,
      'ui_taskbar_end_task' => strings.presetItemEndTask,
      'privacy.advertising_id_off' => strings.presetItemAdvertisingId,
      'privacy.language_list_opt_out' => strings.presetItemLanguageList,
      'privacy.app_launch_tracking_off' => strings.presetItemAppLaunchTracking,
      'privacy.tailored_experiences_off' =>
        strings.presetItemTailoredExperiences,
      'privacy.cloud_optimized_content_off' => strings.presetItemCloudContent,
      'privacy.diagnostic_data_required' => strings.presetItemDiagnosticData,
      'sparkle.privacy.overlay' => strings.presetItemLockScreenOverlay,
      'sparkle.privacy.lock_screen' => strings.presetItemLockScreenFacts,
      'gaming.game_dvr_off' => strings.presetItemGameDvr,
      _ => operationId,
    };

String manualLabel(AppLocalizations strings, ManualStep step) =>
    switch (step.id) {
      'driverClean' => strings.presetManualDriverClean,
      _ => strings.presetManualWinsux,
    };
