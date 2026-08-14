// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ZapTweaks';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Elige el idioma que usa ZapTweaks.';

  @override
  String get settings => 'Configuración';

  @override
  String get startWithWindows => 'Iniciar con Windows';

  @override
  String get startWithWindowsDescription =>
      'Inicia ZapTweaks después de iniciar sesión en Windows.';

  @override
  String get openLogFolder => 'Abrir carpeta de registros';

  @override
  String get redetectSystemState => 'Volver a detectar el estado del sistema';

  @override
  String get exportProfile => 'Exportar perfil';

  @override
  String get importProfile => 'Importar perfil';

  @override
  String get resetAppSettings => 'Restablecer ajustes de la aplicación';

  @override
  String get updates => 'Actualizaciones';

  @override
  String get automaticUpdateNotifications =>
      'Notificaciones automáticas de actualización';

  @override
  String get automaticUpdateDescription =>
      'Comprueba al iniciar y muestra un indicador. Las actualizaciones nunca se instalan automáticamente.';

  @override
  String get checking => 'Comprobando...';

  @override
  String get checkNow => 'Comprobar ahora';

  @override
  String get viewRelease => 'Ver versión';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get applicationVersion => 'Versión de la aplicación';

  @override
  String get dryRunMode => 'Modo de simulación';

  @override
  String get dryRunDescription => 'Simula comandos sin modificar Windows.';

  @override
  String get done => 'Hecho';

  @override
  String get operationFailed => 'Operación fallida';

  @override
  String get updateAvailable => 'Hay una actualización disponible';

  @override
  String get updateAvailableDescription =>
      'Puedes revisar las notas de la versión o instalarla directamente.';
}
