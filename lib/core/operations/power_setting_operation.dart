import '../../platform/windows/power_scheme_service.dart';
import 'operation.dart';

class PowerSettingOperation implements OperationDefinition {
  const PowerSettingOperation({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.destination,
    required this.subgroupId,
    required this.settingId,
    required PowerSchemeStore store,
    this.privilege = OperationPrivilege.administrator,
    this.risk = OperationRisk.medium,
    this.benefitEvidence = EvidenceLevel.inferred,
    this.technicalSources = const <String>[],
  }) : _store = store;

  @override
  final String id;
  @override
  final String titleKey;
  @override
  final String descriptionKey;
  @override
  final String destination;
  final String subgroupId;
  final String settingId;
  final PowerSchemeStore _store;
  @override
  final OperationPrivilege privilege;
  @override
  final OperationRisk risk;
  @override
  final EvidenceLevel benefitEvidence;
  @override
  final List<String> technicalSources;

  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get domain => 'power';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
  @override
  String? get evidenceBinaryVersion => null;
  @override
  String? get evidenceSha256 => null;
  @override
  List<String> get supportedEditions => const <String>['Home', 'Pro'];
  @override
  List<String> get supportedArchitectures => const <String>['x64'];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000 || context.architecture != 'x64') {
      return const SupportResult.unsupported(
        'Windows 11 x64 build 22000 or newer is required.',
      );
    }
    try {
      _desired(request);
      return const SupportResult.supported();
    } on FormatException catch (error) {
      return SupportResult.unsupported(error.message);
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    final scheme = request.target ?? _store.activeSchemeId;
    final value = _store.readSetting(scheme, subgroupId, settingId);
    return OperationState(
      OperationStateKind.configured,
      value: <String, int>{'ac': value.ac, 'dc': value.dc},
    );
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final scheme = request.target ?? _store.activeSchemeId;
    final activeScheme = _store.activeSchemeId;
    final value = _store.readSetting(scheme, subgroupId, settingId);
    return OperationSnapshot(
      type: 'powerSetting',
      data: <String, Object?>{
        'scheme': scheme,
        'activeScheme': activeScheme,
        'ac': value.ac,
        'dc': value.dc,
      },
      expectedAfterRollback: OperationState(
        OperationStateKind.configured,
        value: <String, int>{'ac': value.ac, 'dc': value.dc},
      ),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final scheme = request.target ?? _store.activeSchemeId;
    _store.writeSetting(scheme, subgroupId, settingId, _desired(request));
    if (_store.activeSchemeId == scheme) _store.setActiveScheme(scheme);
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'powerSetting') {
      throw StateError('Unexpected power snapshot type.');
    }
    final scheme = snapshot.data['scheme'];
    final activeScheme = snapshot.data['activeScheme'];
    final ac = snapshot.data['ac'];
    final dc = snapshot.data['dc'];
    if (scheme is! String ||
        activeScheme is! String ||
        ac is! int ||
        dc is! int ||
        (request.target != null && request.target != scheme)) {
      throw StateError('Invalid power snapshot.');
    }
    _store.writeSetting(
      scheme,
      subgroupId,
      settingId,
      PowerSettingValue(ac: ac, dc: dc),
    );
    _store.setActiveScheme(activeScheme);
  }

  static PowerSettingValue _desired(OperationRequest request) {
    final desired = request.desiredValue;
    if (desired is! Map || desired['ac'] is! int || desired['dc'] is! int) {
      throw const FormatException('AC and DC integer values are required.');
    }
    final ac = desired['ac']! as int;
    final dc = desired['dc']! as int;
    if (ac < 0 || dc < 0 || ac > 0xffffffff || dc > 0xffffffff) {
      throw const FormatException('Power values must be unsigned DWORDs.');
    }
    return PowerSettingValue(ac: ac, dc: dc);
  }
}
