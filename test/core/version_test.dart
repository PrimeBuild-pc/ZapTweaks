import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/app/app_metadata.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('app metadata version matches the current release', () {
    expect(AppMetadata.semanticVersion, '1.5.1');
  });
}
