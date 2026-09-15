import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/service_start_operation.dart';
import 'package:script_utility/platform/windows/service_control_manager.dart';

class _Services implements ServiceConfigurationStore {
  int startType = 3;
  bool delayed = false;

  @override
  void configureStart(
    String name, {
    required int startType,
    required bool delayedAutoStart,
  }) {
    this.startType = startType;
    delayed = delayedAutoStart;
  }

  @override
  WindowsServiceInfo inspect(String name) => WindowsServiceInfo(
    name: name,
    displayName: name,
    startType: startType,
    delayedAutoStart: delayed,
    state: 1,
    account: 'LocalSystem',
    dependencies: const <String>[],
    processId: 0,
  );
}

void main() {
  test(
    'service startup operation snapshots and restores exact configuration',
    () async {
      final services = _Services();
      final operation = ServiceStartOperation(
        store: services,
        allowedServices: const <String>{'ExampleSvc'},
      );
      const request = OperationRequest(
        operationId: 'service.start.configure',
        target: 'ExampleSvc',
        desiredValue: <String, Object?>{
          'startType': 2,
          'delayedAutoStart': true,
        },
      );
      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      expect((await operation.verify(request)).value, request.desiredValue);
      await operation.rollback(request, snapshot);
      expect(
        (await operation.inspect(
          request,
        )).sameValue(snapshot.expectedAfterRollback),
        isTrue,
      );
    },
  );

  test('service startup operation rejects non-allowlisted services', () async {
    final operation = ServiceStartOperation(
      store: _Services(),
      allowedServices: const <String>{'ExampleSvc'},
    );
    const request = OperationRequest(
      operationId: 'service.start.configure',
      target: 'CriticalSvc',
      desiredValue: <String, Object?>{
        'startType': 4,
        'delayedAutoStart': false,
      },
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
