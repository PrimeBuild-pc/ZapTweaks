import '../../platform/windows/scheduled_task_service.dart';
import 'operation.dart';

class ScheduledTaskOperation implements OperationDefinition {
  const ScheduledTaskOperation({
    required this.store,
    required this.allowedTasks,
  });

  final ScheduledTaskStore store;
  final Set<String> allowedTasks;

  ({String path, String name}) _target(OperationRequest request) {
    final target = request.target;
    if (target == null || !allowedTasks.contains(target)) {
      throw StateError('Scheduled task is not allowlisted.');
    }
    final split = target.lastIndexOf(r'\');
    if (split <= 0 || split == target.length - 1) {
      throw StateError('Invalid scheduled task identity.');
    }
    return (
      path: target.substring(0, split + 1),
      name: target.substring(split + 1),
    );
  }

  bool _desired(OperationRequest request) {
    if (request.desiredValue is! bool) {
      throw StateError('Task state must be Boolean.');
    }
    return request.desiredValue! as bool;
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
      final target = _target(request);
      _desired(request);
      await store.inspect(target.path, target.name);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final target = _target(request);
      final state = await store.inspect(target.path, target.name);
      return OperationState(
        OperationStateKind.configured,
        value: state.enabled,
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
      throw StateError(before.message ?? 'Task inspection failed.');
    }
    return OperationSnapshot(
      type: 'scheduledTaskState',
      data: <String, Object?>{
        'target': request.target,
        'enabled': before.value,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final target = _target(request);
    await store.setEnabled(target.path, target.name, _desired(request));
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'scheduledTaskState' ||
        snapshot.data['target'] != request.target) {
      throw StateError('Invalid scheduled task snapshot.');
    }
    final target = _target(request);
    await store.setEnabled(
      target.path,
      target.name,
      snapshot.data['enabled']! as bool,
    );
  }

  @override
  String get id => 'task.enabled.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'scheduledTaskTitle';
  @override
  String get descriptionKey => 'scheduledTaskDescription';
  @override
  String get domain => 'tasks';
  @override
  String get destination => 'Windows';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
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
    'https://learn.microsoft.com/powershell/module/scheduledtasks/get-scheduledtask',
    'https://learn.microsoft.com/powershell/module/scheduledtasks/disable-scheduledtask',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
