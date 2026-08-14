import 'package:fluent_ui/fluent_ui.dart';

import '../../../../core/models/hardware_profile.dart';
import '../../../../core/models/system_metrics_snapshot.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/metric_card.dart';

class HomeStatsPage extends StatelessWidget {
  const HomeStatsPage({
    super.key,
    required this.hardwareProfile,
    required this.latestMetrics,
    required this.cpuHistory,
    required this.memoryHistory,
    required this.gpuHistory,
    required this.vramHistory,
  });

  final HardwareProfile hardwareProfile;
  final SystemMetricsSnapshot latestMetrics;
  final List<double> cpuHistory;
  final List<double> memoryHistory;
  final List<double> gpuHistory;
  final List<double> vramHistory;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          strings.homeAndStats,
          style: FluentTheme.of(context).typography.title,
        ),
        const SizedBox(height: 16),
        _buildMetricGrid(context, strings),
        const SizedBox(height: 28),
        Text(
          strings.detectedHardware,
          style: FluentTheme.of(context).typography.subtitle,
        ),
        const SizedBox(height: 12),
        _buildHardwareGrid(context, strings),
      ],
    );
  }

  Widget _buildMetricGrid(BuildContext context, AppLocalizations strings) {
    final cards = <MetricCard>[
      MetricCard(
        title: strings.cpuUsage,
        value: latestMetrics.cpuLabel,
        subtitle: strings.cpuUsageDescription,
        color: const Color(0xFF4CAF50),
        history: cpuHistory,
      ),
      MetricCard(
        title: strings.gpuUsage,
        value: latestMetrics.gpuLabel,
        subtitle: strings.gpuUsageDescription,
        color: const Color(0xFFFF9800),
        history: gpuHistory,
      ),
      MetricCard(
        title: strings.vramUsage,
        value: latestMetrics.vramPercentLabel,
        subtitle: latestMetrics.vramDetailLabel,
        color: const Color(0xFFE91E63),
        history: vramHistory,
      ),
      MetricCard(
        title: strings.memoryUsage,
        value: latestMetrics.memoryPercentLabel,
        subtitle: latestMetrics.memoryDetailLabel,
        color: const Color(0xFF03A9F4),
        history: memoryHistory,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1280 ? 4 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (final card in cards)
              SizedBox(width: width, height: 256, child: card),
          ],
        );
      },
    );
  }

  Widget _buildHardwareGrid(BuildContext context, AppLocalizations strings) {
    final cards = <_HardwareCardData>[
      _HardwareCardData('CPU', hardwareProfile.cpuName),
      _HardwareCardData(
        'GPU',
        hardwareProfile.gpuNames.isEmpty
            ? strings.unknown
            : hardwareProfile.gpuNames.join('\n'),
      ),
      _HardwareCardData(
        strings.installedRam,
        hardwareProfile.ramInstalledLabel,
      ),
      _HardwareCardData(
        strings.gpuDrivers,
        _orEmpty(hardwareProfile.gpuDrivers, strings.noGpuDrivers),
      ),
      _HardwareCardData(
        strings.chipsetDrivers,
        _orEmpty(hardwareProfile.chipsetDrivers, strings.noChipsetDrivers),
      ),
      _HardwareCardData(
        strings.networkAdapters,
        _orEmpty(hardwareProfile.networkAdapters, strings.noConnectedAdapters),
      ),
      _HardwareCardData(
        strings.audioDevices,
        _orEmpty(hardwareProfile.audioDevices, strings.noAudioDevices),
      ),
      _HardwareCardData(
        strings.monitors,
        _orEmpty(hardwareProfile.monitors, strings.noMonitors),
      ),
      _HardwareCardData(
        strings.mice,
        _orEmpty(hardwareProfile.mice, strings.noMice),
      ),
      _HardwareCardData(
        strings.keyboards,
        _orEmpty(hardwareProfile.keyboards, strings.noKeyboards),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1800
            ? 5
            : constraints.maxWidth >= 1200
            ? 4
            : constraints.maxWidth >= 760
            ? 2
            : 1;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (final card in cards)
              SizedBox(
                width: width,
                height: 156,
                child: _HardwareInfoCard(data: card),
              ),
          ],
        );
      },
    );
  }

  String _orEmpty(List<String> values, String emptyLabel) =>
      values.isEmpty ? emptyLabel : values.join('\n');
}

class _HardwareCardData {
  const _HardwareCardData(this.title, this.value);

  final String title;
  final String value;
}

class _HardwareInfoCard extends StatelessWidget {
  const _HardwareInfoCard({required this.data});

  final _HardwareCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              data.title,
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Tooltip(
                message: data.value,
                child: Text(
                  data.value,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: FluentTheme.of(context).typography.caption,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
