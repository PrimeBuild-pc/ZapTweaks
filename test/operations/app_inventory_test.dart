import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/features/apps/application/app_inventory_parser.dart';
import 'package:script_utility/features/apps/domain/app_package.dart';
import 'package:script_utility/features/apps/domain/microsoft_restore_catalog.dart';

void main() {
  test('AppX inventory keeps per-user and provisioned state distinct', () {
    final parser = AppInventoryParser();
    final packages = parser.parseAppx('''[
      {"Name":"Microsoft.Sample","CurrentUser":true,"AllUsers":false,
       "Provisioned":true,"Reinstallable":false}
    ]''');
    final package = packages.single;

    expect(package.scopes, contains(AppInstallScope.currentUser));
    expect(package.scopes, contains(AppInstallScope.provisioned));
    expect(package.reinstallable, isFalse);
    final preview = parser.previewRemoval(
      package,
      scopes: const <AppInstallScope>{AppInstallScope.provisioned},
    );
    expect(preview.affectedScopes, <AppInstallScope>{
      AppInstallScope.provisioned,
    });
  });

  test(
    'all 17 legacy Microsoft app restores have native package identities',
    () {
      expect(microsoftRestoreCatalog, hasLength(17));
      expect(microsoftRestoreCatalog.keys, contains('Microsoft.WindowsStore'));
      expect(microsoftRestoreCatalog.keys, contains('Microsoft.GamingApp'));
    },
  );
}
