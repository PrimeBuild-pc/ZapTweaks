import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/tweak_manager.dart';

void main() {
  runApp(const ZapTweaksApp());

  doWhenWindowReady(() {
    const initialSize = Size(450, 800); // 9:16 aspect ratio
    appWindow.minSize = initialSize;
    appWindow.maxSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.title = 'ZapTweaks by PrimeBuild';
    appWindow.show();
  });
}

class ZapTweaksApp extends StatelessWidget {
  const ZapTweaksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZapTweaks by PrimeBuild',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C1C),
        primaryColor: const Color(0xFFFF6B00),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B00),
          secondary: Color(0xFFFF6B00),
          surface: Color(0xFF2A2A2A),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _currentAppVersion = '1.1.0';
  static const String _latestReleaseApiUrl =
      'https://api.github.com/repos/PrimeBuild-pc/ZapTweaks/releases/latest';
  static const String _releasesPageUrl =
      'https://github.com/PrimeBuild-pc/ZapTweaks/releases';

  final TweakManager _tweakManager = TweakManager();

  final Map<String, bool> tweaks = {
    'bcd_optimizations': false,
    'cpu_unparking': false,
    'cpu_power_management': false,
    'cpu_intel_optimizations': false,
    'cpu_amd_optimizations': false,
    'gpu_nvidia_optimizations': false,
    'gpu_amd_optimizations': false,
    'gpu_intel_optimizations': false,
    'ram_optimizations': false,
    'storage_optimizations': false,
    'network_optimizations': false,
    'timer_latency': false,
    'visual_effects': false,
    'system_responsiveness': false,
    'telemetry_disable': false,
    'services_disable': false,
    'ui_optimizations': false,
    'privacy_tracking': false,
    'explorer_optimizations': false,
    'notifications_minimal': false,
    'windows_update': false,
    'game_mode': false,
    'flip_model_optimizations': false,
    'disable_mpo': false,
  };

  bool needsRestart = false;
  List<String> availablePowerPlans = [];
  String? activePowerPlan;
  final Set<String> _aggressivePowerPlans = <String>{};
  SharedPreferences? _prefs;

  String _detectedCpuName = 'Unknown CPU';
  String _detectedCpuVendor = 'unknown';
  final Set<String> _detectedGpuVendors = <String>{};
  final List<String> _detectedGpuNames = <String>[];
  bool _hardwareDetectionReady = false;
  final Set<String> _pendingTweaks = <String>{};

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _prefs = await SharedPreferences.getInstance();
    await _detectHardware();
    await _loadSavedState();
    await _cleanAllDuplicatePowerPlans();
    await _loadAvailablePowerPlans();
    await _loadAggressivePowerPlans();
    await _getActivePowerPlan();
  }

  bool get _isIntelCpu => _detectedCpuVendor == 'intel';
  bool get _isAmdCpu => _detectedCpuVendor == 'amd';
  bool get _hasNvidiaGpu => _detectedGpuVendors.contains('nvidia');
  bool get _hasAmdGpu => _detectedGpuVendors.contains('amd');
  bool get _hasIntelGpu => _detectedGpuVendors.contains('intel');

  Future<void> _detectHardware() async {
    String cpuName = 'Unknown CPU';
    String cpuVendor = 'unknown';
    final Set<String> gpuVendors = <String>{};
    final List<String> gpuNames = <String>[];

    try {
      final cpuResult = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        '(Get-CimInstance Win32_Processor | Select-Object -First 1 -ExpandProperty Name)',
      ], runInShell: true);

      if (cpuResult.exitCode == 0) {
        final detectedCpu = cpuResult.stdout.toString().trim();
        if (detectedCpu.isNotEmpty) {
          cpuName = detectedCpu;
          final cpuLower = detectedCpu.toLowerCase();
          if (cpuLower.contains('intel')) {
            cpuVendor = 'intel';
          } else if (cpuLower.contains('amd') || cpuLower.contains('ryzen')) {
            cpuVendor = 'amd';
          }
        }
      }

      final gpuResult = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        '(Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name)',
      ], runInShell: true);

      if (gpuResult.exitCode == 0) {
        final lines = gpuResult.stdout
            .toString()
            .split(RegExp(r'\r?\n'))
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        gpuNames.addAll(lines);
        for (final gpuName in lines) {
          final gpuLower = gpuName.toLowerCase();
          if (gpuLower.contains('nvidia') || gpuLower.contains('geforce')) {
            gpuVendors.add('nvidia');
          }
          if (gpuLower.contains('amd') || gpuLower.contains('radeon')) {
            gpuVendors.add('amd');
          }
          if (gpuLower.contains('intel') || gpuLower.contains('arc')) {
            gpuVendors.add('intel');
          }
        }
      }
    } catch (_) {
      // Keep fallback values when hardware detection is unavailable.
    }

    if (!mounted) return;
    setState(() {
      _detectedCpuName = cpuName;
      _detectedCpuVendor = cpuVendor;
      _detectedGpuVendors
        ..clear()
        ..addAll(gpuVendors);
      _detectedGpuNames
        ..clear()
        ..addAll(gpuNames);
      _hardwareDetectionReady = true;
    });
  }

  Future<void> _loadSavedState() async {
    if (_prefs == null) return;

    setState(() {
      tweaks.forEach((key, value) {
        tweaks[key] = _prefs!.getBool(key) ?? false;
      });

      final migratedFlipModel = _prefs!.getBool('flip_model_optimizations');
      final legacyFullscreen = _prefs!.getBool('fullscreen_optimizations');
      if (migratedFlipModel == null && legacyFullscreen != null) {
        tweaks['flip_model_optimizations'] = legacyFullscreen;
      }

      needsRestart = _prefs!.getBool('needsRestart') ?? false;
    });
  }

  Future<void> _saveTweakState(String key, bool value) async {
    if (_prefs == null) return;
    await _prefs!.setBool(key, value);
  }

  Future<void> _saveRestartState(bool value) async {
    if (_prefs == null) return;
    await _prefs!.setBool('needsRestart', value);
  }

  bool _tweakRequiresRestart(String key) {
    const noRestartRequired = <String>[];
    return !noRestartRequired.contains(key);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowBorder(
        color: const Color(0xFF3A3A3A),
        width: 1,
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Container(
                height: 40,
                color: const Color(0xFF1C1C1C),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.bolt, color: Color(0xFFFF6B00), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'ZapTweaks by PrimeBuild',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MoveWindow(
                        child: Container(color: Colors.transparent),
                      ),
                    ),
                    IconButton(
                      tooltip: 'About',
                      onPressed: _showAboutDialog,
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                    MinimizeWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: Colors.white70,
                        mouseOver: Color(0xFF2A2A2A),
                        iconMouseOver: Colors.white,
                      ),
                    ),
                    MaximizeWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: Colors.white70,
                        mouseOver: Color(0xFF2A2A2A),
                        iconMouseOver: Colors.white,
                      ),
                    ),
                    CloseWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: Colors.white70,
                        mouseOver: Color(0xFFE81123),
                        iconMouseOver: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (needsRestart)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B0000).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF6B00),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFF6B00),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Restart required to apply changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _restartSystem,
                              child: const Text(
                                'Restart',
                                style: TextStyle(color: Color(0xFFFF6B00)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3A3A3A),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.memory,
                                color: Color(0xFFFF6B00),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _hardwareDetectionReady
                                    ? 'Hardware detected'
                                    : 'Hardware detection in progress...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'CPU: $_detectedCpuName',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _detectedGpuNames.isEmpty
                                ? 'GPU: Unknown'
                                : 'GPU: ${_detectedGpuNames.join(' | ')}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSection(
                      'Boot & System Configuration',
                      Icons.power_settings_new,
                      [
                        _buildTweakTile(
                          'Advanced Boot Optimizations',
                          'BCDedit: timer and boot path tuning aligned for Windows 11 24H2+',
                          'bcd_optimizations',
                        ),
                      ],
                    ),

                    _buildSection('CPU Performance', Icons.memory, [
                      _buildTweakTile(
                        'CPU Core Unparking',
                        'Unparks all CPU cores (All CPUs)',
                        'cpu_unparking',
                      ),
                      _buildTweakTile(
                        'CPU Power Management',
                        'Disables C-States, throttling, Win32Priority (All CPUs)',
                        'cpu_power_management',
                      ),
                      _buildTweakTile(
                        'Intel CPU Optimizations',
                        'Heterogeneous P/E-core scheduling (12th gen+)',
                        'cpu_intel_optimizations',
                        isEnabled: _isIntelCpu,
                        disabledReason: 'Available only on Intel CPUs.',
                      ),
                      _buildTweakTile(
                        'AMD Ryzen Optimizations',
                        'AMD-specific power and performance tweaks',
                        'cpu_amd_optimizations',
                        isEnabled: _isAmdCpu,
                        disabledReason: 'Available only on AMD Ryzen CPUs.',
                      ),
                    ]),

                    _buildSection('GPU - NVIDIA', Icons.videogame_asset, [
                      _buildTweakTile(
                        'NVIDIA RTX Optimizations',
                        'GPU priority max, HAGS, TDR delay, game task scheduling',
                        'gpu_nvidia_optimizations',
                        isEnabled: _hasNvidiaGpu,
                        disabledReason: 'No NVIDIA GPU detected.',
                      ),
                    ]),

                    _buildSection('GPU - AMD Radeon', Icons.sports_esports, [
                      _buildTweakTile(
                        'AMD Radeon Optimizations',
                        'ULPS, PowerPlay, DRR, thermal throttling, VRAM clocks',
                        'gpu_amd_optimizations',
                        isEnabled: _hasAmdGpu,
                        disabledReason: 'No AMD Radeon GPU detected.',
                      ),
                    ]),

                    _buildSection('GPU - Intel Arc', Icons.computer, [
                      _buildTweakTile(
                        'Intel Arc Optimizations',
                        'XeSS, ReBAR, shader cache 4GB, ASPM, deep link, DPST',
                        'gpu_intel_optimizations',
                        isEnabled: _hasIntelGpu,
                        disabledReason: 'No Intel GPU detected.',
                      ),
                    ]),

                    _buildSection('Memory (RAM)', Icons.storage, [
                      _buildTweakTile(
                        'RAM Optimizations',
                        'Paging executive, cache, superfetch, prefetch, SysMain',
                        'ram_optimizations',
                      ),
                    ]),

                    _buildSection('Storage (SSD/NVMe)', Icons.sd_storage, [
                      _buildTweakTile(
                        'Storage Optimizations',
                        'NTFS, TRIM, compression, indexing, AHCI power mgmt',
                        'storage_optimizations',
                      ),
                    ]),

                    _buildSection('Network & Latency', Icons.network_check, [
                      _buildTweakTile(
                        'Network Optimizations',
                        'TCP optimizer, throttling disable, interrupt moderation',
                        'network_optimizations',
                      ),
                      _buildTweakTile(
                        'Timer & Latency',
                        'MMCSS, audio latency, timer resolution, system response',
                        'timer_latency',
                      ),
                    ]),

                    _buildSection('Visual Effects & UI', Icons.visibility, [
                      _buildTweakTile(
                        'Disable Visual Effects',
                        'Animations, transparency, blur, Aero, Start Menu effects',
                        'visual_effects',
                      ),
                      _buildTweakTile(
                        'System Responsiveness',
                        'Menu delay 0ms, hover time, task kill timeouts reduced',
                        'system_responsiveness',
                      ),
                      _buildTweakTile(
                        'UI Optimizations',
                        'Taskbar, Start Menu, widgets, search box, meet now',
                        'ui_optimizations',
                      ),
                      _buildTweakTile(
                        'Explorer Optimizations',
                        'Thumbnails, cache, quick access, file extensions shown',
                        'explorer_optimizations',
                      ),
                    ]),

                    _buildSection('Privacy & Telemetry', Icons.privacy_tip, [
                      _buildTweakTile(
                        'Disable Telemetry',
                        'DiagTrack, feedback, Cortana, error reporting, CEIP',
                        'telemetry_disable',
                      ),
                      _buildTweakTile(
                        'Privacy & Tracking',
                        'Location, ads, sync, activity history, Spotlight, apps',
                        'privacy_tracking',
                      ),
                    ]),

                    _buildSection('Services & Background', Icons.settings, [
                      _buildTweakTile(
                        'Diagnostics Services (Surgical)',
                        'Limits only telemetry/diagnostics services (DiagTrack, dmwappush, WER, WDI)',
                        'services_disable',
                      ),
                      _buildTweakTile(
                        'Notifications Minimal',
                        'Toast, focus assist, lockscreen notifications disabled',
                        'notifications_minimal',
                      ),
                    ]),

                    _buildSection('Gaming Tweaks', Icons.sports_esports, [
                      _buildTweakTile(
                        'Disable Game Mode',
                        'Prevents micro-stuttering and scheduling issues',
                        'game_mode',
                      ),
                      _buildTweakTile(
                        'Flip Model Optimizations (Recommended)',
                        'Keeps modern Windows 11 fullscreen optimization path for lower latency and faster alt-tab.',
                        'flip_model_optimizations',
                      ),
                    ]),

                    _buildSection('Troubleshooting', Icons.health_and_safety, [
                      _buildTweakTile(
                        'Disable MPO (only if needed)',
                        'Disable only if you see flicker/black screen in browser or Discord. Keep enabled for best windowed performance.',
                        'disable_mpo',
                      ),
                    ]),

                    _buildSection('Windows Update', Icons.system_update, [
                      _buildTweakTile(
                        'Update Optimizations',
                        'Auto-reboot off, P2P delivery off, 50% bandwidth, no driver updates',
                        'windows_update',
                      ),
                    ]),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.power,
                                color: const Color(0xFFFF6B00),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Power Plans',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (activePowerPlan != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C1C),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFF6B00),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    color: Color(0xFFFF6B00),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Active Plan',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Text(
                                          _powerPlanLabel(activePowerPlan!),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1C),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF3A3A3A),
                                width: 1,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: null,
                                hint: const Text(
                                  'Select a power plan to activate',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                dropdownColor: const Color(0xFF2A2A2A),
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFFFF6B00),
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                items: availablePowerPlans.map((plan) {
                                  return DropdownMenuItem<String>(
                                    value: plan,
                                    child: Text(_powerPlanLabel(plan)),
                                  );
                                }).toList(),
                                onChanged: (String? selectedPlan) {
                                  if (selectedPlan != null) {
                                    _activatePowerPlan(selectedPlan);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFF6B00,
                              ).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFF6B00),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Tip: on modern Intel P/E-core and AMD Ryzen CPUs, keep Balanced as default power plan. Use aggressive plans only for specific troubleshooting.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _importBundledPowerPlan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B00),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.folder_special,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Bundled',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _importCustomPowerPlan,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3A3A3A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.upload_file, size: 18),
                                  label: const Text(
                                    'Custom',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildSection('Advanced Tools', Icons.build_circle, [
                      _buildAdvancedActionTile(
                        icon: Icons.system_update,
                        title: 'Update Installed Apps (Winget)',
                        subtitle:
                            'Runs winget upgrade for installed software packages.',
                        onTap: _checkAppUpdates,
                      ),
                      _buildAdvancedActionTile(
                        icon: Icons.cleaning_services,
                        title: 'Full Windows Debloat Script',
                        subtitle:
                            'Safe cleanup script for optional UWP bloat components.',
                        onTap: _runWinScript,
                      ),
                      _buildAdvancedActionTile(
                        icon: Icons.construction,
                        title: 'Chris Titus Tech Windows Utility',
                        subtitle:
                            'Launches the external CTT utility for advanced tuning.',
                        onTap: _runChrisTitusTool,
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                border: Border(
                  top: BorderSide(color: Color(0xFFFF6B00), width: 1),
                ),
              ),
              child: const Center(
                child: Text(
                  'by Prime Build',
                  style: TextStyle(
                    color: Color(0xFFFF6B00),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF6B00), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAdvancedActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final accentColor = const Color(0xFFFF6B00);

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF3A3A3A), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          hoverColor: accentColor.withValues(alpha: 0.12),
          splashColor: accentColor.withValues(alpha: 0.20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
          leading: Icon(icon, color: accentColor),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _buildTweakTile(
    String title,
    String description,
    String key, {
    bool isEnabled = true,
    String? disabledReason,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF3A3A3A), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? Colors.white : Colors.white54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEnabled
                      ? description
                      : '$description${disabledReason != null ? '\n$disabledReason' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isEnabled
                        ? Colors.white.withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildToggleSwitch(key, isEnabled: isEnabled),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(String key, {bool isEnabled = true}) {
    final value = tweaks[key] ?? false;
    final isPending = _pendingTweaks.contains(key);

    if (isPending) {
      return const SizedBox(
        width: 30,
        height: 30,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
          ),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        if (!isEnabled || _pendingTweaks.contains(key)) return;

        final newValue = !value;
        final requiresRestart = _tweakRequiresRestart(key);

        setState(() {
          _pendingTweaks.add(key);
        });

        final result = await _tweakManager.applyTweak(key, newValue);
        if (!result.success) {
          final failureMessage = result.errors.isNotEmpty
              ? result.errors.first
              : 'One or more commands failed while applying this tweak.';

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF8B0000),
                content: Text('Failed to apply "$key": $failureMessage'),
              ),
            );
          }

          setState(() {
            _pendingTweaks.remove(key);
          });
          return;
        }

        setState(() {
          tweaks[key] = newValue;
          if (requiresRestart && newValue) {
            needsRestart = true;
          }
          _pendingTweaks.remove(key);
        });

        await _saveTweakState(key, newValue);
        if (requiresRestart && newValue) {
          await _saveRestartState(true);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: !isEnabled
              ? const Color(0xFF2D2D2D)
              : value
              ? const Color(0xFFFF6B00)
              : const Color(0xFF3A3A3A),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadAvailablePowerPlans() async {
    final result = await Process.run('powercfg', ['/list'], runInShell: true);
    if (result.exitCode != 0) {
      return;
    }

    final lines = result.stdout.toString().split('\n');
    final plans = <String>[];
    final seen = <String>{};

    final regex = RegExp(
      r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s+\((.+?)\)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match == null) continue;

      final planName = match.group(2)!.trim();
      final planKey = planName.toLowerCase();
      if (!seen.contains(planKey)) {
        seen.add(planKey);
        plans.add(planName);
      }
    }

    if (!mounted) return;
    setState(() {
      availablePowerPlans = plans;
    });
  }

  Future<void> _loadAggressivePowerPlans() async {
    final powerPlansDirectory = _resolveBundledPowerPlansDirectory();
    if (powerPlansDirectory == null) {
      return;
    }

    final aggressivePlans = await _tweakManager
        .detectAggressiveBundledPowerPlans(powerPlansDirectory);

    if (!mounted) return;
    setState(() {
      _aggressivePowerPlans
        ..clear()
        ..addAll(aggressivePlans);
    });
  }

  String? _resolveBundledPowerPlansDirectory() {
    final executableDirectory = path.dirname(Platform.resolvedExecutable);
    final candidates = <String>[
      path.join(
        executableDirectory,
        'data',
        'flutter_assets',
        'resources',
        'Powerplans',
      ),
      path.join(Directory.current.path, 'resources', 'Powerplans'),
    ];

    for (final candidate in candidates) {
      if (Directory(candidate).existsSync()) {
        return candidate;
      }
    }

    return null;
  }

  String _powerPlanLabel(String planName) {
    final normalizedPlan = planName.trim().toLowerCase();
    final isAggressive = _aggressivePowerPlans.contains(normalizedPlan);
    return isAggressive ? '$planName [Aggressive]' : planName;
  }

  Future<void> _getActivePowerPlan() async {
    final result = await Process.run('powercfg', [
      '/getactivescheme',
    ], runInShell: true);
    if (result.exitCode != 0) {
      return;
    }

    String? active;
    final output = result.stdout.toString();
    final activeMatch = RegExp(r'\((.+?)\)').firstMatch(output);
    if (activeMatch != null) {
      active = activeMatch.group(1)?.trim();
    }

    if (!mounted) return;
    setState(() {
      activePowerPlan = active;
    });
  }

  // Detect and remove duplicate power plans with the same name
  Future<void> _cleanAllDuplicatePowerPlans() async {
    final listResult = await Process.run('powercfg', [
      '/list',
    ], runInShell: true);
    if (listResult.exitCode == 0) {
      final lines = listResult.stdout.toString().split('\n');
      Map<String, List<String>> planGuids = {};

      // Group all GUIDs by plan name
      for (var line in lines) {
        final guidMatch = RegExp(
          r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s+\((.+?)\)',
          caseSensitive: false,
        ).firstMatch(line);
        if (guidMatch != null) {
          String guid = guidMatch.group(1)!;
          String planName = guidMatch.group(2)!.trim();

          if (!planGuids.containsKey(planName)) {
            planGuids[planName] = [];
          }
          planGuids[planName]!.add(guid);
        }
      }

      // For each plan name, if there are duplicates, keep only the first and delete the rest
      for (var entry in planGuids.entries) {
        if (entry.value.length > 1) {
          for (int i = 1; i < entry.value.length; i++) {
            await Process.run('powercfg', [
              '/delete',
              entry.value[i],
            ], runInShell: true);
          }
        }
      }
    }
  }

  Future<void> _removeDuplicatePowerPlans(String planName) async {
    final listResult = await Process.run('powercfg', [
      '/list',
    ], runInShell: true);
    if (listResult.exitCode == 0) {
      final lines = listResult.stdout.toString().split('\n');
      List<String> guids = [];

      // Find all GUIDs with the same plan name
      for (var line in lines) {
        if (line.contains(planName)) {
          final guidMatch = RegExp(
            r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',
            caseSensitive: false,
          ).firstMatch(line);
          if (guidMatch != null) {
            guids.add(guidMatch.group(1)!);
          }
        }
      }

      // If there are duplicates (more than 1), keep only the first one and delete the rest
      if (guids.length > 1) {
        for (int i = 1; i < guids.length; i++) {
          await Process.run('powercfg', [
            '/delete',
            guids[i],
          ], runInShell: true);
        }
      }
    }
  }

  Future<void> _activatePowerPlan(String planName) async {
    // First, remove any duplicate power plans with the same name
    await _removeDuplicatePowerPlans(planName);

    // Try to find the GUID of the power plan by name
    final listResult = await Process.run('powercfg', [
      '/list',
    ], runInShell: true);
    if (listResult.exitCode == 0) {
      final lines = listResult.stdout.toString().split('\n');
      String? guid;

      for (var line in lines) {
        if (line.contains(planName)) {
          // Extract GUID from line like: "Power Scheme GUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  (Plan Name)"
          final guidMatch = RegExp(
            r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})',
            caseSensitive: false,
          ).firstMatch(line);
          if (guidMatch != null) {
            guid = guidMatch.group(1);
            break;
          }
        }
      }

      if (guid != null) {
        // Power plan exists, just activate it
        final result = await Process.run('powercfg', [
          '/setactive',
          guid,
        ], runInShell: true);
        if (result.exitCode == 0) {
          await _getActivePowerPlan();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Activated power plan: $planName'),
                backgroundColor: const Color(0xFFFF6B00),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to activate power plan: ${result.stderr}',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      } else {
        // Power plan not found in system - try to import it if it's bundled
        final bundledPlans = [
          'Exm Free Power Plan V6',
          'adamx',
          'ancel',
          'atlas',
          'bitsum',
          'calypto',
          'core',
          'exmfree',
          'hybred',
          'kaisen',
          'kirby',
          'khorvie',
          'kizzimo',
          'lawliet',
          'nexus',
          'powerx',
          'sapphire',
          'vtrl',
          'xilly',
          'xos',
          'FrameSyncBoost',
        ];

        if (bundledPlans.contains(planName)) {
          // Import the bundled power plan (only happens if not found)
          final exePath = Platform.resolvedExecutable;
          final exeDir = path.dirname(exePath);
          final powerPlanPath = path.join(
            exeDir,
            'data',
            'flutter_assets',
            'resources',
            'Powerplans',
            '$planName.pow',
          );

          final file = File(powerPlanPath);
          if (await file.exists()) {
            final importResult = await Process.run('powercfg', [
              '/import',
              powerPlanPath,
            ], runInShell: true);
            if (importResult.exitCode == 0) {
              // Import successful, now activate it
              await Future.delayed(const Duration(milliseconds: 500));
              await _activatePowerPlan(planName); // Recursive call after import
              return;
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to import power plan: ${importResult.stderr}',
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Power plan file not found: $powerPlanPath'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Power plan "$planName" not found. Please import it first.',
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _importBundledPowerPlan() async {
    // Show dialog to select from bundled power plans
    if (!mounted) return;

    final bundledPlans = [
      'Exm Free Power Plan V6',
      'adamx',
      'ancel',
      'atlas',
      'bitsum',
      'calypto',
      'core',
      'exmfree',
      'hybred',
      'kaisen',
      'kirby',
      'khorvie',
      'kizzimo',
      'lawliet',
      'nexus',
      'powerx',
      'sapphire',
      'vtrl',
      'xilly',
      'xos',
      'FrameSyncBoost',
    ];

    String? selectedPlan = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Select Bundled Power Plan',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bundledPlans.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  _powerPlanLabel(bundledPlans[index]),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.of(context).pop(bundledPlans[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFFF6B00)),
            ),
          ),
        ],
      ),
    );

    if (selectedPlan != null) {
      // Get the executable directory to find the bundled power plans
      final exePath = Platform.resolvedExecutable;
      final exeDir = path.dirname(exePath);
      final powerPlanPath = path.join(
        exeDir,
        'data',
        'flutter_assets',
        'resources',
        'Powerplans',
        '$selectedPlan.pow',
      );

      final file = File(powerPlanPath);
      if (await file.exists()) {
        final result = await Process.run('powercfg', [
          '/import',
          powerPlanPath,
        ], runInShell: true);
        if (result.exitCode == 0) {
          await _loadAvailablePowerPlans();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Imported power plan: $selectedPlan'),
                backgroundColor: const Color(0xFFFF6B00),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to import: ${result.stderr}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Power plan file not found: $powerPlanPath'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _importCustomPowerPlan() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pow'],
      dialogTitle: 'Select Custom Power Plan',
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      final importResult = await Process.run('powercfg', [
        '/import',
        filePath,
      ], runInShell: true);

      if (importResult.exitCode == 0) {
        await _loadAvailablePowerPlans();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Custom power plan imported successfully'),
              backgroundColor: const Color(0xFFFF6B00),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to import: ${importResult.stderr}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _runWinScript() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFFF6B00)),
            SizedBox(width: 12),
            Text('Full Windows Debloat', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This will execute a comprehensive Windows debloat script that removes:\n\n'
          '• Bloatware and unnecessary apps\n'
          '• Telemetry and tracking services\n'
          '• Windows features you may not need\n\n'
          'A system restart will be required after completion.\n\n'
          'Do you want to proceed?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
            ),
            child: const Text('Execute Script'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        String scriptPath = path.join(
          path.dirname(Platform.resolvedExecutable),
          'data',
          'flutter_assets',
          'resources',
          'winscript.bat',
        );

        // Run script in a new cmd window (not silent)
        await Process.start('cmd', [
          '/c',
          'start',
          'cmd',
          '/k',
          scriptPath,
        ], runInShell: true);

        if (mounted) {
          // Activate restart required
          setState(() {
            needsRestart = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Debloat script started! Check the command window. Restart required after completion.',
              ),
              backgroundColor: Color(0xFFFF6B00),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
            ),
          );
        }

        await _saveRestartState(true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to run script: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _runChrisTitusTool() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Row(
          children: [
            Icon(Icons.construction, color: Color(0xFFFF6B00)),
            SizedBox(width: 12),
            Text(
              'Chris Titus Tech Tool',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'This will launch the local PrimeBuild tweak console script.\n\n'
          'Remote script execution has been removed for security reasons.\n\n'
          'The tool will open in a separate command window.\n\n'
          'Do you want to proceed?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
            ),
            child: const Text('Launch Local Tool'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final scriptCandidates = [
          path.join(
            path.dirname(Platform.resolvedExecutable),
            'data',
            'flutter_assets',
            'resources',
            'PrimeBuild_TweakConsole.cmd',
          ),
          path.join(
            Directory.current.path,
            'resources',
            'PrimeBuild_TweakConsole.cmd',
          ),
        ];

        String? scriptPath;
        for (final candidate in scriptCandidates) {
          if (await File(candidate).exists()) {
            scriptPath = candidate;
            break;
          }
        }

        if (scriptPath == null) {
          throw Exception(
            'Local tool not found: resources/PrimeBuild_TweakConsole.cmd',
          );
        }

        await Process.start('cmd', [
          '/c',
          'start',
          'cmd',
          '/k',
          scriptPath,
        ], runInShell: true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Local tweak console launched. Check the command window.',
              ),
              backgroundColor: Color(0xFFFF6B00),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to launch tool: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _restartSystem() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Row(
          children: [
            Icon(Icons.restart_alt, color: Color(0xFFFF6B00)),
            SizedBox(width: 12),
            Text('System Restart', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'The system will restart to apply changes.\n\nDo you want to continue?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
            ),
            child: const Text('Restart Now'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Reset restart required state
      setState(() {
        needsRestart = false;
      });
      await _saveRestartState(false);

      // Execute system restart
      await Process.run('shutdown', [
        '/r',
        '/t',
        '5',
        '/c',
        'ZapTweaks: Restarting to apply changes...',
      ], runInShell: true);

      // Show confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('System will restart in 5 seconds...'),
            backgroundColor: Color(0xFFFF6B00),
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showAboutDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Row(
          children: [
            Icon(Icons.bolt, color: Color(0xFFFF6B00)),
            SizedBox(width: 12),
            Text('ZapTweaks', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('by Prime Build', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 8),
            Text(
              'Version: v$_currentAppVersion',
              style: TextStyle(
                color: Color(0xFFFF6B00),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _checkForUpdates();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
            ),
            child: const Text('Check for Updates'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    if (!mounted) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(_latestReleaseApiUrl),
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'ZapTweaks/$_currentAppVersion',
        },
      );

      if (response.statusCode != 200) {
        await _showUpdateErrorDialog(
          'GitHub API error (${response.statusCode}). Please try again later.',
        );
        return;
      }

      final payload = jsonDecode(response.body);
      if (payload is! Map<String, dynamic>) {
        await _showUpdateErrorDialog('Invalid response received from GitHub.');
        return;
      }

      final tagName = (payload['tag_name'] ?? '').toString().trim();
      if (tagName.isEmpty) {
        await _showUpdateErrorDialog('Latest release version not found.');
        return;
      }

      final remoteVersion = _normalizeVersion(tagName);
      final hasUpdate = _isRemoteVersionNewer(
        remoteVersion,
        _currentAppVersion,
      );

      if (!mounted) {
        return;
      }

      if (hasUpdate) {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Row(
              children: [
                Icon(Icons.system_update, color: Color(0xFFFF6B00)),
                SizedBox(width: 12),
                Text('Update Available', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              'A newer version is available.\n\n'
              'Current: v$_currentAppVersion\n'
              'Latest: v$remoteVersion',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'Later',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _openReleasesPage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Download Update'),
              ),
            ],
          ),
        );
      } else {
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFFFF6B00)),
                SizedBox(width: 12),
                Text('Up to Date', style: TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              'You are running the latest version (v$_currentAppVersion).',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B00),
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (_) {
      await _showUpdateErrorDialog(
        'Unable to check updates right now. Check your internet connection and try again.',
      );
    }
  }

  String _normalizeVersion(String rawVersion) {
    final sanitized = rawVersion.trim().replaceFirst(RegExp(r'^[vV]'), '');
    return sanitized;
  }

  bool _isRemoteVersionNewer(String remoteVersion, String localVersion) {
    final remoteParts = _parseVersionParts(remoteVersion);
    final localParts = _parseVersionParts(localVersion);
    final maxLength = remoteParts.length > localParts.length
        ? remoteParts.length
        : localParts.length;

    for (var i = 0; i < maxLength; i++) {
      final remote = i < remoteParts.length ? remoteParts[i] : 0;
      final local = i < localParts.length ? localParts[i] : 0;

      if (remote > local) {
        return true;
      }
      if (remote < local) {
        return false;
      }
    }

    return false;
  }

  List<int> _parseVersionParts(String version) {
    final cleanVersion = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    return cleanVersion
        .split('.')
        .map(
          (part) => int.tryParse(part.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        )
        .toList();
  }

  Future<void> _openReleasesPage() async {
    final releaseUri = Uri.parse(_releasesPageUrl);
    final launched = await launchUrl(
      releaseUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF8B0000),
          content: Text('Unable to open browser for release download.'),
        ),
      );
    }
  }

  Future<void> _showUpdateErrorDialog(String message) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFFF6B00)),
            SizedBox(width: 12),
            Text('Update Check Failed', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAppUpdates() async {
    // State variables for the dialog
    String currentApp = 'Checking for updates...';
    double progress = 0.0;
    bool isComplete = false;
    String resultMessage = '';
    int updatedCount = 0;

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Start winget upgrade process
            if (!isComplete && progress == 0.0) {
              _runWingetUpgrade((app, prog, complete, message, count) {
                setDialogState(() {
                  currentApp = app;
                  progress = prog;
                  isComplete = complete;
                  resultMessage = message;
                  updatedCount = count;
                });
              });
              progress = 0.01; // Mark as started
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF2A2A2A),
              title: Row(
                children: [
                  Icon(
                    isComplete ? Icons.check_circle : Icons.update,
                    color: const Color(0xFFFF6B00),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isComplete ? 'Update Complete' : 'Updating Apps',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isComplete) ...[
                      Text(
                        currentApp,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress > 0.01 ? progress : null,
                          backgroundColor: const Color(0xFF1C1C1C),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF6B00),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        progress > 0.01
                            ? '${(progress * 100).toInt()}%'
                            : 'Starting...',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ] else ...[
                      Text(
                        resultMessage,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (updatedCount > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          '$updatedCount app(s) updated successfully',
                          style: const TextStyle(
                            color: Color(0xFFFF6B00),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              actions: [
                if (isComplete)
                  ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('OK'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _runWingetUpgrade(
    Function(String, double, bool, String, int) onUpdate,
  ) async {
    try {
      // First, list available updates
      onUpdate('Scanning for available updates...', 0.05, false, '', 0);

      final listResult = await Process.run('winget', [
        'upgrade',
        '--include-unknown',
      ], runInShell: true);

      // Parse the list output to count available updates
      final listOutput = listResult.stdout.toString();
      final lines = listOutput.split('\n');
      int availableUpdates = 0;

      for (final line in lines) {
        if (line.contains('winget upgrade') ||
            line.trim().isEmpty ||
            line.contains('Name') ||
            line.contains('---')) {
          continue;
        }
        if (line.trim().isNotEmpty &&
            !line.contains('upgrade available') &&
            !line.contains('upgrades available')) {
          availableUpdates++;
        }
      }

      if (availableUpdates == 0 ||
          listOutput.contains('No installed package found matching')) {
        onUpdate('', 1.0, true, 'All apps are up to date!', 0);
        return;
      }

      onUpdate(
        'Found $availableUpdates update(s). Starting upgrade...',
        0.1,
        false,
        '',
        0,
      );

      // Run winget upgrade --all
      final process = await Process.start('winget', [
        'upgrade',
        '--all',
        '--silent',
        '--accept-package-agreements',
        '--accept-source-agreements',
        '--disable-interactivity',
      ], runInShell: true);

      int updatedApps = 0;
      String lastApp = '';

      // Listen to stdout
      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        final outputLines = data.split('\n');
        for (final line in outputLines) {
          if (line.trim().isEmpty) continue;

          // Try to extract app name being updated
          if (line.contains('Successfully installed') ||
              line.contains('Successfully upgraded')) {
            updatedApps++;
            final progress = (0.1 + (0.85 * updatedApps / availableUpdates))
                .clamp(0.1, 0.95);
            onUpdate('Completed: $line', progress, false, '', updatedApps);
          } else if (line.contains('Installing') ||
              line.contains('Downloading') ||
              line.contains('Found')) {
            lastApp = line.trim();
            final progress = (0.1 + (0.85 * updatedApps / availableUpdates))
                .clamp(0.1, 0.95);
            onUpdate(lastApp, progress, false, '', updatedApps);
          }
        }
      });

      // Listen to stderr
      process.stderr.transform(const SystemEncoding().decoder).listen((data) {
        // Ignore most stderr as winget outputs progress there
      });

      // Wait for process to complete
      final exitCode = await process.exitCode;

      if (exitCode == 0 || updatedApps > 0) {
        onUpdate('', 1.0, true, 'Update process completed!', updatedApps);
      } else {
        onUpdate(
          '',
          1.0,
          true,
          'Update completed. Some apps may have been skipped.',
          updatedApps,
        );
      }
    } catch (e) {
      onUpdate('', 1.0, true, 'Error: $e', 0);
    }
  }
}
