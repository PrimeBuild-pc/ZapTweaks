import '../models/tweak_descriptor.dart';
import '../../models/check_tweaks.dart';
import '../../models/gaming_optimizations_tweaks.dart';
import '../../models/hardware_tweaks.dart';
import '../../models/networking_tweaks.dart';
import '../../models/power_cpu_tweaks.dart';
import '../../models/privacy_bloatware_tweaks.dart';
import '../../models/program_tools_tweaks.dart';
import '../../models/recovered_script_tweaks.dart';
import '../../models/system_checks_tweaks.dart';
import '../../models/system_tweak.dart';
import '../../models/ui_visuals_tweaks.dart';

class TweakCatalogService {
  static const List<String> navigationCategories = <String>[
    'Home',
    'Gaming',
    'Networking',
    'Power & CPU',
    'Graphics',
    'Windows',
    'System Checks',
    'Refresh & Recovery',
    'Setup',
    'Advanced',
    'Privacy',
    'Visuals',
    'Tools',
  ];

  static const Set<String> restartRequiredSystemTweaks = <String>{
    'bcd_optimizations',
    'cpu_unparking',
    'cpu_power_management',
    'cpu_intel_optimizations',
    'cpu_amd_optimizations',
    'ram_optimizations',
    'storage_optimizations',
    'timer_latency',
    'visual_effects',
    'system_responsiveness',
    'telemetry_disable',
    'services_disable',
    'ui_optimizations',
    'privacy_tracking',
    'explorer_optimizations',
    'notifications_minimal',
    'game_mode',
    'windows_update',
  };

  List<TweakDescriptor> buildCatalog() {
    final descriptors = <TweakDescriptor>[
      ..._buildSystemToggleDescriptors(),
      ..._buildScriptDescriptors(),
    ];

    descriptors.sort((left, right) => left.title.compareTo(right.title));
    return descriptors;
  }

  List<TweakDescriptor> buildCatalogForCategory(String category) {
    if (category == 'Home') {
      return const <TweakDescriptor>[];
    }

    return buildCatalog()
        .where((descriptor) => descriptor.category == category)
        .toList(growable: false);
  }

  List<TweakDescriptor> _buildSystemToggleDescriptors() {
    const metadata =
        <
          String,
          ({
            String title,
            String description,
            String category,
            bool aggressive,
            String? cpuVendor,
            Set<String> gpuVendors,
          })
        >{
          'bcd_optimizations': (
            title: 'Advanced Boot Optimizations',
            description: 'Tune BCD and boot path for reduced overhead.',
            category: 'Advanced',
            aggressive: true,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'cpu_unparking': (
            title: 'CPU Core Unparking',
            description: 'Unpark all CPU cores for low-latency workloads.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'cpu_power_management': (
            title: 'CPU Power Management',
            description: 'Disable throttling and optimize scheduler behavior.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'cpu_intel_optimizations': (
            title: 'Intel CPU Optimizations',
            description: 'Tune Intel P and E core scheduling profile.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: 'intel',
            gpuVendors: <String>{},
          ),
          'cpu_amd_optimizations': (
            title: 'AMD Ryzen Optimizations',
            description: 'Apply AMD-specific power and latency tuning.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: 'amd',
            gpuVendors: <String>{},
          ),
          'gpu_nvidia_optimizations': (
            title: 'NVIDIA Optimizations',
            description: 'Apply NVIDIA graphics scheduling and latency tweaks.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{'nvidia'},
          ),
          'gpu_amd_optimizations': (
            title: 'AMD GPU Optimizations',
            description:
                'Apply AMD graphics stack tuning and power profile tweaks.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{'amd'},
          ),
          'gpu_intel_optimizations': (
            title: 'Intel GPU Optimizations',
            description: 'Apply Intel graphics stack performance tuning.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{'intel'},
          ),
          'ram_optimizations': (
            title: 'RAM Optimizations',
            description: 'Tune memory manager and cache behavior.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'storage_optimizations': (
            title: 'Storage Optimizations',
            description: 'Tune NTFS, TRIM, and storage power behavior.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'network_optimizations': (
            title: 'Network Optimizations',
            description: 'Tune TCP profile and remove multimedia throttling.',
            category: 'Networking',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'timer_latency': (
            title: 'Timer and Latency',
            description: 'Tune MMCSS and timer request behavior.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'visual_effects': (
            title: 'Disable Visual Effects',
            description: 'Reduce animation and visual overhead.',
            category: 'Visuals',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'system_responsiveness': (
            title: 'System Responsiveness',
            description: 'Reduce UI delays and task timeout values.',
            category: 'Windows',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'telemetry_disable': (
            title: 'Disable Telemetry',
            description: 'Disable telemetry and diagnostics channels.',
            category: 'Privacy',
            aggressive: true,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'services_disable': (
            title: 'Diagnostics Services',
            description:
                'Limit diagnostics service activity for a lean profile.',
            category: 'Advanced',
            aggressive: true,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'ui_optimizations': (
            title: 'UI Optimizations',
            description: 'Apply taskbar and shell cleanup settings.',
            category: 'Visuals',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'privacy_tracking': (
            title: 'Privacy and Tracking',
            description: 'Reduce ad tracking and background activity signals.',
            category: 'Privacy',
            aggressive: true,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'explorer_optimizations': (
            title: 'Explorer Optimizations',
            description: 'Tune file explorer behavior and caching.',
            category: 'Visuals',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'notifications_minimal': (
            title: 'Minimal Notifications',
            description: 'Reduce toast and lock-screen interruptions.',
            category: 'Visuals',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'windows_update': (
            title: 'Windows Update Behavior',
            description: 'Adjust update behavior for gaming-focused workflows.',
            category: 'Windows',
            aggressive: true,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
          'game_mode': (
            title: 'Disable Game Mode',
            description: 'Reduce scheduling side effects and micro-stutter.',
            category: 'Gaming',
            aggressive: false,
            cpuVendor: null,
            gpuVendors: <String>{},
          ),
        };

    final descriptors = <TweakDescriptor>[];
    for (final entry in metadata.entries) {
      descriptors.add(
        TweakDescriptor(
          id: entry.key,
          title: entry.value.title,
          description: entry.value.description,
          category: entry.value.category,
          isAggressive: entry.value.aggressive,
          restartRequired: restartRequiredSystemTweaks.contains(entry.key),
          requiredCpuVendor: entry.value.cpuVendor,
          requiredGpuVendors: entry.value.gpuVendors,
          systemKey: entry.key,
        ),
      );
    }

    return descriptors;
  }

  List<TweakDescriptor> _buildScriptDescriptors() {
    final tweaks = <SystemTweak>[
      ...createCheckTweaks(),
      ...createRecoveredScriptTweaks(),
      ...createSystemChecksTweaks(),
      ...createPowerCpuTweaks(),
      ...createPrivacyBloatwareTweaks(),
      ...createNetworkingTweaks(),
      ...createGamingOptimizationsTweaks(),
      ...createUiVisualsTweaks(),
      ...createProgramToolTweaks(),
      ...createHardwareTweaks(),
    ];

    return tweaks
        .map(
          (tweak) => TweakDescriptor(
            id: tweak.id,
            title: tweak.title,
            description: tweak.description,
            category: _mapToNavigationCategory(tweak.category),
            isAggressive: tweak.isAggressive,
            scriptTweak: tweak,
          ),
        )
        .toList();
  }

  String _mapToNavigationCategory(String sourceCategory) {
    switch (sourceCategory) {
      case 'Networking':
        return 'Networking';
      case 'Privacy & Bloatware':
        return 'Privacy';
      case 'UI & Visuals':
        return 'Visuals';
      case 'Gaming Optimizations':
        return 'Gaming';
      case 'Graphics Scripts':
        return 'Graphics';
      case 'Power & CPU':
        return 'Power & CPU';
      case 'System Checks':
        return 'System Checks';
      case 'Refresh & Recovery':
        return 'Refresh & Recovery';
      case 'Setup Scripts':
        return 'Setup';
      case 'Windows Scripts':
        return 'Windows';
      case 'Advanced Scripts':
        return 'Advanced';
      case 'Drivers & Installers':
        return 'Tools';
      default:
        return 'Advanced';
    }
  }
}
