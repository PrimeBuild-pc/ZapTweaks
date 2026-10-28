import 'dart:typed_data';

import '../../platform/windows/registry_value_store.dart';
import 'operation.dart';
import 'registry_dword_operation.dart';

/// Attribution only: no upstream payload is downloaded or executed.
const sparkleSourceUrl = 'https://github.com/thedogecraft/sparkle';

const sparkleManualServices = <String>{
  'DiagTrack',
  'dmwappushservice',
  'WerSvc',
  'PcaSvc',
  'XblAuthManager',
  'XblGameSave',
  'XboxNetApiSvc',
  'RemoteRegistry',
  'MapsBroker',
  'WMPNetworkSvc',
};

/// Separate registration list: the host owns catalog and helper integration.
List<OperationDefinition> createSparkleManualOperations(
  RegistryValueStore store,
) => <OperationDefinition>[
  SparkleRegistryStringOperation(
    id: 'sparkle.clock.short_time',
    titleKey: 'sparkleClock',
    descriptionKey: 'sparkleManualSafeNotice',
    path: r'HKCU\Control Panel\International',
    valueName: 'sShortTime',
    fixedValue: 'HH:mm',
    store: store,
  ),
  SparkleRegistryStringOperation(
    id: 'sparkle.clock.time_format',
    titleKey: 'sparkleClock',
    descriptionKey: 'sparkleManualSafeNotice',
    path: r'HKCU\Control Panel\International',
    valueName: 'sTimeFormat',
    fixedValue: 'HH:mm:ss',
    store: store,
  ),
  SparkleRegistryStringOperation(
    id: 'sparkle.shell.menu_delay',
    titleKey: 'sparkleMenuDelay',
    descriptionKey: 'sparkleManualSafeNotice',
    path: r'HKCU\Control Panel\Desktop',
    valueName: 'MenuShowDelay',
    store: store,
  ),
  SparkleFixedDwordOperation(
    id: 'sparkle.shell.seconds',
    titleKey: 'sparkleSeconds',
    descriptionKey: 'sparkleManualSafeNotice',
    path: r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
    valueName: 'ShowSecondsInSystemClock',
    fixedValue: 1,
    store: store,
  ),
  SparkleFixedDwordOperation(
    id: 'sparkle.privacy.overlay',
    titleKey: 'sparkleLockScreen',
    descriptionKey: 'sparkleManualSafeNotice',
    path:
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager',
    valueName: 'RotatingLockScreenOverlayEnabled',
    fixedValue: 0,
    store: store,
  ),
  SparkleFixedDwordOperation(
    id: 'sparkle.privacy.lock_screen',
    titleKey: 'sparkleLockScreen',
    descriptionKey: 'sparkleManualSafeNotice',
    path:
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager',
    valueName: 'SubscribedContent-338387Enabled',
    fixedValue: 0,
    store: store,
  ),
  SparkleFixedDwordOperation(
    id: 'sparkle.shell.hide_search',
    titleKey: 'sparkleSearch',
    descriptionKey: 'sparkleManualSafeNotice',
    path: r'HKCU\Software\Microsoft\Windows\CurrentVersion\Search',
    valueName: 'SearchboxTaskbarMode',
    fixedValue: 0,
    store: store,
  ),
  SparkleHvciConfiguredOperation(store),
  SparkleFixedDwordOperation(
    id: 'sparkle.security.rdp_warning_version',
    titleKey: 'sparkleRdp',
    descriptionKey: 'sparkleRdpWarning',
    path:
        r'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client',
    valueName: 'RedirectionWarningDialogVersion',
    fixedValue: 1,
    expert: true,
    store: store,
    restartImpact: RestartImpact.process,
  ),
];

class SparkleFixedDwordOperation extends RegistryDwordOperation {
  SparkleFixedDwordOperation({
    required super.id,
    required super.path,
    required super.valueName,
    required super.store,
    required this.fixedValue,
    required super.titleKey,
    required super.descriptionKey,
    bool expert = false,
    super.restartImpact = RestartImpact.signOut,
  }) : super(
         destination: expert ? 'Expert' : 'Windows',
         privilege: expert
             ? OperationPrivilege.administrator
             : OperationPrivilege.user,
         scope: expert ? OperationScope.machine : OperationScope.user,
         risk: expert ? OperationRisk.high : OperationRisk.low,
         technicalSources: const <String>[
           sparkleSourceUrl,
           'https://learn.microsoft.com/windows/win32/sysinfo/registry-functions',
         ],
       );

  final int fixedValue;

  void _validate(OperationRequest request) {
    if (request.desiredValue is! int ||
        request.desiredValue != fixedValue ||
        request.target != null ||
        request.parameters.isNotEmpty) {
      throw ArgumentError('Only this fixed Registry DWORD setting is allowed.');
    }
  }

  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.inferred;

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      _validate(request);
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
    return super.supports(context, request);
  }

  @override
  Future<void> apply(OperationRequest request) async {
    _validate(request);
    await super.apply(request);
  }
}

/// Only the configured Enabled value; never VBS, Secure Boot or UEFI locks.
class SparkleHvciConfiguredOperation extends SparkleFixedDwordOperation {
  SparkleHvciConfiguredOperation(RegistryValueStore store)
    : super(
        id: 'sparkle.security.hvci_configured_off',
        titleKey: 'sparkleHvci',
        descriptionKey: 'sparkleHvciWarning',
        path:
            r'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity',
        valueName: 'Enabled',
        fixedValue: 0,
        expert: true,
        restartImpact: RestartImpact.reboot,
        store: store,
      );

  Future<void> _requireUnmanagedUnlocked() async {
    final policy = await store.read(
      r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard',
      'HypervisorEnforcedCodeIntegrity',
      view: view,
    );
    final locked = await store.read(path, 'Locked', view: view);
    if (policy != null ||
        (locked != null &&
            (locked.type != RegistryDwordOperation.regDword ||
                locked.bytes.length != 4 ||
                ByteData.sublistView(
                      locked.bytes,
                    ).getUint32(0, Endian.little) !=
                    0))) {
      throw StateError(
        'Managed or UEFI-locked HVCI is unavailable; no bypass.',
      );
    }
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    final support = await super.supports(context, request);
    if (!support.supported) return support;
    try {
      await _requireUnmanagedUnlocked();
      return support;
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<void> apply(OperationRequest request) async {
    await _requireUnmanagedUnlocked();
    await super.apply(request);
  }

  @override
  Future<OperationState> verify(OperationRequest request) async {
    final state = await inspect(request);
    return OperationState(
      state.kind,
      value: state.value,
      message:
          'Configured HVCI value only. Reboot required; effective HVCI/VBS '
          'and Secure Boot status are not changed or verified here.',
    );
  }
}

/// A fixed REG_SZ target. The only editable value is canonical 0–4000 ms.
class SparkleRegistryStringOperation extends RegistryDwordOperation {
  SparkleRegistryStringOperation({
    required super.id,
    required super.path,
    required super.valueName,
    required super.store,
    this.fixedValue,
    required super.titleKey,
    required super.descriptionKey,
  }) : super(
         destination: 'Windows',
         privilege: OperationPrivilege.user,
         scope: OperationScope.user,
         restartImpact: RestartImpact.signOut,
         technicalSources: const <String>[
           sparkleSourceUrl,
           'https://learn.microsoft.com/windows/win32/sysinfo/registry-value-types',
         ],
       );

  static const regSz = 1;
  final String? fixedValue;

  String _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value is! String ||
        request.target != null ||
        request.parameters.isNotEmpty ||
        (fixedValue != null && value != fixedValue) ||
        (fixedValue == null &&
            (!RegExp(r'^(0|[1-9][0-9]{0,3})$').hasMatch(value) ||
                int.parse(value) > 4000))) {
      throw ArgumentError(
        'Expected the fixed time format or 0–4000 ms REG_SZ.',
      );
    }
    return value;
  }

  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.inferred;

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.architecture != 'x64' || context.windowsBuild < 22000) {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      _desired(request);
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  OperationState _state(RawRegistryValue? raw) {
    if (raw == null) return const OperationState(OperationStateKind.absent);
    final bytes = raw.bytes;
    if (raw.type == regSz && bytes.length >= 2 && bytes.length.isEven) {
      final data = ByteData.sublistView(bytes);
      final units = <int>[
        for (var i = 0; i < bytes.length; i += 2)
          data.getUint16(i, Endian.little),
      ];
      if (units.last == 0 && !units.take(units.length - 1).contains(0)) {
        return OperationState(
          OperationStateKind.configured,
          value: String.fromCharCodes(units.take(units.length - 1)),
        );
      }
    }
    return OperationState(
      OperationStateKind.mixed,
      value: <String, Object?>{'type': raw.type, 'bytes': raw.bytes},
      message: 'Unexpected Registry type or malformed REG_SZ.',
    );
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async =>
      _state(await store.read(path, valueName, view: view));

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    _desired(request);
    final raw = await store.read(path, valueName, view: view);
    return OperationSnapshot(
      type: 'registryValue',
      data: <String, Object?>{
        'path': path,
        'name': valueName,
        'view': view.name,
        'existed': raw != null,
        if (raw != null) 'registryType': raw.type,
        if (raw != null) 'bytes': Uint8List.fromList(raw.bytes),
      },
      expectedAfterRollback: _state(raw),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    final units = <int>[..._desired(request).codeUnits, 0];
    final bytes = Uint8List(units.length * 2);
    final data = ByteData.sublistView(bytes);
    for (var i = 0; i < units.length; i++) {
      data.setUint16(i * 2, units[i], Endian.little);
    }
    await store.write(
      path,
      valueName,
      RawRegistryValue(type: regSz, bytes: bytes),
      view: view,
    );
  }
}
