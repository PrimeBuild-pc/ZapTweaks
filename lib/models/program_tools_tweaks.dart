import 'action_tweaks.dart';
import 'system_tweak.dart';

List<SystemTweak> createProgramToolTweaks() {
  return <SystemTweak>[
    // Core launcher actions (non-executable resources)
    ScriptInteractiveTweak(
      id: 'recovery_repair_bad_tweaks_zoicware',
      title: 'Repair Bad Tweaks by zoicware',
      description:
          'Runs the pinned MIT-licensed RepairBadTweaks script by zoicware to detect and interactively restore known harmful tweak values.',
      category: 'Refresh & Recovery',
      scriptSegments: <String>[
        'external_scripts',
        'RepairBadTweaks',
        'RepairTweaks.ps1',
      ],
      isAggressive: true,
      warningMessage:
          'This third-party recovery script can change boot, service, device and Registry settings. Review every detected repair before confirming.',
    ),
    BatchScriptTweak(
      id: 'tool_winscript_batch',
      title: 'WinScript Batch Utility',
      description: 'Runs bundled WinScript maintenance batch actions.',
      category: 'Drivers & Installers',
      batchSegments: <String>['winscript.bat'],
      isAggressive: true,
    ),
    RegistryImportTweak(
      id: 'tool_import_minimal_services_profile',
      title: 'Import Minimal Services Profile',
      description:
          'Imports minimal service startup policy from bundled .reg file by Sapphire.',
      category: 'Drivers & Installers',
      registrySegments: <String>['minimal_services.reg'],
      isAggressive: true,
    ),
    RegistryImportTweak(
      id: 'tool_import_disable_advanced_services_profile',
      title: 'Import Disable Advanced Services Profile',
      description:
          'Imports advanced services hard-disable profile from bundled .reg file by Sapphire.',
      category: 'Drivers & Installers',
      registrySegments: <String>['disable_advanced_services.reg'],
      isAggressive: true,
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_beyond_performance_device_tweaker_discord',
      title: 'Beyond Performance Device Tweaker',
      description:
          'Opens the public Beyond Performance Discord channel that distributes Device Tweaker.',
      category: 'Drivers & Installers',
      url: 'https://discord.gg/eGmDd28m4k',
      actionLabel: 'Open Discord',
      isAggressive: true,
      warningMessage:
          'This opens the author-provided public Discord source. Review the shared file, version, and instructions before running any device tweak.',
    ),
    ScriptInteractiveTweak(
      id: 'tool_device_tweaker_script',
      title: 'Device Tweaker (LLG x LLC)',
      description:
          'Opens the bundled Device Tweaker GUI script for per-device interrupt, MSI, and power tuning.',
      category: 'Drivers & Installers',
      scriptSegments: <String>['interactive_scripts', 'DeviceTweaker.ps1'],
      actionLabel: 'Open Tool',
      isAggressive: true,
      warningMessage:
          'Device Tweaker changes per-device interrupt affinity, MSI mode, and power settings. '
          'Review each change in its window before applying it.',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_scewin_gui_releases',
      title: 'SCEWIN-GUI Releases',
      description:
          'Opens the MIT-licensed SCEWIN-GUI releases. It edits SCEWIN/AMISCE NVRAM files; it does not include SCEWIN itself.',
      category: 'Advanced Scripts',
      url: 'https://github.com/eskezje/SCEWIN-GUI/releases',
      actionLabel: 'Open Releases',
      isAggressive: true,
      warningMessage:
          'Firmware/NVRAM changes can make a system unbootable. Back up the original file and use only on supported hardware.',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_nvidia_nvflash_download',
      title: 'NVIDIA NVFlash Download',
      description:
          'Opens TechPowerUp NVFlash downloads. ZapTweaks never selects a ROM or runs flash commands.',
      category: 'Advanced Scripts',
      url: 'https://www.techpowerup.com/download/nvidia-nvflash/',
      actionLabel: 'Open Download',
      isAggressive: true,
      warningMessage:
          'VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and do not use patched protection-bypass builds.',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_amdvbflash_download',
      title: 'AMDVBFlash Download',
      description:
          'Opens TechPowerUp AMDVBFlash downloads. ZapTweaks never selects a ROM or runs flash commands.',
      category: 'Advanced Scripts',
      url: 'https://www.techpowerup.com/download/amdvbflash/',
      actionLabel: 'Open Download',
      isAggressive: true,
      warningMessage:
          'VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and remove any temporary driver after use.',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_winslopr_releases',
      title: 'Download Winslopr',
      description:
          'Opens the official Winslopr releases page on GitHub in your browser.',
      category: 'Drivers & Installers',
      url: 'https://github.com/builtbybel/Winslopr/releases',
      actionLabel: 'Open Releases',
    ),
    ExternalUrlLauncherTweak(
      id: "tool_marius_heier_tools_hub",
      title: "Marius Heier Tools Hub",
      description:
          "Opens the tools.mariusheier.com index with every latency, polling and input diagnostic tool.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/",
      actionLabel: 'Open',
    ),
    PowerShellTerminalCommandTweak(
      id: "tool_marius_deeppoll_script",
      title: "DeepPoll USB Polling Analyzer (Script)",
      description:
          "Runs DeepPoll in an elevated PowerShell window: USB polling rate analysis with microsecond precision via kernel ETW tracing.",
      category: 'Drivers & Installers',
      command: "irm https://tools.mariusheier.com/deeppoll.ps1 | iex",
      actionLabel: 'Run Tool',
      warningMessage:
          "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.",
    ),
    ExternalUrlLauncherTweak(
      id: "tool_marius_deeppoll_web",
      title: "DeepPoll USB Polling Analyzer (Web)",
      description:
          "Opens the DeepPoll web page describing the USB polling rate analyzer.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/deeppoll.html",
      actionLabel: 'Open',
    ),
    PowerShellTerminalCommandTweak(
      id: "tool_marius_deeplog_script",
      title: "DeepLog Input Recorder (Script)",
      description:
          "Runs DeepLog in an elevated PowerShell window: records 30 seconds of controller input with a system snapshot for diagnostics.",
      category: 'Drivers & Installers',
      command: "irm https://tools.mariusheier.com/deeplog.ps1 | iex",
      actionLabel: 'Run Tool',
      warningMessage:
          "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.",
    ),
    ExternalUrlLauncherTweak(
      id: "tool_marius_deeplog_web",
      title: "DeepLog Input Recorder (Web)",
      description:
          "Opens the DeepLog web page describing the controller input recorder.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/deeplog.html",
      actionLabel: 'Open',
    ),
    PowerShellTerminalCommandTweak(
      id: "tool_marius_rig_script",
      title: "Rig Profiles Hardware Report (Script)",
      description:
          "Runs the Rig Profiles diagnostic script that collects and submits a hardware profile and compatibility information.",
      category: 'Drivers & Installers',
      command: "irm https://tools.mariusheier.com/rig.ps1 | iex",
      actionLabel: 'Run Tool',
      warningMessage:
          "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.",
    ),
    ExternalUrlLauncherTweak(
      id: "tool_marius_rig_web",
      title: "Rig Profiles Hardware Report (Web)",
      description:
          "Opens the Rig Profiles web page describing the hardware profile submission.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/rig.html",
      actionLabel: 'Open',
    ),
    PowerShellTerminalCommandTweak(
      id: "tool_marius_cpudirect_script",
      title: "CPU Direct USB Port Check (Script)",
      description:
          "Runs CPU Direct in an elevated PowerShell window: checks whether USB devices sit on CPU-direct or chipset ports and detects hubs.",
      category: 'Drivers & Installers',
      command: "irm https://tools.mariusheier.com/cpudirect.ps1 | iex",
      actionLabel: 'Run Tool',
      warningMessage:
          "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.",
    ),
    ExternalUrlLauncherTweak(
      id: "tool_marius_cpudirect_web",
      title: "CPU Direct USB Port Check (Web)",
      description:
          "Opens the CPU Direct web page describing the USB port check.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/cpudirect.html",
      actionLabel: 'Open',
    ),
    ExternalUrlLauncherTweak(
      id: "tool_marius_step_count_noise_web",
      title: "Step Count vs Noise Joystick Demo",
      description:
          "Opens the browser demo showing why a noisy 12-bit joystick chatters even at full resolution.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/step-count-vs-noise-joystick.html",
      actionLabel: 'Open',
    ),
    ExternalUrlLauncherTweak(
      id: "tool_marius_usb_hid_analyzer_web",
      title: "USB HID Polling Analyzer",
      description:
          "Opens the browser tool that measures real device polling frequency, jitter, timing consistency and device speed.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/poll_checker.html",
      actionLabel: 'Open',
    ),
    PowerShellTerminalCommandTweak(
      id: 'tool_install_win11_debloat_raphire',
      title: 'Install Win11 Debloat',
      description:
          'Runs the official Win11Debloat remote command in a visible elevated PowerShell window.',
      category: 'Drivers & Installers',
      command: '& ([scriptblock]::Create((irm "https://debloat.raphi.re/")))',
      actionLabel: 'Install',
      isAggressive: true,
      warningMessage:
          'This action executes a remote PowerShell command from debloat.raphi.re and can change system configuration. Continue only if you trust the source.',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_windows_11_fix_tweaks_kubaam',
      title: 'Windows 11 Fix Tweaks by kubaam',
      description:
          'Opens the pinned upstream project for review. Its all-in-one batch file is not executed by ZapTweaks.',
      category: 'Drivers & Installers',
      url:
          'https://github.com/kubaam/Windows-11-Fix-Tweaks/tree/8da4fe0251f3c46aec6434e38e7a92f06307313a',
      actionLabel: 'Open source',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_ctt_winutil',
      title: 'CTT WinUtil by Chris Titus Tech',
      description:
          'Opens the official WinUtil releases page. ZapTweaks never executes mutable remote PowerShell code.',
      category: 'Drivers & Installers',
      url: 'https://github.com/ChrisTitusTech/winutil/releases',
      actionLabel: 'Open releases',
    ),
    PowerShellTerminalCommandTweak(
      id: 'tool_install_winhance',
      title: 'Install Winhance',
      description:
          'Installs Winhance with Winget for common Windows customization and baseline optimization.',
      category: 'Drivers & Installers',
      command:
          'winget install --exact --id memstechtips.Winhance --accept-package-agreements --accept-source-agreements',
      actionLabel: 'Install',
      isAggressive: true,
    ),
    PowerShellTerminalCommandTweak(
      id: 'tool_sysinternals_suite_winget',
      title: 'Install Sysinternals Suite',
      description:
          'Installs Microsoft Sysinternals Suite with Winget. The PowerShell window stays open so you can read the final PATH/tool output.',
      category: 'Drivers & Installers',
      command: 'winget install -e --id Microsoft.Sysinternals.Suite',
      actionLabel: 'Install',
      isAggressive: true,
    ),
    PowerShellTerminalCommandTweak(
      id: 'tool_winsux_debloat',
      title: 'WinSux by Fr33hty',
      description:
          'Runs Fr33hty\'s remote WinSux debloat command. Invasive action with no in-app revert.',
      category: 'Privacy & Bloatware',
      command:
          'iwr https://github.com/FR33THYFR33THY/WinSux/raw/refs/heads/main/WinSux.ps1 -useb | iex',
      actionLabel: 'Run WinSux',
      isAggressive: true,
      warningMessage:
          'This action executes a remote PowerShell command from '
          'github.com/FR33THYFR33THY and applies invasive debloat changes. '
          'There is no in-app revert for this action. Continue only if you '
          'fully trust the source.',
    ),

    // Existing bundled tools
    ExecutableLauncherTweak(
      id: 'tool_unpark_cpu',
      title: 'Unpark CPU',
      description: 'CPU core unparking utility.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'UnparkCpu.exe'],
    ),
    ExecutableLauncherTweak(
      id: 'tool_mouse_flat_curve',
      title: 'Mouse Flat Curve',
      description: 'Applies flat mouse acceleration curve settings.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'MouseFlatCurve.exe'],
    ),
    ExecutableLauncherTweak(
      id: 'tool_mouse_movement_recorder',
      title: 'Mouse Movement Recorder',
      description: 'Checks effective mouse polling behavior.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'mousemovementrecorder.exe'],
    ),
    ExecutableLauncherTweak(
      id: 'tool_controller_polling',
      title: 'Polling Tool',
      description: 'Controller polling rate measurement tool.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'polling.exe'],
    ),
    ExecutableLauncherTweak(
      id: 'tool_queue_size_tuner',
      title: 'Queue Size Tuner',
      description: 'Storage queue tuning utility.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'QueueSize_Tuner.exe'],
      isAggressive: true,
    ),
    ExecutableLauncherTweak(
      id: 'tool_power_settings_explorer',
      title: 'PowerSettingsExplorer',
      description: 'Advanced Windows power-plan settings editor.',
      category: 'Drivers & Installers',
      executableSegments: <String>[
        'programmi',
        'PowerSettingsExplorer',
        'PowerSettingsExplorer.exe',
      ],
      isAggressive: true,
    ),
    ExecutableLauncherTweak(
      id: 'tool_interrupt_affinity_policy',
      title: 'Interrupt Affinity Policy Tool',
      description: 'Interrupt affinity and IRQ policy tuning utility.',
      category: 'Drivers & Installers',
      executableSegments: <String>[
        'programmi',
        'Interrupt_Affinity_Policy_Tool',
        'intPolicy_x64.exe',
      ],
      isAggressive: true,
    ),
    ExecutableLauncherTweak(
      id: 'tool_gpuz',
      title: 'GPU-Z',
      description: 'Detailed GPU diagnostics and sensors.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'GPU-Z.2.69.0.exe'],
    ),
    ExecutableLauncherTweak(
      id: 'tool_furmark_setup',
      title: 'FurMark Installer',
      description: 'GPU stress-test installer package.',
      category: 'Drivers & Installers',
      executableSegments: <String>[
        'programmi',
        'FurMark_2.10.2_Win64_Setup.exe',
      ],
      actionLabel: 'Install',
      isAggressive: true,
    ),
    ExecutableLauncherTweak(
      id: 'tool_more_clock_tool',
      title: 'More Clock Tool',
      description: 'AMD clock/voltage control utility.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'MoreClockTool.exe'],
      isAggressive: true,
    ),
    ExecutableLauncherTweak(
      id: 'tool_more_power_tool_setup',
      title: 'MorePowerTool Installer',
      description: 'AMD power table tuning installer.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'MorePowerTool_Setup.exe'],
      actionLabel: 'Install',
      isAggressive: true,
    ),
    ExecutableLauncherTweak(
      id: 'tool_msi_afterburner_setup',
      title: 'MSI Afterburner Installer',
      description: 'GPU overclocking and monitoring installer.',
      category: 'Drivers & Installers',
      executableSegments: <String>[
        'programmi',
        'MSIAfterburnerSetup467Beta2.exe',
      ],
      actionLabel: 'Install',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_autoruns_folder',
      title: 'Autoruns',
      description: 'Startup and scheduled task analyzer suite.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'Autoruns'],
      launchExecutableRelativePath: 'Autoruns64.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_cpuz_folder',
      title: 'CPU-Z',
      description: 'CPU and memory information utility.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'cpu-z_2.19-en'],
      launchExecutableRelativePath: 'cpuz_x64.exe',
    ),
    DirectoryLauncherTweak(
      id: 'tool_cru_folder',
      title: 'CRU',
      description: 'Custom Resolution Utility for display modes.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'cru-1.5.3'],
      launchExecutableRelativePath: 'CRU.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_hidusbf_folder',
      title: 'hidusbf',
      description: 'USB polling overclock toolkit for HID devices.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'hidusbf (BB11.5.25)'],
      launchExecutableRelativePath: 'DRIVER/Setup.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_hwinfo_folder',
      title: 'HWiNFO',
      description: 'System sensors and hardware telemetry suite.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'hwi_834'],
      launchExecutableRelativePath: 'HWiNFO64.EXE',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_nvidia_profile_inspector_download',
      title: 'Download NVIDIA Profile Inspector',
      description: 'Opens the official NVIDIA Profile Inspector releases page.',
      category: 'Drivers & Installers',
      url: 'https://github.com/Orbmu2k/nvidiaProfileInspector/releases',
      actionLabel: 'Open Download',
    ),
    DirectoryLauncherTweak(
      id: 'tool_nvidia_profile_inspector_folder',
      title: 'NVIDIA Profile Inspector',
      description: 'Advanced NVIDIA profile editor.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'nvidiaProfileInspector'],
      launchExecutableRelativePath: 'nvidiaProfileInspector.exe',
      isAggressive: true,
    ),
    NvidiaProfileImportTweak(
      id: 'tool_nvidia_profile_inspector_nip_profile',
      title: 'NVIDIA Profile Inspector Profiles (.nip)',
      description:
          'Choose a bundled profile and import it directly with NVIDIA Profile Inspector.',
      category: 'Drivers & Installers',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_prime95_folder',
      title: 'Prime95',
      description: 'CPU stress-test and stability validation.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'p95v3019b20.win64'],
      launchExecutableRelativePath: 'prime95.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_testmem5_folder',
      title: 'TestMem5',
      description: 'RAM stress-test utility.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'TestMem5'],
      launchExecutableRelativePath: 'TM5.exe',
      isAggressive: true,
    ),

    // Newly integrated external and bundled utilities
    ExecutableLauncherTweak(
      id: 'tool_wtools_setup',
      title: 'WTools 1.0.9.3 Installer',
      description:
          'Installs the bundled, Wagnardsoft-signed WTools 1.0.9.3 package.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'WTools v1.0.9.3_setup.exe'],
      actionLabel: 'Install',
      isAggressive: true,
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_wtools_official_page',
      title: 'WTools Official Page',
      description:
          'Opens the official Wagnardsoft page for downloads and updates.',
      category: 'Drivers & Installers',
      url: 'https://www.wagnardsoft.com/wtools',
      actionLabel: 'Open Download',
    ),
    DirectoryLauncherTweak(
      id: 'tool_rammap_folder',
      title: 'RAMMap',
      description: 'Microsoft Sysinternals physical memory analysis utility.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'RAMMap'],
      launchExecutableRelativePath: 'RAMMap64.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_device_cleanup_folder',
      title: 'Device Cleanup',
      description: 'Cleans phantom/non-present device entries from Windows.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'DeviceCleanup'],
      launchExecutableRelativePath: 'DeviceCleanup.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_driver_store_explorer_folder',
      title: 'Driver Store Explorer (RAPR)',
      description: 'Inspects and prunes old/unused driver packages.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'DriverStoreExplorer-v1.0.26'],
      launchExecutableRelativePath: 'Rapr.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_dismpp_folder',
      title: 'Dism++',
      description: 'Advanced DISM and servicing operations toolkit.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'Dism++10.1.1002.1B'],
      launchExecutableRelativePath: 'Dism++x64.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_cleanmgrplus_folder',
      title: 'Cleanmgr+',
      description:
          'Extended disk cleanup and temporary-file management utility.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'cleanmgrplus'],
      launchExecutableRelativePath: 'Cleanmgr+.exe',
    ),
    ExecutableLauncherTweak(
      id: 'tool_gpu_dword_manager',
      title: 'GPU DWORD Manager',
      description: 'GPU registry DWORD tuning utility.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'GPU_Dword_Manager.exe'],
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_msi_util_folder',
      title: 'MSI Utility v3',
      description: 'Message Signaled Interrupt policy utility.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'MSI_util_v3'],
      launchExecutableRelativePath: 'MSI_util_v3.exe',
      isAggressive: true,
    ),
    ExecutableLauncherTweak(
      id: 'tool_polling_rate_tester_app',
      title: 'Polling Rate Tester App',
      description: 'Dedicated mouse polling rate validation utility.',
      category: 'Drivers & Installers',
      executableSegments: <String>[
        'programmi',
        'PollingRateTesterApp_v1.00.01.exe',
      ],
    ),
    DirectoryLauncherTweak(
      id: 'tool_radeon_tuner_folder',
      title: 'Radeon Tuner',
      description: 'AMD Radeon driver tuning and profile utility.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'RadeonTuner'],
      launchExecutableRelativePath: 'RadeonTuner.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_tcp_optimizer_folder',
      title: 'TCP Optimizer',
      description: 'Network stack optimization and diagnostics tool.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'TCPOptimizer'],
      launchExecutableRelativePath: 'TCPOptimizer.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_vivetool_folder',
      title: 'ViVeTool',
      description: 'Windows feature flag management utility.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'ViVeTool-v0.3.4-IntelAmd'],
      launchExecutableRelativePath: 'ViVeTool.exe',
      isAggressive: true,
    ),
    DirectoryLauncherTweak(
      id: 'tool_star_ethernet_analyzer_folder',
      title: 'Star Ethernet Analyzer',
      description: 'Ethernet and jitter diagnostics toolkit.',
      category: 'Drivers & Installers',
      directorySegments: <String>['programmi', 'Star Ethernet Analyzer'],
      launchExecutableRelativePath: '2. StarTrinity.Installer.exe',
    ),
    ExplorerSelectFileTweak(
      id: 'tool_star_ethernet_analyzer_video',
      title: 'Star Ethernet Analyzer Video Guide',
      description:
          'Opens the bundled video guide with the default Windows app.',
      category: 'Drivers & Installers',
      fileSegments: <String>[
        'programmi',
        'Star Ethernet Analyzer',
        '0. How_to_use.mp4',
      ],
      openWithDefaultApp: true,
      actionLabel: 'Play Video',
    ),
    ScriptInteractiveTweak(
      id: 'tool_star_ethernet_analyzer_script',
      title: 'Star Ethernet Analyzer Script',
      description: 'Interactive helper script for Star Ethernet Analyzer.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'programmi',
        'Star Ethernet Analyzer',
        'StarAnalyzer_bam.ps1',
      ],
      isAggressive: true,
    ),
    // Newly added scripts and programs
    ExecutableLauncherTweak(
      id: 'tool_rtl_utility',
      title: 'RTL Utility',
      description: 'Realtek utility and diagnostics tool.',
      category: 'Drivers & Installers',
      executableSegments: <String>['programmi', 'RTL_Utility_1_0_12_x64.exe'],
      isAggressive: true,
    ),
    BatchScriptTweak(
      id: 'tool_fix_tools_runner',
      title: 'Fix Tools Launcher',
      description: 'Runs the Fix Tools batch launcher menu.',
      category: 'Drivers & Installers',
      batchSegments: <String>['interactive_scripts', 'Fix Tools', 'run.bat'],
      isAggressive: true,
    ),
    ScriptInteractiveTweak(
      id: 'tool_fix_tools_battery_report',
      title: 'Battery Report',
      description: 'Fix Tools diagnostic script.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        'Fix Tools',
        'BatteryReport.ps1',
      ],
    ),
    ScriptInteractiveTweak(
      id: 'tool_fix_tools_change_name',
      title: 'Change Name',
      description: 'Fix Tools helper script.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        'Fix Tools',
        'Change Name.ps1',
      ],
    ),
    ScriptInteractiveTweak(
      id: 'tool_fix_tools_fastclean',
      title: 'FastClean',
      description: 'Fix Tools cleanup script.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        'Fix Tools',
        'FastClean.ps1',
      ],
      isAggressive: true,
    ),
    ScriptInteractiveTweak(
      id: 'tool_fix_tools_permessi',
      title: 'Permessi',
      description: 'Fix Tools permissions repair script.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        'Fix Tools',
        'Permessi.ps1',
      ],
      isAggressive: true,
    ),
    ScriptInteractiveTweak(
      id: 'tool_fix_tools_reset_network',
      title: 'Reset Network',
      description: 'Fix Tools network reset script.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        'Fix Tools',
        'ResetNetwork.ps1',
      ],
      isAggressive: true,
    ),
    ScriptInteractiveTweak(
      id: 'tool_fix_tools_ripristina_anteprime',
      title: 'Ripristina Anteprime',
      description: 'Fix Tools thumbnail cache repair script.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        'Fix Tools',
        'RipristinaAntemprime.ps1',
      ],
      isAggressive: true,
    ),
    ScriptInteractiveTweak(
      id: 'tool_fix_tools_sfc_dism',
      title: 'SFC & DISM',
      description: 'Fix Tools integrity and image repair script.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        'Fix Tools',
        'SFC & DISM.ps1',
      ],
      isAggressive: true,
    ),
    ScriptInteractiveTweak(
      id: 'tool_gaming_net_diagnostic',
      title: 'Gaming Network Diagnostic',
      description: 'Quick network diagnostics script for gaming sessions.',
      category: 'Drivers & Installers',
      scriptSegments: <String>[
        'interactive_scripts',
        'gaming_net_diagnostic.ps1',
      ],
      isAggressive: true,
    ),
  ];
}
