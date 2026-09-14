import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/security/elevated_helper.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../application/windows_app_inventory_service.dart';
import '../domain/app_package.dart';

class AppInventoryPage extends StatefulWidget {
  const AppInventoryPage({super.key});

  @override
  State<AppInventoryPage> createState() => _AppInventoryPageState();
}

class _AppInventoryPageState extends State<AppInventoryPage> {
  late final WindowsAppInventoryService _inventory;
  late final ElevatedHelperClient _helper;
  List<AppPackage> _packages = const <AppPackage>[];
  bool _loading = true;
  bool _systemScopesComplete = false;
  String _query = '';
  String? _message;

  @override
  void initState() {
    super.initState();
    _inventory = WindowsAppInventoryService(
      processRunner: ProcessRunner.shared,
    );
    _helper = ElevatedHelperClient(directory: defaultElevatedHelperDirectory());
    _scanLocal();
  }

  Future<void> _scanLocal() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    final results = await Future.wait(<Future<AppInventoryResult>>[
      _inventory.scanCurrentUser(),
      _inventory.scanWinget(),
    ]);
    if (!mounted) return;
    setState(() {
      _packages = _merge(results.expand((result) => result.packages));
      _message = results
          .map((result) => result.message)
          .whereType<String>()
          .join('\n');
      if (_message!.isEmpty) _message = null;
      _systemScopesComplete = false;
      _loading = false;
    });
  }

  Future<void> _scanSystemScopes() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final result = await _helper.scanSystemApps();
      if (!mounted) return;
      setState(() {
        _packages = _merge(<AppPackage>[..._packages, ...result.packages]);
        _systemScopesComplete =
            result.allUsersComplete && result.provisionedComplete;
      });
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static List<AppPackage> _merge(Iterable<AppPackage> packages) {
    final merged = <String, AppPackage>{};
    for (final package in packages) {
      final key = '${package.provider.name}:${package.packageId.toLowerCase()}';
      final previous = merged[key];
      merged[key] = AppPackage(
        provider: package.provider,
        packageId: package.packageId,
        name: package.name,
        version: package.version ?? previous?.version,
        publisher: package.publisher ?? previous?.publisher,
        scopes: <AppInstallScope>{...?previous?.scopes, ...package.scopes},
        source: package.source,
        reinstallable: package.reinstallable || previous?.reinstallable == true,
      );
    }
    return merged.values.toList(growable: false)
      ..sort((left, right) => left.name.compareTo(right.name));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final query = _query.trim().toLowerCase();
    final packages = _packages
        .where(
          (package) =>
              query.isEmpty ||
              package.name.toLowerCase().contains(query) ||
              package.packageId.toLowerCase().contains(query) ||
              (package.publisher?.toLowerCase().contains(query) ?? false),
        )
        .toList(growable: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              SizedBox(
                width: 320,
                child: TextBox(
                  placeholder: strings.searchInstalledApps,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Button(
                onPressed: _loading ? null : _scanLocal,
                child: Text(strings.refreshInventory),
              ),
              FilledButton(
                onPressed: _loading ? null : _scanSystemScopes,
                child: Text(strings.scanAllUsers),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _systemScopesComplete
                ? strings.systemScopesComplete
                : strings.systemScopesIncomplete,
          ),
          if (_message != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: Text(strings.operationFailed),
              content: Text(_message!),
              severity: InfoBarSeverity.error,
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: _loading
                ? const Center(child: ProgressRing())
                : ListView.separated(
                    itemCount: packages.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final package = packages[index];
                      final scopes = package.scopes
                          .map(
                            (scope) => switch (scope) {
                              AppInstallScope.currentUser =>
                                strings.currentUser,
                              AppInstallScope.allUsers => strings.allUsers,
                              AppInstallScope.provisioned =>
                                strings.provisioned,
                            },
                          )
                          .join(', ');
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              package.name,
                              style: FluentTheme.of(
                                context,
                              ).typography.bodyStrong,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${package.packageId} · ${package.provider.name} · $scopes',
                            ),
                            if (package.publisher != null)
                              Text(package.publisher!),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
