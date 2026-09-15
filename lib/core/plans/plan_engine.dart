import 'dart:math';

import '../operations/operation.dart';
import '../operations/operation_registry.dart';
import '../persistence/operation_store.dart';
import 'operation_plan.dart';

abstract class OperationExecutor {
  Future<void> apply(OperationDefinition definition, OperationRequest request);
  Future<void> rollback(
    OperationDefinition definition,
    OperationRequest request,
    OperationSnapshot snapshot,
  );
}

class DirectOperationExecutor implements OperationExecutor {
  const DirectOperationExecutor();

  @override
  Future<void> apply(
    OperationDefinition definition,
    OperationRequest request,
  ) => definition.apply(request);

  @override
  Future<void> rollback(
    OperationDefinition definition,
    OperationRequest request,
    OperationSnapshot snapshot,
  ) => definition.rollback(request, snapshot);
}

class RejectingElevatedExecutor implements OperationExecutor {
  const RejectingElevatedExecutor();

  @override
  Future<void> apply(
    OperationDefinition definition,
    OperationRequest request,
  ) => throw StateError('No elevated helper is connected.');

  @override
  Future<void> rollback(
    OperationDefinition definition,
    OperationRequest request,
    OperationSnapshot snapshot,
  ) => throw StateError('No elevated helper is connected.');
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
       elevatedExecutor = elevatedExecutor ?? const RejectingElevatedExecutor();

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
      final canPlan =
          support.supported &&
          before.kind != OperationStateKind.unknown &&
          before.kind != OperationStateKind.notApplicable &&
          before.kind != OperationStateKind.error;
      items.add(
        PlanItem(
          operationId: definition.id,
          request: request,
          before: before,
          status: canPlan ? PlanItemStatus.planned : PlanItemStatus.skipped,
          error: canPlan ? null : support.reason ?? before.message,
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
        try {
          item.snapshot = await definition.captureSnapshot(item.request);
          item.status = PlanItemStatus.snapshotted;
        } catch (error) {
          item
            ..status = PlanItemStatus.failed
            ..error = error.toString();
          rethrow;
        }
      }
      store?.save(plan);

      var stopSystemMutations = false;
      for (final item in plan.items.where(
        (item) => item.status == PlanItemStatus.snapshotted,
      )) {
        if (stopSystemMutations) {
          item
            ..status = PlanItemStatus.skipped
            ..error = 'Skipped after an earlier system mutation failed.';
          continue;
        }

        final definition = registry.resolve(item.operationId);
        final failedDependency = definition.dependencies.any((dependency) {
          final dependencyItem = plan.items.cast<PlanItem?>().firstWhere(
            (candidate) => candidate?.operationId == dependency,
            orElse: () => null,
          );
          return dependencyItem == null ||
              dependencyItem.status == PlanItemStatus.failed ||
              dependencyItem.status == PlanItemStatus.skipped;
        });
        if (failedDependency) {
          item
            ..status = PlanItemStatus.skipped
            ..error = 'Skipped because a dependency did not complete.';
          continue;
        }

        item.status = PlanItemStatus.applying;
        store?.save(plan);
        try {
          final executor =
              definition.privilege == OperationPrivilege.administrator
              ? elevatedExecutor
              : userExecutor;
          await executor.apply(definition, item.request);
          final observed = await definition.verify(item.request);
          item.written = observed;
          final valueMatches = _valuesEqual(
            observed.value,
            item.request.desiredValue,
          );
          if (observed.kind == OperationStateKind.pendingRestart &&
              valueMatches) {
            item.status = PlanItemStatus.pendingRestart;
            plan.restartRequired = true;
          } else if ((observed.kind == OperationStateKind.configured &&
                  valueMatches) ||
              (observed.kind == OperationStateKind.absent &&
                  item.request.desiredValue == null)) {
            item.status = PlanItemStatus.verified;
            if (definition.restartImpact == RestartImpact.reboot) {
              plan.restartRequired = true;
            }
          } else {
            throw StateError(
              '${definition.id} verification returned '
              '${observed.kind.name} with an unexpected value.',
            );
          }
        } catch (error) {
          item
            ..status = PlanItemStatus.failed
            ..error = error.toString();
          if (definition.scope != OperationScope.app) {
            stopSystemMutations = true;
          }
        }
      }

      final hasFailure = plan.items.any(
        (item) => item.status == PlanItemStatus.failed,
      );
      final mayNeedRollback = plan.items.any(
        (item) =>
            item.status == PlanItemStatus.verified ||
            item.status == PlanItemStatus.pendingRestart ||
            (item.status == PlanItemStatus.failed && item.snapshot != null),
      );
      plan.status = hasFailure
          ? (mayNeedRollback ? PlanStatus.rollbackRequired : PlanStatus.failed)
          : PlanStatus.completed;
    } catch (error) {
      final current = plan.items.where(
        (item) => item.status == PlanItemStatus.applying,
      );
      if (current.isNotEmpty) {
        current.first
          ..status = PlanItemStatus.failed
          ..error = error.toString();
      }
      plan.status = PlanStatus.failed;
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
          item.status == PlanItemStatus.pendingRestart ||
          item.status == PlanItemStatus.failed,
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
      final executor = definition.privilege == OperationPrivilege.administrator
          ? elevatedExecutor
          : userExecutor;
      try {
        await executor.rollback(definition, item.request, snapshot);
        final restored = await definition.inspect(item.request);
        if (!restored.sameValue(snapshot.expectedAfterRollback)) {
          throw StateError('${definition.id} rollback verification failed.');
        }
        item.status = PlanItemStatus.rolledBack;
      } catch (error) {
        item
          ..status = PlanItemStatus.rollbackConflict
          ..error = error.toString();
        conflict = true;
      }
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
