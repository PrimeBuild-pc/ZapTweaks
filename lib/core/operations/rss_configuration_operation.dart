import '../../platform/windows/hardware_capability_validators.dart';
import '../../platform/windows/rss_service.dart';
import 'operation.dart';

class RssConfigurationOperation implements OperationDefinition {
  const RssConfigurationOperation(this.store);

  final RssStore store;

  RssConfiguration _desired(OperationRequest request) {
    final target = request.target;
    final value = request.desiredValue;
    if (target == null || value is! Map) {
      throw const FormatException(
        'Adapter and complete RSS tuple are required.',
      );
    }
    final json = Map<String, dynamic>.from(value);
    int integer(String key) {
      final item = json[key];
      if (item is! int) throw FormatException('Invalid RSS $key.');
      return item;
    }

    final processors = json['processorArray'];
    if (json['enabled'] is! bool ||
        json['profile'] is! String ||
        processors is! List) {
      throw const FormatException('Invalid RSS tuple.');
    }
    return RssConfiguration(
      enabled: json['enabled']! as bool,
      profile: json['profile']! as String,
      baseProcessor: ProcessorAddress(
        integer('baseGroup'),
        integer('baseNumber'),
      ),
      maximumProcessor: ProcessorAddress(
        integer('maxGroup'),
        integer('maxNumber'),
      ),
      processorCount: integer('processorCount'),
      queueCount: integer('queueCount'),
      processorArray: processors
          .map((row) {
            final item = Map<String, dynamic>.from(row as Map);
            return ProcessorAddress(
              item['group']! as int,
              item['number']! as int,
            );
          })
          .toList(growable: false),
    );
  }

  static Map<String, Object?> _configuration(
    RssConfiguration value,
  ) => <String, Object?>{
    'enabled': value.enabled,
    'profile': value.profile,
    'baseGroup': value.baseProcessor.group,
    'baseNumber': value.baseProcessor.number,
    'maxGroup': value.maximumProcessor.group,
    'maxNumber': value.maximumProcessor.number,
    'processorCount': value.processorCount,
    'queueCount': value.queueCount,
    'processorArray': value.processorArray
        .map(
          (item) => <String, int>{'group': item.group, 'number': item.number},
        )
        .toList(growable: false),
  };

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000 || context.architecture != 'x64') {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      final current = await store.inspect(request.target!);
      final error = HardwareCapabilityValidators.validateRss(
        _desired(request),
        store.capabilities(current),
      );
      return error == null
          ? const SupportResult.supported()
          : SupportResult.unsupported(error);
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final state = await store.inspect(request.target!);
      return OperationState(
        OperationStateKind.configured,
        value: _configuration(state.configuration),
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
      throw StateError(before.message ?? 'RSS inspection failed.');
    }
    return OperationSnapshot(
      type: 'rssConfiguration',
      data: <String, Object?>{
        'adapter': request.target,
        'configuration': before.value,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) =>
      store.write(request.target!, _desired(request));

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'rssConfiguration' ||
        snapshot.data['adapter'] != request.target) {
      throw StateError('Invalid RSS snapshot.');
    }
    await store.write(
      request.target!,
      _desired(
        OperationRequest(
          operationId: id,
          target: request.target,
          desiredValue: snapshot.data['configuration'],
        ),
      ),
    );
  }

  @override
  String get id => 'network.rss.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'rssConfigurationTitle';
  @override
  String get descriptionKey => 'rssConfigurationDescription';
  @override
  String get domain => 'network';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.device;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.device;
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
    'https://learn.microsoft.com/powershell/module/netadapter/get-netadapterrss',
    'https://learn.microsoft.com/powershell/module/netadapter/set-netadapterrss',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
