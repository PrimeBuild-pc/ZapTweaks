import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/platform/windows/service_control_manager.dart';

void main() {
  test('SCM reads typed service configuration and live state', () {
    if (!Platform.isWindows) return;

    final service = const ServiceControlManager().inspect('EventLog');

    expect(service.name, 'EventLog');
    expect(service.displayName, isNotEmpty);
    expect(service.startType, inInclusiveRange(0, 4));
    expect(service.state, inInclusiveRange(1, 7));
    expect(service.account, isNotEmpty);
    expect(service.processId, greaterThanOrEqualTo(0));
  });

  test('SCM rejects untrusted service names before native access', () {
    expect(
      () => const ServiceControlManager().inspect(r'EventLog\other'),
      throwsArgumentError,
    );
  });
}
