import '../../features/drivers/application/driver_store_service.dart';
import '../../features/drivers/application/windows_driver_inventory_service.dart';
import '../../features/drivers/domain/device_identity.dart';
import '../../features/drivers/domain/driver_package.dart';
import 'operation.dart';

class DriverStoreRemoveOperation implements OperationDefinition {
  const DriverStoreRemoveOperation({
    required DriverStoreService store,
    required WindowsDriverInventoryService inventory,
    required List<DeviceIdentity> Function() deviceInventory,
  }) : _store = store,
       _inventory = inventory,
       _deviceInventory = deviceInventory;

  final DriverStoreService _store;
  final WindowsDriverInventoryService _inventory;
  final List<DeviceIdentity> Function() _deviceInventory;
  static final RegExp _publishedName = RegExp(
    r'^oem[0-9]+\.inf$',
    caseSensitive: false,
  );

  String _target(OperationRequest request) {
    final target = request.target;
    if (target == null || !_publishedName.hasMatch(target)) {
      throw StateError('Invalid Driver Store identity.');
    }
    if (request.desiredValue != null) {
      throw StateError('Driver removal desired value must be null.');
    }
    return target;
  }

  Future<DriverPackage?> _package(OperationRequest request) async {
    final target = _target(request).toLowerCase();
    final result = await _inventory.scan();
    if (!result.complete) {
      throw StateError(result.message ?? 'Driver Store inventory failed.');
    }
    for (final package in result.packages) {
      if (package.publishedName.toLowerCase() == target) return package;
    }
    return null;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _target(request);
      return context.architecture == 'x64' && context.windowsBuild >= 22000
          ? const SupportResult.supported()
          : const SupportResult.unsupported('Requires Windows 11 x64.');
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final package = await _package(request);
      return package == null
          ? const OperationState(OperationStateKind.absent)
          : OperationState(
              OperationStateKind.configured,
              value: package.toJson(),
            );
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final package = await _package(request);
    if (package == null) throw StateError('Driver package is not installed.');
    if (!package.signed ||
        package.publisher.toLowerCase().contains('microsoft')) {
      throw StateError('Only signed third-party packages can be removed.');
    }
    if (_deviceInventory().any(
      (device) =>
          device.driverInf?.toLowerCase() ==
          package.publishedName.toLowerCase(),
    )) {
      throw StateError('A present device is still bound to this package.');
    }
    final export = await _store.exportPackage(package);
    return OperationSnapshot(
      type: 'driverStoreExport',
      data: export.toReferenceJson(),
      expectedAfterRollback: OperationState(
        OperationStateKind.configured,
        value: package.toJson(),
      ),
    );
  }

  @override
  Future<void> apply(OperationRequest request) =>
      _store.removePackage(_target(request));

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'driverStoreExport') {
      throw StateError('Invalid driver export snapshot.');
    }
    if ((snapshot.data['publishedName'] as String?)?.toLowerCase() !=
        _target(request).toLowerCase()) {
      throw StateError('Driver export does not match the operation target.');
    }
    await _store.restoreReference(snapshot.data);
  }

  @override
  String get id => 'driver.store.remove';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'driverStoreRemoveTitle';
  @override
  String get descriptionKey => 'driverStoreRemoveDescription';
  @override
  String get domain => 'drivers';
  @override
  String get destination => 'Drivers';
  @override
  OperationScope get scope => OperationScope.driver;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.reboot;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.bestEffort;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.unverified;
  @override
  String? get evidenceBinaryVersion => null;
  @override
  String? get evidenceSha256 => null;
  @override
  List<String> get supportedEditions => const <String>['Home', 'Pro'];
  @override
  List<String> get supportedArchitectures => const <String>['x64'];
  @override
  List<String> get technicalSources => const <String>[
    'https://learn.microsoft.com/windows-hardware/drivers/devtest/pnputil-command-syntax',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
