import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../features/drivers/application/setupapi_device_inventory_service.dart';
import '../../../features/drivers/domain/device_identity.dart';
import '../../../l10n/app_localizations.dart';
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
  String? _busy;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
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
      setState(() => _devices = devices);
    } catch (error) {
      setState(() => _message = error.toString());
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
    var enabled = capability.msi || capability.msiX;
    final count = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => ContentDialog(
          title: Text(strings.configureMsi),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(strings.interruptChangeWarning),
              const SizedBox(height: 12),
              Checkbox(
                checked: enabled,
                content: Text(strings.enableMsi),
                onChanged: (value) =>
                    setDialogState(() => enabled = value ?? false),
              ),
              const SizedBox(height: 8),
              TextBox(
                controller: count,
                enabled: enabled,
                placeholder: '1-${capability.messageMaximum}',
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
    if (confirmed != true) return;
    final limit = int.tryParse(count.text);
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
        },
      ),
    );
  }

  Future<void> _configureAffinity(PciInterruptCapability capability) async {
    final strings = AppLocalizations.of(context);
    final mask = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(strings.configureInterruptAffinity),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(strings.interruptChangeWarning),
            const SizedBox(height: 12),
            TextBox(controller: mask, placeholder: strings.affinityMaskHint),
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
    );
    if (confirmed != true) return;
    final value = mask.text.trim().toLowerCase();
    if (!RegExp(r'^[1-9a-f][0-9a-f]{0,15}$').hasMatch(value)) {
      setState(() => _message = strings.invalidAffinityMask);
      return;
    }
    await _execute(
      OperationRequest(
        operationId: 'device.interrupt_affinity.configure',
        target: capability.device.instanceId,
        desiredValue: <String, Object>{
          'devicePolicy': 4,
          'processorGroup': 0,
          'maskHex': value,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Text(
          strings.interruptConfiguration,
          style: FluentTheme.of(context).typography.title,
        ),
        const SizedBox(height: 6),
        Text(strings.interruptConfigurationDescription),
        if (_message != null) ...<Widget>[
          const SizedBox(height: 12),
          InfoBar(title: Text(_message!), severity: InfoBarSeverity.info),
        ],
        const SizedBox(height: 12),
        if (_devices.isEmpty)
          Text(strings.noCompatibleInterruptDevices)
        else
          ..._devices.map(
            (capability) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  title: Text(capability.device.description),
                  subtitle: Text(
                    '${capability.device.instanceId}\n'
                    'Line: ${capability.lineBased} · MSI: ${capability.msi} · '
                    'MSI-X: ${capability.msiX} · Max: ${capability.messageMaximum}',
                  ),
                  trailing: _busy == capability.device.instanceId
                      ? const ProgressRing()
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Button(
                              onPressed: _busy == null
                                  ? () => _configureMsi(capability)
                                  : null,
                              child: Text(strings.configureMsi),
                            ),
                            const SizedBox(width: 8),
                            Button(
                              onPressed: _busy == null
                                  ? () => _configureAffinity(capability)
                                  : null,
                              child: Text(strings.configureInterruptAffinity),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
