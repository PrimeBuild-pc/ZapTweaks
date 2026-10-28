import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../core/security/elevated_helper.dart';
import '../../../features/apps/application/app_store_catalog.dart';
import '../../../features/apps/application/app_store_service.dart';
import '../../../features/apps/application/windows_app_inventory_service.dart';
import '../../../features/apps/domain/app_package.dart';
import '../../../features/apps/domain/appx_candidate_policy.dart';
import '../../../features/apps/domain/store_app.dart';
import '../../../features/drivers/application/setupapi_device_inventory_service.dart';
import '../../../features/drivers/domain/device_identity.dart';
import '../../../features/tweaks/application/tweak_controller.dart';
import '../../../l10n/app_localizations.dart';

Map<OperationPrivilege, List<OperationRequest>> setupRequestGroups(
  List<OperationRequest> requests,
) {
  final groups = <OperationPrivilege, List<OperationRequest>>{};
  for (final request in requests) {
    final privilege = switch (request.operationId) {
      'app.winget.set' ||
      'app.appx.remove_current_user' => OperationPrivilege.user,
      'ui_taskbar_end_task' ||
      'app.appx.remove_system' => OperationPrivilege.administrator,
      _ => throw StateError('Unknown guided setup operation.'),
    };
    (groups[privilege] ??= <OperationRequest>[]).add(request);
  }
  return groups;
}

class GuidedSetupPage extends StatefulWidget {
  const GuidedSetupPage({
    required this.controller,
    this.catalogLoader,
    this.deviceInventoryLoader,
    this.systemAppsLoader,
    super.key,
  });

  final TweakController controller;
  final Future<AppStoreCatalog> Function()? catalogLoader;
  final Future<List<DeviceIdentity>> Function()? deviceInventoryLoader;
  final Future<AppInventoryResult> Function()? systemAppsLoader;

  @override
  State<GuidedSetupPage> createState() => _GuidedSetupPageState();
}

class _GuidedSetupPageState extends State<GuidedSetupPage> {
  late final AppStoreService _apps;
  late final WindowsAppInventoryService _appInventory;
  int _step = 0;
  int? _installedCount;
  int? _deviceCount;
  int? _devicesWithoutInf;
  List<StoreApp> _catalog = const <StoreApp>[];
  Set<String> _installedIds = const <String>{};
  final _selectedApps = <String>{};
  List<AppPackage> _appxPackages = const <AppPackage>[];
  List<AppPackage> _currentAppxPackages = const <AppPackage>[];
  final _selectedAppx = <String, String>{};
  bool _systemScopesComplete = false;
  bool _enableTaskbarEndTask = false;
  String _appQuery = '';
  bool _working = false;
  bool _updatesReviewed = false;
  final _reports = <OperationPlan>[];
  final _appliedGroups = <OperationPrivilege>{};
  String? _message;

  @override
  void initState() {
    super.initState();
    _apps = AppStoreService(processRunner: ProcessRunner.shared);
    _appInventory = WindowsAppInventoryService(
      processRunner: ProcessRunner.shared,
    );
  }

  Future<void> _inventory() async {
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        (widget.catalogLoader ?? AppStoreCatalog.load)(),
        _apps.installedWingetIds(),
        _appInventory.scanCurrentUser(),
        widget.deviceInventoryLoader?.call() ??
            Future<List<DeviceIdentity>>(
              () => SetupApiDeviceInventoryService().scanPresent(),
            ),
      ]);
      final currentApps = results[2] as AppInventoryResult;
      if (!currentApps.currentUserComplete) {
        throw StateError(
          currentApps.message ?? 'Current-user AppX inventory failed.',
        );
      }
      final devices = results[3] as List<DeviceIdentity>;
      if (!mounted) return;
      setState(() {
        _catalog = (results[0] as AppStoreCatalog).apps;
        _installedIds = results[1] as Set<String>;
        _installedCount = _installedIds.length;
        _currentAppxPackages = currentApps.packages;
        _appxPackages = currentApps.packages;
        _selectedAppx.clear();
        _systemScopesComplete = false;
        _deviceCount = devices.length;
        _devicesWithoutInf = devices
            .where((device) => device.driverInf == null)
            .length;
      });
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _openWindowsUpdate() async {
    final result = await ProcessRunner.shared.launch('explorer', <String>[
      'ms-settings:windowsupdate',
    ]);
    if (!result.success && mounted) {
      setState(() => _message = result.details);
    }
  }

  Future<void> _scanSystemApps() async {
    setState(() {
      _working = true;
      _systemScopesComplete = false;
      _message = null;
    });
    try {
      final result =
          await (widget.systemAppsLoader ??
              ElevatedHelperClient(
                directory: defaultElevatedHelperDirectory(),
              ).scanSystemApps)();
      if (!mounted) return;
      setState(() {
        _appxPackages = mergeAppPackages(<AppPackage>[
          ..._currentAppxPackages,
          ...result.packages,
        ]);
        _systemScopesComplete =
            result.allUsersComplete && result.provisionedComplete;
        _selectedAppx.removeWhere(
          (id, scope) => !_availableAppxScopes(id).contains(scope),
        );
        _message = result.message;
      });
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _apply(OperationPrivilege privilege) async {
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(
        setupRequestGroups(_requests)[privilege]!,
      );
      if (!mounted) return;
      setState(() {
        _reports.add(plan);
        _appliedGroups.add(privilege);
      });
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final titles = <String>[
      strings.wizardInventory,
      strings.wizardBaseline,
      strings.wizardWindowsUpdate,
      strings.wizardDrivers,
      strings.wizardApplications,
      strings.wizardDebloat,
      strings.wizardPrivacyInterface,
      strings.wizardPreview,
      strings.wizardApply,
      strings.wizardReport,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            strings.guidedSetup,
            style: FluentTheme.of(context).typography.title,
          ),
          const SizedBox(height: 8),
          Text('${_step + 1}/10 · ${titles[_step]}'),
          const SizedBox(height: 12),
          ProgressBar(value: (_step + 1) * 10),
          if (_message != null) ...<Widget>[
            const SizedBox(height: 12),
            InfoBar(
              title: Text(strings.operationFailed),
              content: Text(_message!),
              severity: InfoBarSeverity.error,
            ),
          ],
          const SizedBox(height: 16),
          Expanded(child: _content(strings)),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Button(
                onPressed: _step == 0 || _working || _reports.isNotEmpty
                    ? null
                    : () => setState(() => _step--),
                child: Text(strings.back),
              ),
              const Spacer(),
              if (_step < 8)
                FilledButton(
                  onPressed:
                      _working ||
                          (_step == 0 && _installedCount == null) ||
                          (_step == 2 && !_updatesReviewed)
                      ? null
                      : () => setState(() => _step++),
                  child: Text(strings.continueAction),
                )
              else if (_step == 8)
                FilledButton(
                  onPressed: _working ? null : () => setState(() => _step = 9),
                  child: Text(strings.wizardReport),
                )
              else
                FilledButton(
                  onPressed: () => setState(() {
                    _step = 0;
                    _reports.clear();
                    _appliedGroups.clear();
                    _selectedApps.clear();
                    _selectedAppx.clear();
                    _enableTaskbarEndTask = false;
                  }),
                  child: Text(strings.finish),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _content(AppLocalizations strings) => switch (_step) {
    0 => _inventoryStep(strings),
    1 => _baselineStep(strings),
    2 => _updatesStep(strings),
    3 => _driversStep(strings),
    4 => _appsStep(strings),
    5 => _debloatStep(strings),
    6 => _privacyStep(strings),
    7 => _previewStep(strings),
    8 => _applyStep(strings),
    _ => _reportStep(strings),
  };

  Widget _inventoryStep(AppLocalizations strings) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(strings.wizardInventoryDescription),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: _working ? null : _inventory,
        child: Text(strings.runInventory),
      ),
      if (_installedCount != null) ...<Widget>[
        const SizedBox(height: 16),
        Text(strings.inventorySummary(_installedCount!, _deviceCount!)),
      ],
    ],
  );

  Widget _baselineStep(AppLocalizations strings) {
    final hardware = widget.controller.hardwareProfile;
    return _notice(
      '${strings.cpuValue(hardware.cpuName)}\n'
      '${strings.gpuValue(hardware.gpuNames.join(', '))}\n'
      '${strings.ramValue(hardware.ramInstalledLabel)}\n'
      'Windows build ${hardware.windowsBuild}',
    );
  }

  Widget _updatesStep(AppLocalizations strings) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(strings.wizardUpdateNotice),
      const SizedBox(height: 12),
      Button(
        onPressed: _openWindowsUpdate,
        child: Text(strings.openWindowsUpdate),
      ),
      const SizedBox(height: 12),
      Checkbox(
        checked: _updatesReviewed,
        content: Text(strings.updatesReviewed),
        onChanged: (value) => setState(() => _updatesReviewed = value ?? false),
      ),
    ],
  );

  Widget _driversStep(AppLocalizations strings) => _notice(
    strings.driverInventorySummary(_deviceCount ?? 0, _devicesWithoutInf ?? 0),
  );

  Widget _appsStep(AppLocalizations strings) {
    final query = _appQuery.trim().toLowerCase();
    final visible = _catalog
        .where(
          (app) =>
              app.wingetId != null &&
              !_installedIds.contains(app.wingetId!.toLowerCase()) &&
              (query.isEmpty || app.name.toLowerCase().contains(query)),
        )
        .take(100)
        .toList(growable: false);
    return Column(
      children: <Widget>[
        TextBox(
          placeholder: strings.searchApps,
          onChanged: (value) => setState(() => _appQuery = value),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (context, index) {
              final app = visible[index];
              return Checkbox(
                checked: _selectedApps.contains(app.wingetId),
                content: Text('${app.name} · ${app.attribution}'),
                onChanged: (value) => setState(() {
                  if (value == true) {
                    _selectedApps.add(app.wingetId!);
                  } else {
                    _selectedApps.remove(app.wingetId);
                  }
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _debloatStep(AppLocalizations strings) => ListView(
    children: <Widget>[
      Text(
        'No defaults. Existing accounts and future-account provisioning are separate opt-in scopes. Restore sources are not rollback.',
      ),
      const SizedBox(height: 10),
      Button(
        onPressed: _working ? null : _scanSystemApps,
        child: Text(strings.scanAllUsers),
      ),
      Text(
        _systemScopesComplete
            ? strings.systemScopesComplete
            : strings.systemScopesIncomplete,
      ),
      for (final group in AppxCandidateGroup.values) ...<Widget>[
        const SizedBox(height: 12),
        Text(group.label, style: FluentTheme.of(context).typography.bodyStrong),
        for (final entry in appxCandidatePolicy.entries.where(
          (entry) => entry.value.group == group,
        ))
          _appxChoice(entry.key, entry.value, strings),
      ],
    ],
  );

  Widget _appxChoice(
    String id,
    AppxCandidate candidate,
    AppLocalizations strings,
  ) {
    final scopes = _availableAppxScopes(id);
    final available = scopes.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${candidate.name} · $id'),
          Text(candidate.consequence),
          Text(
            candidate.restore == null
                ? strings.notReinstallable
                : '${strings.recovery}: ${candidate.restore!.source} · ${candidate.restore!.packageId}',
          ),
          if (!available) const Text('Inventory only / unavailable metadata'),
          if (available)
            for (final scope in scopes)
              Checkbox(
                checked: _selectedAppx[id] == scope,
                content: Text(_scopeLabel(scope, strings)),
                onChanged: (checked) => setState(() {
                  if (checked == true) {
                    _selectedAppx[id] = scope;
                  } else {
                    _selectedAppx.remove(id);
                  }
                }),
              ),
        ],
      ),
    );
  }

  List<String> _availableAppxScopes(String id) {
    final package = _appxPackages
        .where((package) => package.packageId == id)
        .firstOrNull;
    if (package == null || !package.canRemoveAppx) return const <String>[];
    return <String>[
      if (package.scopes.contains(AppInstallScope.currentUser)) 'currentUser',
      if (_systemScopesComplete &&
          package.scopes.contains(AppInstallScope.allUsers))
        'allUsers',
      if (_systemScopesComplete &&
          package.scopes.contains(AppInstallScope.provisioned))
        'provisioned',
      if (_systemScopesComplete &&
          package.scopes.contains(AppInstallScope.allUsers) &&
          package.scopes.contains(AppInstallScope.provisioned))
        'allUsersAndProvisioned',
    ];
  }

  String _scopeLabel(String scope, AppLocalizations strings) => switch (scope) {
    'currentUser' => strings.currentUser,
    'allUsers' => '${strings.allUsers} · existing accounts',
    'provisioned' => '${strings.provisioned} · future accounts',
    _ =>
      '${strings.allUsers} + ${strings.provisioned} · existing + future accounts',
  };

  Widget _privacyStep(AppLocalizations strings) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(strings.wizardPrivacyNotice),
      const SizedBox(height: 12),
      Checkbox(
        checked: _enableTaskbarEndTask,
        content: Text(strings.operationTaskbarEndTaskTitle),
        onChanged: (value) =>
            setState(() => _enableTaskbarEndTask = value ?? false),
      ),
    ],
  );

  List<OperationRequest> get _requests => <OperationRequest>[
    if (_enableTaskbarEndTask)
      const OperationRequest(
        operationId: 'ui_taskbar_end_task',
        desiredValue: 1,
      ),
    for (final id in _selectedApps)
      OperationRequest(
        operationId: 'app.winget.set',
        target: id,
        desiredValue: true,
      ),
    for (final entry in _selectedAppx.entries)
      if (_availableAppxScopes(entry.key).contains(entry.value))
        OperationRequest(
          operationId: entry.value == 'currentUser'
              ? 'app.appx.remove_current_user'
              : 'app.appx.remove_system',
          target: entry.key,
          desiredValue: null,
          parameters: <String, Object?>{'scope': entry.value},
        ),
  ];

  Widget _previewStep(AppLocalizations strings) => _requests.isEmpty
      ? _notice(strings.noAppsSelected)
      : ListView(
          children: <Widget>[
            Text(strings.planContains(_requests.length)),
            const SizedBox(height: 8),
            Text(
              'Separate user and administrator plans; no cross-plan transaction or automatic rollback.',
            ),
            for (final group in setupRequestGroups(
              _requests,
            ).entries) ...<Widget>[
              const SizedBox(height: 10),
              Text('${strings.wizardPreview} · ${group.key.name}'),
              for (final request in group.value)
                if (request.operationId.startsWith('app.appx.'))
                  Text(
                    strings.confirmAppxRemovalMessage(
                      appxCandidatePolicy[request.target]!.name,
                      request.target!,
                      _scopeLabel(
                        request.parameters['scope'] as String,
                        strings,
                      ),
                      '${appxCandidatePolicy[request.target]!.group.label}\n'
                      '${appxCandidatePolicy[request.target]!.consequence}\n'
                      '${appxCandidatePolicy[request.target]!.restore?.packageId ?? strings.notReinstallable}',
                    ),
                  )
                else
                  Text(
                    '${request.operationId} · ${request.target ?? 'current user'} · ${request.desiredValue}',
                  ),
            ],
          ],
        );

  Widget _applyStep(AppLocalizations strings) => ListView(
    children: <Widget>[
      Text(
        _requests.isEmpty
            ? strings.noAppsSelected
            : strings.readyToApply(_requests.length),
      ),
      Text(
        'Separate plans. Apply each explicitly; completing one does not guarantee the other succeeds.',
      ),
      for (final group in setupRequestGroups(_requests).entries)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Button(
            onPressed: _working || _appliedGroups.contains(group.key)
                ? null
                : () => _apply(group.key),
            child: Text(
              '${strings.applyPlan} · ${group.key.name} · ${group.value.length}',
            ),
          ),
        ),
    ],
  );

  Widget _reportStep(AppLocalizations strings) {
    if (_reports.isEmpty) return _notice(strings.noPlanReport);
    return ListView(
      children: <Widget>[
        Text(
          'Restore sources are not rollback: local app data, existing-user scopes and future-user provisioning are not restored.',
        ),
        for (final report in _reports) ...<Widget>[
          Text('${strings.planStatus}: ${report.status.name}'),
          const SizedBox(height: 8),
          for (final item in report.items) ...<Widget>[
            Text(
              '${item.request.target ?? item.request.operationId}: ${item.status.name}${item.error == null ? '' : ' · ${item.error}'}',
            ),
            if (item.request.operationId.startsWith('app.appx.'))
              Text(
                '${strings.recovery}: ${item.snapshot?.data['restoreSource'] ?? strings.notReinstallable} · ${item.snapshot?.data['restorePackageId'] ?? ''}',
              ),
          ],
        ],
        for (final group in setupRequestGroups(
          _requests,
        ).keys.where((group) => !_appliedGroups.contains(group)))
          Text('${group.name}: not executed'),
      ],
    );
  }

  static Widget _notice(String text) =>
      Align(alignment: Alignment.topLeft, child: SelectableText(text));
}
