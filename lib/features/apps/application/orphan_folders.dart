import 'dart:io';

import 'folder_size_cache.dart' show normalizeFolder;
import 'uninstall_command.dart' show expandEnvironment;

/// Program Files folders that belong to Windows or to every program.
const _systemFolders = <String>{
  'common files',
  'windowsapps',
  'modifiablewindowsapps',
  'internet explorer',
  'reference assemblies',
  'msbuild',
  'dotnet',
  'powershell',
  'uninstall information',
  'windows defender',
  'windows defender advanced threat protection',
  'windows mail',
  'windows media player',
  'windows multimedia platform',
  'windows nt',
  'windows photo viewer',
  'windows portable devices',
  'windows security',
  'windows sidebar',
  'windowspowershell',
  'microsoft update health tools',
};

/// Folders in [candidates] that none of [references] (install locations,
/// uninstall command lines, AppX locations) points into. Windows and
/// Microsoft folders are left out; the rest is only a suggestion, never
/// preselected, because a portable tool or a driver kit has no Uninstall key.
List<String> findOrphanFolders(
  Iterable<String> candidates,
  Iterable<String> references, {
  Map<String, String> environment = const <String, String>{},
}) {
  final refs = <String>[
    for (final reference in references)
      normalizeFolder(
        (expandEnvironment(reference, environment) ?? reference).replaceAll(
          '"',
          '',
        ),
      ).toLowerCase(),
  ];
  return <String>[
    for (final folder in candidates)
      if (!_isSystem(folder) &&
          !refs.any((ref) {
            final f = normalizeFolder(folder).toLowerCase();
            return ref == f || ref.startsWith('$f\\');
          }))
        folder,
  ];
}

bool _isSystem(String folder) {
  final name = normalizeFolder(folder).split(r'\').last.toLowerCase();
  return _systemFolders.contains(name) ||
      name.startsWith('microsoft') ||
      name.startsWith('windows');
}

/// First-level folders of Program Files and Program Files (x86).
List<String> programFilesFolders(Map<String, String> environment) => <String>[
  for (final root in <String?>[
    environment['ProgramFiles'],
    environment['ProgramFiles(x86)'],
  ].nonNulls.toSet())
    if (Directory(root).existsSync())
      for (final entity in Directory(root).listSync(followLinks: false))
        if (entity is Directory) entity.path,
];
