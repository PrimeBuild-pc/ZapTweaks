import 'package:fluent_ui/fluent_ui.dart';

FluentThemeData buildZapTweaksTheme({
  required Color accentColor,
  Brightness brightness = Brightness.dark,
}) {
  final swatch = _buildAccentSwatch(accentColor);
  final dark = brightness == Brightness.dark;

  return FluentThemeData(
    brightness: brightness,
    accentColor: AccentColor.swatch(swatch),
    scaffoldBackgroundColor: dark
        ? const Color(0xFF202020)
        : const Color(0xFFF5F5F5),
    cardColor: dark ? const Color(0xFF2A2A2A) : Colors.white,
    micaBackgroundColor: dark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF3F3F3),
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
