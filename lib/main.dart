import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  // App version for update checking
  static const String currentVersion = '1.0.0';
  static const String githubRepo = 'PrimeBuild-pc/ZapTweaks';

  // Tweak states
  Map<String, bool> tweaks = {
    // Boot & BCD
    'bcd_optimizations': false,
    // CPU - Common
    'cpu_unparking': false,
    'cpu_power_management': false,
    // CPU - Intel Specific
    'cpu_intel_optimizations': false,  // Intel 12th gen+ P-core/E-core scheduling
    // CPU - AMD Specific
    'cpu_amd_optimizations': false,  // AMD Ryzen specific optimizations
    // GPU - NVIDIA
    'gpu_nvidia_optimizations': false,
    // GPU - AMD
    'gpu_amd_optimizations': false,
    // GPU - Intel Arc
    'gpu_intel_optimizations': false,
    // RAM
    'ram_optimizations': false,
    // Storage
    'storage_optimizations': false,
    // Network
    'network_optimizations': false,
    // System
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
    'fullscreen_optimizations': false,
  };

  bool needsRestart = false;
  List<String> availablePowerPlans = [];
  String? activePowerPlan;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSavedState();
    await _cleanAllDuplicatePowerPlans();
    await _loadAvailablePowerPlans();
    await _getActivePowerPlan();
  }

  Future<void> _loadSavedState() async {
    if (_prefs == null) return;

    setState(() {
      // Carica lo stato di ogni tweak
      tweaks.forEach((key, value) {
        tweaks[key] = _prefs!.getBool(key) ?? false;
      });

      // Load restart required state
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
    // Almost all tweaks require restart (they modify registry or services)
    // Only power plan imports don't require restart
    const noRestartRequired = [
      // Power plans apply immediately
    ];

    // All other tweaks require restart
    return !noRestartRequired.contains(key);
  }

  Future<void> _loadAvailablePowerPlans() async {
    // Hardcoded list of bundled power plans
    final bundledPlans = [
      'Exm Free Power Plan V6',
      'adamx',
      'ancel',
      'core',
      'exmfree',
      'hybred',
      'khorvie',
      'lawliet',
      'powerx',
      'xilly',
      'atlas',
      'bitsum',
      'calypto',
      'kaisen',
      'kirby',
      'kizzimo',
      'nexus',
      'sapphire',
      'vtrl',
      'xos',
      'FrameSyncBoost',
    ];

    // Get all system power plans
    final result = await Process.run('powercfg', ['/list'], runInShell: true);
    final systemPlans = <String>[];
    if (result.exitCode == 0) {
      final lines = result.stdout.toString().split('\n');
      for (var line in lines) {
        if (line.contains('(') && line.contains(')')) {
          final match = RegExp(r'\(([^)]+)\)').firstMatch(line);
          if (match != null) {
            systemPlans.add(match.group(1)!);
          }
        }
      }
    }

    setState(() {
      // Combine bundled plans with system plans (remove duplicates)
      final allPlans = <String>{...bundledPlans, ...systemPlans};
      availablePowerPlans = allPlans.toList()..sort();
    });
  }

  Future<void> _getActivePowerPlan() async {
    final result = await Process.run('powercfg', ['/getactivescheme'], runInShell: true);
    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      final match = RegExp(r'\(([^)]+)\)').firstMatch(output);
      if (match != null) {
        setState(() {
          activePowerPlan = match.group(1);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WindowBorder(
        color: const Color(0xFFFF6B00),
        width: 1,
        child: Column(
          children: [
            // Custom Title Bar
            WindowTitleBarBox(
              child: Container(
                color: const Color(0xFF1C1C1C),
                child: Row(
                  children: [
                    Expanded(
                      child: MoveWindow(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  // Restart icon (visible only when needed)
                                  if (needsRestart)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF6B00),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.restart_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  if (needsRestart) const SizedBox(width: 8),
                                  Icon(
                                    Icons.bolt,
                                    color: const Color(0xFFFF6B00),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'ZapTweaks',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'by PrimeBuild',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFFFF6B00),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Check for updates button
                    Tooltip(
                      message: 'Check for updates',
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _checkForUpdates,
                          child: Container(
                            width: 46,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.system_update,
                                color: Color(0xFFFF6B00),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Restart button (always visible)
                    Tooltip(
                      message: needsRestart ? 'Restart system' : 'No restart required',
                      child: MouseRegion(
                        cursor: needsRestart ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        child: GestureDetector(
                          onTap: needsRestart ? _restartSystem : null,
                          child: Container(
                            width: 46,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.restart_alt,
                                color: needsRestart ? const Color(0xFFFF6B00) : const Color(0xFF4A4A4A),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    MinimizeWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: Colors.white,
                        iconMouseOver: const Color(0xFFFF6B00),
                        mouseOver: const Color(0xFF2A2A2A),
                      ),
                    ),
                    CloseWindowButton(
                      colors: WindowButtonColors(
                        iconNormal: Colors.white,
                        iconMouseOver: Colors.white,
                        mouseOver: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (needsRestart)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFF6B00),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.restart_alt,
                            color: const Color(0xFFFF6B00),
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
                        ],
                      ),
                    ),

                  _buildSection(
                    'Boot & System Configuration',
                    Icons.power_settings_new,
                    [
                      _buildTweakTile(
                        'Advanced Boot Optimizations',
                        'BCDedit: Dynamic Tick, HPET, TSC, memory, MSI mode',
                        'bcd_optimizations',
                        () => _applyBcdOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'CPU Performance',
                    Icons.memory,
                    [
                      _buildTweakTile(
                        'CPU Core Unparking',
                        'Unparks all CPU cores (All CPUs)',
                        'cpu_unparking',
                        () => _applyCpuUnparking,
                      ),
                      _buildTweakTile(
                        'CPU Power Management',
                        'Disables C-States, throttling, Win32Priority (All CPUs)',
                        'cpu_power_management',
                        () => _applyCpuPowerManagement,
                      ),
                      _buildTweakTile(
                        'Intel CPU Optimizations',
                        'Heterogeneous P/E-core scheduling (12th gen+)',
                        'cpu_intel_optimizations',
                        () => _applyIntelCpuOptimizations,
                      ),
                      _buildTweakTile(
                        'AMD Ryzen Optimizations',
                        'AMD-specific power and performance tweaks',
                        'cpu_amd_optimizations',
                        () => _applyAmdCpuOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'GPU - NVIDIA',
                    Icons.videogame_asset,
                    [
                      _buildTweakTile(
                        'NVIDIA RTX Optimizations',
                        'GPU priority max, HAGS, TDR delay, game task scheduling',
                        'gpu_nvidia_optimizations',
                        () => _applyNvidiaOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'GPU - AMD Radeon',
                    Icons.sports_esports,
                    [
                      _buildTweakTile(
                        'AMD Radeon Optimizations',
                        'ULPS, PowerPlay, DRR, thermal throttling, VRAM clocks',
                        'gpu_amd_optimizations',
                        () => _applyAmdOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'GPU - Intel Arc',
                    Icons.computer,
                    [
                      _buildTweakTile(
                        'Intel Arc Optimizations',
                        'XeSS, ReBAR, shader cache 4GB, ASPM, deep link, DPST',
                        'gpu_intel_optimizations',
                        () => _applyIntelOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'Memory (RAM)',
                    Icons.storage,
                    [
                      _buildTweakTile(
                        'RAM Optimizations',
                        'Paging executive, cache, superfetch, prefetch, SysMain',
                        'ram_optimizations',
                        () => _applyRamOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'Storage (SSD/NVMe)',
                    Icons.sd_storage,
                    [
                      _buildTweakTile(
                        'Storage Optimizations',
                        'NTFS, TRIM, compression, indexing, AHCI power mgmt',
                        'storage_optimizations',
                        () => _applyStorageOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'Network & Latency',
                    Icons.network_check,
                    [
                      _buildTweakTile(
                        'Network Optimizations',
                        'TCP optimizer, throttling disable, interrupt moderation',
                        'network_optimizations',
                        () => _applyNetworkOptimizations,
                      ),
                      _buildTweakTile(
                        'Timer & Latency',
                        'MMCSS, audio latency, timer resolution, system response',
                        'timer_latency',
                        () => _applyTimerLatency,
                      ),
                    ],
                  ),

                  _buildSection(
                    'Visual Effects & UI',
                    Icons.visibility,
                    [
                      _buildTweakTile(
                        'Disable Visual Effects',
                        'Animations, transparency, blur, Aero, Start Menu effects',
                        'visual_effects',
                        () => _applyVisualEffects,
                      ),
                      _buildTweakTile(
                        'System Responsiveness',
                        'Menu delay 0ms, hover time, task kill timeouts reduced',
                        'system_responsiveness',
                        () => _applySystemResponsiveness,
                      ),
                      _buildTweakTile(
                        'UI Optimizations',
                        'Taskbar, Start Menu, widgets, search box, meet now',
                        'ui_optimizations',
                        () => _applyUiOptimizations,
                      ),
                      _buildTweakTile(
                        'Explorer Optimizations',
                        'Thumbnails, cache, quick access, file extensions shown',
                        'explorer_optimizations',
                        () => _applyExplorerOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'Privacy & Telemetry',
                    Icons.privacy_tip,
                    [
                      _buildTweakTile(
                        'Disable Telemetry',
                        'DiagTrack, feedback, Cortana, error reporting, CEIP',
                        'telemetry_disable',
                        () => _applyTelemetryDisable,
                      ),
                      _buildTweakTile(
                        'Privacy & Tracking',
                        'Location, ads, sync, activity history, Spotlight, apps',
                        'privacy_tracking',
                        () => _applyPrivacyTracking,
                      ),
                    ],
                  ),

                  _buildSection(
                    'Services & Background',
                    Icons.settings,
                    [
                      _buildTweakTile(
                        'Disable Unused Services',
                        'Xbox, diagnostics, search, maps, remote, fax, insider',
                        'services_disable',
                        () => _applyServicesDisable,
                      ),
                      _buildTweakTile(
                        'Notifications Minimal',
                        'Toast, focus assist, lockscreen notifications disabled',
                        'notifications_minimal',
                        () => _applyNotificationsMinimal,
                      ),
                    ],
                  ),

                  _buildSection(
                    'Gaming Tweaks',
                    Icons.sports_esports,
                    [
                      _buildTweakTile(
                        'Disable Game Mode',
                        'Prevents micro-stuttering and scheduling issues',
                        'game_mode',
                        () => _applyGameMode,
                      ),
                      _buildTweakTile(
                        'Fullscreen Optimizations',
                        'Disables FSE optimizations and Game DVR completely',
                        'fullscreen_optimizations',
                        () => _applyFullscreenOptimizations,
                      ),
                    ],
                  ),

                  _buildSection(
                    'Windows Update',
                    Icons.system_update,
                    [
                      _buildTweakTile(
                        'Update Optimizations',
                        'Auto-reboot off, P2P delivery off, 50% bandwidth, no driver updates',
                        'windows_update',
                        () => _applyWindowsUpdate,
                      ),
                    ],
                  ),

                  // Check App Updates Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: ElevatedButton.icon(
                      onPressed: _checkAppUpdates,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.update),
                      label: const Text('Check App Updates'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Power Plan Management
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

                        // Active power plan display
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Active Plan',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        activePowerPlan!,
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

                        // Dropdown to select and activate power plan
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF6B00)),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              items: availablePowerPlans.map((plan) {
                                return DropdownMenuItem<String>(
                                  value: plan,
                                  child: Text(plan),
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

                        const SizedBox(height: 12),

                        // Import buttons
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _importBundledPowerPlan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B00),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.folder_special, size: 18),
                                label: const Text('Bundled', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _importCustomPowerPlan,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3A3A3A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.upload_file, size: 18),
                                label: const Text('Custom', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Advanced Tools Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
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
                          Icon(
                            Icons.build_circle,
                            color: const Color(0xFFFF6B00),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Advanced Tools',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // WinScript.bat Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: ElevatedButton.icon(
                        onPressed: _runWinScript,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        icon: const Icon(Icons.cleaning_services, size: 20),
                        label: const Text(
                          'Full Windows Debloat Script',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    // Chris Titus Tech Tool Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ElevatedButton.icon(
                        onPressed: _runChrisTitusTool,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A3A3A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(double.infinity, 0),
                        ),
                        icon: const Icon(Icons.construction, size: 20),
                        label: const Text(
                          'Chris Titus Tech Windows Utility',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF1C1C1C),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFFF6B00),
                    width: 1,
                  ),
                ),
              ),
              child: Center(
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
                Icon(
                  icon,
                  color: const Color(0xFFFF6B00),
                  size: 24,
                ),
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

  Widget _buildTweakTile(
    String title,
    String description,
    String key,
    Function Function() applyFunction,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF3A3A3A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildToggleSwitch(key, applyFunction),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(String key, Function Function() applyFunction) {
    bool value = tweaks[key] ?? false;
    return GestureDetector(
      onTap: () async {
        bool newValue = !value;
        
        // Determine IMMEDIATELY if restart is required (before applying)
        final requiresRestart = _tweakRequiresRestart(key);

        setState(() {
          tweaks[key] = newValue;
          // Activate restart icon IMMEDIATELY if needed
          if (requiresRestart && newValue) {
            needsRestart = true;
          }
        });

        // Save state
        await _saveTweakState(key, newValue);
        if (requiresRestart && newValue) {
          await _saveRestartState(true);
        }

        // Apply tweak in background (doesn't block UI)
        applyFunction()();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? const Color(0xFFFF6B00) : const Color(0xFF3A3A3A),
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

  // CPU Tweaks
  Future<void> Function(bool) get _applyCpuCStates => (bool enable) async {
        await _runCommand(
          enable
              ? 'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power" /v "CsEnabled" /t REG_DWORD /d 0 /f'
              : 'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power" /v "CsEnabled" /f',
        );
      };

  Future<void> Function(bool) get _applyCoreParking => (bool enable) async {
        await _runCommand(
          'powercfg /setacvalueindex scheme_current sub_processor CPMINCORES ${enable ? "100" : "5"}',
        );
        await _runCommand(
          'powercfg /setacvalueindex scheme_current sub_processor CPMAXCORES 100',
        );
        await _runCommand('powercfg /setactive scheme_current');
      };

  Future<void> Function(bool) get _applyCpuThrottling => (bool enable) async {
        await _runCommand(
          enable
              ? 'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f'
              : 'reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerThrottling" /v "PowerThrottlingOff" /f',
        );
        await _runCommand(
          'powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN ${enable ? "100" : "5"}',
        );
        await _runCommand(
          'powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100',
        );
        await _runCommand('powercfg /setactive scheme_current');
      };

  Future<void> Function(bool) get _applyCoreUnparking => (bool enable) async {
        await _runCommand(
          'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power" /v "CoreParkingDisabled" /t REG_DWORD /d ${enable ? "1" : "0"} /f',
        );
      };

  // GPU Tweaks
  Future<void> Function(bool) get _applyGpuHags => (bool enable) async {
        await _runCommand(
          'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d ${enable ? "2" : "1"} /f',
        );
      };

  Future<void> Function(bool) get _applyGpuMpo => (bool enable) async {
        if (enable) {
          await _runCommand(
            'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\Dwm" /v "OverlayTestMode" /t REG_DWORD /d 5 /f',
          );
        } else {
          await _runCommand(
            'reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows\\Dwm" /v "OverlayTestMode" /f',
          );
        }
      };

  // RAM Tweaks
  Future<void> Function(bool) get _applyRamPaging => (bool enable) async {
        await _runCommand(
          'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d ${enable ? "1" : "0"} /f',
        );
      };

  Future<void> Function(bool) get _applyRamSysMain => (bool enable) async {
        await _runCommand('sc config "SysMain" start= ${enable ? "disabled" : "auto"}');
        if (enable) {
          await _runCommand('net stop "SysMain"');
        } else {
          await _runCommand('net start "SysMain"');
        }
      };

  // SSD Tweaks
  Future<void> Function(bool) get _applySsdTrim => (bool enable) async {
        await _runCommand('fsutil behavior set DisableDeleteNotify ${enable ? "0" : "1"}');
      };

  Future<void> Function(bool) get _applySsdAhci => (bool enable) async {
        await _runCommand(
          'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\storahci\\Parameters\\Device" /v "EnableHIPM" /t REG_DWORD /d ${enable ? "0" : "1"} /f',
        );
        await _runCommand(
          'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\storahci\\Parameters\\Device" /v "EnableDIPM" /t REG_DWORD /d ${enable ? "0" : "1"} /f',
        );
      };

  Future<void> Function(bool) get _applyNvmeOptimization => (bool enable) async {
        await _runCommand(
          'powercfg -setacvalueindex scheme_current SUB_PCIEXPRESS ASPM ${enable ? "0" : "2"}',
        );
        await _runCommand(
          'powercfg -setacvalueindex scheme_current SUB_USB USBSELECTIVE ${enable ? "0" : "1"}',
        );
        await _runCommand(
          'powercfg -setacvalueindex scheme_current SUB_DISK DISKIDLE ${enable ? "0" : "10"}',
        );
        await _runCommand('powercfg -setactive scheme_current');
      };

  // Scheduling Tweaks
  Future<void> Function(bool) get _applySchedulingPriority => (bool enable) async {
        await _runCommand(
          'reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d ${enable ? "0x00000026" : "0x00000002"} /f',
        );
      };

  Future<void> Function(bool) get _applySchedulingMmcss => (bool enable) async {
        await _runCommand(
          'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d ${enable ? "0" : "20"} /f',
        );
        await _runCommand(
          'reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d ${enable ? "0xffffffff" : "10"} /f',
        );
      };

  Future<void> Function(bool) get _applySchedulingGameDvr => (bool enable) async {
        await _runCommand(
          'reg add "HKCU\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d ${enable ? "0" : "1"} /f',
        );
        await _runCommand(
          'reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d ${enable ? "0" : "1"} /f',
        );
      };

  // Boot Configuration Tweaks
  Future<void> Function(bool) get _applyBcdDynamicTick => (bool enable) async {
        if (enable) {
          await _runCommand('bcdedit /set disabledynamictick yes');
          await _runCommand('bcdedit /set useplatformtick yes');
        } else {
          await _runCommand('bcdedit /deletevalue disabledynamictick');
          await _runCommand('bcdedit /deletevalue useplatformtick');
        }
      };

  Future<void> Function(bool) get _applyBcdTsc => (bool enable) async {
        if (enable) {
          await _runCommand('bcdedit /set tscsyncpolicy enhanced');
        } else {
          await _runCommand('bcdedit /deletevalue tscsyncpolicy');
        }
      };

  // MSI Mode
  Future<void> Function(bool) get _applyMsiMode => (bool enable) async {
        if (enable) {
          // Enable MSI mode for devices
          final psScript = '''
\$devs = @()
\$devs += Get-PnpDevice -Class Net -PresentOnly | Where-Object { \$_.Status -eq "OK" -and \$_.Manufacturer -match "Realtek" }
\$devs += Get-PnpDevice -Class Display -PresentOnly | Where-Object { \$_.Status -eq "OK" -and (\$_.Manufacturer -match "NVIDIA|Advanced Micro Devices|AMD") }
\$devs += Get-PnpDevice -PresentOnly | Where-Object { \$_.Status -eq "OK" -and (\$_.FriendlyName -match "NVMe" -or \$_.InstanceId -match "NVME") }
\$devs += Get-PnpDevice -PresentOnly | Where-Object { \$_.Status -eq "OK" -and (\$_.FriendlyName -match "xHCI|USB 3\\.|USB3|USB eXtensible Host Controller") }
\$devs = \$devs | Sort-Object InstanceId -Unique
foreach (\$dev in \$devs) {
  \$base = "HKLM:\\SYSTEM\\CurrentControlSet\\Enum\\\$(\$dev.InstanceId)\\Device Parameters\\Interrupt Management"
  \$msi = Join-Path \$base "MessageSignaledInterruptProperties"
  \$aff = Join-Path \$base "Affinity Policy"
  if (-not (Test-Path \$msi)) { New-Item -Path \$msi -Force | Out-Null }
  if (-not (Test-Path \$aff)) { New-Item -Path \$aff -Force | Out-Null }
  New-ItemProperty -Path \$msi -Name MSISupported -PropertyType DWord -Value 1 -Force | Out-Null
  New-ItemProperty -Path \$aff -Name DevicePolicy -PropertyType DWord -Value 5 -Force | Out-Null
}
''';
          await Process.run('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psScript], runInShell: true);
        } else {
          // Disable MSI mode (revert)
          final psScript = '''
\$devs = @()
\$devs += Get-PnpDevice -Class Net -PresentOnly | Where-Object { \$_.Status -eq "OK" -and \$_.Manufacturer -match "Realtek" }
\$devs += Get-PnpDevice -Class Display -PresentOnly | Where-Object { \$_.Status -eq "OK" -and (\$_.Manufacturer -match "NVIDIA|Advanced Micro Devices|AMD") }
\$devs += Get-PnpDevice -PresentOnly | Where-Object { \$_.Status -eq "OK" -and (\$_.FriendlyName -match "NVMe" -or \$_.InstanceId -match "NVME") }
\$devs += Get-PnpDevice -PresentOnly | Where-Object { \$_.Status -eq "OK" -and (\$_.FriendlyName -match "xHCI|USB 3\\.|USB3|USB eXtensible Host Controller") }
\$devs = \$devs | Sort-Object InstanceId -Unique
foreach (\$dev in \$devs) {
  \$base = "HKLM:\\SYSTEM\\CurrentControlSet\\Enum\\\$(\$dev.InstanceId)\\Device Parameters\\Interrupt Management"
  \$msi = Join-Path \$base "MessageSignaledInterruptProperties"
  \$aff = Join-Path \$base "Affinity Policy"
  if (Test-Path \$msi) { Remove-ItemProperty -Path \$msi -Name MSISupported -ErrorAction SilentlyContinue }
  if (Test-Path \$aff) { Remove-ItemProperty -Path \$aff -Name DevicePolicy -ErrorAction SilentlyContinue }
}
''';
          await Process.run('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psScript], runInShell: true);
        }
      };

  // ==========================================================================
  // NEW COMPREHENSIVE IMPLEMENTATIONS
  // ==========================================================================

  // BCD OPTIMIZATIONS
  Future<void> Function(bool) get _applyBcdOptimizations => (bool enable) async {
    if (enable) {
      await _runCommand('bcdedit /set disabledynamictick yes');
      await _runCommand('bcdedit /deletevalue useplatformclock');
      await _runCommand('bcdedit /set useplatformtick yes');
      await _runCommand('bcdedit /set tscsyncpolicy enhanced');
      await _runCommand('bcdedit /set firstmegabytepolicy UseAll');
      await _runCommand('bcdedit /set avoidlowmemory 0x8000000');
      await _runCommand('bcdedit /set nolowmem yes');
      await _runCommand('bcdedit /set x2apicpolicy Enable');
      await _runCommand('bcdedit /set configaccesspolicy Default');
      await _runCommand('bcdedit /set MSI Default');
      await _runCommand('bcdedit /set bootux disabled');
      await _runCommand('bcdedit /set bootmenupolicy legacy');
      await _runCommand('bcdedit /set quietboot yes');
    } else {
      await _runCommand('bcdedit /deletevalue disabledynamictick');
      await _runCommand('bcdedit /deletevalue useplatformtick');
      await _runCommand('bcdedit /deletevalue tscsyncpolicy');
      await _runCommand('bcdedit /deletevalue firstmegabytepolicy');
      await _runCommand('bcdedit /deletevalue avoidlowmemory');
      await _runCommand('bcdedit /deletevalue nolowmem');
      await _runCommand('bcdedit /deletevalue x2apicpolicy');
      await _runCommand('bcdedit /deletevalue bootux');
      await _runCommand('bcdedit /deletevalue bootmenupolicy');
      await _runCommand('bcdedit /deletevalue quietboot');
    }
  };

  // CPU UNPARKING
  Future<void> Function(bool) get _applyCpuUnparking => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerSettings\\54533251-82be-4824-96c1-47b60b740d00\\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMax" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerSettings\\54533251-82be-4824-96c1-47b60b740d00\\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMin" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\ControlSet001\\Control\\Power\\PowerSettings\\54533251-82be-4824-96c1-47b60b740d00\\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerSettings\\54533251-82be-4824-96c1-47b60b740d00\\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power" /v "CoreParkingDisabled" /t REG_DWORD /d "1" /f');
      await _runCommand('powercfg -setacvalueindex scheme_current sub_processor HETEROPOLICY 4');
      // ParkControl commands - Set minimum cores to 100%
      await _runCommand('powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100');
      await _runCommand('powercfg -setdcvalueindex scheme_current sub_processor CPMINCORES 100');
      // Set processor throttle minimum to 100%
      await _runCommand('powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100');
      await _runCommand('powercfg -setdcvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100');
      await _runCommand('powercfg -setactive scheme_current');
    } else {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power" /v "CoreParkingDisabled" /t REG_DWORD /d "0" /f');
      await _runCommand('powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 0');
      await _runCommand('powercfg -setdcvalueindex scheme_current sub_processor CPMINCORES 0');
      await _runCommand('powercfg -setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 0');
      await _runCommand('powercfg -setdcvalueindex scheme_current sub_processor PROCTHROTTLEMIN 0');
      await _runCommand('powercfg -setactive scheme_current');
    }
  };

  // CPU POWER MANAGEMENT
  Future<void> Function(bool) get _applyCpuPowerManagement => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "0x00000026" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f');
      await _runCommand('powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100');
      await _runCommand('powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100');
      await _runCommand('powercfg /setactive scheme_current');
    } else {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "0x00000002" /f');
      await _runCommand('reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Power\\PowerThrottling" /v "PowerThrottlingOff" /f');
      await _runCommand('powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 5');
    }
  };

  // INTEL CPU SPECIFIC OPTIMIZATIONS
  Future<void> Function(bool) get _applyIntelCpuOptimizations => (bool enable) async {
    if (enable) {
      // Heterogeneous Thread Scheduling Policy (12th gen+ with P-cores and E-cores)
      // 0 = Prefer E-cores, 3 = Prefer P-cores, 4 = Automatic (best for gaming)
      await _runCommand('powercfg /setacvalueindex scheme_current sub_processor HETEROPOLICY 4');
      await _runCommand('powercfg /setactive scheme_current');
    } else {
      // Ripristina default (0 = Automatic balanced)
      await _runCommand('powercfg /setacvalueindex scheme_current sub_processor HETEROPOLICY 0');
      await _runCommand('powercfg /setactive scheme_current');
    }
  };

  // AMD RYZEN CPU SPECIFIC OPTIMIZATIONS
  Future<void> Function(bool) get _applyAmdCpuOptimizations => (bool enable) async {
    if (enable) {
      // AMD Ryzen specific optimizations (no heterogeneous policy needed)
      // Additional AMD-specific registry tweaks can be added here if needed
      // For now, AMD uses the common unparking and power management tweaks
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f');
    } else {
      await _runCommand('reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "FeatureSettings" /f');
    }
  };

  // NVIDIA GPU
  Future<void> Function(bool) get _applyNvidiaOptimizations => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "Priority" /t REG_DWORD /d "6" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d "60" /f');
    } else {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "1" /f');
      await _runCommand('reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDelay" /f');
    }
  };

  // AMD GPU
  Future<void> Function(bool) get _applyAmdOptimizations => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d "60" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableUlps" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0001" /v "EnableUlps" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "PP_SclkDeepSleepDisable" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "DisableDRR" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "PP_MemClockDeepSleepDisable" /t REG_DWORD /d "1" /f');
    } else {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableUlps" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0001" /v "EnableUlps" /t REG_DWORD /d "1" /f');
    }
  };

  // INTEL ARC GPU
  Future<void> Function(bool) get _applyIntelOptimizations => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "Disable_OverlayDSQualityEnhancement" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "DpstEnable" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "KMD_EnableComputePreemption" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "KMD_FRTCEnable" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Intel\\Display\\igfxcui\\Media" /v "EnableIntelHWAccel" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "PP_MemClockStateDisable" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableASPM" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableUlps" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Intel\\Display\\igfxcui\\Media" /v "EnableDeepLink" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableResizableBAR" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "ShaderCache" /t REG_DWORD /d "1" /f');
    } else {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}\\0000" /v "EnableUlps" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "1" /f');
    }
  };

  // RAM OPTIMIZATIONS
  Future<void> Function(bool) get _applyRamOptimizations => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f');
      await _runCommand('sc config "SysMain" start=disabled');
      await _runCommand('net stop "SysMain"');
    } else {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "0" /f');
      await _runCommand('sc config "SysMain" start=auto');
    }
  };

  // STORAGE OPTIMIZATIONS
  Future<void> Function(bool) get _applyStorageOptimizations => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management\\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsDisable8dot3NameCreation" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "2" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d "1" /f');
      await _runCommand('fsutil behavior set disablecompression 1');
      await _runCommand('fsutil behavior set encryptpagingfile 0');
      await _runCommand('fsutil behavior set DisableDeleteNotify 0');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\storahci\\Parameters\\Device" /v "EnableHIPM" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\storahci\\Parameters\\Device" /v "EnableDIPM" /t REG_DWORD /d "0" /f');
      // NVMe Power Management - Disable PCIe ASPM
      await _runCommand('powercfg -setacvalueindex scheme_current SUB_PCIEXPRESS ASPM 0');
      await _runCommand('powercfg -setdcvalueindex scheme_current SUB_PCIEXPRESS ASPM 0');
      // Disable USB Selective Suspend
      await _runCommand('powercfg -setacvalueindex scheme_current SUB_USB USBSELECTIVE 0');
      await _runCommand('powercfg -setdcvalueindex scheme_current SUB_USB USBSELECTIVE 0');
      // Disable disk idle timeout
      await _runCommand('powercfg -setacvalueindex scheme_current SUB_DISK DISKIDLE 0');
      await _runCommand('powercfg -setdcvalueindex scheme_current SUB_DISK DISKIDLE 0');
      // Disable CPU idle
      await _runCommand('powercfg -setacvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 1');
      await _runCommand('powercfg -setdcvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 1');
      await _runCommand('powercfg -setactive scheme_current');
    } else {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "0" /f');
      await _runCommand('fsutil behavior set DisableDeleteNotify 1');
      // Revert NVMe Power Management
      await _runCommand('powercfg -setacvalueindex scheme_current SUB_PCIEXPRESS ASPM 1');
      await _runCommand('powercfg -setdcvalueindex scheme_current SUB_PCIEXPRESS ASPM 1');
      await _runCommand('powercfg -setacvalueindex scheme_current SUB_USB USBSELECTIVE 1');
      await _runCommand('powercfg -setdcvalueindex scheme_current SUB_USB USBSELECTIVE 1');
      await _runCommand('powercfg -setacvalueindex scheme_current SUB_DISK DISKIDLE 0');
      await _runCommand('powercfg -setdcvalueindex scheme_current SUB_DISK DISKIDLE 0');
      await _runCommand('powercfg -setacvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 0');
      await _runCommand('powercfg -setdcvalueindex scheme_current SUB_PROCESSOR IDLEDISABLE 0');
      await _runCommand('powercfg -setactive scheme_current');
    }
  };

  // NETWORK OPTIMIZATIONS
  Future<void> Function(bool) get _applyNetworkOptimizations => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "0xffffffff" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d "2" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "DpcWatchdogProfileOffset" /t REG_DWORD /d "10000" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "DpcTimeout" /t REG_DWORD /d "0" /f');
    } else {
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "10" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "20" /f');
    }
  };

  // TIMER & LATENCY
  Future<void> Function(bool) get _applyTimerLatency => (bool enable) async {
    if (enable) {
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "GlobalTimerResolutionRequests" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "LazyModeTimeout" /t REG_DWORD /d "10000" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "Affinity" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "GPU Priority" /t REG_DWORD /d "8" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile\\Tasks\\Audio" /v "Priority" /t REG_DWORD /d "6" /f');
    } else {
      await _runCommand('reg delete "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" /v "GlobalTimerResolutionRequests" /f');
    }
  };

  Future<void> _applyVisualEffects() async {
    if (tweaks['visual_effects']!) {
      // Disable animations and visual effects
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "2" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ListviewAlphaSelect" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ListviewShadow" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" /v "EnableAeroPeek" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\DWM" /v "AlwaysHibernateThumbnails" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DWM" /v "DisallowAnimations" /t REG_DWORD /d "1" /f');
      // Aero Shake disable
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f');
      // Balloon tips disable
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d "0" /f');
      // Color prevalence disable
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "0" /f');
    } else {
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v "EnableTransparency" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "DisallowShaking" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "1" /f');
    }
  }

  Future<void> _applySystemResponsiveness() async {
    if (tweaks['system_responsiveness']!) {
      // Optimize system responsiveness
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "4294967295" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop" /v "LowLevelHooksTimeout" /t REG_SZ /d "1000" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Mouse" /v "MouseHoverTime" /t REG_SZ /d "10" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f');
    } else {
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Multimedia\\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "20" /f');
      await _runCommand('reg add "HKCU\\Control Panel\\Desktop" /v "MenuShowDelay" /t REG_SZ /d "400" /f');
    }
  }

  Future<void> _applyUiOptimizations() async {
    if (tweaks['ui_optimizations']!) {
      // Optimize UI elements
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarDa" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f');
      // Meet Now
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f');
      // News and Interests
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f');
      // People Band
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\People" /v "PeopleBand" /t REG_DWORD /d "0" /f');
      // Taskbar badges
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarBadges" /t REG_DWORD /d "0" /f');
      // Taskbar Glom Level (never combine = more responsive)
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d "2" /f');
    } else {
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced\\People" /v "PeopleBand" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarBadges" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d "0" /f');
    }
  }

  Future<void> _applyExplorerOptimizations() async {
    if (tweaks['explorer_optimizations']!) {
      // Optimize Windows Explorer
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "Hidden" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "SeparateProcess" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "LaunchTo" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "Max Cached Icons" /t REG_SZ /d "4096" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "DisableThumbnailCache" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer" /v "DisableThumbsDBOnNetworkFolders" /t REG_DWORD /d "1" /f');
      // Quick Access tracking
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "ShowFrequent" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "ShowRecent" /t REG_DWORD /d "0" /f');
    } else {
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "HideFileExt" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "Hidden" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "ShowFrequent" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer" /v "ShowRecent" /t REG_DWORD /d "1" /f');
    }
  }

  Future<void> _applyTelemetryDisable() async {
    if (tweaks['telemetry_disable']!) {
      // Disable telemetry and diagnostics
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\WMI\\Autologger\\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Services\\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f');
      await _runCommand('sc config DiagTrack start=disabled');
      await _runCommand('sc config dmwappushservice start=disabled');
      await _runCommand('sc config WerSvc start=disabled');
      await _runCommand('sc stop DiagTrack');
      await _runCommand('sc stop dmwappushservice');
      await _runCommand('sc stop WerSvc');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\System" /v "EnableActivityFeed" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f');
      // Windows Error Reporting
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f');
      // CEIP (Customer Experience Improvement Program)
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\SQMClient\\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\SQMClient" /v "CEIPEnable" /t REG_DWORD /d "0" /f');
    } else {
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "3" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "3" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Policies\\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "3" /f');
      await _runCommand('reg delete "HKLM\\SOFTWARE\\Microsoft\\Windows\\Windows Error Reporting" /v "Disabled" /f');
      await _runCommand('reg delete "HKLM\\SOFTWARE\\Policies\\Microsoft\\SQMClient\\Windows" /v "CEIPEnable" /f');
      await _runCommand('sc config DiagTrack start=auto');
      await _runCommand('sc config WerSvc start=auto');
    }
  }

  Future<void> _applyPrivacyTracking() async {
    if (tweaks['privacy_tracking']!) {
      // Disable privacy invasive features
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Privacy" /v "TailoredExperiencesWithDiagnosticDataEnabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\PolicyManager\\default\\WiFi\\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Siuf\\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Siuf\\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f');
      // Disable Background Apps
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f');
      // Sync Settings - All Groups
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Language" /v "Enabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync\\Groups\\Windows" /v "Enabled" /t REG_DWORD /d "0" /f');
      // Start Menu tracking
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f');
    } else {
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "1" /f');
    }
  }

  Future<void> _applyServicesDisable() async {
    if (tweaks['services_disable']!) {
      // Disable unnecessary services
      // Xbox services
      await _runCommand('sc config XblAuthManager start=disabled');
      await _runCommand('sc config XblGameSave start=disabled');
      await _runCommand('sc config XboxGipSvc start=disabled');
      await _runCommand('sc config XboxNetApiSvc start=disabled');
      await _runCommand('sc stop XblAuthManager');
      await _runCommand('sc stop XblGameSave');
      await _runCommand('sc stop XboxGipSvc');
      await _runCommand('sc stop XboxNetApiSvc');
      // Search and other services
      await _runCommand('sc config WSearch start=disabled');
      await _runCommand('sc stop WSearch');
      await _runCommand('sc config MapsBroker start=disabled');
      await _runCommand('sc stop MapsBroker');
      await _runCommand('sc config RetailDemo start=disabled');
      await _runCommand('sc stop RetailDemo');
      await _runCommand('sc config OneSyncSvc start=disabled');
      await _runCommand('sc stop OneSyncSvc');
      await _runCommand('sc config PcaSvc start=disabled');
      await _runCommand('sc stop PcaSvc');
      // Diagnostic services
      await _runCommand('sc config DPS start=disabled');
      await _runCommand('sc stop DPS');
      await _runCommand('sc config WdiServiceHost start=disabled');
      await _runCommand('sc stop WdiServiceHost');
      await _runCommand('sc config WdiSystemHost start=disabled');
      await _runCommand('sc stop WdiSystemHost');
      // Remote services
      await _runCommand('sc config RemoteRegistry start=disabled');
      await _runCommand('sc stop RemoteRegistry');
      await _runCommand('sc config RemoteAccess start=disabled');
      await _runCommand('sc stop RemoteAccess');
      // Other services
      await _runCommand('sc config Fax start=disabled');
      await _runCommand('sc stop Fax');
      await _runCommand('sc config wisvc start=disabled');
      await _runCommand('sc stop wisvc');
      await _runCommand('sc config WpcMonSvc start=disabled');
      await _runCommand('sc stop WpcMonSvc');
    } else {
      await _runCommand('sc config WSearch start=demand');
      await _runCommand('sc config DPS start=auto');
      await _runCommand('sc config WdiServiceHost start=demand');
      await _runCommand('sc config WdiSystemHost start=demand');
    }
  }

  Future<void> _applyNotificationsMinimal() async {
    if (tweaks['notifications_minimal']!) {
      // Minimize notifications
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\CloudStore\\Store\\Cache\\DefaultAccount" /v "IsActionCenterQuietHoursEnabled" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\CloudStore\\Store\\Cache\\DefaultAccount" /v "FocusAssistAutoRules" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings\\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /t REG_DWORD /d "0" /f');
    } else {
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "1" /f');
    }
  }

  Future<void> _applyGameMode() async {
    if (tweaks['game_mode']!) {
      // Disable Game Mode and Game Bar
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f');
      await _runCommand('reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d "0" /f');
    } else {
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f');
    }
  }

  Future<void> _applyFullscreenOptimizations() async {
    if (tweaks['fullscreen_optimizations']!) {
      // Enable fullscreen optimizations
      await _runCommand('reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f');
      await _runCommand('reg add "HKLM\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f');
    } else {
      await _runCommand('reg add "HKCU\\System\\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "0" /f');
    }
  }

  Future<void> _applyWindowsUpdate() async {
    if (tweaks['windows_update']!) {
      // Optimize Windows Update behavior
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "1" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU" /v "AUPowerManagement" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\DeliveryOptimization\\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\DeliveryOptimization" /v "SystemSettingsDownloadMode" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\DeliveryOptimization\\Settings" /v "DownloadMode" /t REG_DWORD /d "0" /f');
      // Bandwidth limits
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeliveryOptimization" /v "PercentageMaxBackgroundBandwidth" /t REG_DWORD /d "50" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeliveryOptimization" /v "PercentageMaxForegroundBandwidth" /t REG_DWORD /d "50" /f');
      // Driver update blocking
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f');
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f');
      await _runCommand('sc config wuauserv start=demand');
    } else {
      await _runCommand('reg add "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "0" /f');
      await _runCommand('reg delete "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DriverSearching" /v "SearchOrderConfig" /f');
      await _runCommand('reg delete "HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /f');
      await _runCommand('sc config wuauserv start=auto');
    }
  }

  Future<void> _runCommand(String command) async {
    try {
      final result = await Process.run(
        'cmd',
        ['/c', command],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        debugPrint('Command failed: $command');
        debugPrint('Error: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('Exception running command: $e');
    }
  }

  // Detect and remove duplicate power plans with the same name
  Future<void> _cleanAllDuplicatePowerPlans() async {
    final listResult = await Process.run('powercfg', ['/list'], runInShell: true);
    if (listResult.exitCode == 0) {
      final lines = listResult.stdout.toString().split('\n');
      Map<String, List<String>> planGuids = {};

      // Group all GUIDs by plan name
      for (var line in lines) {
        final guidMatch = RegExp(r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})\s+\((.+?)\)', caseSensitive: false).firstMatch(line);
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
            await Process.run('powercfg', ['/delete', entry.value[i]], runInShell: true);
          }
        }
      }
    }
  }

  Future<void> _removeDuplicatePowerPlans(String planName) async {
    final listResult = await Process.run('powercfg', ['/list'], runInShell: true);
    if (listResult.exitCode == 0) {
      final lines = listResult.stdout.toString().split('\n');
      List<String> guids = [];

      // Find all GUIDs with the same plan name
      for (var line in lines) {
        if (line.contains(planName)) {
          final guidMatch = RegExp(r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})', caseSensitive: false).firstMatch(line);
          if (guidMatch != null) {
            guids.add(guidMatch.group(1)!);
          }
        }
      }

      // If there are duplicates (more than 1), keep only the first one and delete the rest
      if (guids.length > 1) {
        for (int i = 1; i < guids.length; i++) {
          await Process.run('powercfg', ['/delete', guids[i]], runInShell: true);
        }
      }
    }
  }

  Future<void> _activatePowerPlan(String planName) async {
    // First, remove any duplicate power plans with the same name
    await _removeDuplicatePowerPlans(planName);

    // Try to find the GUID of the power plan by name
    final listResult = await Process.run('powercfg', ['/list'], runInShell: true);
    if (listResult.exitCode == 0) {
      final lines = listResult.stdout.toString().split('\n');
      String? guid;

      for (var line in lines) {
        if (line.contains(planName)) {
          // Extract GUID from line like: "Power Scheme GUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx  (Plan Name)"
          final guidMatch = RegExp(r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})', caseSensitive: false).firstMatch(line);
          if (guidMatch != null) {
            guid = guidMatch.group(1);
            break;
          }
        }
      }

      if (guid != null) {
        // Power plan exists, just activate it
        final result = await Process.run('powercfg', ['/setactive', guid], runInShell: true);
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
                content: Text('Failed to activate power plan: ${result.stderr}'),
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
          'Exm Free Power Plan V6', 'adamx', 'ancel', 'atlas', 'bitsum', 'calypto',
          'core', 'exmfree', 'hybred', 'kaisen', 'kirby', 'khorvie', 'kizzimo',
          'lawliet', 'nexus', 'powerx', 'sapphire', 'vtrl', 'xilly', 'xos', 'FrameSyncBoost',
        ];

        if (bundledPlans.contains(planName)) {
          // Import the bundled power plan (only happens if not found)
          final exePath = Platform.resolvedExecutable;
          final exeDir = path.dirname(exePath);
          final powerPlanPath = path.join(exeDir, 'data', 'flutter_assets', 'resources', 'Powerplans', '$planName.pow');

          final file = File(powerPlanPath);
          if (await file.exists()) {
            final importResult = await Process.run('powercfg', ['/import', powerPlanPath], runInShell: true);
            if (importResult.exitCode == 0) {
              // Import successful, now activate it
              await Future.delayed(const Duration(milliseconds: 500));
              await _activatePowerPlan(planName); // Recursive call after import
              return;
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to import power plan: ${importResult.stderr}'),
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
                content: Text('Power plan "$planName" not found. Please import it first.'),
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
        title: const Text('Select Bundled Power Plan', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bundledPlans.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(bundledPlans[index], style: const TextStyle(color: Colors.white)),
                onTap: () => Navigator.of(context).pop(bundledPlans[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFFFF6B00))),
          ),
        ],
      ),
    );

    if (selectedPlan != null) {
      // Get the executable directory to find the bundled power plans
      final exePath = Platform.resolvedExecutable;
      final exeDir = path.dirname(exePath);
      final powerPlanPath = path.join(exeDir, 'data', 'flutter_assets', 'resources', 'Powerplans', '$selectedPlan.pow');

      final file = File(powerPlanPath);
      if (await file.exists()) {
        final result = await Process.run('powercfg', ['/import', powerPlanPath], runInShell: true);
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
      final importResult = await Process.run('powercfg', ['/import', filePath], runInShell: true);

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
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
        await Process.start(
          'cmd',
          ['/c', 'start', 'cmd', '/k', scriptPath],
          runInShell: true,
        );

        if (mounted) {
          // Activate restart required
          setState(() {
            needsRestart = true;
          });
          await _saveRestartState(true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debloat script started! Check the command window. Restart required after completion.'),
              backgroundColor: Color(0xFFFF6B00),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
            ),
          );
        }
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
            Text('Chris Titus Tech Tool', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This will launch Chris Titus Tech\'s Windows Utility:\n\n'
          '• Advanced Windows tweaking tool\n'
          '• System optimization options\n'
          '• Software installation manager\n\n'
          'The tool will open in a separate PowerShell window.\n\n'
          'Do you want to proceed?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B00),
              foregroundColor: Colors.white,
            ),
            child: const Text('Launch Tool'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Execute PowerShell command as admin in a new window
        await Process.start(
          'powershell',
          [
            '-NoExit',
            '-Command',
            'Start-Process powershell -Verb RunAs -ArgumentList \'-NoExit\', \'-Command\', \'iwr -useb https://christitus.com/win | iex\''
          ],
          runInShell: true,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chris Titus Tech tool launched! Check PowerShell window.'),
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
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
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
      await Process.run('shutdown', ['/r', '/t', '5', '/c', 'ZapTweaks: Restarting to apply changes...'], runInShell: true);

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

  Future<void> _checkForUpdates() async {
    // Show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Checking for updates...'),
          ],
        ),
        backgroundColor: Color(0xFF2A2A2A),
        duration: Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      // Close loading snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');
        final releaseUrl = data['html_url'] as String;

        if (_isNewerVersion(latestVersion, currentVersion)) {
          // New version available - open release page
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('New version $latestVersion available! Opening download page...'),
                backgroundColor: const Color(0xFFFF6B00),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          await Process.run('cmd', ['/c', 'start', releaseUrl], runInShell: true);
        } else {
          // App is up to date - show popup
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: const Color(0xFF2A2A2A),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFFFF6B00)),
                    SizedBox(width: 12),
                    Text('All up to date!', style: TextStyle(color: Colors.white)),
                  ],
                ),
                content: Text(
                  'ZapTweaks v$currentVersion is the latest version.',
                  style: const TextStyle(color: Colors.white70),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
        }
      } else if (response.statusCode == 404) {
        // No release found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No release found'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking for updates: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
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
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress > 0.01 ? progress : null,
                          backgroundColor: const Color(0xFF1C1C1C),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        progress > 0.01 ? '${(progress * 100).toInt()}%' : 'Starting...',
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
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
                          style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 13),
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

  Future<void> _runWingetUpgrade(Function(String, double, bool, String, int) onUpdate) async {
    try {
      // First, list available updates
      onUpdate('Scanning for available updates...', 0.05, false, '', 0);

      final listResult = await Process.run(
        'winget',
        ['upgrade', '--include-unknown'],
        runInShell: true,
      );

      // Parse the list output to count available updates
      final listOutput = listResult.stdout.toString();
      final lines = listOutput.split('\n');
      int availableUpdates = 0;

      for (final line in lines) {
        if (line.contains('winget upgrade') || line.trim().isEmpty || line.contains('Name') || line.contains('---')) {
          continue;
        }
        if (line.trim().isNotEmpty && !line.contains('upgrade available') && !line.contains('upgrades available')) {
          availableUpdates++;
        }
      }

      if (availableUpdates == 0 || listOutput.contains('No installed package found matching')) {
        onUpdate('', 1.0, true, 'All apps are up to date!', 0);
        return;
      }

      onUpdate('Found $availableUpdates update(s). Starting upgrade...', 0.1, false, '', 0);

      // Run winget upgrade --all
      final process = await Process.start(
        'winget',
        [
          'upgrade',
          '--all',
          '--silent',
          '--accept-package-agreements',
          '--accept-source-agreements',
          '--disable-interactivity',
        ],
        runInShell: true,
      );

      int updatedApps = 0;
      String lastApp = '';

      // Listen to stdout
      process.stdout.transform(const SystemEncoding().decoder).listen((data) {
        final outputLines = data.split('\n');
        for (final line in outputLines) {
          if (line.trim().isEmpty) continue;

          // Try to extract app name being updated
          if (line.contains('Successfully installed') || line.contains('Successfully upgraded')) {
            updatedApps++;
            final progress = (0.1 + (0.85 * updatedApps / availableUpdates)).clamp(0.1, 0.95);
            onUpdate('Completed: $line', progress, false, '', updatedApps);
          } else if (line.contains('Installing') || line.contains('Downloading') || line.contains('Found')) {
            lastApp = line.trim();
            final progress = (0.1 + (0.85 * updatedApps / availableUpdates)).clamp(0.1, 0.95);
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
        onUpdate('', 1.0, true, 'Update completed. Some apps may have been skipped.', updatedApps);
      }
    } catch (e) {
      onUpdate('', 1.0, true, 'Error: $e', 0);
    }
  }
}
