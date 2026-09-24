import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../features/apps/application/app_store_catalog.dart';
import '../../../features/apps/application/app_store_service.dart';
import '../../../features/apps/application/windows_app_inventory_service.dart';
import '../../../features/apps/domain/app_package.dart';
import '../../../features/apps/domain/store_app.dart';
import '../../../features/drivers/application/setupapi_device_inventory_service.dart';
import '../../../features/drivers/domain/device_identity.dart';
import '../../../features/tweaks/application/tweak_controller.dart';
import '../../../l10n/app_localizations.dart';

class GuidedSetupPage extends StatefulWidget {
  const GuidedSetupPage({required this.controller, super.key});

  final TweakController controller;

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
  final _selectedAppx = <String>{};
  bool _enableTaskbarEndTask = false;
  String _appQuery = '';
  bool _working = false;
  bool _updatesReviewed = false;
  OperationPlan? _report;
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
        AppStoreCatalog.load(),
        _apps.installedWingetIds(),
        _appInventory.scanCurrentUser(),
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
        _appxPackages = currentApps.packages;
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

  Future<void> _apply() async {
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(_requests);
      if (!mounted) return;
      setState(() {
        _report = plan;
        _step = 9;
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
                onPressed: _step == 0 || _working
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
                  onPressed: _working
                      ? null
                      : _requests.isEmpty
                      ? () => setState(() => _step = 9)
                      : _apply,
                  child: Text(
                    _requests.isEmpty ? strings.finish : strings.applyPlan,
                  ),
                )
              else
                FilledButton(
                  onPressed: () => setState(() {
                    _step = 0;
                    _report = null;
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
      Text(strings.wizardDebloatNotice),
      const SizedBox(height: 10),
      for (final package in _appxPackages)
        Checkbox(
          checked: _selectedAppx.contains(package.packageId),
          content: Text(
            '${package.name} · ${package.reinstallable ? strings.reinstallable : strings.notReinstallable}',
          ),
          onChanged: package.reinstallable
              ? (value) => setState(() {
                  if (value == true) {
                    _selectedAppx.add(package.packageId);
                  } else {
                    _selectedAppx.remove(package.packageId);
                  }
                })
              : null,
        ),
    ],
  );

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
    for (final id in _selectedAppx)
      OperationRequest(
        operationId: 'app.appx.remove_current_user',
        target: id,
        desiredValue: null,
        parameters: const <String, Object?>{'scope': 'currentUser'},
      ),
  ];

  Widget _previewStep(AppLocalizations strings) => _requests.isEmpty
      ? _notice(strings.noAppsSelected)
      : ListView(
          children: <Widget>[
            Text(strings.planContains(_requests.length)),
            const SizedBox(height: 8),
            for (final request in _requests)
              Text(
                '${request.operationId} · ${request.target ?? 'current user'} · ${request.desiredValue}',
              ),
          ],
        );

  Widget _applyStep(AppLocalizations strings) => _notice(
    _requests.isEmpty
        ? strings.noAppsSelected
        : strings.readyToApply(_requests.length),
  );

  Widget _reportStep(AppLocalizations strings) {
    final report = _report;
    if (report == null) return _notice(strings.noPlanReport);
    return ListView(
      children: <Widget>[
        Text('${strings.planStatus}: ${report.status.name}'),
        const SizedBox(height: 8),
        for (final item in report.items)
          Text(
            '${item.request.target}: ${item.status.name}${item.error == null ? '' : ' · ${item.error}'}',
          ),
      ],
    );
  }

  static Widget _notice(String text) =>
      Align(alignment: Alignment.topLeft, child: SelectableText(text));
}
