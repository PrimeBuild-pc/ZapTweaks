import '../../../core/operations/operation.dart';
import '../../apps/application/service_inventory.dart';
import '../domain/preset_catalog.dart';
import 'startup_inventory.dart';

/// What this PC looks like, read before the preview.
class PresetFacts {
  const PresetFacts({
    required this.installedAppx,
    required this.services,
    required this.startup,
    required this.tweaks,
  });

  /// Removable AppX package names installed for the current user.
  final Set<String> installedAppx;

  /// Keyed by lowercase service name.
  final Map<String, ServiceEntry> services;
  final List<StartupEntry> startup;

  /// Keyed by operation id, from a read-only inspection.
  final Map<String, ({SupportResult support, OperationState before})> tweaks;
}

enum PreviewStatus { apply, done, skipped, manual }

enum SkipReason {
  notInstalled,
  notFound,
  unsupported,
  duplicate,
  hasDependents,
}

class PreviewLine {
  const PreviewLine(
    this.item,
    this.status, {
    this.label,
    this.reason,
    this.detail,
    this.requests = const <OperationRequest>[],
  });

  final PresetItem item;
  final PreviewStatus status;

  /// What this line is about on this PC (service or startup entry name).
  final String? label;
  final SkipReason? reason;

  /// Unsupported reason from the operation, when there is one.
  final String? detail;
  final List<OperationRequest> requests;
}

List<PreviewLine> buildPresetPreview(Preset preset, PresetFacts facts) {
  final lines = <PreviewLine>[];
  final startupTargets = <String>{};
  for (final item in preset.items) {
    switch (item) {
      case AppPresetItem(:final packageName):
        lines.add(
          facts.installedAppx.contains(packageName)
              ? PreviewLine(
                  item,
                  PreviewStatus.apply,
                  requests: <OperationRequest>[
                    OperationRequest(
                      operationId: 'app.appx.remove_current_user',
                      target: packageName,
                      desiredValue: null,
                      parameters: const <String, Object?>{
                        'scope': 'currentUser',
                      },
                    ),
                  ],
                )
              : PreviewLine(
                  item,
                  PreviewStatus.skipped,
                  reason: SkipReason.notInstalled,
                ),
        );
      case ServicePresetItem(:final name, :final startType):
        final service = facts.services[name.toLowerCase()];
        lines.add(
          service == null
              ? PreviewLine(
                  item,
                  PreviewStatus.skipped,
                  reason: SkipReason.notFound,
                )
              : service.startType == startType
              ? PreviewLine(
                  item,
                  PreviewStatus.done,
                  label: service.displayName,
                )
              // Windows refuses to disable a service others depend on.
              : startType == 4 && service.dependents > 0
              ? PreviewLine(
                  item,
                  PreviewStatus.skipped,
                  label: service.displayName,
                  reason: SkipReason.hasDependents,
                )
              : PreviewLine(
                  item,
                  PreviewStatus.apply,
                  label: service.displayName,
                  requests: <OperationRequest>[
                    OperationRequest(
                      operationId: 'service.start.configure',
                      target: service.name,
                      desiredValue: <String, Object?>{
                        'startType': startType,
                        'delayedAutoStart': false,
                      },
                    ),
                  ],
                ),
        );
      case StartupPresetItem(:final rule):
        final matches = facts.startup
            .where((entry) => rule.matches(entry.name, entry.command))
            .toList();
        if (matches.isEmpty) {
          lines.add(
            PreviewLine(
              item,
              PreviewStatus.skipped,
              reason: SkipReason.notFound,
            ),
          );
        }
        for (final entry in matches) {
          final operationId = entry.machine
              ? 'startup.entry.configure'
              : 'startup.entry.configure_user';
          // The engine allows one write per operation and target.
          if (!startupTargets.add('$operationId|${entry.name.toLowerCase()}')) {
            lines.add(
              PreviewLine(
                item,
                PreviewStatus.skipped,
                label: entry.name,
                reason: SkipReason.duplicate,
              ),
            );
            continue;
          }
          lines.add(
            entry.enabled
                ? PreviewLine(
                    item,
                    PreviewStatus.apply,
                    label: entry.name,
                    requests: <OperationRequest>[
                      OperationRequest(
                        operationId: operationId,
                        target: entry.name,
                        desiredValue: false,
                        parameters: <String, Object?>{
                          'location': entry.location,
                        },
                      ),
                    ],
                  )
                : PreviewLine(item, PreviewStatus.done, label: entry.name),
          );
        }
      case TweakPresetItem(:final operationId, :final desiredValue):
        final state = facts.tweaks[operationId];
        if (state == null || !state.support.supported) {
          lines.add(
            PreviewLine(
              item,
              PreviewStatus.skipped,
              reason: SkipReason.unsupported,
              detail: state?.support.reason,
            ),
          );
        } else if (state.before.sameValue(
          desiredValue == null
              ? const OperationState(OperationStateKind.absent)
              : OperationState(
                  OperationStateKind.configured,
                  value: desiredValue,
                ),
        )) {
          lines.add(PreviewLine(item, PreviewStatus.done));
        } else {
          lines.add(
            PreviewLine(
              item,
              PreviewStatus.apply,
              requests: <OperationRequest>[
                OperationRequest(
                  operationId: operationId,
                  desiredValue: desiredValue,
                ),
              ],
            ),
          );
        }
      case ManualPresetItem():
        lines.add(PreviewLine(item, PreviewStatus.manual));
    }
  }
  return lines;
}

/// Requests the preview turns into, one plan per privilege. Apps go apart
/// from settings: removed apps have no exact rollback, settings do.
({
  List<OperationRequest> admin,
  List<OperationRequest> userSettings,
  List<OperationRequest> userApps,
})
presetPlans(
  List<PreviewLine> lines, {
  Set<String> excluded = const <String>{},
}) {
  final admin = <OperationRequest>[];
  final userSettings = <OperationRequest>[];
  final userApps = <OperationRequest>[];
  for (final line in lines) {
    if (line.status != PreviewStatus.apply) continue;
    if (excluded.contains(line.item.key)) continue;
    for (final request in line.requests) {
      if (request.operationId == 'app.appx.remove_current_user') {
        userApps.add(request);
      } else if (presetAdminOperations.contains(request.operationId)) {
        admin.add(request);
      } else {
        userSettings.add(request);
      }
    }
  }
  return (admin: admin, userSettings: userSettings, userApps: userApps);
}

/// Operations in presets that run through the elevated helper.
const presetAdminOperations = <String>{
  'service.start.configure',
  'startup.entry.configure',
  'power_throttling_off',
  'privacy.advertising_id_off',
  'privacy.diagnostic_data_required',
  'gaming.game_dvr_off',
};
