import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../application/app_store_catalog.dart';
import '../application/app_store_service.dart';
import '../../tweaks/application/tweak_controller.dart';
import '../domain/store_app.dart';

class AppStorePage extends StatefulWidget {
  const AppStorePage({required this.controller, super.key});

  final TweakController controller;

  @override
  State<AppStorePage> createState() => _AppStorePageState();
}

class _AppStorePageState extends State<AppStorePage> {
  late final AppStoreService _service;
  List<StoreApp> _apps = const <StoreApp>[];
  Set<String> _installed = const <String>{};
  final _selected = <String>{};
  String _query = '';
  String? _category;
  bool _installedOnly = false;
  bool _loading = true;
  String? _message;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _service = AppStoreService(processRunner: ProcessRunner.shared);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final catalog = await AppStoreCatalog.load();
      Set<String> installed;
      var inventoryUnavailable = false;
      try {
        installed = await _service.installedWingetIds();
      } catch (_) {
        installed = const <String>{};
        inventoryUnavailable = true;
      }
      if (!mounted) return;
      setState(() {
        _apps = catalog.apps;
        _installed = installed;
        if (inventoryUnavailable) {
          _message = AppLocalizations.of(context).appInventoryUnavailable;
        }
        _selected.removeWhere(
          (id) => !_installed.contains(
            _apps.firstWhere((app) => app.id == id).wingetId?.toLowerCase(),
          ),
        );
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = error.toString();
        _loading = false;
      });
    }
  }

  List<StoreApp> get _visible {
    final query = _query.trim().toLowerCase();
    return _apps
        .where((app) {
          final installed =
              app.wingetId != null &&
              _installed.contains(app.wingetId!.toLowerCase());
          return (_category == null || app.category == _category) &&
              (!_installedOnly || installed) &&
              (query.isEmpty ||
                  app.name.toLowerCase().contains(query) ||
                  (app.wingetId?.toLowerCase().contains(query) ?? false) ||
                  app.author.toLowerCase().contains(query));
        })
        .toList(growable: false);
  }

  Future<void> _install(StoreApp app) async {
    setState(() => _busyId = app.id);
    try {
      if (app.wingetId == null) {
        await _service.openSource(app);
      } else {
        final plan = await widget.controller
            .executeNativeRequests(<OperationRequest>[
              OperationRequest(
                operationId: 'app.winget.set',
                target: app.wingetId,
                desiredValue: true,
              ),
            ]);
        if (plan.status != PlanStatus.completed) {
          throw StateError(plan.items.single.error ?? 'Installation failed.');
        }
        _installed = await _service.installedWingetIds();
      }
      _message = null;
    } catch (error) {
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _uninstallSelected() async {
    final apps = _apps.where((app) => _selected.contains(app.id));
    final preview = _service.previewUninstall(apps, _installed);
    if (preview.apps.isEmpty) return;
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.confirmBulkUninstall),
        content: Text(
          strings.confirmBulkUninstallMessage(
            preview.apps.map((app) => '• ${app.name}').join('\n'),
          ),
        ),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.uninstall),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busyId = 'bulk');
    try {
      final plan = await widget.controller
          .executeNativeRequests(<OperationRequest>[
            for (final app in preview.apps)
              OperationRequest(
                operationId: 'app.winget.set',
                target: app.wingetId,
                desiredValue: false,
              ),
          ]);
      if (plan.status != PlanStatus.completed) {
        _message = plan.items
            .where((item) => item.error != null)
            .map((item) => '${item.request.target}: ${item.error}')
            .join('\n');
      } else {
        _message = null;
      }
      _installed = await _service.installedWingetIds();
      _selected.clear();
    } catch (error) {
      _message = error.toString();
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final categories = _apps.map((app) => app.category).toSet().toList()
      ..sort();
    final visible = _visible;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(strings.appCatalogSources),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 300,
                child: TextBox(
                  placeholder: strings.searchApps,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              SizedBox(
                width: 220,
                child: ComboBox<String?>(
                  value: _category,
                  isExpanded: true,
                  items: <ComboBoxItem<String?>>[
                    ComboBoxItem<String?>(
                      value: null,
                      child: Text(strings.allCategories),
                    ),
                    for (final category in categories)
                      ComboBoxItem<String?>(
                        value: category,
                        child: Text(category),
                      ),
                  ],
                  onChanged: (value) => setState(() => _category = value),
                ),
              ),
              Checkbox(
                checked: _installedOnly,
                content: Text(strings.installedOnly),
                onChanged: (value) =>
                    setState(() => _installedOnly = value ?? false),
              ),
              Button(
                onPressed: _loading ? null : _load,
                child: Text(strings.refreshInventory),
              ),
              FilledButton(
                onPressed: _selected.isEmpty || _busyId != null
                    ? null
                    : _uninstallSelected,
                child: Text(
                  '${strings.uninstallSelected} (${_selected.length})',
                ),
              ),
            ],
          ),
          if (_message != null) ...<Widget>[
            const SizedBox(height: 12),
            InfoBar(
              title: Text(strings.operationFailed),
              content: Text(_message!),
              severity: InfoBarSeverity.error,
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: ProgressRing())
                : ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final app = visible[index];
                      final installed =
                          app.wingetId != null &&
                          _installed.contains(app.wingetId!.toLowerCase());
                      final busy = _busyId == app.id;
                      return Semantics(
                        label: '${app.name}, ${app.attribution}',
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                checked: _selected.contains(app.id),
                                onChanged: installed && _busyId == null
                                    ? (value) => setState(() {
                                        if (value == true) {
                                          _selected.add(app.id);
                                        } else {
                                          _selected.remove(app.id);
                                        }
                                      })
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      app.name,
                                      style: FluentTheme.of(
                                        context,
                                      ).typography.bodyStrong,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${app.attribution} · ${app.category}${app.wingetId == null ? '' : ' · ${app.wingetId}'}',
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                installed
                                    ? strings.installed
                                    : strings.notInstalled,
                              ),
                              const SizedBox(width: 12),
                              if (busy)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: ProgressRing(),
                                )
                              else
                                Button(
                                  onPressed: _busyId == null && !installed
                                      ? () => _install(app)
                                      : null,
                                  child: Text(
                                    app.wingetId == null
                                        ? strings.openOfficialPage
                                        : strings.install,
                                  ),
                                ),
                            ],
                          ),
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
