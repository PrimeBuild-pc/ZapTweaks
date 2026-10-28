import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/presentation/app_inventory_page.dart';
import 'package:script_utility/features/tweaks/application/tweak_controller.dart';
import 'package:script_utility/l10n/app_localizations.dart';

import '../../operations/appx_test_fixtures.dart';

class _Inventory extends ProcessRunner {
  _Inventory()
    : super(mode: ProcessExecutionMode.dryRun, dryRunDelay: Duration.zero);

  @override
  Future<String> runPowerShellForOutput(String script) async {
    if (script.contains('QuietUninstallString')) {
      return jsonEncode([
        {
          'Hive': 'HKLM',
          'View': '64',
          'Key': 'Big',
          'DisplayName': 'Big Game Launcher',
          'Publisher': 'Contoso',
          'EstimatedSize': 4 * 1024 * 1024,
          'UninstallString': 'u.exe',
        },
        {
          'Hive': 'HKLM',
          'View': '64',
          'Key': 'Small',
          'DisplayName': 'Small Tool',
          'EstimatedSize': 1024,
          'UninstallString': 'u.exe',
        },
        {
          'Hive': 'HKLM',
          'View': '64',
          'Key': 'VC',
          'DisplayName': 'Microsoft Visual C++ 2015-2022 Redistributable (x64)',
          'EstimatedSize': 20000,
          'UninstallString': 'u.exe',
        },
      ]);
    }
    if (script.contains('InstallLocation')) return '[]';
    return jsonEncode(appxInventory());
  }

  @override
  Future<CommandResult> run(
    String executable,
    List<String> arguments, {
    bool runInShell = false,
    Duration timeout = const Duration(minutes: 2),
  }) async => const CommandResult(exitCode: 1, stdout: '', stderr: 'no winget');
}

class _Controller extends ChangeNotifier implements TweakController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester) async {
  final previous = ProcessRunner.shared;
  ProcessRunner.configureShared(_Inventory());
  addTearDown(() => ProcessRunner.configureShared(previous));
  tester.view.physicalSize = const Size(1280, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final controller = _Controller();
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    FluentApp(
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AppInventoryPage(controller: controller),
    ),
  );
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

double _y(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dy;

void main() {
  testWidgets('one list: programs and Store apps, biggest first', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Big Game Launcher'), findsOneWidget);
    expect(find.text('4.0 GB'), findsOneWidget);
    expect(_y(tester, 'Big Game Launcher'), lessThan(_y(tester, 'Small Tool')));
    await tester.scrollUntilVisible(
      find.text('Feedback Hub'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Feedback Hub'), findsOneWidget);
    expect(find.text('Controlla prima'), findsWidgets, reason: 'VC++ runtime');
    expect(tester.takeException(), isNull);
  });

  testWidgets('selection shows count and total size', (tester) async {
    await _pump(tester);

    final rowCheckbox = find.descendant(
      of: find
          .ancestor(
            of: find.text('Big Game Launcher'),
            matching: find.byType(Row),
          )
          .first,
      matching: find.byType(Checkbox),
    );
    await tester.tap(rowCheckbox);
    await tester.pumpAndSettle();

    expect(find.textContaining('1 selezionate · 4.0 GB'), findsOneWidget);
  });
}
