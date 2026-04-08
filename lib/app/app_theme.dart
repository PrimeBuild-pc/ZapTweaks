import 'package:fluent_ui/fluent_ui.dart';

FluentThemeData buildZapTweaksTheme({required Color accentColor}) {
  final swatch = _buildAccentSwatch(accentColor);

  return FluentThemeData(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch(swatch),
    scaffoldBackgroundColor: const Color(0xFF202020),
    cardColor: const Color(0xFF2A2A2A),
    micaBackgroundColor: const Color(0xFF1E1E1E),
    visualDensity: VisualDensity.standard,
  );
}

Map<String, Color> _buildAccentSwatch(Color baseColor) {
  Color tone(double amount) {
    if (amount >= 0) {
      return Color.lerp(baseColor, Colors.white, amount) ?? baseColor;
    }

    return Color.lerp(baseColor, Colors.black, -amount) ?? baseColor;
  }

  return <String, Color>{
    'darkest': tone(-0.62),
    'darker': tone(-0.45),
    'dark': tone(-0.25),
    'normal': baseColor,
    'light': tone(0.2),
    'lighter': tone(0.38),
    'lightest': tone(0.56),
  };
}
