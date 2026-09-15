import '../../platform/windows/power_scheme_service.dart';
import 'operation.dart';

class PowerSchemeActivationOperation implements OperationDefinition {
  const PowerSchemeActivationOperation({required this.store});

  final PowerSchemeStore store;

  String _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (request.target != null ||
        request.parameters.isNotEmpty ||
        value is! String ||
        !_guid.hasMatch(value)) {
      throw StateError('A canonical power scheme GUID is required.');
    }
    return value.toLowerCase();
  }

  static final RegExp _guid = RegExp(
    r'^\{[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\}$',
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
      _desired(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      _desired(request);
      return OperationState(
        OperationStateKind.configured,
        value: store.activeSchemeId.toLowerCase(),
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
    _desired(request);
    final active = store.activeSchemeId.toLowerCase();
    return OperationSnapshot(
      type: 'activePowerScheme',
      data: <String, Object?>{'schemeId': active},
      expectedAfterRollback: OperationState(
        OperationStateKind.configured,
        value: active,
      ),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async =>
      store.setActiveScheme(_desired(request));

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'activePowerScheme' ||
        snapshot.data['schemeId'] is! String) {
      throw StateError('Invalid active power scheme snapshot.');
    }
    store.setActiveScheme(snapshot.data['schemeId']! as String);
  }

  @override
  String get id => 'power.scheme.activate';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'activatePowerScheme';
  @override
  String get descriptionKey => 'activatePowerSchemeDescription';
  @override
  String get domain => 'power';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.powerPlan;
  @override
  OperationRisk get risk => OperationRisk.low;
  @override
  OperationPrivilege get privilege => OperationPrivilege.user;
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
    'https://learn.microsoft.com/windows/win32/api/powrprof/nf-powrprof-powersetactivescheme',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
