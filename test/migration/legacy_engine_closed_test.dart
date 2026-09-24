import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/models/action_tweaks.dart';

void main() {
  test('legacy controller cannot execute mutations or bundled payloads', () {
    final controller = File(
      'lib/features/tweaks/application/tweak_controller.dart',
    ).readAsStringSync();
    expect(controller, isNot(contains('_tweakManager.applyTweak(')));
    expect(controller, isNot(contains('.applySystemTweak(')));

    final payloadTypes = <Type>{
      ScriptInteractiveTweak,
      BatchScriptTweak,
      RegistryImportTweak,
      PowerShellTerminalCommandTweak,
      NvidiaProfileImportTweak,
      ExecutableLauncherTweak,
      DirectoryLauncherTweak,
      ExplorerSelectFileTweak,
    };
    final localPayloads = TweakCatalogService().buildCatalog().where(
      (item) => payloadTypes.contains(item.scriptTweak.runtimeType),
    );
    expect(localPayloads, isNotEmpty);
    expect(localPayloads.every((item) => item.isBlockedLegacyScript), isTrue);
    expect(
      TweakCatalogService()
          .buildCatalog()
          .singleWhere(
            (item) => item.id == 'tool_winget_interactive_uninstaller',
          )
          .isBlockedLegacyScript,
      isTrue,
    );

    expect(
      Directory('resources')
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => file.path.replaceAll('\\', '/')),
      <String>['resources/.gitkeep'],
    );
  });
}
