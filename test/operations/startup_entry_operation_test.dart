import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/startup_entry_operation.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

class _Registry implements RegistryValueStore {
  final values = <String, RawRegistryValue>{};

  String _key(String path, String name, RegistryView view) =>
      '${view.name}|${path.toLowerCase()}|$name';

  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => values[_key(path, name, view)];

  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  }) async => values[_key(path, name, view)] = value;

  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async => values.remove(_key(path, name, view));
}

const _run = r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run';
const _approved =
    r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run';
const _context = OperationContext(windowsBuild: 26100, edition: 'Pro');

OperationRequest _request(String name, bool enabled) => OperationRequest(
  operationId: 'startup.entry.configure_user',
  target: name,
  desiredValue: enabled,
  parameters: const <String, Object?>{'location': 'run'},
);

void main() {
  test(
    'disables like Task Manager and restores the exact previous bytes',
    () async {
      final registry = _Registry();
      await registry.write(
        _run,
        'Spotify',
        RawRegistryValue(type: 1, bytes: Uint8List.fromList([0x61, 0])),
      );
      final operation = StartupEntryOperation.user(registry);
      final request = _request('Spotify', false);

      expect((await operation.supports(_context, request)).supported, isTrue);
      expect((await operation.inspect(request)).value, isTrue);
      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      final written = await registry.read(_approved, 'Spotify');
      expect(written!.type, 3, reason: 'REG_BINARY');
      expect(written.bytes.length, 12);
      expect(written.bytes.first, 3, reason: 'disabled flag');
      expect((await operation.verify(request)).value, isFalse);

      await operation.rollback(request, snapshot);
      expect(await registry.read(_approved, 'Spotify'), isNull);
      expect((await operation.inspect(request)).value, isTrue);
    },
  );

  test('re-enabling writes the enabled flag', () async {
    final registry = _Registry();
    await registry.write(
      _run,
      'Discord',
      RawRegistryValue(type: 1, bytes: Uint8List.fromList([0x61, 0])),
    );
    await registry.write(
      _approved,
      'Discord',
      RawRegistryValue(
        type: 3,
        bytes: Uint8List.fromList([3, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8]),
      ),
    );
    final operation = StartupEntryOperation.user(registry);
    expect((await operation.inspect(_request('Discord', true))).value, isFalse);
    await operation.apply(_request('Discord', true));
    expect((await registry.read(_approved, 'Discord'))!.bytes.first, 2);
  });

  test('missing entries, bad names and bad locations are refused', () async {
    final operation = StartupEntryOperation.user(_Registry());
    for (final request in <OperationRequest>[
      _request('Missing', false),
      _request(r'..\x', false),
      _request('', false),
      const OperationRequest(
        operationId: 'startup.entry.configure_user',
        target: 'Spotify',
        desiredValue: false,
        parameters: <String, Object?>{'location': 'run32'},
      ),
      const OperationRequest(
        operationId: 'startup.entry.configure_user',
        target: 'Spotify',
        desiredValue: 'no',
        parameters: <String, Object?>{'location': 'run'},
      ),
    ]) {
      expect(
        (await operation.supports(_context, request)).supported,
        isFalse,
        reason: '${request.target} ${request.parameters}',
      );
    }
  });

  test('machine variant reads Run32 through the 32-bit view', () async {
    final registry = _Registry();
    await registry.write(
      r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
      'Updater',
      RawRegistryValue(type: 1, bytes: Uint8List.fromList([0x61, 0])),
      view: RegistryView.registry32,
    );
    final operation = StartupEntryOperation.machine(registry);
    const request = OperationRequest(
      operationId: 'startup.entry.configure',
      target: 'Updater',
      desiredValue: false,
      parameters: <String, Object?>{'location': 'run32'},
    );
    expect(operation.privilege, OperationPrivilege.administrator);
    expect((await operation.supports(_context, request)).supported, isTrue);
    await operation.apply(request);
    expect(
      (await registry.read(
        r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32',
        'Updater',
      ))!.bytes.first,
      3,
    );
  });
}
