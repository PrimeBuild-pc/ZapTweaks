import 'dart:math';

import '../operations/operation.dart';
import '../operations/operation_registry.dart';
import '../persistence/operation_store.dart';
import 'operation_plan.dart';

abstract class OperationExecutor {
  Future<void> apply(OperationDefinition definition, OperationRequest request);
}

class DirectOperationExecutor implements OperationExecutor {
  const DirectOperationExecutor();

  @override
  Future<void> apply(
    OperationDefinition definition,
    OperationRequest request,
  ) => definition.apply(request);
}

class PlanEngine {
  PlanEngine({
    required this.registry,
    required this.context,
    required this.user,
    required this.appVersion,
    this.store,
    OperationExecutor? userExecutor,
    OperationExecutor? elevatedExecutor,
  }) : userExecutor = userExecutor ?? const DirectOperationExecutor(),
       elevatedExecutor = elevatedExecutor ?? const DirectOperationExecutor();

  final OperationRegistry registry;
  final OperationContext context;
  final String user;
  final String appVersion;
  final OperationStore? store;
  final OperationExecutor userExecutor;
  final OperationExecutor elevatedExecutor;

  Future<OperationPlan> plan(List<OperationRequest> requests) async {
    final ordered = _order(requests);
    final items = <PlanItem>[];
    for (final request in ordered) {
      final definition = registry.resolve(request.operationId);
      final support = await definition.supports(context, request);
      final before = support.supported
          ? await definition.inspect(request)
          : OperationState(
              OperationStateKind.notApplicable,
              message: support.reason,
            );
      items.add(
        PlanItem(
          operationId: definition.id,
          request: request,
          before: before,
          status: support.supported
              ? PlanItemStatus.planned
              : PlanItemStatus.skipped,
        ),
      );
    }
    final result = OperationPlan(
      id: _newPlanId(),
      createdAt: DateTime.now().toUtc(),
      user: user,
      appVersion: appVersion,
      windowsBuild: context.windowsBuild,
      items: items,
    );
    store?.save(result);
    return result;
  }

  Future<OperationPlan> execute(
    OperationPlan plan, {
    bool dryRun = false,
  }) async {
    if (dryRun) {
      plan.status = PlanStatus.dryRunComplete;
      store?.save(plan);
      return plan;
    }

    plan.status = PlanStatus.running;
    store?.save(plan);
    try {
      for (final item in plan.items.where(
        (item) => item.status == PlanItemStatus.planned,
      )) {
        final definition = registry.resolve(item.operationId);
        item.snapshot = await definition.captureSnapshot(item.request);
        item.status = PlanItemStatus.snapshotted;
      }
      store?.save(plan);

      for (final item in plan.items.where(
        (item) => item.status == PlanItemStatus.snapshotted,
      )) {
        final definition = registry.resolve(item.operationId);
        item.status = PlanItemStatus.applying;
        store?.save(plan);
        final executor =
            definition.privilege == OperationPrivilege.administrator
            ? elevatedExecutor
            : userExecutor;
        await executor.apply(definition, item.request);
        final observed = await definition.verify(item.request);
        item.written = observed;
        if (observed.kind == OperationStateKind.pendingRestart) {
          item.status = PlanItemStatus.pendingRestart;
          plan.restartRequired = true;
        } else if (observed.kind == OperationStateKind.configured &&
            _valuesEqual(observed.value, item.request.desiredValue)) {
          item.status = PlanItemStatus.verified;
        } else {
          throw StateError(
            '${definition.id} verification returned ${observed.kind.name}.',
          );
        }
      }
      plan.status = PlanStatus.completed;
    } catch (error) {
      final current = plan.items.where(
        (item) => item.status == PlanItemStatus.applying,
      );
      if (current.isNotEmpty) {
        current.first
          ..status = PlanItemStatus.failed
          ..error = error.toString();
      }
      plan.status =
          plan.items.any(
            (item) =>
                item.status == PlanItemStatus.verified ||
                item.status == PlanItemStatus.pendingRestart,
          )
          ? PlanStatus.rollbackRequired
          : PlanStatus.failed;
    }
    store?.save(plan);
    return plan;
  }

  Future<OperationPlan> rollback(
    OperationPlan plan, {
    bool overwriteConflicts = false,
  }) async {
    var conflict = false;
    for (final item in plan.items.reversed.where(
      (item) =>
          item.status == PlanItemStatus.verified ||
          item.status == PlanItemStatus.pendingRestart,
    )) {
      final definition = registry.resolve(item.operationId);
      final snapshot = item.snapshot;
      if (snapshot == null ||
          definition.rollbackCapability == RollbackCapability.none ||
          definition.rollbackCapability == RollbackCapability.manual) {
        continue;
      }
      final current = await definition.inspect(item.request);
      if (item.written != null &&
          !current.sameValue(item.written!) &&
          !overwriteConflicts) {
        item.status = PlanItemStatus.rollbackConflict;
        conflict = true;
        continue;
      }
      await definition.rollback(item.request, snapshot);
      final restored = await definition.inspect(item.request);
      if (!restored.sameValue(snapshot.expectedAfterRollback)) {
        item.status = PlanItemStatus.rollbackConflict;
        conflict = true;
        continue;
      }
      item.status = PlanItemStatus.rolledBack;
    }
    plan.status = conflict
        ? PlanStatus.rollbackConflict
        : PlanStatus.rolledBack;
    if (!conflict) plan.restartRequired = false;
    store?.save(plan);
    return plan;
  }

  List<OperationRequest> _order(List<OperationRequest> requests) {
    final byDefinition = <String, OperationRequest>{};
    for (final request in requests) {
      final id = registry.resolve(request.operationId).id;
      if (byDefinition.containsKey(id)) {
        throw StateError('Duplicate operation in plan: $id');
      }
      byDefinition[id] = request;
    }
    for (final entry in byDefinition.entries) {
      final definition = registry.resolve(entry.key);
      final conflict = definition.conflicts.where(byDefinition.containsKey);
      if (conflict.isNotEmpty) {
        throw StateError('${entry.key} conflicts with ${conflict.first}.');
      }
    }

    final result = <OperationRequest>[];
    final visiting = <String>{};
    final visited = <String>{};
    void visit(String id) {
      if (visited.contains(id)) return;
      if (!visiting.add(id)) throw StateError('Dependency cycle at $id.');
      for (final dependency in registry.resolve(id).dependencies) {
        if (!byDefinition.containsKey(dependency)) {
          throw StateError('$id requires missing operation $dependency.');
        }
        visit(dependency);
      }
      visiting.remove(id);
      visited.add(id);
      result.add(byDefinition[id]!);
    }

    for (final id in byDefinition.keys) {
      visit(id);
    }
    return result;
  }

  static String _newPlanId() {
    final random = Random.secure();
    return List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  static bool _valuesEqual(Object? left, Object? right) => OperationState(
    OperationStateKind.configured,
    value: left,
  ).sameValue(OperationState(OperationStateKind.configured, value: right));
}
