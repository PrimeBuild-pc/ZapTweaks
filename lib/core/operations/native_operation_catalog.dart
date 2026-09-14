import '../../features/apps/domain/microsoft_restore_catalog.dart';
import '../../platform/windows/registry_value_store.dart';
import '../services/process_runner.dart';
import 'app_restore_operation.dart';
import 'appx_removal_operation.dart';
import 'operation.dart';
import 'registry_dword_operation.dart';

List<OperationDefinition> createNativeOperationCatalog(
  RegistryValueStore registry,
  ProcessRunner processRunner,
) => <OperationDefinition>[
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
