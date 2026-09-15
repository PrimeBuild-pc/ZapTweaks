import 'dart:io';

import '../../platform/windows/power_plan_file_service.dart';
import '../../platform/windows/power_scheme_service.dart';
import 'operation.dart';

class PowerSchemeDeleteOperation implements OperationDefinition {
  const PowerSchemeDeleteOperation({
    required this.files,
    required this.schemes,
  });
  final PowerPlanFileService files;
  final PowerSchemeManagement schemes;

  String _id(OperationRequest request) {
    final id = request.target;
    if (id == null ||
        request.desiredValue != null ||
        request.parameters.isNotEmpty ||
        !_guid.hasMatch(id)) {
      throw StateError('Invalid power scheme delete request.');
    }
    return id.toLowerCase();
  }

  static final RegExp _guid = RegExp(
    r'^\{[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\}$',
  );
  PowerSchemeInfo? _find(String id) {
    for (final scheme in schemes.enumerate()) {
      if (scheme.id == id) return scheme;
    }
    return null;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000 || context.architecture != 'x64') {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      final scheme = _find(_id(request));
      if (scheme == null) {
        return const SupportResult.unsupported('Power scheme does not exist.');
      }
      if (scheme.active) {
        return const SupportResult.unsupported(
          'The active power scheme cannot be deleted.',
        );
      }
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      return _find(_id(request)) == null
          ? const OperationState(OperationStateKind.absent)
          : const OperationState(OperationStateKind.configured, value: true);
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  Directory _backupDirectory() {
    final root =
        Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
    return Directory(
      '$root${Platform.pathSeparator}ZapTweaks${Platform.pathSeparator}Helper${Platform.pathSeparator}PowerPlanBackups',
    );
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final id = _id(request);
    final scheme = _find(id);
    if (scheme == null || scheme.active) {
      throw StateError(
        'Only an inactive existing power scheme can be deleted.',
      );
    }
    final directory = _backupDirectory();
    await directory.create(recursive: true);
    final backup = File(
      '${directory.path}${Platform.pathSeparator}${id.substring(1, id.length - 1)}.pow',
    );
    if (await backup.exists()) await backup.delete();
    await files.exportScheme(id, backup);
    return OperationSnapshot(
      type: 'deletedPowerScheme',
      data: <String, Object?>{'id': id, 'backupPath': backup.path},
      expectedAfterRollback: const OperationState(
        OperationStateKind.configured,
        value: true,
      ),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async =>
      schemes.deleteScheme(_id(request));
  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final id = _id(request);
    if (snapshot.type != 'deletedPowerScheme' ||
        snapshot.data['id'] != id ||
        snapshot.data['backupPath'] is! String) {
      throw StateError('Invalid deleted power scheme snapshot.');
    }
    final backup = File(snapshot.data['backupPath']! as String);
    final staging = Directory(
      '${backup.parent.path}${Platform.pathSeparator}restore-$id',
    );
    await files.importScheme(backup, staging, schemeId: id);
    if (await staging.exists()) {
      await staging.delete(recursive: true);
    }
    await backup.delete();
  }

  @override
  String get id => 'power.scheme.delete';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'deletePowerPlan';
  @override
  String get descriptionKey => 'deletePowerPlanDescription';
  @override
  String get domain => 'power';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.powerPlan;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.runtimeObserved;
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
    'https://learn.microsoft.com/windows/win32/api/powrprof/nf-powrprof-powerdeletescheme',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
