import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

import '../core/services/process_runner.dart';
import 'system_tweak.dart';

void _validateRelativeSegments(List<String> relativeSegments) {
  if (relativeSegments.isEmpty) {
    throw Exception('Invalid resource path: empty segments.');
  }

  for (final segment in relativeSegments) {
    final normalized = segment.trim();
    if (normalized.isEmpty) {
      throw Exception('Invalid resource path: empty segment.');
    }
    if (normalized == '..' ||
        normalized.contains('..\\') ||
        normalized.contains('../') ||
        path.isAbsolute(normalized)) {
      throw Exception('Invalid resource path segment: "$segment"');
    }
  }
}

String? resolveResourceFilePath(List<String> relativeSegments) {
  _validateRelativeSegments(relativeSegments);

  final executableDirectory = path.dirname(Platform.resolvedExecutable);
  final candidates = <String>[
    path.joinAll([
      executableDirectory,
      'data',
      'flutter_assets',
      'resources',
      ...relativeSegments,
    ]),
    path.joinAll([executableDirectory, 'resources', ...relativeSegments]),
    path.joinAll([Directory.current.path, 'resources', ...relativeSegments]),
  ];

  for (final candidate in candidates) {
    if (File(candidate).existsSync()) {
      return candidate;
    }
  }

  return null;
}

String _resourceRelativePath(List<String> relativeSegments) {
  return 'resources\\${path.joinAll(relativeSegments)}';
}

String? resolveResourceDirectoryPath(List<String> relativeSegments) {
  _validateRelativeSegments(relativeSegments);

  final executableDirectory = path.dirname(Platform.resolvedExecutable);
  final candidates = <String>[
    path.joinAll([
      executableDirectory,
      'data',
      'flutter_assets',
      'resources',
      ...relativeSegments,
    ]),
    path.joinAll([executableDirectory, 'resources', ...relativeSegments]),
    path.joinAll([Directory.current.path, 'resources', ...relativeSegments]),
  ];

  for (final candidate in candidates) {
    if (Directory(candidate).existsSync()) {
      return candidate;
    }
  }

  return null;
}

String _resolveToolsRootDirectory() {
  final appData = Platform.environment['APPDATA'];
  if (appData != null && appData.trim().isNotEmpty) {
    return path.join(appData, 'ZapTweaks', 'Tools');
  }

  final userProfile = Platform.environment['USERPROFILE'];
  if (userProfile != null && userProfile.trim().isNotEmpty) {
    return path.join(userProfile, 'AppData', 'Roaming', 'ZapTweaks', 'Tools');
  }

  return path.join(Directory.current.path, 'ZapTweaksTools');
}

Future<String> _deployResourceFileToTools(List<String> relativeSegments) async {
  _validateRelativeSegments(relativeSegments);

  final sourcePath = resolveResourceFilePath(relativeSegments);
  if (sourcePath == null) {
    throw Exception(
      'Missing executable: ${_resourceRelativePath(relativeSegments)}',
    );
  }

  final toolsRoot = _resolveToolsRootDirectory();
  final targetPath = path.joinAll(<String>[toolsRoot, ...relativeSegments]);

  try {
    await Directory(path.dirname(targetPath)).create(recursive: true);
    await File(sourcePath).copy(targetPath);
  } on FileSystemException catch (e) {
    throw Exception(
      'Unable to copy ${_resourceRelativePath(relativeSegments)} to %APPDATA% tools folder (${e.message}).',
    );
  }

  return targetPath;
}

Future<String> _deployResourceDirectoryToTools(
  List<String> relativeSegments,
) async {
  _validateRelativeSegments(relativeSegments);

  final sourceDirectoryPath = resolveResourceDirectoryPath(relativeSegments);
  if (sourceDirectoryPath == null) {
    throw Exception(
      'Missing folder: ${_resourceRelativePath(relativeSegments)}',
    );
  }

  final toolsRoot = _resolveToolsRootDirectory();
  final targetDirectoryPath = path.joinAll(<String>[
    toolsRoot,
    ...relativeSegments,
  ]);

  final sourceDirectory = Directory(sourceDirectoryPath);
  final targetDirectory = Directory(targetDirectoryPath);

  try {
    if (targetDirectory.existsSync()) {
      await targetDirectory.delete(recursive: true);
    }

    await targetDirectory.create(recursive: true);
    await _copyDirectoryContents(sourceDirectory, targetDirectory);
  } on FileSystemException catch (e) {
    throw Exception(
      'Unable to prepare ${_resourceRelativePath(relativeSegments)} in %APPDATA% tools folder (${e.message}).',
    );
  }

  return targetDirectoryPath;
}

Future<void> _copyDirectoryContents(Directory source, Directory target) async {
  await for (final entity in source.list(
    recursive: false,
    followLinks: false,
  )) {
    final childTargetPath = path.join(target.path, path.basename(entity.path));

    if (entity is File) {
      await entity.copy(childTargetPath);
    } else if (entity is Directory) {
      final targetSubdirectory = Directory(childTargetPath);
      await targetSubdirectory.create(recursive: true);
      await _copyDirectoryContents(entity, targetSubdirectory);
    }
  }
}

class ExecutableLauncherTweak extends ActionSystemTweak {
  ExecutableLauncherTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.executableSegments,
    this.arguments = const <String>[],
    super.actionLabel = 'Open',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.launcher);

  final List<String> executableSegments;
  final List<String> arguments;

  @override
  Future<void> onApply() async {
    try {
      final sourceExecutablePath = resolveResourceFilePath(executableSegments);
      if (sourceExecutablePath == null) {
        throw Exception(
          'Missing executable: ${_resourceRelativePath(executableSegments)}',
        );
      }

      final executablePath = ProcessRunner.shared.isDryRun
          ? sourceExecutablePath
          : await _deployResourceFileToTools(executableSegments);

      final launchResult = await ProcessRunner.shared.launch(
        executablePath,
        arguments,
      );
      if (!launchResult.success) {
        throw Exception(launchResult.details);
      }
    } catch (e) {
      throw Exception('Failed to launch executable (${e.toString()}).');
    }
  }
}

class DirectoryLauncherTweak extends ActionSystemTweak {
  DirectoryLauncherTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.directorySegments,
    this.launchExecutableRelativePath,
    super.actionLabel = 'Open',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.launcher);

  final List<String> directorySegments;
  final String? launchExecutableRelativePath;

  @override
  Future<void> onApply() async {
    _validateRelativeSegments(directorySegments);

    final sourceDirectoryPath = resolveResourceDirectoryPath(directorySegments);
    if (sourceDirectoryPath == null) {
      throw Exception(
        'Missing folder: ${_resourceRelativePath(directorySegments)}. '
        'Place the required files in resources\\${path.joinAll(directorySegments)}.',
      );
    }

    final launchDirectoryPath = ProcessRunner.shared.isDryRun
        ? sourceDirectoryPath
        : await _deployResourceDirectoryToTools(directorySegments);

    String? executableToLaunch;
    if (launchExecutableRelativePath != null &&
        launchExecutableRelativePath!.trim().isNotEmpty) {
      final normalizedRelativeExecutable = path.normalize(
        launchExecutableRelativePath!,
      );

      if (normalizedRelativeExecutable.contains('..') ||
          path.isAbsolute(normalizedRelativeExecutable)) {
        throw Exception('Invalid launcher executable relative path.');
      }

      final candidate = path.join(
        launchDirectoryPath,
        normalizedRelativeExecutable,
      );
      if (File(candidate).existsSync()) {
        executableToLaunch = candidate;
      } else {
        throw Exception(
          'Missing executable: ${path.join(_resourceRelativePath(directorySegments), normalizedRelativeExecutable)}',
        );
      }
    }

    try {
      if (executableToLaunch != null) {
        final launchResult = await ProcessRunner.shared.launch(
          executableToLaunch,
          const <String>[],
        );
        if (!launchResult.success) {
          throw Exception(launchResult.details);
        }
        return;
      }

      final explorerResult = await ProcessRunner.shared.launch(
        'explorer',
        <String>[launchDirectoryPath],
      );
      if (!explorerResult.success) {
        throw Exception(explorerResult.details);
      }
    } catch (e) {
      throw Exception('Failed to launch directory tool (${e.toString()}).');
    }
  }
}

class ScriptInteractiveTweak extends ActionSystemTweak {
  ScriptInteractiveTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.scriptSegments,
    super.actionLabel = 'Run Script',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.interactiveScript);

  final List<String> scriptSegments;

  @override
  Future<void> onApply() async {
    _validateRelativeSegments(scriptSegments);

    final scriptPath = resolveResourceFilePath(scriptSegments);
    if (scriptPath == null) {
      throw Exception(
        'Missing script: ${_resourceRelativePath(scriptSegments)}',
      );
    }

    final launchResult = await ProcessRunner.shared.launch(
      'powershell',
      <String>['-NoExit', '-ExecutionPolicy', 'Bypass', '-File', scriptPath],
    );

    if (!launchResult.success) {
      throw Exception(
        'Failed to launch interactive script (${launchResult.details}).',
      );
    }
  }
}

class ExternalUrlLauncherTweak extends ActionSystemTweak {
  ExternalUrlLauncherTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.url,
    super.actionLabel = 'Open',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.launcher);

  final String url;

  @override
  Future<void> onApply() async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('Invalid URL: $url');
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw Exception('Unable to open URL: $url');
    }
  }
}

class PowerShellCommandTweak extends ActionSystemTweak {
  PowerShellCommandTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.command,
    super.actionLabel = 'Run',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.interactiveScript);

  final String command;

  @override
  Future<void> onApply() async {
    final result = await ProcessRunner.shared.run('powershell', <String>[
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      command,
    ], timeout: const Duration(minutes: 3));

    if (!result.success) {
      throw Exception('Failed to execute command (${result.details}).');
    }
  }
}

class PowerShellTerminalCommandTweak extends ActionSystemTweak {
  PowerShellTerminalCommandTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.command,
    this.elevated = true,
    super.actionLabel = 'Run',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.interactiveScript);

  final String command;
  final bool elevated;

  @override
  Future<void> onApply() async {
    final escapedCommand = command.replaceAll("'", "''");
    final elevateFlag = elevated ? '-Verb RunAs ' : '';
    final startProcessCommand =
        'Start-Process -FilePath powershell $elevateFlag-ArgumentList @('
        "'-NoExit','-ExecutionPolicy','Bypass','-Command','"
        '$escapedCommand'
        "')";

    final result = await ProcessRunner.shared.run('powershell', <String>[
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      startProcessCommand,
    ]);

    if (!result.success) {
      throw Exception(
        'Failed to open PowerShell command window (${result.details}).',
      );
    }
  }
}

class BatchScriptTweak extends ActionSystemTweak {
  BatchScriptTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.batchSegments,
    this.arguments = const <String>[],
    super.actionLabel = 'Run Script',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.launcher);

  final List<String> batchSegments;
  final List<String> arguments;

  @override
  Future<void> onApply() async {
    _validateRelativeSegments(batchSegments);

    final sourceBatchPath = resolveResourceFilePath(batchSegments);
    if (sourceBatchPath == null) {
      throw Exception(
        'Missing script: ${_resourceRelativePath(batchSegments)}',
      );
    }

    final batchPath = ProcessRunner.shared.isDryRun
        ? sourceBatchPath
        : await _deployResourceFileToTools(batchSegments);

    final result = await ProcessRunner.shared.run('cmd', <String>[
      '/c',
      batchPath,
      ...arguments,
    ], timeout: const Duration(minutes: 5));

    if (!result.success) {
      throw Exception('Batch execution failed (${result.details}).');
    }
  }
}

class ExplorerSelectFileTweak extends ActionSystemTweak {
  ExplorerSelectFileTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.fileSegments,
    super.actionLabel = 'Show File',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.launcher);

  final List<String> fileSegments;

  @override
  Future<void> onApply() async {
    _validateRelativeSegments(fileSegments);

    final filePath = resolveResourceFilePath(fileSegments);
    if (filePath == null) {
      throw Exception('Missing file: ${_resourceRelativePath(fileSegments)}');
    }

    final result = await ProcessRunner.shared.launch('explorer', <String>[
      '/select,$filePath',
    ]);

    if (!result.success) {
      throw Exception('Unable to open file in Explorer (${result.details}).');
    }
  }
}

class RegistryImportTweak extends ActionSystemTweak {
  RegistryImportTweak({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required this.registrySegments,
    super.actionLabel = 'Import',
    super.isAggressive,
    super.warningMessage,
  }) : super(type: TweakUiType.launcher);

  final List<String> registrySegments;

  @override
  Future<void> onApply() async {
    _validateRelativeSegments(registrySegments);

    final sourceRegPath = resolveResourceFilePath(registrySegments);
    if (sourceRegPath == null) {
      throw Exception(
        'Missing registry file: ${_resourceRelativePath(registrySegments)}',
      );
    }

    final regPath = ProcessRunner.shared.isDryRun
        ? sourceRegPath
        : await _deployResourceFileToTools(registrySegments);

    final result = await ProcessRunner.shared.run('reg', <String>[
      'import',
      regPath,
    ], timeout: const Duration(minutes: 2));

    if (!result.success) {
      throw Exception('Registry import failed (${result.details}).');
    }
  }
}
