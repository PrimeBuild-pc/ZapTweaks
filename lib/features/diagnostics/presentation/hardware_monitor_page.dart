import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../platform/windows/battery_health_service.dart';
import '../../../platform/windows/cpu_frequency_service.dart';
import '../../../platform/windows/gpu_memory_service.dart';
import '../../../platform/windows/thermal_zone_service.dart';
import 'battery_health_card.dart';

class HardwareMonitorPage extends StatefulWidget {
  const HardwareMonitorPage({super.key});

  @override
  State<HardwareMonitorPage> createState() => _HardwareMonitorPageState();
}

class _HardwareMonitorPageState extends State<HardwareMonitorPage> {
  bool _busy = false;
  String? _error;
  int? _bytes;
  ThermalZoneSnapshot? _thermals;
  CpuFrequencySnapshot? _cpu;

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

  Future<void> _captureCpu() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final snapshot = await WindowsCpuFrequencyService(
        processRunner: ProcessRunner.shared,
      ).capture();
      if (!mounted) return;
      setState(() => _cpu = snapshot);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _cpuCard(BuildContext context, AppLocalizations strings) {
    final theme = FluentTheme.of(context);
    final cpu = _cpu;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(strings.cpuFrequency, style: theme.typography.subtitle),
            const SizedBox(height: 6),
            Text(strings.cpuFrequencyDescription),
            if (cpu != null) ...<Widget>[
              const SizedBox(height: 16),
              Text(
                strings.cpuEffectiveClock(
                  '${cpu.total.effectiveMhz}',
                  '${cpu.nominalMhz}',
                ),
                style: theme.typography.title,
              ),
              Text(
                strings.cpuParkedCount(
                  '${cpu.parkedCount}',
                  '${cpu.processors.length}',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  for (final (index, core) in cpu.processors.indexed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: theme.resources.controlStrokeColorDefault,
                        ),
                      ),
                      child: Text(
                        core.parked
                            ? 'CPU $index · ${strings.cpuParked}'
                            : 'CPU $index · ${(core.effectiveMhz / 1000).toStringAsFixed(2)} GHz · ${core.utility}%',
                        style: core.parked
                            ? TextStyle(
                                color: theme.resources.textFillColorDisabled,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(strings.cpuFrequencySource, style: theme.typography.caption),
            ],
            const SizedBox(height: 16),
            Button(
              onPressed: _busy ? null : _captureCpu,
              child: Text(strings.captureNow),
            ),
          ],
        ),
      ),
    );
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
      setState(() => _thermals = snapshot);
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
        BatteryHealthSection(
          load: WindowsBatteryHealthService(
            processRunner: ProcessRunner.shared,
          ).capture,
        ),
        _cpuCard(context, strings),
        const SizedBox(height: 12),
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
                Button(
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
                if (_thermals case final thermals?) ...<Widget>[
                  const SizedBox(height: 16),
                  if (thermals.zones.isEmpty)
                    Text(strings.noThermalSensors)
                  else
                    for (final zone in thermals.zones)
                      Text(
                        zone.limited
                            ? '${zone.name} · ${zone.celsius.toStringAsFixed(1)} °C · ${strings.thermalZoneLimited('${zone.passiveLimit}')}'
                            : '${zone.name} · ${zone.celsius.toStringAsFixed(1)} °C',
                        style: FluentTheme.of(context).typography.bodyLarge,
                      ),
                  const SizedBox(height: 8),
                  Text(switch (thermals.source) {
                    ThermalZoneSource.counters => strings.thermalSourceCounters,
                    ThermalZoneSource.acpi => strings.thermalSourceAcpi,
                    ThermalZoneSource.none => strings.thermalSourceNone,
                  }, style: FluentTheme.of(context).typography.caption),
                ],
                const SizedBox(height: 16),
                Button(
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
