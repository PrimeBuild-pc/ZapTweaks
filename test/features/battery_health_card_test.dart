import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/app/widgets/ui_kit.dart';
import 'package:script_utility/features/diagnostics/presentation/battery_health_card.dart';
import 'package:script_utility/l10n/app_localizations.dart';
import 'package:script_utility/platform/windows/battery_health_service.dart';

Future<void> _pump(WidgetTester tester, String json) async {
  await tester.binding.setSurfaceSize(const Size(900, 700));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    FluentApp(
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScaffoldPage(
        content: BatteryHealthSection(
          load: () async => WindowsBatteryHealthService.parse(json),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

BatteryGlyphPainter _painter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((paint) => paint.painter)
    .whereType<BatteryGlyphPainter>()
    .single;

void main() {
  testWidgets('desktop without battery shows nothing', (tester) async {
    await _pump(tester, '{"source":"none","batteries":[]}');
    expect(find.text('Salute della batteria'), findsNothing);
  });

  testWidgets('worn battery shows health, band, capacities and source', (
    tester,
  ) async {
    await _pump(
      tester,
      '{"source":"wmi","batteries":[{"name":"BAT0","designed":50000,'
      '"full":35000,"cycles":412,"remaining":17500,"online":false}]}',
    );
    expect(find.text('Salute della batteria'), findsOneWidget);
    expect(find.text('70%'), findsOneWidget);
    expect(find.text('Usurata'), findsOneWidget);
    expect(find.text('50000 mWh'), findsOneWidget);
    expect(find.text('35000 mWh'), findsOneWidget);
    expect(find.text('30%'), findsOneWidget);
    expect(find.text('412'), findsOneWidget);
    expect(find.text('50% · A batteria'), findsOneWidget);
    expect(find.textContaining('BatteryStaticData'), findsOneWidget);
    expect(_painter(tester).fraction, 0.7);
    expect(_painter(tester).fill, StatusBadge.warning);
  });

  testWidgets('missing design capacity reads "not available", empty glyph', (
    tester,
  ) async {
    await _pump(
      tester,
      '{"source":"report","batteries":[{"name":"BAT0","designed":null,'
      '"full":41000,"cycles":null,"remaining":null,"online":null}]}',
    );
    expect(find.text('0%'), findsNothing);
    expect(find.text('Non disponibile'), findsWidgets);
    expect(_painter(tester).fraction, isNull);
    expect(find.textContaining('powercfg'), findsOneWidget);
  });
}
