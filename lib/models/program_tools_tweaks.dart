import 'action_tweaks.dart';
import 'system_tweak.dart';

List<SystemTweak> createProgramToolTweaks() {
  return <SystemTweak>[
    // Core launcher actions (non-executable resources)
    ExternalUrlLauncherTweak(
      id: 'recovery_repair_bad_tweaks_zoicware',
      title: 'Repair Bad Tweaks by zoicware',
      description:
          'Opens the pinned MIT-licensed upstream source; the script is not bundled or executed by ZapTweaks.',
      category: 'Refresh & Recovery',
      url:
          'https://github.com/zoicware/RepairBadTweaks/tree/0afa349ba7dca7a44eb8a5e64de1a38ae12f71a5',
      actionLabel: 'Open Pinned Source',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_suite',
      title: 'ZOICWARE',
      description:
          'Opens the official MIT-licensed Windows 11 performance and quality-of-life utility project.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/ZOICWARE',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_defender_pro_tools',
      title: 'DefenderProTools by zoicware',
      description:
          'Opens the official MIT-licensed project for explicit Windows Defender controls. Nothing is downloaded or executed automatically.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/DefenderProTools',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_remove_windows_ai',
      title: 'RemoveWindowsAI by zoicware',
      description:
          'Opens the official MIT-licensed project for reviewing removal of Copilot, Recall, and related components.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/RemoveWindowsAI',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_zscripts',
      title: 'zScripts by zoicware',
      description:
          'Opens the official miscellaneous PowerShell scripts repository. No license is declared, so ZapTweaks does not copy or execute its code.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/zScripts',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_pbo_tuner_2',
      title: 'PBOTuner2 by zoicware',
      description:
          'Opens the official Ryzen PBO undervolt automation project. Firmware tuning remains external and requires independent stability testing.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/PBOTuner2',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_remove_cbs_apps',
      title: 'RemoveCBSApps by zoicware',
      description:
          'Opens the official MIT-licensed project for Get Started, Windows Backup, and Cross Device Resume controls.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/RemoveCBSApps',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_power_plan_settings_editor',
      title: 'PowerPlanSettingsEditor by zoicware',
      description:
          'Opens the official MIT-licensed editor. ZapTweaks also provides its own integrated Power Settings Explorer.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/PowerPlanSettingsEditor',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_ultimate_disk_cleanup',
      title: 'UltimateDiskCleanup by zoicware',
      description:
          'Opens the official Windows Disk Cleanup project with hidden options. Review targets before deleting data.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/UltimateDiskCleanup',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_service_manager_plus',
      title: 'ServiceManagerPlus by zoicware',
      description:
          'Opens the official MIT-licensed advanced Windows service manager project.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/ServiceManagerPlus',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_windows_device_remover',
      title: 'WindowsDeviceRemover by zoicware',
      description:
          'Opens the official MIT-licensed device and driver removal project. ZapTweaks keeps driver removal capability-gated.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/WindowsDeviceRemover',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_windows_update_manager',
      title: 'WindowsUpdateManager by zoicware',
      description:
          'Opens the official advanced Windows Update manager project; its code is not bundled because no license is declared.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/WindowsUpdateManager',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_dynamic_min_services',
      title: 'DynamicMinServices by zoicware',
      description:
          'Opens the official experimental service-reduction project. No license is declared and no code is bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/DynamicMinServices',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_zturbo',
      title: 'zTurbo by zoicware',
      description:
          'Opens the official parallel optimization script project. No license is declared and no code is bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/zTurbo',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_override_edid',
      title: 'OverrideEDID by zoicware',
      description:
          'Opens the official project for reviewing EDID extension-block changes related to app startup stutter.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/OverrideEDID',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_hosts_builder',
      title: 'HostsBuilder by zoicware',
      description:
          'Opens the official custom Windows hosts-file builder project. No license is declared and no code is bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/HostsBuilder',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_remove_apps_policy_editor',
      title: 'RemoveAppsPolicyEditor by zoicware',
      description:
          'Opens the official MIT-licensed Windows 11 RemoveDefaultMicrosoftStorePackages policy editor.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/RemoveAppsPolicyEditor',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_zoicware_tweak_fth',
      title: 'TweakFTH by zoicware',
      description:
          'Opens the official MIT-licensed Fault Tolerant Heap management project.',
      category: 'Drivers & Installers',
      url: 'https://github.com/zoicware/TweakFTH',
      actionLabel: 'Open Official Project',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_benchmate',
      title: 'BenchMate',
      description:
          'Opens the official benchmark validation suite download page. The application is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://benchmate.org/',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_linpack_xtreme',
      title: 'Linpack Xtreme',
      description:
          'Opens the publisher download page hosted by TechPowerUp for CPU and memory stress testing.',
      category: 'Drivers & Installers',
      url: 'https://www.techpowerup.com/download/linpack-xtreme/',
      actionLabel: 'Open Publisher Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_occt',
      title: 'OCCT',
      description:
          'Opens the official stability and stress-testing download page. The application is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.ocbase.com/download',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_y_cruncher',
      title: 'y-cruncher',
      description:
          'Opens the official CPU and memory benchmark and stress-test page.',
      category: 'Drivers & Installers',
      url: 'https://www.numberworld.org/y-cruncher/',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_cinebench_2024',
      title: 'Cinebench 2024',
      description:
          'Opens Maxon’s official CPU and GPU benchmark download page.',
      category: 'Drivers & Installers',
      url: 'https://www.maxon.net/en/downloads/cinebench-2024-downloads',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_memtest86',
      title: 'MemTest86',
      description:
          'Opens PassMark’s official bootable memory-test download page.',
      category: 'Drivers & Installers',
      url: 'https://www.memtest86.com/download.htm',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_corecycler',
      title: 'CoreCycler',
      description:
          'Opens the official project for per-core Ryzen stability testing after PBO or Curve Optimizer changes.',
      category: 'Drivers & Installers',
      url: 'https://github.com/sp00n/corecycler',
      actionLabel: 'Open Official Project',
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
    ExternalUrlLauncherTweak(
      id: 'tool_device_tweaker_script',
      title: 'Device Tweaker (LLG x LLC)',
      description:
          'Opens the author-provided distribution channel; the mutable script is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://discord.gg/eGmDd28m4k',
      actionLabel: 'Open Author Source',
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
    ExternalUrlLauncherTweak(
      id: "tool_marius_deeppoll_script",
      title: "DeepPoll USB Polling Analyzer",
      description:
          "Opens the official DeepPoll page; ZapTweaks never executes its mutable remote script.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/deeppoll.html",
      actionLabel: 'Open Official Page',
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
    ExternalUrlLauncherTweak(
      id: "tool_marius_deeplog_script",
      title: "DeepLog Input Recorder",
      description:
          "Opens the official DeepLog page; ZapTweaks never executes its mutable remote script.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/deeplog.html",
      actionLabel: 'Open Official Page',
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
    ExternalUrlLauncherTweak(
      id: "tool_marius_rig_script",
      title: "Rig Profiles Hardware Report",
      description:
          "Opens the official Rig Profiles page; ZapTweaks never executes its mutable remote script.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/rig.html",
      actionLabel: 'Open Official Page',
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
    ExternalUrlLauncherTweak(
      id: "tool_marius_cpudirect_script",
      title: "CPU Direct USB Port Check",
      description:
          "Opens the official CPU Direct page; ZapTweaks never executes its mutable remote script.",
      category: 'Drivers & Installers',
      url: "https://tools.mariusheier.com/cpudirect.html",
      actionLabel: 'Open Official Page',
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
    ExternalUrlLauncherTweak(
      id: 'tool_winsux_debloat',
      title: 'WinSux by Fr33hty',
      description:
          'Opens the official WinSux source. ZapTweaks never executes its mutable remote script.',
      category: 'Privacy & Bloatware',
      url: 'https://github.com/FR33THYFR33THY/WinSux',
      actionLabel: 'Open Official Source',
    ),

    // Existing bundled tools
    ExternalUrlLauncherTweak(
      id: 'tool_unpark_cpu',
      title: 'Unpark CPU',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://coderbag.com/product/quickcpu',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_mouse_flat_curve',
      title: 'MarkC Mouse Fix',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://donewmouseaccel.blogspot.com/2010/03/markc-windows-7-mouse-acceleration-fix.html',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_mouse_movement_recorder',
      title: 'Mouse Movement Recorder',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://donewmouseaccel.blogspot.com/2010/03/markc-windows-7-mouse-acceleration-fix.html',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_controller_polling',
      title: 'HIDUSBF polling tools',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/LordOfMice/hidusbf/releases',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_queue_size_tuner',
      title: 'Storage queue guidance',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://learn.microsoft.com/windows-hardware/test/wpt/optimizing-performance-and-responsiveness-exercise-3',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_power_settings_explorer',
      title: 'PowerSettingsExplorer',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://forums.guru3d.com/threads/windows-power-plan-settings-explorer-utility.416058/',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_interrupt_affinity_policy',
      title: 'Interrupt Affinity Tool (integrated replacement)',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://learn.microsoft.com/windows-hardware/drivers/kernel/interrupt-affinity-and-priority',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_gpuz',
      title: 'GPU-Z',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.techpowerup.com/gpuz/',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_furmark_setup',
      title: 'FurMark',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://geeks3d.com/furmark/',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_more_clock_tool',
      title: 'MoreClockTool',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://www.igorslab.de/en/download-area-new-version-of-morepowertool-mpt-and-final-release-of-redbioseditor-rbe/',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_more_power_tool_setup',
      title: 'MorePowerTool',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://www.igorslab.de/en/download-area-new-version-of-morepowertool-mpt-and-final-release-of-redbioseditor-rbe/',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_msi_afterburner_setup',
      title: 'MSI Afterburner',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.msi.com/Landing/afterburner/graphics-cards',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_autoruns_folder',
      title: 'Autoruns',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://learn.microsoft.com/sysinternals/downloads/autoruns',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_cpuz_folder',
      title: 'CPU-Z',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.cpuid.com/softwares/cpu-z.html',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_cru_folder',
      title: 'Custom Resolution Utility',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_hidusbf_folder',
      title: 'HIDUSBF',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/LordOfMice/hidusbf/releases',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_hwinfo_folder',
      title: 'HWiNFO',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.hwinfo.com/download/',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_nvidia_profile_inspector_download',
      title: 'Download NVIDIA Profile Inspector',
      description: 'Opens the official NVIDIA Profile Inspector releases page.',
      category: 'Drivers & Installers',
      url: 'https://github.com/Orbmu2k/nvidiaProfileInspector/releases',
      actionLabel: 'Open Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_nvidia_profile_inspector_folder',
      title: 'NVIDIA Profile Inspector',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/Orbmu2k/nvidiaProfileInspector/releases',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_nvidia_profile_inspector_nip_profile',
      title: 'NVIDIA Profile Inspector profiles',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/Orbmu2k/nvidiaProfileInspector/releases',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_prime95_folder',
      title: 'Prime95',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.mersenne.org/download/',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_testmem5_folder',
      title: 'TestMem5',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://www.overclock.net/threads/memory-testing-with-testmem5-tm5-with-custom-configs.1751608/',
      actionLabel: 'Open Authoritative Page',
    ),

    // Newly integrated external and bundled utilities
    ExternalUrlLauncherTweak(
      id: 'tool_wtools_setup',
      title: 'WTools',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.wagnardsoft.com/wtools',
      actionLabel: 'Open Official Download',
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
    ExternalUrlLauncherTweak(
      id: 'tool_rammap_folder',
      title: 'RAMMap',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://learn.microsoft.com/sysinternals/downloads/rammap',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_device_cleanup_folder',
      title: 'Device Cleanup Tool',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.uwe-sieber.de/misc_tools_e.html',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_driver_store_explorer_folder',
      title: 'Driver Store Explorer',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/lostindark/DriverStoreExplorer/releases',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_dismpp_folder',
      title: 'Dism++',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/Chuyu-Team/Dism-Multi-language/releases',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_cleanmgrplus_folder',
      title: 'Cleanmgr+',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/builtbybel/CleanmgrPlus/releases',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_gpu_dword_manager',
      title: 'GPU DWORD Manager',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/YuukiFST/GPU-Dword-Manager/releases',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_msi_util_folder',
      title: 'MSI Utility v3',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://forums.guru3d.com/threads/windows-line-based-vs-message-signaled-based-interrupts-msi-tool.378044/',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_polling_rate_tester_app',
      title: 'Razer Polling Rate Tester',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.razer.com/technology/razer-polling-rate-tester',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_radeon_tuner_folder',
      title: 'Radeon Tuner',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/GSDragoon/RadeonTuner/releases',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_tcp_optimizer_folder',
      title: 'TCP Optimizer',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://www.speedguide.net/downloads.php',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_vivetool_folder',
      title: 'ViVeTool',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://github.com/thebookisclosed/ViVe/releases',
      actionLabel: 'Open Authoritative Page',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_star_ethernet_analyzer_folder',
      title: 'StarTrinity network tools',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://startrinity.com/InternetQuality/ContinuousBandwidthTester.aspx',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_star_ethernet_analyzer_video',
      title: 'StarTrinity network tools guide',
      description:
          'Opens the official download page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://startrinity.com/InternetQuality/ContinuousBandwidthTester.aspx',
      actionLabel: 'Open Official Download',
    ),
    ExternalUrlLauncherTweak(
      id: 'tool_star_ethernet_analyzer_script',
      title: 'StarTrinity network tools',
      description:
          'Opens the official download page; the helper script is not bundled.',
      category: 'Drivers & Installers',
      url:
          'https://startrinity.com/InternetQuality/ContinuousBandwidthTester.aspx',
      actionLabel: 'Open Official Download',
    ),
    // Newly added scripts and programs
    ExternalUrlLauncherTweak(
      id: 'tool_rtl_utility',
      title: 'RTL Utility',
      description:
          'Opens the authoritative download or documentation page; the binary is not bundled.',
      category: 'Drivers & Installers',
      url: 'https://oblique-audio.com/rtl-utility.php',
      actionLabel: 'Open Authoritative Page',
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
