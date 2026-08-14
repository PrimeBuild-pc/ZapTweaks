import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'process_runner.dart';

class PowerPlan {
  const PowerPlan({required this.name, required this.filePath});

  final String name;
  final String filePath;
}

class PowerPlanService {
  PowerPlanService({
    required SharedPreferences preferences,
    required ProcessRunner processRunner,
  }) : _preferences = preferences,
       _processRunner = processRunner;

  static const String _previousPlanKey = 'powerPlan.previousGuid';
  static const String _importedGuidPrefix = 'powerPlan.importedGuid:';

  final SharedPreferences _preferences;
  final ProcessRunner _processRunner;

  Future<List<PowerPlan>> availablePlans() async {
    final roots = <Directory>[
      Directory(
        path.join(
          path.dirname(Platform.resolvedExecutable),
          'resources',
          'Powerplans',
        ),
      ),
      Directory(path.join(Directory.current.path, 'resources', 'Powerplans')),
    ];
    Directory? root;
    for (final candidate in roots) {
      if (candidate.existsSync()) {
        root = candidate;
        break;
      }
    }
    if (root == null) {
      return const <PowerPlan>[];
    }

    final plans =
        root
            .listSync()
            .whereType<File>()
            .where((file) => path.extension(file.path).toLowerCase() == '.pow')
            .map(
              (file) => PowerPlan(
                name: path.basenameWithoutExtension(file.path),
                filePath: file.path,
              ),
            )
            .toList()
          ..sort((left, right) => left.name.compareTo(right.name));
    return plans;
  }

  Future<void> importAndActivate(PowerPlan plan) async {
    if (!File(plan.filePath).existsSync()) {
      throw Exception('Power plan file is missing: ${plan.name}');
    }

    final previousGuid = await _activeGuid();
    if (previousGuid != null) {
      await _preferences.setString(_previousPlanKey, previousGuid);
    }

    final key =
        '$_importedGuidPrefix${path.basename(plan.filePath).toLowerCase()}';
    var importedGuid = _preferences.getString(key);
    final knownPlans = await _listGuids();
    if (importedGuid == null || !knownPlans.contains(importedGuid)) {
      final result = await _processRunner.run('powercfg', <String>[
        '/import',
        plan.filePath,
      ]);
      if (!result.success) {
        throw Exception(
          result.details.isEmpty ? 'Power plan import failed.' : result.details,
        );
      }

      final afterImport = await _listGuids();
      final imported = afterImport.difference(knownPlans);
      if (imported.length != 1) {
        throw Exception('Windows did not report a unique imported power plan.');
      }
      importedGuid = imported.single;
      await _preferences.setString(key, importedGuid);
    }

    final activate = await _processRunner.run('powercfg', <String>[
      '/setactive',
      importedGuid,
    ]);
    if (!activate.success) {
      throw Exception(
        activate.details.isEmpty
            ? 'Power plan activation failed.'
            : activate.details,
      );
    }
  }

  Future<void> restorePreviousPlan() async {
    final previousGuid = _preferences.getString(_previousPlanKey);
    if (previousGuid == null) {
      throw Exception('No previous power plan is recorded.');
    }

    final result = await _processRunner.run('powercfg', <String>[
      '/setactive',
      previousGuid,
    ]);
    if (!result.success) {
      throw Exception(
        result.details.isEmpty
            ? 'Previous power plan is unavailable.'
            : result.details,
      );
    }
  }

  Future<String?> _activeGuid() async {
    final result = await _processRunner.run('powercfg', const <String>[
      '/getactivescheme',
    ]);
    return _guid(result.stdout);
  }

  Future<Set<String>> _listGuids() async {
    final result = await _processRunner.run('powercfg', const <String>[
      '/list',
    ]);
    return RegExp(r'[0-9a-fA-F-]{36}')
        .allMatches(result.stdout)
        .map((match) => match.group(0)!.toLowerCase())
        .toSet();
  }

  String? _guid(String output) =>
      RegExp(r'[0-9a-fA-F-]{36}').firstMatch(output)?.group(0)?.toLowerCase();
}
