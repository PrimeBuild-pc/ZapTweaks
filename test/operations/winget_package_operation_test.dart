import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/winget_package_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';

void main() {
  test('winget package operation snapshots, verifies and rolls back', () async {
    var installed = false;
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async {
        if (arguments.first == 'export') {
          final output = arguments[arguments.indexOf('--output') + 1];
          await File(output).writeAsString(
            jsonEncode(<String, Object?>{
              'Sources': <Object?>[
                <String, Object?>{
                  'Packages': installed
                      ? <Object?>[
                          <String, String>{
                            'PackageIdentifier': 'Vendor.Package',
                          },
                        ]
                      : <Object?>[],
                },
              ],
            }),
          );
        } else if (arguments.first == 'install') {
          installed = true;
        } else if (arguments.first == 'uninstall') {
          installed = false;
        }
        return ProcessResult(1, 0, '', '');
      },
    );
    final operation = WingetPackageOperation(processRunner: runner);
    const request = OperationRequest(
      operationId: 'app.winget.set',
      target: 'Vendor.Package',
      desiredValue: true,
    );

    final snapshot = await operation.captureSnapshot(request);
    await operation.apply(request);
    expect((await operation.verify(request)).value, isTrue);
    await operation.rollback(request, snapshot);
    expect(installed, isFalse);
  });

  test(
    'winget package operation rejects command injection identities',
    () async {
      final operation = WingetPackageOperation(
        processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
      );
      const request = OperationRequest(
        operationId: 'app.winget.set',
        target: 'Vendor.Package & calc.exe',
        desiredValue: true,
      );

      expect(
        (await operation.supports(
          const OperationContext(windowsBuild: 26100, edition: 'Pro'),
          request,
        )).supported,
        isFalse,
      );
    },
  );
}
