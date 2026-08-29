import '../core/registry_manager.dart';
import 'action_tweaks.dart';
import 'system_tweak.dart';

List<SystemTweak> createHardwareTweaks() {
  return <SystemTweak>[
    BackgroundPollingRateCapTweak(),
    ScriptInteractiveTweak(
      id: 'hardware_controller_overclock_script',
      title: 'Controller Overclock',
      description: 'Interactive script by Fr33thy.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        '7 Hardware',
        '4 Controller Overclock.ps1',
      ],
      actionLabel: 'Run Script',
      isAggressive: true,
    ),
  ];
}

class BackgroundPollingRateCapTweak extends SystemTweak {
  BackgroundPollingRateCapTweak()
    : super(
        id: 'hardware_background_polling_rate_cap',
        title: 'Background Polling Rate Cap',
        description:
            'Off = unlocked background polling. Revert restores default behavior.',
        category: 'Drivers & Installers',
      );

  static const String _keyPath = r'HKCU\Control Panel\Mouse';
  static const String _valueName = 'RawMouseThrottleEnabled';

  @override
  Future<void> onApply() async {
    await RegistryManager.writeDword(_keyPath, _valueName, 0);
  }

  @override
  Future<void> onRevert() async {
    final current = await RegistryManager.readDword(_keyPath, _valueName);
    if (current != null) {
      await RegistryManager.deleteValue(_keyPath, _valueName);
    }
  }

  @override
  Future<bool> checkState() async {
    final current = await RegistryManager.readDword(_keyPath, _valueName);
    final applied = current == 0;
    return applied;
  }
}
