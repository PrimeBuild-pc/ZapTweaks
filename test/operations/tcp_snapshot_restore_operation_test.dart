import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:script_utility/core/models/restore_point_result.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/operation_registry.dart';
import 'package:script_utility/core/operations/tcp_optimizer_operations.dart';
import 'package:script_utility/core/persistence/operation_store.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/plans/plan_engine.dart';
import 'package:script_utility/core/security/elevated_helper.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/core/services/restore_point_service.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/core/tweak_manager.dart';
import 'package:script_utility/platform/windows/tcp_optimizer_service.dart';

const _context = OperationContext(windowsBuild: 26100, edition: 'Pro');
const _rssRequest = OperationRequest(
  operationId: 'network.tcp.setting.configure',
  target: 'global:rss',
  desiredValue: 'Enabled',
);
const _requests = [
  _rssRequest,
  OperationRequest(
    operationId: 'network.tcp.setting.configure',
    target: 'global:rsc',
    desiredValue: 'Enabled',
  ),
  OperationRequest(
    operationId: 'network.tcp.setting.configure',
    target: 'template:InternetCustom:ecn',
    desiredValue: 'Enabled',
  ),
];
TcpSettingState _exact(String target, String value) => TcpSettingState(
  target: target,
  template: target.startsWith('global:') ? 'Global' : 'InternetCustom',
  field: target.split(':').last,
  value: value,
  configuredValue: value,
  effectiveValue: null,
  configurationStore: target.startsWith('global:')
      ? 'NetOffloadGlobalSetting'
      : 'NetTCPSetting',
  inheritance: 'none',
  supportedValues: const ['Disabled', 'Enabled'],
  writable: true,
);

class _Store implements TcpOptimizerStore {
  _Store({
    this.failedIndex,
    this.mutateFirst = false,
    this.rollbackFailure = false,
    this.driftOnFailure = false,
    this.readbackDrift = false,
    this.restoreDrift = false,
  });
  final int? failedIndex;
  final bool mutateFirst,
      rollbackFailure,
      driftOnFailure,
      readbackDrift,
      restoreDrift;
  final states = {
    for (final request in _requests)
      request.target!: _exact(request.target!, 'Disabled'),
  };
  int attempts = 0;
  final restoreOrder = <String>[];
  void Function()? beforeWrite;
  @override
  Future<List<TcpSettingState>> inventory() async => states.values.toList();
  @override
  Future<TcpSettingState> inspect(String target) async =>
      states[target] ?? (throw StateError('Unknown target'));
  @override
  Future<void> write(
    String target,
    String value, {
    required TcpSettingState expected,
  }) async {
    if (!OperationState(
      OperationStateKind.configured,
      value: states[target]!.original,
    ).sameValue(
      OperationState(OperationStateKind.configured, value: expected.original),
    )) {
      throw StateError('TCP configured state drifted before write.');
    }
    if (value == 'Disabled') {
      restoreOrder.add(target);
      if (rollbackFailure) throw StateError('rollback failure');
      states[target] = _exact(target, restoreDrift ? 'Enabled' : value);
      return;
    }
    beforeWrite?.call();
    final fail = attempts++ == failedIndex;
    if (!fail || mutateFirst) {
      states[target] = _exact(target, readbackDrift ? 'Other' : value);
    }
    if (fail) {
      if (driftOnFailure) states[target] = _exact(target, 'Other');
      throw StateError('original failure');
    }
  }
}

PlanEngine _engine(_Store store, OperationStore? journal) => PlanEngine(
  registry: OperationRegistry([
    TcpSettingOperation(store, journal: journal),
    TcpSnapshotRestoreOperation(store, journal: journal),
  ]),
  context: _context,
  user: 'test',
  appVersion: 'test',
  store: journal,
  elevatedExecutor: const DirectOperationExecutor(),
);

class _Restore extends RestorePointService {
  _Restore() : super(processRunner: ProcessRunner());
  @override
  Future<RestorePointResult> createRestorePoint({
    required String description,
  }) async => const RestorePointResult(success: true);
}

void main() {
  test(
    'Sparkle preview lists eight options, RSS only, no substitute template',
    () {
      final preview = TcpSparklePreset.preview([
        _exact('global:rss', 'Disabled'),
      ]);
      expect(preview, hasLength(8));
      expect(
        preview.where((item) => item.included).map((item) => item.target),
        ['global:rss'],
      );
      expect(preview.where((item) => !item.included), hasLength(7));
      expect(
        preview.every((item) => !item.target.contains('InternetCustom')),
        isTrue,
      );
      expect(TcpSettingOperation(_Store()).risk, OperationRisk.high);
    },
  );
  test(
    'custom-template variants require an explicit choice and exact originals',
    () {
      final states = [
        _exact('global:rss', 'Disabled'),
        _exact('template:InternetCustom:heuristics', 'Enabled'),
        _exact('template:InternetCustom:ecn', 'Disabled'),
        _exact('template:InternetCustom:timestamps', 'Enabled'),
      ];
      expect(
        TcpSparklePreset.requests(TcpSparklePreset.preview(states)),
        hasLength(1),
      );
      final selected = TcpSparklePreset.preview(
        states,
        template: 'InternetCustom',
      );
      expect(
        TcpSparklePreset.requests(selected).map((request) => request.target),
        [
          'global:rss',
          'template:InternetCustom:heuristics',
          'template:InternetCustom:ecn',
          'template:InternetCustom:timestamps',
        ],
      );
      expect(
        selected.where(
          (option) => option.reasonKey == 'tcpPresetTemplateVariant',
        ),
        hasLength(3),
      );
      expect(
        () => TcpSparklePreset.preview(states, template: 'Internet'),
        throwsArgumentError,
      );
      expect(
        () =>
            TcpSparklePreset.preview(states, template: 'InternetCustom; exit'),
        throwsArgumentError,
      );
      expect(
        TcpSparklePreset.preview(
          states.take(2).toList(),
          template: 'InternetCustom',
        ).where((option) => option.included),
        hasLength(2),
      );
    },
  );
  test(
    'absent Default inherited managed and incomplete captures never write',
    () async {
      for (final state in [
        const TcpSettingState(
          target: 'global:rss',
          template: 'Global',
          field: 'rss',
          value: 'Enabled',
          supportedValues: ['Disabled', 'Enabled'],
          writable: true,
        ),
        _exact('global:rss', 'Default'),
        const TcpSettingState(
          target: 'global:rss',
          template: 'Global',
          field: 'rss',
          value: 'Enabled',
          configuredValue: 'Disabled',
          effectiveValue: 'Enabled',
          configurationStore: 'NetOffloadGlobalSetting',
          inheritance: 'policy',
          supportedValues: ['Disabled', 'Enabled'],
          writable: true,
        ),
      ]) {
        final store = _Store()..states['global:rss'] = state;
        final operation = TcpSettingOperation(store);
        expect(
          (await operation.supports(_context, _rssRequest)).supported,
          isFalse,
        );
        expect(
          TcpSparklePreset.preview([state]).where((item) => item.included),
          isEmpty,
        );
        await expectLater(
          operation.captureSnapshot(_rssRequest),
          throwsStateError,
        );
        await expectLater(operation.apply(_rssRequest), throwsStateError);
        expect(store.attempts, 0);
      }
    },
  );
  test(
    'digest target schema store and live drift are checked before write',
    () async {
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final journal = OperationStore(database);
      final store = _Store();
      final operation = TcpSettingOperation(store, journal: journal);
      final plan = await _engine(store, journal).plan([_rssRequest]);
      final snapshot = await operation.captureSnapshot(_rssRequest);
      plan.status = PlanStatus.running;
      plan.items.single
        ..snapshot = snapshot
        ..status = PlanItemStatus.applying
        ..written = const OperationState(
          OperationStateKind.configured,
          value: 'Enabled',
        );
      journal.save(plan);
      for (final data in <Map<String, Object?>>[
        {...snapshot.data, 'target': 'global:rsc'},
        {...snapshot.data, 'schema': 42},
        {
          ...snapshot.data,
          'original': {
            ...snapshot.data['original']! as Map,
            'store': 'ArbitraryStore',
          },
        },
        {...snapshot.data, 'digest': '0' * 64},
      ]) {
        await expectLater(
          operation.applySnapshot(
            _rssRequest,
            OperationSnapshot(
              type: snapshot.type,
              data: data,
              expectedAfterRollback: snapshot.expectedAfterRollback,
            ),
          ),
          throwsStateError,
        );
      }
      store.states['global:rss'] = _exact('global:rss', 'Enabled');
      await expectLater(
        operation.applySnapshot(_rssRequest, snapshot),
        throwsA(
          isA<StateError>().having(
            (error) => error.toString(),
            'reason',
            contains('drifted after capture'),
          ),
        ),
      );
      expect(store.attempts, 0);
    },
  );
  test('direct apply rejects non-journaled writes and injection', () async {
    final store = _Store();
    final operation = TcpSettingOperation(store);
    for (final request in [
      _rssRequest,
      const OperationRequest(
        operationId: 'network.tcp.setting.configure',
        target: 'global:rss;whoami',
        desiredValue: 'Enabled',
      ),
      const OperationRequest(
        operationId: 'network.tcp.setting.configure',
        target: 'global:rss',
        desiredValue: 'Enabled',
        parameters: {'command': 'whoami'},
      ),
    ]) {
      await expectLater(operation.apply(request), throwsA(anything));
    }
    expect(store.attempts, 0);
  });
  for (final failedIndex in [0, 1, 2]) {
    for (final mutateFirst in [false, true]) {
      test(
        'failure at $failedIndex mutate=$mutateFirst restores attempted writes in reverse',
        () async {
          final database = sqlite3.openInMemory();
          addTearDown(database.close);
          final journal = OperationStore(database);
          final store = _Store(
            failedIndex: failedIndex,
            mutateFirst: mutateFirst,
          );
          final engine = _engine(store, journal);
          final plan = await engine.plan(_requests);
          store.beforeWrite = () {
            final persisted = journal.load(plan.id)!;
            expect(
              persisted.items.every((item) => item.snapshot != null),
              isTrue,
            );
            expect(
              persisted.items[store.attempts].status,
              PlanItemStatus.applying,
            );
          };
          await engine.execute(plan);
          expect(plan.status, PlanStatus.rolledBack);
          expect(
            store.states.values.map((item) => item.value),
            everyElement('Disabled'),
          );
          expect(
            store.restoreOrder,
            _requests
                .take(failedIndex + (mutateFirst ? 1 : 0))
                .map((item) => item.target)
                .toList()
                .reversed
                .toList(),
          );
          expect(plan.items[failedIndex].error, contains('original failure'));
        },
      );
    }
  }
  test(
    'journal required and incomplete capture prevents every write',
    () async {
      final store = _Store();
      final engine = _engine(store, null);
      await expectLater(
        engine.execute(await engine.plan(_requests)),
        throwsStateError,
      );
      expect(store.attempts, 0);
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final journaled = _engine(store, OperationStore(database));
      final plan = await journaled.plan(_requests);
      store.states['global:rsc'] = const TcpSettingState(
        target: 'global:rsc',
        template: 'Global',
        field: 'rsc',
        value: 'Enabled',
        supportedValues: ['Disabled', 'Enabled'],
        writable: true,
      );
      await journaled.execute(plan);
      expect(store.attempts, 0);
      expect(plan.status, PlanStatus.failed);
    },
  );
  for (final drift in [false, true]) {
    test(
      'rollback ${drift ? 'drift' : 'error'} preserves original error',
      () async {
        final database = sqlite3.openInMemory();
        addTearDown(database.close);
        final store = _Store(
          failedIndex: 1,
          mutateFirst: true,
          rollbackFailure: !drift,
          driftOnFailure: drift,
        );
        final engine = _engine(store, OperationStore(database));
        final plan = await engine.plan(_requests);
        await engine.execute(plan);
        expect(plan.status, PlanStatus.rollbackConflict);
        expect(plan.items[1].error, contains('original failure'));
        expect(
          plan.items.any(
            (item) => item.status == PlanItemStatus.rollbackConflict,
          ),
          isTrue,
        );
      },
    );
  }
  test(
    'typed recovery resolves the original only from a trusted journal record',
    () async {
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final journal = OperationStore(database);
      final store = _Store();
      final engine = _engine(store, journal);
      final original = await engine.plan([_rssRequest]);
      await engine.execute(original);
      final restore = OperationRequest(
        operationId: 'network.tcp.snapshot.restore',
        target: 'global:rss',
        desiredValue: 'Disabled',
        parameters: {
          'planId': original.id,
          'sequence': 0,
          'digest': original.items.single.snapshot!.data['digest'],
        },
      );
      final restored = await engine.plan([restore]);
      await engine.execute(restored);
      expect(restored.status, PlanStatus.completed);
      expect(store.states['global:rss']!.value, 'Disabled');
      await engine.rollback(restored);
      expect(store.states['global:rss']!.value, 'Enabled');
      final operation = TcpSnapshotRestoreOperation(store, journal: journal);
      for (final parameters in [
        {...restore.parameters, 'path': 'C:\\untrusted.sqlite'},
        {...restore.parameters, 'planId': '../operations.sqlite'},
        {...restore.parameters, 'sequence': -1},
        {...restore.parameters, 'digest': '0' * 64},
      ]) {
        expect(
          (await operation.supports(
            _context,
            OperationRequest(
              operationId: restore.operationId,
              target: restore.target,
              desiredValue: restore.desiredValue,
              parameters: parameters,
            ),
          )).supported,
          isFalse,
        );
      }
      expect(
        (await operation.supports(
          _context,
          OperationRequest(
            operationId: restore.operationId,
            target: 'global:rsc',
            desiredValue: 'Disabled',
            parameters: restore.parameters,
          ),
        )).supported,
        isFalse,
      );
    },
  );

  test(
    'capture drift never authorizes rollback of a write that was not attempted',
    () async {
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final journal = OperationStore(database);
      final store = _Store()
        ..states['global:rss'] = _exact('global:rss', 'Enabled');
      final engine = _engine(store, journal);
      final plan = await engine.plan([_rssRequest]);
      store.states['global:rss'] = _exact('global:rss', 'Disabled');
      await engine.execute(plan);
      expect(plan.status, PlanStatus.failed);
      expect(plan.items.single.snapshot, isNotNull);
      expect(plan.items.single.written, isNull);
      store.states['global:rss'] = _exact('global:rss', 'Enabled');
      await expectLater(
        TcpSettingOperation(
          store,
          journal: journal,
        ).rollback(_rssRequest, plan.items.single.snapshot!),
        throwsStateError,
      );
      await engine.rollback(plan);
      expect(store.states['global:rss']!.value, 'Enabled');
      expect(store.attempts, 0);
      expect(store.restoreOrder, isEmpty);
    },
  );
  test(
    'unregistered or unattempted snapshots cannot bypass the trusted journal',
    () async {
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final journal = OperationStore(database);
      final store = _Store();
      final operation = TcpSettingOperation(store, journal: journal);
      final snapshot = await operation.captureSnapshot(_rssRequest);
      await expectLater(
        operation.applySnapshot(_rssRequest, snapshot),
        throwsStateError,
      );
      await expectLater(
        operation.rollback(_rssRequest, snapshot),
        throwsStateError,
      );
      final plan = await _engine(store, journal).plan([_rssRequest]);
      plan.items.single.snapshot = snapshot;
      journal.save(plan);
      await expectLater(
        operation.applySnapshot(_rssRequest, snapshot),
        throwsStateError,
      );
      await expectLater(
        operation.rollback(_rssRequest, snapshot),
        throwsStateError,
      );
      expect(store.attempts, 0);
    },
  );
  for (final restoring in [false, true]) {
    test(
      '${restoring ? 'restore' : 'apply'} readback drift cannot report success',
      () async {
        final database = sqlite3.openInMemory();
        addTearDown(database.close);
        final store = _Store(
          readbackDrift: !restoring,
          restoreDrift: restoring,
        );
        final engine = _engine(store, OperationStore(database));
        final plan = await engine.plan([_rssRequest]);
        await engine.execute(plan);
        if (restoring) await engine.rollback(plan);
        expect(plan.status, PlanStatus.rollbackConflict);
        expect(
          plan.items.single.error,
          contains(restoring ? 'read-back' : 'verification'),
        );
      },
    );
  }
  test(
    'native helper plan uses the same journal checks and partial-failure rollback',
    () async {
      final directory = await Directory.systemTemp.createTemp('tcp-helper-');
      addTearDown(() => directory.delete(recursive: true));
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final journal = OperationStore(database);
      final store = _Store(failedIndex: 1, mutateFirst: true);
      final registry = OperationRegistry([
        TcpSettingOperation(store, journal: journal),
      ]);
      final host = ElevatedHelperHost(
        allowedDirectory: directory,
        catalogService: TweakCatalogService(),
        tweakManager: TweakManager(),
        restorePointService: _Restore(),
        operationRegistry: registry,
        operationContext: _context,
        operationStore: journal,
      );
      var launches = 0;
      final client = ElevatedHelperClient(
        directory: directory,
        secureDirectory: (_) async {},
        launcher: (_, request, nonce, digest) {
          launches++;
          return host.run(request, nonce, digest);
        },
      );
      final result = await client.executeNativePlan(
        requests: _requests,
        user: 'test',
        appVersion: 'test',
      );
      expect(result.status, PlanStatus.rolledBack);
      expect(launches, 1);
      expect(
        store.states.values.map((item) => item.value),
        everyElement('Disabled'),
      );
      await expectLater(
        client.applyNativeOperation(_rssRequest),
        throwsStateError,
      );
      await expectLater(
        client.executeNativePlan(
          requests: const [
            OperationRequest(
              operationId: 'network.tcp.setting.configure',
              target: 'global:rss',
              desiredValue: 'Enabled',
              parameters: {'command': 'whoami'},
            ),
          ],
          user: 'test',
          appVersion: 'test',
        ),
        throwsStateError,
      );
      expect(store.attempts, 2);
    },
  );
  test(
    'file-backed journal survives close/reopen and needs no caller-supplied path',
    () async {
      final directory = await Directory.systemTemp.createTemp('tcp-journal-');
      addTearDown(() => directory.delete(recursive: true));
      final path = '${directory.path}/operations.sqlite';
      final store = _Store();
      var database = sqlite3.open(path);
      var journal = OperationStore(database);
      final plan = await _engine(store, journal).plan([_rssRequest]);
      final item = plan.items.single;
      item.snapshot = await TcpSettingOperation(
        store,
      ).captureSnapshot(item.request);
      item.status = PlanItemStatus.applying;
      item.written = const OperationState(
        OperationStateKind.configured,
        value: 'Enabled',
      );
      plan.status = PlanStatus.running;
      journal.save(plan);
      await store.write(
        'global:rss',
        'Enabled',
        expected: store.states['global:rss']!,
      );
      database.close();
      database = sqlite3.open(path);
      addTearDown(database.close);
      journal = OperationStore(database);
      journal.markRunningPlansInterrupted();
      final recovered = journal.loadIncomplete().single;
      await _engine(store, journal).rollback(recovered);
      expect(recovered.status, PlanStatus.rolledBack);
      expect(store.states['global:rss']!.value, 'Disabled');
    },
  );
  test(
    'recovery reloads snapshots and restores an interrupted attempted write',
    () async {
      final database = sqlite3.openInMemory();
      addTearDown(database.close);
      final journal = OperationStore(database);
      final store = _Store();
      final engine = _engine(store, journal);
      final plan = await engine.plan(_requests);
      for (final item in plan.items) {
        item.snapshot = await TcpSettingOperation(
          store,
        ).captureSnapshot(item.request);
        item.status = PlanItemStatus.snapshotted;
      }
      plan.status = PlanStatus.running;
      plan.items.first.status = PlanItemStatus.applying;
      plan.items.first.written = const OperationState(
        OperationStateKind.configured,
        value: 'Enabled',
      );
      journal.save(plan);
      await store.write(
        'global:rss',
        'Enabled',
        expected: store.states['global:rss']!,
      );
      journal.markRunningPlansInterrupted();
      final recovered = journal.loadIncomplete().single;
      await _engine(store, journal).rollback(recovered);
      expect(recovered.status, PlanStatus.rolledBack);
      expect(store.states['global:rss']!.value, 'Disabled');
      expect(recovered.items.first.error, contains('stopped'));
    },
  );
}
