import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/operation_registry.dart';
import 'package:script_utility/core/operations/registry_dword_operation.dart';
import 'package:script_utility/core/operations/sparkle_operations.dart';
import 'package:script_utility/core/persistence/operation_store.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/plans/plan_engine.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';
import 'package:sqlite3/sqlite3.dart';

class _Registry implements RegistryValueStore {
  final values = <String, RawRegistryValue>{};
  final writes = <String>[];
  bool ignoreWrites = false;
  String key(String path, String name, RegistryView view) =>
      '${view.name}/$path/$name';

  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async {
    final raw = values[key(path, name, view)];
    return raw == null
        ? null
        : RawRegistryValue(
            type: raw.type,
            bytes: Uint8List.fromList(raw.bytes),
          );
  }

  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => values.remove(key(path, name, view));

  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  }) async {
    final target = key(path, name, view);
    writes.add(target);
    if (!ignoreWrites) {
      values[target] = RawRegistryValue(
        type: value.type,
        bytes: Uint8List.fromList(value.bytes),
      );
    }
  }
}

const _context = OperationContext(windowsBuild: 26100, edition: 'Pro');

RegistryDwordOperation _find(_Registry registry, String id) =>
    createSparkleManualOperations(registry).singleWhere((op) => op.id == id)
        as RegistryDwordOperation;

void main() {
  test(
    'registration is fixed, non-network, user/admin separated, no payload',
    () {
      final operations = createSparkleManualOperations(_Registry());
      expect(operations, hasLength(9));
      expect(operations.map((op) => op.id).toSet(), hasLength(9));
      expect(
        operations.every(
          (op) => op.rollbackCapability == RollbackCapability.exact,
        ),
        isTrue,
      );
      expect(
        operations.every(
          (op) => op.technicalSources.contains(sparkleSourceUrl),
        ),
        isTrue,
      );
      expect(
        operations.where((op) => op.privilege == OperationPrivilege.user),
        hasLength(7),
      );
      expect(
        operations.where((op) => op.risk == OperationRisk.high),
        hasLength(2),
      );
      expect(
        operations.any(
          (op) => RegExp('defender|edge|nvidia|network').hasMatch(op.id),
        ),
        isFalse,
      );
    },
  );

  test(
    'all fixed DWORDs reject deletes, wrong type, other targets and values before apply',
    () async {
      final registry = _Registry();
      for (final op in createSparkleManualOperations(
        registry,
      ).whereType<SparkleFixedDwordOperation>()) {
        for (final value in <Object?>[
          null,
          true,
          '${op.fixedValue}',
          op.fixedValue == 1 ? 0 : 1,
        ]) {
          final request = OperationRequest(
            operationId: op.id,
            desiredValue: value,
          );
          expect((await op.supports(_context, request)).supported, isFalse);
          await expectLater(op.apply(request), throwsArgumentError);
        }
        final wrongTarget = OperationRequest(
          operationId: op.id,
          desiredValue: op.fixedValue,
          target: 'other',
        );
        expect((await op.supports(_context, wrongTarget)).supported, isFalse);
        await expectLater(op.apply(wrongTarget), throwsArgumentError);
      }
      expect(registry.writes, isEmpty);
    },
  );

  test(
    'clock formats are UTF-16LE REG_SZ; verify and journal rollback restore arbitrary raw type/bytes',
    () async {
      for (final id in <String>[
        'sparkle.clock.short_time',
        'sparkle.clock.time_format',
      ]) {
        final registry = _Registry();
        final op = _find(registry, id) as SparkleRegistryStringOperation;
        final key = registry.key(op.path, op.valueName, op.view);
        final key32 = registry.key(
          op.path,
          op.valueName,
          RegistryView.registry32,
        );
        registry.values[key] = RawRegistryValue(
          type: 3,
          bytes: Uint8List.fromList([0, 255, 19]),
        );
        registry.values[key32] = RawRegistryValue(
          type: 3,
          bytes: Uint8List.fromList([42]),
        );
        final database = sqlite3.openInMemory();
        addTearDown(database.close);
        final engine = PlanEngine(
          registry: OperationRegistry([op]),
          context: _context,
          user: 'mock',
          appVersion: 'test',
          store: OperationStore(database),
        );
        final plan = await engine.plan([
          OperationRequest(operationId: id, desiredValue: op.fixedValue),
        ]);
        await engine.execute(plan);
        expect(plan.status, PlanStatus.completed);
        expect(plan.items.single.written?.value, op.fixedValue);
        expect(registry.values[key]!.type, 1);
        expect(registry.values[key]!.bytes, [
          for (final unit in op.fixedValue!.codeUnits) ...[unit, 0],
          0,
          0,
        ]);
        final persisted = engine.store!.load(plan.id)!;
        await engine.rollback(persisted);
        expect(persisted.status, PlanStatus.rolledBack);
        expect(registry.values[key]!.type, 3);
        expect(registry.values[key]!.bytes, [0, 255, 19]);
        expect(registry.values[key32]!.bytes, [42]);
      }
    },
  );

  test(
    'absent REG_SZ rollback deletes only the originally absent value',
    () async {
      final registry = _Registry();
      final op = _find(registry, 'sparkle.shell.menu_delay');
      const request = OperationRequest(
        operationId: 'sparkle.shell.menu_delay',
        desiredValue: '0',
      );
      final snapshot = await op.captureSnapshot(request);
      expect(snapshot.data['existed'], isFalse);
      await op.apply(request);
      expect((await op.verify(request)).value, '0');
      await op.rollback(request, snapshot);
      expect((await op.inspect(request)).kind, OperationStateKind.absent);
    },
  );

  test(
    'menu delay bounds and fixed clock strings reject malformed requests at apply boundary',
    () async {
      final registry = _Registry();
      final op = _find(registry, 'sparkle.shell.menu_delay');
      for (final value in <Object?>[
        '-1',
        '4001',
        '99999',
        '00',
        ' 0',
        '1\u0000',
        '1.5',
        '',
        0,
        null,
      ]) {
        final request = OperationRequest(
          operationId: op.id,
          desiredValue: value,
        );
        expect((await op.supports(_context, request)).supported, isFalse);
        await expectLater(op.apply(request), throwsArgumentError);
      }
      for (final value in <String>['0', '1', '4000']) {
        expect(
          (await op.supports(
            _context,
            OperationRequest(operationId: op.id, desiredValue: value),
          )).supported,
          isTrue,
        );
      }
      final clock = _find(registry, 'sparkle.clock.short_time');
      const invalid = OperationRequest(
        operationId: 'sparkle.clock.short_time',
        desiredValue: 'hh:mm tt',
      );
      expect((await clock.supports(_context, invalid)).supported, isFalse);
      await expectLater(clock.apply(invalid), throwsArgumentError);
      expect(registry.writes, isEmpty);
    },
  );

  test(
    'malformed REG_SZ is mixed and rollback preserves malformed bytes exactly',
    () async {
      final registry = _Registry();
      final op = _find(registry, 'sparkle.shell.menu_delay');
      final key = registry.key(op.path, op.valueName, op.view);
      const request = OperationRequest(
        operationId: 'sparkle.shell.menu_delay',
        desiredValue: '0',
      );
      for (final bytes in <List<int>>[
        [1],
        [49, 0],
        [49, 0, 0, 0, 50, 0, 0, 0],
      ]) {
        registry.values[key] = RawRegistryValue(
          type: 1,
          bytes: Uint8List.fromList(bytes),
        );
        expect((await op.inspect(request)).kind, OperationStateKind.mixed);
        final snapshot = await op.captureSnapshot(request);
        await op.apply(request);
        await op.rollback(request, snapshot);
        expect(registry.values[key]!.bytes, bytes);
      }
      final snapshot = await op.captureSnapshot(request);
      await expectLater(
        op.rollback(
          request,
          OperationSnapshot(
            type: snapshot.type,
            data: {...snapshot.data, 'view': 'registry32'},
            expectedAfterRollback: snapshot.expectedAfterRollback,
          ),
        ),
        throwsStateError,
      );
    },
  );

  test('ignored writes cannot produce a successful plan', () async {
    final registry = _Registry()..ignoreWrites = true;
    final op = _find(registry, 'sparkle.shell.menu_delay');
    final engine = PlanEngine(
      registry: OperationRegistry([op]),
      context: _context,
      user: 'mock',
      appVersion: 'test',
    );
    final plan = await engine.plan([
      OperationRequest(operationId: op.id, desiredValue: '0'),
    ]);
    await engine.execute(plan);
    expect(plan.status, PlanStatus.rollbackRequired);
    expect(plan.items.single.status, PlanItemStatus.failed);
  });

  test(
    'HVCI writes only configured Enabled; rejects managed/locked states including apply-time drift',
    () async {
      final registry = _Registry();
      final op = SparkleHvciConfiguredOperation(registry);
      final request = OperationRequest(operationId: op.id, desiredValue: 0);
      expect((await op.supports(_context, request)).supported, isTrue);
      expect(op.restartImpact, RestartImpact.reboot);
      final snapshot = await op.captureSnapshot(request);
      await op.apply(request);
      final observed = await op.verify(request);
      expect(observed.kind, OperationStateKind.configured);
      expect(observed.value, 0);
      expect(observed.message, contains('effective HVCI/VBS'));
      expect(registry.writes.single, endsWith('/${op.path}/Enabled'));
      await op.rollback(request, snapshot);
      expect((await op.inspect(request)).kind, OperationStateKind.absent);
      final lockedKey = registry.key(op.path, 'Locked', op.view);
      registry.values[lockedKey] = RawRegistryValue(
        type: 4,
        bytes: Uint8List.fromList([1, 0, 0, 0]),
      );
      expect((await op.supports(_context, request)).supported, isFalse);
      await expectLater(op.apply(request), throwsStateError);
      registry.values.remove(lockedKey);
      registry.values[registry.key(
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard',
        'HypervisorEnforcedCodeIntegrity',
        op.view,
      )] = RawRegistryValue(
        type: 4,
        bytes: Uint8List.fromList([0, 0, 0, 0]),
      );
      expect((await op.supports(_context, request)).supported, isFalse);
      await expectLater(op.apply(request), throwsStateError);
      expect(registry.writes, hasLength(1));
    },
  );

  test(
    'RDP uses exact requested policy key and restores existing non-DWORD raw value',
    () async {
      final registry = _Registry();
      final op = _find(registry, 'sparkle.security.rdp_warning_version');
      expect(
        op.path,
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client',
      );
      expect(op.valueName, 'RedirectionWarningDialogVersion');
      expect(op.privilege, OperationPrivilege.administrator);
      expect(op.risk, OperationRisk.high);
      final key = registry.key(op.path, op.valueName, op.view);
      registry.values[key] = RawRegistryValue(
        type: 1,
        bytes: Uint8List.fromList([49, 0, 0, 0]),
      );
      final request = OperationRequest(operationId: op.id, desiredValue: 1);
      final snapshot = await op.captureSnapshot(request);
      await op.apply(request);
      expect((await op.verify(request)).value, 1);
      await op.rollback(request, snapshot);
      expect(registry.values[key]!.type, 1);
      expect(registry.values[key]!.bytes, [49, 0, 0, 0]);
    },
  );
}
