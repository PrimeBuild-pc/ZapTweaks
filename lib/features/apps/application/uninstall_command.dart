import '../domain/app_package.dart';

/// What to do with one Uninstall entry: run an exact command, or show it as
/// a manual step. Registry strings are untrusted: they are split into an
/// executable plus arguments here, and nothing is ever handed to a shell.
sealed class UninstallPlan {
  const UninstallPlan();
}

class UninstallCommand extends UninstallPlan {
  const UninstallCommand({
    required this.executable,
    required this.arguments,
    required this.silent,
  });

  /// Absolute path of an existing .exe.
  final String executable;
  final List<String> arguments;

  /// True when no window is expected (MSI /qn, quiet string, known switch).
  final bool silent;
}

enum UninstallManualReason { noUninstaller, unsafeCommand, notFound }

class UninstallManual extends UninstallPlan {
  const UninstallManual(this.reason, this.commandLine);

  final UninstallManualReason reason;

  /// The registry text, shown to the user as-is; never executed.
  final String? commandLine;
}

/// Programs that run other code or scripts: a registry entry pointing at
/// them is shown as a manual step instead of being launched.
const _blockedExecutables = <String>{
  'cmd.exe',
  'powershell.exe',
  'pwsh.exe',
  'powershell_ise.exe',
  'wscript.exe',
  'cscript.exe',
  'mshta.exe',
  'rundll32.exe',
  'regsvr32.exe',
  'bash.exe',
  'wsl.exe',
  'conhost.exe',
  'explorer.exe',
  'msbuild.exe',
  'installutil.exe',
};

final _guid = RegExp(
  r'\{[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\}',
  caseSensitive: false,
);
final _inno = RegExp(r'^unins\d{3}\.exe$', caseSensitive: false);
final _nsis = RegExp(
  r'^(uninst|uninstall|uninstaller)\.exe$',
  caseSensitive: false,
);

UninstallPlan planUninstall(
  UninstallEntry entry, {
  required Map<String, String> environment,
  required bool Function(String path) fileExists,
  bool preferSilent = true,
}) {
  final msiexec = expandEnvironment(
    r'%SystemRoot%\System32\msiexec.exe',
    environment,
  );
  UninstallPlan msi(String code) => msiexec == null
      ? UninstallManual(UninstallManualReason.notFound, entry.uninstallString)
      : UninstallCommand(
          executable: msiexec,
          arguments: preferSilent
              ? <String>['/x', code.toUpperCase(), '/qn', '/norestart']
              : <String>['/x', code.toUpperCase()],
          silent: preferSilent,
        );

  if (entry.msiProductCode != null) return msi(entry.msiProductCode!);

  final quiet = preferSilent ? entry.quietUninstallString : null;
  final source = quiet ?? entry.uninstallString;
  if (source == null || source.trim().isEmpty) {
    return const UninstallManual(UninstallManualReason.noUninstaller, null);
  }
  final split = splitCommandLine(source);
  if (split == null) {
    return UninstallManual(UninstallManualReason.unsafeCommand, source);
  }
  final (rawExecutable, arguments) = split;
  final executable = expandEnvironment(rawExecutable, environment);
  // Judge the expanded name: "%ComSpec%" is cmd.exe.
  final name = (executable ?? rawExecutable).split(r'\').last.toLowerCase();
  if (name == 'msiexec.exe' || name == 'msiexec') {
    // Rebuild from the GUID only: registry switches (TRANSFORMS=…) are dropped.
    final code = _guid.firstMatch(arguments.join(' '))?.group(0);
    return code == null
        ? UninstallManual(UninstallManualReason.unsafeCommand, source)
        : msi(code);
  }
  if (executable == null ||
      !_safeExecutable(executable) ||
      _blockedExecutables.contains(name)) {
    return UninstallManual(UninstallManualReason.unsafeCommand, source);
  }
  if (!fileExists(executable)) {
    return UninstallManual(UninstallManualReason.notFound, source);
  }
  if (quiet != null) {
    return UninstallCommand(
      executable: executable,
      arguments: arguments,
      silent: true,
    );
  }
  bool has(String flag) =>
      arguments.any((argument) => argument.toUpperCase() == flag);
  if (preferSilent && _inno.hasMatch(name)) {
    return UninstallCommand(
      executable: executable,
      arguments: <String>[
        ...arguments,
        for (final flag in const [
          '/VERYSILENT',
          '/SUPPRESSMSGBOXES',
          '/NORESTART',
        ])
          if (!has(flag)) flag,
      ],
      silent: true,
    );
  }
  if (preferSilent && _nsis.hasMatch(name)) {
    // shortcut: NSIS is recognised by file name only (BCU reads the binary);
    // a non-NSIS uninstaller ignores /S and simply shows its window.
    return UninstallCommand(
      executable: executable,
      arguments: <String>[...arguments, if (!has('/S')) '/S'],
      silent: true,
    );
  }
  return UninstallCommand(
    executable: executable,
    arguments: arguments,
    silent: false,
  );
}

/// Absolute local `X:\…\name.exe` without `..` segments.
bool _safeExecutable(String path) =>
    RegExp(r'^[A-Za-z]:\\', caseSensitive: false).hasMatch(path) &&
    path.toLowerCase().endsWith('.exe') &&
    !path.split(r'\').contains('..');

/// Expands %VAR% from [environment] (case-insensitive); unknown → null.
String? expandEnvironment(String value, Map<String, String> environment) {
  final lower = <String, String>{
    for (final entry in environment.entries)
      entry.key.toLowerCase(): entry.value,
  };
  var failed = false;
  final result = value.replaceAllMapped(RegExp(r'%([^%]+)%'), (match) {
    final found = lower[match.group(1)!.toLowerCase()];
    if (found == null) failed = true;
    return found ?? '';
  });
  return failed ? null : result;
}

/// Splits a registry command line into executable and arguments.
/// Quoted executable: up to the closing quote. Unquoted: up to the first
/// `.exe` followed by a space or the end, so `C:\Program Files\x.exe /a`
/// works. Arguments follow the usual Windows quoting. Null when malformed.
(String, List<String>)? splitCommandLine(String commandLine) {
  final text = commandLine.trim();
  if (text.isEmpty) return null;
  String executable;
  String rest;
  if (text.startsWith('"')) {
    final end = text.indexOf('"', 1);
    if (end < 0) return null;
    executable = text.substring(1, end);
    rest = text.substring(end + 1);
  } else {
    final match = RegExp(
      r'\.exe(?=\s|$)',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      executable = text.substring(0, match.end);
      rest = text.substring(match.end);
    } else {
      final space = text.indexOf(' ');
      executable = space < 0 ? text : text.substring(0, space);
      rest = space < 0 ? '' : text.substring(space);
    }
  }
  final arguments = <String>[];
  final current = StringBuffer();
  var quoted = false, started = false, slashes = 0;
  for (final char in rest.split('')) {
    if (char == r'\') {
      slashes++;
      started = true;
      continue;
    }
    // CommandLineToArgvW: 2n backslashes + quote → n and a toggle,
    // 2n+1 → n and a literal quote; otherwise backslashes are literal.
    if (char == '"') {
      current.write(r'\' * (slashes ~/ 2));
      if (slashes.isOdd) {
        current.write('"');
      } else {
        quoted = !quoted;
      }
      slashes = 0;
      started = true;
      continue;
    }
    current.write(r'\' * slashes);
    slashes = 0;
    if (!quoted && (char == ' ' || char == '\t')) {
      if (started) arguments.add(current.toString());
      current.clear();
      started = false;
    } else {
      current.write(char);
      started = true;
    }
  }
  current.write(r'\' * slashes);
  if (quoted) return null;
  if (started) arguments.add(current.toString());
  return (executable.trim(), arguments);
}
