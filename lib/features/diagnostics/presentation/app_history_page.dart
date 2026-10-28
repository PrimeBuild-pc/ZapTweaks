import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/security/elevated_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/srum_history_service.dart';

/// Per-app network, CPU and disk use of the last 30 days, from the System Resource Usage Monitor (read-only).
class AppHistoryPage extends StatefulWidget {
  const AppHistoryPage({this.load, super.key});

  /// Defaults to the elevated helper; tests pass a fake.
  final Future<SrumHistory> Function()? load;

  @override
  State<AppHistoryPage> createState() => _AppHistoryPageState();
}

String formatBytes(int bytes) {
  const units = <String>['B', 'KB', 'MB', 'GB', 'TB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  return '${value.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
}

class _AppHistoryPageState extends State<AppHistoryPage> {
  bool _busy = false;
  String? _error;
  SrumHistory? _history;

  Future<void> _read() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final history =
          await (widget.load ??
              ElevatedHelperClient(
                directory: defaultElevatedHelperDirectory(),
              ).scanSrumHistory)();
      if (mounted) setState(() => _history = history);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ISO date: unambiguous in every language, no extra dependency.
  String _date(DateTime? time) =>
      time == null ? '–' : time.toLocal().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    final history = _history;
    final network = history == null
        ? <SrumAppUsage>[]
        : (history.apps.where((app) => app.networkBytes > 0).toList()
                ..sort((a, b) => b.networkBytes.compareTo(a.networkBytes)))
              .take(15)
              .toList();
    final cpu = history == null
        ? <SrumAppUsage>[]
        : (history.apps.where((app) => app.cycles > 0).toList()
                ..sort((a, b) => b.cycles.compareTo(a.cycles)))
              .take(15)
              .toList();
    String name(SrumAppUsage app) =>
        app.attributed ? app.name : strings.srumUnattributed;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(strings.srumTitle, style: theme.typography.subtitle),
                const SizedBox(height: 6),
                Text(strings.srumDescription),
                const SizedBox(height: 16),
                _busy
                    ? const ProgressRing()
                    : FilledButton(
                        onPressed: _read,
                        child: Text(strings.srumRead),
                      ),
              ],
            ),
          ),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: 12),
          InfoBar(
            title: Text(strings.operationFailed),
            content: Text(_error!),
            severity: InfoBarSeverity.error,
          ),
        ],
        if (history != null) ...<Widget>[
          if (!history.collecting) ...<Widget>[
            const SizedBox(height: 12),
            InfoBar(
              title: Text(strings.srumNotCollectingTitle),
              content: Text(
                strings.srumNotCollecting(
                  history.serviceStatus.isEmpty ? '–' : history.serviceStatus,
                  history.serviceStartType.isEmpty
                      ? '–'
                      : history.serviceStartType,
                  _date(history.lastRecord),
                ),
              ),
              severity: InfoBarSeverity.warning,
            ),
          ],
          const SizedBox(height: 12),
          if (history.apps.isEmpty)
            Text(strings.srumNoData)
          else ...<Widget>[
            _section(strings.srumNetwork, <Widget>[
              for (final app in network)
                _row(
                  name(app),
                  app.path,
                  '↑ ${formatBytes(app.bytesSent)}   ↓ ${formatBytes(app.bytesReceived)}',
                ),
            ]),
            const SizedBox(height: 12),
            _section(strings.srumCpu, <Widget>[
              for (final app in cpu)
                _row(
                  name(app),
                  app.path,
                  strings.srumCpuShare(
                    (100 * app.cycles / history.totalCycles).toStringAsFixed(1),
                    app.cycles == 0
                        ? '0'
                        : (100 * app.backgroundCycles / app.cycles)
                              .toStringAsFixed(0),
                  ),
                ),
            ]),
          ],
          const SizedBox(height: 8),
          Text(
            strings.srumSource(
              _date(history.firstRecord),
              _date(history.lastRecord),
            ),
            style: theme.typography.caption,
          ),
        ],
      ],
    );
  }

  Widget _section(String title, List<Widget> rows) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: FluentTheme.of(context).typography.bodyStrong),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    ),
  );

  Widget _row(String name, String path, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Tooltip(message: path, child: Text(name)),
        ),
        const SizedBox(width: 12),
        Text(value),
      ],
    ),
  );
}
