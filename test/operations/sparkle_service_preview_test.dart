import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/operation_registry.dart';
import 'package:script_utility/core/operations/service_start_operation.dart';
import 'package:script_utility/core/operations/sparkle_operations.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/plans/plan_engine.dart';
import 'package:script_utility/platform/windows/service_control_manager.dart';
import 'package:script_utility/platform/windows/sparkle_service_preview.dart';

class _Services implements ServiceConfigurationStore {
  final values = <String, (int, bool)>{
    'DiagTrack': (2, true),
    'WerSvc': (3, false),
  };
  final writes = <String>[];
  List<String> dependents = const ['ExampleDependent'];

  @override
  WindowsServiceInfo inspect(String name) {
    final value = values[name];
    if (value == null) throw StateError('Not installed');
    return WindowsServiceInfo(
      name: name,
      displayName: name,
      startType: value.$1,
      delayedAutoStart: value.$2,
      state: 4,
      account: 'LocalSystem',
      dependencies: const ['RpcSs'],
      dependents: dependents,
      processId: 7,
    );
  }

  @override
  void configureStart(
    String name, {
    required int startType,
    required bool delayedAutoStart,
  }) {
    writes.add(name);
    values[name] = (startType, delayedAutoStart);
  }
}

void main() {
  test(
    'preview is read-only, allowlisted and preserves dependency/live-state details and unavailable reasons',
    () {
      final services = _Services();
      final previews = inspectSparkleServices(services);
      expect(previews.map((p) => p.name).toSet(), sparkleManualServices);
      final installed = previews
          .firstWhere((p) => p.name == 'DiagTrack')
          .service!;
      expect(installed.dependencies, ['RpcSs']);
      expect(installed.dependents, ['ExampleDependent']);
      expect(installed.state, 4);
      expect(
        previews.firstWhere((p) => p.name == 'MapsBroker').error,
        contains('Not installed'),
      );
      expect(services.writes, isEmpty);
    },
  );

  test(
    'requests have no selection defaults and reject non-allowlisted/bad startup values',
    () {
      expect(sparkleServiceRequests({}), isEmpty);
      expect(
        () => sparkleServiceRequests({'WinDefend': 4}),
        throwsArgumentError,
      );
      expect(
        () => sparkleServiceRequests({'DiagTrack': 0}),
        throwsArgumentError,
      );
      final requests = sparkleServiceRequests({'DiagTrack': 4});
      expect(requests.single.target, 'DiagTrack');
      expect(requests.single.desiredValue, {
        'startType': 4,
        'delayedAutoStart': false,
      });
    },
  );

  test(
    'bulk plan creates individual snapshots, verifies and restores startup/delay without stopping live services',
    () async {
      final services = _Services();
      services.dependents = [];
      final before = Map<String, (int, bool)>.from(services.values);
      final operation = ServiceStartOperation(
        store: services,
        allowedServices: sparkleManualServices,
      );
      final engine = PlanEngine(
        registry: OperationRegistry([operation]),
        context: const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        user: 'mock',
        appVersion: 'test',
        elevatedExecutor: const DirectOperationExecutor(),
      );
      final plan = await engine.plan(
        sparkleServiceRequests({'DiagTrack': 4, 'WerSvc': 4}),
      );
      expect(plan.items, hasLength(2));
      await engine.execute(plan);
      expect(plan.items.map((p) => p.snapshot!.data['service']), [
        'DiagTrack',
        'WerSvc',
      ]);
      expect(plan.status, PlanStatus.completed);
      expect(
        plan.items.every((p) => p.status == PlanItemStatus.verified),
        isTrue,
      );
      expect(services.inspect('DiagTrack').state, 4);
      expect(services.writes, ['DiagTrack', 'WerSvc']);
      await engine.rollback(plan);
      expect(plan.status, PlanStatus.rolledBack);
      expect(services.values, before);
      expect(services.inspect('WerSvc').state, 4);
    },
  );
}
