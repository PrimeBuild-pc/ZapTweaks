import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/native_operation_catalog.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/registry_value_store.dart';

void main() {
  test('native operations carry bounded platform and source evidence', () {
    final operations = createNativeOperationCatalog(
      const WindowsRegistryValueStore(),
      ProcessRunner(mode: ProcessExecutionMode.dryRun),
    );

    for (final operation in operations) {
      expect(
        operation.supportedEditions,
        containsAll(<String>['Home', 'Pro']),
        reason: operation.id,
      );
      expect(
        operation.supportedArchitectures,
        contains('x64'),
        reason: operation.id,
      );
      expect(operation.technicalSources, isNotEmpty, reason: operation.id);
      expect(
        operation.technicalSources.every(
          (source) => source.startsWith('https://'),
        ),
        isTrue,
        reason: operation.id,
      );
    }
  });

  test('forbidden security bypasses have no native operation', () {
    final ids = createNativeOperationCatalog(
      const WindowsRegistryValueStore(),
      ProcessRunner(mode: ProcessExecutionMode.dryRun),
    ).map((operation) => operation.id);

    expect(ids, isNot(contains('advanced_driver_whql_secure_boot_bypass')));
    expect(
      ids,
      isNot(contains('security.disable_vulnerable_driver_blocklist')),
    );
    expect(ids, isNot(contains('hardware.write_msr')));
  });
}
