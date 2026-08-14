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
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          strings.homeAndStats,
          style: FluentTheme.of(context).typography.title,
        ),
        const SizedBox(height: 12),
        _buildHardwareGrid(context),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            SizedBox(
              width: 380,
              child: MetricCard(
                title: strings.cpuUsage,
                value: latestMetrics.cpuLabel,
                subtitle: strings.cpuUsageDescription,
                color: const Color(0xFF4CAF50),
                history: cpuHistory,
              ),
            ),
            SizedBox(
              width: 380,
              child: MetricCard(
                title: strings.gpuUsage,
                value: latestMetrics.gpuLabel,
                subtitle: strings.gpuUsageDescription,
                color: const Color(0xFFFF9800),
                history: gpuHistory,
              ),
            ),
            SizedBox(
              width: 380,
              child: MetricCard(
                title: strings.vramUsage,
                value: latestMetrics.vramPercentLabel,
                subtitle: latestMetrics.vramDetailLabel,
                color: const Color(0xFFE91E63),
                history: vramHistory,
              ),
            ),
            SizedBox(
              width: 380,
              child: MetricCard(
                title: strings.memoryUsage,
                value: latestMetrics.memoryPercentLabel,
                subtitle: latestMetrics.memoryDetailLabel,
                color: const Color(0xFF03A9F4),
                history: memoryHistory,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHardwareGrid(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        _infoCard(context, 'CPU', hardwareProfile.cpuName),
        _infoCard(
          context,
          'GPU',
          hardwareProfile.gpuNames.isEmpty
              ? AppLocalizations.of(context).unknown
              : hardwareProfile.gpuNames.join(' | '),
        ),
        _infoCard(
          context,
          AppLocalizations.of(context).installedRam,
          hardwareProfile.ramInstalledLabel,
        ),
        _infoCard(
          context,
          AppLocalizations.of(context).networkAdapters,
          hardwareProfile.networkAdapters.isEmpty
              ? AppLocalizations.of(context).noConnectedAdapters
              : hardwareProfile.networkAdapters.join('\n'),
        ),
        _infoCard(
          context,
          AppLocalizations.of(context).audioDevices,
          hardwareProfile.audioDevices.isEmpty
              ? AppLocalizations.of(context).noAudioDevices
              : hardwareProfile.audioDevices.join('\n'),
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context, String title, String value) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: FluentTheme.of(context).typography.bodyStrong),
              const SizedBox(height: 8),
              Text(value),
            ],
          ),
        ),
      ),
    );
  }
}
