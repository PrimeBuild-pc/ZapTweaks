import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../application/device_driver_correlator.dart';
import '../application/local_driver_package_service.dart';
import '../application/setupapi_device_inventory_service.dart';
import '../application/windows_driver_inventory_service.dart';
import '../domain/device_driver_binding.dart';
import '../domain/driver_package.dart';

class DriverInventoryPage extends StatefulWidget {
  const DriverInventoryPage({required this.controller, super.key});

  final TweakController controller;

  @override
  State<DriverInventoryPage> createState() => _DriverInventoryPageState();
}

class _DriverInventoryPageState extends State<DriverInventoryPage> {
  late final WindowsDriverInventoryService _inventory;
  late final LocalDriverPackageService _localPackages;
  List<DeviceDriverBinding> _bindings = const <DeviceDriverBinding>[];
  List<DriverPackage> _packages = const <DriverPackage>[];
  String _query = '';
  String _infPath = '';
  DeviceDriverBinding? _selectedDevice;
  VerifiedLocalDriver? _verifiedDriver;
  bool _loading = true;
  bool _verifying = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _inventory = WindowsDriverInventoryService(
      processRunner: ProcessRunner.shared,
    );
    _localPackages = LocalDriverPackageService(
      processRunner: ProcessRunner.shared,
      inventory: _inventory,
      verifySignature: (file) => LocalDriverPackageService.verifyAuthenticode(
        file,
        processRunner: ProcessRunner.shared,
      ),
    );
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final result = await _inventory.scan();
      if (!result.complete) {
        throw StateError(result.message ?? 'Driver inventory failed.');
      }
      final devices = await Future(
        () => const SetupApiDeviceInventoryService().scanPresent(),
      );
      if (!mounted) return;
      setState(() {
        _packages = result.packages;
        _bindings = const DeviceDriverCorrelator().correlate(
          devices,
          result.packages,
        );
      });
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyLocal() async {
    final device = _selectedDevice;
    if (device == null || _infPath.trim().isEmpty) return;
    setState(() {
      _verifying = true;
      _message = null;
      _verifiedDriver = null;
    });
    try {
      final verified = await _localPackages.verify(
        File(_infPath.trim()),
        deviceHardwareIds: device.device.hardwareIds,
      );
      if (mounted) setState(() => _verifiedDriver = verified);
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _installLocal() async {
    final verified = _verifiedDriver;
    final device = _selectedDevice;
    if (verified == null || device == null) return;
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.confirmLocalDriverInstall),
        content: Text(
          strings.confirmLocalDriverInstallMessage(
            device.device.description,
            verified.publisher,
            verified.infSha256,
          ),
        ),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.install),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[
          OperationRequest(
            operationId: 'driver.package.install_local',
            target: verified.infPath,
            desiredValue: true,
            parameters: <String, Object?>{
              'hardwareIds': device.device.hardwareIds.toList(growable: false),
              'infSha256': verified.infSha256,
              'catalogSha256': verified.catalogSha256,
              'publisher': verified.publisher,
            },
          ),
        ],
      );
      if (plan.status != PlanStatus.completed) {
        throw StateError(
          plan.items.single.error ?? 'Driver installation failed.',
        );
      }
      _verifiedDriver = null;
      await _scan();
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(DriverPackage package) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.confirmDriverRemoval),
        content: Text(
          strings.confirmDriverRemovalMessage(
            package.publishedName,
            package.infName,
            package.publisher,
            package.version,
          ),
        ),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.uninstall),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _loading = true);
    try {
      final plan = await widget.controller
          .executeNativeRequests(<OperationRequest>[
            OperationRequest(
              operationId: 'driver.store.remove',
              target: package.publishedName,
              desiredValue: null,
            ),
          ]);
      if (plan.status != PlanStatus.completed) {
        throw StateError(plan.items.single.error ?? 'Driver removal failed.');
      }
      await _scan();
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final bound = _bindings
        .where((binding) => binding.package != null)
        .map((binding) => binding.package!.publishedName.toLowerCase())
        .toSet();
    final query = _query.trim().toLowerCase();
    final packages = _packages
        .where(
          (package) =>
              query.isEmpty ||
              package.publishedName.toLowerCase().contains(query) ||
              package.infName.toLowerCase().contains(query) ||
              package.publisher.toLowerCase().contains(query),
        )
        .toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            children: <Widget>[
              SizedBox(
                width: 320,
                child: TextBox(
                  placeholder: strings.searchDrivers,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Button(
                onPressed: _loading ? null : _scan,
                child: Text(strings.refreshInventory),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    strings.installLocalDriver,
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 280,
                        child: ComboBox<DeviceDriverBinding>(
                          value: _selectedDevice,
                          placeholder: Text(strings.selectDevice),
                          items: <ComboBoxItem<DeviceDriverBinding>>[
                            for (final binding in _bindings.where(
                              (item) => item.device.hardwareIds.isNotEmpty,
                            ))
                              ComboBoxItem<DeviceDriverBinding>(
                                value: binding,
                                child: Text(binding.device.description),
                              ),
                          ],
                          onChanged: (value) => setState(() {
                            _selectedDevice = value;
                            _verifiedDriver = null;
                          }),
                        ),
                      ),
                      SizedBox(
                        width: 360,
                        child: TextBox(
                          placeholder: strings.localInfPath,
                          onChanged: (value) => setState(() {
                            _infPath = value;
                            _verifiedDriver = null;
                          }),
                        ),
                      ),
                      Button(
                        onPressed:
                            _verifying ||
                                _selectedDevice == null ||
                                _infPath.trim().isEmpty
                            ? null
                            : _verifyLocal,
                        child: Text(strings.verifyDriverPackage),
                      ),
                      FilledButton(
                        onPressed: _verifiedDriver == null || _loading
                            ? null
                            : _installLocal,
                        child: Text(strings.install),
                      ),
                    ],
                  ),
                  if (_verifiedDriver != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      strings.verifiedDriverPublisher(
                        _verifiedDriver!.publisher,
                        _verifiedDriver!.infSha256,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(strings.driverStoreSafetyNotice),
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
                : ListView.separated(
                    itemCount: packages.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      final isBound = bound.contains(
                        package.publishedName.toLowerCase(),
                      );
                      final thirdParty = !package.publisher
                          .toLowerCase()
                          .contains('microsoft');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${package.publishedName} · ${package.infName}',
                                    style: FluentTheme.of(
                                      context,
                                    ).typography.bodyStrong,
                                  ),
                                  Text(
                                    '${package.publisher} · ${package.version} · ${package.signed ? strings.signed : strings.unsigned}',
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              isBound
                                  ? strings.driverInUse
                                  : strings.driverUnbound,
                            ),
                            const SizedBox(width: 12),
                            Button(
                              onPressed:
                                  isBound ||
                                      !thirdParty ||
                                      !package.signed ||
                                      _loading
                                  ? null
                                  : () => _remove(package),
                              child: Text(strings.exportAndRemove),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
