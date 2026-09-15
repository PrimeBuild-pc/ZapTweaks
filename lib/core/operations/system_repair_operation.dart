import '../../platform/windows/system_repair_service.dart';
import 'operation.dart';

enum SystemRepairKind { componentStore, systemFiles }

class SystemRepairOperation implements OperationDefinition {
  SystemRepairOperation({required this.kind, required this.service});

  final SystemRepairKind kind;
  final WindowsRepairService service;
  RepairReport? _lastReport;

  void _validate(OperationRequest request) {
    if (request.target != null ||
        request.desiredValue != true ||
        request.parameters.isNotEmpty) {
      throw StateError('Invalid system repair request.');
    }
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
      _validate(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      _validate(request);
      final report = _lastReport;
      return report == null
          ? const OperationState(OperationStateKind.absent)
          : OperationState(
              report.verified
                  ? OperationStateKind.configured
                  : OperationStateKind.error,
              value: report.verified ? true : false,
              message: report.verified
                  ? null
                  : '${report.action} verification failed '
                        '(${report.verificationExitCode}).',
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
    return const OperationSnapshot(
      type: 'nonReversibleRepair',
      data: <String, Object?>{},
      expectedAfterRollback: OperationState(OperationStateKind.absent),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    _validate(request);
    _lastReport = kind == SystemRepairKind.componentStore
        ? await service.repairComponentStore()
        : await service.repairSystemFiles();
    if (!_lastReport!.verified) {
      throw StateError('${_lastReport!.action} did not pass verification.');
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError('Windows repairs are not reversible.');

  @override
  String get id => kind == SystemRepairKind.componentStore
      ? 'recovery.dism.restore_health'
      : 'recovery.sfc.scan_now';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => kind == SystemRepairKind.componentStore
      ? 'repairComponentStore'
      : 'repairSystemFiles';
  @override
  String get descriptionKey => kind == SystemRepairKind.componentStore
      ? 'repairComponentStoreDescription'
      : 'repairSystemFilesDescription';
  @override
  String get domain => 'recovery';
  @override
  String get destination => 'Diagnostics & Recovery';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  OperationRisk get risk => OperationRisk.medium;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.none;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.runtimeObserved;
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
    'https://learn.microsoft.com/windows-hardware/manufacture/desktop/repair-a-windows-image',
    'https://support.microsoft.com/windows/using-system-file-checker-in-windows-365e0031-36b1-6031-f804-8fd86e0ef4ca',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
