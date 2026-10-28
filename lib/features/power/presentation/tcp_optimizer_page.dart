import 'dart:async';

import '../../../app/widgets/ui_kit.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/operations/tcp_optimizer_operations.dart';
import '../../../core/persistence/operation_store.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/hardware_capability_validators.dart';
import '../../../platform/windows/network_diagnostics_service.dart';
import '../../../platform/windows/rss_service.dart';
import '../../../platform/windows/tcp_optimizer_service.dart';
import '../../tweaks/application/tweak_controller.dart';

class TcpOptimizerPage extends StatefulWidget {
  const TcpOptimizerPage({required this.controller, this.journal, super.key});

  final TweakController controller;
  final OperationStore? journal;

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

  // Kept bilingual here until the shared-locale owner registers the handoff keys.
  String _presetText(String key) {
    const text = <String, (String, String)>{
      'tcpPresetTitle': ('Manual network preset', 'Preset rete manuale'),
      'tcpPresetDescription': (
        'Limited subset of network settings. No recommendation or speed claim. Only exactly restorable native configuration fields are included; connection/adapter effective state is not inferred.',
        'Sottoinsieme limitato delle impostazioni di rete. Nessuna raccomandazione o promessa di velocità. Include solo configurazioni native ripristinabili esattamente; non presume lo stato effettivo di connessioni o adattatori.',
      ),
      'tcpPresetHighRisk': (
        'High risk · Administrator · May interrupt connectivity. All originals are journaled before any write. On failure, every attempted write is restored in reverse order; conflicts remain visible in recovery history.',
        'Rischio alto · Amministratore · Può interrompere la connettività. Tutti gli originali sono salvati nel journal prima di scrivere. In caso di errore, ogni scrittura tentata viene ripristinata in ordine inverso; i conflitti restano visibili nella cronologia di ripristino.',
      ),
      'tcpPresetNoTemplate': (
        'Leave templates unchanged',
        'Non modificare i template',
      ),
      'tcpPresetTemplateChoice': (
        'Optional explicit custom template (no default)',
        'Template custom opzionale ed esplicito (nessuna preselezione)',
      ),
      'tcpPresetTemplateVariant': (
        'Explicit per-template variant; not equivalent to global settings.',
        'Variante esplicita per-template; non equivale alle impostazioni globali.',
      ),
      'tcpPresetIncluded': ('Included', 'Incluso'),
      'tcpPresetExcluded': ('Excluded', 'Escluso'),
      'tcpPresetGlobalScopeUnavailable': (
        'No exactly reversible global API in this implementation; a per-template field is not equivalent.',
        'Nessuna API globale esattamente reversibile in questa implementazione; un valore per-template non è equivalente.',
      ),
      'tcpPresetInternetReadOnly': (
        'Internet congestion is read-only here. InternetCustom is not substituted.',
        'La congestione di Internet è in sola lettura qui. InternetCustom non viene sostituito.',
      ),
      'tcpPresetExactStateUnavailable': (
        'Missing, unsupported, managed, Default/inherited or incomplete configured state: no write.',
        'Stato configurato mancante, non supportato, gestito, Default/ereditato o incompleto: nessuna scrittura.',
      ),
      'tcpPresetApiUnavailable': (
        'No typed exact snapshot/setter for this global option.',
        'Nessuno snapshot/setter tipizzato esatto per questa opzione globale.',
      ),
      'tcpPresetCustomReadOnly': (
        'Custom ICW is not a validated writable Windows 11 client field.',
        'ICW Custom non è un campo scrivibile convalidato sul client Windows 11.',
      ),
      'tcpRecoveryTitle': (
        'Restore an original TCP journal value',
        'Ripristina un valore TCP originale dal journal',
      ),
      'tcpRecoveryDescription': (
        'Select one attempted operation. Restore resolves the original from the trusted journal, checks current drift and saves a new recoverable plan. No reset or default value is used.',
        'Seleziona una operazione tentata. Il ripristino risolve l’originale dal journal fidato, controlla il drift corrente e salva un nuovo piano ripristinabile. Non usa reset o valori predefiniti.',
      ),
      'tcpRecoveryUnavailable': (
        'TCP journal recovery is not connected in this build.',
        'Il ripristino TCP dal journal non è collegato in questa build.',
      ),
      'tcpConfiguredState': ('Configured', 'Configurato'),
      'tcpEffectiveState': ('Effective (if exposed)', 'Effettivo (se esposto)'),
      'tcpConfigurationStore': (
        'Configuration source',
        'Fonte della configurazione',
      ),
    };
    final pair = text[key]!;
    return Localizations.localeOf(context).languageCode == 'it'
        ? pair.$2
        : pair.$1;
  }

  Future<void> _previewSparklePreset() async {
    setState(() {
      _busy = 'sparklePreset';
      _message = null;
    });
    try {
      final inventory = await _tcp.inventory();
      String? template;
      var options = TcpSparklePreset.preview(inventory);
      final templates =
          inventory
              .where((state) => state.template.endsWith('Custom'))
              .map((state) => state.template)
              .toSet()
              .toList()
            ..sort();
      if (!mounted) return;
      final strings = AppLocalizations.of(context);
      final approved = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, updateDialog) => ContentDialog(
            constraints: const BoxConstraints(maxWidth: 680),
            title: Text(_presetText('tcpPresetTitle')),
            content: SizedBox(
              height: 420,
              child: ListView(
                children: [
                  Text(_presetText('tcpPresetDescription')),
                  const SizedBox(height: 12),
                  InfoLabel(
                    label: _presetText('tcpPresetTemplateChoice'),
                    child: ComboBox<String>(
                      value: template,
                      placeholder: Text(_presetText('tcpPresetTemplateChoice')),
                      isExpanded: true,
                      items: [
                        ComboBoxItem(
                          value: '',
                          child: Text(_presetText('tcpPresetNoTemplate')),
                        ),
                        for (final name in templates)
                          ComboBoxItem(value: name, child: Text(name)),
                      ],
                      onChanged: (value) => updateDialog(() {
                        template = value == null || value.isEmpty
                            ? null
                            : value;
                        options = TcpSparklePreset.preview(
                          inventory,
                          template: template,
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InfoBar(
                    title: Text(_presetText('tcpPresetHighRisk')),
                    severity: InfoBarSeverity.warning,
                  ),
                  const SizedBox(height: 12),
                  for (final option in options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_presetText(option.included ? 'tcpPresetIncluded' : 'tcpPresetExcluded')}: ${option.target} → ${option.value}',
                          ),
                          if (!option.included ||
                              option.reasonKey == 'tcpPresetTemplateVariant')
                            Text(_presetText(option.reasonKey)),
                          if (option.included) ...[
                            for (final state in inventory.where(
                              (item) => item.target == option.target,
                            ))
                              Text(
                                '${_presetText('tcpConfiguredState')}: ${state.configuredValue}\n'
                                '${_presetText('tcpEffectiveState')}: ${state.effectiveValue ?? '—'}\n'
                                '${_presetText('tcpConfigurationStore')}: ${state.configurationStore} · ${state.inheritance}',
                              ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              Button(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: options.any((item) => item.included)
                    ? () => Navigator.pop(context, true)
                    : null,
                child: Text(strings.apply),
              ),
            ],
          ),
        ),
      );
      if (approved == true && mounted) {
        await _executeRequests(TcpSparklePreset.requests(options));
      }
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _previewTcpRecovery() async {
    final journal = widget.journal;
    if (journal == null) return;
    setState(() {
      _busy = 'tcpRecovery';
      _message = null;
    });
    try {
      final inventory = await _tcp.inventory();
      final candidates = <(OperationRequest, String)>[];
      final rows = journal.database.select(
        'SELECT DISTINCT plan_id FROM plan_items WHERE operation_id=? ORDER BY plan_id',
        ['network.tcp.setting.configure'],
      );
      for (final row in rows) {
        final plan = journal.load(row['plan_id'] as String)!;
        for (var index = plan.items.length - 1; index >= 0; index--) {
          final item = plan.items[index];
          final snapshot = item.snapshot;
          if (item.operationId != 'network.tcp.setting.configure' ||
              item.written == null ||
              snapshot == null ||
              snapshot.data['schema'] != 2 ||
              item.status == PlanItemStatus.rolledBack) {
            continue;
          }
          final states = inventory.where(
            (state) => state.target == item.request.target,
          );
          if (states.length != 1 ||
              !states.single.exactlyRestorable ||
              (states.single.value != item.written!.value &&
                  states.single.value !=
                      snapshot.expectedAfterRollback.value)) {
            continue;
          }
          candidates.add((
            OperationRequest(
              operationId: 'network.tcp.snapshot.restore',
              target: item.request.target,
              desiredValue: snapshot.expectedAfterRollback.value,
              parameters: {
                'planId': plan.id,
                'sequence': index,
                'digest': snapshot.data['digest'],
              },
            ),
            '${plan.createdAt.toLocal()} · ${plan.id}\n${item.request.target}: ${states.single.configuredValue} → ${snapshot.expectedAfterRollback.value}',
          ));
        }
      }
      if (!mounted) return;
      final strings = AppLocalizations.of(context);
      final selected = await showDialog<OperationRequest>(
        context: context,
        builder: (context) => ContentDialog(
          constraints: const BoxConstraints(maxWidth: 680),
          title: Text(_presetText('tcpRecoveryTitle')),
          content: SizedBox(
            height: 420,
            child: ListView(
              children: [
                Text(_presetText('tcpRecoveryDescription')),
                const SizedBox(height: 12),
                InfoBar(
                  title: Text(_presetText('tcpPresetHighRisk')),
                  severity: InfoBarSeverity.warning,
                ),
                if (candidates.isEmpty) Text(strings.noSearchResults),
                for (final candidate in candidates)
                  ListTile(
                    title: Text(candidate.$2),
                    trailing: Button(
                      onPressed: () => Navigator.pop(context, candidate.$1),
                      child: Text(strings.apply),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            Button(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
          ],
        ),
      );
      if (selected != null && mounted) await _execute(selected);
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _busy = null);
    }
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
    final confirmed = await confirmAction(
      context,
      title: strings.qosDelete,
      message: '${strings.qosDeleteConfirm}\n\n${policy.name}',
      confirmLabel: strings.qosDelete,
      destructive: true,
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

  Future<void> _execute(OperationRequest request) =>
      _executeRequests([request]);

  Future<void> _executeRequests(List<OperationRequest> requests) async {
    setState(() {
      _busy = requests.first.target;
      _message = null;
    });
    try {
      final plan = await widget.controller.executeNativeRequests(requests);
      if (plan.status != PlanStatus.completed ||
          plan.items.any(
            (item) =>
                item.status != PlanItemStatus.verified &&
                !(item.status == PlanItemStatus.skipped && item.error == null),
          )) {
        throw StateError(
          '${plan.status.name}\n${plan.items.map((item) => item.error).whereType<String>().join('\n')}',
        );
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
        Button(
          onPressed: !_loading && _busy == null ? _previewSparklePreset : null,
          child: Text(_presetText('tcpPresetTitle')),
        ),
        const SizedBox(height: 8),
        Button(
          onPressed: !_loading && _busy == null && widget.journal != null
              ? _previewTcpRecovery
              : null,
          child: Text(_presetText('tcpRecoveryTitle')),
        ),
        if (widget.journal == null) Text(_presetText('tcpRecoveryUnavailable')),
        const SizedBox(height: 12),
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

  Widget _settingTile(
    AppLocalizations strings,
    TcpSettingState setting,
  ) => Card(
    child: ListTile(
      title: Text(_fieldName(strings, setting.field)),
      subtitle: Text(
        '${setting.template} · ${setting.value}\n'
        '${_presetText('tcpConfiguredState')}: ${setting.configuredValue ?? '—'} · '
        '${_presetText('tcpEffectiveState')}: ${setting.effectiveValue ?? '—'}\n'
        '${_presetText('tcpConfigurationStore')}: ${setting.configurationStore ?? '—'} · ${setting.inheritance}',
      ),
      trailing: Button(
        onPressed: setting.exactlyRestorable && _busy == null
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
