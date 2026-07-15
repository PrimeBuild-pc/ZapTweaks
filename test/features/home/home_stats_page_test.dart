import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/models/hardware_profile.dart';
import 'package:script_utility/core/models/system_metrics_snapshot.dart';
import 'package:script_utility/features/home/presentation/pages/home_stats_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home stats page shows hardware cards and metric labels', (
    tester,
  ) async {
    const profile = HardwareProfile(
      cpuName: 'AMD Ryzen 9 7950X3D',
      cpuVendor: 'amd',
      gpuNames: <String>['NVIDIA GeForce RTX 4080'],
      gpuVendors: <String>{'nvidia'},
      ramInstalledBytes: 34 * 1024 * 1024 * 1024,
      networkAdapters: <String>['Intel Ethernet Connection [NDIS 6.95]'],
      audioDevices: <String>['Realtek(R) Audio'],
    );

    const metrics = SystemMetricsSnapshot(
      timestamp: null,
      cpuUsagePercent: 24.2,
      gpuUsagePercent: 66.7,
      memoryUsagePercent: 58.4,
      memoryUsedBytes: 10 * 1024 * 1024 * 1024,
      memoryTotalBytes: 16 * 1024 * 1024 * 1024,
      vramUsagePercent: 42.5,
      vramUsedBytes: 4 * 1024 * 1024 * 1024,
      vramTotalBytes: 10 * 1024 * 1024 * 1024,
    );

    await tester.pumpWidget(
      FluentApp(
        home: HomeStatsPage(
          hardwareProfile: profile,
          latestMetrics: metrics,
          cpuHistory: const <double>[10, 20, 30],
          gpuHistory: const <double>[45, 55, 66],
          vramHistory: const <double>[20, 30, 42],
          memoryHistory: const <double>[40, 50, 60],
        ),
      ),
    );

    expect(find.text('Home & Stats'), findsOneWidget);
    expect(find.text('CPU'), findsOneWidget);
    expect(find.text('GPU'), findsOneWidget);
    expect(find.text('Installed RAM'), findsOneWidget);
    expect(find.text('Network Adapters'), findsOneWidget);
    expect(find.text('Audio Devices'), findsOneWidget);
    expect(find.text('CPU Usage'), findsOneWidget);
    expect(find.text('GPU Usage'), findsOneWidget);
    expect(find.text('VRAM Usage'), findsOneWidget);
    expect(find.text('Memory Usage'), findsOneWidget);
    expect(find.text('24.2%'), findsOneWidget);
    expect(find.text('66.7%'), findsOneWidget);
    expect(find.text('42.5%'), findsOneWidget);
    expect(find.text('58.4%'), findsOneWidget);
  });
}
