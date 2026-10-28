import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../platform/windows/tcp_optimizer_service.dart';
import '../persistence/operation_store.dart';
import '../plans/operation_plan.dart';
import 'operation.dart';

class TcpPresetOption {
  const TcpPresetOption(
    this.target,
    this.value,
    this.reasonKey, {
    this.included = false,
  });
  final String target;
  final String value;
  final String reasonKey;
  final bool included;
}

/// An explicitly limited manual reference, never a recommendation or an alias.
class TcpSparklePreset {
  static List<TcpPresetOption> preview(
    List<TcpSettingState> inventory, {
    String? template,
  }) {
    if (template != null &&
        (!RegExp(r'^[A-Za-z][A-Za-z0-9]{0,63}$').hasMatch(template) ||
            !template.endsWith('Custom'))) {
      throw ArgumentError('Select an explicit custom TCP template.');
    }
    final rss = inventory.where((item) => item.target == 'global:rss');
    final supported =
        rss.length == 1 &&
        rss.single.exactlyRestorable &&
        rss.single.supportedValues.contains('Enabled');
    return <TcpPresetOption>[
      const TcpPresetOption(
        'global:heuristics',
        'Disabled',
        'tcpPresetGlobalScopeUnavailable',
      ),
      const TcpPresetOption(
        'template:Internet:congestion',
        'CTCP',
        'tcpPresetInternetReadOnly',
      ),
      TcpPresetOption(
        'global:rss',
        'Enabled',
        supported ? 'tcpPresetIncluded' : 'tcpPresetExactStateUnavailable',
        included: supported,
      ),
      const TcpPresetOption(
        'global:ecn',
        'Enabled',
        'tcpPresetGlobalScopeUnavailable',
      ),
      const TcpPresetOption(
        'global:timestamps',
        'Disabled',
        'tcpPresetGlobalScopeUnavailable',
      ),
      const TcpPresetOption(
        'global:fastopen',
        'Enabled',
        'tcpPresetApiUnavailable',
      ),
      const TcpPresetOption(
        'global:fastopenfallback',
        'Enabled',
        'tcpPresetApiUnavailable',
      ),
      const TcpPresetOption(
        'template:Custom:icw',
        '10',
        'tcpPresetCustomReadOnly',
      ),
      if (template != null)
        for (final entry in const {
          'heuristics': 'Disabled',
          'ecn': 'Enabled',
          'timestamps': 'Disabled',
        }.entries)
          _templateOption(inventory, template, entry.key, entry.value),
    ];
  }

  static TcpPresetOption _templateOption(
    List<TcpSettingState> inventory,
    String template,
    String field,
    String value,
  ) {
    final target = 'template:$template:$field';
    final states = inventory.where((state) => state.target == target);
    final included =
        states.length == 1 &&
        states.single.exactlyRestorable &&
        states.single.supportedValues.contains(value);
    return TcpPresetOption(
      target,
      value,
      included ? 'tcpPresetTemplateVariant' : 'tcpPresetExactStateUnavailable',
      included: included,
    );
  }

  static List<OperationRequest> requests(List<TcpPresetOption> preview) => [
    for (final option in preview.where((item) => item.included))
      OperationRequest(
        operationId: 'network.tcp.setting.configure',
        target: option.target,
        desiredValue: option.value,
      ),
  ];
}

class TcpSettingOperation
    implements
        OperationDefinition,
        SnapshotApplyOperation,
        JournaledRollbackOperation {
  const TcpSettingOperation(this.store, {this.journal});

  final TcpOptimizerStore store;
  final OperationStore? journal;

  String _target(OperationRequest request) {
    if (request.operationId != id || request.parameters.isNotEmpty) {
      throw const FormatException(
        'TCP setting identity or parameters are invalid.',
      );
    }
    final target = request.target;
    if (target == null || target.isEmpty) {
      throw const FormatException('A TCP setting target is required.');
    }
    WindowsTcpOptimizerService.validateTarget(target);
    return target;
  }

  String _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value is! String || value.isEmpty || value.length > 64) {
      throw const FormatException('A typed TCP setting value is required.');
    }
    return value;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000 || context.architecture != 'x64') {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      final current = await store.inspect(_target(request));
      final desired = _desired(request);
      if (!current.exactlyRestorable ||
          !current.supportedValues.contains(desired) ||
          const {'Default', 'NotConfigured', 'NotChanged'}.contains(desired)) {
        return const SupportResult.unsupported(
          'The requested value is not exposed by this Windows build.',
        );
      }
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final current = await store.inspect(_target(request));
      return OperationState(
        current.exactlyRestorable
            ? OperationStateKind.configured
            : OperationStateKind.drifted,
        value: current.value,
        message: current.exactlyRestorable
            ? null
            : 'TCP configuration is inherited, managed, unsupported or incomplete.',
      );
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final target = _target(request);
    final desired = _desired(request);
    final current = await store.inspect(target);
    if (!current.exactlyRestorable ||
        !current.supportedValues.contains(desired) ||
        const {'Default', 'NotConfigured', 'NotChanged'}.contains(desired)) {
      throw StateError(
        'TCP configured state cannot be captured/restored exactly.',
      );
    }
    final data = <String, Object?>{
      'schema': 2,
      'operationId': id,
      'target': target,
      'desiredValue': desired,
      'original': current.original,
    };
    data['digest'] = _digest(data);
    return OperationSnapshot(
      type: 'tcpSetting',
      data: data,
      expectedAfterRollback: OperationState(
        OperationStateKind.configured,
        value: current.configuredValue,
      ),
    );
  }

  @override
  Future<void> apply(OperationRequest request) async {
    _target(request);
    _desired(request);
    throw StateError('TCP writes require the journaled plan snapshot.');
  }

  @override
  Future<void> applySnapshot(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final original = _validateSnapshot(request, snapshot);
    _requireJournalRecord(request, snapshot, applying: true);
    final current = await store.inspect(_target(request));
    _validateLive(current, original);
    if (!_sameOriginal(current.original, original)) {
      throw StateError('TCP configured state drifted after capture.');
    }
    final desired = _desired(request);
    if (!current.supportedValues.contains(desired)) {
      throw StateError('TCP desired value is no longer supported.');
    }
    if (current.configuredValue != desired) {
      await store.write(current.target, desired, expected: current);
    }
  }

  Map<String, Object?> _validateSnapshot(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) {
    final target = _target(request);
    final desired = _desired(request);
    final data = snapshot.data;
    final raw = data['original'];
    if (snapshot.type != 'tcpSetting' ||
        data.length != 6 ||
        data['schema'] != 2 ||
        data['operationId'] != id ||
        data['target'] != target ||
        data['desiredValue'] != desired ||
        raw is! Map ||
        raw.length != 4 ||
        data['digest'] != _digest(data)) {
      throw StateError(
        'Invalid or ambiguous TCP snapshot; no guessed restore is allowed.',
      );
    }
    final original = Map<String, Object?>.from(raw);
    final value = original['configured'];
    if (value is! String ||
        value.isEmpty ||
        value.length > 64 ||
        const {'Default', 'NotConfigured', 'NotChanged'}.contains(value) ||
        original['inheritance'] != 'none' ||
        original['store'] !=
            (target.startsWith('global:')
                ? 'NetOffloadGlobalSetting'
                : 'NetTCPSetting') ||
        (original['effective'] != null && original['effective'] != value) ||
        !snapshot.expectedAfterRollback.sameValue(
          OperationState(OperationStateKind.configured, value: value),
        )) {
      throw StateError(
        'TCP snapshot configuration/store is not exactly reversible.',
      );
    }
    return original;
  }

  void _requireJournalRecord(
    OperationRequest request,
    OperationSnapshot snapshot, {
    bool applying = false,
  }) {
    final trusted = journal;
    if (trusted == null) {
      throw StateError('TCP writes require the trusted application journal.');
    }
    final rows = trusted.database.select(
      '''
      SELECT s.plan_id, s.sequence FROM snapshots s
      JOIN plan_items i ON i.plan_id=s.plan_id AND i.sequence=s.sequence
      WHERE i.operation_id=? AND json_extract(s.snapshot_json, '\$.data.digest')=?
    ''',
      [id, snapshot.data['digest']],
    );
    for (final row in rows) {
      final plan = trusted.load(row['plan_id'] as String)!;
      final item = plan.items[row['sequence'] as int];
      final accepted = applying
          ? item.status == PlanItemStatus.applying &&
                plan.status == PlanStatus.running
          : const {
              PlanItemStatus.applying,
              PlanItemStatus.verified,
              PlanItemStatus.pendingRestart,
              PlanItemStatus.failed,
              PlanItemStatus.rollbackConflict,
              PlanItemStatus.rolledBack,
            }.contains(item.status);
      if (accepted &&
          item.written != null &&
          item.written!.sameValue(
            OperationState(
              OperationStateKind.configured,
              value: request.desiredValue,
            ),
          ) &&
          item.operationId == id &&
          item.request.operationId == request.operationId &&
          item.request.target == request.target &&
          item.request.desiredValue == request.desiredValue &&
          OperationState(
            OperationStateKind.configured,
            value: item.request.parameters,
          ).sameValue(
            OperationState(
              OperationStateKind.configured,
              value: request.parameters,
            ),
          ) &&
          OperationState(
            OperationStateKind.configured,
            value: item.snapshot!.toJson(),
          ).sameValue(
            OperationState(
              OperationStateKind.configured,
              value: snapshot.toJson(),
            ),
          )) {
        return;
      }
    }
    throw StateError(
      'TCP snapshot is not an attempted operation in the trusted journal.',
    );
  }

  static String _digest(Map<String, Object?> data) {
    final original = data['original'];
    return sha256
        .convert(
          utf8.encode(
            jsonEncode([
              data['schema'],
              data['operationId'],
              data['target'],
              data['desiredValue'],
              if (original is Map)
                [
                  original['configured'],
                  original['effective'],
                  original['inheritance'],
                  original['store'],
                ],
            ]),
          ),
        )
        .toString();
  }

  static bool _sameOriginal(
    Map<String, Object?> left,
    Map<String, Object?> right,
  ) => const [
    'configured',
    'effective',
    'inheritance',
    'store',
  ].every((key) => left[key] == right[key]);

  static void _validateLive(
    TcpSettingState current,
    Map<String, Object?> original,
  ) {
    if (!current.exactlyRestorable ||
        current.configurationStore != original['store'] ||
        !current.supportedValues.contains(original['configured'])) {
      throw StateError('TCP restore capability or configured state changed.');
    }
  }

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final original = _validateSnapshot(request, snapshot);
    _requireJournalRecord(request, snapshot);
    final current = await store.inspect(_target(request));
    _validateLive(current, original);
    if (_sameOriginal(current.original, original)) return;
    if (current.configuredValue != _desired(request)) {
      throw StateError(
        'TCP rollback conflict: current value differs from the attempted write.',
      );
    }
    await store.write(
      current.target,
      original['configured']! as String,
      expected: current,
    );
    final restored = await store.inspect(current.target);
    _validateLive(restored, original);
    if (!_sameOriginal(restored.original, original)) {
      throw StateError(
        'TCP rollback read-back differs from the original configured state.',
      );
    }
  }

  @override
  String get id => 'network.tcp.setting.configure';
  @override
  int get version => 2;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'tcpSettingOperationTitle';
  @override
  String get descriptionKey => 'tcpSettingOperationDescription';
  @override
  String get domain => 'network';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.machine;
  @override
  OperationRisk get risk => OperationRisk.high;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
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
    'https://learn.microsoft.com/powershell/module/nettcpip/get-nettcpsetting',
    'https://learn.microsoft.com/powershell/module/nettcpip/set-nettcpsetting',
    'https://learn.microsoft.com/powershell/module/nettcpip/get-netoffloadglobalsetting',
    'https://learn.microsoft.com/powershell/module/nettcpip/set-netoffloadglobalsetting',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}

/// Journal references only: no caller-provided snapshot, file path or command.
class TcpSnapshotRestoreOperation extends TcpSettingOperation {
  const TcpSnapshotRestoreOperation(super.store, {super.journal});

  PlanItem _source(OperationRequest request) {
    final parameters = request.parameters;
    final planId = parameters['planId'];
    final sequence = parameters['sequence'];
    final digest = parameters['digest'];
    if (request.operationId != id ||
        parameters.length != 3 ||
        !parameters.keys.every(
          const {'planId', 'sequence', 'digest'}.contains,
        ) ||
        planId is! String ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(planId) ||
        sequence is! int ||
        sequence < 0 ||
        digest is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(digest)) {
      throw const FormatException('Invalid typed TCP journal reference.');
    }
    final plan = journal?.load(planId);
    if (plan == null || sequence >= plan.items.length) {
      throw StateError('TCP journal record is unavailable.');
    }
    final item = plan.items[sequence];
    final snapshot = item.snapshot;
    if (item.operationId != 'network.tcp.setting.configure' ||
        snapshot == null ||
        snapshot.data['digest'] != digest ||
        item.request.target != request.target ||
        snapshot.expectedAfterRollback.value != request.desiredValue) {
      throw StateError(
        'TCP restore target/value/digest does not match the journal.',
      );
    }
    final source = TcpSettingOperation(store, journal: journal);
    source._validateSnapshot(item.request, snapshot);
    source._requireJournalRecord(item.request, snapshot);
    return item;
  }

  @override
  String _target(OperationRequest request) => _source(request).request.target!;

  @override
  String _desired(OperationRequest request) =>
      _source(request).snapshot!.expectedAfterRollback.value! as String;

  Future<void> _checkSourceDrift(OperationRequest request) async {
    final source = _source(request);
    final current = await store.inspect(source.request.target!);
    final state = OperationState(
      OperationStateKind.configured,
      value: current.configuredValue,
    );
    if (!current.exactlyRestorable ||
        (!state.sameValue(source.written!) &&
            !state.sameValue(source.snapshot!.expectedAfterRollback))) {
      throw StateError(
        'TCP journal recovery conflicts with a later configuration change.',
      );
    }
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    try {
      await _checkSourceDrift(request);
      return super.supports(context, request);
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    await _checkSourceDrift(request);
    return super.captureSnapshot(request);
  }

  @override
  String get id => 'network.tcp.snapshot.restore';
  @override
  int get version => 1;
  @override
  String get titleKey => 'tcpSnapshotRestoreOperationTitle';
  @override
  String get descriptionKey => 'tcpSnapshotRestoreOperationDescription';
}

class QosPolicyOperation implements OperationDefinition {
  const QosPolicyOperation(this.store);

  final QosPolicyStore store;

  String _target(OperationRequest request) {
    if (request.parameters.isNotEmpty) {
      throw const FormatException('QoS operation parameters are not allowed.');
    }
    final target = request.target;
    if (target == null || target.isEmpty) {
      throw const FormatException('A QoS policy name is required.');
    }
    return target;
  }

  QosPolicy? _desired(OperationRequest request) {
    final value = request.desiredValue;
    if (value == null) return null;
    if (value is! Map) throw const FormatException('Invalid QoS policy.');
    final policy = QosPolicy.validate(Map<String, dynamic>.from(value));
    if (policy.name != _target(request)) {
      throw const FormatException('QoS policy target mismatch.');
    }
    return policy;
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async {
    if (context.windowsBuild < 22000 || context.architecture != 'x64') {
      return const SupportResult.unsupported('Requires Windows 11 x64.');
    }
    try {
      _desired(request);
      final current = await store.inspect(_target(request));
      if (current != null && !current.editable) {
        return const SupportResult.unsupported(
          'Only ZapTweaks-owned QoS policies can be changed.',
        );
      }
      return const SupportResult.supported();
    } catch (error) {
      return SupportResult.unsupported(error.toString());
    }
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    try {
      final current = await store.inspect(_target(request));
      return current == null
          ? const OperationState(OperationStateKind.absent)
          : OperationState(
              OperationStateKind.configured,
              value: current.toJson(),
            );
    } catch (error) {
      return OperationState(
        OperationStateKind.error,
        message: error.toString(),
      );
    }
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    _desired(request);
    final before = await inspect(request);
    if (before.kind != OperationStateKind.configured &&
        before.kind != OperationStateKind.absent) {
      throw StateError(before.message ?? 'QoS policy inspection failed.');
    }
    return OperationSnapshot(
      type: 'qosPolicy',
      data: <String, Object?>{
        'name': _target(request),
        'original': <String, Object?>{
          'configured': before.value,
          'effective': before.value,
          'inheritance': 'localPolicyStore',
        },
      },
      expectedAfterRollback: before,
    );
  }

  @override
  Future<void> apply(OperationRequest request) =>
      store.write(_target(request), _desired(request));

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    if (snapshot.type != 'qosPolicy' ||
        snapshot.data['name'] != _target(request)) {
      throw StateError('Invalid QoS policy snapshot.');
    }
    final original = snapshot.data['original'];
    final saved = original is Map
        ? (OperationState(
                    OperationStateKind.configured,
                    value: original['effective'],
                  ).sameValue(
                    OperationState(
                      OperationStateKind.configured,
                      value: original['configured'],
                    ),
                  ) &&
                  original['inheritance'] == 'localPolicyStore'
              ? original['configured']
              : null)
        : snapshot.data['policy'];
    if (original is Map &&
        (original['inheritance'] != 'localPolicyStore' ||
            !original.containsKey('configured') ||
            !original.containsKey('effective') ||
            !OperationState(
              OperationStateKind.configured,
              value: original['configured'],
            ).sameValue(
              OperationState(
                OperationStateKind.configured,
                value: original['effective'],
              ),
            ))) {
      throw StateError('Invalid QoS policy snapshot.');
    }
    await store.write(
      _target(request),
      saved == null
          ? null
          : QosPolicy.validate(Map<String, dynamic>.from(saved as Map)),
    );
  }

  @override
  String get id => 'network.qos.policy.configure';
  @override
  int get version => 1;
  @override
  List<String> get legacyAliases => const <String>[];
  @override
  String get titleKey => 'qosPolicyOperationTitle';
  @override
  String get descriptionKey => 'qosPolicyOperationDescription';
  @override
  String get domain => 'network';
  @override
  String get destination => 'Gaming & Performance';
  @override
  OperationScope get scope => OperationScope.app;
  @override
  OperationRisk get risk => OperationRisk.medium;
  @override
  OperationPrivilege get privilege => OperationPrivilege.administrator;
  @override
  RestartImpact get restartImpact => RestartImpact.none;
  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;
  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;
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
    'https://learn.microsoft.com/powershell/module/netqos/get-netqospolicy',
    'https://learn.microsoft.com/powershell/module/netqos/new-netqospolicy',
    'https://learn.microsoft.com/powershell/module/netqos/remove-netqospolicy',
  ];
  @override
  List<String> get dependencies => const <String>[];
  @override
  List<String> get conflicts => const <String>[];
}
