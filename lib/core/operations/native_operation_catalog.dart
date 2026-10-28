import 'dart:io';

import '../../features/apps/application/windows_optional_feature_service.dart';
import '../../features/apps/application/uninstall_command.dart'
    show expandEnvironment;
import '../../features/apps/application/service_inventory.dart';
import '../../features/apps/domain/microsoft_restore_catalog.dart';
import '../../features/apps/domain/service_safety_policy.dart';
import '../../features/drivers/application/driver_store_service.dart';
import '../../features/drivers/application/driver_update_policy_store.dart';
import '../../features/drivers/application/local_driver_package_service.dart';
import '../../features/drivers/application/setupapi_device_inventory_service.dart';
import '../../features/drivers/application/windows_driver_inventory_service.dart';
import '../../platform/windows/etw_dpc_analyzer.dart';
import '../../platform/windows/etw_trace_collector.dart';
import '../../platform/windows/power_plan_file_service.dart';
import '../../platform/windows/power_scheme_service.dart';
import '../../platform/windows/processor_topology.dart';
import '../../platform/windows/registry_value_store.dart';
import '../../platform/windows/rss_service.dart';
import '../../platform/windows/service_control_manager.dart';
import '../../platform/windows/system_repair_service.dart';
import '../../platform/windows/scheduled_task_service.dart';
import '../../platform/windows/tcp_optimizer_service.dart';
import '../services/process_runner.dart';
import '../persistence/operation_store.dart';
import 'app_restore_operation.dart';
import 'appx_removal_operation.dart';
import 'device_interrupt_affinity_operation.dart';
import 'device_msi_operation.dart';
import 'driver_package_install_operation.dart';
import 'driver_store_remove_operation.dart';
import 'driver_update_policy_operation.dart';
import 'etw_trace_operation.dart';
import 'operation.dart';
import 'optional_feature_operation.dart';
import 'power_plan_import_operation.dart';
import 'power_scheme_activation_operation.dart';
import 'power_scheme_delete_operation.dart';
import 'power_scheme_duplicate_operation.dart';
import 'power_scheme_rename_operation.dart';
import 'power_schemes_restore_defaults_operation.dart';
import 'power_setting_configure_operation.dart';
import 'power_setting_operation.dart';
import 'registry_dword_operation.dart';
import 'rss_configuration_operation.dart';
import 'startup_entry_operation.dart';
import 'service_start_operation.dart';
import 'sparkle_operations.dart';
import 'scheduled_task_operation.dart';
import 'system_repair_operation.dart';
import 'tcp_optimizer_operations.dart';
import 'trace_cleanup_operation.dart';
import 'leftover_removal_operation.dart';
import 'restore_point_operation.dart';
import 'win32_uninstall_operation.dart';
import 'winget_package_operation.dart';

// shortcut: read once per process (only successes are kept); re-read on
// each change if users install security products while ZapTweaks runs.
List<String>? _securityProductExes;
Future<List<String>> _securityProducts(ProcessRunner runner) async =>
    _securityProductExes ??= await listSecurityProductExes(runner);

List<OperationDefinition> createNativeOperationCatalog(
  RegistryValueStore registry,
  ProcessRunner processRunner, {
  OperationStore? journal,
}) => <OperationDefinition>[
  ...createSparkleManualOperations(registry),
  PowerPlanImportOperation(
    files: PowerPlanFileService(
      processRunner: processRunner,
      schemes: WindowsPowerSchemeService(),
    ),
    schemes: WindowsPowerSchemeService(),
  ),
  PowerSchemeActivationOperation(store: WindowsPowerSchemeService()),
  PowerSchemeRenameOperation(schemes: WindowsPowerSchemeService()),
  PowerSchemeDuplicateOperation(schemes: WindowsPowerSchemeService()),
  PowerSchemeDeleteOperation(
    files: PowerPlanFileService(
      processRunner: processRunner,
      schemes: WindowsPowerSchemeService(),
    ),
    schemes: WindowsPowerSchemeService(),
  ),
  PowerSchemesRestoreDefaultsOperation(
    files: PowerPlanFileService(
      processRunner: processRunner,
      schemes: WindowsPowerSchemeService(),
    ),
    schemes: WindowsPowerSchemeService(),
    processRunner: processRunner,
  ),
  PowerSettingConfigureOperation(WindowsPowerSchemeService()),
  EtwTraceOperation(
    collector: EtwTraceCollector(
      processRunner: processRunner,
      analyzer: EtwDpcAnalyzer(processRunner: processRunner),
    ),
  ),
  TraceCleanupOperation(),
  UserTempCleanupOperation(),
  ShaderCacheCleanupOperation(),
  CrashReportCleanupOperation(),
  BrowserCacheCleanupOperation(),
  SystemRepairOperation(
    kind: SystemRepairKind.componentStore,
    service: WindowsRepairService(processRunner: processRunner),
  ),
  SystemRepairOperation(
    kind: SystemRepairKind.systemFiles,
    service: WindowsRepairService(processRunner: processRunner),
  ),
  ScheduledTaskOperation(
    store: WindowsScheduledTaskService(processRunner: processRunner),
    allowedTasks: const <String>{r'\Microsoft\Windows\Defrag\ScheduledDefrag'},
  ),
  ServiceStartOperation(
    store: const ServiceControlManager(),
    allowedServices: <String>{
      'DiagTrack',
      'dmwappushservice',
      'WerSvc',
      'PcaSvc',
      'XblAuthManager',
      'XblGameSave',
      'XboxNetApiSvc',
      'RemoteRegistry',
      'MapsBroker',
      'WMPNetworkSvc',
      ...changeableCuratedServices,
    },
    // Services of installed programs (Services tab): Win32 services only,
    // judged on the SCM path, never on what the request claims.
    // Security products are read here too; a failed read refuses.
    allowService: (service) async {
      if (service.serviceType & 0x30 == 0 || service.serviceType & 0x3 != 0) {
        return false;
      }
      final path =
          expandEnvironment(service.binaryPath, Platform.environment) ?? '';
      return classifyService(
            name: service.name,
            binaryPath: path,
            company: null,
            systemRoot: Platform.environment['SystemRoot'] ?? r'C:\Windows',
            securityProduct: isSecurityProductPath(
              path,
              await _securityProducts(processRunner),
            ),
          ).safety !=
          ServiceSafety.keep;
    },
  ),
  DeviceInterruptAffinityOperation(
    registry: registry,
    inventory:
        const SetupApiDeviceInventoryService().scanPciInterruptCapabilities,
    topology: ProcessorTopology.inspect,
  ),
  DeviceMsiOperation(
    registry: registry,
    inventory:
        const SetupApiDeviceInventoryService().scanPciInterruptCapabilities,
  ),
  RssConfigurationOperation(WindowsRssService(processRunner: processRunner)),
  TcpSettingOperation(
    WindowsTcpOptimizerService(processRunner: processRunner),
    journal: journal,
  ),
  TcpSnapshotRestoreOperation(
    WindowsTcpOptimizerService(processRunner: processRunner),
    journal: journal,
  ),
  QosPolicyOperation(WindowsQosPolicyService(processRunner: processRunner)),
  DriverUpdatePolicyOperation(
    registry: registry,
    policyStore: DriverUpdatePolicyStore(),
  ),
  DriverPackageInstallOperation(
    localPackages: LocalDriverPackageService(
      processRunner: processRunner,
      inventory: WindowsDriverInventoryService(processRunner: processRunner),
      verifySignature: (file) => LocalDriverPackageService.verifyAuthenticode(
        file,
        processRunner: processRunner,
      ),
    ),
    inventory: WindowsDriverInventoryService(processRunner: processRunner),
    store: DriverStoreService(
      processRunner: processRunner,
      backupRoot: defaultDriverBackupRoot(),
    ),
  ),
  DriverStoreRemoveOperation(
    store: DriverStoreService(
      processRunner: processRunner,
      backupRoot: defaultDriverBackupRoot(),
    ),
    inventory: WindowsDriverInventoryService(processRunner: processRunner),
    deviceInventory: const SetupApiDeviceInventoryService().scanPresent,
  ),
  ..._createPowerOperations(),
  WingetPackageOperation(processRunner: processRunner),
  OptionalFeatureOperation(
    WindowsOptionalFeatureService(processRunner: processRunner),
  ),
  AppxRemovalOperation(
    id: 'app.appx.remove_current_user',
    systemScopes: false,
    processRunner: processRunner,
  ),
  AppxRemovalOperation(
    id: 'app.appx.remove_system',
    systemScopes: true,
    processRunner: processRunner,
  ),
  Win32UninstallOperation(machine: true, dryRun: processRunner.isDryRun),
  Win32UninstallOperation(machine: false, dryRun: processRunner.isDryRun),
  RestorePointOperation(processRunner: processRunner),
  LeftoverRemovalOperation(machine: true, dryRun: processRunner.isDryRun),
  LeftoverRemovalOperation(machine: false, dryRun: processRunner.isDryRun),
  RegistryDwordOperation(
    id: 'ui_taskbar_end_task',
    titleKey: 'operationTaskbarEndTaskTitle',
    descriptionKey: 'operationTaskbarEndTaskDescription',
    destination: 'Windows',
    path:
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings',
    valueName: 'TaskbarEndTask',
    store: registry,
    privilege: OperationPrivilege.user,
    scope: OperationScope.user,
    minimumWindowsBuild: 22631,
    restartImpact: RestartImpact.process,
    benefitEvidence: EvidenceLevel.documented,
    technicalSources: const <String>[
      'https://learn.microsoft.com/windows/whats-new/whats-new-windows-11-version-23h2',
    ],
  ),
  // Preset building blocks (B8), values from Microsoft's privacy guide.
  RegistryDwordOperation(
    id: 'privacy.advertising_id_off',
    titleKey: 'presetItemAdvertisingId',
    descriptionKey: 'presetItemAdvertisingIdNote',
    destination: 'Windows',
    path: r'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo',
    valueName: 'Enabled',
    store: registry,
    privilege: OperationPrivilege.administrator,
    scope: OperationScope.machine,
    benefitEvidence: EvidenceLevel.documented,
    technicalSources: const <String>[
      'https://learn.microsoft.com/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services',
    ],
  ),
  RegistryDwordOperation(
    id: 'privacy.language_list_opt_out',
    titleKey: 'presetItemLanguageList',
    descriptionKey: 'presetItemLanguageListNote',
    destination: 'Windows',
    path: r'HKCU\Control Panel\International\User Profile',
    valueName: 'HttpAcceptLanguageOptOut',
    store: registry,
    privilege: OperationPrivilege.user,
    scope: OperationScope.user,
    benefitEvidence: EvidenceLevel.documented,
    technicalSources: const <String>[
      'https://learn.microsoft.com/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services',
    ],
  ),
  RegistryDwordOperation(
    id: 'privacy.app_launch_tracking_off',
    titleKey: 'presetItemAppLaunchTracking',
    descriptionKey: 'presetItemAppLaunchTrackingNote',
    destination: 'Windows',
    path: r'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced',
    valueName: 'Start_TrackProgs',
    store: registry,
    privilege: OperationPrivilege.user,
    scope: OperationScope.user,
    benefitEvidence: EvidenceLevel.documented,
    technicalSources: const <String>[
      'https://learn.microsoft.com/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services',
    ],
  ),
  RegistryDwordOperation(
    id: 'privacy.tailored_experiences_off',
    titleKey: 'presetItemTailoredExperiences',
    descriptionKey: 'presetItemTailoredExperiencesNote',
    destination: 'Windows',
    path: r'HKCU\Software\Policies\Microsoft\Windows\CloudContent',
    valueName: 'DisableTailoredExperiencesWithDiagnosticData',
    store: registry,
    privilege: OperationPrivilege.user,
    scope: OperationScope.user,
    benefitEvidence: EvidenceLevel.documented,
    technicalSources: const <String>[
      'https://learn.microsoft.com/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services',
    ],
  ),
  RegistryDwordOperation(
    id: 'privacy.cloud_optimized_content_off',
    titleKey: 'presetItemCloudContent',
    descriptionKey: 'presetItemCloudContentNote',
    destination: 'Windows',
    path: r'HKCU\Software\Policies\Microsoft\Windows\CloudContent',
    valueName: 'DisableCloudOptimizedContent',
    store: registry,
    privilege: OperationPrivilege.user,
    scope: OperationScope.user,
    benefitEvidence: EvidenceLevel.documented,
    technicalSources: const <String>[
      'https://learn.microsoft.com/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services',
    ],
  ),
  RegistryDwordOperation(
    id: 'privacy.diagnostic_data_required',
    titleKey: 'presetItemDiagnosticData',
    descriptionKey: 'presetItemDiagnosticDataNote',
    destination: 'Windows',
    path: r'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection',
    valueName: 'AllowTelemetry',
    store: registry,
    privilege: OperationPrivilege.administrator,
    scope: OperationScope.machine,
    benefitEvidence: EvidenceLevel.documented,
    technicalSources: const <String>[
      'https://learn.microsoft.com/windows/privacy/manage-connections-from-windows-operating-system-components-to-microsoft-services',
    ],
  ),
  RegistryDwordOperation(
    id: 'gaming.game_dvr_off',
    titleKey: 'presetItemGameDvr',
    descriptionKey: 'presetItemGameDvrNote',
    destination: 'Gaming & Performance',
    path: r'HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR',
    valueName: 'AllowGameDVR',
    store: registry,
    privilege: OperationPrivilege.administrator,
    scope: OperationScope.machine,
    benefitEvidence: EvidenceLevel.inferred,
    technicalSources: const <String>[
      'https://www.stigviewer.com/stigs/microsoft_windows_11/2026-05-19/finding/V-253399',
    ],
  ),
  StartupEntryOperation.user(registry),
  StartupEntryOperation.machine(registry),
  RegistryDwordOperation(
    id: 'power_throttling_off',
    titleKey: 'powerThrottlingOffTitle',
    descriptionKey: 'powerThrottlingOffDescription',
    destination: 'Gaming & Performance',
    path: r'HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling',
    valueName: 'PowerThrottlingOff',
    store: registry,
    privilege: OperationPrivilege.administrator,
    scope: OperationScope.machine,
    benefitEvidence: EvidenceLevel.inferred,
    technicalSources: const <String>[
      'https://learn.microsoft.com/windows-server/administration/performance-tuning/role/power-server/configuring-power-management-settings',
    ],
  ),
  for (final app in microsoftRestoreCatalog.entries)
    AppRestoreOperation(
      id: switch (app.key) {
        'Microsoft.MicrosoftStickyNotes' => 'restore_microsoft_stickynotes',
        'MicrosoftCorporationII.QuickAssist' => 'restore_microsoft_quickassist',
        _ => 'restore_${app.key.toLowerCase().replaceAll('.', '_')}',
      },
      legacyPackageName: app.key,
      identity: app.value,
      processRunner: processRunner,
    ),
];

List<OperationDefinition> _createPowerOperations() {
  final store = WindowsPowerSchemeService();
  const subgroup = '54533251-82be-4824-96c1-47b60b740d00';
  return <OperationDefinition>[
    PowerSettingOperation(
      id: 'power_processor_boost_mode',
      titleKey: 'powerProcessorBoostModeTitle',
      descriptionKey: 'powerProcessorBoostModeDescription',
      destination: 'Gaming & Performance',
      subgroupId: subgroup,
      settingId: 'be337238-0d82-4146-a960-4f3749d470c7',
      store: store,
      technicalSources: const <String>[
        'https://learn.microsoft.com/windows-hardware/customize/power-settings/options-for-perf-state-engine-perfboostmode',
      ],
    ),
    PowerSettingOperation(
      id: 'power_max_processor_state',
      titleKey: 'powerMaxProcessorStateTitle',
      descriptionKey: 'powerMaxProcessorStateDescription',
      destination: 'Gaming & Performance',
      subgroupId: subgroup,
      settingId: 'bc5038f7-23e0-4960-96da-33abaf5935ec',
      store: store,
      technicalSources: const <String>[
        'https://learn.microsoft.com/windows-hardware/customize/power-settings/options-for-perf-state-engine-maxperformance',
      ],
    ),
  ];
}
