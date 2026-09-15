import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:script_utility/core/operations/driver_update_policy_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/features/drivers/application/driver_update_policy_store.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

class _Registry implements RegistryValueStore {
  RawRegistryValue? value;

  @override
  Future<void> delete(String path, String name, {RegistryView? view}) async {
    value = null;
  }

  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView? view,
  }) async => value;

  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView? view,
  }) async {
    this.value = RawRegistryValue(
      type: value.type,
      bytes: Uint8List.fromList(value.bytes),
    );
  }
}

int? _dword(RawRegistryValue? value) => value == null
    ? null
    : ByteData.sublistView(value.bytes).getUint32(0, Endian.little);

void main() {
  test(
    'temporary driver policy expires and restores the previous state',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'zap-driver-policy-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final now = DateTime.utc(2026, 1, 1);
      final registry = _Registry();
      final marker = DriverUpdatePolicyStore(
        path: p.join(directory.path, 'policy.json'),
      );
      final operation = DriverUpdatePolicyOperation(
        registry: registry,
        policyStore: marker,
        now: () => now,
      );
      final pause = OperationRequest(
        operationId: operation.id,
        desiredValue: 1,
        parameters: <String, Object?>{
          'expiresAt': now.add(const Duration(days: 7)).toIso8601String(),
        },
      );

      final snapshot = await operation.captureSnapshot(pause);
      await operation.apply(pause);

      expect(_dword(registry.value), 1);
      expect(
        (await marker.read())!.expiresAt,
        now.add(const Duration(days: 7)),
      );
      expect(
        (await operation.verify(pause)).kind,
        OperationStateKind.configured,
      );

      const resume = OperationRequest(
        operationId: 'toggle_automatic_driver_updates_off',
        desiredValue: null,
      );
      expect(
        (await operation.supports(
          const OperationContext(windowsBuild: 26100, edition: 'Pro'),
          resume,
        )).supported,
        isTrue,
      );
      await operation.apply(resume);

      expect(registry.value, isNull);
      expect(await marker.read(), isNull);

      await operation.rollback(pause, snapshot);
      expect(registry.value, isNull);
    },
  );

  test('pause rejects expiration beyond the bounded window', () async {
    final directory = await Directory.systemTemp.createTemp(
      'zap-driver-policy-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final now = DateTime.utc(2026, 1, 1);
    final operation = DriverUpdatePolicyOperation(
      registry: _Registry(),
      policyStore: DriverUpdatePolicyStore(
        path: p.join(directory.path, 'policy.json'),
      ),
      now: () => now,
    );
    final support = await operation.supports(
      const OperationContext(windowsBuild: 26100, edition: 'Pro'),
      OperationRequest(
        operationId: operation.id,
        desiredValue: 1,
        parameters: <String, Object?>{
          'expiresAt': now.add(const Duration(days: 32)).toIso8601String(),
        },
      ),
    );

    expect(support.supported, isFalse);
  });
}
