enum OperationStateKind {
  unknown,
  notApplicable,
  absent,
  configured,
  mixed,
  pendingRestart,
  drifted,
  error,
}

enum OperationScope { user, machine, device, app, driver, powerPlan }

enum EvidenceLevel {
  documented,
  runtimeObserved,
  staticConfirmed,
  inferred,
  unverified,
  rejected,
}

enum OperationRisk { low, medium, high, rejected }

enum OperationPrivilege { user, administrator }

enum RestartImpact { none, process, service, device, signOut, reboot }

enum RollbackCapability { exact, bestEffort, manual, none }

typedef JsonMap = Map<String, Object?>;

class OperationState {
  const OperationState(this.kind, {this.value, this.message});

  final OperationStateKind kind;
  final Object? value;
  final String? message;

  bool sameValue(OperationState other) =>
      kind == other.kind && _deepEquals(value, other.value);

  JsonMap toJson() => <String, Object?>{
    'kind': kind.name,
    'value': value,
    if (message != null) 'message': message,
  };

  factory OperationState.fromJson(JsonMap json) => OperationState(
    OperationStateKind.values.byName(json['kind']! as String),
    value: json['value'],
    message: json['message'] as String?,
  );
}

class SupportResult {
  const SupportResult.supported() : supported = true, reason = null;
  const SupportResult.unsupported(this.reason) : supported = false;

  final bool supported;
  final String? reason;
}

class OperationSnapshot {
  const OperationSnapshot({
    required this.type,
    required this.data,
    required this.expectedAfterRollback,
  });

  final String type;
  final JsonMap data;
  final OperationState expectedAfterRollback;

  JsonMap toJson() => <String, Object?>{
    'type': type,
    'data': data,
    'expectedAfterRollback': expectedAfterRollback.toJson(),
  };

  factory OperationSnapshot.fromJson(JsonMap json) => OperationSnapshot(
    type: json['type']! as String,
    data: Map<String, Object?>.from(json['data']! as Map),
    expectedAfterRollback: OperationState.fromJson(
      Map<String, Object?>.from(json['expectedAfterRollback']! as Map),
    ),
  );
}

class OperationRequest {
  const OperationRequest({
    required this.operationId,
    required this.desiredValue,
    this.target,
    this.parameters = const <String, Object?>{},
  });

  final String operationId;
  final String? target;
  final Object? desiredValue;
  final JsonMap parameters;
}

class OperationContext {
  const OperationContext({
    required this.windowsBuild,
    required this.edition,
    this.architecture = 'x64',
    this.cpuVendor,
    this.gpuVendors = const <String>{},
    this.hasBattery = false,
  });

  final int windowsBuild;
  final String edition;
  final String architecture;
  final String? cpuVendor;
  final Set<String> gpuVendors;
  final bool hasBattery;
}

abstract class OperationDefinition {
  String get id;
  int get version;
  List<String> get legacyAliases;
  String get titleKey;
  String get descriptionKey;
  String get domain;
  String get destination;
  OperationScope get scope;
  OperationRisk get risk;
  OperationPrivilege get privilege;
  RestartImpact get restartImpact;
  RollbackCapability get rollbackCapability;
  EvidenceLevel get mechanismEvidence;
  EvidenceLevel get valueEvidence;
  EvidenceLevel get benefitEvidence;
  List<String> get technicalSources;
  String? get evidenceBinaryVersion => null;
  String? get evidenceSha256 => null;
  List<String> get supportedEditions => const <String>['Home', 'Pro'];
  List<String> get supportedArchitectures => const <String>['x64'];
  List<String> get dependencies;
  List<String> get conflicts;

  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  );
  Future<OperationState> inspect(OperationRequest request);
  Future<OperationSnapshot> captureSnapshot(OperationRequest request);
  Future<void> apply(OperationRequest request);
  Future<OperationState> verify(OperationRequest request);
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot);
}

bool _deepEquals(Object? left, Object? right) {
  if (left is List && right is List) {
    return left.length == right.length &&
        Iterable<int>.generate(
          left.length,
        ).every((index) => _deepEquals(left[index], right[index]));
  }
  if (left is Map && right is Map) {
    return left.length == right.length &&
        left.keys.every(
          (key) => right.containsKey(key) && _deepEquals(left[key], right[key]),
        );
  }
  return left == right;
}
