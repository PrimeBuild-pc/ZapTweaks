import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/win32_uninstall_operation.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

const _uninstall = r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';

RawRegistryValue _sz(String text) => RawRegistryValue(
  type: 1,
  bytes: Uint8List.fromList(<int>[
    for (final unit in '$text\u0000'.codeUnits) ...<int>[
      unit & 0xff,
      unit >> 8,
    ],
  ]),
);

RawRegistryValue _dword(int value) => RawRegistryValue(
  type: 4,
  bytes: Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.little),
);

class _Store implements RegistryValueStore {
  final values = <String, RawRegistryValue>{};
  final views = <String>[];

  void put(String path, String name, RawRegistryValue value) =>
      values['$path|$name'] = value;

  void removeKey(String path) =>
      values.removeWhere((key, _) => key.startsWith('$path|'));

  @override
  Future<RawRegistryValue?> read(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) async {
    views.add(view.name);
    return values['$path|$name'];
  }

  @override
  Future<void> write(
    String path,
    String name,
    RawRegistryValue value, {
    RegistryView view = RegistryView.registry64,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(
    String path,
    String name, {
    RegistryView view = RegistryView.registry64,
  }) => throw UnimplementedError();
}

void main() {
  late _Store store;
  late List<List<String>> launched;

  Win32UninstallOperation operation({
    bool machine = true,
    void Function()? onLaunch,
  }) => Win32UninstallOperation(
    machine: machine,
    store: store,
    environment: const {'SystemRoot': r'C:\Windows'},
    fileExists: (_) => true,
    pollInterval: Duration.zero,
    launch: (executable, arguments) async {
      launched.add(<String>[executable, ...arguments]);
      onLaunch?.call();
      return 0;
    },
  );

  OperationRequest request(String target, {bool silent = true}) =>
      OperationRequest(
        operationId: 'app.win32.uninstall',
        target: target,
        desiredValue: false,
        parameters: <String, Object?>{'silent': silent},
      );

  setUp(() {
    store = _Store();
    launched = <List<String>>[];
    store.put('$_uninstall\\Git_is1', 'DisplayName', _sz('Git'));
    store.put(
      '$_uninstall\\Git_is1',
      'UninstallString',
      _sz(r'"C:\Program Files\Git\unins000.exe"'),
    );
  });

  test(
    're-reads the key, runs the planned command and verifies removal',
    () async {
      final op = operation(
        onLaunch: () => store.removeKey('$_uninstall\\Git_is1'),
      );
      final target = r'HKLM\64\Git_is1';

      expect((await op.inspect(request(target))).value, isTrue);
      await op.apply(request(target));

      expect(launched.single, [
        r'C:\Program Files\Git\unins000.exe',
        '/VERYSILENT',
        '/SUPPRESSMSGBOXES',
        '/NORESTART',
      ]);
      expect((await op.verify(request(target))).value, isFalse);
    },
  );

  test('32-bit entries are read through the 32-bit registry view', () async {
    store.put('$_uninstall\\Old', 'DisplayName', _sz('Old'));
    await operation().inspect(request(r'HKLM\32\Old'));
    expect(store.views.last, RegistryView.registry32.name);
  });

  test(
    'MSI product code from the key name builds msiexec, not the string',
    () async {
      final key = '{26A24AE4-039D-4CA4-87B4-2F64180101F0}';
      store.put('$_uninstall\\$key', 'DisplayName', _sz('Java'));
      store.put('$_uninstall\\$key', 'WindowsInstaller', _dword(1));
      store.put('$_uninstall\\$key', 'UninstallString', _sz('cmd /c evil.exe'));
      final op = operation(
        onLaunch: () => store.removeKey('$_uninstall\\$key'),
      );

      await op.apply(request('HKLM\\64\\$key'));

      expect(launched.single.first, r'C:\Windows\System32\msiexec.exe');
      expect(launched.single.skip(1), ['/x', key, '/qn', '/norestart']);
    },
  );

  test('an unsafe command is never launched', () async {
    store.put('$_uninstall\\Bad', 'DisplayName', _sz('Bad'));
    store.put('$_uninstall\\Bad', 'UninstallString', _sz('cmd /c del C:\\x'));

    await expectLater(
      operation().apply(request(r'HKLM\64\Bad')),
      throwsA(isA<StateError>()),
    );
    expect(launched, isEmpty);
  });

  test(
    'a program still registered after the uninstaller exits fails',
    () async {
      final op = Win32UninstallOperation(
        machine: true,
        store: store,
        environment: const {'SystemRoot': r'C:\Windows'},
        fileExists: (_) => true,
        pollInterval: Duration.zero,
        waitLimit: Duration.zero,
        launch: (_, _) async => 0,
      );
      await expectLater(
        op.apply(request(r'HKLM\64\Git_is1')),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('a failed or cancelled uninstaller stops waiting right away', () async {
    final op = Win32UninstallOperation(
      machine: true,
      store: store,
      environment: const {'SystemRoot': r'C:\Windows'},
      fileExists: (_) => true,
      pollInterval: const Duration(milliseconds: 10),
      waitLimit: const Duration(minutes: 30),
      failureGrace: Duration.zero,
      launch: (_, _) async => 1602,
    );
    final watch = Stopwatch()..start();
    await expectLater(
      op.apply(request(r'HKLM\64\Git_is1')),
      throwsA(
        isA<StateError>().having((e) => e.message, 'message', contains('1602')),
      ),
    );
    expect(watch.elapsed, lessThan(const Duration(seconds: 5)));
  });

  test('HKCU entries never run through the elevated operation', () async {
    expect(
      (await operation().supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        request(r'HKCU\64\Mine'),
      )).supported,
      isFalse,
    );
    expect(
      (await operation(machine: false).supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        request(r'HKLM\64\Git_is1'),
      )).supported,
      isFalse,
    );
    expect(operation(machine: false).privilege, OperationPrivilege.user);
    expect(operation().privilege, OperationPrivilege.administrator);
  });

  test('protected, hidden and update entries are refused', () async {
    for (final (name, flag) in [
      ('NoRemove', 'NoRemove'),
      ('Hidden', 'SystemComponent'),
    ]) {
      store.put('$_uninstall\\$name', 'DisplayName', _sz(name));
      store.put('$_uninstall\\$name', 'UninstallString', _sz(r'C:\x\u.exe'));
      store.put('$_uninstall\\$name', flag, _dword(1));
      await expectLater(
        operation().apply(request('HKLM\\64\\$name')),
        throwsA(isA<StateError>()),
        reason: name,
      );
    }
    store.put('$_uninstall\\KB', 'DisplayName', _sz('KB'));
    store.put('$_uninstall\\KB', 'ParentKeyName', _sz('Office'));
    await expectLater(
      operation().apply(request(r'HKLM\64\KB')),
      throwsA(isA<StateError>()),
    );
    expect(launched, isEmpty);
  });

  test('malformed targets are rejected', () async {
    for (final target in [
      r'HKLM\64\a\b',
      r'HKLM\16\x',
      r'HKLM\64\',
      'HKLM\\64\\${'x' * 300}',
      'nonsense',
    ]) {
      expect(
        (await operation().supports(
          const OperationContext(windowsBuild: 26100, edition: 'Pro'),
          request(target),
        )).supported,
        isFalse,
        reason: target,
      );
    }
    expect(
      jsonEncode(request(r'HKLM\64\Git_is1').parameters),
      '{"silent":true}',
    );
  });
}
