import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/core/security/elevated_helper_policy.dart';

void main() {
  test('helper accepts only allowlisted operations and typed parameters', () {
    final policy = ElevatedHelperPolicy(<String, HelperOperationRule>{
      'service.sample.configure': HelperOperationRule(
        parameters: const <String, Type>{'enabled': bool},
        targetPattern: RegExp(r'^service:[A-Za-z0-9_-]+$'),
      ),
    });

    policy.validate(
      operationId: 'service.sample.configure',
      nonce: '0123456789abcdef0123456789abcdef',
      target: 'service:W32Time',
      parameters: const <String, Object?>{'enabled': true},
    );
    expect(
      () => policy.validate(
        operationId: 'service.sample.configure',
        nonce: '0123456789abcdef0123456789abcdef',
        target: 'service:W32Time',
        parameters: const <String, Object?>{
          'enabled': true,
          'executable': 'powershell.exe',
        },
      ),
      throwsStateError,
    );
    expect(
      () => policy.validate(
        operationId: 'unknown',
        nonce: '0123456789abcdef0123456789abcdef',
        target: null,
        parameters: const <String, Object?>{},
      ),
      throwsStateError,
    );
  });
}
