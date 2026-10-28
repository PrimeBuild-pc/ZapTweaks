import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/features/apps/application/process_inventory.dart';
import 'package:script_utility/features/apps/presentation/process_list_page.dart';
import 'package:script_utility/l10n/app_localizations.dart';

ProcessEntry _p(int pid, String name, String? path, {int memory = 1000}) =>
    ProcessEntry(
      pid: pid,
      name: name,
      path: path,
      description: null,
      company: null,
      memoryBytes: memory,
      cpuPercent: 1.5,
      sessionId: 1,
    );

void main() {
  testWidgets(
    'only user apps can be ended, after confirmation; signers fill in',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final ended = <int>[];
      await tester.pumpWidget(
        FluentApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ScaffoldPage(
            content: ProcessListPage(
              load: () async => <ProcessEntry>[
                _p(4, 'csrss', null, memory: 500),
                _p(
                  20,
                  'Discord',
                  r'C:\Users\Me\AppData\Local\Discord\Discord.exe',
                  memory: 9000,
                ),
              ],
              signers: (paths) async => <String, String>{
                r'C:\Users\Me\AppData\Local\Discord\Discord.exe':
                    'Discord Inc.',
              },
              end: (entry) async {
                ended.add(entry.pid);
                return true;
              },
              open: (_) async {},
              selfPid: 1,
              systemRoot: r'C:\Windows',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Signed by Discord Inc. · PID 20 · C:\\Users\\Me\\AppData\\Local\\Discord\\Discord.exe',
        ),
        findsOneWidget,
      );
      expect(find.text('Can close'), findsOneWidget);
      expect(find.text('Leave running'), findsOneWidget);

      // Sorted by memory: Discord first, so its End button is the first one.
      final endButtons = find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is Tooltip && w.message == 'End process',
        ),
        matching: find.byType(IconButton),
      );
      expect(tester.widget<IconButton>(endButtons.at(0)).onPressed, isNotNull);
      expect(tester.widget<IconButton>(endButtons.at(1)).onPressed, isNull);

      await tester.tap(endButtons.at(0));
      await tester.pumpAndSettle();
      expect(ended, isEmpty, reason: 'nothing ends before confirming');
      await tester.tap(find.widgetWithText(FilledButton, 'End process'));
      await tester.pumpAndSettle();
      expect(ended, [20]);
    },
  );
}
