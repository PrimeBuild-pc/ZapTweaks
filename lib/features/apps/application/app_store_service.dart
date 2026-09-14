import '../../../core/services/process_runner.dart';
import '../domain/store_app.dart';
import 'windows_app_inventory_service.dart';

class AppUninstallPreview {
  const AppUninstallPreview._(this.apps);

  final List<StoreApp> apps;
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

  Future<void> openSource(StoreApp app) async {
    final url = app.url;
    if (url == null || url.scheme != 'https') {
      throw StateError('No verified HTTPS source is available.');
    }
    final result = await _runner.launch('explorer', <String>[url.toString()]);
    if (!result.success) throw StateError(result.details);
  }
}
