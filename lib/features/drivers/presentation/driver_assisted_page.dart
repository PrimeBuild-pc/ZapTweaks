import 'package:fluent_ui/fluent_ui.dart';

import '../../../core/services/process_runner.dart';
import '../../../l10n/app_localizations.dart';

class DriverAssistedPage extends StatelessWidget {
  const DriverAssistedPage({super.key});

  Future<void> _open(BuildContext context, String target) async {
    final result = await ProcessRunner.shared.launch('explorer.exe', <String>[
      target,
    ]);
    if (!result.success && context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => ContentDialog(
          title: Text(AppLocalizations.of(context).operationFailed),
          content: Text(result.details),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final flows = <({String title, String description, String target})>[
      (
        title: strings.amdDriverFlow,
        description: strings.amdDriverFlowDescription,
        target: 'https://www.amd.com/en/support/download/drivers.html',
      ),
      (
        title: strings.nvidiaDriverFlow,
        description: strings.nvidiaDriverFlowDescription,
        target: 'https://www.nvidia.com/Download/index.aspx',
      ),
      (
        title: strings.intelDriverFlow,
        description: strings.intelDriverFlowDescription,
        target: 'https://www.intel.com/content/www/us/en/support/detect.html',
      ),
      (
        title: strings.windowsOptionalDrivers,
        description: strings.windowsOptionalDriversDescription,
        target: 'ms-settings:windowsupdate-optionalupdates',
      ),
      (
        title: strings.deviceManager,
        description: strings.deviceManagerDescription,
        target: 'devmgmt.msc',
      ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: <Widget>[
        InfoBar(
          title: Text(strings.assistedDriverFlows),
          content: Text(strings.assistedDriverFlowsDescription),
          severity: InfoBarSeverity.info,
        ),
        const SizedBox(height: 12),
        for (final flow in flows) ...<Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          flow.title,
                          style: FluentTheme.of(context).typography.bodyStrong,
                        ),
                        const SizedBox(height: 4),
                        Text(flow.description),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Button(
                    onPressed: () => _open(context, flow.target),
                    child: Text(strings.openOfficialSource),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
