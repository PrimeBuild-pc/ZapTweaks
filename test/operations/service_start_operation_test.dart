import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/service_start_operation.dart';
import 'package:script_utility/platform/windows/service_control_manager.dart';

class _Services implements ServiceConfigurationStore {
  int startType = 3;
  bool delayed = false;
  List<String> dependents = [];
  String binaryPath = r'C:\Windows\system32\svchost.exe';
  int serviceType = 0x20;

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
    dependents: dependents,
    processId: 0,
    binaryPath: binaryPath,
    serviceType: serviceType,
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

  test('invalid startup requests never configure a service', () async {
    final services = _Services();
    final operation = ServiceStartOperation(
      store: services,
      allowedServices: const <String>{'ExampleSvc'},
    );
    for (final desired in <Object?>[
      null,
      4,
      <String, Object?>{'startType': 0, 'delayedAutoStart': false},
      <String, Object?>{'startType': 3, 'delayedAutoStart': true},
      <String, Object?>{'startType': '4', 'delayedAutoStart': false},
    ]) {
      final request = OperationRequest(
        operationId: operation.id,
        target: 'ExampleSvc',
        desiredValue: desired,
      );
      expect(
        (await operation.supports(
          const OperationContext(windowsBuild: 26100, edition: 'Pro'),
          request,
        )).supported,
        isFalse,
      );
      await expectLater(operation.apply(request), throwsStateError);
    }
    expect(services.startType, 3);
    expect(services.delayed, isFalse);
  });

  test('dependent services are rechecked at the mutation boundary', () async {
    final services = _Services();
    final operation = ServiceStartOperation(
      store: services,
      allowedServices: const {'ExampleSvc'},
    );
    const request = OperationRequest(
      operationId: 'service.start.configure',
      target: 'ExampleSvc',
      desiredValue: {'startType': 4, 'delayedAutoStart': false},
    );
    expect(
      (await operation.supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        request,
      )).supported,
      isTrue,
    );
    services.dependents = ['RequiredConsumer'];
    await expectLater(operation.apply(request), throwsStateError);
    expect(services.startType, 3);
    expect(
      (await operation.supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        request,
      )).supported,
      isFalse,
    );
  });

  test(
    'rollback restores Manual + delayed flag exactly as Windows had it',
    () async {
      // dmwappushservice, BITS, DoSvc ship as Manual with DelayedAutoStart=1.
      final services = _Services()
        ..startType = 3
        ..delayed = true;
      final operation = ServiceStartOperation(
        store: services,
        allowedServices: const {'ExampleSvc'},
      );
      const request = OperationRequest(
        operationId: 'service.start.configure',
        target: 'ExampleSvc',
        desiredValue: {'startType': 4, 'delayedAutoStart': false},
      );
      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      expect((services.startType, services.delayed), (4, false));

      await operation.rollback(request, snapshot);

      expect((services.startType, services.delayed), (3, true));
      expect(
        (await operation.inspect(
          request,
        )).sameValue(snapshot.expectedAfterRollback),
        isTrue,
      );
    },
  );

  test('rollback also refuses to disable a newly required service', () async {
    final services = _Services()..startType = 4;
    final operation = ServiceStartOperation(
      store: services,
      allowedServices: const {'ExampleSvc'},
    );
    const request = OperationRequest(
      operationId: 'service.start.configure',
      target: 'ExampleSvc',
      desiredValue: {'startType': 3, 'delayedAutoStart': false},
    );
    final snapshot = await operation.captureSnapshot(request);
    await operation.apply(request);
    services.dependents = ['NewConsumer'];
    await expectLater(operation.rollback(request, snapshot), throwsStateError);
    expect(services.startType, 3);
  });

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

  test(
    'unlisted services pass only when the policy accepts what SCM reports',
    () async {
      final services = _Services()..binaryPath = r'C:\Program Files\V\v.exe';
      final operation = ServiceStartOperation(
        store: services,
        allowedServices: const <String>{'ExampleSvc'},
        allowService: (info) =>
            info.binaryPath.startsWith(r'C:\Program Files\') &&
            info.serviceType & 0x30 != 0,
      );
      OperationRequest request(String target) => OperationRequest(
        operationId: 'service.start.configure',
        target: target,
        desiredValue: const <String, Object?>{
          'startType': 4,
          'delayedAutoStart': false,
        },
      );
      const context = OperationContext(windowsBuild: 26100, edition: 'Pro');
      expect(
        (await operation.supports(context, request('VendorSvc'))).supported,
        isTrue,
      );
      await operation.apply(request('VendorSvc'));
      expect(services.startType, 4);

      services
        ..startType = 3
        ..binaryPath = r'C:\Windows\system32\svchost.exe';
      expect(
        (await operation.supports(context, request('VendorSvc'))).supported,
        isFalse,
      );
      await expectLater(
        operation.apply(request('VendorSvc')),
        throwsStateError,
      );
      expect(services.startType, 3);

      services
        ..binaryPath = r'C:\Program Files\V\drv.sys'
        ..serviceType = 1;
      expect(
        (await operation.supports(context, request('VendorDrv'))).supported,
        isFalse,
        reason: 'kernel drivers are never offered',
      );
    },
  );

  test('a failing policy check refuses the service', () async {
    final services = _Services()..binaryPath = r'C:\Program Files\V\v.exe';
    final operation = ServiceStartOperation(
      store: services,
      allowedServices: const <String>{'ExampleSvc'},
      allowService: (info) async => throw StateError('Security Center read'),
    );
    const request = OperationRequest(
      operationId: 'service.start.configure',
      target: 'VendorSvc',
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
    await expectLater(operation.apply(request), throwsStateError);
    expect(services.startType, isNot(4));
  });
}
