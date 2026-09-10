import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/operation_registry.dart';
import 'package:script_utility/core/persistence/operation_store.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/plans/plan_engine.dart';

class _MemoryOperation extends OperationDefinition {
  _MemoryOperation(this.id, this.scope, this._values);

  @override
  final String id;
  @override
  final OperationScope scope;
  final Map<String, Object?> _values;
  @override
  List<String> get legacyAliases => const <String>[];

  String _key(OperationRequest request) => '$id/${request.target ?? ''}';

  @override
  Future<void> apply(OperationRequest request) async {
    _values[_key(request)] = request.desiredValue;
  }

  @override
  Future<OperationSnapshot> captureSnapshot(OperationRequest request) async {
    final state = await inspect(request);
    return OperationSnapshot(
      type: scope == OperationScope.machine ? 'registry' : scope.name,
      data: <String, Object?>{
        'existed': state.kind != OperationStateKind.absent,
        'raw': scope == OperationScope.machine
            ? Uint8List.fromList(<int>[0, 127, 255])
            : state.value,
      },
      expectedAfterRollback: state,
    );
  }

  @override
  Future<OperationState> inspect(OperationRequest request) async {
    final key = _key(request);
    return _values.containsKey(key)
        ? OperationState(OperationStateKind.configured, value: _values[key])
        : const OperationState(OperationStateKind.absent);
  }

  @override
  Future<void> rollback(
    OperationRequest request,
    OperationSnapshot snapshot,
  ) async {
    final previous = snapshot.expectedAfterRollback;
    if (previous.kind == OperationStateKind.absent) {
      _values.remove(_key(request));
    } else {
      _values[_key(request)] = previous.value;
    }
  }

  @override
  Future<SupportResult> supports(
    OperationContext context,
    OperationRequest request,
  ) async => context.architecture == 'x64'
      ? const SupportResult.supported()
      : const SupportResult.unsupported('Windows 11 x64 is required.');

  @override
  Future<OperationState> verify(OperationRequest request) => inspect(request);

  @override
  EvidenceLevel get benefitEvidence => EvidenceLevel.unverified;

  @override
  List<String> get conflicts => const <String>[];

  @override
  List<String> get dependencies => const <String>[];

  @override
  String get descriptionKey => '$id.description';

  @override
  String get destination => 'Expert';

  @override
  String get domain => scope.name;

  @override
  EvidenceLevel get mechanismEvidence => EvidenceLevel.documented;

  @override
  OperationPrivilege get privilege => OperationPrivilege.user;

  @override
  RestartImpact get restartImpact => RestartImpact.none;

  @override
  OperationRisk get risk => OperationRisk.low;

  @override
  RollbackCapability get rollbackCapability => RollbackCapability.exact;

  @override
  List<String> get technicalSources => const <String>['test-fixture'];

  @override
  String get titleKey => '$id.title';

  @override
  EvidenceLevel get valueEvidence => EvidenceLevel.documented;

  @override
  int get version => 1;
}

void main() {
  test(
    'registry, service, power and device operations complete and roll back',
    () async {
      final values = <String, Object?>{};
      final definitions = <OperationDefinition>[
        _MemoryOperation('registry.sample.set', OperationScope.machine, values),
        _MemoryOperation(
          'service.sample.configure',
          OperationScope.machine,
          values,
        ),
        _MemoryOperation('power.sample.set', OperationScope.powerPlan, values),
        _MemoryOperation('device.sample.set', OperationScope.device, values),
      ];
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final store = OperationStore(database);
      final engine = PlanEngine(
        registry: OperationRegistry(definitions),
        context: const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        user: 'test-user',
        appVersion: 'test',
        store: store,
      );
      final plan = await engine.plan(<OperationRequest>[
        for (final definition in definitions)
          OperationRequest(
            operationId: definition.id,
            target: 'sample',
            desiredValue: true,
          ),
      ]);

      await engine.execute(plan);

      expect(plan.status, PlanStatus.completed);
      expect(
        plan.items.every((item) => item.status == PlanItemStatus.verified),
        isTrue,
      );
      expect(store.load(plan.id)!.items, hasLength(4));
      final storedBytes = store
          .load(plan.id)!
          .items
          .first
          .snapshot!
          .data['raw'];
      expect(storedBytes, isA<Uint8List>());
      expect(storedBytes, Uint8List.fromList(<int>[0, 127, 255]));

      await engine.rollback(plan);

      expect(plan.status, PlanStatus.rolledBack);
      expect(values, isEmpty);
    },
  );

  test('rollback refuses to overwrite a later manual change', () async {
    final values = <String, Object?>{};
    final operation = _MemoryOperation(
      'registry.sample.set',
      OperationScope.machine,
      values,
    );
    final engine = PlanEngine(
      registry: OperationRegistry(<OperationDefinition>[operation]),
      context: const OperationContext(windowsBuild: 26100, edition: 'Home'),
      user: 'test-user',
      appVersion: 'test',
    );
    final request = const OperationRequest(
      operationId: 'registry.sample.set',
      target: 'sample',
      desiredValue: true,
    );
    final plan = await engine.plan(<OperationRequest>[request]);
    await engine.execute(plan);
    values['registry.sample.set/sample'] = 'manual-change';

    await engine.rollback(plan);

    expect(plan.status, PlanStatus.rollbackConflict);
    expect(values['registry.sample.set/sample'], 'manual-change');
  });
}
