import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:script_utility/core/services/tweak_catalog_service.dart';
import 'package:script_utility/models/action_tweaks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all bundled scripts and executables are mapped by the catalog', () {
    final repoRoot = Directory.current.path;
    final resourcesRoot = Directory(path.join(repoRoot, 'resources'));
    expect(resourcesRoot.existsSync(), isTrue);

    final referencedScripts = <String>{};
    final referencedExecutables = <String>{};
    final referencedDirectories = <String>{};

    String resourcePath(List<String> segments) =>
        path.normalize(path.joinAll(<String>[resourcesRoot.path, ...segments]));

    for (final descriptor in TweakCatalogService().buildCatalog()) {
      final tweak = descriptor.scriptTweak;
      if (tweak is ScriptInteractiveTweak) {
        referencedScripts.add(resourcePath(tweak.scriptSegments));
      } else if (tweak is ExecutableLauncherTweak) {
        referencedExecutables.add(resourcePath(tweak.executableSegments));
      } else if (tweak is DirectoryLauncherTweak) {
        referencedDirectories.add(resourcePath(tweak.directorySegments));
      } else if (tweak is BatchScriptTweak) {
        referencedScripts.add(resourcePath(tweak.batchSegments));
      } else if (tweak is RegistryImportTweak) {
        referencedScripts.add(resourcePath(tweak.registrySegments));
      } else if (tweak is ExplorerSelectFileTweak) {
        referencedScripts.add(resourcePath(tweak.fileSegments));
      }
    }

    final allScriptFiles = resourcesRoot
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) {
          final lower = file.path.toLowerCase();
          return lower.endsWith('.ps1') ||
              lower.endsWith('.bat') ||
              lower.endsWith('.reg') ||
              lower.endsWith('.nip');
        })
        .map((file) => path.normalize(file.path))
        .toSet();

    final allExecutableFiles = resourcesRoot
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.exe'))
        .map((file) => path.normalize(file.path))
        .toSet();

    final coveredExecutables = <String>{...referencedExecutables};
    for (final directoryPath in referencedDirectories) {
      final directory = Directory(directoryPath);
      if (!directory.existsSync()) {
        continue;
      }

      coveredExecutables.addAll(
        directory
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.toLowerCase().endsWith('.exe'))
            .map((file) => path.normalize(file.path)),
      );
    }

    final uncoveredScripts =
        allScriptFiles
            .difference(referencedScripts)
            .map((item) => path.relative(item, from: repoRoot))
            .toList()
          ..sort();
    final uncoveredExecutables =
        allExecutableFiles
            .difference(coveredExecutables)
            .map((item) => path.relative(item, from: repoRoot))
            .toList()
          ..sort();

    expect(
      uncoveredScripts,
      isEmpty,
      reason: 'Unmapped scripts/files: ${uncoveredScripts.join(', ')}',
    );
    expect(
      uncoveredExecutables,
      isEmpty,
      reason: 'Unmapped executables: ${uncoveredExecutables.join(', ')}',
    );
  });
}
