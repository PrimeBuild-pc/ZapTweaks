import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_scheme_rename_operation.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

class _Schemes implements PowerSchemeManagement {
  String name = 'Original';
  @override
  List<PowerSchemeInfo> enumerate() => <PowerSchemeInfo>[
    PowerSchemeInfo(
      id: '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}',
      name: name,
      active: false,
    ),
  ];
  @override
  void renameScheme(String schemeId, String name) => this.name = name;
  @override
  void deleteScheme(String schemeId) {}
}

void main() {
  test('power scheme rename restores the exact original name', () async {
    final schemes = _Schemes();
    final operation = PowerSchemeRenameOperation(schemes: schemes);
    const request = OperationRequest(
      operationId: 'power.scheme.rename',
      target: '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}',
      desiredValue: 'New name',
    );
    final snapshot = await operation.captureSnapshot(request);
    await operation.apply(request);
    expect((await operation.verify(request)).value, 'New name');
    await operation.rollback(request, snapshot);
    expect(schemes.name, 'Original');
  });
}
