import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/operations/native_operation_catalog.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/operation_registry.dart';
import 'package:script_utility/core/operations/registry_dword_operation.dart';
import 'package:script_utility/core/persistence/operation_store.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/plans/plan_engine.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';
import 'package:sqlite3/sqlite3.dart';

class _MemoryRegistry implements RegistryValueStore {
  final Map<String, RawRegistryValue> values = <String, RawRegistryValue>{};

  String _key(String path, String name, RegistryView view) =>
      '${view.name}/$path/$name';

  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async {
    values.remove(_key(path, name, view));
  }

  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async {
    final value = values[_key(path, name, view)];
    return value == null
        ? null
        : RawRegistryValue(
            type: value.type,
            bytes: Uint8List.fromList(value.bytes),
          );
  }

  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  }) async {
    values[_key(path, name, view)] = RawRegistryValue(
      type: value.type,
      bytes: Uint8List.fromList(value.bytes),
    );
  }
}

RegistryDwordOperation _operation(RegistryValueStore store) =>
    RegistryDwordOperation(
      id: 'registry.sample.set',
      titleKey: 'registrySampleTitle',
      descriptionKey: 'registrySampleDescription',
      destination: 'Expert',
      path: r'HKCU\Software\ZapTweaksTest',
      valueName: 'Sample',
      store: store,
      privilege: OperationPrivilege.user,
      scope: OperationScope.user,
    );

void main() {
  test('native catalog migrates Taskbar End task to the typed engine', () {
    final operations = createNativeOperationCatalog(
      _MemoryRegistry(),
      ProcessRunner(mode: ProcessExecutionMode.dryRun),
    );
    final operation = operations.singleWhere(
      (item) => item.id == 'ui_taskbar_end_task',
    );

    expect(operations, hasLength(33));
    expect(operation.id, 'ui_taskbar_end_task');
    expect(operation.scope, OperationScope.user);
    expect(operation.rollbackCapability, RollbackCapability.exact);
    expect(operations.any((item) => item.id == 'power_throttling_off'), isTrue);
    expect(
      operations.any((item) => item.id == 'power_processor_boost_mode'),
      isTrue,
    );
    expect(
      operations.any((item) => item.id == 'power_max_processor_state'),
      isTrue,
    );
  });

  test(
    'DWORD plan preserves type and exact existing bytes on rollback',
    () async {
      final registry = _MemoryRegistry();
      final key =
          '${RegistryView.registry64.name}/'
          '${r'HKCU\Software\ZapTweaksTest'}/Sample';
      registry.values[key] = RawRegistryValue(
        type: RegistryDwordOperation.regDword,
        bytes: Uint8List.fromList(<int>[0x78, 0x56, 0x34, 0x12]),
      );
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final operation = _operation(registry);
      final engine = PlanEngine(
        registry: OperationRegistry(<OperationDefinition>[operation]),
        context: const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        user: 'test-user',
        appVersion: 'test',
        store: OperationStore(database),
      );
      final plan = await engine.plan(const <OperationRequest>[
        OperationRequest(operationId: 'registry.sample.set', desiredValue: 1),
      ]);

      await engine.execute(plan);

      expect(plan.status, PlanStatus.completed);
      expect(plan.items.single.written?.value, 1);
      expect(
        registry.values[key]?.bytes,
        Uint8List.fromList(<int>[1, 0, 0, 0]),
      );

      final persisted = engine.store!.load(plan.id)!;
      await engine.rollback(persisted);

      expect(persisted.status, PlanStatus.rolledBack);
      expect(
        registry.values[key]?.bytes,
        Uint8List.fromList(<int>[0x78, 0x56, 0x34, 0x12]),
      );
    },
  );

  test('rollback removes only a value that was originally absent', () async {
    final registry = _MemoryRegistry();
    final operation = _operation(registry);
    const request = OperationRequest(
      operationId: 'registry.sample.set',
      desiredValue: 7,
    );
    final snapshot = await operation.captureSnapshot(request);

    await operation.apply(request);
    await operation.rollback(request, snapshot);

    expect((await operation.inspect(request)).kind, OperationStateKind.absent);
  });

  test('invalid DWORD requests are not applicable', () async {
    final operation = _operation(_MemoryRegistry());
    final support = await operation.supports(
      const OperationContext(windowsBuild: 26100, edition: 'Home'),
      const OperationRequest(
        operationId: 'registry.sample.set',
        desiredValue: -1,
      ),
    );

    expect(support.supported, isFalse);
  });
}
