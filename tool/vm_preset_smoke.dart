// VM only (NeuroTune-W11, elevated): previews and applies the Competitive
// preset with the real operations, checks read-back, then undoes the
// settings plans and checks every value is back. Also checks the Services
// tab gate (B7): an installed program's service can be changed, an
// unlisted Windows service cannot. Prints CLEAN=true on success.
import 'dart:io';

import 'package:script_utility/core/operations/native_operation_catalog.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/operation_registry.dart';
import 'package:script_utility/core/plans/operation_plan.dart';
import 'package:script_utility/core/plans/plan_engine.dart';
import 'package:script_utility/core/plans/restore_point.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/service_inventory.dart';
import 'package:script_utility/features/apps/application/windows_app_inventory_service.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';
import 'package:script_utility/features/presets/application/preset_preview.dart';
import 'package:script_utility/features/presets/application/startup_inventory.dart';
import 'package:script_utility/features/presets/domain/preset_catalog.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

Future<void> main() async {
  final failures = <String>[];
  void check(bool ok, String what) {
    stdout.writeln('${ok ? 'OK  ' : 'FAIL'} $what');
    if (!ok) failures.add(what);
  }

  final runner = ProcessRunner.shared;
  final registry = OperationRegistry(
    createNativeOperationCatalog(const WindowsRegistryValueStore(), runner),
  );
  final engine = PlanEngine(
    registry: registry,
    context: const OperationContext(windowsBuild: 26100, edition: 'Pro'),
    user: 'vm',
    appVersion: 'smoke',
    elevatedExecutor: const DirectOperationExecutor(),
  );
  Future<OperationPlan> execute(List<OperationRequest> requests) async {
    final plan = await engine.plan(requests);
    await engine.execute(plan);
    return plan;
  }

  final restore = await createRestorePoint(
    execute,
    description: 'ZapTweaks preset smoke',
    enableProtection: true,
  );
  check(restore == null, 'restore point created (${restore ?? 'ok'})');

  final preset = builtInPresets.last;
  final tweaks = <OperationRequest>[
    for (final item in preset.items)
      if (item is TweakPresetItem)
        OperationRequest(
          operationId: item.operationId,
          desiredValue: item.desiredValue,
        ),
  ];
  final apps = await WindowsAppInventoryService(
    processRunner: runner,
  ).scanCurrentUser();
  final facts = PresetFacts(
    installedAppx: <String>{
      for (final app in apps.packages)
        if (app.canRemoveAppx &&
            app.scopes.contains(AppInstallScope.currentUser))
          app.packageId,
    },
    services: <String, ServiceEntry>{
      for (final s in await listServices(runner)) s.name.toLowerCase(): s,
    },
    startup: await listStartupEntries(runner),
    tweaks: <String, ({SupportResult support, OperationState before})>{
      for (final request in tweaks)
        request.operationId: await () async {
          final d = registry.resolve(request.operationId);
          final support = await d.supports(engine.context, request);
          return (
            support: support,
            before: support.supported
                ? await d.inspect(request)
                : const OperationState(OperationStateKind.notApplicable),
          );
        }(),
    },
  );
  final lines = buildPresetPreview(preset, facts);
  for (final line in lines) {
    stdout.writeln(
      '  ${line.status.name.padRight(7)} ${line.item.key}${line.label == null ? '' : ' (${line.label})'}${line.reason == null ? '' : ' · ${line.reason!.name}'}${line.detail == null ? '' : ' · ${line.detail}'}',
    );
  }
  check(
    lines.any(
      (l) => l.item.key == 'startup:spotify' && l.status == PreviewStatus.apply,
    ),
    'planted Spotify startup entry found',
  );
  final plans = presetPlans(lines);
  final before = <String, OperationState>{
    for (final r in <OperationRequest>[...plans.admin, ...plans.userSettings])
      '${r.operationId}|${r.target}': await registry
          .resolve(r.operationId)
          .inspect(r),
  };

  final applied = <OperationPlan>[];
  for (final requests in <List<OperationRequest>>[
    plans.admin,
    plans.userSettings,
    plans.userApps,
  ]) {
    if (requests.isEmpty) continue;
    final plan = await execute(requests);
    for (final item in plan.items) {
      check(
        item.status == PlanItemStatus.verified ||
            item.status == PlanItemStatus.pendingRestart,
        'apply ${item.operationId} ${item.request.target ?? ''} → ${item.status.name}${item.error == null ? '' : ' ${item.error}'}',
      );
    }
    if (!identical(requests, plans.userApps)) applied.add(plan);
  }
  final again = presetPlans(buildPresetPreview(preset, facts));
  check(again.admin.isNotEmpty, 'preview is stable');

  for (final plan in applied.reversed) {
    final undone = await engine.rollback(plan);
    check(
      undone.status == PlanStatus.rolledBack,
      'rollback plan → ${undone.status.name}',
    );
  }
  for (final entry in before.entries) {
    final parts = entry.key.split('|');
    final request = <OperationRequest>[
      ...plans.admin,
      ...plans.userSettings,
    ].firstWhere((r) => r.operationId == parts[0] && '${r.target}' == parts[1]);
    final now = await registry.resolve(parts[0]).inspect(request);
    check(now.sameValue(entry.value), 'restored ${entry.key}');
  }

  // B7: the Services tab gate.
  const desired = <String, Object?>{'startType': 4, 'delayedAutoStart': false};
  final service = registry.resolve('service.start.configure');
  for (final (name, allowed) in <(String, bool)>[
    ('ZTFakeSvc', true),
    ('Appinfo', false),
  ]) {
    final request = OperationRequest(
      operationId: 'service.start.configure',
      target: name,
      desiredValue: desired,
    );
    final support = await service.supports(engine.context, request);
    check(support.supported == allowed, '$name allowed=$allowed');
    if (allowed && support.supported) {
      final plan = await execute(<OperationRequest>[request]);
      check(
        plan.items.single.status == PlanItemStatus.verified ||
            plan.items.single.status == PlanItemStatus.pendingRestart,
        '$name disabled',
      );
      final undone = await engine.rollback(plan);
      check(undone.status == PlanStatus.rolledBack, '$name restored');
    }
  }

  stdout.writeln('CLEAN=${failures.isEmpty}');
  exitCode = failures.isEmpty ? 0 : 1;
}
