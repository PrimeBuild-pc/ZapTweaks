import '../../../core/services/process_runner.dart';
import '../domain/store_app.dart';
import 'windows_app_inventory_service.dart';

class AppUninstallPreview {
  const AppUninstallPreview._(this.apps);

  final List<StoreApp> apps;
}

class AppBatchResult {
  const AppBatchResult({required this.succeeded, required this.failed});

  final List<StoreApp> succeeded;
  final Map<StoreApp, String> failed;

  bool get success => failed.isEmpty;
}

class AppStoreService {
  AppStoreService({required ProcessRunner processRunner})
    : _runner = processRunner,
      _inventory = WindowsAppInventoryService(processRunner: processRunner);

  final ProcessRunner _runner;
  final WindowsAppInventoryService _inventory;

  Future<Set<String>> installedWingetIds() async {
    final result = await _inventory.scanWinget();
    if (!result.wingetComplete) {
      throw StateError(result.message ?? 'Unable to read installed apps.');
    }
    return result.packages
        .map((package) => package.packageId.toLowerCase())
        .toSet();
  }

  Future<void> install(StoreApp app) async {
    final id = app.wingetId;
    if (id == null) throw StateError('This app has no verified winget ID.');
    final result = await _runner.run('winget', <String>[
      'install',
      '--exact',
      '--id',
      id,
      '--accept-source-agreements',
      '--accept-package-agreements',
      '--disable-interactivity',
    ]);
    if (!result.success) throw StateError(result.details);
    if (!(await installedWingetIds()).contains(id.toLowerCase())) {
      throw StateError('winget completed but the package was not detected.');
    }
  }

  AppUninstallPreview previewUninstall(
    Iterable<StoreApp> apps,
    Set<String> installedIds,
  ) => AppUninstallPreview._(
    apps
        .where(
          (app) =>
              app.wingetId != null &&
              installedIds.contains(app.wingetId!.toLowerCase()),
        )
        .toList(growable: false),
  );

  Future<AppBatchResult> uninstall(AppUninstallPreview preview) async {
    final succeeded = <StoreApp>[];
    final failed = <StoreApp, String>{};
    for (final app in preview.apps) {
      final result = await _runner.run('winget', <String>[
        'uninstall',
        '--exact',
        '--id',
        app.wingetId!,
        '--disable-interactivity',
      ]);
      if (result.success) {
        succeeded.add(app);
      } else {
        failed[app] = result.details;
      }
    }
    if (succeeded.isNotEmpty) {
      final remaining = await installedWingetIds();
      for (final app in List<StoreApp>.from(succeeded)) {
        if (remaining.contains(app.wingetId!.toLowerCase())) {
          succeeded.remove(app);
          failed[app] = 'winget completed but the package is still installed.';
        }
      }
    }
    return AppBatchResult(succeeded: succeeded, failed: failed);
  }

  Future<void> openSource(StoreApp app) async {
    final url = app.url;
    if (url == null || url.scheme != 'https') {
      throw StateError('No verified HTTPS source is available.');
    }
    final result = await _runner.launch('explorer', <String>[url.toString()]);
    if (!result.success) throw StateError(result.details);
  }
}
