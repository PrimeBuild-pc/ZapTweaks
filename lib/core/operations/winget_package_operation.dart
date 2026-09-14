import '../../features/apps/application/windows_app_inventory_service.dart';
import '../services/process_runner.dart';
import 'operation.dart';

class WingetPackageOperation implements OperationDefinition {
  WingetPackageOperation({required ProcessRunner processRunner})
    : _runner = processRunner,
      _inventory = WindowsAppInventoryService(processRunner: processRunner);

  final ProcessRunner _runner;
  final WindowsAppInventoryService _inventory;
  static final RegExp _packageId = RegExp(r'^[A-Za-z0-9._-]{1,200}$');

  String _target(OperationRequest request) {
    final target = request.target;
    if (target == null || !_packageId.hasMatch(target)) {
      throw StateError('Invalid winget package identity.');
    }
    if (request.desiredValue is! bool) {
      throw StateError('winget package state must be boolean.');
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
    final target = _target(request).toLowerCase();
    final result = await _inventory.scanWinget();
    if (!result.wingetComplete) {
      return OperationState(
        OperationStateKind.error,
        message: result.message ?? 'Unable to read winget inventory.',
      );
    }
    final installed = result.packages.any(
      (package) => package.packageId.toLowerCase() == target,
    );
    return OperationState(OperationStateKind.configured, value: installed);
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final before = await inspect(request);
    if (before.kind != OperationStateKind.configured || before.value is! bool) {
      throw StateError(before.message ?? 'Unable to snapshot winget package.');
    }
    return OperationSnapshot(
      type: 'wingetPackage',
      data: <String, Object?>{
        'packageId': _target(request),
        'installed': before.value,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) =>
      _setInstalled(_target(request), request.desiredValue! as bool);

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'wingetPackage' ||
        snapshot.data['packageId'] != _target(request) ||
        snapshot.data['installed'] is! bool) {
      throw StateError('Invalid winget package snapshot.');
    }
    await _setInstalled(request.target!, snapshot.data['installed']! as bool);
  }

  Future<void> _setInstalled(String packageId, bool installed) async {
    final result = await _runner.run('winget', <String>[
      installed ? 'install' : 'uninstall',
      '--exact',
      '--id',
      packageId,
      if (installed) ...<String>[
        '--accept-source-agreements',
        '--accept-package-agreements',
      ],
      '--disable-interactivity',
    ]);
    if (!result.success) throw StateError(result.details);
  }

  @override
  String get id => 'app.winget.set';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'wingetPackageTitle';
  @override
  String get descriptionKey => 'wingetPackageDescription';
  @override
  String get domain => 'apps';
  @override
  String get destination => 'Apps';
  @override
  OperationScope get scope => OperationScope.app;
  @override
  OperationRisk get risk => OperationRisk.medium;
  @override
  OperationPrivilege get privilege => OperationPrivilege.user;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
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
    'https://learn.microsoft.com/windows/package-manager/winget/install',
    'https://learn.microsoft.com/windows/package-manager/winget/uninstall',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
