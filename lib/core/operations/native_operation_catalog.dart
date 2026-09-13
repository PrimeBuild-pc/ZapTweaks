import '../../features/apps/domain/microsoft_restore_catalog.dart';
import '../../platform/windows/registry_value_store.dart';
import '../services/process_runner.dart';
import 'app_restore_operation.dart';
import 'operation.dart';
import 'registry_dword_operation.dart';

List<OperationDefinition> createNativeOperationCatalog(
  RegistryValueStore registry,
  ProcessRunner processRunner,
) => <OperationDefinition>[
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
  for (final app in microsoftRestoreCatalog.entries)
    AppRestoreOperation(
      id: 'restore_${app.key.toLowerCase().replaceAll('.', '_')}',
      legacyPackageName: app.key,
      identity: app.value,
      processRunner: processRunner,
    ),
];
