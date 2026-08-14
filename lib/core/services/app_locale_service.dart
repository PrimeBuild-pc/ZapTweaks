import 'dart:io';
import 'dart:ui';

class AppLocaleService {
  static const String preferenceKey = 'localeCode';
  static const List<String> supportedCodes = <String>[
    'en',
    'it',
    'de',
    'es',
    'fr',
    'ru',
    'zh',
  ];

  static const Map<String, String> nativeNames = <String, String>{
    'en': 'English',
    'it': 'Italiano',
    'de': 'Deutsch',
    'es': 'Español',
    'fr': 'Français',
    'ru': 'Русский',
    'zh': '简体中文',
  };

  static String normalize(String? code) {
    final normalized = code?.trim().toLowerCase().split(RegExp('[-_]')).first;
    return supportedCodes.contains(normalized) ? normalized! : 'en';
  }

  static String systemCode() => normalize(Platform.localeName);

  static Locale localeFor(String code) => Locale(normalize(code));

  static String category(String code, String value) =>
      _categories[normalize(code)]?[value] ?? value;

  static const Map<String, Map<String, String>> _categories =
      <String, Map<String, String>>{
        'it': <String, String>{
          'Home': 'Home',
          'Shortcuts': 'Collegamenti',
          'Gaming': 'Gioco',
          'Networking': 'Rete',
          'Power & CPU': 'Alimentazione e CPU',
          'Graphics': 'Grafica',
          'Windows': 'Windows',
          'System Checks': 'Controlli di sistema',
          'Services': 'Servizi',
          'Refresh & Recovery': 'Ripristino e recupero',
          'Setup': 'Configurazione',
          'Advanced': 'Avanzate',
          'Privacy': 'Privacy',
          'Visuals': 'Aspetto',
          'Tools': 'Strumenti',
          'Settings': 'Impostazioni',
        },
        'de': <String, String>{
          'Home': 'Start',
          'Shortcuts': 'Verknüpfungen',
          'Gaming': 'Spiele',
          'Networking': 'Netzwerk',
          'Power & CPU': 'Energie und CPU',
          'Graphics': 'Grafik',
          'Windows': 'Windows',
          'System Checks': 'Systemprüfungen',
          'Services': 'Dienste',
          'Refresh & Recovery': 'Wiederherstellung',
          'Setup': 'Einrichtung',
          'Advanced': 'Erweitert',
          'Privacy': 'Datenschutz',
          'Visuals': 'Darstellung',
          'Tools': 'Werkzeuge',
          'Settings': 'Einstellungen',
        },
        'es': <String, String>{
          'Home': 'Inicio',
          'Shortcuts': 'Accesos directos',
          'Gaming': 'Juegos',
          'Networking': 'Red',
          'Power & CPU': 'Energía y CPU',
          'Graphics': 'Gráficos',
          'Windows': 'Windows',
          'System Checks': 'Comprobaciones del sistema',
          'Services': 'Servicios',
          'Refresh & Recovery': 'Recuperación',
          'Setup': 'Configuración',
          'Advanced': 'Avanzado',
          'Privacy': 'Privacidad',
          'Visuals': 'Aspecto',
          'Tools': 'Herramientas',
          'Settings': 'Configuración',
        },
        'fr': <String, String>{
          'Home': 'Accueil',
          'Shortcuts': 'Raccourcis',
          'Gaming': 'Jeux',
          'Networking': 'Réseau',
          'Power & CPU': 'Alimentation et processeur',
          'Graphics': 'Graphiques',
          'Windows': 'Windows',
          'System Checks': 'Vérifications système',
          'Services': 'Services',
          'Refresh & Recovery': 'Récupération',
          'Setup': 'Configuration',
          'Advanced': 'Avancé',
          'Privacy': 'Confidentialité',
          'Visuals': 'Apparence',
          'Tools': 'Outils',
          'Settings': 'Paramètres',
        },
        'ru': <String, String>{
          'Home': 'Главная',
          'Shortcuts': 'Ярлыки',
          'Gaming': 'Игры',
          'Networking': 'Сеть',
          'Power & CPU': 'Питание и ЦП',
          'Graphics': 'Графика',
          'Windows': 'Windows',
          'System Checks': 'Проверка системы',
          'Services': 'Службы',
          'Refresh & Recovery': 'Восстановление',
          'Setup': 'Настройка',
          'Advanced': 'Дополнительно',
          'Privacy': 'Конфиденциальность',
          'Visuals': 'Оформление',
          'Tools': 'Инструменты',
          'Settings': 'Параметры',
        },
        'zh': <String, String>{
          'Home': '主页',
          'Shortcuts': '快捷方式',
          'Gaming': '游戏',
          'Networking': '网络',
          'Power & CPU': '电源和 CPU',
          'Graphics': '图形',
          'Windows': 'Windows',
          'System Checks': '系统检查',
          'Services': '服务',
          'Refresh & Recovery': '刷新和恢复',
          'Setup': '设置',
          'Advanced': '高级',
          'Privacy': '隐私',
          'Visuals': '外观',
          'Tools': '工具',
          'Settings': '设置',
        },
      };
}
