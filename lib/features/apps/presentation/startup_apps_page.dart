import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../application/windows_startup_inventory_service.dart';
import '../domain/startup_app.dart';

class StartupAppsPage extends StatefulWidget {
  const StartupAppsPage({super.key});

  @override
  State<StartupAppsPage> createState() => _StartupAppsPageState();
}

class _StartupAppsPageState extends State<StartupAppsPage> {
  late final WindowsStartupInventoryService _inventory;
  List<StartupApp> _apps = const <StartupApp>[];
  String _query = '';
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _inventory = WindowsStartupInventoryService(
      processRunner: ProcessRunner.shared,
    );
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final apps = await _inventory.scan();
      if (mounted) setState(() => _apps = apps);
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _open(String executable, List<String> arguments) async {
    final result = await ProcessRunner.shared.launch(executable, arguments);
    if (!result.success && mounted) {
      setState(() => _message = result.details);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final query = _query.trim().toLowerCase();
    final apps = _apps
        .where(
          (app) =>
              query.isEmpty ||
              app.name.toLowerCase().contains(query) ||
              app.location.toLowerCase().contains(query) ||
              app.user.toLowerCase().contains(query),
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
                  placeholder: strings.searchStartupApps,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Button(
                onPressed: _loading ? null : _scan,
                child: Text(strings.refreshInventory),
              ),
              Button(
                onPressed: () =>
                    _open('explorer', <String>['ms-settings:startupapps']),
                child: Text(strings.openStartupSettings),
              ),
              Button(
                onPressed: () =>
                    _open('taskmgr', const <String>['/0', '/startup']),
                child: Text(strings.openTaskManagerStartup),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(strings.startupInventoryNotice),
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
                    itemCount: apps.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
                            SelectableText(app.command),
                            Text('${app.location} · ${app.user}'),
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
