import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../features/drivers/application/setupapi_device_inventory_service.dart';
import '../../../features/drivers/domain/device_identity.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/interrupt_configuration_service.dart';
import '../../../platform/windows/processor_topology.dart';
import '../../../platform/windows/registry_value_store.dart';
import '../../tweaks/application/tweak_controller.dart';

class InterruptConfigurationPage extends StatefulWidget {
  const InterruptConfigurationPage({required this.controller, super.key});
  final TweakController controller;

  @override
  State<InterruptConfigurationPage> createState() =>
      _InterruptConfigurationPageState();
}

class _InterruptConfigurationPageState
    extends State<InterruptConfigurationPage> {
  List<PciInterruptCapability> _devices = const <PciInterruptCapability>[];
  Map<String, DeviceInterruptConfiguration> _configurations =
      const <String, DeviceInterruptConfiguration>{};
  ProcessorTopology? _topology;
  String _query = '';
  String? _busy;
  String? _message;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      const allowed = <String>{
        '4d36e968-e325-11ce-bfc1-08002be10318',
        '4d36e972-e325-11ce-bfc1-08002be10318',
        '4d36e96c-e325-11ce-bfc1-08002be10318',
      };
      final devices = const SetupApiDeviceInventoryService()
          .scanPciInterruptCapabilities()
          .where(
            (item) => allowed.contains(
              item.device.classGuid.replaceAll(RegExp(r'[{}]'), ''),
            ),
          )
          .toList(growable: false);
      const reader = InterruptConfigurationService(WindowsRegistryValueStore());
      final configurations = <String, DeviceInterruptConfiguration>{};
      for (final device in devices) {
        configurations[device.device.instanceId] = await reader.read(device);
      }
      if (mounted) {
        setState(() {
          _devices = devices;
          _configurations = configurations;
          _topology = ProcessorTopology.inspect();
          _message = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
      if (plan.status != PlanStatus.completed) {
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

  Future<void> _configureMsi(PciInterruptCapability capability) async {
    final strings = AppLocalizations.of(context);
    final current = _configurations[capability.device.instanceId];
    var enabled = current?.msiSupported == 1;
    var priority = current?.devicePriority ?? 0;
    final count = TextEditingController(
      text: (current?.messageNumberLimit ?? 1).toString(),
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          title: Text(strings.configureMsi),
          constraints: const BoxConstraints(maxWidth: 560),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(strings.interruptChangeWarning),
              const SizedBox(height: 12),
              Text(
                strings.interruptCapabilities(
                  capability.lineBased.toString(),
                  capability.msi.toString(),
                  capability.msiX.toString(),
                  capability.messageMaximum,
                ),
              ),
              const SizedBox(height: 12),
              Checkbox(
                checked: enabled,
                content: Text(strings.enableMsi),
                onChanged: (value) =>
                    setDialogState(() => enabled = value ?? false),
              ),
              const SizedBox(height: 8),
              Text(strings.messageNumberLimit),
              TextBox(
                controller: count,
                enabled: enabled,
                placeholder: '1-${capability.messageMaximum}',
              ),
              const SizedBox(height: 8),
              Text(strings.interruptPriority),
              ComboBox<int>(
                value: priority,
                isExpanded: true,
                items: <ComboBoxItem<int>>[
                  for (var value = 0; value <= 3; value++)
                    ComboBoxItem<int>(
                      value: value,
                      child: Text(_priorityName(strings, value)),
                    ),
                ],
                onChanged: (value) =>
                    setDialogState(() => priority = value ?? 0),
              ),
            ],
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
    final limit = int.tryParse(count.text);
    count.dispose();
    if (confirmed != true) return;
    if (enabled &&
        (limit == null || limit < 1 || limit > capability.messageMaximum)) {
      setState(() => _message = strings.msiRange(capability.messageMaximum));
      return;
    }
    await _execute(
      OperationRequest(
        operationId: 'device.msi.configure',
        target: capability.device.instanceId,
        desiredValue: <String, Object?>{
          'msiSupported': enabled ? 1 : 0,
          if (enabled) 'messageNumberLimit': limit,
          'devicePriority': priority,
        },
      ),
    );
  }

  Future<void> _configureAffinity(PciInterruptCapability capability) async {
    final strings = AppLocalizations.of(context);
    final current = _configurations[capability.device.instanceId];
    var policy = current?.devicePolicy ?? 0;
    final processorCount = _topology?.processorsPerGroup[0] ?? 0;
    final currentMask =
        BigInt.tryParse(current?.assignmentMaskHex ?? '', radix: 16) ??
        BigInt.zero;
    final selected = <int>{
      for (var cpu = 0; cpu < processorCount; cpu++)
        if ((currentMask & (BigInt.one << cpu)) != BigInt.zero) cpu,
    };
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          title: Text(strings.configureInterruptAffinity),
          constraints: const BoxConstraints(maxWidth: 680),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(strings.interruptChangeWarning),
              const SizedBox(height: 12),
              Text(strings.interruptPolicy),
              ComboBox<int>(
                value: policy,
                isExpanded: true,
                items: <ComboBoxItem<int>>[
                  for (var value = 0; value <= 5; value++)
                    ComboBoxItem<int>(
                      value: value,
                      child: Text(_policyName(strings, value)),
                    ),
                ],
                onChanged: (value) => setDialogState(() => policy = value ?? 0),
              ),
              if (policy == 4) ...<Widget>[
                const SizedBox(height: 12),
                Text(strings.selectLogicalProcessors),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    for (var cpu = 0; cpu < processorCount; cpu++)
                      ToggleButton(
                        checked: selected.contains(cpu),
                        onChanged: (checked) => setDialogState(
                          () => checked
                              ? selected.add(cpu)
                              : selected.remove(cpu),
                        ),
                        child: Text('CPU $cpu'),
                      ),
                  ],
                ),
              ],
            ],
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
    if (confirmed != true) return;
    if (policy == 4 && selected.isEmpty) {
      setState(() => _message = strings.invalidAffinityMask);
      return;
    }
    var mask = BigInt.zero;
    for (final cpu in selected) {
      mask |= BigInt.one << cpu;
    }
    await _execute(
      OperationRequest(
        operationId: 'device.interrupt_affinity.configure',
        target: capability.device.instanceId,
        desiredValue: <String, Object>{
          'devicePolicy': policy,
          if (policy == 4) 'processorGroup': 0,
          if (policy == 4) 'maskHex': mask.toRadixString(16),
        },
      ),
    );
  }

  String _priorityName(AppLocalizations strings, int value) => switch (value) {
    1 => strings.interruptPriorityLow,
    2 => strings.interruptPriorityNormal,
    3 => strings.interruptPriorityHigh,
    _ => strings.interruptPriorityDefault,
  };

  String _policyName(AppLocalizations strings, int value) => switch (value) {
    1 => strings.interruptPolicyAllClose,
    2 => strings.interruptPolicyOneClose,
    3 => strings.interruptPolicyAllProcessors,
    4 => strings.interruptPolicySpecified,
    5 => strings.interruptPolicySpread,
    _ => strings.interruptPolicyDefault,
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final visible = _devices
        .where((capability) {
          final query = _query.trim().toLowerCase();
          return query.isEmpty ||
              capability.device.description.toLowerCase().contains(query) ||
              capability.device.instanceId.toLowerCase().contains(query) ||
              (capability.device.driverInf?.contains(query) ?? false);
        })
        .toList(growable: false);
    final enabledCount = _configurations.values
        .where((item) => item.msiSupported == 1)
        .length;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text(
          strings.interruptConfiguration,
          style: FluentTheme.of(context).typography.title,
        ),
        const SizedBox(height: 6),
        Text(strings.interruptConfigurationDescription),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _statusCard(strings.compatibleDevices, _devices.length.toString()),
            _statusCard(strings.msiEnabledDevices, enabledCount.toString()),
            _statusCard(
              strings.logicalProcessors,
              (_topology?.logicalProcessorCount ?? 0).toString(),
            ),
            Button(
              onPressed: _loading || _busy != null ? null : _load,
              child: Text(strings.refreshInventory),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextBox(
          placeholder: strings.searchDevices,
          onChanged: (value) => setState(() => _query = value),
        ),
        if (_message != null) ...<Widget>[
          const SizedBox(height: 12),
          InfoBar(title: Text(_message!), severity: InfoBarSeverity.info),
        ],
        const SizedBox(height: 12),
        if (_loading && _devices.isEmpty)
          const Center(child: ProgressRing())
        else if (visible.isEmpty)
          Text(strings.noCompatibleInterruptDevices)
        else
          ...visible.map((capability) {
            final current = _configurations[capability.device.instanceId];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        capability.device.description,
                        style: FluentTheme.of(context).typography.bodyStrong,
                      ),
                      const SizedBox(height: 4),
                      SelectableText(capability.device.instanceId),
                      Text(
                        capability.device.driverInf ?? strings.driverUnknown,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.interruptCapabilities(
                          capability.lineBased.toString(),
                          capability.msi.toString(),
                          capability.msiX.toString(),
                          capability.messageMaximum,
                        ),
                      ),
                      Text(
                        strings.currentInterruptConfiguration(
                          current?.msiSupported == 1 ? 'MSI' : 'Line/default',
                          current?.messageNumberLimit?.toString() ?? '—',
                          _priorityName(strings, current?.devicePriority ?? 0),
                          _policyName(strings, current?.devicePolicy ?? 0),
                          current?.assignmentMaskHex ?? '—',
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_busy == capability.device.instanceId)
                        const ProgressBar()
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            Button(
                              onPressed: _busy == null
                                  ? () => _configureMsi(capability)
                                  : null,
                              child: Text(strings.configureMsi),
                            ),
                            Button(
                              onPressed: _busy == null
                                  ? () => _configureAffinity(capability)
                                  : null,
                              child: Text(strings.configureInterruptAffinity),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _statusCard(String label, String value) => SizedBox(
    width: 170,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(value, style: FluentTheme.of(context).typography.subtitle),
            Text(label),
          ],
        ),
      ),
    ),
  );
}
