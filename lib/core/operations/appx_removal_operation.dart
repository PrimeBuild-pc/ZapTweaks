import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../features/apps/domain/appx_candidate_policy.dart';
import '../../features/apps/domain/microsoft_restore_catalog.dart';
import '../services/process_runner.dart';
import 'operation.dart';

class AppxRemovalOperation implements OperationDefinition {
  AppxRemovalOperation({
    required this.id,
    required this.systemScopes,
    required ProcessRunner processRunner,
    Map<String, MicrosoftRestoreIdentity> allowedPackages =
        microsoftRestoreCatalog,
  }) : _runner = processRunner,
       _allowedPackages = Map<String, MicrosoftRestoreIdentity>.unmodifiable(
         allowedPackages,
       );

  @override
  final String id;
  final bool systemScopes;
  final ProcessRunner _runner;
  final Map<String, MicrosoftRestoreIdentity> _allowedPackages;

  String _target(OperationRequest request) {
    final target = request.target;
    if (target == null || appxCandidatePolicy[target]?.removable != true) {
      throw StateError('AppX package is protected or inventory-only.');
    }
    return target;
  }

  MicrosoftRestoreIdentity? _identity(OperationRequest request) =>
      _allowedPackages[_target(request)] ??
      appxCandidatePolicy[_target(request)]!.restore;

  void _validate(OperationRequest request) {
    if (request.operationId != id ||
        request.desiredValue != null ||
        request.parameters.length != 1 ||
        !request.parameters.containsKey('scope')) {
      throw StateError('Invalid AppX removal request.');
    }
    _target(request);
    _scope(request);
  }

  String _scope(OperationRequest request) {
    final scope = request.parameters['scope'];
    final allowed = systemScopes
        ? const <String>{'allUsers', 'provisioned', 'allUsersAndProvisioned'}
        : const <String>{'currentUser'};
    if (scope is! String || !allowed.contains(scope)) {
      throw StateError('Invalid AppX removal scope.');
    }
    return scope;
  }

  String _query(OperationRequest request) => appxInventoryScript(
    allUsers: systemScopes,
    provisioned: _scope(request) != 'allUsers' && systemScopes,
  );

  Future<({String json, List<Map<String, dynamic>> targets})> _preflight(
    OperationRequest request,
  ) async {
    _validate(request);
    final json = (await _runner.runPowerShellForOutput(_query(request))).trim();
    final inventory = Map<String, dynamic>.from(jsonDecode(json) as Map);
    return (
      json: json,
      targets: validateAppxRemovalInventory(
        inventory,
        _target(request),
        _scope(request),
      ),
    );
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _validate(request);
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
      final result = await _preflight(request);
      return result.targets.isEmpty
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
    _validate(request);
    final before = await inspect(request);
    if (before.kind == OperationStateKind.error) {
      throw StateError(before.message ?? 'Unable to snapshot AppX package.');
    }
    return OperationSnapshot(
      type: 'appxRemoval',
      data: <String, Object?>{
        'package': _target(request),
        'scope': _scope(request),
        'restorePackageId': _identity(request)?.packageId,
        'restoreSource': _identity(request)?.source,
        'rollbackAvailable': false,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final preflight = await _preflight(request);
    final scope = _scope(request);
    final expected = sha256.convert(utf8.encode(preflight.json)).toString();
    // Requery both scopes in the mutation process before the first write.
    final script =
        '''
\$ErrorActionPreference = 'Stop'
\$actual = (& { ${_query(request)} } | Out-String).Trim()
\$sha = [Security.Cryptography.SHA256]::Create()
try {
  \$actualHash = [BitConverter]::ToString(\$sha.ComputeHash([Text.Encoding]::UTF8.GetBytes(\$actual))).Replace('-', '').ToLowerInvariant()
} finally { \$sha.Dispose() }
if (\$actualHash -cne '$expected') { throw 'AppX inventory changed after preflight; nothing removed.' }
${preflight.targets.map((row) {
          if (row.containsKey('PackageName')) {
            return "if (@(Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object { \$_.PackageName -ceq '${row['PackageName']}' }).Count -gt 0) { Remove-AppxProvisionedPackage -Online -PackageName '${row['PackageName']}' -ErrorAction Stop | Out-Null }";
          }
          final users = scope == 'allUsersAndProvisioned' || scope == 'allUsers' ? '-AllUsers' : '';
          // Removing a bundle may also remove a later captured main-package identity.
          return "if (@(Get-AppxPackage $users -PackageTypeFilter All -ErrorAction Stop | Where-Object { \$_.PackageFullName -ceq '${row['PackageFullName']}' }).Count -gt 0) { Remove-AppxPackage -Package '${row['PackageFullName']}' $users -ErrorAction Stop }";
        }).join('\n')}
''';
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
  int get version => 2;
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
