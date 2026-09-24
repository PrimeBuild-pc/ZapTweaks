import 'dart:io';

import '../../platform/windows/power_plan_file_service.dart';
import '../../platform/windows/power_scheme_service.dart';
import 'operation.dart';

class PowerPlanImportOperation implements OperationDefinition {
  const PowerPlanImportOperation({required this.files, required this.schemes});

  final PowerPlanFileService files;
  final PowerSchemeManagement schemes;
  static final RegExp _guid = RegExp(
    r'^\{[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}\}$',
  );

  ({String id, File source}) _input(OperationRequest request) {
    final id = request.desiredValue;
    final source = request.parameters['sourcePath'];
    if (request.target != null ||
        request.parameters.length != 1 ||
        id is! String ||
        !_guid.hasMatch(id) ||
        source is! String) {
      throw StateError('Invalid power plan import request.');
    }
    return (id: id.toLowerCase(), source: File(source));
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
      final input = _input(request);
      if (!await input.source.exists()) {
        return const SupportResult.unsupported(
          'Power plan file does not exist.',
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
      final input = _input(request);
      return schemes.enumerate().any((scheme) => scheme.id == input.id)
          ? OperationState(OperationStateKind.configured, value: input.id)
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
    final before = await inspect(request);
    if (before.kind != OperationStateKind.absent) {
      throw StateError('The requested power scheme GUID already exists.');
    }
    return const OperationSnapshot(
      type: 'powerPlanImport',
      data: <String, Object?>{},
      expectedAfterRollback: OperationState(OperationStateKind.absent),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final input = _input(request);
    final root =
        Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
    final staging = Directory(
      '$root${Platform.pathSeparator}ZapTweaks${Platform.pathSeparator}Helper${Platform.pathSeparator}PowerPlan-${input.id}',
    );
    try {
      await files.importScheme(input.source, staging, schemeId: input.id);
    } finally {
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'powerPlanImport') {
      throw StateError('Invalid power plan import snapshot.');
    }
    final input = _input(request);
    if (schemes.enumerate().any((scheme) => scheme.id == input.id)) {
      schemes.deleteScheme(input.id);
    }
  }

  @override
  String get id => 'power.scheme.import';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'importPowerPlan';
  @override
  String get descriptionKey => 'importPowerPlanDescription';
  @override
  String get domain => 'power';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.powerPlan;
  @override
  OperationRisk get risk => OperationRisk.medium;
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
    'https://learn.microsoft.com/windows-hardware/design/device-experiences/powercfg-command-line-options',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
