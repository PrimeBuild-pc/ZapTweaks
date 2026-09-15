import '../../platform/windows/service_control_manager.dart';
import 'operation.dart';

class ServiceStartOperation implements OperationDefinition {
  const ServiceStartOperation({
    required this.store,
    required this.allowedServices,
  });

  final ServiceConfigurationStore store;
  final Set<String> allowedServices;

  String _target(OperationRequest request) {
    final target = request.target;
    if (target == null ||
        !allowedServices
            .map((v) => v.toLowerCase())
            .contains(target.toLowerCase())) {
      throw StateError('Service is not allowlisted.');
    }
    return allowedServices.firstWhere(
      (v) => v.toLowerCase() == target.toLowerCase(),
    );
  }

  ({int startType, bool delayed}) _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value is! Map ||
        value['startType'] is! int ||
        value['delayedAutoStart'] is! bool) {
      throw StateError('Typed service startup configuration is required.');
    }
    final startType = value['startType']! as int;
    final delayed = value['delayedAutoStart']! as bool;
    if (!const <int>{2, 3, 4}.contains(startType) ||
        (delayed && startType != 2)) {
      throw StateError('Invalid service startup configuration.');
    }
    return (startType: startType, delayed: delayed);
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
      store.inspect(_target(request));
      _desired(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final service = store.inspect(_target(request));
      return OperationState(
        OperationStateKind.configured,
        value: <String, Object?>{
          'startType': service.startType,
          'delayedAutoStart': service.delayedAutoStart,
        },
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
      throw StateError(before.message ?? 'Service inspection failed.');
    }
    return OperationSnapshot(
      type: 'serviceStart',
      data: <String, Object?>{
        'service': _target(request),
        'configuration': before.value,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final desired = _desired(request);
    store.configureStart(
      _target(request),
      startType: desired.startType,
      delayedAutoStart: desired.delayed,
    );
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'serviceStart' ||
        snapshot.data['service'] != _target(request)) {
      throw StateError('Invalid service snapshot.');
    }
    final value = Map<String, Object?>.from(
      snapshot.data['configuration']! as Map,
    );
    store.configureStart(
      _target(request),
      startType: value['startType']! as int,
      delayedAutoStart: value['delayedAutoStart']! as bool,
    );
  }

  @override
  String get id => 'service.start.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'serviceStartTitle';
  @override
  String get descriptionKey => 'serviceStartDescription';
  @override
  String get domain => 'services';
  @override
  String get destination => 'Windows';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.reboot;
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
    'https://learn.microsoft.com/windows/win32/api/winsvc/nf-winsvc-changeserviceconfigw',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
