import 'dart:typed_data';

import '../../platform/windows/registry_value_store.dart';
import 'operation.dart';

class RegistryDwordOperation extends OperationDefinition {
  RegistryDwordOperation({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.destination,
    required this.path,
    required this.valueName,
    required this.store,
    required this.privilege,
    this.scope = OperationScope.machine,
    this.view = RegistryView.registry64,
    this.risk = OperationRisk.low,
    this.restartImpact = RestartImpact.none,
    this.legacyAliases = const <String>[],
    this.dependencies = const <String>[],
    this.conflicts = const <String>[],
    this.benefitEvidence = EvidenceLevel.unverified,
    this.minimumWindowsBuild = 22000,
    this.technicalSources = const <String>[
      'https://learn.microsoft.com/windows/win32/sysinfo/registry-functions',
    ],
  });

  static const int regDword = 4;

  @override
  final String id;
  @override
  final String titleKey;
  @override
  final String descriptionKey;
  @override
  final String destination;
  final String path;
  final String valueName;
  final RegistryValueStore store;
  final RegistryView view;
  final int minimumWindowsBuild;
  @override
  final OperationPrivilege privilege;
  @override
  final OperationScope scope;
  @override
  final OperationRisk risk;
  @override
  final RestartImpact restartImpact;
  @override
  final List<String> legacyAliases;
  @override
  final List<String> dependencies;
  @override
  final List<String> conflicts;
  @override
  final EvidenceLevel benefitEvidence;
  @override
  final List<String> technicalSources;

  @override
  int get version => 1;
  @override
  String get domain => 'registry';
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    final desired = request.desiredValue;
    if (context.architecture != 'x64' ||
        context.windowsBuild < minimumWindowsBuild) {
      return SupportResult.unsupported(
        'Windows 11 x64 build $minimumWindowsBuild or newer is required.',
      );
    }
    if (desired != null &&
        (desired is! int || desired < 0 || desired > 0xffffffff)) {
      return const SupportResult.unsupported(
        'The requested Registry DWORD is invalid.',
      );
    }
    return const SupportResult.supported();
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async =>
      _stateFromRaw(await store.read(path, valueName, view: view));

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final raw = await store.read(path, valueName, view: view);
    final before = _stateFromRaw(raw);
    return OperationSnapshot(
      type: 'registryValue',
      data: <String, Object?>{
        'path': path,
        'name': valueName,
        'view': view.name,
        'existed': raw != null,
        if (raw != null) 'registryType': raw.type,
        if (raw != null) 'bytes': raw.bytes,
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) => request.desiredValue == null
      ? store.delete(path, valueName, view: view)
      : store.write(
          path,
          valueName,
          RawRegistryValue(
            type: regDword,
            bytes: _encodeDword(request.desiredValue! as int),
          ),
          view: view,
        );

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final data = snapshot.data;
    if (snapshot.type != 'registryValue' ||
        data['path'] != path ||
        data['name'] != valueName ||
        data['view'] != view.name) {
      throw StateError('Registry snapshot target mismatch.');
    }
    if (data['existed'] != true) {
      await store.delete(path, valueName, view: view);
      return;
    }
    final bytes = data['bytes'];
    final type = data['registryType'];
    if (bytes is! Uint8List || type is! int) {
      throw StateError('Registry snapshot data is invalid.');
    }
    await store.write(
      path,
      valueName,
      RawRegistryValue(type: type, bytes: bytes),
      view: view,
    );
  }

  static OperationState _stateFromRaw(RawRegistryValue? value) {
    if (value == null) return const OperationState(OperationStateKind.absent);
    if (value.type != regDword || value.bytes.length != 4) {
      return OperationState(
        OperationStateKind.mixed,
        value: <String, Object?>{'type': value.type, 'bytes': value.bytes},
        message: 'The Registry value has an unexpected type or size.',
      );
    }
    return OperationState(
      OperationStateKind.configured,
      value: ByteData.sublistView(value.bytes).getUint32(0, Endian.little),
    );
  }

  static Uint8List _encodeDword(int value) {
    final bytes = Uint8List(4);
    ByteData.sublistView(bytes).setUint32(0, value, Endian.little);
    return bytes;
  }
}
