import '../../platform/windows/tcp_optimizer_service.dart';
import 'operation.dart';

class TcpSettingOperation implements OperationDefinition {
  const TcpSettingOperation(this.store);

  final TcpOptimizerStore store;

  String _target(OperationRequest request) {
    if (request.parameters.isNotEmpty) {
      throw const FormatException('TCP setting parameters are not allowed.');
    }
    final target = request.target;
    if (target == null || target.isEmpty) {
      throw const FormatException('A TCP setting target is required.');
    }
    return target;
  }

  String _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value is! String || value.isEmpty || value.length > 64) {
      throw const FormatException('A typed TCP setting value is required.');
    }
    return value;
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
      final current = await store.inspect(_target(request));
      final desired = _desired(request);
      if (!current.writable || !current.supportedValues.contains(desired)) {
        return const SupportResult.unsupported(
          'The requested value is not exposed by this Windows build.',
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
      final current = await store.inspect(_target(request));
      return OperationState(
        OperationStateKind.configured,
        value: current.value,
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
    final before = await inspect(request);
    if (before.kind != OperationStateKind.configured) {
      throw StateError(before.message ?? 'TCP setting inspection failed.');
    }
    return OperationSnapshot(
      type: 'tcpSetting',
      data: <String, Object?>{
        'target': _target(request),
        'value': before.value,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) =>
      store.write(_target(request), _desired(request));

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'tcpSetting' ||
        snapshot.data['target'] != _target(request) ||
        snapshot.data['value'] is! String) {
      throw StateError('Invalid TCP setting snapshot.');
    }
    await store.write(_target(request), snapshot.data['value']! as String);
  }

  @override
  String get id => 'network.tcp.setting.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'tcpSettingOperationTitle';
  @override
  String get descriptionKey => 'tcpSettingOperationDescription';
  @override
  String get domain => 'network';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.machine;
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
    'https://learn.microsoft.com/powershell/module/nettcpip/get-nettcpsetting',
    'https://learn.microsoft.com/powershell/module/nettcpip/set-nettcpsetting',
    'https://learn.microsoft.com/powershell/module/nettcpip/get-netoffloadglobalsetting',
    'https://learn.microsoft.com/powershell/module/nettcpip/set-netoffloadglobalsetting',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}

class QosPolicyOperation implements OperationDefinition {
  const QosPolicyOperation(this.store);

  final QosPolicyStore store;

  String _target(OperationRequest request) {
    if (request.parameters.isNotEmpty) {
      throw const FormatException('QoS operation parameters are not allowed.');
    }
    final target = request.target;
    if (target == null || target.isEmpty) {
      throw const FormatException('A QoS policy name is required.');
    }
    return target;
  }

  QosPolicy? _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value == null) return null;
    if (value is! Map) throw const FormatException('Invalid QoS policy.');
    final policy = QosPolicy.validate(Map<String, dynamic>.from(value));
    if (policy.name != _target(request)) {
      throw const FormatException('QoS policy target mismatch.');
    }
    return policy;
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
      _desired(request);
      final current = await store.inspect(_target(request));
      if (current != null && !current.editable) {
        return const SupportResult.unsupported(
          'Only ZapTweaks-owned QoS policies can be changed.',
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
      final current = await store.inspect(_target(request));
      return current == null
          ? const OperationState(OperationStateKind.absent)
          : OperationState(
              OperationStateKind.configured,
              value: current.toJson(),
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
    final before = await inspect(request);
    if (before.kind != OperationStateKind.configured &&
        before.kind != OperationStateKind.absent) {
      throw StateError(before.message ?? 'QoS policy inspection failed.');
    }
    return OperationSnapshot(
      type: 'qosPolicy',
      data: <String, Object?>{'name': _target(request), 'policy': before.value},
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) =>
      store.write(_target(request), _desired(request));

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'qosPolicy' ||
        snapshot.data['name'] != _target(request)) {
      throw StateError('Invalid QoS policy snapshot.');
    }
    final saved = snapshot.data['policy'];
    await store.write(
      _target(request),
      saved == null
          ? null
          : QosPolicy.validate(Map<String, dynamic>.from(saved as Map)),
    );
  }

  @override
  String get id => 'network.qos.policy.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'qosPolicyOperationTitle';
  @override
  String get descriptionKey => 'qosPolicyOperationDescription';
  @override
  String get domain => 'network';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.app;
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
    'https://learn.microsoft.com/powershell/module/netqos/get-netqospolicy',
    'https://learn.microsoft.com/powershell/module/netqos/new-netqospolicy',
    'https://learn.microsoft.com/powershell/module/netqos/remove-netqospolicy',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
