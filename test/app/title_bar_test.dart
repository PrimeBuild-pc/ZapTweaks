import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/app/widgets/windows_title_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('title bar displays by PrimeBuild branding', (tester) async {
    await tester.pumpWidget(
      FluentApp(
        home: WindowsTitleBar(
          onAboutPressed: () {},
          backgroundColor: const Color(0xFF1E1E1E),
          wrapWithWindowFrame: false,
          showWindowButtons: false,
        ),
      ),
    );

    expect(find.text('ZapTweaks'), findsOneWidget);
    expect(find.text('by PrimeBuild'), findsOneWidget);
  });
}
