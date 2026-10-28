import '../services/process_runner.dart';
import 'operation.dart';

/// Creates a System Restore point before a batch of changes.
///
/// Windows skips a new point when one was made in the last 24 hours, which
/// would leave today's changes unprotected, so the creation frequency is set
/// to 0 for the call and put back afterwards. System Protection is switched
/// on only when the request asks for it: a disabled protection is reported
/// as an error so the UI can ask the user.
class RestorePointOperation implements OperationDefinition {
  RestorePointOperation({required ProcessRunner processRunner})
    : _runner = processRunner;

  final ProcessRunner _runner;
  static final _description = RegExp(r'^[A-Za-z0-9 ._-]{1,64}$');

  ({String description, bool enable}) _parse(OperationRequest request) {
    final description = request.parameters['description'];
    final enable = request.parameters['enableProtection'] ?? false;
    if (description is! String ||
        !_description.hasMatch(description) ||
        enable is! bool ||
        request.desiredValue != true) {
      throw StateError('Invalid restore point request.');
    }
    return (description: description, enable: enable);
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _parse(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  /// True when the newest restore point carries this description.
  @override
  Future<OperationState> inspect(OperationRequest request) async {
    final description = _parse(request).description;
    try {
      final latest = await _runner.runPowerShellForOutput(
        r'$p = Get-ComputerRestorePoint -ErrorAction Stop | Sort-Object SequenceNumber | Select-Object -Last 1; [string]$p.Description',
      );
      return OperationState(
        OperationStateKind.configured,
        value: latest.trim() == description,
      );
    } catch (error) {
      return OperationState(OperationStateKind.error, message: '$error');
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async =>
      OperationSnapshot(
        type: 'restorePoint',
        data: <String, Object?>{'description': _parse(request).description},
        expectedAfterRollback: const OperationState(
          OperationStateKind.configured,
          value: false,
        ),
      );

  @override
  Future<void> apply(OperationRequest request) async {
    final (:description, :enable) = _parse(request);
    // The description passed _description, so it cannot close the quotes.
    await _runner.runPowerShellForOutput('''
\$ErrorActionPreference = 'Stop'
\$key = 'HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\SystemRestore'
\$name = 'SystemRestorePointCreationFrequency'
\$old = (Get-ItemProperty -LiteralPath \$key -Name \$name -ErrorAction SilentlyContinue).\$name
${enable ? r'Enable-ComputerRestore -Drive "$env:SystemDrive\"' : ''}
try {
  Set-ItemProperty -LiteralPath \$key -Name \$name -Value 0 -Type DWord
  Checkpoint-Computer -Description '$description' -RestorePointType MODIFY_SETTINGS
} finally {
  if (\$null -eq \$old) { Remove-ItemProperty -LiteralPath \$key -Name \$name -ErrorAction SilentlyContinue }
  else { Set-ItemProperty -LiteralPath \$key -Name \$name -Value \$old -Type DWord }
}
''');
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError('A restore point is not rolled back.');

  @override
  String get id => 'system.restore_point.create';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'restorePointTitle';
  @override
  String get descriptionKey => 'restorePointDescription';
  @override
  String get domain => 'recovery';
  @override
  String get destination => 'Diagnostics & Recovery';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  OperationRisk get risk => OperationRisk.low;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.none;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.documented;
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
    'https://learn.microsoft.com/powershell/module/microsoft.powershell.management/checkpoint-computer',
    'https://learn.microsoft.com/windows/win32/sr/srsetrestorepoint',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
