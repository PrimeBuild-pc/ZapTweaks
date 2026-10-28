import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';
import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';
import '../../diagnostics/presentation/app_history_page.dart' show formatBytes;
import '../application/process_inventory.dart';

enum ProcessSort { memory, cpu, name }

/// Running processes, Wintoys style: Windows / Microsoft / third party, and
/// "can close" only for user apps outside the Windows folder.
class ProcessListPage extends StatefulWidget {
  const ProcessListPage({
    this.load,
    this.signers,
    this.end,
    this.open,
    this.selfPid,
    this.systemRoot,
    super.key,
  });

  final Future<List<ProcessEntry>> Function()? load;
  final Future<Map<String, String>> Function(Iterable<String> paths)? signers;
  final Future<bool> Function(ProcessEntry entry)? end;

  /// Opens a folder selection or a URL through Explorer.
  final Future<void> Function(List<String> arguments)? open;
  final int? selfPid;
  final String? systemRoot;

  @override
  State<ProcessListPage> createState() => _ProcessListPageState();
}

class _ProcessListPageState extends State<ProcessListPage> {
  List<ProcessEntry> _entries = const <ProcessEntry>[];
  bool _loading = true;
  String? _message;
  String _search = '';
  ProcessKind? _kind;
  bool _closableOnly = false;
  ProcessSort _sort = ProcessSort.memory;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final entries =
          await (widget.load ?? () => listProcesses(ProcessRunner.shared))();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
      // The signer only matters outside the Windows folder (see classifier).
      final windows = '${_systemRoot.toLowerCase()}\\';
      final signers =
          await (widget.signers ??
              (paths) => fetchSigners(ProcessRunner.shared, paths))(<String>[
            for (final entry in entries)
              if (entry.path != null &&
                  !entry.path!.toLowerCase().startsWith(windows))
                entry.path!,
          ]);
      if (!mounted || signers.isEmpty) return;
      setState(
        () => _entries = <ProcessEntry>[
          for (final entry in _entries)
            entry.path != null && signers.containsKey(entry.path)
                ? entry.withSigner(signers[entry.path])
                : entry,
        ],
      );
    } catch (error) {
      if (mounted) setState(() => _message = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _systemRoot =>
      widget.systemRoot ?? Platform.environment['SystemRoot'] ?? r'C:\Windows';

  ProcessVerdict _verdict(ProcessEntry entry) => classifyProcess(
    entry,
    systemRoot: _systemRoot,
    selfPid: widget.selfPid ?? pid,
  );

  Future<void> _open(List<String> arguments) async {
    if (widget.open != null) return widget.open!(arguments);
    final result = await ProcessRunner.shared.launch('explorer', arguments);
    if (!result.success && mounted) setState(() => _message = result.details);
  }

  Future<void> _end(ProcessEntry entry) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await confirmAction(
      context,
      title: strings.processEnd,
      message: strings.processEndConfirm(entry.name),
      confirmLabel: strings.processEnd,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    try {
      final ended =
          await (widget.end ??
              (entry) => endProcess(ProcessRunner.shared, entry))(entry);
      if (!mounted) return;
      if (!ended) {
        setState(() => _message = strings.processEndChanged);
        return;
      }
    } catch (_) {
      if (mounted) setState(() => _message = strings.processEndFailed);
      return;
    }
    await _scan();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final search = _search.trim().toLowerCase();
    final rows =
        <(ProcessEntry, ProcessVerdict)>[
            for (final entry in _entries) (entry, _verdict(entry)),
          ].where((row) {
            final (entry, verdict) = row;
            return (_kind == null || verdict.kind == _kind) &&
                (!_closableOnly || verdict.canClose) &&
                (search.isEmpty ||
                    <String?>[
                      entry.name,
                      entry.description,
                      entry.company,
                      entry.signer,
                      entry.path,
                    ].any(
                      (v) => v != null && v.toLowerCase().contains(search),
                    ));
          }).toList()
          ..sort(
            (a, b) => switch (_sort) {
              ProcessSort.memory => b.$1.memoryBytes.compareTo(
                a.$1.memoryBytes,
              ),
              ProcessSort.cpu => b.$1.cpuPercent.compareTo(a.$1.cpuPercent),
              ProcessSort.name => a.$1.name.toLowerCase().compareTo(
                b.$1.name.toLowerCase(),
              ),
            },
          );
    final maxMemory = _entries.fold<int>(
      0,
      (max, entry) => entry.memoryBytes > max ? entry.memoryBytes : max,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 280,
                child: TextBox(
                  placeholder: strings.searchProcesses,
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
              InfoLabel(
                label: strings.filterType,
                child: ComboBox<ProcessKind?>(
                  value: _kind,
                  placeholder: Text(strings.filterAll),
                  items: <ComboBoxItem<ProcessKind?>>[
                    ComboBoxItem(value: null, child: Text(strings.filterAll)),
                    for (final kind in ProcessKind.values)
                      ComboBoxItem(
                        value: kind,
                        child: Text(_kindLabel(strings, kind)),
                      ),
                  ],
                  onChanged: (value) => setState(() => _kind = value),
                ),
              ),
              InfoLabel(
                label: strings.sortBy,
                child: ComboBox<ProcessSort>(
                  value: _sort,
                  items: <ComboBoxItem<ProcessSort>>[
                    ComboBoxItem(
                      value: ProcessSort.memory,
                      child: Text(strings.sortMemory),
                    ),
                    ComboBoxItem(
                      value: ProcessSort.cpu,
                      child: Text(strings.sortCpu),
                    ),
                    ComboBoxItem(
                      value: ProcessSort.name,
                      child: Text(strings.sortName),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _sort = value ?? ProcessSort.memory),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Checkbox(
                  checked: _closableOnly,
                  content: Text(strings.processOnlyClosable),
                  onChanged: (value) =>
                      setState(() => _closableOnly = value ?? false),
                ),
              ),
              Button(
                onPressed: _loading ? null : _scan,
                child: Text(strings.refreshInventory),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(strings.processNote),
          if (_message != null) ...<Widget>[
            const SizedBox(height: 10),
            InfoBar(
              title: Text(strings.operationFailed),
              content: Text(_message!),
              severity: InfoBarSeverity.error,
              onClose: () => setState(() => _message = null),
            ),
          ],
          const SizedBox(height: 10),
          Expanded(
            child: _loading && _entries.isEmpty
                ? const Center(child: ProgressRing())
                : rows.isEmpty
                ? EmptyState(strings.noProcessesMatch)
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) => _ProcessRow(
                      entry: rows[index].$1,
                      verdict: rows[index].$2,
                      maxMemory: maxMemory,
                      onEnd: () => _end(rows[index].$1),
                      onOpenLocation: () =>
                          _open(<String>['/select,${rows[index].$1.path}']),
                      onSearch: () => _open(<String>[
                        processSearchUri(rows[index].$1.name).toString(),
                      ]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

String _kindLabel(AppLocalizations strings, ProcessKind kind) => switch (kind) {
  ProcessKind.windows => strings.processKindWindows,
  ProcessKind.microsoftApp => strings.processKindMicrosoft,
  ProcessKind.thirdParty => strings.processKindThirdParty,
};

class _ProcessRow extends StatelessWidget {
  const _ProcessRow({
    required this.entry,
    required this.verdict,
    required this.maxMemory,
    required this.onEnd,
    required this.onOpenLocation,
    required this.onSearch,
  });

  final ProcessEntry entry;
  final ProcessVerdict verdict;
  final int maxMemory;
  final VoidCallback onEnd;
  final VoidCallback onOpenLocation;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    final reason = switch (verdict.reason) {
      ProcessReason.critical => strings.processReasonCritical,
      ProcessReason.windowsFolder => strings.processReasonWindowsFolder,
      ProcessReason.service => strings.processReasonService,
      ProcessReason.self => strings.processReasonSelf,
      ProcessReason.userApp => strings.processReasonUserApp,
    };
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    Widget action(IconData icon, String label, VoidCallback? onPressed) =>
        Tooltip(
          message: label,
          child: IconButton(
            icon: Icon(icon, size: 14, semanticLabel: label),
            onPressed: onPressed,
          ),
        );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.description == null ||
                          entry.description!.toLowerCase() ==
                              entry.name.toLowerCase()
                      ? entry.name
                      : '${entry.name} · ${entry.description}',
                  style: theme.typography.bodyStrong,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  <String>[
                    if (entry.signer != null)
                      strings.signedBy(entry.signer!)
                    else if (entry.company != null)
                      entry.company!,
                    'PID ${entry.pid}',
                    if (entry.path != null) entry.path!,
                  ].join(' · '),
                  style: theme.typography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reason,
                  style: theme.typography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: wide ? 120 : 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(formatBytes(entry.memoryBytes)),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.resources.controlStrokeColorDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: maxMemory <= 0
                        ? 0
                        : (entry.memoryBytes / maxMemory).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '${entry.cpuPercent.toStringAsFixed(1)}%',
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 12),
          if (wide)
            SizedBox(
              width: 110,
              child: StatusBadge(_kindLabel(strings, verdict.kind)),
            ),
          SizedBox(
            width: 130,
            child: StatusBadge(
              verdict.canClose
                  ? strings.processCanClose
                  : strings.processLeaveRunning,
              tone: verdict.canClose ? BadgeTone.positive : BadgeTone.neutral,
              tooltip: reason,
            ),
          ),
          action(
            FluentIcons.cancel,
            strings.processEnd,
            verdict.canClose ? onEnd : null,
          ),
          action(
            FluentIcons.folder_open,
            strings.openLocation,
            entry.path == null ? null : onOpenLocation,
          ),
          action(FluentIcons.search, strings.searchOnline, onSearch),
        ],
      ),
    );
  }
}
