import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/hardware_capability_validators.dart';
import '../../../platform/windows/network_diagnostics_service.dart';
import '../../../platform/windows/rss_service.dart';
import '../../../platform/windows/tcp_optimizer_service.dart';
import '../../tweaks/application/tweak_controller.dart';

class TcpOptimizerPage extends StatefulWidget {
  const TcpOptimizerPage({required this.controller, super.key});

  final TweakController controller;

  @override
  State<TcpOptimizerPage> createState() => _TcpOptimizerPageState();
}

class _TcpOptimizerPageState extends State<TcpOptimizerPage> {
  late final WindowsTcpOptimizerService _tcp = WindowsTcpOptimizerService();
  late final WindowsQosPolicyService _qos = WindowsQosPolicyService();
  late final WindowsRssService _rss = WindowsRssService();
  late final NetworkDiagnosticsService _diagnostics =
      NetworkDiagnosticsService();
  final TextEditingController _endpoint = TextEditingController();
  List<TcpSettingState> _settings = const <TcpSettingState>[];
  List<QosPolicy> _policies = const <QosPolicy>[];
  List<RssAdapterState> _rssAdapters = const <RssAdapterState>[];
  final Map<String, RssConfiguration> _lastEnabledRss =
      <String, RssConfiguration>{};
  NetworkDiagnosticResult? _baseline;
  NetworkDiagnosticResult? _comparison;
  bool _loading = true;
  bool _measuring = false;
  String? _busy;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _diagnostics.cancel();
    _endpoint.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final errors = <String>[];
    var settings = const <TcpSettingState>[];
    var policies = const <QosPolicy>[];
    var adapters = const <RssAdapterState>[];
    try {
      settings = await _tcp.inventory();
    } catch (error) {
      errors.add(error.toString());
    }
    try {
      policies = await _qos.inventory();
    } catch (error) {
      errors.add(error.toString());
    }
    try {
      final names = await _rss.adapterNames();
      adapters = await Future.wait(names.map(_rss.inspect));
    } catch (error) {
      errors.add(error.toString());
    }
    for (final adapter in adapters) {
      if (adapter.configuration.enabled) {
        _lastEnabledRss[adapter.name] = adapter.configuration;
      }
    }
    if (mounted) {
      setState(() {
        _settings = settings;
        _policies = policies;
        _rssAdapters = adapters;
        _message = errors.isEmpty ? null : errors.join('\n');
        _loading = false;
      });
    }
  }

  Future<void> _configureTcp(TcpSettingState setting) async {
    final strings = AppLocalizations.of(context);
    var value = setting.value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          title: Text(strings.tcpChangePreview),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${setting.template} · ${_fieldName(strings, setting.field)}',
              ),
              const SizedBox(height: 10),
              Text('${strings.tcpCurrentValue}: ${setting.value}'),
              const SizedBox(height: 8),
              Text(strings.tcpNewValue),
              ComboBox<String>(
                value: value,
                isExpanded: true,
                items: setting.supportedValues
                    .map(
                      (item) =>
                          ComboBoxItem<String>(value: item, child: Text(item)),
                    )
                    .toList(growable: false),
                onChanged: (next) =>
                    setDialogState(() => value = next ?? value),
              ),
              const SizedBox(height: 12),
              InfoBar(
                title: Text(strings.tcpExactRollbackNotice),
                severity: InfoBarSeverity.warning,
              ),
            ],
          ),
          actions: <Widget>[
            Button(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: value == setting.value
                  ? null
                  : () => Navigator.pop(context, true),
              child: Text(strings.apply),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    await _execute(
      OperationRequest(
        operationId: 'network.tcp.setting.configure',
        target: setting.target,
        desiredValue: value,
      ),
    );
  }

  Future<void> _showAdapterRss() async {
    final strings = AppLocalizations.of(context);
    final selected = await showDialog<RssAdapterState>(
      context: context,
      builder: (context) => ContentDialog(
        constraints: const BoxConstraints(maxWidth: 640),
        title: Text(strings.rssAdapterState),
        content: SizedBox(
          height: 360,
          child: ListView(
            children: _rssAdapters
                .map(
                  (adapter) => ListTile(
                    title: Text(adapter.name),
                    subtitle: Text(
                      '${strings.rssEnabled}: ${adapter.configuration.enabled} · '
                      '${strings.rssProfile}: ${adapter.configuration.profile} · '
                      '${strings.rssQueuesProcessors}: '
                      '${adapter.configuration.queueCount}/${adapter.configuration.processorCount}',
                    ),
                    trailing: Button(
                      onPressed: () => Navigator.pop(context, adapter),
                      child: Text(strings.tcpConfigure),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
    if (selected != null) await _configureRss(selected);
  }

  Future<void> _configureRss(RssAdapterState adapter) async {
    final strings = AppLocalizations.of(context);
    final current = adapter.configuration;
    final editable = current.enabled ? current : _lastEnabledRss[adapter.name];
    var enabled = current.enabled;
    var profile = editable?.profile ?? current.profile;
    final profiles = <String>{
      current.profile,
      'Closest',
      'ClosestStatic',
      'NUMA',
      'NUMAStatic',
      'Conservative',
    }.toList(growable: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          title: Text(adapter.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                checked: enabled,
                content: Text(strings.rssEnabled),
                onChanged: editable == null
                    ? null
                    : (value) =>
                          setDialogState(() => enabled = value ?? enabled),
              ),
              const SizedBox(height: 8),
              Text(strings.rssProfile),
              ComboBox<String>(
                value: profile,
                isExpanded: true,
                items: profiles
                    .map(
                      (value) => ComboBoxItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(growable: false),
                onChanged: editable == null
                    ? null
                    : (value) =>
                          setDialogState(() => profile = value ?? profile),
              ),
              const SizedBox(height: 12),
              InfoBar(
                title: Text(strings.tcpExactRollbackNotice),
                severity: InfoBarSeverity.warning,
              ),
            ],
          ),
          actions: <Widget>[
            Button(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed:
                  editable == null ||
                      (enabled == current.enabled && profile == current.profile)
                  ? null
                  : () => Navigator.pop(context, true),
              child: Text(strings.apply),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    await _execute(
      OperationRequest(
        operationId: 'network.rss.configure',
        target: adapter.name,
        desiredValue: <String, Object?>{
          'enabled': enabled,
          'profile': profile,
          'baseGroup': editable!.baseProcessor.group,
          'baseNumber': editable.baseProcessor.number,
          'maxGroup': editable.maximumProcessor.group,
          'maxNumber': editable.maximumProcessor.number,
          'processorCount': editable.processorCount,
          'queueCount': editable.queueCount,
          'processorArray': editable.processorArray
              .map(
                (processor) => <String, int>{
                  'group': processor.group,
                  'number': processor.number,
                },
              )
              .toList(growable: false),
        },
      ),
    );
  }

  Future<void> _editQos([QosPolicy? existing]) async {
    final strings = AppLocalizations.of(context);
    final name = TextEditingController(
      text: existing?.name ?? QosPolicy.ownedPrefix,
    );
    final app = TextEditingController(text: existing?.appPath ?? '');
    final source = TextEditingController(
      text: existing?.sourcePort?.toString() ?? '',
    );
    final destination = TextEditingController(
      text: existing?.destinationPort?.toString() ?? '',
    );
    final dscp = TextEditingController(text: existing?.dscp?.toString() ?? '');
    final throttle = TextEditingController(
      text: existing?.throttleBitsPerSecond == null
          ? ''
          : (existing!.throttleBitsPerSecond! / 1000000).toString(),
    );
    var protocol = existing?.protocol ?? 'Both';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          constraints: const BoxConstraints(maxWidth: 620),
          title: Text(existing == null ? strings.qosCreate : strings.qosEdit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(strings.qosOwnedOnly),
                const SizedBox(height: 10),
                _field(strings.qosName, name, enabled: existing == null),
                _field(strings.qosAppPath, app),
                Text(strings.qosProtocol),
                ComboBox<String>(
                  value: protocol,
                  isExpanded: true,
                  items: const <String>['TCP', 'UDP', 'Both']
                      .map(
                        (value) => ComboBoxItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) =>
                      setDialogState(() => protocol = value ?? protocol),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(child: _field(strings.qosSourcePort, source)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _field(strings.qosDestinationPort, destination),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(child: _field(strings.qosDscp, dscp)),
                    const SizedBox(width: 8),
                    Expanded(child: _field(strings.qosThrottleMbps, throttle)),
                  ],
                ),
                InfoBar(
                  title: Text(strings.tcpExactRollbackNotice),
                  severity: InfoBarSeverity.warning,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Button(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.apply),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      try {
        int? integer(TextEditingController controller) =>
            controller.text.trim().isEmpty
            ? null
            : int.parse(controller.text.trim());
        final mbps = throttle.text.trim().isEmpty
            ? null
            : double.parse(throttle.text.trim());
        final policy = QosPolicy.validate(<String, dynamic>{
          'name': name.text.trim(),
          'appPath': app.text.trim(),
          'protocol': protocol,
          'sourcePort': integer(source),
          'destinationPort': integer(destination),
          'dscp': integer(dscp),
          'throttleBitsPerSecond': mbps == null
              ? null
              : (mbps * 1000000).round(),
        });
        await _execute(
          OperationRequest(
            operationId: 'network.qos.policy.configure',
            target: policy.name,
            desiredValue: policy.toJson(),
          ),
        );
      } catch (error) {
        if (mounted) setState(() => _message = error.toString());
      }
    }
    for (final controller in <TextEditingController>[
      name,
      app,
      source,
      destination,
      dscp,
      throttle,
    ]) {
      controller.dispose();
    }
  }

  Future<void> _deleteQos(QosPolicy policy) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.qosDelete),
        content: Text('${strings.qosDeleteConfirm}\n\n${policy.name}'),
        actions: <Widget>[
          Button(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.qosDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _execute(
        OperationRequest(
          operationId: 'network.qos.policy.configure',
          target: policy.name,
          desiredValue: null,
        ),
      );
    }
  }

  Future<void> _execute(OperationRequest request) async {
    setState(() {
      _busy = request.target;
      _message = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(
        <OperationRequest>[request],
      );
      if (plan.status != PlanStatus.completed ||
          plan.items.single.status != PlanItemStatus.verified) {
        throw StateError(plan.items.single.error ?? 'Operation failed.');
      }
      await _load();
      if (mounted) {
        setState(
          () => _message = AppLocalizations.of(context).operationCompleted,
        );
      }
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _measure() async {
    Uri endpoint;
    try {
      endpoint = Uri.parse(_endpoint.text.trim());
    } catch (error) {
      setState(() => _message = error.toString());
      return;
    }
    setState(() {
      _measuring = true;
      _message = null;
    });
    try {
      final result = await _diagnostics.measure(endpoint: endpoint);
      if (mounted) {
        setState(() {
          if (_baseline == null) {
            _baseline = result;
          } else {
            _comparison = result;
          }
        });
      }
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _measuring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final globals = _settings
        .where((item) => item.template == 'Global')
        .toList(growable: false);
    final templates = <String, List<TcpSettingState>>{};
    for (final setting in _settings.where(
      (item) => item.template != 'Global',
    )) {
      templates
          .putIfAbsent(setting.template, () => <TcpSettingState>[])
          .add(setting);
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text(
          strings.tcpOptimizer,
          style: FluentTheme.of(context).typography.title,
        ),
        const SizedBox(height: 6),
        Text(strings.tcpOptimizerDescription),
        const SizedBox(height: 12),
        InfoBar(
          title: Text(strings.tcpNoRecommendation),
          severity: InfoBarSeverity.warning,
        ),
        if (_loading) ...<Widget>[
          const SizedBox(height: 12),
          const ProgressBar(),
        ],
        if (_message != null) ...<Widget>[
          const SizedBox(height: 12),
          InfoBar(
            title: Text(_message!),
            severity: _message == strings.operationCompleted
                ? InfoBarSeverity.success
                : InfoBarSeverity.error,
          ),
        ],
        const SizedBox(height: 18),
        _sectionHeader(strings.tcpGlobal),
        ...globals.map((setting) => _settingTile(strings, setting)),
        Button(
          onPressed: _rssAdapters.isEmpty ? null : _showAdapterRss,
          child: Text(strings.tcpAdapterRss),
        ),
        const SizedBox(height: 18),
        _sectionHeader(strings.tcpTemplates),
        ...templates.entries.map(
          (entry) => Expander(
            header: Text(entry.key),
            content: Column(
              children: entry.value
                  .map((setting) => _settingTile(strings, setting))
                  .toList(growable: false),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: <Widget>[
            Expanded(child: _sectionHeader(strings.qosPolicies)),
            FilledButton(
              onPressed: _busy == null ? _editQos : null,
              child: Text(strings.qosCreate),
            ),
          ],
        ),
        Text(strings.qosDescription),
        const SizedBox(height: 8),
        if (_policies.isEmpty) Text(strings.noSearchResults),
        ..._policies.map((policy) => _qosTile(strings, policy)),
        const SizedBox(height: 18),
        _sectionHeader(strings.networkDiagnostics),
        Text(strings.networkDiagnosticsDescription),
        const SizedBox(height: 8),
        InfoBar(title: Text(strings.diagnosticNetworkCost)),
        const SizedBox(height: 8),
        TextBox(
          controller: _endpoint,
          enabled: !_measuring,
          placeholder: strings.diagnosticEndpoint,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            FilledButton(
              onPressed: _measuring ? null : _measure,
              child: Text(
                _baseline == null
                    ? strings.diagnosticBaseline
                    : strings.diagnosticComparison,
              ),
            ),
            Button(
              onPressed: _measuring ? _diagnostics.cancel : null,
              child: Text(strings.diagnosticCancel),
            ),
            Button(
              onPressed: () =>
                  widget.controller.navigateTo('Diagnostics & Recovery'),
              child: Text(strings.openRecoveryHistory),
            ),
          ],
        ),
        if (_measuring) ...<Widget>[
          const SizedBox(height: 8),
          const ProgressBar(),
        ],
        if (_baseline != null) _diagnosticResult(strings, _baseline!, 'A'),
        if (_comparison != null) ...<Widget>[
          _diagnosticResult(strings, _comparison!, 'B'),
          _diagnosticDelta(strings, _baseline!, _comparison!),
        ],
        const SizedBox(height: 18),
        HyperlinkButton(
          onPressed: () => unawaited(
            ProcessRunner.shared.launch('explorer.exe', const <String>[
              'https://github.com/powplowdevs/WINSPAR-Windows-TCP-Optimizer/tree/6392524fcd51925ffe0e082a76facf5b3bb8f322',
            ]),
          ),
          child: Text(strings.tcpAttribution),
        ),
      ],
    );
  }

  Widget _settingTile(AppLocalizations strings, TcpSettingState setting) =>
      Card(
        child: ListTile(
          title: Text(_fieldName(strings, setting.field)),
          subtitle: Text('${setting.template} · ${setting.value}'),
          trailing: Button(
            onPressed: setting.writable && _busy == null
                ? () => _configureTcp(setting)
                : null,
            child: Text(strings.tcpConfigure),
          ),
        ),
      );

  Widget _qosTile(AppLocalizations strings, QosPolicy policy) => Card(
    child: ListTile(
      title: Text(policy.name),
      subtitle: Text(
        '${policy.appPath}\n${policy.protocol} · DSCP ${policy.dscp ?? '—'} · '
        '${policy.throttleBitsPerSecond == null ? '—' : '${policy.throttleBitsPerSecond! / 1000000} Mbit/s'}',
      ),
      trailing: policy.editable
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Button(
                  onPressed: _busy == null ? () => _editQos(policy) : null,
                  child: Text(strings.qosEdit),
                ),
                const SizedBox(width: 6),
                Button(
                  onPressed: _busy == null ? () => _deleteQos(policy) : null,
                  child: Text(strings.qosDelete),
                ),
              ],
            )
          : Text(strings.qosReadOnly),
    ),
  );

  Widget _diagnosticResult(
    AppLocalizations strings,
    NetworkDiagnosticResult result,
    String label,
  ) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '$label · ${result.capturedAt.toLocal()}',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            Text(
              '${strings.diagnosticLatency}: ${_number(result.latencyMs)} ms · '
              '${strings.diagnosticJitter}: ${_number(result.jitterMs)} ms · '
              '${strings.diagnosticPacketLoss}: ${result.packetLossPercent.toStringAsFixed(1)}% · '
              '${strings.diagnosticThroughput}: ${_number(result.throughputMbps)} Mbit/s',
            ),
            SelectableText(
              '${strings.diagnosticEndpoint}: ${result.endpoint}\n'
              '${strings.diagnosticDownloadedBytes}: ${result.downloadedBytes}\n'
              '${strings.diagnosticRawSamples}: '
              '${result.latencySamplesMs.map((value) => value.toStringAsFixed(2)).join(', ')} ms',
            ),
          ],
        ),
      ),
    ),
  );

  Widget _diagnosticDelta(
    AppLocalizations strings,
    NetworkDiagnosticResult before,
    NetworkDiagnosticResult after,
  ) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      '${strings.diagnosticDifference}: '
      '${strings.diagnosticLatency} ${_delta(before.latencyMs, after.latencyMs)} ms · '
      '${strings.diagnosticJitter} ${_delta(before.jitterMs, after.jitterMs)} ms · '
      '${strings.diagnosticPacketLoss} ${_delta(before.packetLossPercent, after.packetLossPercent)}% · '
      '${strings.diagnosticThroughput} ${_delta(before.throughputMbps, after.throughputMbps)} Mbit/s',
    ),
  );

  Widget _sectionHeader(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(value, style: FluentTheme.of(context).typography.subtitle),
  );

  Widget _field(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label),
        TextBox(controller: controller, enabled: enabled),
      ],
    ),
  );

  String _fieldName(AppLocalizations strings, String field) => switch (field) {
    'autotuning' => strings.tcpAutotuning,
    'heuristics' => strings.tcpHeuristics,
    'ecn' => strings.tcpEcn,
    'congestion' => strings.tcpCongestion,
    'rsc' => strings.tcpRsc,
    'rss' => strings.tcpRss,
    _ => field,
  };

  String _number(double? value) => value?.toStringAsFixed(2) ?? '—';

  String _delta(double? before, double? after) {
    if (before == null || after == null) return '—';
    final value = after - before;
    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}';
  }
}
