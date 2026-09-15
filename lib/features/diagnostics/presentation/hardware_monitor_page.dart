import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/gpu_memory_service.dart';

class HardwareMonitorPage extends StatefulWidget {
  const HardwareMonitorPage({super.key});

  @override
  State<HardwareMonitorPage> createState() => _HardwareMonitorPageState();
}

class _HardwareMonitorPageState extends State<HardwareMonitorPage> {
  bool _busy = false;
  String? _error;
  int? _bytes;
  List<double>? _temperatures;

  Future<void> _capture() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final snapshot = await WindowsGpuMemoryService(
        processRunner: ProcessRunner.shared,
      ).capture();
      if (!mounted) return;
      setState(() => _bytes = snapshot.dedicatedBytes);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _captureThermals() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final snapshot = await WindowsThermalSensorService(
        processRunner: ProcessRunner.shared,
      ).capture();
      if (!mounted) return;
      setState(() => _temperatures = snapshot.celsius);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        if (_error != null) ...<Widget>[
          InfoBar(
            title: Text(strings.operationFailed),
            content: Text(_error!),
            severity: InfoBarSeverity.error,
          ),
          const SizedBox(height: 12),
        ],
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.dedicatedVramUsage,
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                const SizedBox(height: 6),
                Text(strings.dedicatedVramUsageDescription),
                const SizedBox(height: 16),
                if (_bytes != null)
                  Text(
                    strings.vramUsageValue(
                      (_bytes! / (1024 * 1024)).toStringAsFixed(0),
                    ),
                    style: FluentTheme.of(context).typography.title,
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _capture,
                  child: _busy
                      ? const ProgressRing(strokeWidth: 2)
                      : Text(strings.captureNow),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  strings.firmwareTemperatures,
                  style: FluentTheme.of(context).typography.subtitle,
                ),
                const SizedBox(height: 6),
                Text(strings.firmwareTemperaturesDescription),
                if (_temperatures != null) ...<Widget>[
                  const SizedBox(height: 16),
                  Text(
                    _temperatures!.isEmpty
                        ? strings.noThermalSensors
                        : _temperatures!
                              .map((value) => '${value.toStringAsFixed(1)} °C')
                              .join(' · '),
                    style: FluentTheme.of(context).typography.title,
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _busy ? null : _captureThermals,
                  child: Text(strings.captureNow),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
