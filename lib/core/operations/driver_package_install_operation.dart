import 'dart:io';

import 'package:path/path.dart' as p;

import '../../features/drivers/application/driver_store_service.dart';
import '../../features/drivers/application/local_driver_package_service.dart';
import '../../features/drivers/application/windows_driver_inventory_service.dart';
import '../../features/drivers/domain/driver_package.dart';
import 'operation.dart';

class DriverPackageInstallOperation implements OperationDefinition {
  const DriverPackageInstallOperation({
    required LocalDriverPackageService localPackages,
    required WindowsDriverInventoryService inventory,
    required DriverStoreService store,
  }) : _localPackages = localPackages,
       _inventory = inventory,
       _store = store;

  final LocalDriverPackageService _localPackages;
  final WindowsDriverInventoryService _inventory;
  final DriverStoreService _store;

  Set<String> _hardwareIds(OperationRequest request) {
    if (request.desiredValue != true ||
        request.target == null ||
        request.parameters.length != 4 ||
        request.parameters['hardwareIds'] is! List ||
        request.parameters['infSha256'] is! String ||
        request.parameters['catalogSha256'] is! String ||
        request.parameters['publisher'] is! String) {
      throw ArgumentError('Invalid local driver installation request.');
    }
    final rawIds = request.parameters['hardwareIds']! as List;
    if (rawIds.any((id) => id is! String)) {
      throw ArgumentError('Invalid device hardware IDs.');
    }
    final ids = rawIds
        .cast<String>()
        .map((id) => id.trim().toUpperCase())
        .where((id) => id.isNotEmpty)
        .toSet();
    if (ids.isEmpty ||
        ids.length > 64 ||
        ids.fold<int>(0, (total, id) => total + id.length) > 2048 ||
        ids.any((id) => id.length > 512)) {
      throw ArgumentError('Invalid device hardware IDs.');
    }
    return ids;
  }

  Future<VerifiedLocalDriver> _verified(OperationRequest request) async {
    final verified = await _localPackages.verify(
      File(request.target!),
      deviceHardwareIds: _hardwareIds(request),
    );
    if (verified.infSha256 != request.parameters['infSha256'] ||
        verified.catalogSha256 != request.parameters['catalogSha256'] ||
        verified.publisher != request.parameters['publisher']) {
      throw StateError(
        'The driver package does not match the approved verification.',
      );
    }
    return verified;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.architecture != 'x64' || context.windowsBuild < 22000) {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      await _verified(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final ids = _hardwareIds(request);
      final infName = p.basename(request.target!).toLowerCase();
      final result = await _inventory.scan();
      if (!result.complete) {
        return OperationState(
          OperationStateKind.error,
          message: result.message ?? 'Driver inventory failed.',
        );
      }
      return result.packages.any(
            (package) =>
                package.infName.toLowerCase() == infName &&
                package.signed &&
                package.hardwareIds.any(ids.contains),
          )
          ? const OperationState(OperationStateKind.configured, value: true)
          : const OperationState(OperationStateKind.absent);
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final verified = await _verified(request);
    final result = await _inventory.scan();
    if (!result.complete) {
      throw StateError(result.message ?? 'Driver inventory failed.');
    }
    final previous = result.packages
        .where((package) => _matches(package, verified))
        .map((package) => package.publishedName)
        .toList(growable: false);
    return OperationSnapshot(
      type: 'driverLocalInstall',
      data: <String, Object?>{
        'infName': p.basename(verified.infPath),
        'hardwareIds': verified.hardwareIds.toList(growable: false),
        'previousPublishedNames': previous,
      },
      expectedAfterRollback: previous.isEmpty
          ? const OperationState(OperationStateKind.absent)
          : const OperationState(OperationStateKind.configured, value: true),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async =>
      _localPackages.install(await _verified(request));

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'driverLocalInstall') {
      throw StateError('Invalid driver install snapshot.');
    }
    final previous = Set<String>.from(
      snapshot.data['previousPublishedNames']! as List,
    ).map((name) => name.toLowerCase()).toSet();
    final infName = snapshot.data['infName']! as String;
    final ids = Set<String>.from(snapshot.data['hardwareIds']! as List);
    final result = await _inventory.scan();
    if (!result.complete) {
      throw StateError(result.message ?? 'Driver inventory failed.');
    }
    final added = result.packages.where(
      (package) =>
          package.infName.toLowerCase() == infName.toLowerCase() &&
          package.hardwareIds.any(ids.contains) &&
          !previous.contains(package.publishedName.toLowerCase()),
    );
    for (final package in added) {
      await _store.removePackage(package.publishedName);
    }
  }

  static bool _matches(DriverPackage package, VerifiedLocalDriver driver) =>
      package.infName.toLowerCase() ==
          p.basename(driver.infPath).toLowerCase() &&
      package.signed &&
      package.hardwareIds.any(driver.hardwareIds.contains);

  @override
  String get id => 'driver.package.install_local';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'installLocalDriver';
  @override
  String get descriptionKey => 'installLocalDriverDescription';
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
    'https://learn.microsoft.com/powershell/module/microsoft.powershell.security/get-authenticodesignature',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
