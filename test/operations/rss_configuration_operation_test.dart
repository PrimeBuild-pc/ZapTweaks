import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/rss_configuration_operation.dart';
import 'package:script_utility/platform/windows/hardware_capability_validators.dart';
import 'package:script_utility/platform/windows/rss_service.dart';

class _RssStore implements RssStore {
  _RssStore(this.state);
  RssAdapterState state;

  @override
  RssCapabilities capabilities(RssAdapterState state) => RssCapabilities(
    processors: <ProcessorAddress>{
      ProcessorAddress(0, 0),
      ProcessorAddress(0, 1),
    },
    maximumQueues: 2,
    maximumProcessors: 2,
  );

  @override
  Future<RssAdapterState> inspect(String adapterName) async => state;

  @override
  Future<void> write(String adapterName, RssConfiguration configuration) async {
    state = RssAdapterState(
      name: adapterName,
      configuration: configuration,
      maximumQueues: 2,
      maximumProcessors: 2,
    );
  }
}

RssConfiguration _configuration(int processors) => RssConfiguration(
  enabled: true,
  profile: 'Closest',
  baseProcessor: const ProcessorAddress(0, 0),
  maximumProcessor: ProcessorAddress(0, processors - 1),
  processorCount: processors,
  queueCount: processors,
  processorArray: <ProcessorAddress>[
    for (var index = 0; index < processors; index++) ProcessorAddress(0, index),
  ],
);

Map<String, Object?> _json(RssConfiguration value) => <String, Object?>{
  'enabled': value.enabled,
  'profile': value.profile,
  'baseGroup': value.baseProcessor.group,
  'baseNumber': value.baseProcessor.number,
  'maxGroup': value.maximumProcessor.group,
  'maxNumber': value.maximumProcessor.number,
  'processorCount': value.processorCount,
  'queueCount': value.queueCount,
  'processorArray': value.processorArray
      .map((item) => <String, int>{'group': item.group, 'number': item.number})
      .toList(),
};

void main() {
  test('RSS operation snapshots and restores the complete tuple', () async {
    final original = _configuration(1);
    final store = _RssStore(
      RssAdapterState(
        name: 'Ethernet',
        configuration: original,
        maximumQueues: 2,
        maximumProcessors: 2,
      ),
    );
    final operation = RssConfigurationOperation(store);
    final request = OperationRequest(
      operationId: operation.id,
      target: 'Ethernet',
      desiredValue: _json(_configuration(2)),
    );

    final snapshot = await operation.captureSnapshot(request);
    await operation.apply(request);
    expect((await operation.verify(request)).value, request.desiredValue);
    await operation.rollback(request, snapshot);
    expect(
      (await operation.inspect(
        request,
      )).sameValue(snapshot.expectedAfterRollback),
      isTrue,
    );
  });

  test('RSS operation rejects processors outside live topology', () async {
    final original = _configuration(1);
    final operation = RssConfigurationOperation(
      _RssStore(
        RssAdapterState(
          name: 'Ethernet',
          configuration: original,
          maximumQueues: 2,
          maximumProcessors: 2,
        ),
      ),
    );
    final invalid = _json(_configuration(2));
    invalid['processorArray'] = <Map<String, int>>[
      <String, int>{'group': 0, 'number': 0},
      <String, int>{'group': 0, 'number': 9},
    ];
    final support = await operation.supports(
      const OperationContext(windowsBuild: 26100, edition: 'Pro'),
      OperationRequest(
        operationId: operation.id,
        target: 'Ethernet',
        desiredValue: invalid,
      ),
    );
    expect(support.supported, isFalse);
  });
}
