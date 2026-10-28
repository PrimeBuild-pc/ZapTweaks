import '../../core/operations/operation.dart';
import '../../core/operations/sparkle_operations.dart';
import 'service_control_manager.dart';

class SparkleServicePreview {
  const SparkleServicePreview({required this.name, this.service, this.error});

  final String name;
  final WindowsServiceInfo? service;
  final String? error;
}

/// Read-only, limited to the existing nonessential service allowlist.
List<SparkleServicePreview> inspectSparkleServices(
  ServiceConfigurationStore store,
) => <SparkleServicePreview>[
  for (final name in sparkleManualServices) _inspect(store, name),
];

SparkleServicePreview _inspect(ServiceConfigurationStore store, String name) {
  try {
    return SparkleServicePreview(name: name, service: store.inspect(name));
  } catch (error) {
    return SparkleServicePreview(name: name, error: error.toString());
  }
}

/// Only explicitly selected entries become requests; never a bulk default.
List<OperationRequest> sparkleServiceRequests(Map<String, int> selected) =>
    <OperationRequest>[
      for (final entry in selected.entries)
        if (!sparkleManualServices.contains(entry.key) ||
            !const <int>{2, 3, 4}.contains(entry.value))
          throw ArgumentError('Invalid explicit service selection.')
        else
          OperationRequest(
            operationId: 'service.start.configure',
            target: entry.key,
            desiredValue: <String, Object?>{
              'startType': entry.value,
              'delayedAutoStart': false,
            },
          ),
    ];
