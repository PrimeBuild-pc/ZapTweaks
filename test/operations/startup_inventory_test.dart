import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/windows_startup_inventory_service.dart';

class _Runner extends ProcessRunner {
  @override
  Future<String> runPowerShellForOutput(String script) async =>
      '[{"Name":"Second","Command":"second.exe","Location":"HKCU\\\\Run","User":"User"},{"Name":"First","Command":"first.exe --safe","Location":"Startup","User":"User"}]';
}

void main() {
  test('startup inventory preserves command, location and user', () async {
    final apps = await WindowsStartupInventoryService(
      processRunner: _Runner(),
    ).scan();

    expect(apps.map((app) => app.name), <String>['First', 'Second']);
    expect(apps.first.command, 'first.exe --safe');
    expect(apps.last.location, r'HKCU\Run');
    expect(apps.last.user, 'User');
  });
}
