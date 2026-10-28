import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/app/widgets/ui_kit.dart';
import 'package:script_utility/l10n/app_localizations.dart';

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  FluentApp(
    locale: const Locale('it'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ScaffoldPage(content: child),
  ),
);

void main() {
  testWidgets('badges always carry a text label', (tester) async {
    await _pump(
      tester,
      const Column(
        children: <Widget>[
          AttributionBadge('Fr33thy'),
          StatusBadge('Tienila', tone: BadgeTone.critical),
        ],
      ),
    );

    expect(find.text('by Fr33thy'), findsOneWidget);
    expect(find.text('Tienila'), findsOneWidget);
  });

  testWidgets('confirmAction returns the choice and cancel is localized', (
    tester,
  ) async {
    bool? result;
    await _pump(
      tester,
      Builder(
        builder: (context) => Button(
          onPressed: () async => result = await confirmAction(
            context,
            title: 'Elimina',
            message: 'Sicuro?',
            confirmLabel: 'Elimina',
            destructive: true,
          ),
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('empty state shows message and optional action', (tester) async {
    var tapped = false;
    await _pump(
      tester,
      EmptyState(
        'Nessuna app',
        actionLabel: 'Aggiorna',
        onAction: () => tapped = true,
      ),
    );

    await tester.tap(find.text('Aggiorna'));
    await tester.pumpAndSettle();
    expect(find.text('Nessuna app'), findsOneWidget);
    expect(tapped, isTrue);
  });
}
