import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_scheme_duplicate_operation.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

class _Schemes implements PowerSchemeManagement {
  final items = <PowerSchemeInfo>[
    const PowerSchemeInfo(
      id: '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}',
      name: 'Source',
      active: true,
    ),
  ];
  @override
  List<PowerSchemeInfo> enumerate() => List<PowerSchemeInfo>.of(items);
  @override
  String duplicateScheme(String schemeId, String name) {
    const id = '{bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb}';
    items.add(PowerSchemeInfo(id: id, name: name, active: false));
    return id;
  }

  @override
  void deleteScheme(String schemeId) =>
      items.removeWhere((item) => item.id == schemeId);
  @override
  void renameScheme(String schemeId, String name) {}
}

void main() {
  test(
    'generated duplicate is verified and rolled back in the same plan',
    () async {
      final schemes = _Schemes();
      final operation = PowerSchemeDuplicateOperation(schemes: schemes);
      const request = OperationRequest(
        operationId: 'power.scheme.duplicate',
        target: '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}',
        desiredValue: 'Copy',
      );
      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      expect((await operation.verify(request)).value, 'Copy');
      await operation.rollback(request, snapshot);
      expect(schemes.items, hasLength(1));
    },
  );
}
