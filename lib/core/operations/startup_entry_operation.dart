import 'dart:convert';
import 'dart:typed_data';

import '../../platform/windows/registry_value_store.dart';
import 'operation.dart';

/// Turns a Run-key startup entry on or off the way Task Manager does: a
/// REG_BINARY flag under Explorer\StartupApproved, never touching the Run
/// value itself. Rollback restores the exact previous flag (or its absence).
class StartupEntryOperation implements OperationDefinition {
  StartupEntryOperation.user(this.store) : machine = false;
  StartupEntryOperation.machine(this.store) : machine = true;

  final RegistryValueStore store;
  final bool machine;

  static const _regBinary = 3;
  static const _cv = r'SOFTWARE\Microsoft\Windows\CurrentVersion';

  String get _root => machine ? 'HKLM' : 'HKCU';

  ({String run, RegistryView view, String approved}) _location(
    OperationRequest request,
  ) {
    if (request.operationId != id) throw StateError('Wrong operation.');
    final name = request.target;
    if (name == null ||
        name.isEmpty ||
        name.length > 256 ||
        name.contains(r'\') ||
        name.contains('\u0000')) {
      throw StateError('Invalid startup entry name.');
    }
    final location = request.parameters['location'];
    final approved = '$_root\\$_cv\\Explorer\\StartupApproved';
    return switch (location) {
      'run' => (
        run: '$_root\\$_cv\\Run',
        view: RegistryView.registry64,
        approved: '$approved\\Run',
      ),
      'run32' when machine => (
        run: '$_root\\$_cv\\Run',
        view: RegistryView.registry32,
        approved: '$approved\\Run32',
      ),
      _ => throw StateError('Invalid startup location.'),
    };
  }

  bool _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value is! bool) throw StateError('Startup state must be true/false.');
    return value;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000) {
      return const SupportResult.unsupported('Requires Windows 11.');
    }
    try {
      _desired(request);
      final location = _location(request);
      final entry = await store.read(
        location.run,
        request.target!,
        view: location.view,
      );
      if (entry == null) {
        return const SupportResult.unsupported('Startup entry not found.');
      }
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final location = _location(request);
      final flag = await store.read(location.approved, request.target!);
      if (flag == null) {
        return const OperationState(OperationStateKind.configured, value: true);
      }
      if (flag.type != _regBinary || flag.bytes.isEmpty) {
        return const OperationState(
          OperationStateKind.error,
          message: 'Unexpected StartupApproved value.',
        );
      }
      // Odd first byte (03, 07) = turned off by the user.
      return OperationState(
        OperationStateKind.configured,
        value: flag.bytes.first & 1 == 0,
      );
    } catch (error) {
      return OperationState(OperationStateKind.error, message: '$error');
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    _desired(request);
    final location = _location(request);
    final before = await inspect(request);
    if (before.kind != OperationStateKind.configured) {
      throw StateError(before.message ?? 'Startup entry inspection failed.');
    }
    final flag = await store.read(location.approved, request.target!);
    return OperationSnapshot(
      type: 'startupEntry',
      data: <String, Object?>{
        'name': request.target,
        'location': request.parameters['location'],
        'flag': flag == null
            ? null
            : <String, Object?>{
                'type': flag.type,
                'bytes': base64Encode(flag.bytes),
              },
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final enabled = _desired(request);
    final location = _location(request);
    final bytes = Uint8List(12)..[0] = enabled ? 2 : 3;
    if (!enabled) {
      // FILETIME of when it was turned off, as Task Manager records it.
      final ticks =
          (DateTime.now().toUtc().millisecondsSinceEpoch + 11644473600000) *
          10000;
      bytes.buffer.asByteData().setUint64(4, ticks, Endian.little);
    }
    await store.write(
      location.approved,
      request.target!,
      RawRegistryValue(type: _regBinary, bytes: bytes),
    );
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final location = _location(request);
    if (snapshot.type != 'startupEntry' ||
        snapshot.data['name'] != request.target ||
        snapshot.data['location'] != request.parameters['location']) {
      throw StateError('Invalid startup snapshot.');
    }
    final flag = snapshot.data['flag'];
    if (flag == null) {
      await store.delete(location.approved, request.target!);
      return;
    }
    if (flag is! Map ||
        flag['type'] != _regBinary ||
        flag['bytes'] is! String) {
      throw StateError('Invalid startup snapshot.');
    }
    await store.write(
      location.approved,
      request.target!,
      RawRegistryValue(
        type: _regBinary,
        bytes: base64Decode(flag['bytes'] as String),
      ),
    );
  }

  @override
  String get id =>
      machine ? 'startup.entry.configure' : 'startup.entry.configure_user';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'startupEntryTitle';
  @override
  String get descriptionKey => 'startupEntryDescription';
  @override
  String get domain => 'startup';
  @override
  String get destination => 'Apps';
  @override
  OperationScope get scope =>
      machine ? OperationScope.machine : OperationScope.user;
  @override
  OperationRisk get risk => OperationRisk.low;
  @override
  OperationPrivilege get privilege =>
      machine ? OperationPrivilege.administrator : OperationPrivilege.user;
  @override
  RestartImpact get restartImpact => RestartImpact.signOut;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.runtimeObserved;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.runtimeObserved;
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
    'https://learn.microsoft.com/windows/win32/setupapi/run-and-runonce-registry-keys',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
