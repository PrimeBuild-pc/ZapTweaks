import '../../features/apps/application/windows_optional_feature_service.dart';
import '../../features/apps/domain/windows_optional_feature.dart';
import 'operation.dart';

class OptionalFeatureOperation implements OperationDefinition {
  const OptionalFeatureOperation(this._service);

  final WindowsOptionalFeatureService _service;

  String _target(OperationRequest request) {
    final target = request.target;
    if (target == null ||
        !WindowsOptionalFeatureService.validName.hasMatch(target)) {
      throw StateError('Invalid optional feature identity.');
    }
    if (request.desiredValue is! bool) {
      throw StateError('Optional feature state must be boolean.');
    }
    return target;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _target(request);
      return context.architecture == 'x64' && context.windowsBuild >= 22000
          ? const SupportResult.supported()
          : const SupportResult.unsupported('Requires Windows 11 x64.');
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final target = _target(request);
      final matches = (await _service.scan()).where(
        (feature) => feature.name == target,
      );
      if (matches.isEmpty) {
        return const OperationState(OperationStateKind.notApplicable);
      }
      final feature = matches.single;
      return switch (feature.state) {
        WindowsOptionalFeatureState.enabled => const OperationState(
          OperationStateKind.configured,
          value: true,
        ),
        WindowsOptionalFeatureState.disabled => const OperationState(
          OperationStateKind.configured,
          value: false,
        ),
        WindowsOptionalFeatureState.enablePending => const OperationState(
          OperationStateKind.pendingRestart,
          value: true,
        ),
        WindowsOptionalFeatureState.disablePending => const OperationState(
          OperationStateKind.pendingRestart,
          value: false,
        ),
        WindowsOptionalFeatureState.unknown => const OperationState(
          OperationStateKind.unknown,
          message: 'Unknown optional feature state.',
        ),
      };
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
    if (before.kind != OperationStateKind.configured || before.value is! bool) {
      throw StateError('Optional feature has no stable state to snapshot.');
    }
    return OperationSnapshot(
      type: 'windowsOptionalFeature',
      data: <String, Object?>{
        'name': _target(request),
        'enabled': before.value,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) =>
      _service.setEnabled(_target(request), request.desiredValue! as bool);

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'windowsOptionalFeature' ||
        snapshot.data['name'] != _target(request) ||
        snapshot.data['enabled'] is! bool) {
      throw StateError('Invalid optional feature snapshot.');
    }
    await _service.setEnabled(
      request.target!,
      snapshot.data['enabled']! as bool,
    );
  }

  @override
  String get id => 'app.optional_feature.set';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'optionalFeatureTitle';
  @override
  String get descriptionKey => 'optionalFeatureDescription';
  @override
  String get domain => 'apps';
  @override
  String get destination => 'Apps';
  @override
  OperationScope get scope => OperationScope.app;
  @override
  OperationRisk get risk => OperationRisk.medium;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.reboot;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.bestEffort;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
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
    'https://learn.microsoft.com/powershell/module/dism/enable-windowsoptionalfeature',
    'https://learn.microsoft.com/powershell/module/dism/disable-windowsoptionalfeature',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
