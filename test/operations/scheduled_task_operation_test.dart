import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/scheduled_task_operation.dart';
import 'package:script_utility/platform/windows/scheduled_task_service.dart';

class _Tasks implements ScheduledTaskStore {
  bool enabled = true;
  @override
  Future<ScheduledTaskState> inspect(String path, String name) async =>
      ScheduledTaskState(path: path, name: name, enabled: enabled);
  @override
  Future<void> setEnabled(String path, String name, bool enabled) async {
    this.enabled = enabled;
  }
}

void main() {
  test('scheduled task state is verified and restored exactly', () async {
    final tasks = _Tasks();
    final operation = ScheduledTaskOperation(
      store: tasks,
      allowedTasks: const <String>{
        r'\Microsoft\Windows\Defrag\ScheduledDefrag',
      },
    );
    const request = OperationRequest(
      operationId: 'task.enabled.configure',
      target: r'\Microsoft\Windows\Defrag\ScheduledDefrag',
      desiredValue: false,
    );
    final snapshot = await operation.captureSnapshot(request);
    await operation.apply(request);
    expect((await operation.verify(request)).value, isFalse);
    await operation.rollback(request, snapshot);
    expect(
      (await operation.inspect(
        request,
      )).sameValue(snapshot.expectedAfterRollback),
      isTrue,
    );
  });

  test('scheduled task operation rejects arbitrary task paths', () async {
    final operation = ScheduledTaskOperation(
      store: _Tasks(),
      allowedTasks: const <String>{
        r'\Microsoft\Windows\Defrag\ScheduledDefrag',
      },
    );
    const request = OperationRequest(
      operationId: 'task.enabled.configure',
      target: r'\Attacker\Task',
      desiredValue: false,
    );
    expect(
      (await operation.supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        request,
      )).supported,
      isFalse,
    );
  });
}
