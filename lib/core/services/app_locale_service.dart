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

  static String loadingStatus(String code, String value) =>
      _loadingStatuses[normalize(code)]?[value] ?? value;

  static const Map<String, Map<String, String>> _loadingStatuses =
      <String, Map<String, String>>{
        'it': <String, String>{
          'Initializing...': 'Inizializzazione...',
          'Initializing UI...': 'Inizializzazione interfaccia...',
          'Loading preferences...': 'Caricamento preferenze...',
          'Loading tweaks catalog...': 'Caricamento catalogo tweak...',
          'Detecting hardware and tweak states...':
              'Rilevamento hardware e stati dei tweak...',
          'Sampling system metrics...': 'Campionamento metriche di sistema...',
          'Ready': 'Pronto',
        },
        'de': <String, String>{
          'Initializing...': 'Initialisierung...',
          'Initializing UI...': 'Benutzeroberfläche wird initialisiert...',
          'Loading preferences...': 'Einstellungen werden geladen...',
          'Loading tweaks catalog...': 'Tweak-Katalog wird geladen...',
          'Detecting hardware and tweak states...':
              'Hardware und Tweak-Zustände werden erkannt...',
          'Sampling system metrics...': 'Systemmetriken werden erfasst...',
          'Ready': 'Bereit',
        },
        'es': <String, String>{
          'Initializing...': 'Inicializando...',
          'Initializing UI...': 'Inicializando la interfaz...',
          'Loading preferences...': 'Cargando preferencias...',
          'Loading tweaks catalog...': 'Cargando el catálogo de ajustes...',
          'Detecting hardware and tweak states...':
              'Detectando hardware y estados de ajustes...',
          'Sampling system metrics...': 'Midiendo métricas del sistema...',
          'Ready': 'Listo',
        },
        'fr': <String, String>{
          'Initializing...': 'Initialisation...',
          'Initializing UI...': 'Initialisation de l’interface...',
          'Loading preferences...': 'Chargement des préférences...',
          'Loading tweaks catalog...': 'Chargement du catalogue de réglages...',
          'Detecting hardware and tweak states...':
              'Détection du matériel et des réglages...',
          'Sampling system metrics...': 'Mesure des métriques système...',
          'Ready': 'Prêt',
        },
        'ru': <String, String>{
          'Initializing...': 'Инициализация...',
          'Initializing UI...': 'Инициализация интерфейса...',
          'Loading preferences...': 'Загрузка настроек...',
          'Loading tweaks catalog...': 'Загрузка каталога настроек...',
          'Detecting hardware and tweak states...':
              'Определение оборудования и состояний настроек...',
          'Sampling system metrics...': 'Сбор системных метрик...',
          'Ready': 'Готово',
        },
        'zh': <String, String>{
          'Initializing...': '正在初始化...',
          'Initializing UI...': '正在初始化界面...',
          'Loading preferences...': '正在加载偏好设置...',
          'Loading tweaks catalog...': '正在加载优化目录...',
          'Detecting hardware and tweak states...': '正在检测硬件和优化状态...',
          'Sampling system metrics...': '正在采集系统指标...',
          'Ready': '就绪',
        },
      };

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
