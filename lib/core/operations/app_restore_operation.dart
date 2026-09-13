import '../../features/apps/application/windows_app_inventory_service.dart';
import '../../features/apps/domain/microsoft_restore_catalog.dart';
import '../services/process_runner.dart';
import 'operation.dart';

class AppRestoreOperation extends OperationDefinition {
  AppRestoreOperation({
    required this.id,
    required this.legacyPackageName,
    required this.identity,
    required ProcessRunner processRunner,
  }) : _processRunner = processRunner,
       _inventory = WindowsAppInventoryService(processRunner: processRunner);

  @override
  final String id;
  final String legacyPackageName;
  final MicrosoftRestoreIdentity identity;
  final ProcessRunner _processRunner;
  final WindowsAppInventoryService _inventory;

  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => '$id.title';
  @override
  String get descriptionKey => '$id.description';
  @override
  String get domain => 'app';
  @override
  String get destination => 'App';
  @override
  OperationScope get scope => OperationScope.app;
  @override
  OperationRisk get risk => OperationRisk.low;
  @override
  OperationPrivilege get privilege => OperationPrivilege.user;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.manual;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.documented;
  @override
  List<String> get technicalSources => const <String>[
    'https://learn.microsoft.com/windows/package-manager/winget/install',
    'https://learn.microsoft.com/powershell/module/appx/get-appxpackage',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.architecture != 'x64' || context.windowsBuild < 22000) {
      return const SupportResult.unsupported('Windows 11 x64 is required.');
    }
    if (request.desiredValue != true ||
        request.target != null ||
        request.parameters.isNotEmpty) {
      return const SupportResult.unsupported('Invalid app restore request.');
    }
    return const SupportResult.supported();
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    final inventory = identity.source == 'msstore'
        ? await _inventory.scanCurrentUser()
        : await _inventory.scanWinget();
    final complete = identity.source == 'msstore'
        ? inventory.currentUserComplete
        : inventory.wingetComplete;
    if (!complete) {
      return OperationState(
        OperationStateKind.error,
        message: inventory.message ?? 'App inventory is unavailable.',
      );
    }
    final installed = inventory.packages.any(
      (package) =>
          package.packageId.toLowerCase() == legacyPackageName.toLowerCase() ||
          package.packageId.toLowerCase() == identity.packageId.toLowerCase(),
    );
    return !installed
        ? const OperationState(OperationStateKind.absent)
        : const OperationState(OperationStateKind.configured, value: true);
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final before = await inspect(request);
    if (before.kind == OperationStateKind.error) {
      throw StateError(before.message ?? 'App inventory is unavailable.');
    }
    return OperationSnapshot(
      type: 'appInstall',
      data: <String, Object?>{
        'legacyPackageName': legacyPackageName,
        'packageId': identity.packageId,
        'source': identity.source,
        'installed': before.kind == OperationStateKind.configured,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) => _runWinget('install');

  @override
  Future<OperationState> verify(OperationRequest request) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final state = await inspect(request);
      if (state.kind == OperationStateKind.configured ||
          state.kind == OperationStateKind.error) {
        return state;
      }
      await Future<void>.delayed(const Duration(seconds: 1));
    }
    return inspect(request);
  }

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'appInstall' ||
        snapshot.data['legacyPackageName'] != legacyPackageName ||
        snapshot.data['packageId'] != identity.packageId ||
        snapshot.data['source'] != identity.source) {
      throw StateError('App snapshot target mismatch.');
    }
    throw StateError('App restore rollback requires manual uninstall review.');
  }

  Future<void> _runWinget(String command) async {
    final result = await _processRunner.run('winget', <String>[
      command,
      '--exact',
      '--id',
      identity.packageId,
      '--source',
      identity.source,
      '--accept-source-agreements',
      if (command == 'install') '--accept-package-agreements',
      '--disable-interactivity',
    ], timeout: const Duration(minutes: 10));
    if (!result.success) {
      throw StateError(
        result.details.isEmpty ? 'winget $command failed.' : result.details,
      );
    }
  }
}
