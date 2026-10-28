import 'package:fluent_ui/fluent_ui.dart';

import '../../../app/widgets/ui_kit.dart';
import '../../../core/operations/leftover_removal_operation.dart';
import '../../../core/operations/operation.dart';
import '../../../core/plans/operation_plan.dart';
import '../../../l10n/app_localizations.dart';
import '../../diagnostics/presentation/app_history_page.dart' show formatBytes;
import '../application/folder_size_cache.dart';
import '../application/leftover_scanner.dart';
import 'uninstall_queue_dialog.dart' show PlanExecutor;

/// Preview of leftovers with sizes; only Good ones start selected. User and
/// machine items go to their own operation (machine through the helper).
class LeftoverReviewDialog extends StatefulWidget {
  const LeftoverReviewDialog({
    required this.load,
    required this.execute,
    this.title,
    this.note,
    super.key,
  });

  final Future<List<Leftover>> Function() load;
  final PlanExecutor execute;
  final String? title;
  final String? note;

  @override
  State<LeftoverReviewDialog> createState() => _LeftoverReviewDialogState();
}

class _LeftoverReviewDialogState extends State<LeftoverReviewDialog> {
  List<Leftover>? _items;
  final Set<String> _selected = <String>{};
  final Map<String, LeftoverRefusal> _refused = <String, LeftoverRefusal>{};
  final Map<String, int> _sizes = <String, int>{};
  final FolderSizeCache _cache = FolderSizeCache();
  bool _busy = false;
  String? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    widget
        .load()
        .then((items) async {
          if (!mounted) return;
          setState(() {
            _items = items;
            // The operation refuses a whole batch for one bad item, so
            // check each one here and keep refused ones out of reach.
            final roots = <bool, LeftoverRoots>{
              for (final machine in <bool>[false, true])
                machine: LeftoverRoots.current(machine: machine),
            };
            for (final item in items) {
              final reason = validateLeftoverItem(
                item.toJson(),
                machine: item.machine,
                roots: roots[item.machine]!,
              );
              if (reason != null) _refused[item.path] = reason;
            }
            _selected.addAll(
              items
                  .where((i) => i.preselected && !_refused.containsKey(i.path))
                  .map((i) => i.path),
            );
          });
          for (final item in items.where(
            (i) => i.kind == LeftoverKind.folder,
          )) {
            final size = await _cache.sizeOf(item.path);
            if (!mounted) return;
            if (size != null) setState(() => _sizes[item.path] = size);
          }
        })
        .catchError((Object error) {
          if (mounted) setState(() => _error = '$error');
        });
  }

  Future<void> _remove() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final failures = <String>[];
    for (final machine in <bool>[false, true]) {
      final items = _items!
          .where((i) => i.machine == machine && _selected.contains(i.path))
          .map((i) => i.toJson())
          .toList();
      if (items.isEmpty) continue;
      try {
        final plan = await widget.execute(<OperationRequest>[
          OperationRequest(
            operationId: machine
                ? 'app.leftovers.remove'
                : 'app.leftovers.remove_user',
            desiredValue: false,
            parameters: <String, Object?>{'items': items},
          ),
        ]);
        final result = plan.items.single;
        if (result.status != PlanItemStatus.verified) {
          failures.add(result.error ?? result.status.name);
        }
      } catch (error) {
        failures.add('$error');
      }
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _done = failures.isEmpty;
      _error = failures.isEmpty ? null : failures.join('\n');
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = FluentTheme.of(context);
    final items = _items;
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 820, maxHeight: 660),
      title: Text(widget.title ?? strings.leftoverTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(widget.note ?? strings.leftoverBackupNote),
          const SizedBox(height: 8),
          if (_error != null)
            InfoBar(
              title: Text(strings.operationFailed),
              content: Text(_error!),
              severity: InfoBarSeverity.error,
              isLong: true,
            ),
          if (_done)
            InfoBar(
              title: Text(
                strings.leftoverRemoved(
                  r'%LOCALAPPDATA%\ZapTweaks\leftover-backups · %ProgramData%\ZapTweaks\leftover-backups',
                ),
              ),
              severity: InfoBarSeverity.success,
              isLong: true,
            ),
          if (items == null && _error == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: ProgressRing()),
            )
          else if (items != null && items.isEmpty)
            EmptyState(strings.leftoverNone)
          else if (items != null)
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final size = _sizes[item.path];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: <Widget>[
                        Checkbox(
                          checked: _selected.contains(item.path),
                          onChanged:
                              _busy || _done || _refused.containsKey(item.path)
                              ? null
                              : (value) => setState(
                                  () => value == true
                                      ? _selected.add(item.path)
                                      : _selected.remove(item.path),
                                ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                <String>[
                                  _kind(strings, item.kind),
                                  if (size != null) formatBytes(size),
                                ].join(' · '),
                                style: theme.typography.bodyStrong,
                              ),
                              SelectableText(
                                item.path,
                                style: theme.typography.caption,
                              ),
                              if (item.detail != null)
                                Text(
                                  item.detail!,
                                  style: theme.typography.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (_refused[item.path] case final reason?)
                                Text(
                                  switch (reason) {
                                    LeftoverRefusal.invalid =>
                                      strings.leftoverRefusedInvalid,
                                    LeftoverRefusal.outsideAllowed =>
                                      strings.leftoverRefusedOutside,
                                    LeftoverRefusal.shared =>
                                      strings.leftoverRefusedShared,
                                  },
                                  style: theme.typography.caption?.copyWith(
                                    color: StatusBadge.critical,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (item.machine) ...<Widget>[
                          const Icon(FluentIcons.shield, size: 14),
                          const SizedBox(width: 6),
                        ],
                        SizedBox(
                          width: 100,
                          child: StatusBadge(
                            switch (item.confidence) {
                              LeftoverConfidence.good => strings.leftoverGood,
                              LeftoverConfidence.medium =>
                                strings.leftoverMedium,
                              LeftoverConfidence.low => strings.leftoverLow,
                            },
                            tone: switch (item.confidence) {
                              LeftoverConfidence.good => BadgeTone.positive,
                              LeftoverConfidence.medium => BadgeTone.caution,
                              LeftoverConfidence.low => BadgeTone.neutral,
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      actions: <Widget>[
        Button(
          onPressed: _busy ? null : () => Navigator.pop(context, _done),
          child: Text(_done ? strings.close : strings.cancel),
        ),
        if (!_done)
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(StatusBadge.critical),
            ),
            onPressed: _busy || _selected.isEmpty || items == null
                ? null
                : _remove,
            child: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: ProgressRing(strokeWidth: 2),
                  )
                : Text(strings.leftoverRemoveSelected(_selected.length)),
          ),
      ],
    );
  }

  static String _kind(AppLocalizations strings, LeftoverKind kind) =>
      switch (kind) {
        LeftoverKind.folder => strings.leftoverKindFolder,
        LeftoverKind.shortcut => strings.leftoverKindShortcut,
        LeftoverKind.registryKey => strings.leftoverKindRegistry,
        LeftoverKind.runValue => strings.leftoverKindRun,
        LeftoverKind.task => strings.leftoverKindTask,
        LeftoverKind.firewallRule => strings.leftoverKindFirewall,
      };
}
