import '../../platform/windows/power_scheme_service.dart';
import 'operation.dart';

class PowerSchemeDuplicateOperation implements OperationDefinition {
  PowerSchemeDuplicateOperation({required this.schemes});
  final PowerSchemeManagement schemes;
  String? _createdId;

  ({String source, String name}) _input(OperationRequest request) {
    final source = request.target;
    final name = request.desiredValue;
    if (source == null ||
        name is! String ||
        request.parameters.isNotEmpty ||
        name.trim().isEmpty ||
        name.length > 128) {
      throw StateError('Invalid power scheme duplication request.');
    }
    return (source: source.toLowerCase(), name: name.trim());
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
      if (!schemes.enumerate().any((scheme) => scheme.id == input.source)) {
        return const SupportResult.unsupported(
          'Source power scheme does not exist.',
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
      _input(request);
      final created = _createdId;
      if (created == null) {
        return const OperationState(OperationStateKind.absent);
      }
      final matches = schemes
          .enumerate()
          .where((scheme) => scheme.id == created)
          .toList();
      return matches.length == 1
          ? OperationState(
              OperationStateKind.configured,
              value: matches.single.name,
            )
          : const OperationState(
              OperationStateKind.error,
              message: 'Duplicated power scheme is missing.',
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
    _input(request);
    return const OperationSnapshot(
      type: 'powerSchemeDuplicate',
      data: <String, Object?>{},
      expectedAfterRollback: OperationState(OperationStateKind.absent),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final input = _input(request);
    _createdId = schemes.duplicateScheme(input.source, input.name);
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);
  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'powerSchemeDuplicate' || _createdId == null) {
      throw StateError('The generated power scheme identity is unavailable.');
    }
    schemes.deleteScheme(_createdId!);
    _createdId = null;
  }

  @override
  String get id => 'power.scheme.duplicate';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'duplicatePowerPlan';
  @override
  String get descriptionKey => 'duplicatePowerPlanDescription';
  @override
  String get domain => 'power';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.powerPlan;
  @override
  OperationRisk get risk => OperationRisk.low;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.bestEffort;
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
    'https://learn.microsoft.com/windows/win32/api/powrprof/nf-powrprof-powerduplicatescheme',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
