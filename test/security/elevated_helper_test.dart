import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/models/restore_point_result.dart';
import 'package:script_utility/core/models/tweak_descriptor.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/operation_registry.dart';
import 'package:script_utility/core/operations/registry_dword_operation.dart';
import 'package:script_utility/core/security/elevated_helper.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/core/services/restore_point_service.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/core/tweak_manager.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

class _Catalog extends TweakCatalogService {
  @override
  List<TweakDescriptor> buildCatalog() => const <TweakDescriptor>[
    TweakDescriptor(
      id: 'sample_toggle',
      title: 'Sample',
      description: 'Sample',
      category: 'Windows',
      systemKey: 'sample_key',
    ),
  ];
}

class _Manager extends TweakManager {
  bool value = false;

  @override
  Future<TweakApplyResult> applyTweak(String key, bool enable) async {
    value = enable;
    return const TweakApplyResult(success: true, errors: <String>[]);
  }

  @override
  Future<bool> detectTweakState(String key) async => value;
}

class _Registry implements RegistryValueStore {
  RawRegistryValue? value;

  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => value = null;

  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => value;

  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue next, {
    RegistryView view = RegistryView.registry64,
  }) async => value = next;
}

class _Restore extends RestorePointService {
  _Restore() : super(processRunner: ProcessRunner());

  int calls = 0;

  @override
  Future<RestorePointResult> createRestorePoint({
    required String description,
  }) async {
    calls++;
    return const RestorePointResult(success: true);
  }
}

void main() {
  test(
    'one helper launch applies only a catalogued system operation',
    () async {
      final directory = await Directory.systemTemp.createTemp('zap-helper-');
      addTearDown(() => directory.delete(recursive: true));
      final manager = _Manager();
      final restore = _Restore();
      final host = ElevatedHelperHost(
        allowedDirectory: directory,
        catalogService: _Catalog(),
        tweakManager: manager,
        restorePointService: restore,
      );
      var launches = 0;
      final client = ElevatedHelperClient(
        directory: directory,
        launcher: (_, request, nonce, digest) async {
          launches++;
          return host.run(request, nonce, digest);
        },
      );

      final result = await client.applySystemTweak(
        operationId: 'sample_toggle',
        desiredValue: true,
        createRestorePoint: true,
      );

      expect(result.success, isTrue);
      expect(result.observed, isTrue);
      expect(manager.value, isTrue);
      expect(restore.calls, 1);
      expect(launches, 1);
      expect(directory.listSync(), isEmpty);
    },
  );

  test(
    'native administrator operation applies and rolls back through one helper',
    () async {
      final directory = await Directory.systemTemp.createTemp('zap-helper-');
      addTearDown(() => directory.delete(recursive: true));
      final values = _Registry();
      final operation = RegistryDwordOperation(
        id: 'registry.admin.set',
        titleKey: 'title',
        descriptionKey: 'description',
        destination: 'Windows',
        path: r'HKLM\Software\ZapTweaksTest',
        valueName: 'Value',
        store: values,
        privilege: OperationPrivilege.administrator,
      );
      final host = ElevatedHelperHost(
        allowedDirectory: directory,
        catalogService: _Catalog(),
        tweakManager: _Manager(),
        restorePointService: _Restore(),
        operationRegistry: OperationRegistry(<OperationDefinition>[operation]),
        operationContext: const OperationContext(
          windowsBuild: 26100,
          edition: 'Pro',
        ),
      );
      final client = ElevatedHelperClient(
        directory: directory,
        secureDirectory: (_) async {},
        launcher: (_, request, nonce, digest) =>
            host.run(request, nonce, digest),
      );
      const request = OperationRequest(
        operationId: 'registry.admin.set',
        desiredValue: 1,
      );
      final snapshot = await operation.captureSnapshot(request);
      final progress = <String>[];
      final subscription = client.progress.listen(
        (event) => progress.add(event.state),
      );
      addTearDown(subscription.cancel);

      await client.applyNativeOperation(request);
      expect(progress, containsAllInOrder(<String>['applying', 'completed']));
      expect((await operation.inspect(request)).value, 1);
      await client.rollbackNativeOperation(request, snapshot);
      expect(
        (await operation.inspect(request)).kind,
        OperationStateKind.absent,
      );
    },
  );

  test('helper refuses request files outside its private directory', () async {
    final directory = await Directory.systemTemp.createTemp('zap-helper-');
    final outside = await Directory.systemTemp.createTemp('zap-outside-');
    addTearDown(() => directory.delete(recursive: true));
    addTearDown(() => outside.delete(recursive: true));
    const nonce =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    final request = File('${outside.path}${Platform.pathSeparator}$nonce.json');
    await request.writeAsString('{}');
    final host = ElevatedHelperHost(
      allowedDirectory: directory,
      catalogService: _Catalog(),
      tweakManager: _Manager(),
      restorePointService: _Restore(),
    );

    expect(await host.run(request, nonce, 'invalid'), 2);
    expect(await File('${request.path}.response').exists(), isFalse);
  });

  test('helper rejects a request changed after approval', () async {
    final directory = await Directory.systemTemp.createTemp('zap-helper-');
    addTearDown(() => directory.delete(recursive: true));
    final manager = _Manager();
    final host = ElevatedHelperHost(
      allowedDirectory: directory,
      catalogService: _Catalog(),
      tweakManager: manager,
      restorePointService: _Restore(),
    );
    final client = ElevatedHelperClient(
      directory: directory,
      launcher: (_, request, nonce, digest) async {
        await request.writeAsString('{}');
        return host.run(request, nonce, digest);
      },
    );

    final result = await client.applySystemTweak(
      operationId: 'sample_toggle',
      desiredValue: true,
      createRestorePoint: false,
    );

    expect(result.success, isFalse);
    expect(manager.value, isFalse);
  });

  test('helper rejects IDs that are not fixed in the local catalog', () async {
    final directory = await Directory.systemTemp.createTemp('zap-helper-');
    addTearDown(() => directory.delete(recursive: true));
    final host = ElevatedHelperHost(
      allowedDirectory: directory,
      catalogService: _Catalog(),
      tweakManager: _Manager(),
      restorePointService: _Restore(),
    );
    final client = ElevatedHelperClient(
      directory: directory,
      launcher: (_, request, nonce, digest) => host.run(request, nonce, digest),
    );

    final result = await client.applySystemTweak(
      operationId: 'not_allowlisted',
      desiredValue: true,
      createRestorePoint: false,
    );

    expect(result.success, isFalse);
    expect(result.message, contains('allowlisted'));
  });
}
