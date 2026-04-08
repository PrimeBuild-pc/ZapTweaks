import 'package:fluent_ui/fluent_ui.dart';

class LogsViewDialog extends StatelessWidget {
  const LogsViewDialog({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(title),
      constraints: const BoxConstraints(maxWidth: 980, maxHeight: 700),
      content: SizedBox(
        width: 900,
        height: 520,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.45)),
            color: const Color(0xFF171717),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: const TextStyle(
                fontFamily: 'Consolas',
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
