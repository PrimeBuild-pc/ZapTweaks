import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';
import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/security/elevated_helper.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../diagnostics/presentation/app_history_page.dart' show formatBytes;
import '../application/app_inventory_parser.dart';
import '../application/app_list_query.dart';
import '../application/folder_size_cache.dart';
import '../application/uninstall_command.dart' show expandEnvironment;
import '../application/windows_app_inventory_service.dart';
import '../domain/app_safety_policy.dart';
import 'installed_app_row.dart';
import 'leftover_review_dialog.dart';
import '../application/leftover_scanner.dart';
import '../application/orphan_folders.dart';
import 'uninstall_queue_dialog.dart';
import '../application/running_processes.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../domain/app_package.dart';

class AppInventoryPage extends StatefulWidget {
  const AppInventoryPage({required this.controller, super.key});

  final TweakController controller;

  @override
  State<AppInventoryPage> createState() => _AppInventoryPageState();
}

class _AppInventoryPageState extends State<AppInventoryPage> {
  late final WindowsAppInventoryService _inventory;
  late final ElevatedHelperClient _helper;
  List<AppPackage> _packages = const <AppPackage>[];
  List<AppPackage> _localPackages = const <AppPackage>[];
  bool _loading = true;
  bool _systemScopesComplete = false;
  AppListQuery _query = const AppListQuery();
  final Set<String> _selected = <String>{};
  FolderSizeCache _sizes = FolderSizeCache();
  final Map<String, int> _sizeOverrides = <String, int>{};
  int _sizeGeneration = 0;
  String? _message;
  String? _removalReport;

  @override
  void initState() {
    super.initState();
    _inventory = WindowsAppInventoryService(
      processRunner: ProcessRunner.shared,
    );
    _helper = ElevatedHelperClient(directory: defaultElevatedHelperDirectory());
    _scanLocal();
  }

  Future<void> _scanLocal() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final winget = _inventory.scanWinget();
    final results = await Future.wait(<Future<AppInventoryResult>>[
      _inventory.scanCurrentUser(),
      _inventory.scanWin32(),
    ]);
    if (!mounted) return;
    setState(() {
      _localPackages = mergeAppPackages(
        results.expand((result) => result.packages),
      );
      _packages = _localPackages;
      _selected.clear();
      _sizeOverrides.clear();
      _sizes = FolderSizeCache();
      _message = results
          .map((result) => result.message)
          .whereType<String>()
          .join('\n');
      if (_message!.isEmpty) _message = null;
      _systemScopesComplete = false;
      _loading = false;
    });
    unawaited(_fillSizes());
    // winget (often 10–30 s) only lends reinstall ids; the list does not wait
    // for it, and a missing winget is not an error.
    final ids = await winget;
    if (!mounted || ids.packages.isEmpty) return;
    setState(() {
      _localPackages = attachWingetIds(_localPackages, ids.packages);
      _packages = attachWingetIds(_packages, ids.packages);
    });
  }

  /// Folder sizes for apps without EstimatedSize, one folder at a time so a
  /// big Program Files does not start hundreds of isolates. A folder shared
  /// by several entries is counted once, and drive roots, Program Files,
  /// Common Files and Windows are never measured.
  Future<void> _fillSizes() async {
    final generation = ++_sizeGeneration;
    final appx = await _inventory.appxInstallLocations();
    final measured = <String>{};
    var pending = 0;
    for (final app in _packages.where((app) => app.sizeBytes == null)) {
      final raw = app.provider == AppProvider.appx
          ? appx[app.packageId]
          : app.installLocation;
      // Uninstall values are read unexpanded (%ProgramFiles%\…).
      final path = raw == null
          ? null
          : expandEnvironment(raw, Platform.environment);
      if (path == null ||
          !isAppOwnedFolder(path) ||
          !measured.add(normalizeFolder(path))) {
        continue;
      }
      final size = await _sizes.sizeOf(path);
      if (!mounted || generation != _sizeGeneration) return;
      if (size == null) continue;
      _sizeOverrides[app.packageId] = size;
      if (++pending % 10 == 0) setState(() {});
    }
    if (mounted) setState(() {});
  }

  List<AppPackage> get _withSizes => <AppPackage>[
    for (final app in _packages)
      _sizeOverrides[app.packageId] == null
          ? app
          : app.copyWith(sizeBytes: _sizeOverrides[app.packageId]),
  ];

  Future<void> _remove(AppPackage package, String scope) async {
    final strings = AppLocalizations.of(context);
    final scopeLabel = switch (scope) {
      'currentUser' => strings.currentUser,
      'allUsers' => '${strings.allUsers} · existing accounts',
      'provisioned' => '${strings.provisioned} · future accounts',
      _ =>
        '${strings.allUsers} + ${strings.provisioned} · existing + future accounts',
    };
    final confirmed = await confirmAction(
      context,
      title: strings.confirmAppxRemoval,
      message: strings.confirmAppxRemovalMessage(
        package.name,
        package.packageId,
        scopeLabel,
        '${package.appxCandidate!.group.label}\n'
        '${package.appxCandidate!.consequence}\n'
        '${_restoreSource(package, strings)}',
      ),
      confirmLabel: strings.uninstall,
      destructive: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _loading = true;
      _removalReport = null;
    });
    OperationPlan? plan;
    try {
      final system = scope != 'currentUser';
      plan = await widget.controller.executeNativeRequests(<OperationRequest>[
        OperationRequest(
          operationId: system
              ? 'app.appx.remove_system'
              : 'app.appx.remove_current_user',
          target: package.packageId,
          desiredValue: null,
          parameters: <String, Object?>{'scope': scope},
        ),
      ]);
      if (mounted && plan.status != PlanStatus.dryRunComplete) {
        await _scanLocal();
      }
      if (mounted) {
        setState(
          () => _removalReport =
              '${package.name} · ${plan!.status.name}\n${_restoreSource(package, strings)}\n'
              'Restore source only; app data, account scopes and provisioning are not rolled back.',
        );
      }
      if ((plan.status != PlanStatus.completed &&
              plan.status != PlanStatus.dryRunComplete) ||
          plan.items.length != 1 ||
          plan.items.any((item) => item.error != null) ||
          (plan.status == PlanStatus.completed &&
              plan.items.single.status != PlanItemStatus.verified &&
              plan.items.single.status != PlanItemStatus.skipped)) {
        throw StateError(
          plan.items.isEmpty
              ? 'AppX removal failed.'
              : plan.items.first.error ?? 'AppX removal failed.',
        );
      }
    } catch (error) {
      if (mounted && plan == null) await _scanLocal();
      if (mounted) {
        setState(() {
          _systemScopesComplete = false;
          _message = error.toString();
          _removalReport =
              '${package.name} · failed\n${_restoreSource(package, strings)}\n'
              'Partial effects cannot be excluded. Restore sources are not rollback.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _scanSystemScopes() async {
    setState(() {
      _loading = true;
      _message = null;
      _systemScopesComplete = false;
    });
    try {
      final result = await _helper.scanSystemApps();
      if (!mounted) return;
      setState(() {
        _packages = mergeAppPackages(<AppPackage>[
          ..._localPackages,
          ...result.packages,
        ]);
        _systemScopesComplete =
            result.allUsersComplete && result.provisionedComplete;
        _message = result.message;
      });
      unawaited(_fillSizes());
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _restoreSource(AppPackage package, AppLocalizations strings) {
    final identity = package.appxCandidate?.restore;
    return identity == null
        ? strings.notReinstallable
        : '${strings.recovery}: ${identity.source} · ${identity.packageId}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    // Framework and resource packages are dependencies, not apps.
    final all = _withSizes.where((app) => !app.isFramework).toList();
    final packages = _query.apply(all);
    final maxSize = all.fold<int>(
      0,
      (max, app) => (app.sizeBytes ?? 0) > max ? app.sizeBytes! : max,
    );
    final selectedPrograms = <AppPackage>[
      for (final app in all)
        if (_selected.contains(app.packageId) &&
            app.provider == AppProvider.win32)
          app,
    ];
    final selection = selectionSize(
      all.where((app) => _selected.contains(app.packageId)),
    );
    Widget filter<T>(
      String label,
      T? value,
      Map<T, String> options,
      void Function(T?) onChanged,
    ) => InfoLabel(
      label: label,
      child: ComboBox<T?>(
        value: value,
        placeholder: Text(strings.filterAll),
        items: <ComboBoxItem<T?>>[
          ComboBoxItem<T?>(value: null, child: Text(strings.filterAll)),
          for (final entry in options.entries)
            ComboBoxItem<T?>(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: (next) => setState(() => onChanged(next)),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 280,
                child: TextBox(
                  placeholder: strings.searchInstalledApps,
                  onChanged: (value) =>
                      setState(() => _query = _query.copyWith(search: value)),
                ),
              ),
              filter<AppType>(
                strings.filterType,
                _query.type,
                <AppType, String>{
                  AppType.user: strings.appTypeUser,
                  AppType.system: strings.appTypeSystem,
                  AppType.store: strings.appTypeStore,
                },
                (v) => _query = _query.copyWith(type: () => v),
              ),
              filter<AppSafety>(
                strings.filterSafety,
                _query.safety,
                <AppSafety, String>{
                  AppSafety.removable: strings.appSafetyRemovable,
                  AppSafety.checkFirst: strings.appSafetyCheckFirst,
                  AppSafety.keep: strings.appSafetyKeep,
                },
                (v) => _query = _query.copyWith(safety: () => v),
              ),
              filter<AppSource>(
                strings.filterSource,
                _query.source,
                <AppSource, String>{
                  AppSource.allUsers: strings.sourceWholePc,
                  AppSource.currentUser: strings.currentUser,
                  AppSource.store: strings.appTypeStore,
                },
                (v) => _query = _query.copyWith(source: () => v),
              ),
              InfoLabel(
                label: strings.sortBy,
                child: ComboBox<AppSort>(
                  value: _query.sort,
                  items: <ComboBoxItem<AppSort>>[
                    ComboBoxItem(
                      value: AppSort.size,
                      child: Text(strings.sortSize),
                    ),
                    ComboBoxItem(
                      value: AppSort.name,
                      child: Text(strings.sortName),
                    ),
                    ComboBoxItem(
                      value: AppSort.date,
                      child: Text(strings.sortDate),
                    ),
                  ],
                  onChanged: (v) => setState(
                    () => _query = _query.copyWith(sort: v ?? AppSort.size),
                  ),
                ),
              ),
              Button(
                onPressed: _loading ? null : _scanLocal,
                child: Text(strings.refreshInventory),
              ),
              Button(
                onPressed: _loading ? null : _scanSystemScopes,
                child: Text(strings.scanAllUsers),
              ),
              Button(
                onPressed: _loading ? null : _reviewOrphans,
                child: Text(strings.orphanFolders),
              ),
              FilledButton(
                onPressed: _loading || selectedPrograms.isEmpty
                    ? null
                    : () => _openQueue(selectedPrograms),
                child: Text(
                  '${strings.uninstallSelected} (${selectedPrograms.length})',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            <String>[
              strings.appsShown(packages.length),
              if (_selected.isNotEmpty)
                strings.selectionSummary(
                  _selected.length,
                  formatBytes(selection.bytes),
                ),
              if (_selected.isNotEmpty && selection.unknown > 0)
                strings.selectionUnknownSizes(selection.unknown),
              if (_selected.length > selectedPrograms.length)
                strings.uninstallStoreAppsHint,
              _systemScopesComplete
                  ? strings.systemScopesComplete
                  : strings.systemScopesIncomplete,
            ].join(' · '),
          ),
          if (_removalReport != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: Text(strings.wizardReport),
              content: Text(_removalReport!),
              severity: InfoBarSeverity.info,
            ),
          ],
          if (_message != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: Text(strings.operationFailed),
              content: Text(_message!),
              severity: InfoBarSeverity.error,
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(child: ProgressRing())
                : packages.isEmpty
                ? EmptyState(strings.noAppsMatch)
                : ListView.separated(
                    itemCount: packages.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      return InstalledAppRow(
                        app: package,
                        maxSizeBytes: maxSize,
                        selected: _selected.contains(package.packageId),
                        onSelected:
                            classifyApp(package).safety == AppSafety.keep
                            ? null
                            : (value) => setState(
                                () => value
                                    ? _selected.add(package.packageId)
                                    : _selected.remove(package.packageId),
                              ),
                        action: _appxAction(package, strings),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          SourceCaption(strings.appsSource),
        ],
      ),
    );
  }

  Future<void> _openQueue(List<AppPackage> apps) async {
    final changed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UninstallQueueDialog(
        apps: apps,
        execute: widget.controller.executeNativeRequests,
        listProcesses: () => listRunningProcesses(ProcessRunner.shared),
        scanLeftovers: (query) => scanLeftovers(ProcessRunner.shared, query),
      ),
    );
    if (changed == true && mounted) await _scanLocal();
  }

  Future<void> _reviewOrphans() async {
    final strings = AppLocalizations.of(context);
    final references = <String>[
      for (final app in _packages)
        ...<String?>[
          app.installLocation == null
              ? null
              : expandEnvironment(app.installLocation!, Platform.environment),
          app.uninstall?.uninstallString,
          app.uninstall?.quietUninstallString,
        ].nonNulls,
    ];
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LeftoverReviewDialog(
        title: strings.orphanFolders,
        note: strings.orphanFoldersNote,
        execute: widget.controller.executeNativeRequests,
        load: () async => <Leftover>[
          for (final folder in findOrphanFolders(
            programFilesFolders(Platform.environment),
            references,
            environment: Platform.environment,
          ))
            Leftover(
              kind: LeftoverKind.folder,
              path: folder,
              confidence: LeftoverConfidence.low,
              machine: true,
            ),
        ],
      ),
    );
  }

  Widget? _appxAction(AppPackage package, AppLocalizations strings) {
    if (!package.canRemoveAppx) return null;
    return DropDownButton(
      title: Text(strings.uninstall),
      items: <MenuFlyoutItemBase>[
        for (final scope in package.scopes.where(
          (scope) =>
              scope == AppInstallScope.currentUser || _systemScopesComplete,
        ))
          MenuFlyoutItem(
            text: Text(switch (scope) {
              AppInstallScope.currentUser => strings.currentUser,
              AppInstallScope.allUsers =>
                '${strings.allUsers} · existing accounts',
              AppInstallScope.provisioned =>
                '${strings.provisioned} · future accounts',
            }),
            onPressed: () => _remove(package, scope.name),
          ),
        if (_systemScopesComplete &&
            package.scopes.contains(AppInstallScope.allUsers) &&
            package.scopes.contains(AppInstallScope.provisioned))
          MenuFlyoutItem(
            text: Text('${strings.allUsers} + ${strings.provisioned}'),
            onPressed: () => _remove(package, 'allUsersAndProvisioned'),
          ),
      ],
    );
  }
}
