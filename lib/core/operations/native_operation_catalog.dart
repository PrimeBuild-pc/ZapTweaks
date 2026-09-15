import '../../features/apps/application/windows_optional_feature_service.dart';
import '../../features/apps/domain/microsoft_restore_catalog.dart';
import '../../features/drivers/application/driver_store_service.dart';
import '../../features/drivers/application/driver_update_policy_store.dart';
import '../../features/drivers/application/local_driver_package_service.dart';
import '../../features/drivers/application/setupapi_device_inventory_service.dart';
import '../../features/drivers/application/windows_driver_inventory_service.dart';
import '../../platform/windows/etw_trace_collector.dart';
import '../../platform/windows/power_scheme_service.dart';
import '../../platform/windows/processor_topology.dart';
import '../../platform/windows/registry_value_store.dart';
import '../../platform/windows/rss_service.dart';
import '../../platform/windows/service_control_manager.dart';
import '../../platform/windows/system_repair_service.dart';
import '../../platform/windows/scheduled_task_service.dart';
import '../services/process_runner.dart';
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
import 'power_setting_operation.dart';
import 'registry_dword_operation.dart';
import 'rss_configuration_operation.dart';
import 'service_start_operation.dart';
import 'scheduled_task_operation.dart';
import 'system_repair_operation.dart';
import 'winget_package_operation.dart';

List<OperationDefinition> createNativeOperationCatalog(
  RegistryValueStore registry,
  ProcessRunner processRunner,
) => <OperationDefinition>[
  EtwTraceOperation(collector: EtwTraceCollector(processRunner: processRunner)),
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
    allowedServices: const <String>{
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
      id: 'restore_${app.key.toLowerCase().replaceAll('.', '_')}',
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
