import 'action_tweaks.dart';
import 'system_tweak.dart';

List<SystemTweak> createCheckTweaks() {
  return <SystemTweak>[
    ScriptInteractiveTweak(
      id: 'check_space_check',
      title: 'Space Check',
      description: 'Interactive diagnostic script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '1 Space Check.ps1'],
    ),
    ScriptInteractiveTweak(
      id: 'check_ram_check',
      title: 'RAM Check',
      description: 'Interactive diagnostic script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '2 Ram Check.ps1'],
    ),
    ScriptInteractiveTweak(
      id: 'check_gpu_check',
      title: 'GPU Check',
      description: 'Interactive diagnostic script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '3 Gpu Check.ps1'],
    ),
    ScriptInteractiveTweak(
      id: 'check_bios_update',
      title: 'BIOS Update Search',
      description: 'Opens motherboard search script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '4 Bios Update.ps1'],
      isAggressive: true,
    ),
    ScriptInteractiveTweak(
      id: 'check_bios_settings',
      title: 'BIOS Settings Guide',
      description: 'Interactive BIOS guidance script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '5 Bios Settings.ps1'],
      isAggressive: true,
    ),
    ScriptInteractiveTweak(
      id: 'check_cpu_test',
      title: 'CPU Test',
      description: 'Interactive stress-test script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '6 Cpu Test.ps1'],
    ),
    ScriptInteractiveTweak(
      id: 'check_ram_test',
      title: 'RAM Test',
      description: 'Interactive stress-test script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '7 Ram Test.ps1'],
    ),
    ScriptInteractiveTweak(
      id: 'check_gpu_test',
      title: 'GPU Test',
      description: 'Interactive stress-test script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '8 Gpu Test.ps1'],
    ),
    ScriptInteractiveTweak(
      id: 'check_hw_info',
      title: 'HW Info',
      description: 'Interactive hardware info script by Fr33thy.',
      category: 'System Checks',
      scriptSegments: <String>['interactive_scripts', '1 Check', '9 Hw Info.ps1'],
    ),
  ];
}

