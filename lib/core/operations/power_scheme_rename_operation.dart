import '../../platform/windows/power_scheme_service.dart';
import 'operation.dart';

class PowerSchemeRenameOperation implements OperationDefinition {
  const PowerSchemeRenameOperation({required this.schemes});
  final PowerSchemeManagement schemes;

  ({String id, String name}) _input(OperationRequest request) {
    final id = request.target;
    final name = request.desiredValue;
    if (id == null ||
        name is! String ||
        request.parameters.isNotEmpty ||
        name.trim().isEmpty ||
        name.length > 128) {
      throw StateError('Invalid power scheme rename request.');
    }
    return (id: id.toLowerCase(), name: name.trim());
  }

  PowerSchemeInfo _find(String id) => schemes.enumerate().singleWhere(
    (scheme) => scheme.id == id,
    orElse: () => throw StateError('Power scheme does not exist.'),
  );

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
      _find(input.id);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final input = _input(request);
      return OperationState(
        OperationStateKind.configured,
        value: _find(input.id).name,
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
    final before = await inspect(request);
    if (before.kind != OperationStateKind.configured) {
      throw StateError(before.message ?? 'Power scheme inspection failed.');
    }
    return OperationSnapshot(
      type: 'powerSchemeName',
      data: <String, Object?>{'name': before.value},
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final input = _input(request);
    schemes.renameScheme(input.id, input.name);
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);
  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'powerSchemeName' ||
        snapshot.data['name'] is! String) {
      throw StateError('Invalid power scheme name snapshot.');
    }
    schemes.renameScheme(_input(request).id, snapshot.data['name']! as String);
  }

  @override
  String get id => 'power.scheme.rename';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'renamePowerPlan';
  @override
  String get descriptionKey => 'renamePowerPlanDescription';
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
    'https://learn.microsoft.com/windows/win32/api/powrprof/nf-powrprof-powerwritefriendlyname',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
