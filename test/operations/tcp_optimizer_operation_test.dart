import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/tcp_optimizer_operations.dart';
import 'package:script_utility/platform/windows/tcp_optimizer_service.dart';

class _TcpStore implements TcpOptimizerStore {
  _TcpStore(this.state);
  TcpSettingState state;
  var writes = 0;

  @override
  Future<List<TcpSettingState>> inventory() async => <TcpSettingState>[state];

  @override
  Future<TcpSettingState> inspect(String target) async {
    if (target != state.target) throw StateError('not found');
    return state;
  }

  @override
  Future<void> write(String target, String value) async {
    writes++;
    state = TcpSettingState(
      target: state.target,
      template: state.template,
      field: state.field,
      value: value,
      supportedValues: state.supportedValues,
      writable: state.writable,
    );
  }
}

class _QosStore implements QosPolicyStore {
  _QosStore(Iterable<QosPolicy> policies)
    : policies = <String, QosPolicy>{
        for (final item in policies) item.name: item,
      };

  final Map<String, QosPolicy> policies;
  final List<String> writes = <String>[];

  @override
  Future<List<QosPolicy>> inventory() async => policies.values.toList();

  @override
  Future<QosPolicy?> inspect(String name) async => policies[name];

  @override
  Future<void> write(String name, QosPolicy? policy) async {
    writes.add(name);
    if (policy == null) {
      policies.remove(name);
    } else {
      policies[name] = policy;
    }
  }
}

const _originalPolicy = QosPolicy(
  name: 'ZapTweaks - Game',
  appPath: r'C:\Games\game.exe',
  protocol: 'Both',
  dscp: 40,
);

void main() {
  const context = OperationContext(windowsBuild: 26100, edition: 'Pro');

  test(
    'TCP setting rejects values not enumerated by the current build',
    () async {
      final store = _TcpStore(
        const TcpSettingState(
          target: 'template:InternetCustom:ecn',
          template: 'InternetCustom',
          field: 'ecn',
          value: 'Disabled',
          supportedValues: <String>['Disabled', 'Enabled'],
          writable: true,
        ),
      );
      final operation = TcpSettingOperation(store);
      const request = OperationRequest(
        operationId: 'network.tcp.setting.configure',
        target: 'template:InternetCustom:ecn',
        desiredValue: 'Maybe',
      );

      expect((await operation.supports(context, request)).supported, isFalse);
      expect(store.writes, 0);
    },
  );

  test(
    'TCP setting snapshots, verifies, and restores the exact value',
    () async {
      final store = _TcpStore(
        const TcpSettingState(
          target: 'global:rsc',
          template: 'Global',
          field: 'rsc',
          value: 'Enabled',
          supportedValues: <String>['Disabled', 'Enabled'],
          writable: true,
        ),
      );
      final operation = TcpSettingOperation(store);
      const request = OperationRequest(
        operationId: 'network.tcp.setting.configure',
        target: 'global:rsc',
        desiredValue: 'Disabled',
      );

      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      expect((await operation.verify(request)).value, 'Disabled');
      await operation.rollback(request, snapshot);
      expect((await operation.inspect(request)).value, 'Enabled');
    },
  );

  test('QoS snapshots and restores present and absent policies', () async {
    final store = _QosStore(const <QosPolicy>[_originalPolicy]);
    final operation = QosPolicyOperation(store);
    final update = OperationRequest(
      operationId: operation.id,
      target: _originalPolicy.name,
      desiredValue: const QosPolicy(
        name: 'ZapTweaks - Game',
        appPath: r'C:\Games\game.exe',
        protocol: 'TCP',
        dscp: 46,
      ).toJson(),
    );
    final present = await operation.captureSnapshot(update);
    await operation.apply(update);
    await operation.rollback(update, present);
    expect(
      store.policies[_originalPolicy.name]!.toJson(),
      _originalPolicy.toJson(),
    );

    const created = QosPolicy(
      name: 'ZapTweaks - New Game',
      appPath: r'C:\Games\new.exe',
      protocol: 'UDP',
      throttleBitsPerSecond: 10000000,
    );
    final create = OperationRequest(
      operationId: operation.id,
      target: created.name,
      desiredValue: created.toJson(),
    );
    final absent = await operation.captureSnapshot(create);
    await operation.apply(create);
    await operation.rollback(create, absent);
    expect(store.policies.containsKey(created.name), isFalse);
  });

  test(
    'QoS validation rejects malformed and arbitrary helper fields',
    () async {
      final store = _QosStore(const <QosPolicy>[]);
      final operation = QosPolicyOperation(store);
      final values = _originalPolicy.toJson()..['command'] = 'Remove-Item C:\\';
      final request = OperationRequest(
        operationId: operation.id,
        target: _originalPolicy.name,
        desiredValue: values,
      );

      expect((await operation.supports(context, request)).supported, isFalse);
      expect(store.writes, isEmpty);
      final helperInjection = OperationRequest(
        operationId: operation.id,
        target: _originalPolicy.name,
        desiredValue: _originalPolicy.toJson(),
        parameters: const <String, Object?>{'command': 'whoami'},
      );
      expect(
        (await operation.supports(context, helperInjection)).supported,
        isFalse,
      );
      expect(store.writes, isEmpty);
      expect(
        () => QosPolicy.validate(<String, dynamic>{
          ..._originalPolicy.toJson(),
          'dscp': 64,
        }),
        throwsFormatException,
      );
      expect(
        () => QosPolicy.validate(<String, dynamic>{
          ..._originalPolicy.toJson(),
          'appPath': r'game.exe & whoami',
        }),
        throwsFormatException,
      );
    },
  );

  test('QoS delete touches only the selected policy', () async {
    const other = QosPolicy(
      name: 'ZapTweaks - Other',
      appPath: r'C:\Games\other.exe',
      protocol: 'Both',
      dscp: 20,
    );
    final store = _QosStore(const <QosPolicy>[_originalPolicy, other]);
    final operation = QosPolicyOperation(store);
    const request = OperationRequest(
      operationId: 'network.qos.policy.configure',
      target: 'ZapTweaks - Game',
      desiredValue: null,
    );

    await operation.apply(request);
    expect(store.policies.keys, <String>[other.name]);
    expect(store.writes, <String>[_originalPolicy.name]);
  });
}
