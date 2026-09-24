import '../services/process_runner.dart';
import 'operation.dart';

class AppxRemovalOperation implements OperationDefinition {
  AppxRemovalOperation({
    required this.id,
    required this.systemScopes,
    required ProcessRunner processRunner,
  }) : _runner = processRunner;

  @override
  final String id;
  final bool systemScopes;
  final ProcessRunner _runner;

  static final RegExp _packageName = RegExp(r'^[A-Za-z0-9_.-]{1,200}$');

  String _target(OperationRequest request) {
    final target = request.target;
    if (target == null || !_packageName.hasMatch(target)) {
      throw StateError('Invalid AppX package identity.');
    }
    return target;
  }

  String _scope(OperationRequest request) {
    final scope = request.parameters['scope'];
    final allowed = systemScopes
        ? const <String>{'allUsers', 'provisioned'}
        : const <String>{'currentUser'};
    if (scope is! String || !allowed.contains(scope)) {
      throw StateError('Invalid AppX removal scope.');
    }
    return scope;
  }

  String _query(OperationRequest request) {
    final target = _target(request);
    return _scope(request) == 'provisioned'
        ? "@(Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object DisplayName -EQ '$target').Count"
        : "@(Get-AppxPackage -Name '$target'${systemScopes ? ' -AllUsers' : ''} -ErrorAction Stop).Count";
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _target(request);
      _scope(request);
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
      final count = int.tryParse(
        (await _runner.runPowerShellForOutput(_query(request))).trim(),
      );
      if (count == null) {
        return const OperationState(
          OperationStateKind.error,
          message: 'Unable to read AppX package state.',
        );
      }
      return count == 0
          ? const OperationState(OperationStateKind.absent)
          : OperationState(
              OperationStateKind.configured,
              value: request.target,
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
    if (before.kind == OperationStateKind.error) {
      throw StateError(before.message ?? 'Unable to snapshot AppX package.');
    }
    return OperationSnapshot(
      type: 'appxRemoval',
      data: <String, Object?>{
        'package': _target(request),
        'scope': _scope(request),
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final target = _target(request);
    final scope = _scope(request);
    final script = switch (scope) {
      'currentUser' =>
        "Get-AppxPackage -Name '$target' -ErrorAction Stop | Remove-AppxPackage -ErrorAction Stop",
      'allUsers' =>
        "Get-AppxPackage -Name '$target' -AllUsers -ErrorAction Stop | Remove-AppxPackage -AllUsers -ErrorAction Stop",
      'provisioned' =>
        "Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object DisplayName -EQ '$target' | ForEach-Object { Remove-AppxProvisionedPackage -Online -PackageName \$_.PackageName -ErrorAction Stop | Out-Null }",
      _ => throw StateError('Invalid AppX removal scope.'),
    };
    await _runner.runPowerShellScript(script);
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) => throw UnsupportedError(
    'AppX removal has no exact rollback. Use its declared restore source when available.',
  );

  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'appxRemovalTitle';
  @override
  String get descriptionKey => 'appxRemovalDescription';
  @override
  String get domain => 'apps';
  @override
  String get destination => 'Apps';
  @override
  OperationScope get scope => OperationScope.app;
  @override
  OperationRisk get risk => OperationRisk.medium;
  @override
  OperationPrivilege get privilege =>
      systemScopes ? OperationPrivilege.administrator : OperationPrivilege.user;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.none;
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
    'https://learn.microsoft.com/powershell/module/appx/remove-appxpackage',
    'https://learn.microsoft.com/powershell/module/dism/remove-appxprovisionedpackage',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
