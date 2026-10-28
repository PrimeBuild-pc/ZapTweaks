import 'dart:io';
import 'dart:typed_data';

import '../../features/apps/application/uninstall_command.dart';
import '../../features/apps/domain/app_package.dart';
import '../../platform/windows/registry_value_store.dart';
import 'operation.dart';

typedef UninstallLauncher =
    Future<int> Function(String executable, List<String> arguments);

/// Uninstalls one Win32/MSI program from its Uninstall key.
///
/// The key is re-read here (in the elevated helper for HKLM) instead of
/// trusting strings from the UI, turned into an exact command by
/// [planUninstall], and launched without a shell. HKLM entries run as
/// administrator; HKCU entries only through the user operation, so a value a
/// standard user can write never runs elevated. There is no automatic undo.
class Win32UninstallOperation implements OperationDefinition {
  Win32UninstallOperation({
    required this.machine,
    RegistryValueStore store = const WindowsRegistryValueStore(),
    UninstallLauncher? launch,
    Map<String, String>? environment,
    bool Function(String path)? fileExists,
    this.pollInterval = const Duration(seconds: 2),
    this.waitLimit,
    this.failureGrace = const Duration(seconds: 20),
    this.dryRun = false,
  }) : _store = store,
       _launch = launch ?? _startAndWait,
       _environment = environment ?? Platform.environment,
       _fileExists = fileExists ?? ((path) => File(path).existsSync());

  final bool machine;
  final RegistryValueStore _store;
  final UninstallLauncher _launch;
  final Map<String, String> _environment;
  final bool Function(String path) _fileExists;
  final Duration pollInterval;

  /// How long the key may linger after the uninstaller exits (Inno and others
  /// hand off to a copy in %TEMP%). Default: 10 min silent, 30 min windowed.
  final Duration? waitLimit;

  /// After a non-success exit code (1602 cancelled, 1603 failed…) only this
  /// short grace is given for the key to vanish, instead of [waitLimit].
  final Duration failureGrace;
  final bool dryRun;

  static const _root = r'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall';
  static final _target = RegExp(
    r'^(HKLM|HKCU)\\(64|32)\\([^\\\x00-\x1f]{1,255})$',
  );

  ({String hive, RegistryView view, String key}) _parse(
    OperationRequest request,
  ) {
    final match = _target.firstMatch(request.target ?? '');
    if (match == null) throw StateError('Invalid Uninstall entry.');
    if ((match[1] == 'HKLM') != machine) {
      throw StateError(
        machine
            ? 'Per-user entries are uninstalled without elevation.'
            : 'Machine-wide entries need the administrator operation.',
      );
    }
    if (request.desiredValue != false ||
        request.parameters['silent'] is! bool?) {
      throw StateError('Invalid uninstall request.');
    }
    return (
      hive: match[1]!,
      view: match[2] == '32'
          ? RegistryView.registry32
          : RegistryView.registry64,
      key: match[3]!,
    );
  }

  /// Fresh read of the entry; null when the program is no longer registered.
  Future<UninstallEntry?> _read(OperationRequest request) async {
    final target = _parse(request);
    final path = '${target.hive}\\$_root\\${target.key}';
    Future<RawRegistryValue?> raw(String name) =>
        _store.read(path, name, view: target.view);
    Future<String?> text(String name) async {
      final value = await raw(name);
      if (value == null || (value.type != 1 && value.type != 2)) return null;
      final units = <int>[
        for (var i = 0; i + 1 < value.bytes.length; i += 2)
          value.bytes[i] | value.bytes[i + 1] << 8,
      ];
      final end = units.indexOf(0);
      final result = String.fromCharCodes(
        end < 0 ? units : units.sublist(0, end),
      ).trim();
      return result.isEmpty ? null : result;
    }

    Future<bool> flag(String name) async {
      final value = await raw(name);
      return value != null &&
          value.type == 4 &&
          value.bytes.length >= 4 &&
          value.bytes.buffer.asByteData().getUint32(0, Endian.little) == 1;
    }

    if (await text('DisplayName') == null) return null;
    final release = (await text('ReleaseType'))?.toLowerCase() ?? '';
    final guid = RegExp(
      r'^\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}$',
      caseSensitive: false,
    );
    return UninstallEntry(
      hive: target.hive,
      view: target.view == RegistryView.registry32 ? '32' : '64',
      key: target.key,
      uninstallString: await text('UninstallString'),
      quietUninstallString: await text('QuietUninstallString'),
      msiProductCode:
          await flag('WindowsInstaller') && guid.hasMatch(target.key)
          ? target.key.toUpperCase()
          : null,
      systemComponent: await flag('SystemComponent'),
      noRemove: await flag('NoRemove'),
      isUpdate:
          await text('ParentKeyName') != null ||
          release.contains('update') ||
          release.contains('hotfix'),
    );
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _parse(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async =>
      OperationState(
        OperationStateKind.configured,
        value: await _read(request) != null,
      );

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final before = await inspect(request);
    return OperationSnapshot(
      type: 'win32Uninstall',
      data: <String, Object?>{
        'target': request.target,
        'installed': before.value,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final entry = await _read(request);
    if (entry == null) return;
    if (entry.systemComponent || entry.noRemove || entry.isUpdate) {
      throw StateError(
        'Hidden, protected or update entries are not uninstalled here.',
      );
    }
    final plan = planUninstall(
      entry,
      environment: _environment,
      fileExists: _fileExists,
      preferSilent: request.parameters['silent'] != false,
    );
    final command = switch (plan) {
      UninstallCommand() => plan,
      UninstallManual(:final reason) => throw StateError(
        'Manual uninstall required (${reason.name}).',
      ),
    };
    if (dryRun) return;
    final exitCode = await _launch(command.executable, command.arguments);
    // 0 done, 3010/1641 done with a restart pending.
    final succeeded = const <int>{0, 3010, 1641}.contains(exitCode);
    final limit = !succeeded
        ? failureGrace
        : waitLimit ??
              (command.silent
                  ? const Duration(minutes: 10)
                  : const Duration(minutes: 30));
    final deadline = DateTime.now().add(limit);
    while (await _read(request) != null) {
      if (!DateTime.now().isBefore(deadline)) {
        throw StateError(
          'The uninstaller exited ($exitCode) but the program is still installed.',
        );
      }
      await Future<void>.delayed(pollInterval);
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(OperationRequest request, OperationSnapshot snapshot) =>
      throw UnsupportedError(
        'An uninstall cannot be undone automatically; reinstall the program.',
      );

  static Future<int> _startAndWait(
    String executable,
    List<String> arguments,
  ) async {
    final process = await Process.start(
      executable,
      arguments,
      runInShell: false,
      mode: ProcessStartMode.inheritStdio,
    );
    return process.exitCode;
  }

  @override
  String get id => machine ? 'app.win32.uninstall' : 'app.win32.uninstall_user';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'win32UninstallTitle';
  @override
  String get descriptionKey => 'win32UninstallDescription';
  @override
  String get domain => 'apps';
  @override
  String get destination => 'Apps';
  @override
  OperationScope get scope => OperationScope.app;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege =>
      machine ? OperationPrivilege.administrator : OperationPrivilege.user;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.none;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;
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
    'https://learn.microsoft.com/windows/win32/msi/uninstall-registry-key',
    'https://learn.microsoft.com/windows-server/administration/windows-commands/msiexec',
    'https://jrsoftware.org/ishelp/index.php?topic=uninstcmdline',
    'https://nsis.sourceforge.io/Docs/Chapter3.html#installerusageuninstaller',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
