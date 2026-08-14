import '../models/tweak_descriptor.dart';

class LocalizedTweakText {
  const LocalizedTweakText({
    required this.title,
    required this.description,
    required this.details,
    required this.actionLabel,
    this.warningMessage,
  });

  final String title;
  final String description;
  final String details;
  final String actionLabel;
  final String? warningMessage;
}

class TweakTextLocalizer {
  static bool hasTranslation(TweakDescriptor descriptor, String locale) =>
      locale == 'en' ||
      _reviewedCopy[locale]?.containsKey(descriptor.id) == true ||
      _machineCopy[locale]?.containsKey(descriptor.id) == true;

  static LocalizedTweakText resolve(TweakDescriptor descriptor, String locale) {
    final copy =
        _reviewedCopy[locale]?[descriptor.id] ??
        _machineCopy[locale]?[descriptor.id];
    final title = copy?.$1 ?? descriptor.title;
    final description =
        copy?.$2 ??
        _generatedDescription(locale, descriptor) ??
        descriptor.description;
    final detailParts = <String>[description, '', _detail(locale, descriptor)];
    final warning = descriptor.scriptTweak?.warningMessage;
    final localizedWarning = warning == null
        ? null
        : (_warnings[locale]?[warning] ?? warning);
    if (localizedWarning != null && localizedWarning.trim().isNotEmpty) {
      detailParts.add('\n${_label(locale, 'warning')}: $localizedWarning');
    }
    return LocalizedTweakText(
      title: title,
      description: description,
      details: detailParts.join('\n'),
      actionLabel:
          _actionLabels[locale]?[descriptor.scriptTweak?.actionLabel] ??
          descriptor.scriptTweak?.actionLabel ??
          '',
      warningMessage: localizedWarning,
    );
  }

  static String? _generatedDescription(
    String locale,
    TweakDescriptor descriptor,
  ) {
    final kind = descriptor.category == 'Shortcuts'
        ? 'shortcut'
        : descriptor.category == 'Services'
        ? 'service'
        : descriptor.id.startsWith('restore_')
        ? 'restore'
        : null;
    return kind == null ? null : _generatedDescriptions[locale]?[kind];
  }

  static const Map<String, Map<String, String>>
  _generatedDescriptions = <String, Map<String, String>>{
    'it': <String, String>{
      'shortcut': 'Apre lo strumento di Windows selezionato.',
      'service':
          'Disabilita il servizio e salva il precedente tipo di avvio per il ripristino.',
      'restore':
          'Installa di nuovo l’app dal catalogo di pacchetti configurato in Windows.',
    },
    'de': <String, String>{
      'shortcut': 'Öffnet das ausgewählte Windows-Tool.',
      'service':
          'Deaktiviert den Dienst und sichert den vorherigen Starttyp für die Wiederherstellung.',
      'restore':
          'Installiert die App erneut aus der konfigurierten Windows-Paketquelle.',
    },
    'es': <String, String>{
      'shortcut': 'Abre la herramienta de Windows seleccionada.',
      'service':
          'Deshabilita el servicio y guarda el tipo de inicio anterior para restaurarlo.',
      'restore':
          'Vuelve a instalar la aplicación desde la fuente de paquetes configurada de Windows.',
    },
    'fr': <String, String>{
      'shortcut': 'Ouvre l’outil Windows sélectionné.',
      'service':
          'Désactive le service et enregistre son type de démarrage précédent pour la restauration.',
      'restore':
          'Réinstalle l’application depuis la source de paquets Windows configurée.',
    },
    'ru': <String, String>{
      'shortcut': 'Открывает выбранный инструмент Windows.',
      'service':
          'Отключает службу и сохраняет предыдущий тип запуска для восстановления.',
      'restore':
          'Повторно устанавливает приложение из настроенного источника пакетов Windows.',
    },
    'zh': <String, String>{
      'shortcut': '打开所选的 Windows 工具。',
      'service': '禁用服务，并保存原启动类型以便还原。',
      'restore': '从已配置的 Windows 软件包源重新安装应用。',
    },
  };

  static String _detail(String locale, TweakDescriptor descriptor) {
    final parts = <String>[
      _label(locale, descriptor.isScriptAction ? 'action' : 'toggle'),
    ];
    if (descriptor.isAggressive) {
      parts.add(_label(locale, 'restore'));
    }
    if (descriptor.restartRequired) {
      parts.add(_label(locale, 'restart'));
    }
    return parts.join(' ');
  }

  static String _label(String locale, String key) =>
      _labels[locale]?[key] ?? _labels['en']![key]!;

  static const Map<String, Map<String, String>>
  _labels = <String, Map<String, String>>{
    'en': <String, String>{
      'toggle': 'Use the switch to apply or revert this setting.',
      'action': 'This is a one-time action; it has no automatic in-app revert.',
      'restore': 'A restore point is required before it runs.',
      'restart': 'Restart Windows after applying it.',
      'warning': 'Warning',
    },
    'it': <String, String>{
      'toggle':
          'Usa l’interruttore per applicare o ripristinare questa impostazione.',
      'action': 'È un’azione singola senza ripristino automatico nell’app.',
      'restore': 'Prima dell’esecuzione è richiesto un punto di ripristino.',
      'restart': 'Riavvia Windows dopo l’applicazione.',
      'warning': 'Avviso',
    },
    'de': <String, String>{
      'toggle':
          'Mit dem Schalter wird diese Einstellung angewendet oder zurückgesetzt.',
      'action':
          'Dies ist eine einmalige Aktion ohne automatische Rücksetzung in der App.',
      'restore':
          'Vor der Ausführung ist ein Wiederherstellungspunkt erforderlich.',
      'restart': 'Windows nach der Anwendung neu starten.',
      'warning': 'Warnung',
    },
    'es': <String, String>{
      'toggle': 'Usa el interruptor para aplicar o revertir este ajuste.',
      'action':
          'Es una acción única sin reversión automática en la aplicación.',
      'restore': 'Se requiere un punto de restauración antes de ejecutarlo.',
      'restart': 'Reinicia Windows después de aplicarlo.',
      'warning': 'Advertencia',
    },
    'fr': <String, String>{
      'toggle': 'Utilisez le commutateur pour appliquer ou annuler ce réglage.',
      'action':
          'Cette action unique ne possède pas d’annulation automatique dans l’application.',
      'restore': 'Un point de restauration est requis avant son exécution.',
      'restart': 'Redémarrez Windows après l’application.',
      'warning': 'Avertissement',
    },
    'ru': <String, String>{
      'toggle':
          'Используйте переключатель для применения или отмены этого параметра.',
      'action':
          'Это однократное действие без автоматической отмены в приложении.',
      'restore': 'Перед запуском требуется точка восстановления.',
      'restart': 'Перезагрузите Windows после применения.',
      'warning': 'Предупреждение',
    },
    'zh': <String, String>{
      'toggle': '使用开关应用或还原此设置。',
      'action': '这是一次性操作，应用内没有自动还原。',
      'restore': '运行前需要创建还原点。',
      'restart': '应用后请重启 Windows。',
      'warning': '警告',
    },
  };

  // Technical names remain English unless a clear native equivalent exists.
  static const Map<String, Map<String, (String, String)>>
  _reviewedCopy = <String, Map<String, (String, String)>>{
    'it': <String, (String, String)>{
      'game_mode': (
        'Modalità gioco attiva',
        'Attiva Modalità gioco senza modificare Game Bar o Game DVR.',
      ),
      'gaming_windowed_optimizations_on': (
        'Ottimizzazioni giochi in finestra attive',
        'Attiva l’aggiornamento swap-effect di Windows 11 per giochi compatibili in finestra o borderless.',
      ),
      'gaming_mpo_off': (
        'Disattiva Multiplane Overlay (MPO)',
        'Soluzione solo diagnostica per flicker o stutter del display; richiede riavvio.',
      ),
      'gaming_amd_gpu_safe_profile': (
        'Profilo GPU AMD sicuro',
        'Applica un profilo driver AMD reversibile senza disattivare protezione termica, Crash Defender o power gating.',
      ),
      'gaming_amd_gpu_extreme_profile': (
        'Profilo GPU AMD estremo',
        'Disattiva protezioni termiche e di risparmio energetico AMD. Solo per test desktop con monitoraggio temperature.',
      ),
      'network_adapter_power_savings_wake_off': (
        'Disattiva risparmio energetico e wake della scheda',
        'Disattiva power saving e wake sulle schede di rete fisiche e salva lo stato per il ripristino.',
      ),
      'device_power_savings_off': (
        'Disattiva risparmio energetico dispositivi',
        'Disattiva il risparmio energetico WMI dei dispositivi. Aumenta il consumo a riposo.',
      ),
      'network_llmnr_off': (
        'Disattiva LLMNR',
        'Disattiva la risoluzione legacy dei nomi tramite multicast locale.',
      ),
      'network_delivery_optimization_off': (
        'Disattiva Delivery Optimization P2P',
        'Impedisce upload e download peer-to-peer di Windows Update.',
      ),
      'network_fast_udp_datagram_send': (
        'Invio datagrammi UDP veloce',
        'Aumenta la soglia di invio AFD per carichi UDP.',
      ),
      'gaming_variable_refresh_rate_on': (
        'Attiva frequenza di aggiornamento variabile',
        'Attiva la preferenza Windows VRR per i giochi compatibili.',
      ),
      'gaming_extended_gpu_timeout': (
        'Timeout GPU esteso',
        'Imposta un ritardo TDR di 10 secondi per la diagnosi di carichi GPU instabili.',
      ),
      'ui_sticky_keys_shortcut_off': (
        'Disattiva scorciatoia Tasti permanenti',
        'Impedisce che cinque pressioni di Maiusc aprano Tasti permanenti.',
      ),
      'windows_ntfs_last_access_updates_off': (
        'Disattiva aggiornamenti ultimo accesso NTFS',
        'Impedisce a NTFS di aggiornare il timestamp a ogni lettura di file.',
      ),
      'toggle_printing_off': (
        'Disattiva stampa',
        'Disabilita il servizio Spooler di stampa fino al ripristino.',
      ),
      'toggle_location_off': (
        'Disattiva posizione',
        'Disabilita i servizi di localizzazione Windows tramite criteri.',
      ),
      'toggle_automatic_driver_updates_off': (
        'Disattiva aggiornamenti automatici driver',
        'Impedisce a Windows Update di installare automaticamente i driver.',
      ),
      'toggle_storage_sense_off': (
        'Disattiva Sensore memoria',
        'Disabilita la pulizia automatica dei file temporanei.',
      ),
      'toggle_activity_history_off': (
        'Disattiva cronologia attività',
        'Impedisce a Windows di pubblicare e caricare la cronologia attività.',
      ),
      'toggle_scheduled_defrag_off': (
        'Disattiva deframmentazione/TRIM pianificata',
        'Disabilita l’attività pianificata Ottimizza unità; l’ottimizzazione manuale resta disponibile.',
      ),
      'toggle_center_taskbar_icons': (
        'Centra icone barra delle applicazioni',
        'Usa l’allineamento centrato delle icone di Windows 11.',
      ),
      'checks_vbs_off': (
        'Disattiva sicurezza basata sulla virtualizzazione',
        'Disabilita i criteri VBS. Riduce le protezioni di isolamento di Windows e richiede un riavvio.',
      ),
      'checks_smart_screen_off': (
        'Disattiva SmartScreen',
        'Disabilita i controlli di reputazione di Windows. Usare solo per test controllati.',
      ),
      'checks_vulnerable_driver_blocklist_off': (
        'Disattiva elenco blocco driver vulnerabili',
        'Disabilita il blocco Microsoft dei driver vulnerabili, riducendo la protezione del kernel.',
      ),
    },
    'de': <String, (String, String)>{
      'game_mode': (
        'Spielmodus an',
        'Aktiviert den Windows-Spielmodus, ohne Game Bar oder Game DVR zu ändern.',
      ),
      'gaming_mpo_off': (
        'Multiplane Overlay (MPO) deaktivieren',
        'Nur zur Diagnose von Flackern oder Ruckeln; Neustart erforderlich.',
      ),
      'gaming_amd_gpu_safe_profile': (
        'Sicheres AMD-GPU-Profil',
        'Wendet ein umkehrbares AMD-Treiberprofil ohne Abschaltung von Thermalschutz, Crash Defender oder Power Gating an.',
      ),
      'gaming_amd_gpu_extreme_profile': (
        'Extremes AMD-GPU-Profil',
        'Deaktiviert AMD-Temperatur- und Energieschutz. Nur für Desktop-Tests mit Temperaturüberwachung.',
      ),
      'device_power_savings_off': (
        'Geräte-Energiesparen aus',
        'Deaktiviert WMI-Energiesparen für Geräte und erhöht den Leerlaufverbrauch.',
      ),
    },
    'es': <String, (String, String)>{
      'game_mode': (
        'Modo de juego activado',
        'Activa el modo de juego de Windows sin modificar Game Bar ni Game DVR.',
      ),
      'gaming_mpo_off': (
        'Desactivar Multiplane Overlay (MPO)',
        'Solución solo de diagnóstico para parpadeos o tirones; requiere reinicio.',
      ),
      'gaming_amd_gpu_safe_profile': (
        'Perfil seguro de GPU AMD',
        'Aplica un perfil reversible del controlador AMD sin desactivar protección térmica, Crash Defender ni power gating.',
      ),
      'gaming_amd_gpu_extreme_profile': (
        'Perfil extremo de GPU AMD',
        'Desactiva las protecciones térmicas y de energía de AMD. Solo para pruebas de escritorio con control de temperatura.',
      ),
      'device_power_savings_off': (
        'Desactivar ahorro de energía de dispositivos',
        'Desactiva el ahorro de energía WMI de dispositivos y aumenta el consumo en reposo.',
      ),
    },
    'fr': <String, (String, String)>{
      'game_mode': (
        'Mode Jeu activé',
        'Active le Mode Jeu Windows sans modifier Game Bar ni Game DVR.',
      ),
      'gaming_mpo_off': (
        'Désactiver Multiplane Overlay (MPO)',
        'Solution de diagnostic uniquement pour scintillement ou saccades ; redémarrage requis.',
      ),
      'gaming_amd_gpu_safe_profile': (
        'Profil GPU AMD sûr',
        'Applique un profil pilote AMD réversible sans désactiver protection thermique, Crash Defender ni power gating.',
      ),
      'gaming_amd_gpu_extreme_profile': (
        'Profil GPU AMD extrême',
        'Désactive les protections thermiques et énergétiques AMD. Réservé aux tests sur desktop avec surveillance des températures.',
      ),
      'device_power_savings_off': (
        'Désactiver l’économie d’énergie des appareils',
        'Désactive l’économie d’énergie WMI des appareils et augmente la consommation au repos.',
      ),
    },
    'ru': <String, (String, String)>{
      'game_mode': (
        'Игровой режим включён',
        'Включает игровой режим Windows, не изменяя Game Bar и Game DVR.',
      ),
      'gaming_mpo_off': (
        'Отключить Multiplane Overlay (MPO)',
        'Только для диагностики мерцания или рывков; требуется перезагрузка.',
      ),
      'gaming_amd_gpu_safe_profile': (
        'Безопасный профиль GPU AMD',
        'Применяет обратимый профиль драйвера AMD без отключения термозащиты, Crash Defender или управления питанием.',
      ),
      'gaming_amd_gpu_extreme_profile': (
        'Экстремальный профиль GPU AMD',
        'Отключает тепловую и энергозащиту AMD. Только для настольных тестов с контролем температуры.',
      ),
      'device_power_savings_off': (
        'Отключить энергосбережение устройств',
        'Отключает энергосбережение устройств WMI и повышает потребление в простое.',
      ),
    },
    'zh': <String, (String, String)>{
      'game_mode': ('开启游戏模式', '开启 Windows 游戏模式，不会修改 Game Bar 或 Game DVR。'),
      'gaming_mpo_off': ('禁用多平面叠加 (MPO)', '仅用于诊断显示闪烁或卡顿；需要重启。'),
      'gaming_amd_gpu_safe_profile': (
        'AMD GPU 安全配置',
        '应用可还原的 AMD 驱动配置，不会关闭热保护、Crash Defender 或电源门控。',
      ),
      'gaming_amd_gpu_extreme_profile': (
        'AMD GPU 极限配置',
        '关闭 AMD 热保护和节能保护。仅限监控温度的台式机测试。',
      ),
      'device_power_savings_off': ('关闭设备节能', '关闭设备的 WMI 节能功能并提高待机功耗。'),
    },
  };

  static const Map<String, Map<String, (String, String)>>
  _machineCopy = <String, Map<String, (String, String)>>{
    "it": <String, (String, String)>{
      "shortcut_advanced_system_settings": (
        "Impostazioni di sistema avanzate",
        "Performance, effetti visivi e ambientazioni.",
      ),
      "shortcut_bluetooth": (
        "Bluetooth e dispositivi",
        "Dispositivi associati, stampanti e impostazioni del mouse.",
      ),
      "shortcut_computer_management": (
        "Gestione informatica",
        "Console unificata per gli strumenti di sistema.",
      ),
      "shortcut_device_manager": (
        "Gestione dispositivi",
        "Apre Gestione dispositivi.",
      ),
      "shortcut_directx_diagnostic": (
        "Diagnostica DirectX",
        "GPU, versione DirectX e diagnostica audio.",
      ),
      "shortcut_disk_management": (
        "Gestione disco",
        "Partizioni, volumi e lettere di unità.",
      ),
      "shortcut_display": (
        "Visualizzazione",
        "Risoluzione, ridimensionamento, HDR e frequenza di aggiornamento.",
      ),
      "shortcut_environment_variables": (
        "Variabili d'ambiente",
        "PATH di sistema e utente, TEMP e altre variabili.",
      ),
      "shortcut_event_viewer": (
        "Visualizzatore eventi",
        "Registri di sistema e delle applicazioni.",
      ),
      "shortcut_game_mode": (
        "Impostazioni della modalità di gioco",
        "Impostazioni della modalità gioco di Windows.",
      ),
      "shortcut_graphics_settings": (
        "Impostazioni grafiche",
        "Preferenza GPU per app e HAGS.",
      ),
      "shortcut_hosts_file": (
        "File degli host",
        "Apre il file host nel Blocco note.",
      ),
      "shortcut_installed_apps": (
        "App installate",
        "Disinstallare e riparare le applicazioni installate.",
      ),
      "shortcut_network": (
        "Rete",
        "Impostazioni Ethernet, Wi-Fi, VPN e proxy.",
      ),
      "shortcut_optional_features": (
        "Funzionalità opzionali",
        "Gestisci le funzionalità facoltative di Windows.",
      ),
      "shortcut_performance_monitor": (
        "Monitoraggio delle prestazioni",
        "Contatori attivi e set di dati.",
      ),
      "shortcut_personalization": (
        "Personalizzazione",
        "Sfondo, colori e impostazioni della schermata di blocco.",
      ),
      "shortcut_power_battery": (
        "Alimentazione e batteria",
        "Impostazioni di sospensione, timeout dello schermo e batteria.",
      ),
      "shortcut_privacy_security": (
        "Privacy e sicurezza",
        "Autorizzazioni sulla privacy e sicurezza di Windows.",
      ),
      "shortcut_registry_editor": (
        "Editor del registro",
        "Accesso diretto al registro.",
      ),
      "shortcut_reliability_history": (
        "Storia dell'affidabilità",
        "Arresti anomali, fallimenti e storia della stabilità.",
      ),
      "shortcut_resource_monitor": (
        "Monitoraggio delle risorse",
        "Attività di CPU, memoria, disco e rete.",
      ),
      "shortcut_services": (
        "Servizi",
        "Avvia, arresta e configura i servizi Windows.",
      ),
      "shortcut_sound": ("Suono", "Impostazioni di uscita, ingresso e volume."),
      "shortcut_startup_folder": (
        "Cartella di avvio",
        "Applicazioni di avvio per utente.",
      ),
      "shortcut_system_configuration": (
        "Configurazione del sistema",
        "Opzioni di avvio e servizi di avvio.",
      ),
      "shortcut_task_scheduler": (
        "Utilità di pianificazione",
        "Attività pianificate e trigger.",
      ),
      "shortcut_windows_features": (
        "Funzionalità di Windows",
        "Attiva o disattiva le funzionalità di Windows.",
      ),
      "shortcut_windows_update": (
        "Aggiornamento di Windows",
        "Controlla e installa gli aggiornamenti.",
      ),
      "gaming_amd_gpu_extreme_profile": (
        "Profilo estremo della GPU AMD",
        "Disabilita la limitazione termica AMD, Crash Defender, power gating, clock gating, ULPS, ASPM e altri comportamenti di risparmio energetico. Solo risoluzione dei problemi del desktop.",
      ),
      "gaming_amd_gpu_safe_profile": (
        "Profilo sicuro GPU AMD",
        "Applica un profilo driver AMD reversibile senza disabilitare la protezione termica, Crash Defender, clock gating o power gating.",
      ),
      "gpu_amd_optimizations": (
        "Risoluzione dei problemi ULPS GPU AMD",
        "Disabilita AMD ULPS per la risoluzione dei problemi; non disabilita la protezione termica o il power gate.",
      ),
      "cpu_amd_optimizations": (
        "Ottimizzazioni AMD Ryzen",
        "Applica la regolazione di potenza e latenza specifica di AMD.",
      ),
      "gaming_amd_ulps_off": (
        "AMD ULPS disattivato",
        "Disabilita EnableUlps sulle chiavi della classe di visualizzazione AMD. Utile per i test di latenza.",
      ),
      "cpu_unparking": (
        "Annullamento del parcheggio del core della CPU",
        "Rimuovi il parcheggio da tutti i core della CPU per carichi di lavoro a bassa latenza.",
      ),
      "cpu_power_management": (
        "Gestione energetica della CPU",
        "Disabilita la limitazione e ottimizza il comportamento dello scheduler.",
      ),
      "gaming_mpo_off": (
        "Disabilita sovrapposizione multipiano (MPO)",
        "Soluzione alternativa di sola risoluzione dei problemi per sfarfallio o balbettio del display; è necessario riavviare.",
      ),
      "gaming_extended_gpu_timeout": (
        "Timeout GPU esteso",
        "Imposta un ritardo di rilevamento del timeout della GPU di 10 secondi per la risoluzione dei problemi relativi a carichi di lavoro GPU pesanti e instabili.",
      ),
      "gaming_legacy_flip_fse": (
        "Flip legacy esclusivo a schermo intero",
        "Passa GameConfigStore al comportamento orientato a FSE per i test a schermo intero legacy.",
      ),
      "game_mode": (
        "Modalità gioco attiva",
        "Abilita la modalità gioco di Windows senza modificare la barra di gioco Xbox o il DVR di gioco.",
      ),
      "gaming_composed_flip_immediate_mode": (
        "Flip indipendente composto da hardware",
        "Forza ForceFlipTrueImmediateMode=1 nello scheduler grafico.",
      ),
      "cpu_intel_optimizations": (
        "Ottimizzazioni della CPU Intel",
        "Ottimizza il profilo di pianificazione Intel P ed E core.",
      ),
      "gpu_intel_optimizations": (
        "Ottimizzazioni GPU Intel",
        "Applicare l'ottimizzazione delle prestazioni dello stack grafico Intel.",
      ),
      "gpu_nvidia_optimizations": (
        "Ottimizzazioni NVIDIA",
        "Applica la pianificazione grafica NVIDIA e le modifiche alla latenza.",
      ),
      "gaming_windowed_optimizations_on": (
        "Ottimizzazioni per i giochi in finestra attivati",
        "Abilita l'aggiornamento con effetto scambio di Windows 11 per giochi compatibili con finestre e senza bordi.",
      ),
      "ram_optimizations": (
        "Ottimizzazioni della RAM",
        "Ottimizza il gestore della memoria e il comportamento della cache.",
      ),
      "storage_optimizations": (
        "Ottimizzazioni dello spazio di archiviazione",
        "Ottimizza il comportamento di NTFS, TRIM e alimentazione di archiviazione.",
      ),
      "timer_latency": (
        "Timer e latenza",
        "Ottimizza il comportamento di MMCSS e delle richieste del timer.",
      ),
      "gaming_variable_refresh_rate_on": (
        "Frequenza di aggiornamento variabile attivata",
        "Abilita la preferenza della frequenza di aggiornamento variabile di Windows per i giochi compatibili.",
      ),
      "network_adapter_power_savings_wake_off": (
        "Risparmio energetico dell'adattatore e riattivazione",
        "Disabilita le funzionalità di risparmio energetico e riattivazione sugli adattatori di rete fisici, con un backup esatto per il ripristino.",
      ),
      "network_delivery_optimization_off": (
        "Ottimizzazione della consegna P2P disattivato",
        "Interrompe i caricamenti e i download peer-to-peer di Windows Update.",
      ),
      "device_power_savings_off": (
        "Risparmio energetico del dispositivo disattivato",
        "Disabilita il risparmio energetico del dispositivo WMI. Ciò aumenta il consumo energetico in modalità inattiva ed è destinato ai desktop.",
      ),
      "network_ecn_disabled": (
        "Disabilita ECN",
        "Disabilita la notifica esplicita di congestione per favorire un comportamento prevedibile a bassa latenza.",
      ),
      "network_timestamps_disabled": (
        "Disabilita timestamp TCP",
        "Disabilita i timestamp TCP per ridurre il sovraccarico del protocollo in scenari incentrati sulla latenza.",
      ),
      "network_rss_enabled": (
        "Abilita RSS",
        "Abilita Receive Side Scaling per distribuire l'elaborazione dei pacchetti tra i core della CPU.",
      ),
      "network_fast_udp_datagram_send": (
        "Invio veloce del datagramma UDP",
        "Aumenta la soglia di invio del datagramma AFD per i carichi di lavoro UDP.",
      ),
      "network_ipv4_only": (
        "Associazioni solo IPv4",
        "Disabilita i collegamenti degli adattatori non essenziali e mantiene IPv4 abilitato su tutti gli adattatori.",
      ),
      "network_llmnr_off": (
        "LLMNR disattivato",
        "Disabilita la risoluzione dei nomi multicast locale legacy.",
      ),
      "network_low_latency_bandwidth_profile": (
        "Profilo di rete a bassa latenza",
        "Applica un profilo di rete aggressivo a bassa latenza che può ridurre la velocità effettiva e l'efficienza complessiva della larghezza di banda.",
      ),
      "network_mmagent_features_off": (
        "Funzionalità MMAgent disattivate",
        "Disabilita le funzionalità di prefetch/prelaunch/OperationAPI di MMAgent e imposta Prefetcher su 0.",
      ),
      "network_optimizations": (
        "Ottimizzazioni di rete",
        "Ottimizza il profilo TCP e rimuovi la limitazione multimediale.",
      ),
      "network_throttling_index_off": (
        "Indice di limitazione della rete disattivato",
        "Imposta NetworkThrottlingIndex su 0xFFFFFFFF per rimuovere i limiti di limitazione multimediale.",
      ),
      "network_prefer_ipv4": (
        "Preferire IPv4 a IPv6",
        "Mantiene IPv6 abilitato ma dà la precedenza a IPv4. Non può essere combinato con i collegamenti Solo IPv4.",
      ),
      "network_itr_interactive_config": (
        "Configurazione interattiva NIC ITR",
        "Apre uno strumento interattivo con privilegi elevati per configurare la velocità di accelerazione dell'interruzione NIC (ITR) per gli adattatori Realtek/Intel/Killer supportati.",
      ),
      "power_amd_preferred_cores": (
        "Core preferiti AMD",
        "Abilita AMD Precision Boost: consente alla CPU di dare priorità ai core più potenti per carichi di lavoro a thread singolo. Solo CPU AMD.",
      ),
      "power_cpu_core_parking_off": (
        "Parcheggio core CPU disattivato",
        "Mostra e imposta i core min/max di parcheggio core del piano attivo al 100%.",
      ),
      "power_disable_cstates": (
        "Disabilita gli stati C della CPU",
        "Limita gli stati di sospensione della CPU per la massima reattività e un potenziamento istantaneo. Solo desktop: aumenta significativamente la temperatura e il consumo di energia in caso di inattività.",
      ),
      "power_cpu_idle_demote_promote": (
        "Disabilita la retrocessione/promozione della CPU inattiva",
        "Imposta le soglie di retrocessione/promozione di inattività al 100% per ridurre il tempo impiegato dalla CPU per entrare/uscire dagli stati di inattività. Latenza inferiore a costi energetici più elevati.",
      ),
      "power_disable_dynamic_tick": (
        "Disabilita il segno di spunta dinamico",
        "Esegue bcdedit /set awaredynamictick yes: rende il timer di sistema più coerente, riduce i micro-stutter nei giochi e nelle app a bassa latenza. Ancora efficace su Windows 11 nel 2026.",
      ),
      "power_fast_startup_hibernate_off": (
        "Avvio rapido e ibernazione disattivata",
        "Disabilita l'ibernazione e l'avvio rapido per una latenza inferiore e un comportamento di spegnimento più pulito.",
      ),
      "power_global_timer_resolution": (
        "Richieste di risoluzione globale del timer",
        "Imposta GlobalTimerResolutionRequests=1: ripristina il comportamento del timer ad alta risoluzione a livello di sistema su Windows 11. Essenziale per app/giochi che si basano su una precisione del timer di 1 ms o 0,5 ms.",
      ),
      "power_hardware_pstates_intel": (
        "P-state hardware Intel (HWP)",
        "Configura Intel Speed Shift/Hardware P-States per la massima polarizzazione delle prestazioni. Solo CPU Intel.",
      ),
      "power_max_processor_state": (
        "Stato massimo del processore (100%)",
        "Imposta la frequenza massima della CPU al 100% per impedire un downclock aggressivo sotto carico.",
      ),
      "power_throttling_off": (
        "Limitazione della potenza disattivata",
        "Disabilita la limitazione dell'alimentazione di Windows per una pianificazione più coerente della CPU sotto carico.",
      ),
      "power_processor_boost_mode": (
        "Modalità di potenziamento delle prestazioni del processore",
        "Abilita la modalità boost aggressiva della CPU (Intel/AMD). Migliora i clock di boost sostenuti sui carichi di lavoro multi-thread. Consigliato per desktop ben raffreddati.",
      ),
      "power_processor_time_check_interval": (
        "Intervallo di controllo del tempo del processore (5 ms)",
        "Riduce l'intervallo di controllo dello scheduler della CPU da 15 ms a 5 ms per una risposta di scalabilità della frequenza più rapida.",
      ),
      "power_system_responsiveness_registry": (
        "Reattività del sistema (10)",
        "Imposta SystemResponsiveness su 10 (dal valore predefinito 20): offre più tempo CPU alle app in primo piano rispetto ai servizi di sistema. Migliora la sensazione di gioco e multitasking.",
      ),
      "power_tsc_sync_policy": (
        "Policy di sincronizzazione TSC (migliorata)",
        "Imposta tscsyncpolicy su Avanzato: migliora la sincronizzazione del timer del core della CPU sui sistemi multi-core. Basso rischio, particolarmente utile sui vecchi sistemi multi-socket.",
      ),
      "power_ultimate_performance_plan": (
        "Piano di potenza per prestazioni definitive",
        "Importa e attiva Ultimate Performance. Ripristina torna a Bilanciato.",
      ),
      "power_win32_priority_separation": (
        "Separazione priorità Win32 (giochi)",
        "Imposta Win32PrioritySeparation su 26 (hex 0x1a): dà la priorità al tempo della CPU dell'app in primo piano. Tweak di gioco classico per una latenza di input inferiore.",
      ),
      "graphics_amd_settings": (
        "Impostazioni AMD",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_cpp_runtime": (
        "Tempo di esecuzione C++",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_directx": (
        "Tempo di esecuzione di DirectX",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_driver_clean": (
        "Autista pulito",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_driver_install_debloat_settings": (
        "Installazione driver Debloat e impostazioni",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_driver_install_latest": (
        "Installazione driver più recente",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_hags_windowed": (
        "HAGS Finestrato",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_hdcp": ("HDCP", "Sceneggiatura interattiva di Fr33thy."),
      "graphics_intel_settings": (
        "Impostazioni Intel",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_msi_mode_script": (
        "Modalità MSI (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_nvidia_settings": (
        "Impostazioni NVIDIA",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_p0_state": (
        "Stato P0",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "graphics_resolution_refresh_rate": (
        "Frequenza di aggiornamento della risoluzione",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_auto_reboot_after_bsod_off": (
        "Riavvio automatico dopo la disattivazione di BSOD",
        "Mantiene un codice di arresto sullo schermo invece di riavviarsi automaticamente dopo un incidente.",
      ),
      "toggle_automatic_driver_updates_off": (
        "Aggiornamenti automatici dei driver disattivati",
        "Impedisce a Windows Update di installare automaticamente gli aggiornamenti dei driver.",
      ),
      "windows_automatic_maintenance_off": (
        "Manutenzione automatica disattivata",
        "Disabilita la manutenzione automatica programmata preservando gli strumenti di manutenzione manuale.",
      ),
      "windows_ntfs_last_access_updates_off": (
        "Aggiornamenti dell'ultimo accesso NTFS disattivati",
        "Impedisce a NTFS di aggiornare un timestamp ogni volta che viene letto un file.",
      ),
      "toggle_scheduled_defrag_off": (
        "Deframmentazione/TRIM pianificata disattivata",
        "Disabilita l'attività pianificata Ottimizza unità; l'ottimizzazione manuale rimane disponibile.",
      ),
      "toggle_storage_sense_off": (
        "Sensore memoria disattivato",
        "Disabilita la pulizia automatica dei file temporanei.",
      ),
      "system_responsiveness": (
        "Reattività del sistema",
        "Riduci i ritardi dell'interfaccia utente e i valori di timeout delle attività.",
      ),
      "windows_update": (
        "Comportamento di Windows Update",
        "Regola il comportamento degli aggiornamenti per flussi di lavoro incentrati sui giochi.",
      ),
      "windows_autoruns_startup_tasks_apps_check": (
        "Attività di avvio e verifica delle app con esecuzione automatica",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_bloatware_script": (
        "Bloatware (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_bloatware_legacy_apps_check_script": (
        "Controllo delle app legacy Bloatware (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_bloatware_legacy_features_check_script": (
        "Controllo delle funzionalità legacy di Bloatware (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_bloatware_taskmgr_check_script": (
        "Bloatware TaskMgr Check (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_bloatware_uwp_apps_check_script": (
        "Controllo delle app UWP bloatware (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_bloatware_uwp_features_check_script": (
        "Controllo delle funzionalità UWP di Bloatware (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_cleanup": ("Pulizia", "Sceneggiatura interattiva di Fr33thy."),
      "windows_context_menu_script": (
        "Menu contestuale (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_control_panel_settings_script": (
        "Impostazioni del pannello di controllo (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_copilot_script": (
        "Copilota (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_core_isolation_script": (
        "Isolamento del core (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_defender_optimize": (
        "Ottimizzazione difensore",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_device_manager_power_savings_wake": (
        "Gestione dispositivi Risparmio energetico e riattivazione",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_edge_webview_script": (
        "Edge e WebView (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_gamebar_script": (
        "Barra di gioco (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_gamemode": (
        "Modalità di gioco",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_loudness_eq": (
        "EQ del volume",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_nvme_faster_driver": (
        "Driver NVME più veloce",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_network_adapter_power_savings_script": (
        "Adattatore di rete Risparmio energetico e riattivazione (variante script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_network_ipv4_only_script": (
        "Solo rete IPv4 (variante script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_notepad_settings": (
        "Impostazioni del blocco note",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_pointer_precision_script": (
        "Precisione del puntatore (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_power_plan_script": (
        "Piano di alimentazione (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_restore_point": (
        "Punto di ripristino",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_scaling": (
        "Ridimensionamento",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_signout_lockscreen_wallpaper_black": (
        "Sfondo della schermata di blocco per l'uscita nero",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_sound": ("Suono", "Sceneggiatura interattiva di Fr33thy."),
      "windows_start_menu_layout_script": (
        "Layout del menu Start (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_start_menu_shortcuts_script": (
        "Scorciatoie del menu Start (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_start_menu_taskbar_script": (
        "Barra delle applicazioni del menu Start (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_theme_black_script": (
        "Tema Nero (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_timer_resolution_script": (
        "Risoluzione timer (variante script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_uac_script": (
        "UAC (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_user_account_pictures_black": (
        "Immagini dell'account utente nere",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_widgets_script": (
        "Widget (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "windows_write_cache_buffer_flushing": (
        "Scrivere lo svuotamento del buffer della cache",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "checks_core_isolation_off": (
        "Isolamento del nucleo Integrità della memoria disattivata",
        "Disabilita l'integrità della memoria HVCI tramite lo scenario del registro DeviceGuard.",
      ),
      "checks_dep_off": (
        "Prevenzione esecuzione dati disattivata",
        "Imposta bcdedit nx su AlwaysOff. Ripristina elimina l'override di nx (impostazione predefinita di Windows).",
      ),
      "checks_firewall_off": (
        "Firewall disattivato",
        "Disabilita i profili firewall pubblici e standard. Ripristina ripristina lo stato abilitato predefinito.",
      ),
      "checks_memory_compression_off": (
        "Compressione della memoria disattivata",
        "Disabilita MemoryCompression in MMAgent per ridurre il sovraccarico della CPU in caso di carichi burst.",
      ),
      "checks_smart_screen_off": (
        "SmartScreen disattivato",
        "Disabilita i controlli di reputazione di Windows. Utilizzare solo per test controllati.",
      ),
      "checks_spectre_meltdown_off": (
        "Mitigazioni Spettro/Fusione disattivate",
        "Imposta FeatureSettingsOverride e FeatureSettingsOverrideMask su 3.",
      ),
      "checks_uac_off": (
        "UAC disattivato",
        "Imposta il controllo dell'account utente su disabilitato. Per ottenere l'effetto completo è necessario un riavvio.",
      ),
      "checks_vbs_off": (
        "Sicurezza basata sulla virtualizzazione disattivata",
        "Disabilita la politica VBS. Ciò indebolisce le protezioni di isolamento di Windows e richiede un riavvio.",
      ),
      "checks_vulnerable_driver_blocklist_off": (
        "Lista bloccata driver vulnerabili disattivata",
        "Disabilita la blocklist dei driver vulnerabili di Microsoft. Ciò indebolisce la protezione del kernel e richiede un riavvio.",
      ),
      "check_bios_settings": (
        "Guida alle impostazioni del BIOS",
        "Script di guida interattiva del BIOS di Fr33thy.",
      ),
      "check_bios_update": (
        "Ricerca aggiornamento BIOS",
        "Apre lo script di ricerca della scheda madre di Fr33thy.",
      ),
      "check_cpu_test": (
        "Prova della CPU",
        "Script interattivo per lo stress test di Fr33thy.",
      ),
      "check_gpu_check": (
        "Controllo GPU",
        "Script diagnostico interattivo di Fr33thy.",
      ),
      "check_gpu_test": (
        "Prova della GPU",
        "Script interattivo per lo stress test di Fr33thy.",
      ),
      "check_hw_info": (
        "Informazioni sull'hardware",
        "Script interattivo di informazioni sull'hardware di Fr33thy.",
      ),
      "check_ram_check": (
        "Controllo RAM",
        "Script diagnostico interattivo di Fr33thy.",
      ),
      "check_ram_test": (
        "Prova della RAM",
        "Script interattivo per lo stress test di Fr33thy.",
      ),
      "check_space_check": (
        "Controllo dello spazio",
        "Script diagnostico interattivo di Fr33thy.",
      ),
      "service_diagtrack_off": (
        "Esperienze utente connesse e telemetria disattivate",
        "Disabilita le esperienze utente connesse e la telemetria e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_pimindexmaintenancesvc_off": (
        "Dati contatto disattivati",
        "Disabilita i dati di contatto e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_devquerybroker_off": (
        "Broker di rilevamento in background DevQuery disattivato",
        "Disabilita DevQuery Background Discovery Broker e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_diagsvc_off": (
        "Servizio di esecuzione diagnostica disattivato",
        "Disabilita il servizio di esecuzione diagnostica e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_trkwks_off": (
        "Client di monitoraggio dei collegamenti distribuiti disattivato",
        "Disabilita il client di monitoraggio dei collegamenti distribuiti e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_mapsbroker_off": (
        "Gestione mappe scaricate disattivato",
        "Disabilita Gestione mappe scaricate e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_efs_off": (
        "Crittografia file system disattivata",
        "Disabilita la crittografia del file system e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_inventorysvc_off": (
        "Valutazione inventario e compatibilità disattivata",
        "Disabilita la valutazione dell'inventario e della compatibilità e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_wpcmonsvc_off": (
        "Controllo genitori disattivato",
        "Disabilita il controllo genitori e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_semgrsvc_off": (
        "Pagamenti e Gestione NFC/SE disattivati",
        "Disabilita i pagamenti e NFC/SE Manager e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "toggle_printing_off": (
        "Stampa disattivata",
        "Disabilita il servizio Spooler di stampa finché non viene ripristinato.",
      ),
      "service_pcasvc_off": (
        "Servizio Risoluzione problemi compatibilità programmi disattivato",
        "Disabilita il servizio Risoluzione problemi compatibilità programmi e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_troubleshootingsvc_off": (
        "Servizio di risoluzione dei problemi consigliato disattivato",
        "Disabilita il servizio di risoluzione dei problemi consigliato e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_remoteregistry_off": (
        "Registro remoto disattivato",
        "Disabilita il registro remoto e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_retaildemo_off": (
        "Servizio demo al dettaglio disattivato",
        "Disabilita il servizio demo al dettaglio e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_remoteaccess_off": (
        "Routing e accesso remoto disattivati",
        "Disabilita Routing e Accesso remoto e ripristina esattamente lo stato di avvio precedente quando ripristinato.",
      ),
      "service_shpamsvc_off": (
        "Gestione account PC condiviso disattivato",
        "Disabilita Gestione account PC condiviso e ripristina l'esatto stato di avvio precedente una volta ripristinato.",
      ),
      "service_scdeviceenum_off": (
        "Enumerazione dei dispositivi smart card disattivata",
        "Disabilita l'enumerazione dei dispositivi smart card e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_scardsvr_off": (
        "Smart card disattivata",
        "Disabilita la Smart Card e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_svsvc_off": (
        "Verificatore spot disattivato",
        "Disabilita Spot Verifier e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_lmhosts_off": (
        "Supporto NetBIOS TCP/IP disattivato",
        "Disabilita l'helper NetBIOS TCP/IP e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_messagingservice_off": (
        "Messaggi di testo disattivati",
        "Disabilita i messaggi di testo e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_dmwappushservice_off": (
        "Servizio di routing dei messaggi push WAP disattivato",
        "Disabilita il servizio di routing dei messaggi push WAP e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_wersvc_off": (
        "Servizio di segnalazione errori di Windows disattivato",
        "Disabilita il servizio Segnalazione errori di Windows e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_wecsvc_off": (
        "Raccolta eventi di Windows disattivata",
        "Disabilita Raccolta eventi di Windows e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_wisvc_off": (
        "Servizio Windows Insider disattivato",
        "Disabilita il servizio Windows Insider e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_wmpnetworksvc_off": (
        "Condivisione in rete di Windows Media Player disattivata",
        "Disabilita la condivisione di rete di Windows Media Player e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_wpnservice_off": (
        "Servizio di sistema Notifiche push di Windows disattivato",
        "Disabilita il servizio di sistema delle notifiche push di Windows e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_xblauthmanager_off": (
        "Gestione autenticazione Xbox Live disattivata",
        "Disabilita Gestione autenticazione Xbox Live e ripristina l'esatto stato di avvio precedente una volta ripristinato.",
      ),
      "service_xblgamesave_off": (
        "Salvataggio del gioco Xbox Live disattivato",
        "Disabilita il salvataggio del gioco Xbox Live e ripristina l'esatto stato di avvio precedente quando ripristinato.",
      ),
      "service_xboxnetapisvc_off": (
        "Servizio di rete Xbox Live disattivato",
        "Disabilita il servizio di rete Xbox Live e ripristina l'esatto stato di avvio precedente una volta ripristinato.",
      ),
      "refresh_account_local": (
        "Conto locale",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "refresh_autounattend": (
        "Assenza automatica",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "refresh_factory_reset": (
        "Ripristino delle impostazioni di fabbrica",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "refresh_network_driver": (
        "Driver di rete",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "refresh_reinstall": (
        "Reinstallare",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "restore_clipchamp_clipchamp": (
        "Ripristina Clipchamp",
        "Installa Clipchamp dalle origini dei pacchetti Windows configurati.",
      ),
      "restore_microsoft_windowsalarms": (
        "Ripristina orologio",
        "Installa Orologio dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_devhome": (
        "Ripristina la home page dello sviluppatore",
        "Installa Dev Home dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_windowsfeedbackhub": (
        "Ripristina l'hub di feedback",
        "Installa Hub di Feedback dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_family": (
        "Ripristina la famiglia Microsoft",
        "Installa Microsoft Family dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_windowsstore": (
        "Ripristina Microsoft Store",
        "Installa Microsoft Store dalle origini dei pacchetti Windows configurate.",
      ),
      "restore_microsoft_todos": (
        "Ripristina Microsoft To Do",
        "Installa Microsoft To Do dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_microsoftofficehub": (
        "Ripristina l'hub di Office",
        "Installa Office Hub dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_onedrive": (
        "Ripristina OneDrive",
        "Installa OneDrive dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_outlookforwindows": (
        "Ripristina Outlook (nuovo)",
        "Installa Outlook (nuovo) dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_yourphone": (
        "Ripristina collegamento telefonico",
        "Installa Collegamento telefonico dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_powerautomatedesktop": (
        "Ripristina Power Automate",
        "Installa Power Automate dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_quickassist": (
        "Ripristina l'assistenza rapida",
        "Installa Quick Assist dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_stickynotes": (
        "Ripristina le note adesive",
        "Installa Sticky Notes dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_gamingapp": (
        "Ripristina l'app Xbox",
        "Installa l'app Xbox dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_xboxgamingoverlay": (
        "Ripristina la barra di gioco Xbox",
        "Installa Xbox Game Bar dalle origini del pacchetto Windows configurate.",
      ),
      "restore_microsoft_xboxidentityprovider": (
        "Ripristina il provider di identità Xbox",
        "Installa Xbox Identity Provider dalle origini del pacchetto Windows configurate.",
      ),
      "refresh_to_bios": ("Al BIOS", "Sceneggiatura interattiva di Fr33thy."),
      "refresh_updates_drivers_block": (
        "Aggiorna il blocco dei driver",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_activation_script": (
        "Attivazione (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_background_apps_script": (
        "App in background (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_bitlocker": ("BitLocker", "Sceneggiatura interattiva di Fr33thy."),
      "setup_convert_home_to_pro": (
        "Converti Home in Pro",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_date_language_region_time": (
        "Data Lingua Regione Ora",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_edge_settings_script": (
        "Impostazioni dei bordi (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_keys": ("Chiavi", "Sceneggiatura interattiva di Fr33thy."),
      "setup_memory_compression_script": (
        "Compressione della memoria (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_startup_apps_7": (
        "App di avvio (7)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_startup_apps_8": (
        "App di avvio (8)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_store_settings_script": (
        "Impostazioni del negozio (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "setup_updates_pause": (
        "Pausa aggiornamenti",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "bcd_optimizations": (
        "Ottimizzazioni di avvio avanzate",
        "Ottimizza BCD e percorso di avvio per ridurre il sovraccarico.",
      ),
      "services_disable": (
        "Servizi di diagnostica",
        "Limita l'attività del servizio di diagnostica per un profilo snello.",
      ),
      "tool_amdvbflash_download": (
        "Scarica AMDVBFlash",
        "Apre i download di TechPowerUp AMDVBFlash. ZapTweaks non seleziona mai una ROM né esegue comandi flash.",
      ),
      "advanced_core_1_thread_1": (
        "Nucleo 1 Discussione 1",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_dep_script": (
        "Prevenzione esecuzione dati (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_defender": (
        "Difensore",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_driver_whql_secure_boot_bypass": (
        "Bypass di avvio sicuro del driver WHQL",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_file_download_security_warning": (
        "Avviso di sicurezza per il download del file",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_firewall_script": (
        "Firewall (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_hardware_composed_flip_script": (
        "Flip indipendente composto da hardware (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_hardware_legacy_flip_script": (
        "Flip legacy hardware (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_keyboard_shortcuts": (
        "Scorciatoie da tastiera",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_mmagent_features_script": (
        "Funzionalità di MMAgent (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_mpo_script": (
        "MPO (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_nvidia_nvflash_download": (
        "Scarica NVIDIA NV Flash",
        "Apre i download di TechPowerUp NVFlash. ZapTweaks non seleziona mai una ROM né esegue comandi flash.",
      ),
      "advanced_priority": (
        "Priorità",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_rebar_force": (
        "Forza dell'armatura",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_scewin_gui_releases": (
        "Rilasci SCEWIN-GUI",
        "Apre le versioni SCEWIN-GUI con licenza MIT. Modifica i file NVRAM SCEWIN/AMISCE; non include SCEWIN stesso.",
      ),
      "advanced_smt_ht": ("SMTHT", "Sceneggiatura interattiva di Fr33thy."),
      "advanced_services": ("Servizi", "Sceneggiatura interattiva di Fr33thy."),
      "advanced_spectre_meltdown_script": (
        "Spettro Meltdown (variante della sceneggiatura)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_start_search_shell_mobsync": (
        "Avvia la ricerca Shell Mobsync",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "advanced_ulps_script": (
        "ULPS (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "toggle_activity_history_off": (
        "Cronologia attività disattivata",
        "Impedisce a Windows di pubblicare e caricare la cronologia delle attività.",
      ),
      "privacy_consumer_content": (
        "Contenuti per i consumatori e suggerimenti di app automatiche",
        "Disabilita i consigli di avvio, i suggerimenti sui contenuti per i consumatori e i push silenziosi delle app preinstallate.",
      ),
      "privacy_copilot": (
        "Disabilita copilota",
        "Disabilita i criteri Copilot e rimuove la registrazione corrente del pacchetto dell'app Copilot.",
      ),
      "telemetry_disable": (
        "Disabilita telemetria",
        "Disabilitare i canali di telemetria e diagnostica.",
      ),
      "privacy_gamebar": (
        "Barra di gioco e sovrapposizione di acquisizione",
        "Disabilita l'acquisizione della barra di gioco e la sovrapposizione dei valori dei criteri correlati.",
      ),
      "toggle_location_off": (
        "Posizione disattivata",
        "Disabilita i servizi di localizzazione di Windows tramite criteri.",
      ),
      "privacy_online_search_suggestions": (
        "Suggerimenti per la ricerca online disattivati",
        "Disabilita i suggerimenti basati sul Web nella ricerca di Windows senza disabilitare la ricerca locale.",
      ),
      "privacy_powershell_telemetry": (
        "Telemetria di PowerShell 7 disattivata",
        "Esclude i nuovi processi di PowerShell 7 dalla telemetria dell'applicazione. È necessario un riavvio.",
      ),
      "privacy_tracking": (
        "Privacy e tracciamento",
        "Riduci il monitoraggio degli annunci e i segnali di attività in background.",
      ),
      "privacy_widgets": (
        "Widget e feed di notizie",
        "Disabilita i flag dei criteri dei widget e interrompe l'esecuzione dei processi dei widget.",
      ),
      "privacy_safe_debloat": (
        "Preimpostazione di debloat sicura",
        "Rimuove solo le app di rigonfiamento UWP selezionate preservando i componenti di base di Store e Xbox.",
      ),
      "tool_winsux_debloat": (
        "WinSux di Fr33hty",
        "Esegue il comando remoto di debloat WinSux di Fr33hty. Azione invasiva senza ripristino in-app.",
      ),
      "ui_background_apps_off": (
        "App in background disattivate",
        "Blocca l'esecuzione dell'app in background tramite la policy AppPrivacy.",
      ),
      "toggle_center_taskbar_icons": (
        "Icone centrali della barra delle applicazioni",
        "Utilizza l'allineamento dell'icona centrata sulla barra delle applicazioni di Windows 11.",
      ),
      "ui_context_menu_clean": (
        "Menu contestuale Pulito",
        "Abilita il menu contestuale classico e rimuove le voci selezionate della shell.",
      ),
      "visual_effects": (
        "Disabilita effetti visivi",
        "Ridurre l'animazione e il sovraccarico visivo.",
      ),
      "explorer_optimizations": (
        "Ottimizzazioni di Explorer",
        "Ottimizza il comportamento e la memorizzazione nella cache di Esplora file.",
      ),
      "ui_folder_discovery_off": (
        "Rilevamento tipo cartella disattivato",
        "Impedisce a Explorer di rilevare automaticamente i modelli di cartelle, il che può velocizzare le cartelle multimediali di grandi dimensioni.",
      ),
      "ui_hide_explorer_gallery": (
        "Nascondi la Galleria Esplora file",
        "Nasconde l'elemento di navigazione della Galleria da Esplora file.",
      ),
      "notifications_minimal": (
        "Notifiche minime",
        "Riduci le interruzioni dei toast e della schermata di blocco.",
      ),
      "ui_pointer_precision_off": (
        "Precisione del puntatore disattivata",
        "Disabilita la precisione del puntatore e imposta le soglie del mouse in stile 6/11.",
      ),
      "ui_start_taskbar_clean": (
        "Menu Start e barra delle applicazioni Puliti",
        "Nasconde widget/ricerca/visualizzazione attività/chat e applica l'allineamento a sinistra + preferenze di visualizzazione elenco.",
      ),
      "ui_sticky_keys_shortcut_off": (
        "Scorciatoia tasti permanenti disattivata",
        "Impedisce alla scorciatoia Maiusc cinque volte di aprire i tasti permanenti.",
      ),
      "ui_taskbar_end_task": (
        "Termina attività sulla barra delle applicazioni",
        "Aggiunge l'attività Termina ai menu contestuali dell'app sulla barra delle applicazioni nelle build di Windows 11 supportate.",
      ),
      "ui_dark_theme": (
        "Tema Nero",
        "Applica un profilo dell'interfaccia utente Windows scuro e disabilita gli effetti di trasparenza.",
      ),
      "ui_optimizations": (
        "Ottimizzazioni dell'interfaccia utente",
        "Applica le impostazioni della barra delle applicazioni e della pulizia della shell.",
      ),
      "hardware_background_polling_rate_cap": (
        "Limite della velocità di polling in background",
        "Spento = polling in background sbloccato. Ripristina ripristina il comportamento predefinito.",
      ),
      "tool_autoruns_folder": (
        "Esecuzioni automatiche",
        "Suite di analisi di avvio e attività pianificate.",
      ),
      "hardware_background_polling_rate_cap_script": (
        "Limite velocità polling in background (variante dello script)",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_fix_tools_battery_report": (
        "Rapporto sulla batteria",
        "Correggi lo script diagnostico degli strumenti.",
      ),
      "tool_beyond_performance_device_tweaker_discord": (
        "Oltre le prestazioni del dispositivo Tweaker",
        "Apre il canale pubblico Beyond Performance Discord che distribuisce Device Tweaker.",
      ),
      "tool_cpuz_folder": (
        "CPU-Z",
        "Utilità per le informazioni sulla CPU e sulla memoria.",
      ),
      "tool_cru_folder": (
        "CRU",
        "Utilità di risoluzione personalizzata per le modalità di visualizzazione.",
      ),
      "installers_cru_sre": (
        "Programma di installazione dello script CRU SRE",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_fix_tools_change_name": (
        "Cambia nome",
        "Correzione dello script di supporto degli strumenti.",
      ),
      "tool_cleanmgrplus_folder": (
        "Cleanmgr+",
        "Utilità di pulizia estesa del disco e di gestione dei file temporanei.",
      ),
      "hardware_controller_overclock_script": (
        "Overclock del controller",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "hardware_controller_polling_rate_script": (
        "Test della velocità di polling del controller",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_device_cleanup_folder": (
        "Pulizia del dispositivo",
        "Pulisce le voci del dispositivo fantasma/non presente da Windows.",
      ),
      "tool_dismpp_folder": (
        "Dism++",
        "Kit di strumenti avanzati per operazioni di manutenzione e DISM.",
      ),
      "tool_winslopr_releases": (
        "Scarica Winslopr",
        "Apre la pagina ufficiale delle versioni di Winslopr su GitHub nel browser.",
      ),
      "tool_driver_store_explorer_folder": (
        "Esploratore archivio driver (RAPR)",
        "Ispeziona e elimina i pacchetti driver vecchi/inutilizzati.",
      ),
      "tool_fix_tools_fastclean": (
        "FastClean",
        "Correggi lo script di pulizia degli strumenti.",
      ),
      "tool_fix_tools_runner": (
        "Correggi il programma di avvio degli strumenti",
        "Esegue il menu di avvio batch Strumenti di correzione.",
      ),
      "tool_fortnite_diagnostic_ping": (
        "Strumento ping diagnostico Fortnite di Alexanderthedad",
        "Esegue il comando diagnostico remoto ufficiale per la risoluzione dei problemi del ping di Fortnite.",
      ),
      "tool_furmark_setup": (
        "Programma di installazione di FurMark",
        "Pacchetto di installazione per test di stress della GPU.",
      ),
      "tool_gpu_dword_manager": (
        "Gestore DWORD GPU",
        "Utilità di ottimizzazione DWORD del registro GPU.",
      ),
      "tool_gpuz": ("GPU-Z", "Diagnostica e sensori GPU dettagliati."),
      "tool_gaming_net_diagnostic": (
        "Diagnostica della rete di gioco",
        "Script di diagnostica di rete rapida per sessioni di gioco.",
      ),
      "tool_hwinfo_folder": (
        "HWiNFO",
        "Sensori di sistema e suite di telemetria hardware.",
      ),
      "tool_import_disable_advanced_services_profile": (
        "Importa Disabilita profilo servizi avanzati",
        "Importa il profilo di disabilitazione definitiva dei servizi avanzati dal file .reg in bundle di Sapphire.",
      ),
      "tool_import_minimal_services_profile": (
        "Importa il profilo dei servizi minimi",
        "Importa la policy di avvio del servizio minima dal file .reg in bundle di Sapphire.",
      ),
      "tool_sysinternals_suite_winget": (
        "Installa la suite Sysinternals",
        "Installa Microsoft Sysinternals Suite con Winget. La finestra di PowerShell rimane aperta in modo da poter leggere l'output finale del PERCORSO/strumento.",
      ),
      "tool_install_win11_debloat_raphire": (
        "Installa Win11 Debloat",
        "Esegue il comando remoto ufficiale Win11Debloat in una finestra PowerShell con privilegi elevati visibile.",
      ),
      "tool_install_winhance": (
        "Installa Winhance",
        "Installa Winhance con Winget per la personalizzazione comune di Windows e l'ottimizzazione di base.",
      ),
      "installers_menu": (
        "Menù Installatori",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_winget_interactive_uninstaller": (
        "Programma di disinstallazione dell'app interattiva",
        "Elenca le applicazioni Winget installate in un terminale in modo da poterne selezionare una da rimuovere.",
      ),
      "tool_interrupt_affinity_policy": (
        "Strumento di policy di affinità di interruzione",
        "Affinità di interrupt e utilità di ottimizzazione dei criteri IRQ.",
      ),
      "tool_interrupt_affinity_policy_ia64": (
        "Strumento di policy di affinità di interruzione (IA64)",
        "Build IA64 dell'utilità dei criteri di affinità di interruzione.",
      ),
      "tool_interrupt_affinity_policy_x86": (
        "Strumento di policy di affinità di interruzione (x86)",
        "build x86 dell'utilità dei criteri di affinità di interruzione.",
      ),
      "tool_msi_afterburner_setup": (
        "Programma di installazione di MSI Afterburner",
        "Programma di installazione per overclocking e monitoraggio della GPU.",
      ),
      "installers_msi_afterburner": (
        "Programma di installazione dello script MSI Afterburner",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_msi_util_folder": (
        "Utilità MSI v3",
        "Utilità della policy di interruzione segnalata dal messaggio.",
      ),
      "tool_more_clock_tool": (
        "Altro strumento Orologio",
        "Utilità di controllo clock/tensione AMD.",
      ),
      "installers_more_clock_tool": (
        "Altro programma di installazione dello script dello strumento Orologio",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_more_power_tool_setup": (
        "Altroprogramma di installazione di PowerTool",
        "Programma di installazione dell'ottimizzazione del tavolo di alimentazione AMD.",
      ),
      "tool_mouse_flat_curve": (
        "Curva piatta del mouse",
        "Applica le impostazioni della curva di accelerazione piatta del mouse.",
      ),
      "tool_mouse_movement_recorder": (
        "Registratore di movimenti del mouse",
        "Controlla il comportamento efficace del polling del mouse.",
      ),
      "hardware_mouse_polling_rate_test_script": (
        "Test della velocità di polling del mouse",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_nvidia_profile_inspector_nip_profile": (
        "Impostazioni delle prestazioni NVIDIA (.nip)",
        "Profilo incentrato sulle prestazioni. Non utilizzare se si ricerca la qualità visiva.",
      ),
      "tool_nvidia_profile_inspector_folder": (
        "Ispettore profilo NVIDIA",
        "Editor avanzato di profili NVIDIA.",
      ),
      "installers_nvidia_profile_inspector": (
        "Programma di installazione dello script NVIDIA Profile Inspector",
        "Sceneggiatura interattiva di Fr33thy.",
      ),
      "tool_fix_tools_permessi": (
        "Permessi",
        "Correggi lo script di riparazione delle autorizzazioni degli strumenti.",
      ),
      "tool_polling_rate_tester_app": (
        "App per il test della frequenza dei sondaggi",
        "Utilità dedicata di convalida della velocità di polling del mouse.",
      ),
      "tool_controller_polling": (
        "Strumento di sondaggio",
        "Strumento di misurazione della velocità di polling del controller.",
      ),
      "tool_power_settings_explorer": (
        "PowerSettingsExplorer",
        "Editor avanzato delle impostazioni del piano di alimentazione di Windows.",
      ),
      "tool_prime95_folder": (
        "Primo95",
        "Test di stress della CPU e convalida della stabilità.",
      ),
      "tool_queue_size_tuner": (
        "Sintonizzatore delle dimensioni della coda",
        "Utilità di ottimizzazione della coda di archiviazione.",
      ),
      "tool_rammap_folder": (
        "RAMMap",
        "Utilità di analisi della memoria fisica di Microsoft Sysinternals.",
      ),
      "tool_rtl_utility": (
        "Utilità RTL",
        "Utilità e strumento di diagnostica Realtek.",
      ),
      "tool_radeon_tuner_folder": (
        "Sintonizzatore Radeon",
        "Ottimizzazione del driver AMD Radeon e utilità del profilo.",
      ),
      "tool_fix_tools_reset_network": (
        "Reimposta rete",
        "Correggi lo script di reimpostazione della rete degli strumenti.",
      ),
      "tool_fix_tools_ripristina_anteprime": (
        "Ripristina Antiprime",
        "Correggi lo script di riparazione della cache delle miniature degli strumenti.",
      ),
      "tool_ctt_winutil": (
        "Esegui CTT WinUtil",
        "Apre Chris Titus Tech WinUtil per attività comuni di configurazione, riparazione e ottimizzazione di base di Windows.",
      ),
      "tool_fix_tools_sfc_dism": (
        "SFC e DISM",
        "Correggi l'integrità degli strumenti e lo script di riparazione delle immagini.",
      ),
      "tool_star_ethernet_analyzer_folder": (
        "Analizzatore Star Ethernet",
        "Kit di strumenti per la diagnostica Ethernet e jitter.",
      ),
      "tool_star_ethernet_analyzer_start_bat": (
        "Avvio dell'analizzatore Star Ethernet",
        "Esegue il programma di avvio batch in bundle per Star Ethernet Analyser.",
      ),
      "tool_star_ethernet_analyzer_script": (
        "Script dell'analizzatore Star Ethernet",
        "Script di supporto interattivo per Star Ethernet Analyser.",
      ),
      "tool_star_ethernet_analyzer_video": (
        "Guida video all'analizzatore Star Ethernet",
        "Apre la guida video in bundle con l'app Windows predefinita.",
      ),
      "tool_tcp_optimizer_folder": (
        "Ottimizzatore TCP",
        "Strumento di ottimizzazione e diagnostica dello stack di rete.",
      ),
      "tool_testmem5_folder": (
        "ProvaMem5",
        "Utilità per test di stress della RAM.",
      ),
      "tool_usb_latency_analyzer_v2_marius_heier": (
        "Analizzatore di latenza USB V2 di Marius Heier",
        "Esegue lo strumento diagnostico di Marius Heier in una finestra PowerShell con privilegi elevati visibile. Ciò non applica modifiche ed è destinato all'output diagnostico della console.",
      ),
      "tool_unpark_cpu": (
        "Annulla parcheggio CPU",
        "Utilità di unparking del core della CPU.",
      ),
      "tool_vivetool_folder": (
        "ViVeTool",
        "Utilità di gestione dei flag delle funzionalità di Windows.",
      ),
      "tool_winscript_batch": (
        "Utilità batch WinScript",
        "Esegue le azioni batch di manutenzione WinScript in bundle.",
      ),
      "tool_hidusbf_folder": (
        "hidusbf",
        "Toolkit di overclock polling USB per dispositivi HID.",
      ),
    },
    "de": <String, (String, String)>{
      "shortcut_advanced_system_settings": (
        "Erweiterte Systemeinstellungen",
        "Leistung, visuelle Effekte und Umgebungseinstellungen.",
      ),
      "shortcut_bluetooth": (
        "Bluetooth und Geräte",
        "Gekoppelte Geräte, Drucker und Mauseinstellungen.",
      ),
      "shortcut_computer_management": (
        "Computermanagement",
        "Einheitliche Konsole für Systemtools.",
      ),
      "shortcut_device_manager": (
        "Gerätemanager",
        "Öffnet den Geräte-Manager.",
      ),
      "shortcut_directx_diagnostic": (
        "DirectX-Diagnose",
        "GPU, DirectX-Version und Audiodiagnose.",
      ),
      "shortcut_disk_management": (
        "Datenträgerverwaltung",
        "Partitionen, Volumes und Laufwerksbuchstaben.",
      ),
      "shortcut_display": (
        "Anzeige",
        "Auflösung, Skalierung, HDR und Bildwiederholfrequenz.",
      ),
      "shortcut_environment_variables": (
        "Umgebungsvariablen",
        "System- und Benutzerpfad, TEMP und andere Variablen.",
      ),
      "shortcut_event_viewer": (
        "Ereignisanzeige",
        "System- und Anwendungsprotokolle.",
      ),
      "shortcut_game_mode": (
        "Spielmoduseinstellungen",
        "Einstellungen für den Windows-Spielmodus.",
      ),
      "shortcut_graphics_settings": (
        "Grafikeinstellungen",
        "GPU-Präferenz und HAGS pro App.",
      ),
      "shortcut_hosts_file": (
        "Hosts-Datei",
        "Öffnet die Hosts-Datei im Editor.",
      ),
      "shortcut_installed_apps": (
        "Installierte Apps",
        "Deinstallieren und reparieren Sie installierte Anwendungen.",
      ),
      "shortcut_network": (
        "Netzwerk",
        "Ethernet-, WLAN-, VPN- und Proxy-Einstellungen.",
      ),
      "shortcut_optional_features": (
        "Optionale Funktionen",
        "Verwalten Sie optionale Windows-Funktionen.",
      ),
      "shortcut_performance_monitor": (
        "Leistungsmonitor",
        "Live-Zähler und Datensätze.",
      ),
      "shortcut_personalization": (
        "Personalisierung",
        "Hintergrund, Farben und Sperrbildschirmeinstellungen.",
      ),
      "shortcut_power_battery": (
        "Strom und Batterie",
        "Ruhezustand, Bildschirm-Timeout und Akkueinstellungen.",
      ),
      "shortcut_privacy_security": (
        "Privatsphäre und Sicherheit",
        "Datenschutzberechtigungen und Windows-Sicherheit.",
      ),
      "shortcut_registry_editor": (
        "Registrierungseditor",
        "Direkter Registrierungszugriff.",
      ),
      "shortcut_reliability_history": (
        "Zuverlässigkeitsgeschichte",
        "Abstürze, Ausfälle und Stabilitätsverlauf.",
      ),
      "shortcut_resource_monitor": (
        "Ressourcenmonitor",
        "CPU-, Speicher-, Festplatten- und Netzwerkaktivität.",
      ),
      "shortcut_services": (
        "Dienstleistungen",
        "Windows-Dienste starten, stoppen und konfigurieren.",
      ),
      "shortcut_sound": (
        "Ton",
        "Ausgabe-, Eingabe- und Lautstärkeeinstellungen.",
      ),
      "shortcut_startup_folder": (
        "Startordner",
        "Startanwendungen pro Benutzer.",
      ),
      "shortcut_system_configuration": (
        "Systemkonfiguration",
        "Boot-Optionen und Startdienste.",
      ),
      "shortcut_task_scheduler": (
        "Aufgabenplaner",
        "Geplante Aufgaben und Auslöser.",
      ),
      "shortcut_windows_features": (
        "Windows-Funktionen",
        "Schalten Sie Windows-Funktionen ein oder aus.",
      ),
      "shortcut_windows_update": (
        "Windows-Update",
        "Suchen Sie nach Updates und installieren Sie diese.",
      ),
      "gaming_amd_gpu_extreme_profile": (
        "AMD GPU Extreme Profile",
        "Deaktiviert AMD Thermal Throttling, Crash Defender, Power Gating, Clock Gating, ULPS, ASPM und anderes Energiesparverhalten. Nur Desktop-Fehlerbehebung.",
      ),
      "gaming_amd_gpu_safe_profile": (
        "AMD GPU-sicheres Profil",
        "Wendet ein umkehrbares AMD-Treiberprofil an, ohne den Wärmeschutz, Crash Defender, Clock Gating oder Power Gating zu deaktivieren.",
      ),
      "gpu_amd_optimizations": (
        "AMD GPU ULPS-Fehlerbehebung",
        "Deaktiviert AMD ULPS zur Fehlerbehebung; Der thermische Schutz oder das Power-Gating werden dadurch nicht deaktiviert.",
      ),
      "cpu_amd_optimizations": (
        "AMD Ryzen-Optimierungen",
        "Wenden Sie AMD-spezifische Leistungs- und Latenzoptimierung an.",
      ),
      "gaming_amd_ulps_off": (
        "AMD ULPS Aus",
        "Deaktiviert EnableUlps für AMD-Anzeigeklassenschlüssel. Nützlich für Latenztests.",
      ),
      "cpu_unparking": (
        "Entparken des CPU-Kerns",
        "Entparken Sie alle CPU-Kerne für Workloads mit geringer Latenz.",
      ),
      "cpu_power_management": (
        "CPU-Energieverwaltung",
        "Deaktivieren Sie die Drosselung und optimieren Sie das Planerverhalten.",
      ),
      "gaming_mpo_off": (
        "Multiplane Overlay (MPO) deaktivieren",
        "Problemumgehung nur zur Fehlerbehebung bei Displayflimmern oder Stottern; Neustart erforderlich.",
      ),
      "gaming_extended_gpu_timeout": (
        "Erweitertes GPU-Timeout",
        "Legt eine 10-sekündige GPU-Timeout-Erkennungsverzögerung zur Fehlerbehebung bei instabilen, hohen GPU-Workloads fest.",
      ),
      "gaming_legacy_flip_fse": (
        "Exklusiver Legacy Flip im Vollbildmodus",
        "Schaltet GameConfigStore auf FSE-orientiertes Verhalten für ältere Vollbildtests um.",
      ),
      "game_mode": (
        "Spielmodus Ein",
        "Aktiviert den Windows-Spielemodus, ohne die Xbox Game Bar oder den Game DVR zu ändern.",
      ),
      "gaming_composed_flip_immediate_mode": (
        "Hardware komponierter unabhängiger Flip",
        "Erzwingt ForceFlipTrueImmediateMode=1 im Grafikplaner.",
      ),
      "cpu_intel_optimizations": (
        "Intel CPU-Optimierungen",
        "Optimieren Sie das Intel P- und E-Core-Planungsprofil.",
      ),
      "gpu_intel_optimizations": (
        "Intel GPU-Optimierungen",
        "Wenden Sie die Leistungsoptimierung des Intel-Grafikstapels an.",
      ),
      "gpu_nvidia_optimizations": (
        "NVIDIA-Optimierungen",
        "Wenden Sie NVIDIA-Grafikplanung und Latenzoptimierungen an.",
      ),
      "gaming_windowed_optimizations_on": (
        "Optimierungen für Fensterspiele aktiviert",
        "Ermöglicht das Windows 11-Swap-Effekt-Upgrade für kompatible Fenster- und randlose Spiele.",
      ),
      "ram_optimizations": (
        "RAM-Optimierungen",
        "Optimieren Sie das Speichermanager- und Cache-Verhalten.",
      ),
      "storage_optimizations": (
        "Speicheroptimierungen",
        "Optimieren Sie NTFS, TRIM und das Energieverhalten des Speichers.",
      ),
      "timer_latency": (
        "Timer und Latenz",
        "Optimieren Sie das MMCSS- und Timer-Anforderungsverhalten.",
      ),
      "gaming_variable_refresh_rate_on": (
        "Variable Bildwiederholfrequenz aktiviert",
        "Aktiviert die variable Aktualisierungsrate von Windows für kompatible Spiele.",
      ),
      "network_adapter_power_savings_wake_off": (
        "Energieeinsparung und Wake-Off durch den Adapter",
        "Deaktiviert die Energiespar- und Aktivierungsfunktionen auf physischen Netzwerkadaptern mit einer genauen Sicherung zum Wiederherstellen.",
      ),
      "network_delivery_optimization_off": (
        "Lieferoptimierung P2P aus",
        "Stoppt Peer-to-Peer-Uploads und -Downloads von Windows Update.",
      ),
      "device_power_savings_off": (
        "Energiesparmodus des Geräts ausgeschaltet",
        "Deaktiviert den Energiesparmodus für WMI-Geräte. Dies erhöht den Stromverbrauch im Leerlauf und ist für Desktops gedacht.",
      ),
      "network_ecn_disabled": (
        "ECN deaktivieren",
        "Deaktiviert die explizite Überlastungsbenachrichtigung, um vorhersehbares Verhalten mit geringer Latenz zu fördern.",
      ),
      "network_timestamps_disabled": (
        "Deaktivieren Sie TCP-Zeitstempel",
        "Deaktiviert TCP-Zeitstempel, um den Protokoll-Overhead in latenzorientierten Szenarien zu reduzieren.",
      ),
      "network_rss_enabled": (
        "RSS aktivieren",
        "Ermöglicht die Empfangsseitige Skalierung, um die Paketverarbeitung auf die CPU-Kerne zu verteilen.",
      ),
      "network_fast_udp_datagram_send": (
        "Schneller UDP-Datagrammversand",
        "Erhöht den AFD-Datagramm-Sendeschwellenwert für UDP-Workloads.",
      ),
      "network_ipv4_only": (
        "Nur IPv4-Bindungen",
        "Deaktiviert nicht unbedingt erforderliche Adapterbindungen und hält IPv4 auf allen Adaptern aktiviert.",
      ),
      "network_llmnr_off": (
        "LLMNR Aus",
        "Deaktiviert die alte lokale Multicast-Namensauflösung.",
      ),
      "network_low_latency_bandwidth_profile": (
        "Netzwerkprofil mit geringer Latenz",
        "Wendet ein aggressives Netzwerkprofil mit geringer Latenz an, das den Durchsatz und die Gesamtbandbreiteneffizienz verringern kann.",
      ),
      "network_mmagent_features_off": (
        "MMAgent-Funktionen deaktiviert",
        "Deaktiviert die Prefetch-/Prelaunch-/OperationAPI-Funktionen von MMAgent und setzt Prefetcher auf 0.",
      ),
      "network_optimizations": (
        "Netzwerkoptimierungen",
        "Optimieren Sie das TCP-Profil und entfernen Sie die Multimedia-Drosselung.",
      ),
      "network_throttling_index_off": (
        "Netzwerkdrosselungsindex deaktiviert",
        "Setzt NetworkThrottlingIndex auf 0xFFFFFFFF, um Multimedia-Drosselungsbeschränkungen zu entfernen.",
      ),
      "network_prefer_ipv4": (
        "Bevorzugen Sie IPv4 gegenüber IPv6",
        "Behält IPv6 aktiviert, gibt IPv4 jedoch Vorrang. Kann nicht mit reinen IPv4-Bindungen kombiniert werden.",
      ),
      "network_itr_interactive_config": (
        "NIC ITR Interactive Config",
        "Öffnet ein erweitertes interaktives Tool zum Konfigurieren der NIC Interrupt Throttle Rate (ITR) für unterstützte Realtek/Intel/Killer-Adapter.",
      ),
      "power_amd_preferred_cores": (
        "AMD bevorzugte Kerne",
        "Aktiviert AMD Precision Boost – ermöglicht der CPU, die stärksten Kerne für Single-Thread-Workloads zu priorisieren. Nur AMD-CPUs.",
      ),
      "power_cpu_core_parking_off": (
        "CPU-Kern-Parken ausgeschaltet",
        "Blendet die Mindest-/Höchstanzahl der Kernparkplätze im aktiven Plan ein und setzt sie auf 100 %.",
      ),
      "power_disable_cstates": (
        "Deaktivieren Sie die CPU-C-States",
        "Begrenzt den Ruhezustand der CPU für maximale Reaktionsfähigkeit und sofortigen Boost. Nur Desktop – erhöht die Temperatur und den Stromverbrauch im Leerlauf erheblich.",
      ),
      "power_cpu_idle_demote_promote": (
        "Deaktivieren Sie die Herabstufung/Heraufstufung im CPU-Leerlauf",
        "Legt die Schwellenwerte für die Herabstufung/Heraufstufung des Leerlaufs auf 100 % fest, um die Zeit zu reduzieren, die die CPU damit verbringt, in den Leerlaufzustand zu gelangen bzw. diesen zu verlassen. Geringere Latenz bei höheren Stromkosten.",
      ),
      "power_disable_dynamic_tick": (
        "Deaktivieren Sie das dynamische Häkchen",
        "Führt bcdedit /setdisabledynamictick aus. Ja – macht den System-Timer konsistenter, reduziert Mikroruckeln in Spielen und Apps mit geringer Latenz. Unter Windows 11 im Jahr 2026 immer noch wirksam.",
      ),
      "power_fast_startup_hibernate_off": (
        "Schnelles Starten und Ausschalten des Ruhezustands",
        "Deaktiviert den Ruhezustand und den Schnellstart für eine geringere Latenz und ein saubereres Verhalten beim Herunterfahren.",
      ),
      "power_global_timer_resolution": (
        "Globale Timer-Auflösungsanfragen",
        "Setzt GlobalTimerResolutionRequests=1 – stellt das systemweite hochauflösende Timer-Verhalten unter Windows 11 wieder her. Unverzichtbar für Apps/Spiele, die auf eine Timer-Präzision von 1 ms oder 0,5 ms angewiesen sind.",
      ),
      "power_hardware_pstates_intel": (
        "Intel Hardware P-States (HWP)",
        "Konfiguriert Intel Speed Shift/Hardware P-States für maximale Leistungsorientierung. Nur Intel-CPUs.",
      ),
      "power_max_processor_state": (
        "Maximaler Prozessorstatus (100 %)",
        "Setzt die maximale CPU-Frequenz auf 100 %, um ein aggressives Heruntertakten unter Last zu verhindern.",
      ),
      "power_throttling_off": (
        "Leistungsdrosselung aus",
        "Deaktiviert die Windows-Energiedrosselung für eine konsistentere CPU-Planung unter Last.",
      ),
      "power_processor_boost_mode": (
        "Prozessorleistungs-Boost-Modus",
        "Aktiviert den aggressiven CPU-Boost-Modus (Intel/AMD). Verbessert die anhaltenden Boost-Takte bei Multi-Thread-Workloads. Empfohlen für gut gekühlte Desktops.",
      ),
      "power_processor_time_check_interval": (
        "Prozessorzeit-Überprüfungsintervall (5 ms)",
        "Reduziert das Überprüfungsintervall des CPU-Schedulers von 15 ms auf 5 ms für eine schnellere Reaktion bei der Frequenzskalierung.",
      ),
      "power_system_responsiveness_registry": (
        "Systemreaktionsfähigkeit (10)",
        "Setzt SystemResponsiveness auf 10 (vom Standardwert 20) – gibt mehr CPU-Zeit, um Apps über Systemdienste in den Vordergrund zu stellen. Verbessert das Spiel- und Multitasking-Gefühl.",
      ),
      "power_tsc_sync_policy": (
        "TSC-Synchronisierungsrichtlinie (erweitert)",
        "Setzt tscsyncpolicy auf „Erweitert“ – verbessert die CPU-Kern-Timer-Synchronisierung auf Multi-Core-Systemen. Geringes Risiko, besonders nützlich bei älteren Systemen mit mehreren Steckdosen.",
      ),
      "power_ultimate_performance_plan": (
        "Ultimativer Leistungsplan",
        "Importiert und aktiviert Ultimate Performance. Setzen Sie die Schalter wieder auf „Balanced“.",
      ),
      "power_win32_priority_separation": (
        "Win32-Prioritätstrennung (Gaming)",
        "Setzt Win32PrioritySeparation auf 26 (hex 0x1a) – priorisiert die CPU-Zeit der Vordergrund-App. Klassische Gaming-Optimierung für geringere Eingabelatenz.",
      ),
      "graphics_amd_settings": (
        "AMD-Einstellungen",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_cpp_runtime": (
        "C++-Laufzeit",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_directx": (
        "DirectX-Laufzeit",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_driver_clean": (
        "Treiber sauber",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_driver_install_debloat_settings": (
        "Treiberinstallation, Debloat und Einstellungen",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_driver_install_latest": (
        "Neueste Treiberinstallation",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_hags_windowed": (
        "HAGS mit Fenster",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_hdcp": ("HDCP", "Interaktives Skript von Fr33thy."),
      "graphics_intel_settings": (
        "Intel-Einstellungen",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_msi_mode_script": (
        "MSI-Modus (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_nvidia_settings": (
        "NVIDIA-Einstellungen",
        "Interaktives Skript von Fr33thy.",
      ),
      "graphics_p0_state": ("P0-Zustand", "Interaktives Skript von Fr33thy."),
      "graphics_resolution_refresh_rate": (
        "Auflösungsaktualisierungsrate",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_auto_reboot_after_bsod_off": (
        "Automatischer Neustart nach BSOD-Aus",
        "Behält einen Stoppcode auf dem Bildschirm, anstatt nach einem Absturz automatisch neu zu starten.",
      ),
      "toggle_automatic_driver_updates_off": (
        "Automatische Treiberaktualisierungen deaktiviert",
        "Verhindert, dass Windows Update automatisch Treiberupdates installiert.",
      ),
      "windows_automatic_maintenance_off": (
        "Automatische Wartung aus",
        "Deaktiviert die geplante automatische Wartung, während die manuellen Wartungstools erhalten bleiben.",
      ),
      "windows_ntfs_last_access_updates_off": (
        "NTFS-Updates für den letzten Zugriff deaktiviert",
        "Verhindert, dass NTFS jedes Mal einen Zeitstempel aktualisiert, wenn eine Datei gelesen wird.",
      ),
      "toggle_scheduled_defrag_off": (
        "Geplante Defragmentierung/TRIM aus",
        "Deaktiviert die geplante Aufgabe „Laufwerke optimieren“; Die manuelle Optimierung bleibt weiterhin verfügbar.",
      ),
      "toggle_storage_sense_off": (
        "Speichererkennung aus",
        "Deaktiviert die automatische Bereinigung temporärer Dateien.",
      ),
      "system_responsiveness": (
        "Systemreaktionsfähigkeit",
        "Reduzieren Sie UI-Verzögerungen und Task-Timeout-Werte.",
      ),
      "windows_update": (
        "Windows Update-Verhalten",
        "Passen Sie das Aktualisierungsverhalten für spielorientierte Arbeitsabläufe an.",
      ),
      "windows_autoruns_startup_tasks_apps_check": (
        "Startup-Aufgaben und Apps-Prüfung werden automatisch ausgeführt",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_bloatware_script": (
        "Bloatware (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_bloatware_legacy_apps_check_script": (
        "Überprüfung älterer Bloatware-Apps (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_bloatware_legacy_features_check_script": (
        "Überprüfung der Bloatware-Legacy-Funktionen (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_bloatware_taskmgr_check_script": (
        "Bloatware TaskMgr Check (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_bloatware_uwp_apps_check_script": (
        "Überprüfung von Bloatware-UWP-Apps (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_bloatware_uwp_features_check_script": (
        "Überprüfung der Bloatware-UWP-Funktionen (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_cleanup": ("Aufräumen", "Interaktives Skript von Fr33thy."),
      "windows_context_menu_script": (
        "Kontextmenü (Script-Variante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_control_panel_settings_script": (
        "Systemsteuerungseinstellungen (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_copilot_script": (
        "Copilot (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_core_isolation_script": (
        "Kernisolation (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_defender_optimize": (
        "Defender optimieren",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_device_manager_power_savings_wake": (
        "Gerätemanager Energiesparen und Aufwecken",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_edge_webview_script": (
        "Edge & WebView (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_gamebar_script": (
        "Gamebar (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_gamemode": ("Spielmodus", "Interaktives Skript von Fr33thy."),
      "windows_loudness_eq": (
        "Lautstärke-EQ",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_nvme_faster_driver": (
        "NVME-Schneller-Treiber",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_network_adapter_power_savings_script": (
        "Energieeinsparung und Aktivierung des Netzwerkadapters (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_network_ipv4_only_script": (
        "Nur Netzwerk IPv4 (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_notepad_settings": (
        "Notepad-Einstellungen",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_pointer_precision_script": (
        "Zeigergenauigkeit (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_power_plan_script": (
        "Energieplan (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_restore_point": (
        "Wiederherstellungspunkt",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_scaling": ("Skalierung", "Interaktives Skript von Fr33thy."),
      "windows_signout_lockscreen_wallpaper_black": (
        "Abmelden Lockscreen Wallpaper Schwarz",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_sound": ("Ton", "Interaktives Skript von Fr33thy."),
      "windows_start_menu_layout_script": (
        "Startmenü-Layout (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_start_menu_shortcuts_script": (
        "Startmenü-Verknüpfungen (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_start_menu_taskbar_script": (
        "Startmenü-Taskleiste (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_theme_black_script": (
        "Thema Schwarz (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_timer_resolution_script": (
        "Timer-Auflösung (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_uac_script": (
        "UAC (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_user_account_pictures_black": (
        "Benutzerkontobilder schwarz",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_widgets_script": (
        "Widgets (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "windows_write_cache_buffer_flushing": (
        "Leeren des Schreib-Cache-Puffers",
        "Interaktives Skript von Fr33thy.",
      ),
      "checks_core_isolation_off": (
        "Kernisolationsspeicherintegrität aus",
        "Deaktiviert die HVCI-Speicherintegrität über das DeviceGuard-Registrierungsszenario.",
      ),
      "checks_dep_off": (
        "Datenausführungsverhinderung deaktiviert",
        "Setzt bcdedit nx auf AlwaysOff. „Zurücksetzen“ löscht die NX-Überschreibung (Windows-Standard).",
      ),
      "checks_firewall_off": (
        "Firewall aus",
        "Deaktiviert öffentliche und Standard-Firewall-Profile. „Zurücksetzen“ stellt den standardmäßig aktivierten Status wieder her.",
      ),
      "checks_memory_compression_off": (
        "Speicherkomprimierung aus",
        "Deaktiviert die Speicherkomprimierung in MMAgent, um den CPU-Overhead bei Burst-Lasten zu senken.",
      ),
      "checks_smart_screen_off": (
        "SmartScreen aus",
        "Deaktiviert Windows-Reputationsprüfungen. Nur für kontrollierte Tests verwenden.",
      ),
      "checks_spectre_meltdown_off": (
        "Spectre/Meltdown-Abschwächungen deaktiviert",
        "Setzt FeatureSettingsOverride und FeatureSettingsOverrideMask auf 3.",
      ),
      "checks_uac_off": (
        "UAC aus",
        "Setzt die Benutzerkontensteuerung auf deaktiviert. Für die volle Wirkung ist ein Neustart erforderlich.",
      ),
      "checks_vbs_off": (
        "Virtualisierungsbasierte Sicherheit aus",
        "Deaktiviert die VBS-Richtlinie. Dadurch wird der Isolationsschutz von Windows geschwächt und ein Neustart erforderlich.",
      ),
      "checks_vulnerable_driver_blocklist_off": (
        "Blockierungsliste für gefährdete Treiber deaktiviert",
        "Deaktiviert die Sperrliste für anfällige Treiber von Microsoft. Dadurch wird der Kernelschutz geschwächt und ein Neustart erforderlich.",
      ),
      "check_bios_settings": (
        "BIOS-Einstellungshandbuch",
        "Interaktives BIOS-Anleitungsskript von Fr33thy.",
      ),
      "check_bios_update": (
        "BIOS-Update-Suche",
        "Öffnet das Motherboard-Suchskript von Fr33thy.",
      ),
      "check_cpu_test": (
        "CPU-Test",
        "Interaktives Stresstest-Skript von Fr33thy.",
      ),
      "check_gpu_check": (
        "GPU-Check",
        "Interaktives Diagnoseskript von Fr33thy.",
      ),
      "check_gpu_test": (
        "GPU-Test",
        "Interaktives Stresstest-Skript von Fr33thy.",
      ),
      "check_hw_info": (
        "HW-Info",
        "Interaktives Hardware-Info-Skript von Fr33thy.",
      ),
      "check_ram_check": (
        "RAM-Check",
        "Interaktives Diagnoseskript von Fr33thy.",
      ),
      "check_ram_test": (
        "RAM-Test",
        "Interaktives Stresstest-Skript von Fr33thy.",
      ),
      "check_space_check": (
        "Platzkontrolle",
        "Interaktives Diagnoseskript von Fr33thy.",
      ),
      "service_diagtrack_off": (
        "Vernetzte Benutzererfahrungen und Telemetrie aus",
        "Deaktiviert verbundene Benutzererfahrungen und Telemetrie und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_pimindexmaintenancesvc_off": (
        "Kontaktdaten aus",
        "Deaktiviert Kontaktdaten und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_devquerybroker_off": (
        "DevQuery Background Discovery Broker deaktiviert",
        "Deaktiviert den DevQuery Background Discovery Broker und stellt beim Zurücksetzen seinen genauen vorherigen Startstatus wieder her.",
      ),
      "service_diagsvc_off": (
        "Diagnoseausführungsdienst deaktiviert",
        "Deaktiviert den Diagnostic Execution Service und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_trkwks_off": (
        "Verteilter Link-Tracking-Client deaktiviert",
        "Deaktiviert den Distributed Link Tracking Client und stellt beim Zurücksetzen seinen genauen vorherigen Startstatus wieder her.",
      ),
      "service_mapsbroker_off": (
        "Maps Manager deaktiviert",
        "Deaktiviert den Downloaded Maps Manager und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_efs_off": (
        "Verschlüsselung des Dateisystems aus",
        "Deaktiviert das verschlüsselnde Dateisystem und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_inventorysvc_off": (
        "Bestands- und Kompatibilitätsbewertung deaktiviert",
        "Deaktiviert die Bestands- und Kompatibilitätsbewertung und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_wpcmonsvc_off": (
        "Kindersicherung aus",
        "Deaktiviert die Kindersicherung und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_semgrsvc_off": (
        "Zahlungen und NFC/SE-Manager aus",
        "Deaktiviert Zahlungen und NFC/SE Manager und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "toggle_printing_off": (
        "Drucken aus",
        "Deaktiviert den Druckspoolerdienst, bis er wiederhergestellt wird.",
      ),
      "service_pcasvc_off": (
        "Dienst „Programmkompatibilitätsassistent“ deaktiviert",
        "Deaktiviert den Programmkompatibilitäts-Assistentendienst und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_troubleshootingsvc_off": (
        "Empfohlener Fehlerbehebungsdienst deaktiviert",
        "Deaktiviert den empfohlenen Fehlerbehebungsdienst und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_remoteregistry_off": (
        "Remote-Registrierung deaktiviert",
        "Deaktiviert die Remote-Registrierung und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_retaildemo_off": (
        "Einzelhandels-Demo-Service deaktiviert",
        "Deaktiviert den Retail Demo Service und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_remoteaccess_off": (
        "Routing und Fernzugriff aus",
        "Deaktiviert Routing und Fernzugriff und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_shpamsvc_off": (
        "Shared PC Account Manager deaktiviert",
        "Deaktiviert den Shared PC Account Manager und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_scdeviceenum_off": (
        "Smartcard-Geräteaufzählung deaktiviert",
        "Deaktiviert die Smartcard-Geräteaufzählung und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_scardsvr_off": (
        "Smartcard aus",
        "Deaktiviert die Smart Card und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_svsvc_off": (
        "Spot Verifier aus",
        "Deaktiviert Spot Verifier und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_lmhosts_off": (
        "TCP/IP-NetBIOS-Helper aus",
        "Deaktiviert den TCP/IP NetBIOS Helper und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_messagingservice_off": (
        "Textnachrichten aus",
        "Deaktiviert Textnachrichten und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_dmwappushservice_off": (
        "WAP-Push-Nachrichten-Routing-Dienst deaktiviert",
        "Deaktiviert den WAP-Push-Message-Routing-Dienst und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_wersvc_off": (
        "Windows-Fehlerberichterstattungsdienst deaktiviert",
        "Deaktiviert den Windows-Fehlerberichterstattungsdienst und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_wecsvc_off": (
        "Windows-Ereigniskollektor deaktiviert",
        "Deaktiviert den Windows-Ereigniskollektor und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_wisvc_off": (
        "Windows Insider-Dienst deaktiviert",
        "Deaktiviert den Windows Insider-Dienst und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_wmpnetworksvc_off": (
        "Windows Media Player-Netzwerkfreigabe deaktiviert",
        "Deaktiviert die Netzwerkfreigabe von Windows Media Player und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_wpnservice_off": (
        "Windows-Push-Benachrichtigungssystemdienst deaktiviert",
        "Deaktiviert den Windows-Push-Benachrichtigungssystemdienst und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_xblauthmanager_off": (
        "Xbox Live Auth Manager deaktiviert",
        "Deaktiviert den Xbox Live Auth Manager und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_xblgamesave_off": (
        "Xbox Live-Spiel-Save-Off",
        "Deaktiviert das Speichern von Xbox Live-Spielen und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "service_xboxnetapisvc_off": (
        "Xbox Live-Netzwerkdienst deaktiviert",
        "Deaktiviert den Xbox Live-Netzwerkdienst und stellt beim Zurücksetzen den genauen vorherigen Startstatus wieder her.",
      ),
      "refresh_account_local": (
        "Konto lokal",
        "Interaktives Skript von Fr33thy.",
      ),
      "refresh_autounattend": (
        "Automatisch unbeaufsichtigt",
        "Interaktives Skript von Fr33thy.",
      ),
      "refresh_factory_reset": (
        "Werksreset",
        "Interaktives Skript von Fr33thy.",
      ),
      "refresh_network_driver": (
        "Netzwerktreiber",
        "Interaktives Skript von Fr33thy.",
      ),
      "refresh_reinstall": (
        "Neu installieren",
        "Interaktives Skript von Fr33thy.",
      ),
      "restore_clipchamp_clipchamp": (
        "Clipchamp wiederherstellen",
        "Installiert Clipchamp von den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_windowsalarms": (
        "Uhr wiederherstellen",
        "Installiert Clock von den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_devhome": (
        "Stellen Sie Dev Home wieder her",
        "Installiert Dev Home von den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_windowsfeedbackhub": (
        "Feedback-Hub wiederherstellen",
        "Installiert Feedback Hub aus den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_family": (
        "Stellen Sie die Microsoft-Familie wieder her",
        "Installiert Microsoft Family aus den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_windowsstore": (
        "Stellen Sie den Microsoft Store wieder her",
        "Installiert Microsoft Store von den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_todos": (
        "Stellen Sie Microsoft To Do wieder her",
        "Installiert Microsoft To Do aus den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_microsoftofficehub": (
        "Stellen Sie Office Hub wieder her",
        "Installiert Office Hub von den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_onedrive": (
        "OneDrive wiederherstellen",
        "Installiert OneDrive von den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_outlookforwindows": (
        "Outlook wiederherstellen (neu)",
        "Installiert Outlook (neu) aus den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_yourphone": (
        "Telefonverbindung wiederherstellen",
        "Installiert Phone Link aus den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_powerautomatedesktop": (
        "Stellen Sie Power Automate wieder her",
        "Installiert Power Automate aus den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_quickassist": (
        "Stellen Sie Quick Assist wieder her",
        "Installiert Quick Assist aus den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_stickynotes": (
        "Haftnotizen wiederherstellen",
        "Installiert Sticky Notes aus den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_gamingapp": (
        "Stellen Sie die Xbox-App wieder her",
        "Installiert die Xbox-App von den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_xboxgamingoverlay": (
        "Stellen Sie die Xbox Game Bar wieder her",
        "Installiert die Xbox Game Bar von den konfigurierten Windows-Paketquellen.",
      ),
      "restore_microsoft_xboxidentityprovider": (
        "Stellen Sie den Xbox-Identitätsanbieter wieder her",
        "Installiert den Xbox-Identitätsanbieter von den konfigurierten Windows-Paketquellen.",
      ),
      "refresh_to_bios": ("Zum BIOS", "Interaktives Skript von Fr33thy."),
      "refresh_updates_drivers_block": (
        "Aktualisiert den Treiberblock",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_activation_script": (
        "Aktivierung (Script-Variante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_background_apps_script": (
        "Hintergrund-Apps (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_bitlocker": ("BitLocker", "Interaktives Skript von Fr33thy."),
      "setup_convert_home_to_pro": (
        "Konvertieren Sie Home in Pro",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_date_language_region_time": (
        "Datum Sprache Region Uhrzeit",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_edge_settings_script": (
        "Kanteneinstellungen (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_keys": ("Schlüssel", "Interaktives Skript von Fr33thy."),
      "setup_memory_compression_script": (
        "Speicherkomprimierung (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_startup_apps_7": (
        "Startup-Apps (7)",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_startup_apps_8": (
        "Startup-Apps (8)",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_store_settings_script": (
        "Store-Einstellungen (Script-Variante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "setup_updates_pause": (
        "Updates pausieren",
        "Interaktives Skript von Fr33thy.",
      ),
      "bcd_optimizations": (
        "Erweiterte Boot-Optimierungen",
        "Passen Sie BCD und Boot-Pfad an, um den Overhead zu reduzieren.",
      ),
      "services_disable": (
        "Diagnosedienste",
        "Beschränken Sie die Aktivität des Diagnosedienstes für ein Lean-Profil.",
      ),
      "tool_amdvbflash_download": (
        "AMDVBFlash-Download",
        "Öffnet TechPowerUp AMDVBFlash-Downloads. ZapTweaks wählt niemals ein ROM aus oder führt Flash-Befehle aus.",
      ),
      "advanced_core_1_thread_1": (
        "Kern 1 Thread 1",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_dep_script": (
        "Datenausführungsverhinderung (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_defender": ("Verteidiger", "Interaktives Skript von Fr33thy."),
      "advanced_driver_whql_secure_boot_bypass": (
        "Treiber WHQL Secure Boot Bypass",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_file_download_security_warning": (
        "Sicherheitswarnung beim Dateidownload",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_firewall_script": (
        "Firewall (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_hardware_composed_flip_script": (
        "Hardware-komponierter unabhängiger Flip (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_hardware_legacy_flip_script": (
        "Hardware Legacy Flip (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_keyboard_shortcuts": (
        "Tastaturkürzel",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_mmagent_features_script": (
        "MMAgent-Funktionen (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_mpo_script": (
        "MPO (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_nvidia_nvflash_download": (
        "NVIDIA NVFlash-Download",
        "Öffnet TechPowerUp NVFlash-Downloads. ZapTweaks wählt niemals ein ROM aus oder führt Flash-Befehle aus.",
      ),
      "advanced_priority": ("Priorität", "Interaktives Skript von Fr33thy."),
      "advanced_rebar_force": (
        "Bewehrungskraft",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_scewin_gui_releases": (
        "SCEWIN-GUI-Versionen",
        "Öffnet die MIT-lizenzierten SCEWIN-GUI-Versionen. Es bearbeitet SCEWIN/AMISCE NVRAM-Dateien; SCEWIN selbst ist darin nicht enthalten.",
      ),
      "advanced_smt_ht": ("SMT HT", "Interaktives Skript von Fr33thy."),
      "advanced_services": (
        "Dienstleistungen",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_spectre_meltdown_script": (
        "Spectre Meltdown (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_start_search_shell_mobsync": (
        "Starten Sie Search Shell Mobsync",
        "Interaktives Skript von Fr33thy.",
      ),
      "advanced_ulps_script": (
        "ULPS (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "toggle_activity_history_off": (
        "Aktivitätsverlauf aus",
        "Verhindert, dass Windows den Aktivitätsverlauf veröffentlicht und hochlädt.",
      ),
      "privacy_consumer_content": (
        "Verbraucherinhalte und Auto-App-Vorschläge",
        "Deaktiviert Startempfehlungen, Vorschläge für Verbraucherinhalte und stille vorinstallierte App-Pushes.",
      ),
      "privacy_copilot": (
        "Copilot deaktivieren",
        "Deaktiviert Copilot-Richtlinien und entfernt die aktuelle Registrierung des Copilot-App-Pakets.",
      ),
      "telemetry_disable": (
        "Telemetrie deaktivieren",
        "Deaktivieren Sie Telemetrie- und Diagnosekanäle.",
      ),
      "privacy_gamebar": (
        "Spielleiste und Capture-Overlay",
        "Deaktiviert die Game Bar-Erfassung und Overlay-bezogene Richtlinienwerte.",
      ),
      "toggle_location_off": (
        "Standort aus",
        "Deaktiviert Windows-Standortdienste über eine Richtlinie.",
      ),
      "privacy_online_search_suggestions": (
        "Online-Suchvorschläge deaktiviert",
        "Deaktiviert webbasierte Vorschläge in der Windows-Suche, ohne die lokale Suche zu deaktivieren.",
      ),
      "privacy_powershell_telemetry": (
        "PowerShell 7-Telemetrie aus",
        "Wählt neue PowerShell 7-Prozesse aus der Anwendungstelemetrie aus. Ein Neustart ist erforderlich.",
      ),
      "privacy_tracking": (
        "Datenschutz und Tracking",
        "Reduzieren Sie Anzeigenverfolgung und Hintergrundaktivitätssignale.",
      ),
      "privacy_widgets": (
        "Widgets und Newsfeed",
        "Deaktiviert Widgets-Richtlinienflags und stoppt die Ausführung von Widget-Prozessen.",
      ),
      "privacy_safe_debloat": (
        "Sichere Debloat-Voreinstellung",
        "Entfernt nur ausgewählte UWP-Bloat-Apps, während Store- und Xbox-Basiskomponenten erhalten bleiben.",
      ),
      "tool_winsux_debloat": (
        "WinSux von Fr33hty",
        "Führt den Remote-WinSux-Debloat-Befehl von Fr33hty aus. Invasive Aktion ohne In-App-Rückgängigmachung.",
      ),
      "ui_background_apps_off": (
        "Hintergrund-Apps aus",
        "Blockiert die Ausführung von Apps im Hintergrund über die AppPrivacy-Richtlinie.",
      ),
      "toggle_center_taskbar_icons": (
        "Symbole der mittleren Taskleiste",
        "Verwendet die zentrierte Ausrichtung der Taskleistensymbole von Windows 11.",
      ),
      "ui_context_menu_clean": (
        "Kontextmenü bereinigen",
        "Aktiviert das klassische Kontextmenü und entfernt ausgewählte Shell-Clutter-Einträge.",
      ),
      "visual_effects": (
        "Visuelle Effekte deaktivieren",
        "Reduzieren Sie den Animations- und visuellen Aufwand.",
      ),
      "explorer_optimizations": (
        "Explorer-Optimierungen",
        "Optimieren Sie das Verhalten und Caching des Datei-Explorers.",
      ),
      "ui_folder_discovery_off": (
        "Ordnertyperkennung aus",
        "Verhindert, dass der Explorer Ordnervorlagen automatisch erkennt, was die Geschwindigkeit bei großen Medienordnern erhöhen kann.",
      ),
      "ui_hide_explorer_gallery": (
        "Datei-Explorer-Galerie ausblenden",
        "Versteckt das Galerie-Navigationselement im Datei-Explorer.",
      ),
      "notifications_minimal": (
        "Minimale Benachrichtigungen",
        "Reduzieren Sie Toast- und Sperrbildschirmunterbrechungen.",
      ),
      "ui_pointer_precision_off": (
        "Zeigergenauigkeit aus",
        "Deaktiviert die Zeigergenauigkeit und legt Mausschwellenwerte im 6/11-Stil fest.",
      ),
      "ui_start_taskbar_clean": (
        "Startmenü und Taskleiste bereinigen",
        "Versteckt Widgets/Suche/Aufgabenansicht/Chat und wendet die Einstellungen für Linksausrichtung und Listenansicht an.",
      ),
      "ui_sticky_keys_shortcut_off": (
        "Sticky Keys-Verknüpfung deaktiviert",
        "Verhindert, dass die fünffache Umschalttaste Sticky Keys öffnet.",
      ),
      "ui_taskbar_end_task": (
        "Taskleisten-Task beenden",
        "Fügt den Taskleisten-App-Kontextmenüs bei unterstützten Windows 11-Builds die Aufgabe „Task beenden“ hinzu.",
      ),
      "ui_dark_theme": (
        "Thema Schwarz",
        "Wendet ein dunkles Windows-UI-Profil an und deaktiviert Transparenzeffekte.",
      ),
      "ui_optimizations": (
        "UI-Optimierungen",
        "Übernehmen Sie die Taskleisten- und Shell-Bereinigungseinstellungen.",
      ),
      "hardware_background_polling_rate_cap": (
        "Obergrenze der Hintergrundabfragerate",
        "Aus = Hintergrundabfrage nicht gesperrt. „Zurücksetzen“ stellt das Standardverhalten wieder her.",
      ),
      "tool_autoruns_folder": (
        "Autoruns",
        "Suite zur Analyse von Start- und geplanten Aufgaben.",
      ),
      "hardware_background_polling_rate_cap_script": (
        "Obergrenze der Hintergrundabfragerate (Skriptvariante)",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_fix_tools_battery_report": (
        "Batteriebericht",
        "Fix Tools-Diagnoseskript.",
      ),
      "tool_beyond_performance_device_tweaker_discord": (
        "Beyond Performance Device Tweaker",
        "Öffnet den öffentlichen Beyond Performance Discord-Kanal, der Device Tweaker vertreibt.",
      ),
      "tool_cpuz_folder": (
        "CPU-Z",
        "Dienstprogramm für CPU- und Speicherinformationen.",
      ),
      "tool_cru_folder": (
        "CRU",
        "Dienstprogramm zur benutzerdefinierten Auflösung für Anzeigemodi.",
      ),
      "installers_cru_sre": (
        "CRU SRE-Skript-Installationsprogramm",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_fix_tools_change_name": ("Namen ändern", "Fix Tools-Hilfsskript."),
      "tool_cleanmgrplus_folder": (
        "Cleanmgr+",
        "Erweitertes Dienstprogramm zur Datenträgerbereinigung und Verwaltung temporärer Dateien.",
      ),
      "hardware_controller_overclock_script": (
        "Controller-Übertaktung",
        "Interaktives Skript von Fr33thy.",
      ),
      "hardware_controller_polling_rate_script": (
        "Controller-Abfrageratentest",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_device_cleanup_folder": (
        "Gerätebereinigung",
        "Bereinigt Phantom-/nicht vorhandene Geräteeinträge aus Windows.",
      ),
      "tool_dismpp_folder": (
        "Dism++",
        "Erweitertes DISM- und Wartungsbetriebs-Toolkit.",
      ),
      "tool_winslopr_releases": (
        "Laden Sie Winslopr herunter",
        "Öffnet die offizielle Winslopr-Releases-Seite auf GitHub in Ihrem Browser.",
      ),
      "tool_driver_store_explorer_folder": (
        "Driver Store Explorer (RAPR)",
        "Überprüft und bereinigt alte/unbenutzte Treiberpakete.",
      ),
      "tool_fix_tools_fastclean": (
        "FastClean",
        "Korrigieren Sie das Tools-Bereinigungsskript.",
      ),
      "tool_fix_tools_runner": (
        "Fix Tools Launcher",
        "Führt das Batch-Launcher-Menü „Fix Tools“ aus.",
      ),
      "tool_fortnite_diagnostic_ping": (
        "Fortnite-Diagnose-Ping-Tool von Alexanderthedad",
        "Führt den offiziellen Ferndiagnosebefehl zur Fortnite-Ping-Fehlerbehebung aus.",
      ),
      "tool_furmark_setup": (
        "FurMark-Installationsprogramm",
        "GPU-Stresstest-Installationspaket.",
      ),
      "tool_gpu_dword_manager": (
        "GPU-DWORD-Manager",
        "DWORD-Tuning-Dienstprogramm für die GPU-Registrierung.",
      ),
      "tool_gpuz": ("GPU-Z", "Detaillierte GPU-Diagnose und Sensoren."),
      "tool_gaming_net_diagnostic": (
        "Gaming-Netzwerkdiagnose",
        "Schnelles Netzwerkdiagnoseskript für Spielesitzungen.",
      ),
      "tool_hwinfo_folder": (
        "HWiNFO",
        "Systemsensoren und Hardware-Telemetrie-Suite.",
      ),
      "tool_import_disable_advanced_services_profile": (
        "Importieren Sie das Profil „Erweiterte Dienste deaktivieren“.",
        "Importiert das Profil zur dauerhaften Deaktivierung erweiterter Dienste aus der gebündelten .reg-Datei von Sapphire.",
      ),
      "tool_import_minimal_services_profile": (
        "Minimales Serviceprofil importieren",
        "Importiert minimale Dienststartrichtlinien aus der gebündelten .reg-Datei von Sapphire.",
      ),
      "tool_sysinternals_suite_winget": (
        "Installieren Sie die Sysinternals Suite",
        "Installiert die Microsoft Sysinternals Suite mit Winget. Das PowerShell-Fenster bleibt geöffnet, sodass Sie die endgültige PATH-/Tool-Ausgabe lesen können.",
      ),
      "tool_install_win11_debloat_raphire": (
        "Installieren Sie Win11 Debloat",
        "Führt den offiziellen Win11Debloat-Remotebefehl in einem sichtbaren PowerShell-Fenster mit erhöhten Rechten aus.",
      ),
      "tool_install_winhance": (
        "Installieren Sie Winhance",
        "Installiert Winhance mit Winget für allgemeine Windows-Anpassungen und Basisoptimierung.",
      ),
      "installers_menu": (
        "Installateur-Menü",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_winget_interactive_uninstaller": (
        "Interaktives App-Deinstallationsprogramm",
        "Listet installierte Winget-Anwendungen in einem Terminal auf, sodass Sie eine zum Entfernen auswählen können.",
      ),
      "tool_interrupt_affinity_policy": (
        "Affinitätsrichtlinien-Tool unterbrechen",
        "Dienstprogramm zur Interrupt-Affinität und IRQ-Richtlinienoptimierung.",
      ),
      "tool_interrupt_affinity_policy_ia64": (
        "Interrupt Affinity Policy Tool (IA64)",
        "IA64-Build des Interrupt-Affinitätsrichtlinien-Dienstprogramms.",
      ),
      "tool_interrupt_affinity_policy_x86": (
        "Interrupt Affinity Policy Tool (x86)",
        "x86-Build des Interrupt-Affinitätsrichtlinien-Dienstprogramms.",
      ),
      "tool_msi_afterburner_setup": (
        "MSI Afterburner-Installationsprogramm",
        "Installationsprogramm für GPU-Übertaktung und -Überwachung.",
      ),
      "installers_msi_afterburner": (
        "MSI Afterburner Script Installer",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_msi_util_folder": (
        "MSI-Dienstprogramm v3",
        "Dienstprogramm für Message Signaled Interrupt-Richtlinien.",
      ),
      "tool_more_clock_tool": (
        "Mehr Uhr-Tool",
        "AMD-Dienstprogramm zur Takt-/Spannungssteuerung.",
      ),
      "installers_more_clock_tool": (
        "Mehr Clock Tool Script Installer",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_more_power_tool_setup": (
        "MorePowerTool-Installationsprogramm",
        "AMD Power Table Tuning-Installationsprogramm.",
      ),
      "tool_mouse_flat_curve": (
        "Flache Mauskurve",
        "Wendet Einstellungen für die flache Beschleunigungskurve der Maus an.",
      ),
      "tool_mouse_movement_recorder": (
        "Mausbewegungsrekorder",
        "Überprüft das effektive Polling-Verhalten der Maus.",
      ),
      "hardware_mouse_polling_rate_test_script": (
        "Maus-Polling-Rate-Test",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_nvidia_profile_inspector_nip_profile": (
        "NVIDIA-Leistungseinstellungen (.nip)",
        "Leistungsorientiertes Profil. Nicht verwenden, wenn Sie visuelle Qualität wünschen.",
      ),
      "tool_nvidia_profile_inspector_folder": (
        "NVIDIA-Profilinspektor",
        "Erweiterter NVIDIA-Profileditor.",
      ),
      "installers_nvidia_profile_inspector": (
        "NVIDIA Profile Inspector-Skriptinstallationsprogramm",
        "Interaktives Skript von Fr33thy.",
      ),
      "tool_fix_tools_permessi": (
        "Permessi",
        "Korrigieren Sie das Reparaturskript für Tools-Berechtigungen.",
      ),
      "tool_polling_rate_tester_app": (
        "Polling-Rate-Tester-App",
        "Spezielles Dienstprogramm zur Validierung der Maus-Polling-Rate.",
      ),
      "tool_controller_polling": (
        "Umfragetool",
        "Tool zur Messung der Controller-Abfragerate.",
      ),
      "tool_power_settings_explorer": (
        "PowerSettingsExplorer",
        "Erweiterter Windows-Energieplan-Einstellungseditor.",
      ),
      "tool_prime95_folder": (
        "Prime95",
        "CPU-Stresstest und Stabilitätsvalidierung.",
      ),
      "tool_queue_size_tuner": (
        "Warteschlangengrößen-Tuner",
        "Dienstprogramm zur Optimierung der Speicherwarteschlange.",
      ),
      "tool_rammap_folder": (
        "RAMMap",
        "Microsoft Sysinternals-Dienstprogramm zur Analyse des physischen Speichers.",
      ),
      "tool_rtl_utility": (
        "RTL-Dienstprogramm",
        "Realtek-Dienstprogramm und Diagnosetool.",
      ),
      "tool_radeon_tuner_folder": (
        "Radeon-Tuner",
        "Dienstprogramm zur Optimierung und Profilierung von AMD Radeon-Treibern.",
      ),
      "tool_fix_tools_reset_network": (
        "Netzwerk zurücksetzen",
        "Fix Tools-Netzwerk-Reset-Skript.",
      ),
      "tool_fix_tools_ripristina_anteprime": (
        "Ripristina Anteprime",
        "Fix Tools-Skript zur Reparatur des Thumbnail-Cache.",
      ),
      "tool_ctt_winutil": (
        "Führen Sie CTT WinUtil aus",
        "Öffnet Chris Titus Tech WinUtil für allgemeine Windows-Einrichtungs-, Reparatur- und Basisoptimierungsaufgaben.",
      ),
      "tool_fix_tools_sfc_dism": (
        "SFC & DISM",
        "Korrigieren Sie die Integrität der Tools und das Image-Reparaturskript.",
      ),
      "tool_star_ethernet_analyzer_folder": (
        "Star Ethernet-Analysator",
        "Ethernet- und Jitter-Diagnose-Toolkit.",
      ),
      "tool_star_ethernet_analyzer_start_bat": (
        "Star Ethernet Analyzer Launcher",
        "Führt den mitgelieferten Batch-Launcher für Star Ethernet Analyzer aus.",
      ),
      "tool_star_ethernet_analyzer_script": (
        "Star Ethernet Analyzer-Skript",
        "Interaktives Hilfsskript für Star Ethernet Analyzer.",
      ),
      "tool_star_ethernet_analyzer_video": (
        "Videoanleitung zum Star-Ethernet-Analysator",
        "Öffnet die mitgelieferte Videoanleitung mit der Standard-Windows-App.",
      ),
      "tool_tcp_optimizer_folder": (
        "TCP-Optimierer",
        "Tool zur Optimierung und Diagnose des Netzwerk-Stacks.",
      ),
      "tool_testmem5_folder": (
        "TestMem5",
        "Dienstprogramm zum RAM-Stresstest.",
      ),
      "tool_usb_latency_analyzer_v2_marius_heier": (
        "USB-Latenzanalysator V2 von Marius Heier",
        "Führt das Diagnosetool von Marius Heier in einem sichtbaren erhöhten PowerShell-Fenster aus. Dies betrifft keine Optimierungen und ist für die Konsolendiagnoseausgabe gedacht.",
      ),
      "tool_unpark_cpu": (
        "CPU entparken",
        "Dienstprogramm zum Entparken des CPU-Kerns.",
      ),
      "tool_vivetool_folder": (
        "ViVeTool",
        "Windows-Dienstprogramm zur Feature-Flag-Verwaltung.",
      ),
      "tool_winscript_batch": (
        "WinScript-Stapeldienstprogramm",
        "Führt gebündelte Batch-Aktionen für die WinScript-Wartung aus.",
      ),
      "tool_hidusbf_folder": (
        "hidusbf",
        "USB-Polling-Übertaktungs-Toolkit für HID-Geräte.",
      ),
    },
    "es": <String, (String, String)>{
      "shortcut_advanced_system_settings": (
        "Configuración avanzada del sistema",
        "Performance, efectos visuales y ambientación.",
      ),
      "shortcut_bluetooth": (
        "Bluetooth y dispositivos",
        "Dispositivos emparejados, impresoras y configuración del mouse.",
      ),
      "shortcut_computer_management": (
        "Manejo Informático",
        "Consola unificada para herramientas del sistema.",
      ),
      "shortcut_device_manager": (
        "Administrador de dispositivos",
        "Abre el Administrador de dispositivos.",
      ),
      "shortcut_directx_diagnostic": (
        "Diagnóstico DirectX",
        "GPU, versión DirectX y diagnóstico de audio.",
      ),
      "shortcut_disk_management": (
        "Gestión de discos",
        "Particiones, volúmenes y letras de unidad.",
      ),
      "shortcut_display": (
        "Pantalla",
        "Resolución, escalado, HDR y frecuencia de actualización.",
      ),
      "shortcut_environment_variables": (
        "Variables de entorno",
        "Sistema y usuario PATH, TEMP y otras variables.",
      ),
      "shortcut_event_viewer": (
        "Visor de eventos",
        "Registros del sistema y de las aplicaciones.",
      ),
      "shortcut_game_mode": (
        "Configuración del modo de juego",
        "Configuración del modo de juego de Windows.",
      ),
      "shortcut_graphics_settings": (
        "Configuración de gráficos",
        "Preferencia de GPU por aplicación y HAGS.",
      ),
      "shortcut_hosts_file": (
        "Archivo de hosts",
        "Abre el archivo de hosts en el Bloc de notas.",
      ),
      "shortcut_installed_apps": (
        "Aplicaciones instaladas",
        "Desinstalar y reparar aplicaciones instaladas.",
      ),
      "shortcut_network": (
        "Red",
        "Configuración de Ethernet, Wi-Fi, VPN y proxy.",
      ),
      "shortcut_optional_features": (
        "Características opcionales",
        "Administre las funciones opcionales de Windows.",
      ),
      "shortcut_performance_monitor": (
        "Monitor de rendimiento",
        "Contadores en vivo y conjuntos de datos.",
      ),
      "shortcut_personalization": (
        "Personalización",
        "Fondo, colores y configuración de pantalla de bloqueo.",
      ),
      "shortcut_power_battery": (
        "Energía y batería",
        "Suspensión, tiempo de espera de la pantalla y configuración de la batería.",
      ),
      "shortcut_privacy_security": (
        "Privacidad y seguridad",
        "Permisos de privacidad y seguridad de Windows.",
      ),
      "shortcut_registry_editor": (
        "Editor de registro",
        "Acceso directo al registro.",
      ),
      "shortcut_reliability_history": (
        "Historial de confiabilidad",
        "Accidentes, fallos e historial de estabilidad.",
      ),
      "shortcut_resource_monitor": (
        "Monitor de recursos",
        "Actividad de CPU, memoria, disco y red.",
      ),
      "shortcut_services": (
        "Servicios",
        "Iniciar, detener y configurar servicios de Windows.",
      ),
      "shortcut_sound": (
        "sonido",
        "Configuración de salida, entrada y volumen.",
      ),
      "shortcut_startup_folder": (
        "Carpeta de inicio",
        "Aplicaciones de inicio por usuario.",
      ),
      "shortcut_system_configuration": (
        "Configuración del sistema",
        "Opciones de arranque y servicios de inicio.",
      ),
      "shortcut_task_scheduler": (
        "Programador de tareas",
        "Tareas programadas y desencadenantes.",
      ),
      "shortcut_windows_features": (
        "Características de Windows",
        "Activa o desactiva las funciones de Windows.",
      ),
      "shortcut_windows_update": (
        "Actualización de Windows",
        "Busque e instale actualizaciones.",
      ),
      "gaming_amd_gpu_extreme_profile": (
        "Perfil extremo de GPU AMD",
        "Deshabilita la aceleración térmica de AMD, Crash Defender, activación de energía, activación de reloj, ULPS, ASPM y otros comportamientos de ahorro de energía. Solo solución de problemas de escritorio.",
      ),
      "gaming_amd_gpu_safe_profile": (
        "Perfil seguro de GPU AMD",
        "Aplica un perfil de controlador AMD reversible sin desactivar la protección térmica, Crash Defender, la activación del reloj o la activación de energía.",
      ),
      "gpu_amd_optimizations": (
        "Solución de problemas de ULPS de GPU AMD",
        "Desactiva AMD ULPS para solucionar problemas; no desactiva la protección térmica ni la activación de energía.",
      ),
      "cpu_amd_optimizations": (
        "Optimizaciones de AMD Ryzen",
        "Aplique ajustes de potencia y latencia específicos de AMD.",
      ),
      "gaming_amd_ulps_off": (
        "AMD ULPS desactivado",
        "Deshabilita EnableUlps en las claves de clase de pantalla AMD. Útil para pruebas de latencia.",
      ),
      "cpu_unparking": (
        "Desestacionamiento del núcleo de la CPU",
        "Desaparque todos los núcleos de CPU para cargas de trabajo de baja latencia.",
      ),
      "cpu_power_management": (
        "Gestión de energía de la CPU",
        "Deshabilite la limitación y optimice el comportamiento del programador.",
      ),
      "gaming_mpo_off": (
        "Deshabilitar la superposición multiplano (MPO)",
        "Solución alternativa para la resolución de problemas relacionados con el parpadeo o la tartamudez de la pantalla; Se requiere reinicio.",
      ),
      "gaming_extended_gpu_timeout": (
        "Tiempo de espera de GPU extendido",
        "Establece un retraso de detección de tiempo de espera de GPU de 10 segundos para solucionar problemas de cargas de trabajo de GPU pesadas e inestables.",
      ),
      "gaming_legacy_flip_fse": (
        "Legacy Flip exclusivo a pantalla completa",
        "Cambia GameConfigStore al comportamiento orientado a FSE para pruebas heredadas de pantalla completa.",
      ),
      "game_mode": (
        "Modo de juego activado",
        "Habilita el modo de juego de Windows sin cambiar la barra de juegos de Xbox o el DVR de juegos.",
      ),
      "gaming_composed_flip_immediate_mode": (
        "Flip independiente compuesto por hardware",
        "Fuerza ForceFlipTrueImmediateMode=1 en el programador de gráficos.",
      ),
      "cpu_intel_optimizations": (
        "Optimizaciones de CPU Intel",
        "Ajuste el perfil de programación de núcleos Intel P y E.",
      ),
      "gpu_intel_optimizations": (
        "Optimizaciones de GPU Intel",
        "Aplique el ajuste del rendimiento de la pila de gráficos Intel.",
      ),
      "gpu_nvidia_optimizations": (
        "Optimizaciones de NVIDIA",
        "Aplique ajustes de latencia y programación de gráficos de NVIDIA.",
      ),
      "gaming_windowed_optimizations_on": (
        "Optimizaciones para juegos con ventana activadas",
        "Habilita la actualización con efecto de intercambio de Windows 11 para juegos compatibles con ventanas y sin bordes.",
      ),
      "ram_optimizations": (
        "Optimizaciones de RAM",
        "Ajuste el administrador de memoria y el comportamiento de la caché.",
      ),
      "storage_optimizations": (
        "Optimizaciones de almacenamiento",
        "Ajuste el comportamiento de NTFS, TRIM y energía de almacenamiento.",
      ),
      "timer_latency": (
        "Temporizador y latencia",
        "Ajuste MMCSS y el comportamiento de solicitud del temporizador.",
      ),
      "gaming_variable_refresh_rate_on": (
        "Frecuencia de actualización variable activada",
        "Habilita la preferencia de frecuencia de actualización variable de Windows para juegos compatibles.",
      ),
      "network_adapter_power_savings_wake_off": (
        "Ahorro de energía del adaptador y apagado",
        "Desactiva las funciones de ahorro de energía y activación en adaptadores de red físicos, con una copia de seguridad exacta para revertir.",
      ),
      "network_delivery_optimization_off": (
        "Optimización de entrega P2P desactivada",
        "Detiene las cargas y descargas de igual a igual de Windows Update.",
      ),
      "device_power_savings_off": (
        "Ahorro de energía del dispositivo desactivado",
        "Desactiva el ahorro de energía del dispositivo WMI. Esto aumenta el uso de energía en inactividad y está destinado a computadoras de escritorio.",
      ),
      "network_ecn_disabled": (
        "Deshabilitar ECN",
        "Desactiva la notificación explícita de congestión para favorecer un comportamiento predecible de baja latencia.",
      ),
      "network_timestamps_disabled": (
        "Deshabilitar marcas de tiempo TCP",
        "Deshabilita las marcas de tiempo de TCP para reducir la sobrecarga del protocolo en escenarios centrados en la latencia.",
      ),
      "network_rss_enabled": (
        "Habilitar RSS",
        "Habilita la escala del lado de recepción para distribuir el procesamiento de paquetes entre los núcleos de la CPU.",
      ),
      "network_fast_udp_datagram_send": (
        "Envío rápido de datagramas UDP",
        "Aumenta el umbral de envío de datagramas de AFD para cargas de trabajo UDP.",
      ),
      "network_ipv4_only": (
        "Enlaces solo IPv4",
        "Deshabilita los enlaces de adaptadores no esenciales y mantiene IPv4 habilitado en todos los adaptadores.",
      ),
      "network_llmnr_off": (
        "LLMNR desactivado",
        "Deshabilita la resolución de nombres de multidifusión local heredada.",
      ),
      "network_low_latency_bandwidth_profile": (
        "Perfil de red de baja latencia",
        "Aplica un perfil de red agresivo de baja latencia que puede reducir el rendimiento y la eficiencia general del ancho de banda.",
      ),
      "network_mmagent_features_off": (
        "Funciones de MMAgent desactivadas",
        "Deshabilita las funciones de captación previa/inicio previo/OperaciónAPI de MMAgent y establece Prefetcher en 0.",
      ),
      "network_optimizations": (
        "Optimizaciones de red",
        "Ajuste el perfil TCP y elimine la limitación multimedia.",
      ),
      "network_throttling_index_off": (
        "Índice de limitación de red desactivado",
        "Establece NetworkThrottlingIndex en 0xFFFFFFFF para eliminar los límites de limitación multimedia.",
      ),
      "network_prefer_ipv4": (
        "Prefiere IPv4 sobre IPv6",
        "Mantiene IPv6 habilitado pero da prioridad a IPv4. No se puede combinar con enlaces solo IPv4.",
      ),
      "network_itr_interactive_config": (
        "Configuración interactiva de NIC ITR",
        "Abre una herramienta interactiva elevada para configurar la tasa de aceleración de interrupción (ITR) de NIC para adaptadores Realtek/Intel/Killer compatibles.",
      ),
      "power_amd_preferred_cores": (
        "Núcleos preferidos de AMD",
        "Habilita AMD Precision Boost: permite que la CPU priorice los núcleos más potentes para cargas de trabajo de un solo subproceso. Solo CPU AMD.",
      ),
      "power_cpu_core_parking_off": (
        "Estacionamiento del núcleo de la CPU desactivado",
        "Muestra y establece los núcleos mínimos/máximos de estacionamiento de núcleos del plan activo al 100%.",
      ),
      "power_disable_cstates": (
        "Deshabilitar los estados C de la CPU",
        "Limita los estados de suspensión de la CPU para una máxima capacidad de respuesta y un impulso instantáneo. Solo computadora de escritorio: aumenta significativamente la temperatura y el consumo de energía en inactivo.",
      ),
      "power_cpu_idle_demote_promote": (
        "Deshabilitar CPU inactiva Degradar/Promocionar",
        "Establece los umbrales de degradación/promoción de inactividad al 100 % para reducir el tiempo que la CPU dedica a entrar o salir de estados inactivos. Menor latencia a mayor costo de energía.",
      ),
      "power_disable_dynamic_tick": (
        "Deshabilitar tick dinámico",
        "Ejecuta bcdedit /set enabledynamictick sí: hace que el temporizador del sistema sea más consistente, reduce el micro-tartamudeo en juegos y aplicaciones de baja latencia. Sigue vigente en Windows 11 en 2026.",
      ),
      "power_fast_startup_hibernate_off": (
        "Inicio rápido e hibernación desactivada",
        "Desactiva la hibernación y el inicio rápido para lograr una latencia más baja y un comportamiento de apagado más limpio.",
      ),
      "power_global_timer_resolution": (
        "Solicitudes de resolución de temporizador global",
        "Establece GlobalTimerResolutionRequests=1: restaura el comportamiento del temporizador de alta resolución en todo el sistema en Windows 11. Esencial para aplicaciones/juegos que dependen de una precisión del temporizador de 1 ms o 0,5 ms.",
      ),
      "power_hardware_pstates_intel": (
        "Estados P de hardware Intel (HWP)",
        "Configura Intel Speed Shift/Hardware P-States para obtener el máximo sesgo de rendimiento. Solo CPU Intel.",
      ),
      "power_max_processor_state": (
        "Estado máximo del procesador (100%)",
        "Establece la frecuencia máxima de la CPU en 100% para evitar una reducción agresiva de la frecuencia de reloj bajo carga.",
      ),
      "power_throttling_off": (
        "Aceleración de potencia apagada",
        "Desactiva la limitación de energía de Windows para una programación de CPU más consistente bajo carga.",
      ),
      "power_processor_boost_mode": (
        "Modo de mejora del rendimiento del procesador",
        "Habilita el modo agresivo de refuerzo de CPU (Intel/AMD). Mejora los relojes de impulso sostenido en cargas de trabajo de subprocesos múltiples. Recomendado para escritorios bien refrigerados.",
      ),
      "power_processor_time_check_interval": (
        "Intervalo de verificación del tiempo del procesador (5 ms)",
        "Reduce el intervalo de verificación del programador de la CPU de 15 ms a 5 ms para una respuesta de escalado de frecuencia más rápida.",
      ),
      "power_system_responsiveness_registry": (
        "Capacidad de respuesta del sistema (10)",
        "Establece la capacidad de respuesta del sistema en 10 (desde el valor predeterminado 20): brinda más tiempo de CPU para poner en primer plano las aplicaciones sobre los servicios del sistema. Mejora la sensación de juego y multitarea.",
      ),
      "power_tsc_sync_policy": (
        "Política de sincronización de TSC (mejorada)",
        "Establece tscsyncpolicy en Mejorado: mejora la sincronización del temporizador del núcleo de la CPU en sistemas de múltiples núcleos. Bajo riesgo, especialmente útil en sistemas antiguos de múltiples enchufes.",
      ),
      "power_ultimate_performance_plan": (
        "Plan de energía de máximo rendimiento",
        "Importa y activa Ultimate Performance. Revertir cambia nuevamente a Equilibrado.",
      ),
      "power_win32_priority_separation": (
        "Separación de prioridad Win32 (juegos)",
        "Establece Win32PrioritySeparation en 26 (hexadecimal 0x1a): prioriza el tiempo de CPU de la aplicación en primer plano. Ajuste de juego clásico para una menor latencia de entrada.",
      ),
      "graphics_amd_settings": (
        "Configuración de AMD",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_cpp_runtime": (
        "Tiempo de ejecución de C++",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_directx": (
        "Tiempo de ejecución de DirectX",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_driver_clean": (
        "Conductor limpio",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_driver_install_debloat_settings": (
        "Configuración y descarga de instalación del controlador",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_driver_install_latest": (
        "Instalación del controlador más reciente",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_hags_windowed": (
        "HAGS con ventana",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_hdcp": ("HDCP", "Guión interactivo de Fr33thy."),
      "graphics_intel_settings": (
        "Configuración Intel",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_msi_mode_script": (
        "Modo MSI (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_nvidia_settings": (
        "Configuración de NVIDIA",
        "Guión interactivo de Fr33thy.",
      ),
      "graphics_p0_state": ("Estado P0", "Guión interactivo de Fr33thy."),
      "graphics_resolution_refresh_rate": (
        "Resolución Tasa de actualización",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_auto_reboot_after_bsod_off": (
        "Reinicio automático después de desactivar BSOD",
        "Mantiene un código de parada en la pantalla en lugar de reiniciarse automáticamente después de un bloqueo.",
      ),
      "toggle_automatic_driver_updates_off": (
        "Actualizaciones automáticas de controladores desactivadas",
        "Evita que Windows Update instale automáticamente actualizaciones de controladores.",
      ),
      "windows_automatic_maintenance_off": (
        "Mantenimiento automático desactivado",
        "Desactiva el mantenimiento automático programado conservando las herramientas de mantenimiento manual.",
      ),
      "windows_ntfs_last_access_updates_off": (
        "Actualizaciones de último acceso NTFS desactivadas",
        "Evita que NTFS actualice una marca de tiempo cada vez que se lee un archivo.",
      ),
      "toggle_scheduled_defrag_off": (
        "Desfragmentación/TRIM programada desactivada",
        "Desactiva la tarea programada Optimizar unidades; La optimización manual sigue estando disponible.",
      ),
      "toggle_storage_sense_off": (
        "Sensor de almacenamiento desactivado",
        "Desactiva la limpieza automática de archivos temporales.",
      ),
      "system_responsiveness": (
        "Capacidad de respuesta del sistema",
        "Reduzca los retrasos en la interfaz de usuario y los valores de tiempo de espera de las tareas.",
      ),
      "windows_update": (
        "Comportamiento de actualización de Windows",
        "Ajuste el comportamiento de actualización para flujos de trabajo centrados en juegos.",
      ),
      "windows_autoruns_startup_tasks_apps_check": (
        "Comprobación de aplicaciones y tareas de inicio de ejecución automática",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_bloatware_script": (
        "Bloatware (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_bloatware_legacy_apps_check_script": (
        "Comprobación de aplicaciones heredadas de Bloatware (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_bloatware_legacy_features_check_script": (
        "Verificación de características heredadas de Bloatware (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_bloatware_taskmgr_check_script": (
        "Comprobación de Bloatware TaskMgr (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_bloatware_uwp_apps_check_script": (
        "Comprobación de aplicaciones Bloatware UWP (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_bloatware_uwp_features_check_script": (
        "Comprobación de funciones de Bloatware UWP (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_cleanup": ("limpieza", "Guión interactivo de Fr33thy."),
      "windows_context_menu_script": (
        "Menú contextual (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_control_panel_settings_script": (
        "Configuración del panel de control (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_copilot_script": (
        "Copiloto (variante de guión)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_core_isolation_script": (
        "Aislamiento del núcleo (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_defender_optimize": (
        "Optimizar defensor",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_device_manager_power_savings_wake": (
        "Administrador de dispositivos Ahorro de energía y activación",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_edge_webview_script": (
        "Edge y WebView (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_gamebar_script": (
        "Barra de juego (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_gamemode": ("Modo de juego", "Guión interactivo de Fr33thy."),
      "windows_loudness_eq": (
        "Ecualizador de sonoridad",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_nvme_faster_driver": (
        "Controlador NVME más rápido",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_network_adapter_power_savings_script": (
        "Ahorro de energía y reactivación del adaptador de red (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_network_ipv4_only_script": (
        "Red IPv4 únicamente (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_notepad_settings": (
        "Configuración del Bloc de notas",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_pointer_precision_script": (
        "Precisión del puntero (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_power_plan_script": (
        "Plan de energía (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_restore_point": (
        "Punto de restauración",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_scaling": ("Escalado", "Guión interactivo de Fr33thy."),
      "windows_signout_lockscreen_wallpaper_black": (
        "Fondo de Pantalla de Bloqueo Negro",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_sound": ("sonido", "Guión interactivo de Fr33thy."),
      "windows_start_menu_layout_script": (
        "Diseño del menú Inicio (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_start_menu_shortcuts_script": (
        "Accesos directos del menú Inicio (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_start_menu_taskbar_script": (
        "Barra de tareas del menú Inicio (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_theme_black_script": (
        "Tema negro (variante de guión)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_timer_resolution_script": (
        "Resolución del temporizador (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_uac_script": (
        "UAC (variante de guión)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_user_account_pictures_black": (
        "Imágenes de cuentas de usuario en negro",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_widgets_script": (
        "Widgets (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "windows_write_cache_buffer_flushing": (
        "Escritura de vaciado del búfer de caché",
        "Guión interactivo de Fr33thy.",
      ),
      "checks_core_isolation_off": (
        "Integridad de la memoria de aislamiento central desactivada",
        "Deshabilita la integridad de la memoria HVCI a través del escenario de registro DeviceGuard.",
      ),
      "checks_dep_off": (
        "Prevención de ejecución de datos desactivada",
        "Establece bcdedit nx en AlwaysOff. Revertir elimina la anulación de nx (valor predeterminado de Windows).",
      ),
      "checks_firewall_off": (
        "Cortafuegos desactivado",
        "Deshabilita los perfiles de firewall públicos y estándar. Revertir restaura el estado habilitado predeterminado.",
      ),
      "checks_memory_compression_off": (
        "Compresión de memoria desactivada",
        "Deshabilita MemoryCompression en MMAgent para reducir la sobrecarga de la CPU bajo cargas en ráfaga.",
      ),
      "checks_smart_screen_off": (
        "Pantalla inteligente apagada",
        "Desactiva las comprobaciones de reputación de Windows. Úselo únicamente para pruebas controladas.",
      ),
      "checks_spectre_meltdown_off": (
        "Mitigaciones de espectro/fusión desactivadas",
        "Establece FeatureSettingsOverride y FeatureSettingsOverrideMask en 3.",
      ),
      "checks_uac_off": (
        "UAC desactivado",
        "Establece el Control de cuentas de usuario en deshabilitado. Es necesario reiniciar para lograr un efecto completo.",
      ),
      "checks_vbs_off": (
        "Seguridad basada en virtualización desactivada",
        "Deshabilita la política VBS. Esto debilita las protecciones de aislamiento de Windows y requiere un reinicio.",
      ),
      "checks_vulnerable_driver_blocklist_off": (
        "Lista de bloqueo de controladores vulnerables desactivada",
        "Deshabilita la lista de bloqueo de controladores vulnerables de Microsoft. Esto debilita la protección del kernel y requiere un reinicio.",
      ),
      "check_bios_settings": (
        "Guía de configuración del BIOS",
        "Script de guía de BIOS interactivo de Fr33thy.",
      ),
      "check_bios_update": (
        "Búsqueda de actualización de BIOS",
        "Abre el script de búsqueda de la placa base de Fr33thy.",
      ),
      "check_cpu_test": (
        "Prueba de CPU",
        "Guión interactivo de prueba de estrés de Fr33thy.",
      ),
      "check_gpu_check": (
        "Comprobación de GPU",
        "Guión de diagnóstico interactivo de Fr33thy.",
      ),
      "check_gpu_test": (
        "Prueba de GPU",
        "Guión interactivo de prueba de estrés de Fr33thy.",
      ),
      "check_hw_info": (
        "Información de hardware",
        "Guión de información de hardware interactivo de Fr33thy.",
      ),
      "check_ram_check": (
        "Comprobación de RAM",
        "Guión de diagnóstico interactivo de Fr33thy.",
      ),
      "check_ram_test": (
        "Prueba de RAM",
        "Guión interactivo de prueba de estrés de Fr33thy.",
      ),
      "check_space_check": (
        "Comprobación de espacio",
        "Guión de diagnóstico interactivo de Fr33thy.",
      ),
      "service_diagtrack_off": (
        "Experiencias de usuario conectado y telemetría desactivadas",
        "Deshabilita las experiencias de usuario conectado y la telemetría y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_pimindexmaintenancesvc_off": (
        "Datos de contacto desactivados",
        "Deshabilita los datos de contacto y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_devquerybroker_off": (
        "Agente de descubrimiento en segundo plano de DevQuery desactivado",
        "Deshabilita DevQuery Background Discovery Broker y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_diagsvc_off": (
        "Servicio de ejecución de diagnóstico desactivado",
        "Deshabilita el servicio de ejecución de diagnóstico y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_trkwks_off": (
        "Cliente de seguimiento de enlaces distribuidos desactivado",
        "Deshabilita el cliente de seguimiento de enlaces distribuidos y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_mapsbroker_off": (
        "Administrador de mapas descargados desactivado",
        "Deshabilita el Administrador de mapas descargados y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_efs_off": (
        "Cifrar sistema de archivos desactivado",
        "Deshabilita el sistema de cifrado de archivos y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_inventorysvc_off": (
        "Tasación de inventario y compatibilidad desactivada",
        "Deshabilita la evaluación de inventario y compatibilidad y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_wpcmonsvc_off": (
        "Controles parentales desactivados",
        "Deshabilita los controles parentales y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_semgrsvc_off": (
        "Administrador de pagos y NFC/SE desactivado",
        "Desactiva Pagos y NFC/SE Manager y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "toggle_printing_off": (
        "Impresión desactivada",
        "Deshabilita el servicio Print Spooler hasta que se revierta.",
      ),
      "service_pcasvc_off": (
        "Servicio de asistente de compatibilidad de programas desactivado",
        "Deshabilita el servicio Asistente de compatibilidad de programas y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_troubleshootingsvc_off": (
        "Servicio de solución de problemas recomendado desactivado",
        "Deshabilita el servicio de solución de problemas recomendado y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_remoteregistry_off": (
        "Registro remoto desactivado",
        "Deshabilita el Registro remoto y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_retaildemo_off": (
        "Servicio de demostración minorista desactivado",
        "Deshabilita el servicio de demostración minorista y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_remoteaccess_off": (
        "Enrutamiento y acceso remoto desactivados",
        "Deshabilita el enrutamiento y el acceso remoto y restaura exactamente su estado de inicio anterior cuando se revierte.",
      ),
      "service_shpamsvc_off": (
        "Administrador de cuentas de PC compartida desactivado",
        "Deshabilita el Administrador de cuentas de PC compartida y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_scdeviceenum_off": (
        "Enumeración de dispositivos de tarjeta inteligente desactivada",
        "Deshabilita la enumeración de dispositivos de tarjeta inteligente y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_scardsvr_off": (
        "Tarjeta inteligente desactivada",
        "Deshabilita la tarjeta inteligente y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_svsvc_off": (
        "Verificador puntual desactivado",
        "Deshabilita Spot Verifier y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_lmhosts_off": (
        "Asistente TCP/IP NetBIOS desactivado",
        "Deshabilita TCP/IP NetBIOS Helper y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_messagingservice_off": (
        "Mensajes de texto desactivados",
        "Deshabilita la mensajería de texto y restaura exactamente su estado de inicio anterior cuando se revierte.",
      ),
      "service_dmwappushservice_off": (
        "Servicio de enrutamiento de mensajes push WAP desactivado",
        "Deshabilita el servicio de enrutamiento de mensajes push WAP y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_wersvc_off": (
        "Servicio de informe de errores de Windows desactivado",
        "Deshabilita el servicio de informe de errores de Windows y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_wecsvc_off": (
        "Colector de eventos de Windows desactivado",
        "Deshabilita el recopilador de eventos de Windows y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_wisvc_off": (
        "Servicio interno de Windows desactivado",
        "Deshabilita el servicio Windows Insider y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_wmpnetworksvc_off": (
        "Compartir red de Windows Media Player desactivado",
        "Deshabilita el uso compartido de red de Windows Media Player y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_wpnservice_off": (
        "Servicio del sistema de notificaciones push de Windows desactivado",
        "Deshabilita el servicio del sistema de notificaciones push de Windows y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_xblauthmanager_off": (
        "Administrador de autenticación de Xbox Live desactivado",
        "Deshabilita Xbox Live Auth Manager y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "service_xblgamesave_off": (
        "Ahorro de juegos de Xbox Live",
        "Desactiva Xbox Live Game Save y restaura exactamente su estado de inicio anterior cuando se revierte.",
      ),
      "service_xboxnetapisvc_off": (
        "Servicio de red Xbox Live desactivado",
        "Deshabilita el servicio de red Xbox Live y restaura su estado de inicio anterior exacto cuando se revierte.",
      ),
      "refresh_account_local": (
        "Cuenta Local",
        "Guión interactivo de Fr33thy.",
      ),
      "refresh_autounattend": (
        "desatendencia automática",
        "Guión interactivo de Fr33thy.",
      ),
      "refresh_factory_reset": (
        "Restablecimiento de fábrica",
        "Guión interactivo de Fr33thy.",
      ),
      "refresh_network_driver": (
        "Controlador de red",
        "Guión interactivo de Fr33thy.",
      ),
      "refresh_reinstall": ("Reinstalar", "Guión interactivo de Fr33thy."),
      "restore_clipchamp_clipchamp": (
        "Restaurar Clipchamp",
        "Instala Clipchamp desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_windowsalarms": (
        "Restaurar reloj",
        "Instala Clock desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_devhome": (
        "Restaurar inicio de desarrollo",
        "Instala Dev Home desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_windowsfeedbackhub": (
        "Restaurar el centro de comentarios",
        "Instala Feedback Hub desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_family": (
        "Restaurar la familia Microsoft",
        "Instala Microsoft Family desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_windowsstore": (
        "Restaurar la tienda de Microsoft",
        "Instala Microsoft Store desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_todos": (
        "Restaurar Microsoft para hacer",
        "Instala Microsoft To Do desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_microsoftofficehub": (
        "Restaurar el centro de Office",
        "Instala Office Hub desde los orígenes de paquetes de Windows configurados.",
      ),
      "restore_microsoft_onedrive": (
        "Restaurar OneDrive",
        "Instala OneDrive desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_outlookforwindows": (
        "Restaurar Outlook (nuevo)",
        "Instala Outlook (nuevo) desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_yourphone": (
        "Restaurar enlace telefónico",
        "Instala Phone Link desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_powerautomatedesktop": (
        "Restaurar energía automatizar",
        "Instala Power Automate desde los orígenes de paquetes de Windows configurados.",
      ),
      "restore_microsoft_quickassist": (
        "Restaurar asistencia rápida",
        "Instala Quick Assist desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_stickynotes": (
        "Restaurar notas adhesivas",
        "Instala Sticky Notes desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_gamingapp": (
        "Restaurar la aplicación Xbox",
        "Instala la aplicación Xbox desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_xboxgamingoverlay": (
        "Restaurar la barra de juegos de Xbox",
        "Instala Xbox Game Bar desde las fuentes de paquetes de Windows configuradas.",
      ),
      "restore_microsoft_xboxidentityprovider": (
        "Restaurar proveedor de identidad de Xbox",
        "Instala Xbox Identity Provider desde las fuentes de paquetes de Windows configuradas.",
      ),
      "refresh_to_bios": ("A la BIOS", "Guión interactivo de Fr33thy."),
      "refresh_updates_drivers_block": (
        "Bloque de controladores de actualizaciones",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_activation_script": (
        "Activación (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_background_apps_script": (
        "Aplicaciones en segundo plano (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_bitlocker": ("BitLocker", "Guión interactivo de Fr33thy."),
      "setup_convert_home_to_pro": (
        "Convertir casa a profesional",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_date_language_region_time": (
        "Fecha Idioma Región Hora",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_edge_settings_script": (
        "Configuración de borde (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_keys": ("llaves", "Guión interactivo de Fr33thy."),
      "setup_memory_compression_script": (
        "Compresión de memoria (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_startup_apps_7": (
        "Aplicaciones de inicio (7)",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_startup_apps_8": (
        "Aplicaciones de inicio (8)",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_store_settings_script": (
        "Configuración de la tienda (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "setup_updates_pause": (
        "Actualizaciones en pausa",
        "Guión interactivo de Fr33thy.",
      ),
      "bcd_optimizations": (
        "Optimizaciones de arranque avanzadas",
        "Ajuste BCD y ruta de arranque para reducir los gastos generales.",
      ),
      "services_disable": (
        "Servicios de diagnóstico",
        "Limitar la actividad del servicio de diagnóstico para un perfil eficiente.",
      ),
      "tool_amdvbflash_download": (
        "Descarga AMDVBFlash",
        "Abre las descargas de TechPowerUp AMDVBFlash. ZapTweaks nunca selecciona una ROM ni ejecuta comandos flash.",
      ),
      "advanced_core_1_thread_1": (
        "Núcleo 1 Hilo 1",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_dep_script": (
        "Prevención de ejecución de datos (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_defender": ("Defensor", "Guión interactivo de Fr33thy."),
      "advanced_driver_whql_secure_boot_bypass": (
        "Omisión de arranque seguro del controlador WHQL",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_file_download_security_warning": (
        "Advertencia de seguridad de descarga de archivos",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_firewall_script": (
        "Cortafuegos (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_hardware_composed_flip_script": (
        "Flip independiente compuesto por hardware (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_hardware_legacy_flip_script": (
        "Hardware Legacy Flip (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_keyboard_shortcuts": (
        "Atajos de teclado",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_mmagent_features_script": (
        "Funciones de MMAgent (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_mpo_script": (
        "MPO (variante de guión)",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_nvidia_nvflash_download": (
        "Descarga NVFlash de NVIDIA",
        "Abre las descargas de TechPowerUp NVFlash. ZapTweaks nunca selecciona una ROM ni ejecuta comandos flash.",
      ),
      "advanced_priority": ("Prioridad", "Guión interactivo de Fr33thy."),
      "advanced_rebar_force": (
        "Fuerza de barra de refuerzo",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_scewin_gui_releases": (
        "Lanzamientos de SCEWIN-GUI",
        "Abre las versiones de SCEWIN-GUI con licencia del MIT. Edita archivos SCEWIN/AMISCE NVRAM; no incluye al propio SCEWIN.",
      ),
      "advanced_smt_ht": ("SMT HT", "Guión interactivo de Fr33thy."),
      "advanced_services": ("Servicios", "Guión interactivo de Fr33thy."),
      "advanced_spectre_meltdown_script": (
        "Spectre Meltdown (variante de guión)",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_start_search_shell_mobsync": (
        "Iniciar búsqueda Shell Mobsync",
        "Guión interactivo de Fr33thy.",
      ),
      "advanced_ulps_script": (
        "ULPS (variante de guión)",
        "Guión interactivo de Fr33thy.",
      ),
      "toggle_activity_history_off": (
        "Historial de actividad desactivado",
        "Impide que Windows publique y cargue el historial de actividad.",
      ),
      "privacy_consumer_content": (
        "Contenido del consumidor y sugerencias de aplicaciones automáticas",
        "Deshabilita las recomendaciones de inicio, las sugerencias de contenido para el consumidor y los envíos silenciosos de aplicaciones preinstaladas.",
      ),
      "privacy_copilot": (
        "Deshabilitar copiloto",
        "Deshabilita las políticas de Copilot y elimina el registro actual del paquete de la aplicación Copilot.",
      ),
      "telemetry_disable": (
        "Desactivar telemetría",
        "Desactive los canales de telemetría y diagnóstico.",
      ),
      "privacy_gamebar": (
        "Barra de juegos y superposición de captura",
        "Deshabilita la captura de la barra de juegos y la superposición de valores de políticas relacionados.",
      ),
      "toggle_location_off": (
        "Ubicación desactivada",
        "Deshabilita los servicios de ubicación de Windows a través de una política.",
      ),
      "privacy_online_search_suggestions": (
        "Sugerencias de búsqueda en línea desactivadas",
        "Deshabilita las sugerencias basadas en web en la búsqueda de Windows sin deshabilitar la búsqueda local.",
      ),
      "privacy_powershell_telemetry": (
        "Telemetría de PowerShell 7 desactivada",
        "Opta por que los nuevos procesos de PowerShell 7 queden fuera de la telemetría de la aplicación. Es necesario reiniciar.",
      ),
      "privacy_tracking": (
        "Privacidad y seguimiento",
        "Reduzca el seguimiento de anuncios y las señales de actividad en segundo plano.",
      ),
      "privacy_widgets": (
        "Widgets y noticias",
        "Deshabilita los indicadores de política de widgets y detiene la ejecución de procesos de widgets.",
      ),
      "privacy_safe_debloat": (
        "Preajuste de liberación segura",
        "Elimina solo las aplicaciones bloat seleccionadas para UWP y al mismo tiempo conserva los componentes básicos de la Tienda y Xbox.",
      ),
      "tool_winsux_debloat": (
        "WinSux de Fr33hty",
        "Ejecuta el comando de desbloqueo WinSux remoto de Fr33hty. Acción invasiva sin reversión en la aplicación.",
      ),
      "ui_background_apps_off": (
        "Aplicaciones en segundo plano desactivadas",
        "Bloquea la ejecución de aplicaciones en segundo plano a través de la política AppPrivacy.",
      ),
      "toggle_center_taskbar_icons": (
        "Centrar iconos de la barra de tareas",
        "Utiliza la alineación de iconos de la barra de tareas centrada en Windows 11.",
      ),
      "ui_context_menu_clean": (
        "Menú contextual Limpiar",
        "Habilita el menú contextual clásico y elimina las entradas seleccionadas del desorden del shell.",
      ),
      "visual_effects": (
        "Deshabilitar efectos visuales",
        "Reduzca la animación y la sobrecarga visual.",
      ),
      "explorer_optimizations": (
        "Optimizaciones del explorador",
        "Ajuste el comportamiento y el almacenamiento en caché del explorador de archivos.",
      ),
      "ui_folder_discovery_off": (
        "Descubrimiento de tipo de carpeta desactivado",
        "Evita que Explorer detecte automáticamente plantillas de carpetas, lo que puede acelerar las carpetas multimedia de gran tamaño.",
      ),
      "ui_hide_explorer_gallery": (
        "Ocultar galería del Explorador de archivos",
        "Oculta el elemento de navegación de la Galería del Explorador de archivos.",
      ),
      "notifications_minimal": (
        "Notificaciones mínimas",
        "Reduzca las interrupciones de brindis y pantalla de bloqueo.",
      ),
      "ui_pointer_precision_off": (
        "Precisión del puntero desactivada",
        "Desactiva la precisión del puntero y establece umbrales de mouse estilo 6/11.",
      ),
      "ui_start_taskbar_clean": (
        "Menú Inicio y barra de tareas limpia",
        "Oculta widgets/búsqueda/vista de tareas/chat y aplica preferencias de alineación izquierda + vista de lista.",
      ),
      "ui_sticky_keys_shortcut_off": (
        "Atajo de teclas adhesivas desactivado",
        "Evita que el atajo Shift cinco veces abra Sticky Keys.",
      ),
      "ui_taskbar_end_task": (
        "Tarea final de la barra de tareas",
        "Agrega Finalizar tarea a los menús contextuales de la aplicación de la barra de tareas en compilaciones compatibles de Windows 11.",
      ),
      "ui_dark_theme": (
        "Tema negro",
        "Aplica un perfil de interfaz de usuario de Windows oscuro y desactiva los efectos de transparencia.",
      ),
      "ui_optimizations": (
        "Optimizaciones de la interfaz de usuario",
        "Aplique la configuración de limpieza de la barra de tareas y del shell.",
      ),
      "hardware_background_polling_rate_cap": (
        "Límite de tasa de sondeo en segundo plano",
        "Desactivado = sondeo en segundo plano desbloqueado. Revertir restaura el comportamiento predeterminado.",
      ),
      "tool_autoruns_folder": (
        "Ejecuciones automáticas",
        "Suite de análisis de tareas programadas y de inicio.",
      ),
      "hardware_background_polling_rate_cap_script": (
        "Límite de tasa de sondeo en segundo plano (variante de script)",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_fix_tools_battery_report": (
        "Informe de batería",
        "Script de diagnóstico de herramientas de reparación.",
      ),
      "tool_beyond_performance_device_tweaker_discord": (
        "Más allá del ajuste del dispositivo de rendimiento",
        "Abre el canal público Beyond Performance Discord que distribuye Device Tweaker.",
      ),
      "tool_cpuz_folder": (
        "CPU-Z",
        "Utilidad de información de CPU y memoria.",
      ),
      "tool_cru_folder": (
        "CRU",
        "Utilidad de resolución personalizada para modos de visualización.",
      ),
      "installers_cru_sre": (
        "Instalador de scripts CRU SRE",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_fix_tools_change_name": (
        "Cambiar nombre",
        "Script auxiliar de Fix Tools.",
      ),
      "tool_cleanmgrplus_folder": (
        "Gerente de limpieza+",
        "Utilidad extendida de limpieza de disco y administración de archivos temporales.",
      ),
      "hardware_controller_overclock_script": (
        "Overclock del controlador",
        "Guión interactivo de Fr33thy.",
      ),
      "hardware_controller_polling_rate_script": (
        "Prueba de tasa de sondeo del controlador",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_device_cleanup_folder": (
        "Limpieza del dispositivo",
        "Limpia las entradas de dispositivos fantasmas/no presentes de Windows.",
      ),
      "tool_dismpp_folder": (
        "Dism++",
        "Kit de herramientas de operaciones de servicio y DISM avanzado.",
      ),
      "tool_winslopr_releases": (
        "Descargar Winslopr",
        "Abre la página oficial de lanzamientos de Winslopr en GitHub en su navegador.",
      ),
      "tool_driver_store_explorer_folder": (
        "Explorador de tienda de controladores (RAPR)",
        "Inspecciona y elimina paquetes de controladores antiguos o no utilizados.",
      ),
      "tool_fix_tools_fastclean": (
        "limpieza rápida",
        "Script de limpieza de Fix Tools.",
      ),
      "tool_fix_tools_runner": (
        "Lanzador de herramientas de reparación",
        "Ejecuta el menú del iniciador por lotes de Fix Tools.",
      ),
      "tool_fortnite_diagnostic_ping": (
        "Herramienta de ping de diagnóstico de Fortnite de Alexanderthedad",
        "Ejecuta el comando de diagnóstico remoto oficial para la resolución de problemas de ping de Fortnite.",
      ),
      "tool_furmark_setup": (
        "Instalador de FurMark",
        "Paquete de instalación de prueba de estrés de GPU.",
      ),
      "tool_gpu_dword_manager": (
        "Administrador DWORD de GPU",
        "Utilidad de ajuste DWORD del registro de GPU.",
      ),
      "tool_gpuz": ("GPU-Z", "Diagnósticos y sensores detallados de GPU."),
      "tool_gaming_net_diagnostic": (
        "Diagnóstico de red de juegos",
        "Script de diagnóstico rápido de red para sesiones de juego.",
      ),
      "tool_hwinfo_folder": (
        "HWiNFO",
        "Sensores del sistema y suite de telemetría de hardware.",
      ),
      "tool_import_disable_advanced_services_profile": (
        "Importar Deshabilitar perfil de servicios avanzados",
        "Importa el perfil de desactivación completa de servicios avanzados desde el archivo .reg incluido por Sapphire.",
      ),
      "tool_import_minimal_services_profile": (
        "Importar perfil de servicios mínimos",
        "Importa una política de inicio de servicio mínima desde un archivo .reg incluido por Sapphire.",
      ),
      "tool_sysinternals_suite_winget": (
        "Instalar la suite Sysinternals",
        "Instala Microsoft Sysinternals Suite con Winget. La ventana de PowerShell permanece abierta para que pueda leer el resultado final de la RUTA/herramienta.",
      ),
      "tool_install_win11_debloat_raphire": (
        "Instalar Win11 Debloat",
        "Ejecuta el comando remoto oficial Win11Debloat en una ventana elevada visible de PowerShell.",
      ),
      "tool_install_winhance": (
        "Instalar Winhance",
        "Instala Winhance con Winget para la personalización común de Windows y la optimización básica.",
      ),
      "installers_menu": (
        "Menú de instaladores",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_winget_interactive_uninstaller": (
        "Desinstalador de aplicaciones interactivas",
        "Enumera las aplicaciones Winget instaladas en una terminal para que pueda seleccionar una y eliminarla.",
      ),
      "tool_interrupt_affinity_policy": (
        "Herramienta de política de afinidad de interrupción",
        "Utilidad de ajuste de políticas de IRQ y afinidad de interrupciones.",
      ),
      "tool_interrupt_affinity_policy_ia64": (
        "Herramienta de política de afinidad de interrupción (IA64)",
        "Construcción IA64 de la utilidad de política de afinidad de interrupciones.",
      ),
      "tool_interrupt_affinity_policy_x86": (
        "Herramienta de política de afinidad de interrupción (x86)",
        "Construcción x86 de la utilidad de política de afinidad de interrupciones.",
      ),
      "tool_msi_afterburner_setup": (
        "Instalador de posquemador MSI",
        "Instalador de monitoreo y overclocking de GPU.",
      ),
      "installers_msi_afterburner": (
        "Instalador de secuencias de comandos MSI Afterburner",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_msi_util_folder": (
        "Utilidad MSI v3",
        "Utilidad de política de interrupción señalizada por mensaje.",
      ),
      "tool_more_clock_tool": (
        "Más herramienta de reloj",
        "Utilidad de control de voltaje/reloj AMD.",
      ),
      "installers_more_clock_tool": (
        "Más instalador de scripts de la herramienta de reloj",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_more_power_tool_setup": (
        "MásInstalador PowerTool",
        "Instalador de tuning de mesa de potencia AMD.",
      ),
      "tool_mouse_flat_curve": (
        "Curva plana del ratón",
        "Aplica la configuración de la curva de aceleración del mouse plano.",
      ),
      "tool_mouse_movement_recorder": (
        "Grabador de movimiento del mouse",
        "Comprueba el comportamiento efectivo de sondeo del mouse.",
      ),
      "hardware_mouse_polling_rate_test_script": (
        "Prueba de tasa de sondeo del mouse",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_nvidia_profile_inspector_nip_profile": (
        "Configuración de rendimiento de NVIDIA (.nip)",
        "Perfil centrado en el desempeño. No lo utilice si busca calidad visual.",
      ),
      "tool_nvidia_profile_inspector_folder": (
        "Inspector de perfiles de NVIDIA",
        "Editor de perfiles NVIDIA avanzado.",
      ),
      "installers_nvidia_profile_inspector": (
        "Instalador de secuencias de comandos del inspector de perfiles NVIDIA",
        "Guión interactivo de Fr33thy.",
      ),
      "tool_fix_tools_permessi": (
        "Permessi",
        "Script de reparación de permisos de Fix Tools.",
      ),
      "tool_polling_rate_tester_app": (
        "Aplicación Probador de tasa de sondeo",
        "Utilidad dedicada de validación de la tasa de sondeo del mouse.",
      ),
      "tool_controller_polling": (
        "Herramienta de encuesta",
        "Herramienta de medición de la tasa de sondeo del controlador.",
      ),
      "tool_power_settings_explorer": (
        "Explorador de configuración de energía",
        "Editor avanzado de configuración del plan de energía de Windows.",
      ),
      "tool_prime95_folder": (
        "Prime95",
        "Prueba de estrés de CPU y validación de estabilidad.",
      ),
      "tool_queue_size_tuner": (
        "Sintonizador de tamaño de cola",
        "Utilidad de ajuste de colas de almacenamiento.",
      ),
      "tool_rammap_folder": (
        "RAMMapa",
        "Utilidad de análisis de memoria física Microsoft Sysinternals.",
      ),
      "tool_rtl_utility": (
        "Utilidad RTL",
        "Utilidad y herramienta de diagnóstico Realtek.",
      ),
      "tool_radeon_tuner_folder": (
        "Sintonizador Radeon",
        "Utilidad de perfil y ajuste del controlador AMD Radeon.",
      ),
      "tool_fix_tools_reset_network": (
        "Restablecer red",
        "Script de restablecimiento de red de Fix Tools.",
      ),
      "tool_fix_tools_ripristina_anteprime": (
        "Ripristina Anteprime",
        "Script de reparación de caché de miniaturas de Fix Tools.",
      ),
      "tool_ctt_winutil": (
        "Ejecute CTT WinUtil",
        "Abre Chris Titus Tech WinUtil para tareas comunes de configuración, reparación y optimización básica de Windows.",
      ),
      "tool_fix_tools_sfc_dism": (
        "SFC y DISM",
        "Arreglar la integridad de las herramientas y el script de reparación de imágenes.",
      ),
      "tool_star_ethernet_analyzer_folder": (
        "Analizador de Ethernet estrella",
        "Kit de herramientas de diagnóstico de Ethernet y jitter.",
      ),
      "tool_star_ethernet_analyzer_start_bat": (
        "Lanzador del analizador Star Ethernet",
        "Ejecuta el iniciador de lotes incluido para Star Ethernet Analyzer.",
      ),
      "tool_star_ethernet_analyzer_script": (
        "Script del analizador Star Ethernet",
        "Script de ayuda interactivo para Star Ethernet Analyzer.",
      ),
      "tool_star_ethernet_analyzer_video": (
        "Guía en vídeo del analizador Star Ethernet",
        "Abre la guía de vídeo incluida con la aplicación predeterminada de Windows.",
      ),
      "tool_tcp_optimizer_folder": (
        "Optimizador TCP",
        "Herramienta de diagnóstico y optimización de la pila de red.",
      ),
      "tool_testmem5_folder": (
        "PruebaMem5",
        "Utilidad de prueba de estrés de RAM.",
      ),
      "tool_usb_latency_analyzer_v2_marius_heier": (
        "Analizador de latencia USB V2 de marius heier",
        "Ejecuta la herramienta de diagnóstico de Marius Heier en una ventana elevada visible de PowerShell. Esto no aplica ajustes y está destinado a la salida de diagnóstico de la consola.",
      ),
      "tool_unpark_cpu": (
        "Desaparcar CPU",
        "Utilidad para desbloquear el núcleo de la CPU.",
      ),
      "tool_vivetool_folder": (
        "ViVeHerramienta",
        "Utilidad de administración de indicadores de funciones de Windows.",
      ),
      "tool_winscript_batch": (
        "Utilidad por lotes de WinScript",
        "Ejecuta acciones por lotes de mantenimiento de WinScript incluidas.",
      ),
      "tool_hidusbf_folder": (
        "hidusbf",
        "Kit de herramientas de overclock de sondeo USB para dispositivos HID.",
      ),
    },
    "fr": <String, (String, String)>{
      "shortcut_advanced_system_settings": (
        "Paramètres système avancés",
        "Performances, effets visuels et paramètres d’environnement.",
      ),
      "shortcut_bluetooth": (
        "Bluetooth et appareils",
        "Paramètres des appareils, imprimantes et souris couplés.",
      ),
      "shortcut_computer_management": (
        "Gestion informatique",
        "Console unifiée pour les outils système.",
      ),
      "shortcut_device_manager": (
        "Gestionnaire de périphériques",
        "Ouvre le Gestionnaire de périphériques.",
      ),
      "shortcut_directx_diagnostic": (
        "Diagnostic DirectX",
        "GPU, version DirectX et diagnostics audio.",
      ),
      "shortcut_disk_management": (
        "Gestion des disques",
        "Partitions, volumes et lettres de lecteur.",
      ),
      "shortcut_display": (
        "Affichage",
        "Résolution, mise à l'échelle, HDR et taux de rafraîchissement.",
      ),
      "shortcut_environment_variables": (
        "Variables d'environnement",
        "PATH système et utilisateur, TEMP et autres variables.",
      ),
      "shortcut_event_viewer": (
        "Observateur d'événements",
        "Journaux système et applications.",
      ),
      "shortcut_game_mode": (
        "Paramètres du mode jeu",
        "Paramètres du mode jeu Windows.",
      ),
      "shortcut_graphics_settings": (
        "Paramètres graphiques",
        "Préférence GPU par application et HAGS.",
      ),
      "shortcut_hosts_file": (
        "Fichier d'hôtes",
        "Ouvre le fichier hosts dans le Bloc-notes.",
      ),
      "shortcut_installed_apps": (
        "Applications installées",
        "Désinstallez et réparez les applications installées.",
      ),
      "shortcut_network": (
        "Réseau",
        "Paramètres Ethernet, Wi-Fi, VPN et proxy.",
      ),
      "shortcut_optional_features": (
        "Fonctionnalités facultatives",
        "Gérez les fonctionnalités facultatives de Windows.",
      ),
      "shortcut_performance_monitor": (
        "Moniteur de performances",
        "Compteurs en direct et ensembles de données.",
      ),
      "shortcut_personalization": (
        "Personnalisation",
        "Paramètres d’arrière-plan, de couleurs et d’écran de verrouillage.",
      ),
      "shortcut_power_battery": (
        "Alimentation et batterie",
        "Paramètres de veille, d'expiration de l'écran et de batterie.",
      ),
      "shortcut_privacy_security": (
        "Confidentialité et sécurité",
        "Autorisations de confidentialité et sécurité Windows.",
      ),
      "shortcut_registry_editor": (
        "Éditeur de registre",
        "Accès direct au registre.",
      ),
      "shortcut_reliability_history": (
        "Historique de fiabilité",
        "Crashs, échecs et historique de stabilité.",
      ),
      "shortcut_resource_monitor": (
        "Moniteur de ressources",
        "Activité du processeur, de la mémoire, du disque et du réseau.",
      ),
      "shortcut_services": (
        "Prestations",
        "Démarrez, arrêtez et configurez les services Windows.",
      ),
      "shortcut_sound": ("Son", "Paramètres de sortie, d’entrée et de volume."),
      "shortcut_startup_folder": (
        "Dossier de démarrage",
        "Applications de démarrage par utilisateur.",
      ),
      "shortcut_system_configuration": (
        "Configuration du système",
        "Options de démarrage et services de démarrage.",
      ),
      "shortcut_task_scheduler": (
        "Planificateur de tâches",
        "Tâches et déclencheurs planifiés.",
      ),
      "shortcut_windows_features": (
        "Fonctionnalités Windows",
        "Activez ou désactivez les fonctionnalités de Windows.",
      ),
      "shortcut_windows_update": (
        "Mise à jour Windows",
        "Recherchez et installez les mises à jour.",
      ),
      "gaming_amd_gpu_extreme_profile": (
        "Profil extrême du GPU AMD",
        "Désactive la limitation thermique AMD, Crash Defender, le power gating, l'horloge, ULPS, ASPM et d'autres comportements d'économie d'énergie. Dépannage du bureau uniquement.",
      ),
      "gaming_amd_gpu_safe_profile": (
        "Profil sécurisé pour GPU AMD",
        "Applique un profil de pilote AMD réversible sans désactiver la protection thermique, Crash Defender, le clock gating ou le power gating.",
      ),
      "gpu_amd_optimizations": (
        "Dépannage ULPS du GPU AMD",
        "Désactive AMD ULPS pour le dépannage ; il ne désactive pas la protection thermique ni le power gate.",
      ),
      "cpu_amd_optimizations": (
        "Optimisations AMD Ryzen",
        "Appliquez les réglages de puissance et de latence spécifiques à AMD.",
      ),
      "gaming_amd_ulps_off": (
        "AMD ULPS désactivé",
        "Désactive EnableUlps sur les clés de classe d’affichage AMD. Utile pour les tests de latence.",
      ),
      "cpu_unparking": (
        "Déparkage du cœur du processeur",
        "Libérez tous les cœurs de processeur pour les charges de travail à faible latence.",
      ),
      "cpu_power_management": (
        "Gestion de l'alimentation du processeur",
        "Désactivez la limitation et optimisez le comportement du planificateur.",
      ),
      "gaming_mpo_off": (
        "Désactiver la superposition multiplan (MPO)",
        "Solution de dépannage uniquement pour le scintillement ou le bégaiement de l'affichage ; redémarrage requis.",
      ),
      "gaming_extended_gpu_timeout": (
        "Délai d'expiration du GPU étendu",
        "Définit un délai de détection d'expiration du GPU de 10 secondes pour dépanner les charges de travail GPU lourdes et instables.",
      ),
      "gaming_legacy_flip_fse": (
        "Legacy Flip exclusif en plein écran",
        "Fait passer GameConfigStore au comportement orienté FSE pour les tests plein écran existants.",
      ),
      "game_mode": (
        "Mode jeu activé",
        "Active le mode jeu Windows sans modifier la Xbox Game Bar ou le Game DVR.",
      ),
      "gaming_composed_flip_immediate_mode": (
        "Flip indépendant composé de matériel",
        "Force ForceFlipTrueImmediateMode=1 dans le planificateur graphique.",
      ),
      "cpu_intel_optimizations": (
        "Optimisations du processeur Intel",
        "Ajustez le profil de planification des cœurs Intel P et E.",
      ),
      "gpu_intel_optimizations": (
        "Optimisations du GPU Intel",
        "Appliquez le réglage des performances de la pile graphique Intel.",
      ),
      "gpu_nvidia_optimizations": (
        "Optimisations NVIDIA",
        "Appliquez des ajustements de planification graphique et de latence NVIDIA.",
      ),
      "gaming_windowed_optimizations_on": (
        "Optimisations pour les jeux fenêtrés activés",
        "Permet la mise à niveau de l'effet d'échange de Windows 11 pour les jeux compatibles avec fenêtrage et sans bordure.",
      ),
      "ram_optimizations": (
        "Optimisations de la RAM",
        "Ajustez le gestionnaire de mémoire et le comportement du cache.",
      ),
      "storage_optimizations": (
        "Optimisations du stockage",
        "Ajustez le comportement de NTFS, TRIM et de la puissance de stockage.",
      ),
      "timer_latency": (
        "Minuterie et latence",
        "Ajustez le MMCSS et le comportement des demandes de minuterie.",
      ),
      "gaming_variable_refresh_rate_on": (
        "Taux de rafraîchissement variable activé",
        "Active la préférence de taux de rafraîchissement variable Windows pour les jeux compatibles.",
      ),
      "network_adapter_power_savings_wake_off": (
        "Économies d'énergie et réveil de l'adaptateur",
        "Désactive les fonctionnalités d'économie d'énergie et de réveil sur les adaptateurs réseau physiques, avec une sauvegarde exacte pour le rétablissement.",
      ),
      "network_delivery_optimization_off": (
        "Optimisation de la livraison P2P désactivée",
        "Arrête les téléchargements peer-to-peer Windows Update.",
      ),
      "device_power_savings_off": (
        "Économie d'énergie de l'appareil désactivée",
        "Désactive l’économie d’énergie du périphérique WMI. Cela augmente la consommation d'énergie au repos et est destiné aux ordinateurs de bureau.",
      ),
      "network_ecn_disabled": (
        "Désactiver l'ECN",
        "Désactive la notification explicite de congestion pour favoriser un comportement prévisible à faible latence.",
      ),
      "network_timestamps_disabled": (
        "Désactiver les horodatages TCP",
        "Désactive les horodatages TCP pour réduire la surcharge du protocole dans les scénarios axés sur la latence.",
      ),
      "network_rss_enabled": (
        "Activer RSS",
        "Permet à la mise à l'échelle côté réception de distribuer le traitement des paquets sur les cœurs du processeur.",
      ),
      "network_fast_udp_datagram_send": (
        "Envoi rapide de datagrammes UDP",
        "Augmente le seuil d'envoi de datagrammes AFD pour les charges de travail UDP.",
      ),
      "network_ipv4_only": (
        "Liaisons IPv4 uniquement",
        "Désactive les liaisons d’adaptateur non essentielles et maintient IPv4 activé sur tous les adaptateurs.",
      ),
      "network_llmnr_off": (
        "LLMNR désactivé",
        "Désactive la résolution de noms de multidiffusion locale héritée.",
      ),
      "network_low_latency_bandwidth_profile": (
        "Profil réseau à faible latence",
        "Applique un profil réseau agressif à faible latence qui peut réduire le débit et l'efficacité globale de la bande passante.",
      ),
      "network_mmagent_features_off": (
        "Fonctionnalités MMAgent désactivées",
        "Désactive les fonctionnalités de prélecture/prélancement/OperationAPI de MMAgent et définit Prefetcher sur 0.",
      ),
      "network_optimizations": (
        "Optimisations du réseau",
        "Ajustez le profil TCP et supprimez la limitation multimédia.",
      ),
      "network_throttling_index_off": (
        "Index de limitation du réseau désactivé",
        "Définit NetworkThrottlingIndex sur 0xFFFFFFFF pour supprimer les limites de limitation multimédia.",
      ),
      "network_prefer_ipv4": (
        "Préférez IPv4 à IPv6",
        "Maintient IPv6 activé mais donne la priorité à IPv4. Ne peut pas être combiné avec les liaisons IPv4 uniquement.",
      ),
      "network_itr_interactive_config": (
        "Configuration interactive de la carte réseau ITR",
        "Ouvre un outil interactif élevé pour configurer le taux d'accélération des interruptions de la carte réseau (ITR) pour les adaptateurs Realtek/Intel/Killer pris en charge.",
      ),
      "power_amd_preferred_cores": (
        "Cœurs préférés AMD",
        "Active AMD Precision Boost – permet au processeur de donner la priorité aux cœurs les plus puissants pour les charges de travail monothread. Processeurs AMD uniquement.",
      ),
      "power_cpu_core_parking_off": (
        "Stationnement du cœur du processeur désactivé",
        "Affiche et définit les cœurs min/max de stationnement du plan actif à 100 %.",
      ),
      "power_disable_cstates": (
        "Désactiver les états C du processeur",
        "Limite les états de veille du processeur pour une réactivité maximale et un boost instantané. Ordinateur de bureau uniquement : augmente considérablement la température et la consommation d'énergie au ralenti.",
      ),
      "power_cpu_idle_demote_promote": (
        "Désactiver la rétrogradation/promotion d'inactivité du processeur",
        "Définit les seuils de rétrogradation/promotion d'inactivité à 100 % pour réduire le temps passé par le processeur à entrer/sortir des états d'inactivité. Latence réduite pour un coût énergétique plus élevé.",
      ),
      "power_disable_dynamic_tick": (
        "Désactiver la coche dynamique",
        "Exécute bcdedit /set Disabledynamictick yes - rend la minuterie du système plus cohérente, réduit les micro-bégaiements dans les jeux et les applications à faible latence. Toujours efficace sur Windows 11 en 2026.",
      ),
      "power_fast_startup_hibernate_off": (
        "Démarrage rapide et mise en veille prolongée",
        "Désactive la mise en veille prolongée et le démarrage rapide pour une latence plus faible et un comportement d'arrêt plus propre.",
      ),
      "power_global_timer_resolution": (
        "Demandes de résolution de minuterie globale",
        "Définit GlobalTimerResolutionRequests=1 – restaure le comportement de la minuterie haute résolution à l’échelle du système sous Windows 11. Essentiel pour les applications/jeux qui reposent sur une précision de minuterie de 1 ms ou 0,5 ms.",
      ),
      "power_hardware_pstates_intel": (
        "États P matériels Intel (HWP)",
        "Configure Intel Speed Shift / Hardware P-States pour un biais de performances maximal. Processeurs Intel uniquement.",
      ),
      "power_max_processor_state": (
        "État maximal du processeur (100 %)",
        "Définit la fréquence maximale du processeur à 100 % pour éviter un downclocking agressif sous charge.",
      ),
      "power_throttling_off": (
        "Limitation de puissance désactivée",
        "Désactive la limitation de puissance de Windows pour une planification plus cohérente du processeur sous charge.",
      ),
      "power_processor_boost_mode": (
        "Mode d'amélioration des performances du processeur",
        "Active le mode boost agressif du processeur (Intel/AMD). Améliore les horloges de boost soutenues sur les charges de travail multithread. Recommandé pour les ordinateurs de bureau bien refroidis.",
      ),
      "power_processor_time_check_interval": (
        "Intervalle de vérification du temps du processeur (5 ms)",
        "Réduit l'intervalle de vérification du planificateur de processeur de 15 ms à 5 ms pour une réponse de mise à l'échelle de fréquence plus rapide.",
      ),
      "power_system_responsiveness_registry": (
        "Réactivité du système (10)",
        "Définit SystemResponsiveness sur 10 (par rapport à 20 par défaut) - donne plus de temps CPU aux applications de premier plan sur les services système. Améliore la sensation de jeu et de multitâche.",
      ),
      "power_tsc_sync_policy": (
        "Politique de synchronisation TSC (améliorée)",
        "Définit tscsyncpolicy sur Enhanced - améliore la synchronisation du minuteur du cœur du processeur sur les systèmes multicœurs. Faible risque, particulièrement utile sur les anciens systèmes multi-sockets.",
      ),
      "power_ultimate_performance_plan": (
        "Plan d'alimentation de performance ultime",
        "Importe et active Ultimate Performance. Revenir revient à Équilibré.",
      ),
      "power_win32_priority_separation": (
        "Séparation des priorités Win32 (Jeux)",
        "Définit Win32PrioritySeparation sur 26 (hex 0x1a) - donne la priorité au temps CPU de l'application de premier plan. Ajustement de jeu classique pour une latence d'entrée plus faible.",
      ),
      "graphics_amd_settings": (
        "Paramètres AMD",
        "Script interactif de Fr33thy.",
      ),
      "graphics_cpp_runtime": (
        "Exécution C++",
        "Script interactif de Fr33thy.",
      ),
      "graphics_directx": (
        "Exécution DirectX",
        "Script interactif de Fr33thy.",
      ),
      "graphics_driver_clean": (
        "Pilote propre",
        "Script interactif de Fr33thy.",
      ),
      "graphics_driver_install_debloat_settings": (
        "Débloat et paramètres d'installation du pilote",
        "Script interactif de Fr33thy.",
      ),
      "graphics_driver_install_latest": (
        "Dernière installation du pilote",
        "Script interactif de Fr33thy.",
      ),
      "graphics_hags_windowed": (
        "HAGS avec fenêtre",
        "Script interactif de Fr33thy.",
      ),
      "graphics_hdcp": ("HDCP", "Script interactif de Fr33thy."),
      "graphics_intel_settings": (
        "Paramètres Intel",
        "Script interactif de Fr33thy.",
      ),
      "graphics_msi_mode_script": (
        "Mode MSI (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "graphics_nvidia_settings": (
        "Paramètres NVIDIA",
        "Script interactif de Fr33thy.",
      ),
      "graphics_p0_state": ("État P0", "Script interactif de Fr33thy."),
      "graphics_resolution_refresh_rate": (
        "Taux de rafraîchissement de la résolution",
        "Script interactif de Fr33thy.",
      ),
      "windows_auto_reboot_after_bsod_off": (
        "Redémarrage automatique après la désactivation du BSOD",
        "Conserve un code d'arrêt à l'écran au lieu de redémarrer automatiquement après un crash.",
      ),
      "toggle_automatic_driver_updates_off": (
        "Mises à jour automatiques des pilotes désactivées",
        "Empêche Windows Update d'installer automatiquement les mises à jour des pilotes.",
      ),
      "windows_automatic_maintenance_off": (
        "Arrêt automatique de la maintenance",
        "Désactive la maintenance automatique programmée tout en préservant les outils de maintenance manuelle.",
      ),
      "windows_ntfs_last_access_updates_off": (
        "Mises à jour NTFS du dernier accès désactivées",
        "Empêche NTFS de mettre à jour un horodatage à chaque fois qu'un fichier est lu.",
      ),
      "toggle_scheduled_defrag_off": (
        "Défragmentation programmée / TRIM désactivé",
        "Désactive la tâche planifiée d'optimisation des lecteurs ; l'optimisation manuelle reste disponible.",
      ),
      "toggle_storage_sense_off": (
        "Détection de stockage désactivée",
        "Désactive le nettoyage automatique des fichiers temporaires.",
      ),
      "system_responsiveness": (
        "Réactivité du système",
        "Réduisez les retards de l’interface utilisateur et les valeurs d’expiration des tâches.",
      ),
      "windows_update": (
        "Comportement de Windows Update",
        "Ajustez le comportement de mise à jour pour les flux de travail axés sur les jeux.",
      ),
      "windows_autoruns_startup_tasks_apps_check": (
        "Exécution automatique des tâches de démarrage et vérification des applications",
        "Script interactif de Fr33thy.",
      ),
      "windows_bloatware_script": (
        "Bloatware (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_bloatware_legacy_apps_check_script": (
        "Vérification des applications héritées de Bloatware (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_bloatware_legacy_features_check_script": (
        "Vérification des fonctionnalités héritées de Bloatware (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_bloatware_taskmgr_check_script": (
        "Vérification de Bloatware TaskMgr (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_bloatware_uwp_apps_check_script": (
        "Vérification des applications Bloatware UWP (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_bloatware_uwp_features_check_script": (
        "Vérification des fonctionnalités de Bloatware UWP (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_cleanup": ("Nettoyage", "Script interactif de Fr33thy."),
      "windows_context_menu_script": (
        "Menu contextuel (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_control_panel_settings_script": (
        "Paramètres du panneau de configuration (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_copilot_script": (
        "Copilote (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_core_isolation_script": (
        "Isolation de base (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_defender_optimize": (
        "Défenseur Optimiser",
        "Script interactif de Fr33thy.",
      ),
      "windows_device_manager_power_savings_wake": (
        "Gestionnaire de périphériques Économies d'énergie et réveil",
        "Script interactif de Fr33thy.",
      ),
      "windows_edge_webview_script": (
        "Edge et WebView (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_gamebar_script": (
        "Barre de jeu (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_gamemode": ("Mode de jeu", "Script interactif de Fr33thy."),
      "windows_loudness_eq": (
        "Égalisation du volume",
        "Script interactif de Fr33thy.",
      ),
      "windows_nvme_faster_driver": (
        "Pilote NVME plus rapide",
        "Script interactif de Fr33thy.",
      ),
      "windows_network_adapter_power_savings_script": (
        "Économies d'énergie et réveil de l'adaptateur réseau (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_network_ipv4_only_script": (
        "Réseau IPv4 uniquement (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_notepad_settings": (
        "Paramètres du bloc-notes",
        "Script interactif de Fr33thy.",
      ),
      "windows_pointer_precision_script": (
        "Précision du pointeur (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_power_plan_script": (
        "Plan d'alimentation (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_restore_point": (
        "Point de restauration",
        "Script interactif de Fr33thy.",
      ),
      "windows_scaling": ("Mise à l'échelle", "Script interactif de Fr33thy."),
      "windows_signout_lockscreen_wallpaper_black": (
        "Déconnexion Lockscreen Fond D'écran Noir",
        "Script interactif de Fr33thy.",
      ),
      "windows_sound": ("Son", "Script interactif de Fr33thy."),
      "windows_start_menu_layout_script": (
        "Disposition du menu Démarrer (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_start_menu_shortcuts_script": (
        "Raccourcis du menu Démarrer (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_start_menu_taskbar_script": (
        "Barre des tâches du menu Démarrer (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_theme_black_script": (
        "Thème Noir (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_timer_resolution_script": (
        "Résolution de la minuterie (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_uac_script": (
        "UAC (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_user_account_pictures_black": (
        "Photos du compte utilisateur Noir",
        "Script interactif de Fr33thy.",
      ),
      "windows_widgets_script": (
        "Widgets (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "windows_write_cache_buffer_flushing": (
        "Vidage du tampon de cache d'écriture",
        "Script interactif de Fr33thy.",
      ),
      "checks_core_isolation_off": (
        "Intégrité de la mémoire d'isolation du cœur désactivée",
        "Désactive l’intégrité de la mémoire HVCI via le scénario de registre DeviceGuard.",
      ),
      "checks_dep_off": (
        "Prévention de l'exécution des données désactivée",
        "Définit bcdedit nx sur AlwaysOff. Revert supprime le remplacement de nx (par défaut de Windows).",
      ),
      "checks_firewall_off": (
        "Pare-feu désactivé",
        "Désactive les profils de pare-feu Public et Standard. Revert restaure l’état activé par défaut.",
      ),
      "checks_memory_compression_off": (
        "Compression de la mémoire désactivée",
        "Désactive MemoryCompression dans MMAgent pour réduire la surcharge du processeur sous les charges en rafale.",
      ),
      "checks_smart_screen_off": (
        "Écran intelligent désactivé",
        "Désactive les vérifications de réputation Windows. Utiliser uniquement pour des tests contrôlés.",
      ),
      "checks_spectre_meltdown_off": (
        "Atténuations de spectre/fusion désactivées",
        "Définit FeatureSettingsOverride et FeatureSettingsOverrideMask sur 3.",
      ),
      "checks_uac_off": (
        "UAC désactivé",
        "Définit le contrôle de compte d'utilisateur sur désactivé. Un redémarrage est nécessaire pour obtenir le plein effet.",
      ),
      "checks_vbs_off": (
        "Sécurité basée sur la virtualisation désactivée",
        "Désactive la stratégie VBS. Cela affaiblit les protections d'isolation de Windows et nécessite un redémarrage.",
      ),
      "checks_vulnerable_driver_blocklist_off": (
        "Liste de blocage des pilotes vulnérables désactivée",
        "Désactive la liste de blocage des pilotes vulnérables de Microsoft. Cela affaiblit la protection du noyau et nécessite un redémarrage.",
      ),
      "check_bios_settings": (
        "Guide des paramètres du BIOS",
        "Script interactif de guidage du BIOS par Fr33thy.",
      ),
      "check_bios_update": (
        "Recherche de mise à jour du BIOS",
        "Ouvre le script de recherche de carte mère par Fr33thy.",
      ),
      "check_cpu_test": (
        "Test du processeur",
        "Script de test de stress interactif par Fr33thy.",
      ),
      "check_gpu_check": (
        "Vérification du GPU",
        "Script de diagnostic interactif par Fr33thy.",
      ),
      "check_gpu_test": (
        "Test GPU",
        "Script de test de stress interactif par Fr33thy.",
      ),
      "check_hw_info": (
        "Informations matérielles",
        "Script interactif d'informations sur le matériel par Fr33thy.",
      ),
      "check_ram_check": (
        "Vérification de la RAM",
        "Script de diagnostic interactif par Fr33thy.",
      ),
      "check_ram_test": (
        "Test de RAM",
        "Script de test de stress interactif par Fr33thy.",
      ),
      "check_space_check": (
        "Vérification de l'espace",
        "Script de diagnostic interactif par Fr33thy.",
      ),
      "service_diagtrack_off": (
        "Expériences utilisateur connectées et télémétrie désactivées",
        "Désactive les expériences utilisateur connectées et la télémétrie et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_pimindexmaintenancesvc_off": (
        "Données de contact désactivées",
        "Désactive les données de contact et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_devquerybroker_off": (
        "Courtier de découverte en arrière-plan DevQuery désactivé",
        "Désactive DevQuery Background Discovery Broker et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_diagsvc_off": (
        "Service d'exécution de diagnostic désactivé",
        "Désactive le service d'exécution de diagnostic et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_trkwks_off": (
        "Client de suivi de lien distribué désactivé",
        "Désactive le client de suivi des liens distribués et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_mapsbroker_off": (
        "Gestionnaire de cartes téléchargées désactivé",
        "Désactive le gestionnaire de cartes téléchargées et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_efs_off": (
        "Cryptage du système de fichiers désactivé",
        "Désactive le cryptage du système de fichiers et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_inventorysvc_off": (
        "Inventaire et évaluation de compatibilité",
        "Désactive l'évaluation de l'inventaire et de la compatibilité et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_wpcmonsvc_off": (
        "Contrôle parental désactivé",
        "Désactive le contrôle parental et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_semgrsvc_off": (
        "Paiements et gestionnaire NFC/SE désactivés",
        "Désactive les paiements et NFC/SE Manager et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "toggle_printing_off": (
        "Impression désactivée",
        "Désactive le service Print Spooler jusqu’à ce qu’il soit rétabli.",
      ),
      "service_pcasvc_off": (
        "Assistant de compatibilité des programmes Service désactivé",
        "Désactive le service Assistant de compatibilité des programmes et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_troubleshootingsvc_off": (
        "Service de dépannage recommandé désactivé",
        "Désactive le service de dépannage recommandé et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_remoteregistry_off": (
        "Registre distant désactivé",
        "Désactive le registre distant et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_retaildemo_off": (
        "Service de démonstration au détail désactivé",
        "Désactive le service de démonstration de vente au détail et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_remoteaccess_off": (
        "Routage et accès à distance désactivés",
        "Désactive le routage et l'accès à distance et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_shpamsvc_off": (
        "Gestionnaire de comptes PC partagé désactivé",
        "Désactive le gestionnaire de comptes PC partagé et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_scdeviceenum_off": (
        "Énumération des périphériques de carte à puce désactivée",
        "Désactive l'énumération des périphériques de carte à puce et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_scardsvr_off": (
        "Carte à puce désactivée",
        "Désactive la carte à puce et restaure son état de démarrage précédent exact une fois rétablie.",
      ),
      "service_svsvc_off": (
        "Vérificateur ponctuel désactivé",
        "Désactive Spot Verifier et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_lmhosts_off": (
        "Assistant TCP/IP NetBIOS désactivé",
        "Désactive TCP/IP NetBIOS Helper et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_messagingservice_off": (
        "Messagerie texte désactivée",
        "Désactive la messagerie texte et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_dmwappushservice_off": (
        "Service de routage des messages push WAP désactivé",
        "Désactive le service de routage des messages push WAP et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_wersvc_off": (
        "Service de rapport d'erreurs Windows désactivé",
        "Désactive le service de rapport d'erreurs Windows et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_wecsvc_off": (
        "Collecteur d'événements Windows désactivé",
        "Désactive le collecteur d'événements Windows et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_wisvc_off": (
        "Service Windows Insider désactivé",
        "Désactive le service Windows Insider et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_wmpnetworksvc_off": (
        "Partage réseau du lecteur Windows Media désactivé",
        "Désactive le partage réseau du Lecteur Windows Media et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_wpnservice_off": (
        "Service système de notifications push Windows désactivé",
        "Désactive le service système de notifications push Windows et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_xblauthmanager_off": (
        "Gestionnaire d'authentification Xbox Live désactivé",
        "Désactive Xbox Live Auth Manager et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_xblgamesave_off": (
        "Économisez sur les jeux Xbox Live",
        "Désactive la sauvegarde de jeu Xbox Live et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "service_xboxnetapisvc_off": (
        "Service réseau Xbox Live désactivé",
        "Désactive le service réseau Xbox Live et restaure son état de démarrage précédent exact une fois rétabli.",
      ),
      "refresh_account_local": (
        "Compte local",
        "Script interactif de Fr33thy.",
      ),
      "refresh_autounattend": (
        "Sans surveillance automatique",
        "Script interactif de Fr33thy.",
      ),
      "refresh_factory_reset": (
        "Réinitialisation d'usine",
        "Script interactif de Fr33thy.",
      ),
      "refresh_network_driver": (
        "Pilote réseau",
        "Script interactif de Fr33thy.",
      ),
      "refresh_reinstall": ("Réinstaller", "Script interactif de Fr33thy."),
      "restore_clipchamp_clipchamp": (
        "Restaurer Clipchamp",
        "Installe Clipchamp à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_windowsalarms": (
        "Restaurer l'horloge",
        "Installe Clock à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_devhome": (
        "Restaurer l'accueil des développeurs",
        "Installe Dev Home à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_windowsfeedbackhub": (
        "Restaurer le centre de commentaires",
        "Installe Feedback Hub à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_family": (
        "Restaurer la famille Microsoft",
        "Installe Microsoft Family à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_windowsstore": (
        "Restaurer le Microsoft Store",
        "Installe le Microsoft Store à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_todos": (
        "Restaurer Microsoft à faire",
        "Installe Microsoft To Do à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_microsoftofficehub": (
        "Restaurer le hub Office",
        "Installe Office Hub à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_onedrive": (
        "Restaurer OneDrive",
        "Installe OneDrive à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_outlookforwindows": (
        "Restaurer Outlook (nouveau)",
        "Installe Outlook (nouveau) à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_yourphone": (
        "Restaurer le lien téléphonique",
        "Installe Phone Link à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_powerautomatedesktop": (
        "Restaurer l'automatisation de l'alimentation",
        "Installe Power Automate à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_quickassist": (
        "Restaurer l'assistance rapide",
        "Installe Quick Assist à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_stickynotes": (
        "Restaurer les notes autocollantes",
        "Installe Sticky Notes à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_gamingapp": (
        "Restaurer l'application Xbox",
        "Installe l'application Xbox à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_xboxgamingoverlay": (
        "Restaurer la barre de jeu Xbox",
        "Installe la Xbox Game Bar à partir des sources de packages Windows configurées.",
      ),
      "restore_microsoft_xboxidentityprovider": (
        "Restaurer le fournisseur d'identité Xbox",
        "Installe le fournisseur d'identité Xbox à partir des sources de packages Windows configurées.",
      ),
      "refresh_to_bios": ("Vers le BIOS", "Script interactif de Fr33thy."),
      "refresh_updates_drivers_block": (
        "Bloc de pilotes de mises à jour",
        "Script interactif de Fr33thy.",
      ),
      "setup_activation_script": (
        "Activation (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "setup_background_apps_script": (
        "Applications en arrière-plan (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "setup_bitlocker": ("BitLocker", "Script interactif de Fr33thy."),
      "setup_convert_home_to_pro": (
        "Convertir la maison en Pro",
        "Script interactif de Fr33thy.",
      ),
      "setup_date_language_region_time": (
        "Date Langue Région Heure",
        "Script interactif de Fr33thy.",
      ),
      "setup_edge_settings_script": (
        "Paramètres Edge (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "setup_keys": ("Clés", "Script interactif de Fr33thy."),
      "setup_memory_compression_script": (
        "Compression de mémoire (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "setup_startup_apps_7": (
        "Applications de démarrage (7)",
        "Script interactif de Fr33thy.",
      ),
      "setup_startup_apps_8": (
        "Applications de démarrage (8)",
        "Script interactif de Fr33thy.",
      ),
      "setup_store_settings_script": (
        "Paramètres du magasin (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "setup_updates_pause": (
        "Pause des mises à jour",
        "Script interactif de Fr33thy.",
      ),
      "bcd_optimizations": (
        "Optimisations de démarrage avancées",
        "Ajustez le BCD et le chemin de démarrage pour réduire les frais généraux.",
      ),
      "services_disable": (
        "Services de diagnostic",
        "Limitez l’activité du service de diagnostic pour un profil allégé.",
      ),
      "tool_amdvbflash_download": (
        "Téléchargement AMDVBFlash",
        "Ouvre les téléchargements TechPowerUp AMDVBFlash. ZapTweaks ne sélectionne jamais de ROM ni n'exécute de commandes flash.",
      ),
      "advanced_core_1_thread_1": (
        "Noyau 1 Fil 1",
        "Script interactif de Fr33thy.",
      ),
      "advanced_dep_script": (
        "Prévention de l'exécution des données (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "advanced_defender": ("Défenseur", "Script interactif de Fr33thy."),
      "advanced_driver_whql_secure_boot_bypass": (
        "Pilote WHQL Secure Boot Bypass",
        "Script interactif de Fr33thy.",
      ),
      "advanced_file_download_security_warning": (
        "Avertissement de sécurité pour le téléchargement de fichiers",
        "Script interactif de Fr33thy.",
      ),
      "advanced_firewall_script": (
        "Pare-feu (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "advanced_hardware_composed_flip_script": (
        "Flip indépendant composé de matériel (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "advanced_hardware_legacy_flip_script": (
        "Retournement matériel hérité (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "advanced_keyboard_shortcuts": (
        "Raccourcis clavier",
        "Script interactif de Fr33thy.",
      ),
      "advanced_mmagent_features_script": (
        "Fonctionnalités MMAgent (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "advanced_mpo_script": (
        "MPO (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "tool_nvidia_nvflash_download": (
        "Téléchargement NVIDIA NVFlash",
        "Ouvre les téléchargements TechPowerUp NVFlash. ZapTweaks ne sélectionne jamais de ROM ni n'exécute de commandes flash.",
      ),
      "advanced_priority": ("Priorité", "Script interactif de Fr33thy."),
      "advanced_rebar_force": (
        "Force des barres d'armature",
        "Script interactif de Fr33thy.",
      ),
      "tool_scewin_gui_releases": (
        "Versions de SCEWIN-GUI",
        "Ouvre les versions SCEWIN-GUI sous licence MIT. Il édite les fichiers SCEWIN/AMISCE NVRAM ; il n'inclut pas SCEWIN lui-même.",
      ),
      "advanced_smt_ht": ("SMT HT", "Script interactif de Fr33thy."),
      "advanced_services": ("Prestations", "Script interactif de Fr33thy."),
      "advanced_spectre_meltdown_script": (
        "Spectre Meltdown (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "advanced_start_search_shell_mobsync": (
        "Démarrer la recherche Shell Mobsync",
        "Script interactif de Fr33thy.",
      ),
      "advanced_ulps_script": (
        "ULPS (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "toggle_activity_history_off": (
        "Historique d'activité désactivé",
        "Empêche Windows de publier et de télécharger l'historique des activités.",
      ),
      "privacy_consumer_content": (
        "Contenu grand public et suggestions d'applications automatiques",
        "Désactive les recommandations de démarrage, les suggestions de contenu grand public et les applications push silencieuses préinstallées.",
      ),
      "privacy_copilot": (
        "Désactivation du copilote",
        "Désactive les politiques Copilot et supprime l’enregistrement actuel du package d’application Copilot.",
      ),
      "telemetry_disable": (
        "Désactiver la télémétrie",
        "Désactivez les canaux de télémétrie et de diagnostic.",
      ),
      "privacy_gamebar": (
        "Barre de jeu et superposition de capture",
        "Désactive la capture et la superposition des valeurs de stratégie liées à la capture de la barre de jeu.",
      ),
      "toggle_location_off": (
        "Localisation désactivée",
        "Désactive les services de localisation Windows via une stratégie.",
      ),
      "privacy_online_search_suggestions": (
        "Suggestions de recherche en ligne désactivées",
        "Désactive les suggestions Web dans la recherche Windows sans désactiver la recherche locale.",
      ),
      "privacy_powershell_telemetry": (
        "Télémétrie PowerShell 7 désactivée",
        "Optimise les nouveaux processus PowerShell 7 de la télémétrie des applications. Un redémarrage est nécessaire.",
      ),
      "privacy_tracking": (
        "Confidentialité et suivi",
        "Réduisez le suivi des publicités et les signaux d’activité en arrière-plan.",
      ),
      "privacy_widgets": (
        "Widgets et fil d'actualité",
        "Désactive les indicateurs de stratégie des widgets et arrête l’exécution des processus de widget.",
      ),
      "privacy_safe_debloat": (
        "Préréglage de déballage sécurisé",
        "Supprime uniquement les applications UWP bloat sélectionnées tout en préservant les composants de base Store et Xbox.",
      ),
      "tool_winsux_debloat": (
        "WinSux par Fr33hty",
        "Exécute la commande WinSux debloat à distance de Fr33hty. Action invasive sans retour dans l'application.",
      ),
      "ui_background_apps_off": (
        "Applications en arrière-plan désactivées",
        "Bloque l’exécution de l’application en arrière-plan via la stratégie AppPrivacy.",
      ),
      "toggle_center_taskbar_icons": (
        "Icônes de la barre des tâches centrale",
        "Utilise l’alignement centré des icônes de la barre des tâches de Windows 11.",
      ),
      "ui_context_menu_clean": (
        "Menu contextuel Nettoyer",
        "Active le menu contextuel classique et supprime les entrées encombrées du shell sélectionnées.",
      ),
      "visual_effects": (
        "Désactiver les effets visuels",
        "Réduisez l’animation et la surcharge visuelle.",
      ),
      "explorer_optimizations": (
        "Optimisations de l'explorateur",
        "Ajustez le comportement et la mise en cache de l'explorateur de fichiers.",
      ),
      "ui_folder_discovery_off": (
        "Découverte du type de dossier désactivée",
        "Empêche l'Explorateur de détecter automatiquement les modèles de dossiers, ce qui peut accélérer les dossiers multimédias volumineux.",
      ),
      "ui_hide_explorer_gallery": (
        "Masquer la galerie de l'explorateur de fichiers",
        "Masque l’élément de navigation Galerie de l’Explorateur de fichiers.",
      ),
      "notifications_minimal": (
        "Notifications minimales",
        "Réduisez les interruptions de toast et d’écran de verrouillage.",
      ),
      "ui_pointer_precision_off": (
        "Précision du pointeur désactivée",
        "Désactive la précision du pointeur et définit les seuils de souris de style 6/11.",
      ),
      "ui_start_taskbar_clean": (
        "Nettoyage du menu Démarrer et de la barre des tâches",
        "Masque les widgets/recherche/vue des tâches/chat et applique l’alignement à gauche + les préférences d’affichage de liste.",
      ),
      "ui_sticky_keys_shortcut_off": (
        "Raccourci des touches collantes désactivé",
        "Empêche le raccourci Shift cinq fois d'ouvrir les Sticky Keys.",
      ),
      "ui_taskbar_end_task": (
        "Fin de tâche dans la barre des tâches",
        "Ajoute la tâche de fin aux menus contextuels de l'application de la barre des tâches sur les versions Windows 11 prises en charge.",
      ),
      "ui_dark_theme": (
        "Thème Noir",
        "Applique un profil d'interface utilisateur Windows sombre et désactive les effets de transparence.",
      ),
      "ui_optimizations": (
        "Optimisations de l'interface utilisateur",
        "Appliquez les paramètres de nettoyage de la barre des tâches et du shell.",
      ),
      "hardware_background_polling_rate_cap": (
        "Plafond du taux d'interrogation en arrière-plan",
        "Désactivé = interrogation en arrière-plan déverrouillée. Revert restaure le comportement par défaut.",
      ),
      "tool_autoruns_folder": (
        "Exécutions automatiques",
        "Suite d'analyseurs de tâches de démarrage et de tâches planifiées.",
      ),
      "hardware_background_polling_rate_cap_script": (
        "Plafond du taux d'interrogation en arrière-plan (variante de script)",
        "Script interactif de Fr33thy.",
      ),
      "tool_fix_tools_battery_report": (
        "Rapport de batterie",
        "Réparer le script de diagnostic des outils.",
      ),
      "tool_beyond_performance_device_tweaker_discord": (
        "Au-delà des performances",
        "Ouvre la chaîne publique Beyond Performance Discord qui distribue Device Tweaker.",
      ),
      "tool_cpuz_folder": (
        "CPU-Z",
        "Utilitaire d'informations sur le processeur et la mémoire.",
      ),
      "tool_cru_folder": (
        "CRU",
        "Utilitaire de résolution personnalisée pour les modes d'affichage.",
      ),
      "installers_cru_sre": (
        "Programme d'installation de scripts CRU SRE",
        "Script interactif de Fr33thy.",
      ),
      "tool_fix_tools_change_name": (
        "Changer le nom",
        "Correction du script d'assistance des outils.",
      ),
      "tool_cleanmgrplus_folder": (
        "Nettoyer+",
        "Utilitaire étendu de nettoyage de disque et de gestion de fichiers temporaires.",
      ),
      "hardware_controller_overclock_script": (
        "Overclocking du contrôleur",
        "Script interactif de Fr33thy.",
      ),
      "hardware_controller_polling_rate_script": (
        "Test de taux d'interrogation du contrôleur",
        "Script interactif de Fr33thy.",
      ),
      "tool_device_cleanup_folder": (
        "Nettoyage de l'appareil",
        "Nettoie les entrées de périphérique fantômes/absents de Windows.",
      ),
      "tool_dismpp_folder": (
        "Dism++",
        "Boîte à outils avancée pour les opérations DISM et de maintenance.",
      ),
      "tool_winslopr_releases": (
        "Télécharger Winslopr",
        "Ouvre la page officielle des versions de Winslopr sur GitHub dans votre navigateur.",
      ),
      "tool_driver_store_explorer_folder": (
        "Explorateur de magasin de pilotes (RAPR)",
        "Inspecte et élague les packages de pilotes anciens/inutilisés.",
      ),
      "tool_fix_tools_fastclean": (
        "Nettoyage rapide",
        "Réparer le script de nettoyage des outils.",
      ),
      "tool_fix_tools_runner": (
        "Fixer le lanceur d'outils",
        "Exécute le menu du lanceur de lots Fix Tools.",
      ),
      "tool_fortnite_diagnostic_ping": (
        "Outil de diagnostic Ping Fortnite par Alexanderthedad",
        "Exécute la commande officielle de diagnostic à distance pour le dépannage du ping Fortnite.",
      ),
      "tool_furmark_setup": (
        "Installateur FurMark",
        "Package d'installation de test de stress GPU.",
      ),
      "tool_gpu_dword_manager": (
        "Gestionnaire GPU DWORD",
        "Utilitaire de réglage DWORD du registre GPU.",
      ),
      "tool_gpuz": ("GPU-Z", "Diagnostics et capteurs GPU détaillés."),
      "tool_gaming_net_diagnostic": (
        "Diagnostic du réseau de jeu",
        "Script de diagnostic réseau rapide pour les sessions de jeu.",
      ),
      "tool_hwinfo_folder": (
        "HWiINFO",
        "Capteurs système et suite matérielle de télémétrie.",
      ),
      "tool_import_disable_advanced_services_profile": (
        "Importer Désactiver le profil des services avancés",
        "Importe le profil de désactivation matérielle des services avancés à partir du fichier .reg fourni par Sapphire.",
      ),
      "tool_import_minimal_services_profile": (
        "Importer un profil de services minimaux",
        "Importe la politique de démarrage de service minimale à partir du fichier .reg fourni par Sapphire.",
      ),
      "tool_sysinternals_suite_winget": (
        "Installer la suite Sysinternals",
        "Installe la suite Microsoft Sysinternals avec Winget. La fenêtre PowerShell reste ouverte afin que vous puissiez lire la sortie finale du PATH/outil.",
      ),
      "tool_install_win11_debloat_raphire": (
        "Installer Win11 Debloat",
        "Exécute la commande à distance officielle Win11Debloat dans une fenêtre PowerShell élevée et visible.",
      ),
      "tool_install_winhance": (
        "Installer Winhance",
        "Installe Winhance avec Winget pour une personnalisation Windows courante et une optimisation de base.",
      ),
      "installers_menu": (
        "Menu Installateurs",
        "Script interactif de Fr33thy.",
      ),
      "tool_winget_interactive_uninstaller": (
        "Programme de désinstallation d'applications interactives",
        "Répertorie les applications Winget installées dans un terminal afin que vous puissiez en sélectionner une à supprimer.",
      ),
      "tool_interrupt_affinity_policy": (
        "Outil de stratégie d’affinité d’interruption",
        "Utilitaire d'affinité d'interruption et de réglage des politiques d'IRQ.",
      ),
      "tool_interrupt_affinity_policy_ia64": (
        "Outil de stratégie d’affinité d’interruption (IA64)",
        "Construction IA64 de l'utilitaire de politique d'affinité d'interruption.",
      ),
      "tool_interrupt_affinity_policy_x86": (
        "Outil de stratégie d’affinité d’interruption (x86)",
        "Version x86 de l'utilitaire de stratégie d'affinité d'interruption.",
      ),
      "tool_msi_afterburner_setup": (
        "Programme d'installation du programme de postcombustion MSI",
        "Installateur d'overclocking et de surveillance GPU.",
      ),
      "installers_msi_afterburner": (
        "Programme d'installation du script MSI Afterburner",
        "Script interactif de Fr33thy.",
      ),
      "tool_msi_util_folder": (
        "Utilitaire MSI v3",
        "Utilitaire de stratégie d’interruption signalée par message.",
      ),
      "tool_more_clock_tool": (
        "Plus d'outil d'horloge",
        "Utilitaire de contrôle d'horloge/tension AMD.",
      ),
      "installers_more_clock_tool": (
        "Plus d'installation de script d'outil d'horloge",
        "Script interactif de Fr33thy.",
      ),
      "tool_more_power_tool_setup": (
        "Installateur MorePowerTool",
        "Installateur de réglage de la table d'alimentation AMD.",
      ),
      "tool_mouse_flat_curve": (
        "Courbe plate de la souris",
        "Applique les paramètres de courbe d'accélération de la souris plate.",
      ),
      "tool_mouse_movement_recorder": (
        "Enregistreur de mouvements de souris",
        "Vérifie le comportement efficace d’interrogation de la souris.",
      ),
      "hardware_mouse_polling_rate_test_script": (
        "Test de taux d'interrogation de la souris",
        "Script interactif de Fr33thy.",
      ),
      "tool_nvidia_profile_inspector_nip_profile": (
        "Paramètres de performances NVIDIA (.nip)",
        "Profil axé sur la performance. Ne pas utiliser si vous recherchez une qualité visuelle.",
      ),
      "tool_nvidia_profile_inspector_folder": (
        "Inspecteur de profil NVIDIA",
        "Éditeur de profil NVIDIA avancé.",
      ),
      "installers_nvidia_profile_inspector": (
        "Programme d'installation du script de l'inspecteur de profil NVIDIA",
        "Script interactif de Fr33thy.",
      ),
      "tool_fix_tools_permessi": (
        "Permessi",
        "Réparer le script de réparation des autorisations des outils.",
      ),
      "tool_polling_rate_tester_app": (
        "Application de test de taux d'interrogation",
        "Utilitaire dédié de validation du taux d’interrogation de la souris.",
      ),
      "tool_controller_polling": (
        "Outil de sondage",
        "Outil de mesure du taux d’interrogation du contrôleur.",
      ),
      "tool_power_settings_explorer": (
        "Explorateur PowerSettings",
        "Éditeur avancé de paramètres de plan d’alimentation Windows.",
      ),
      "tool_prime95_folder": (
        "Premier95",
        "Test de stress CPU et validation de stabilité.",
      ),
      "tool_queue_size_tuner": (
        "Accordeur de taille de file d'attente",
        "Utilitaire de réglage de la file d'attente de stockage.",
      ),
      "tool_rammap_folder": (
        "Carte RAM",
        "Utilitaire d'analyse de la mémoire physique Microsoft Sysinternals.",
      ),
      "tool_rtl_utility": (
        "Utilitaire RTL",
        "Utilitaire et outil de diagnostic Realtek.",
      ),
      "tool_radeon_tuner_folder": (
        "Tuner Radeon",
        "Utilitaire de réglage et de profil du pilote AMD Radeon.",
      ),
      "tool_fix_tools_reset_network": (
        "Réinitialiser le réseau",
        "Réparer le script de réinitialisation du réseau Outils.",
      ),
      "tool_fix_tools_ripristina_anteprime": (
        "Ripristina Anteprime",
        "Réparer le script de réparation du cache des vignettes des outils.",
      ),
      "tool_ctt_winutil": (
        "Exécutez CTT WinUtil",
        "Ouvre Chris Titus Tech WinUtil pour les tâches courantes de configuration, de réparation et d'optimisation de base de Windows.",
      ),
      "tool_fix_tools_sfc_dism": (
        "SFC et DISM",
        "Correction de l'intégrité des outils et du script de réparation d'image.",
      ),
      "tool_star_ethernet_analyzer_folder": (
        "Analyseur Ethernet étoile",
        "Boîte à outils de diagnostic Ethernet et gigue.",
      ),
      "tool_star_ethernet_analyzer_start_bat": (
        "Lanceur d'analyseur Star Ethernet",
        "Exécute le lanceur de lots fourni pour Star Ethernet Analyzer.",
      ),
      "tool_star_ethernet_analyzer_script": (
        "Script de l'analyseur Star Ethernet",
        "Script d'aide interactif pour Star Ethernet Analyzer.",
      ),
      "tool_star_ethernet_analyzer_video": (
        "Guide vidéo de l'analyseur Star Ethernet",
        "Ouvre le guide vidéo fourni avec l'application Windows par défaut.",
      ),
      "tool_tcp_optimizer_folder": (
        "Optimiseur TCP",
        "Outil d’optimisation et de diagnostic de la pile réseau.",
      ),
      "tool_testmem5_folder": ("TestMem5", "Utilitaire de test de stress RAM."),
      "tool_usb_latency_analyzer_v2_marius_heier": (
        "Analyseur de latence USB V2 par Marius Heier",
        "Exécute l'outil de diagnostic de Marius Heier dans une fenêtre PowerShell visible et élevée. Cela ne s'applique pas aux ajustements et est destiné à la sortie des diagnostics de la console.",
      ),
      "tool_unpark_cpu": (
        "Déparquer le processeur",
        "Utilitaire de déparkage du cœur du processeur.",
      ),
      "tool_vivetool_folder": (
        "ViVeTool",
        "Utilitaire de gestion des indicateurs de fonctionnalités Windows.",
      ),
      "tool_winscript_batch": (
        "Utilitaire de lots WinScript",
        "Exécute les actions groupées de maintenance WinScript.",
      ),
      "tool_hidusbf_folder": (
        "hidusbf",
        "Boîte à outils d'overclocking d'interrogation USB pour les appareils HID.",
      ),
    },
    "ru": <String, (String, String)>{
      "shortcut_advanced_system_settings": (
        "Расширенные настройки системы",
        "Производительность, визуальные эффекты и настройки окружения.",
      ),
      "shortcut_bluetooth": (
        "Bluetooth и устройства",
        "Сопряженные устройства, принтеры и настройки мыши.",
      ),
      "shortcut_computer_management": (
        "Управление компьютером",
        "Единая консоль для системных инструментов.",
      ),
      "shortcut_device_manager": (
        "Диспетчер устройств",
        "Открывает диспетчер устройств.",
      ),
      "shortcut_directx_diagnostic": (
        "Диагностика DirectX",
        "Графический процессор, версия DirectX и аудиодиагностика.",
      ),
      "shortcut_disk_management": (
        "Управление дисками",
        "Разделы, тома и буквы дисков.",
      ),
      "shortcut_display": (
        "Дисплей",
        "Разрешение, масштабирование, HDR и частота обновления.",
      ),
      "shortcut_environment_variables": (
        "Переменные среды",
        "Системные и пользовательские PATH, TEMP и другие переменные.",
      ),
      "shortcut_event_viewer": (
        "Просмотр событий",
        "Журналы системы и приложений.",
      ),
      "shortcut_game_mode": (
        "Настройки игрового режима",
        "Настройки игрового режима Windows.",
      ),
      "shortcut_graphics_settings": (
        "Настройки графики",
        "Настройки графического процессора для каждого приложения и HAGS.",
      ),
      "shortcut_hosts_file": (
        "Файл хостов",
        "Открывает файл хостов в Блокноте.",
      ),
      "shortcut_installed_apps": (
        "Установленные приложения",
        "Удаление и восстановление установленных приложений.",
      ),
      "shortcut_network": ("Сеть", "Настройки Ethernet, Wi-Fi, VPN и прокси."),
      "shortcut_optional_features": (
        "Дополнительные функции",
        "Управление дополнительными функциями Windows.",
      ),
      "shortcut_performance_monitor": (
        "Монитор производительности",
        "Живые счетчики и наборы данных.",
      ),
      "shortcut_personalization": (
        "Персонализация",
        "Фон, цвета и настройки экрана блокировки.",
      ),
      "shortcut_power_battery": (
        "Мощность и аккумулятор",
        "Режим сна, тайм-аут экрана и настройки батареи.",
      ),
      "shortcut_privacy_security": (
        "Конфиденциальность и безопасность",
        "Разрешения на конфиденциальность и безопасность Windows.",
      ),
      "shortcut_registry_editor": (
        "Редактор реестра",
        "Прямой доступ к реестру.",
      ),
      "shortcut_reliability_history": (
        "История надежности",
        "Сбои, сбои и история стабильности.",
      ),
      "shortcut_resource_monitor": (
        "Монитор ресурсов",
        "Процессор, память, диск и сетевая активность.",
      ),
      "shortcut_services": (
        "Услуги",
        "Запуск, остановка и настройка служб Windows.",
      ),
      "shortcut_sound": ("Звук", "Настройки выхода, входа и громкости."),
      "shortcut_startup_folder": (
        "Папка автозагрузки",
        "Запуск приложений для каждого пользователя.",
      ),
      "shortcut_system_configuration": (
        "Конфигурация системы",
        "Параметры загрузки и службы запуска.",
      ),
      "shortcut_task_scheduler": (
        "Планировщик задач",
        "Запланированные задачи и триггеры.",
      ),
      "shortcut_windows_features": (
        "Возможности Windows",
        "Включите или отключите функции Windows.",
      ),
      "shortcut_windows_update": (
        "Центр обновления Windows",
        "Проверьте наличие и установите обновления.",
      ),
      "gaming_amd_gpu_extreme_profile": (
        "Экстремальный профиль графического процессора AMD",
        "Отключает тепловое регулирование AMD, Crash Defender, стробирование питания, стробирование тактовой частоты, ULPS, ASPM и другие функции энергосбережения. Только устранение неполадок на рабочем столе.",
      ),
      "gaming_amd_gpu_safe_profile": (
        "Безопасный профиль графического процессора AMD",
        "Применяет обратимый профиль драйвера AMD без отключения тепловой защиты, Crash Defender, стробирования тактовой частоты или стробирования мощности.",
      ),
      "gpu_amd_optimizations": (
        "Устранение неполадок ULPS графического процессора AMD",
        "Отключает AMD ULPS для устранения неполадок; он не отключает тепловую защиту или блокировку мощности.",
      ),
      "cpu_amd_optimizations": (
        "Оптимизация AMD Ryzen",
        "Примените специфичную для AMD настройку мощности и задержки.",
      ),
      "gaming_amd_ulps_off": (
        "AMD ULPS выкл.",
        "Отключает EnableUlps для ключей класса дисплея AMD. Полезно для тестирования задержки.",
      ),
      "cpu_unparking": (
        "Отключение ядра процессора",
        "Отключите все ядра ЦП для рабочих нагрузок с малой задержкой.",
      ),
      "cpu_power_management": (
        "Управление питанием процессора",
        "Отключите регулирование и оптимизируйте поведение планировщика.",
      ),
      "gaming_mpo_off": (
        "Отключить многоплоскостное наложение (MPO)",
        "Обходной путь только для устранения неполадок, связанных с мерцанием или зависанием дисплея; требуется перезагрузка.",
      ),
      "gaming_extended_gpu_timeout": (
        "Расширенный тайм-аут графического процессора",
        "Устанавливает 10-секундную задержку обнаружения тайм-аута графического процессора для устранения нестабильных и тяжелых рабочих нагрузок графического процессора.",
      ),
      "gaming_legacy_flip_fse": (
        "Эксклюзивный полноэкранный флип Legacy Flip",
        "Переключает GameConfigStore на поведение, ориентированное на FSE, для устаревшего полноэкранного тестирования.",
      ),
      "game_mode": (
        "Игровой режим включен",
        "Включает игровой режим Windows без изменения игровой панели Xbox или игрового видеорегистратора.",
      ),
      "gaming_composed_flip_immediate_mode": (
        "Аппаратный составной независимый флип",
        "Принудительно устанавливает ForceFlipTrueImmediateMode=1 в графическом планировщике.",
      ),
      "cpu_intel_optimizations": (
        "Оптимизация процессора Intel",
        "Настройте профиль планирования ядра Intel P и E.",
      ),
      "gpu_intel_optimizations": (
        "Оптимизация графического процессора Intel",
        "Примените настройку производительности графического стека Intel.",
      ),
      "gpu_nvidia_optimizations": (
        "Оптимизация NVIDIA",
        "Примените графическое планирование NVIDIA и настройки задержки.",
      ),
      "gaming_windowed_optimizations_on": (
        "Оптимизация для оконных игр включена",
        "Включает обновление с эффектом подкачки Windows 11 для совместимых игр с окном и без рамки.",
      ),
      "ram_optimizations": (
        "Оптимизация оперативной памяти",
        "Настройте диспетчер памяти и поведение кэша.",
      ),
      "storage_optimizations": (
        "Оптимизация хранилища",
        "Настройте NTFS, TRIM и энергопотребление хранилища.",
      ),
      "timer_latency": (
        "Таймер и задержка",
        "Настройте MMCSS и поведение запроса таймера.",
      ),
      "gaming_variable_refresh_rate_on": (
        "Переменная частота обновления включена",
        "Включает настройку переменной частоты обновления Windows для совместимых игр.",
      ),
      "network_adapter_power_savings_wake_off": (
        "Энергосбережение адаптера и выключение",
        "Отключает функции энергосбережения и пробуждения на физических сетевых адаптерах с точным резервным копированием для возврата.",
      ),
      "network_delivery_optimization_off": (
        "Оптимизация доставки P2P выключена",
        "Останавливает одноранговую загрузку и скачивание Центра обновления Windows.",
      ),
      "device_power_savings_off": (
        "Энергосбережение устройства выключено",
        "Отключает энергосбережение устройства WMI. Это увеличивает энергопотребление в режиме ожидания и предназначено для настольных компьютеров.",
      ),
      "network_ecn_disabled": (
        "Отключить ECN",
        "Отключает явное уведомление о перегрузке, чтобы обеспечить предсказуемое поведение с малой задержкой.",
      ),
      "network_timestamps_disabled": (
        "Отключить временные метки TCP",
        "Отключает временные метки TCP, чтобы уменьшить накладные расходы протокола в сценариях, ориентированных на задержку.",
      ),
      "network_rss_enabled": (
        "Включить RSS",
        "Включает масштабирование на стороне приема для распределения обработки пакетов по ядрам ЦП.",
      ),
      "network_fast_udp_datagram_send": (
        "Быстрая отправка датаграмм UDP",
        "Повышает порог отправки датаграммы AFD для рабочих нагрузок UDP.",
      ),
      "network_ipv4_only": (
        "Привязки только IPv4",
        "Отключает несущественные привязки адаптеров и сохраняет включенным IPv4 на всех адаптерах.",
      ),
      "network_llmnr_off": (
        "LLMNR выкл.",
        "Отключает устаревшее разрешение локальных имен многоадресной рассылки.",
      ),
      "network_low_latency_bandwidth_profile": (
        "Сетевой профиль с низкой задержкой",
        "Применяет агрессивный сетевой профиль с малой задержкой, который может снизить пропускную способность и общую эффективность использования полосы пропускания.",
      ),
      "network_mmagent_features_off": (
        "Функции MMAgent отключены",
        "Отключает функции предварительной выборки/предзапуска/OperationAPI MMAgent и устанавливает для Prefetcher значение 0.",
      ),
      "network_optimizations": (
        "Оптимизация сети",
        "Настройте профиль TCP и удалите регулирование мультимедиа.",
      ),
      "network_throttling_index_off": (
        "Индекс регулирования сети выключен",
        "Устанавливает для NetworkThrottlingIndex значение 0xFFFFFFFF, чтобы удалить ограничения регулирования мультимедиа.",
      ),
      "network_prefer_ipv4": (
        "Предпочитайте IPv4 IPv6",
        "IPv6 остается включенным, но приоритет отдается IPv4. Невозможно объединить с привязками «Только IPv4».",
      ),
      "network_itr_interactive_config": (
        "Интерактивная конфигурация NIC ITR",
        "Открывает интерактивный инструмент с повышенными правами для настройки частоты прерываний сетевого адаптера (ITR) для поддерживаемых адаптеров Realtek/Intel/Killer.",
      ),
      "power_amd_preferred_cores": (
        "Предпочтительные ядра AMD",
        "Включает AMD Precision Boost — позволяет процессору отдавать приоритет самым сильным ядрам для однопоточных рабочих нагрузок. Только процессоры AMD.",
      ),
      "power_cpu_core_parking_off": (
        "Парковка ядра процессора выключена",
        "Отображает и устанавливает минимальное/максимальное значение парковки ядра активного плана на 100%.",
      ),
      "power_disable_cstates": (
        "Отключить C-состояния процессора",
        "Ограничивает состояния сна процессора для максимальной реакции и мгновенного ускорения. Только для настольных компьютеров — значительно увеличивает температуру и энергопотребление в режиме простоя.",
      ),
      "power_cpu_idle_demote_promote": (
        "Отключить понижение/повышение уровня простоя ЦП",
        "Устанавливает пороговые значения понижения/повышения режима простоя на 100 %, чтобы сократить время, затрачиваемое ЦП на вход в состояния простоя и выход из него. Меньшая задержка при более высоких затратах на электроэнергию.",
      ),
      "power_disable_dynamic_tick": (
        "Отключить динамический тик",
        "Запускает bcdedit /set disabledynamictick yes — делает системный таймер более согласованным, уменьшает микрозадержки в играх и приложениях с малой задержкой. Все еще действует в Windows 11 в 2026 году.",
      ),
      "power_fast_startup_hibernate_off": (
        "Быстрый запуск и выключение режима гибернации",
        "Отключает режим гибернации и быстрый запуск для уменьшения задержки и более четкого завершения работы.",
      ),
      "power_global_timer_resolution": (
        "Запросы разрешения глобального таймера",
        "Устанавливает GlobalTimerResolutionRequests=1 — восстанавливает общесистемное поведение таймера с высоким разрешением в Windows 11. Важно для приложений и игр, которые полагаются на точность таймера 1 мс или 0,5 мс.",
      ),
      "power_hardware_pstates_intel": (
        "Аппаратные P-состояния Intel (HWP)",
        "Настраивает Intel Speed Shift/аппаратные P-состояния для максимального смещения производительности. Только процессоры Intel.",
      ),
      "power_max_processor_state": (
        "Максимальное состояние процессора (100%)",
        "Устанавливает максимальную частоту ЦП на 100 %, чтобы предотвратить резкое понижение тактовой частоты под нагрузкой.",
      ),
      "power_throttling_off": (
        "Регулирование мощности выключено",
        "Отключает регулирование мощности Windows для более согласованного планирования процессора под нагрузкой.",
      ),
      "power_processor_boost_mode": (
        "Режим повышения производительности процессора",
        "Включает агрессивный режим ускорения ЦП (Intel/AMD). Улучшает постоянную тактовую частоту при многопоточных рабочих нагрузках. Рекомендуется для хорошо охлаждаемых настольных компьютеров.",
      ),
      "power_processor_time_check_interval": (
        "Интервал проверки времени процессора (5 мс)",
        "Уменьшает интервал проверки планировщика ЦП с 15 мс до 5 мс для более быстрого реагирования на масштабирование частоты.",
      ),
      "power_system_responsiveness_registry": (
        "Отзывчивость системы (10)",
        "Устанавливает SystemResponsiveness равным 10 (по умолчанию 20) — дает больше процессорного времени приложениям на переднем плане по сравнению с системными службами. Улучшает ощущение игры и многозадачности.",
      ),
      "power_tsc_sync_policy": (
        "Политика синхронизации TSC (расширенная)",
        "Устанавливает для tscsyncpolicy значение Enhanced — улучшает синхронизацию таймера ядра ЦП в многоядерных системах. Низкий риск, особенно полезен в старых системах с несколькими сокетами.",
      ),
      "power_ultimate_performance_plan": (
        "План электропитания с максимальной производительностью",
        "Импортирует и активирует Ultimate Performance. Revert переключает обратно на баланс.",
      ),
      "power_win32_priority_separation": (
        "Разделение приоритетов Win32 (игры)",
        "Устанавливает для Win32PrioritySeparation значение 26 (шестнадцатеричное 0x1a) — определяет приоритет процессорного времени приложения на переднем плане. Классический игровой твик для снижения задержки ввода.",
      ),
      "graphics_amd_settings": (
        "Настройки AMD",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_cpp_runtime": (
        "С++ среда выполнения",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_directx": (
        "Среда выполнения DirectX",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_driver_clean": (
        "Драйвер чистый",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_driver_install_debloat_settings": (
        "Установка драйверов, разблокировка и настройки",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_driver_install_latest": (
        "Установка драйвера последняя",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_hags_windowed": (
        "HAGS с окнами",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_hdcp": ("HDCP", "Интерактивный сценарий от Fr33thy."),
      "graphics_intel_settings": (
        "Настройки Intel",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_msi_mode_script": (
        "Режим MSI (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_nvidia_settings": (
        "Настройки NVIDIA",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_p0_state": (
        "Состояние P0",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "graphics_resolution_refresh_rate": (
        "Частота обновления разрешения",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_auto_reboot_after_bsod_off": (
        "Автоматическая перезагрузка после BSOD выключена",
        "Сохраняет код остановки на экране вместо автоматического перезапуска после сбоя.",
      ),
      "toggle_automatic_driver_updates_off": (
        "Автоматическое обновление драйверов выключено",
        "Запрещает Центру обновления Windows автоматически устанавливать обновления драйверов.",
      ),
      "windows_automatic_maintenance_off": (
        "Автоматическое обслуживание выключено",
        "Отключает плановое автоматическое обслуживание, сохраняя при этом инструменты ручного обслуживания.",
      ),
      "windows_ntfs_last_access_updates_off": (
        "Обновления последнего доступа NTFS отключены",
        "Не позволяет NTFS обновлять метку времени каждый раз при чтении файла.",
      ),
      "toggle_scheduled_defrag_off": (
        "Запланированная дефрагментация/TRIM выключена",
        "Отключает запланированную задачу «Оптимизация дисков»; ручная оптимизация остается доступной.",
      ),
      "toggle_storage_sense_off": (
        "Контроль памяти выключен",
        "Отключает автоматическую очистку временных файлов.",
      ),
      "system_responsiveness": (
        "Отзывчивость системы",
        "Уменьшите задержки пользовательского интерфейса и значения времени ожидания задачи.",
      ),
      "windows_update": (
        "Поведение Центра обновления Windows",
        "Настройте поведение обновления для рабочих процессов, ориентированных на игры.",
      ),
      "windows_autoruns_startup_tasks_apps_check": (
        "Задачи автозапуска и проверка приложений",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_bloatware_script": (
        "Раздутое ПО (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_bloatware_legacy_apps_check_script": (
        "Проверка устаревших приложений на наличие вредоносного ПО (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_bloatware_legacy_features_check_script": (
        "Проверка устаревших функций раздутого ПО (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_bloatware_taskmgr_check_script": (
        "Проверка раздутого ПО TaskMgr (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_bloatware_uwp_apps_check_script": (
        "Проверка приложений UWP для раздутого ПО (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_bloatware_uwp_features_check_script": (
        "Проверка функций раздутого ПО UWP (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_cleanup": ("Очистка", "Интерактивный сценарий от Fr33thy."),
      "windows_context_menu_script": (
        "Контекстное меню (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_control_panel_settings_script": (
        "Настройки панели управления (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_copilot_script": (
        "Второй пилот (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_core_isolation_script": (
        "Изоляция ядра (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_defender_optimize": (
        "Оптимизация защитника",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_device_manager_power_savings_wake": (
        "Диспетчер устройств: энергосбережение и пробуждение",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_edge_webview_script": (
        "Edge и WebView (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_gamebar_script": (
        "Игровая панель (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_gamemode": ("Режим игры", "Интерактивный сценарий от Fr33thy."),
      "windows_loudness_eq": (
        "Эквалайзер громкости",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_nvme_faster_driver": (
        "NVME более быстрый драйвер",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_network_adapter_power_savings_script": (
        "Энергосбережение и пробуждение сетевого адаптера (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_network_ipv4_only_script": (
        "Только сеть IPv4 (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_notepad_settings": (
        "Настройки блокнота",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_pointer_precision_script": (
        "Точность указателя (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_power_plan_script": (
        "План электропитания (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_restore_point": (
        "Точка восстановления",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_scaling": (
        "Масштабирование",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_signout_lockscreen_wallpaper_black": (
        "Выход Обои для экрана блокировки Черный",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_sound": ("Звук", "Интерактивный сценарий от Fr33thy."),
      "windows_start_menu_layout_script": (
        "Макет меню «Пуск» (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_start_menu_shortcuts_script": (
        "Ярлыки меню «Пуск» (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_start_menu_taskbar_script": (
        "Панель задач меню «Пуск» (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_theme_black_script": (
        "Черная тема (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_timer_resolution_script": (
        "Разрешение таймера (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_uac_script": (
        "UAC (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_user_account_pictures_black": (
        "Изображения учетной записи пользователя черные",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_widgets_script": (
        "Виджеты (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "windows_write_cache_buffer_flushing": (
        "Запись очистки буфера кэша",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "checks_core_isolation_off": (
        "Изоляция ядра. Целостность памяти выключена.",
        "Отключает целостность памяти HVCI через сценарий реестра DeviceGuard.",
      ),
      "checks_dep_off": (
        "Предотвращение выполнения данных выключено",
        "Устанавливает для bcdedit nx значение AlwaysOff. Revert удаляет переопределение nx (по умолчанию в Windows).",
      ),
      "checks_firewall_off": (
        "Брандмауэр выключен",
        "Отключает общедоступные и стандартные профили брандмауэра. Revert восстанавливает включенное состояние по умолчанию.",
      ),
      "checks_memory_compression_off": (
        "Сжатие памяти выключено",
        "Отключает сжатие памяти в MMAgent для снижения нагрузки на процессор при пакетных нагрузках.",
      ),
      "checks_smart_screen_off": (
        "SmartScreen выключен",
        "Отключает проверку репутации Windows. Используйте только для контролируемого тестирования.",
      ),
      "checks_spectre_meltdown_off": (
        "Защита от Spectre/Meltdown отключена",
        "Устанавливает для FeatureSettingsOverride и FeatureSettingsOverrideMask значение 3.",
      ),
      "checks_uac_off": (
        "UAC выключен",
        "Отключает контроль учетных записей пользователей. Для полного эффекта необходима перезагрузка.",
      ),
      "checks_vbs_off": (
        "Безопасность на основе виртуализации выключена",
        "Отключает политику VBS. Это ослабляет изоляционную защиту Windows и требует перезагрузки.",
      ),
      "checks_vulnerable_driver_blocklist_off": (
        "Черный список уязвимых драйверов отключен",
        "Отключает черный список уязвимых драйверов Microsoft. Это ослабляет защиту ядра и требует перезагрузки.",
      ),
      "check_bios_settings": (
        "Руководство по настройке BIOS",
        "Сценарий интерактивного руководства по BIOS от Fr33thy.",
      ),
      "check_bios_update": (
        "Поиск обновлений BIOS",
        "Открывает скрипт поиска материнской платы от Fr33thy.",
      ),
      "check_cpu_test": (
        "Тест процессора",
        "Интерактивный скрипт стресс-теста от Fr33thy.",
      ),
      "check_gpu_check": (
        "Проверка графического процессора",
        "Интерактивный диагностический скрипт от Fr33thy.",
      ),
      "check_gpu_test": (
        "Тест графического процессора",
        "Интерактивный скрипт стресс-теста от Fr33thy.",
      ),
      "check_hw_info": (
        "Информация об оборудовании",
        "Интерактивный сценарий информации об оборудовании от Fr33thy.",
      ),
      "check_ram_check": (
        "Проверка оперативной памяти",
        "Интерактивный диагностический скрипт от Fr33thy.",
      ),
      "check_ram_test": (
        "Тест оперативной памяти",
        "Интерактивный скрипт стресс-теста от Fr33thy.",
      ),
      "check_space_check": (
        "Проверка пространства",
        "Интерактивный диагностический скрипт от Fr33thy.",
      ),
      "service_diagtrack_off": (
        "Взаимодействие с подключенными пользователями и телеметрия отключены",
        "Отключает взаимодействие с подключенными пользователями и телеметрию и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_pimindexmaintenancesvc_off": (
        "Контактные данные выключены",
        "Отключает контактные данные и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_devquerybroker_off": (
        "Брокер фонового обнаружения DevQuery отключен",
        "Отключает DevQuery Background Discovery Broker и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_diagsvc_off": (
        "Служба выполнения диагностики выключена",
        "Отключает службу выполнения диагностики и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_trkwks_off": (
        "Клиент отслеживания распределенных ссылок отключен",
        "Отключает клиент отслеживания распределенных ссылок и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_mapsbroker_off": (
        "Менеджер загруженных карт отключен",
        "Отключает диспетчер загруженных карт и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_efs_off": (
        "Шифрование файловой системы выключено",
        "Отключает шифрованную файловую систему и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_inventorysvc_off": (
        "Инвентаризация и оценка совместимости отключены",
        "Отключает инвентаризацию и оценку совместимости и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_wpcmonsvc_off": (
        "Родительский контроль выключен",
        "Отключает родительский контроль и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_semgrsvc_off": (
        "Платежи и NFC/SE Manager отключены",
        "Отключает платежи и NFC/SE Manager и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "toggle_printing_off": (
        "Печать выключена",
        "Отключает службу диспетчера очереди печати до тех пор, пока она не будет восстановлена.",
      ),
      "service_pcasvc_off": (
        "Служба помощника по совместимости программ выключена",
        "Отключает службу помощника по совместимости программ и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_troubleshootingsvc_off": (
        "Рекомендуемая служба устранения неполадок отключена",
        "Отключает рекомендуемую службу устранения неполадок и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_remoteregistry_off": (
        "Удаленный реестр отключен",
        "Отключает удаленный реестр и восстанавливает его предыдущее состояние запуска при возврате.",
      ),
      "service_retaildemo_off": (
        "Розничная демонстрационная услуга отключена",
        "Отключает Retail Demo Service и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_remoteaccess_off": (
        "Маршрутизация и удаленный доступ отключены",
        "Отключает маршрутизацию и удаленный доступ и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_shpamsvc_off": (
        "Диспетчер учетных записей общего компьютера выключен",
        "Отключает диспетчер учетных записей общего ПК и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_scdeviceenum_off": (
        "Перечисление устройств смарт-карт выключено",
        "Отключает перечисление устройств смарт-карт и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_scardsvr_off": (
        "Смарт-карта выключена",
        "Отключает смарт-карту и восстанавливает ее предыдущее состояние запуска при возврате.",
      ),
      "service_svsvc_off": (
        "Точечная верификация выключена",
        "Отключает Spot Verifier и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_lmhosts_off": (
        "TCP/IP NetBIOS Helper выключен",
        "Отключает TCP/IP NetBIOS Helper и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_messagingservice_off": (
        "Текстовые сообщения выключены",
        "Отключает обмен текстовыми сообщениями и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_dmwappushservice_off": (
        "Служба маршрутизации сообщений WAP Push отключена",
        "Отключает службу маршрутизации push-сообщений WAP и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_wersvc_off": (
        "Служба отчетов об ошибках Windows отключена",
        "Отключает службу отчетов об ошибках Windows и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_wecsvc_off": (
        "Сборщик событий Windows выключен.",
        "Отключает сборщик событий Windows и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_wisvc_off": (
        "Служба предварительной оценки Windows отключена",
        "Отключает службу Windows Insider и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_wmpnetworksvc_off": (
        "Сетевой доступ к проигрывателю Windows Media отключен.",
        "Отключает общий доступ к проигрывателю Windows Media и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_wpnservice_off": (
        "Системная служба push-уведомлений Windows отключена",
        "Отключает системную службу push-уведомлений Windows и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_xblauthmanager_off": (
        "Диспетчер аутентификации Xbox Live выключен",
        "Отключает диспетчер аутентификации Xbox Live и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_xblgamesave_off": (
        "Сохранение игры в Xbox Live отключено",
        "Отключает сохранение игры в Xbox Live и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "service_xboxnetapisvc_off": (
        "Сетевая служба Xbox Live отключена",
        "Отключает сетевую службу Xbox Live и восстанавливает точное предыдущее состояние запуска при возврате.",
      ),
      "refresh_account_local": (
        "Учетная запись локальная",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "refresh_autounattend": (
        "Автоавтономка",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "refresh_factory_reset": (
        "Сброс к заводским настройкам",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "refresh_network_driver": (
        "Сетевой драйвер",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "refresh_reinstall": (
        "Переустановить",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "restore_clipchamp_clipchamp": (
        "Восстановить Clipchamp",
        "Устанавливает Clipchamp из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_windowsalarms": (
        "Восстановить часы",
        "Устанавливает Clock из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_devhome": (
        "Восстановить домашнюю страницу разработчика",
        "Устанавливает Dev Home из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_windowsfeedbackhub": (
        "Восстановление центра отзывов",
        "Устанавливает Центр отзывов из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_family": (
        "Восстановить семейство Microsoft",
        "Устанавливает семейство Microsoft из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_windowsstore": (
        "Восстановить Магазин Microsoft",
        "Устанавливает Microsoft Store из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_todos": (
        "Восстановить Microsoft To Do",
        "Устанавливает Microsoft To Do из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_microsoftofficehub": (
        "Восстановить Office Hub",
        "Устанавливает Office Hub из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_onedrive": (
        "Восстановить OneDrive",
        "Устанавливает OneDrive из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_outlookforwindows": (
        "Восстановить Outlook (новый)",
        "Устанавливает Outlook (новый) из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_yourphone": (
        "Восстановить телефонную связь",
        "Устанавливает Phone Link из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_powerautomatedesktop": (
        "Автоматизация восстановления мощности",
        "Устанавливает Power Automate из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_quickassist": (
        "Восстановление быстрой помощи",
        "Устанавливает Quick Assist из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_stickynotes": (
        "Восстановить заметки",
        "Устанавливает Sticky Notes из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_gamingapp": (
        "Восстановить приложение Xbox",
        "Устанавливает приложение Xbox из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_xboxgamingoverlay": (
        "Восстановить игровую панель Xbox",
        "Устанавливает Xbox Game Bar из настроенных источников пакетов Windows.",
      ),
      "restore_microsoft_xboxidentityprovider": (
        "Восстановить поставщика удостоверений Xbox",
        "Устанавливает поставщика удостоверений Xbox из настроенных источников пакетов Windows.",
      ),
      "refresh_to_bios": ("В БИОС", "Интерактивный сценарий от Fr33thy."),
      "refresh_updates_drivers_block": (
        "Блокировка драйверов обновлений",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_activation_script": (
        "Активация (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_background_apps_script": (
        "Фоновые приложения (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_bitlocker": ("БитЛоккер", "Интерактивный сценарий от Fr33thy."),
      "setup_convert_home_to_pro": (
        "Превратить дом в профессионал",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_date_language_region_time": (
        "Дата Язык Регион Время",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_edge_settings_script": (
        "Настройки Edge (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_keys": ("Ключи", "Интерактивный сценарий от Fr33thy."),
      "setup_memory_compression_script": (
        "Сжатие памяти (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_startup_apps_7": (
        "Приложения для запуска (7)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_startup_apps_8": (
        "Стартап-приложения (8)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_store_settings_script": (
        "Настройки магазина (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "setup_updates_pause": (
        "Обновления Пауза",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "bcd_optimizations": (
        "Расширенная оптимизация загрузки",
        "Настройте BCD и путь загрузки для снижения накладных расходов.",
      ),
      "services_disable": (
        "Услуги диагностики",
        "Ограничьте активность диагностических услуг для экономичного профиля.",
      ),
      "tool_amdvbflash_download": (
        "Скачать AMDVBFlash",
        "Открывает загрузки TechPowerUp AMDVBFlash. ZapTweaks никогда не выбирает ПЗУ и не запускает команды прошивки.",
      ),
      "advanced_core_1_thread_1": (
        "Ядро 1 Поток 1",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_dep_script": (
        "Предотвращение выполнения данных (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_defender": ("Защитник", "Интерактивный сценарий от Fr33thy."),
      "advanced_driver_whql_secure_boot_bypass": (
        "Обход безопасной загрузки драйвера WHQL",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_file_download_security_warning": (
        "Предупреждение безопасности загрузки файла",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_firewall_script": (
        "Брандмауэр (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_hardware_composed_flip_script": (
        "Аппаратный составной независимый флип (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_hardware_legacy_flip_script": (
        "Аппаратное обеспечение Legacy Flip (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_keyboard_shortcuts": (
        "Сочетания клавиш",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_mmagent_features_script": (
        "Возможности MMAgent (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_mpo_script": (
        "MPO (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_nvidia_nvflash_download": (
        "Загрузка NVIDIA NVFlash",
        "Открывает загрузки TechPowerUp NVFlash. ZapTweaks никогда не выбирает ПЗУ и не запускает команды прошивки.",
      ),
      "advanced_priority": ("Приоритет", "Интерактивный сценарий от Fr33thy."),
      "advanced_rebar_force": (
        "Арматура Форс",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_scewin_gui_releases": (
        "Релизы SCEWIN-GUI",
        "Открывает выпуски SCEWIN-GUI, лицензированные MIT. Он редактирует файлы SCEWIN/AMISCE NVRAM; он не включает сам SCEWIN.",
      ),
      "advanced_smt_ht": ("СМТ ХТ", "Интерактивный сценарий от Fr33thy."),
      "advanced_services": ("Услуги", "Интерактивный сценарий от Fr33thy."),
      "advanced_spectre_meltdown_script": (
        "Spectre Meltdown (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_start_search_shell_mobsync": (
        "Начать поиск Shell Mobsync",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "advanced_ulps_script": (
        "ULPS (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "toggle_activity_history_off": (
        "История активности выключена",
        "Не позволяет Windows публиковать и загружать историю активности.",
      ),
      "privacy_consumer_content": (
        "Потребительский контент и автоматические предложения приложений",
        "Отключает рекомендации по запуску, предложения пользовательского контента и автоматическую отправку предустановленных приложений.",
      ),
      "privacy_copilot": (
        "Отключить второго пилота",
        "Отключает политики Copilot и удаляет текущую регистрацию пакета приложения Copilot.",
      ),
      "telemetry_disable": (
        "Отключить телеметрию",
        "Отключить каналы телеметрии и диагностики.",
      ),
      "privacy_gamebar": (
        "Игровая панель и наложение захвата",
        "Отключает захват игровой панели и наложение значений политики, связанных с ней.",
      ),
      "toggle_location_off": (
        "Местоположение выключено",
        "Отключает службы определения местоположения Windows с помощью политики.",
      ),
      "privacy_online_search_suggestions": (
        "Предложения по онлайн-поиску отключены",
        "Отключает веб-предложения в поиске Windows без отключения локального поиска.",
      ),
      "privacy_powershell_telemetry": (
        "Телеметрия PowerShell 7 отключена",
        "Отключает новые процессы PowerShell 7 от телеметрии приложений. Требуется перезагрузка.",
      ),
      "privacy_tracking": (
        "Конфиденциальность и отслеживание",
        "Уменьшите отслеживание рекламы и сигналы фоновой активности.",
      ),
      "privacy_widgets": (
        "Виджеты и лента новостей",
        "Отключает флаги политики виджетов и останавливает запуск процессов виджетов.",
      ),
      "privacy_safe_debloat": (
        "Предустановка безопасного раздувания",
        "Удаляет только выбранные раздутые приложения UWP, сохраняя при этом базовые компоненты Store и Xbox.",
      ),
      "tool_winsux_debloat": (
        "WinSux от Fr33hty",
        "Запускает команду удаленной разблокировки WinSux Fr33hty. Инвазивное действие без возврата в приложение.",
      ),
      "ui_background_apps_off": (
        "Фоновые приложения выключены",
        "Блокирует фоновое выполнение приложений с помощью политики AppPrivacy.",
      ),
      "toggle_center_taskbar_icons": (
        "Центральные значки панели задач",
        "Использует выравнивание значков панели задач по центру Windows 11.",
      ),
      "ui_context_menu_clean": (
        "Контекстное меню Очистить",
        "Включает классическое контекстное меню и удаляет выбранные ненужные записи оболочки.",
      ),
      "visual_effects": (
        "Отключить визуальные эффекты",
        "Уменьшите анимацию и визуальные накладные расходы.",
      ),
      "explorer_optimizations": (
        "Оптимизация проводника",
        "Настройте поведение и кеширование файлового проводника.",
      ),
      "ui_folder_discovery_off": (
        "Обнаружение типа папки выключено",
        "Не позволяет Проводнику автоматически определять шаблоны папок, что может ускорить работу больших мультимедийных папок.",
      ),
      "ui_hide_explorer_gallery": (
        "Скрыть галерею проводника",
        "Скрывает элемент навигации «Галерея» в проводнике.",
      ),
      "notifications_minimal": (
        "Минимальные уведомления",
        "Уменьшите прерывания всплывающих уведомлений и блокировки экрана.",
      ),
      "ui_pointer_precision_off": (
        "Точность указателя выключена",
        "Отключает точность указателя и устанавливает пороговые значения мыши в стиле 6/11.",
      ),
      "ui_start_taskbar_clean": (
        "Меню «Пуск» и очистка панели задач",
        "Скрывает виджеты/поиск/представление задач/чат и применяет выравнивание по левому краю + настройки просмотра списка.",
      ),
      "ui_sticky_keys_shortcut_off": (
        "Ярлык липких клавиш отключен",
        "Предотвращает открытие Sticky Keys при пятикратном нажатии клавиши Shift.",
      ),
      "ui_taskbar_end_task": (
        "Завершить задачу панели задач",
        "Добавляет задачу «Завершить» в контекстные меню приложений на панели задач в поддерживаемых сборках Windows 11.",
      ),
      "ui_dark_theme": (
        "Тема Черный",
        "Применяет темный профиль пользовательского интерфейса Windows и отключает эффекты прозрачности.",
      ),
      "ui_optimizations": (
        "Оптимизация пользовательского интерфейса",
        "Примените настройки панели задач и очистки оболочки.",
      ),
      "hardware_background_polling_rate_cap": (
        "Ограничение частоты фонового опроса",
        "Выкл. = фоновый опрос разблокирован. Revert восстанавливает поведение по умолчанию.",
      ),
      "tool_autoruns_folder": (
        "Автозапуск",
        "Пакет анализатора запуска и запланированных задач.",
      ),
      "hardware_background_polling_rate_cap_script": (
        "Ограничение частоты фонового опроса (вариант сценария)",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_fix_tools_battery_report": (
        "Отчет о батарее",
        "Диагностический скрипт Fix Tools.",
      ),
      "tool_beyond_performance_device_tweaker_discord": (
        "Твикер устройств Beyond Performance",
        "Открывает общедоступный канал Beyond Performance Discord, на котором распространяется Device Tweaker.",
      ),
      "tool_cpuz_folder": (
        "CPU-Z",
        "Утилита для получения информации о процессоре и памяти.",
      ),
      "tool_cru_folder": (
        "КРУ",
        "Утилита пользовательского разрешения для режимов отображения.",
      ),
      "installers_cru_sre": (
        "Установщик сценариев CRU SRE",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_fix_tools_change_name": (
        "Изменить имя",
        "Исправление вспомогательного сценария инструментов.",
      ),
      "tool_cleanmgrplus_folder": (
        "Очистка+",
        "Расширенная утилита очистки диска и управления временными файлами.",
      ),
      "hardware_controller_overclock_script": (
        "Разгон контроллера",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "hardware_controller_polling_rate_script": (
        "Тест скорости опроса контроллера",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_device_cleanup_folder": (
        "Очистка устройства",
        "Очищает записи фантомных/отсутствующих устройств в Windows.",
      ),
      "tool_dismpp_folder": (
        "Дизм++",
        "Расширенный набор инструментов DISM и операций обслуживания.",
      ),
      "tool_winslopr_releases": (
        "Скачать Winslopr",
        "Открывает официальную страницу выпусков Winslopr на GitHub в вашем браузере.",
      ),
      "tool_driver_store_explorer_folder": (
        "Обозреватель хранилища драйверов (RAPR)",
        "Проверяет и удаляет старые/неиспользуемые пакеты драйверов.",
      ),
      "tool_fix_tools_fastclean": (
        "FastClean",
        "Исправить скрипт очистки инструментов.",
      ),
      "tool_fix_tools_runner": (
        "Исправить инструменты запуска",
        "Запускает меню пакетного запуска Fix Tools.",
      ),
      "tool_fortnite_diagnostic_ping": (
        "Инструмент диагностики Fortnite от Alexanderthedad",
        "Запускает официальную команду удаленной диагностики для устранения неполадок с пингом Fortnite.",
      ),
      "tool_furmark_setup": (
        "Установщик FurMark",
        "Пакет установки стресс-тестирования графического процессора.",
      ),
      "tool_gpu_dword_manager": (
        "Менеджер DWORD графического процессора",
        "Утилита настройки реестра графического процессора DWORD.",
      ),
      "tool_gpuz": (
        "ГПУ-З",
        "Подробная диагностика графического процессора и датчиков.",
      ),
      "tool_gaming_net_diagnostic": (
        "Диагностика игровой сети",
        "Скрипт быстрой диагностики сети для игровых сессий.",
      ),
      "tool_hwinfo_folder": (
        "ХВИНФО",
        "Системные датчики и аппаратный пакет телеметрии.",
      ),
      "tool_import_disable_advanced_services_profile": (
        "Импортировать профиль отключения расширенных служб",
        "Импортирует профиль жесткого отключения расширенных служб из прилагаемого файла .reg от Sapphire.",
      ),
      "tool_import_minimal_services_profile": (
        "Импортировать профиль минимальных служб",
        "Импортирует минимальную политику запуска служб из прилагаемого REG-файла от Sapphire.",
      ),
      "tool_sysinternals_suite_winget": (
        "Установите пакет Sysinternals",
        "Устанавливает Microsoft Sysinternals Suite с Winget. Окно PowerShell остается открытым, поэтому вы можете прочитать окончательный вывод PATH/инструмента.",
      ),
      "tool_install_win11_debloat_raphire": (
        "Установить деблокировку Win11",
        "Запускает официальную удаленную команду Win11Debloat в видимом окне PowerShell с повышенными правами.",
      ),
      "tool_install_winhance": (
        "Установить Винханс",
        "Устанавливает Winhance вместе с Winget для общей настройки Windows и базовой оптимизации.",
      ),
      "installers_menu": (
        "Меню установщиков",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_winget_interactive_uninstaller": (
        "Интерактивный деинсталлятор приложений",
        "Перечисляет установленные приложения Winget в терминале, чтобы вы могли выбрать одно из них для удаления.",
      ),
      "tool_interrupt_affinity_policy": (
        "Инструмент политики сходства прерываний",
        "Утилита настройки привязки прерываний и политики IRQ.",
      ),
      "tool_interrupt_affinity_policy_ia64": (
        "Инструмент политики сходства прерываний (IA64)",
        "Сборка IA64 утилиты политики привязки прерываний.",
      ),
      "tool_interrupt_affinity_policy_x86": (
        "Инструмент политики сходства прерываний (x86)",
        "x86-сборка утилиты политики привязки прерываний.",
      ),
      "tool_msi_afterburner_setup": (
        "Установщик MSI Afterburner",
        "Установщик для разгона и мониторинга графического процессора.",
      ),
      "installers_msi_afterburner": (
        "Установщик сценариев MSI Afterburner",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_msi_util_folder": (
        "Утилита MSI v3",
        "Утилита политики прерываний, сигнализированных сообщениями.",
      ),
      "tool_more_clock_tool": (
        "Дополнительный инструмент «Часы»",
        "Утилита AMD для управления тактовой частотой/напряжением.",
      ),
      "installers_more_clock_tool": (
        "Дополнительный установщик скриптов Clock Tool",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_more_power_tool_setup": (
        "ПодробнееУстановщик PowerTool",
        "Установщик настройки таблицы мощности AMD.",
      ),
      "tool_mouse_flat_curve": (
        "Плоская кривая мыши",
        "Применяет настройки кривой ускорения плоской мыши.",
      ),
      "tool_mouse_movement_recorder": (
        "Регистратор движения мыши",
        "Проверяет эффективное поведение опроса мыши.",
      ),
      "hardware_mouse_polling_rate_test_script": (
        "Тест скорости опроса мыши",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_nvidia_profile_inspector_nip_profile": (
        "Настройки производительности NVIDIA (.nip)",
        "Профиль, ориентированный на производительность. Не используйте, если вам нужно визуальное качество.",
      ),
      "tool_nvidia_profile_inspector_folder": (
        "Инспектор профилей NVIDIA",
        "Расширенный редактор профилей NVIDIA.",
      ),
      "installers_nvidia_profile_inspector": (
        "Установщик сценариев NVIDIA Profile Inspector",
        "Интерактивный сценарий от Fr33thy.",
      ),
      "tool_fix_tools_permessi": (
        "Пермесси",
        "Скрипт восстановления разрешений Fix Tools.",
      ),
      "tool_polling_rate_tester_app": (
        "Приложение для проверки частоты опроса",
        "Специальная утилита проверки частоты опроса мыши.",
      ),
      "tool_controller_polling": (
        "Инструмент опроса",
        "Инструмент измерения частоты опроса контроллера.",
      ),
      "tool_power_settings_explorer": (
        "PowerSettingsExplorer",
        "Расширенный редактор настроек плана электропитания Windows.",
      ),
      "tool_prime95_folder": (
        "Прайм95",
        "Стресс-тест процессора и проверка стабильности.",
      ),
      "tool_queue_size_tuner": (
        "Тюнер размера очереди",
        "Утилита настройки очереди хранилища.",
      ),
      "tool_rammap_folder": (
        "RAMMap",
        "Утилита анализа физической памяти Microsoft Sysinternals.",
      ),
      "tool_rtl_utility": (
        "Утилита RTL",
        "Утилита Realtek и инструмент диагностики.",
      ),
      "tool_radeon_tuner_folder": (
        "Радеон тюнер",
        "Утилита настройки драйверов и профилей AMD Radeon.",
      ),
      "tool_fix_tools_reset_network": (
        "Сбросить сеть",
        "Fix Tools сценарий сброса сети.",
      ),
      "tool_fix_tools_ripristina_anteprime": (
        "Рипристина Антепрайм",
        "Скрипт восстановления кеша миниатюр Fix Tools.",
      ),
      "tool_ctt_winutil": (
        "Запустите CTT WinUtil.",
        "Открывает Chris Titus Tech WinUtil для выполнения распространенных задач по установке, восстановлению и базовой оптимизации Windows.",
      ),
      "tool_fix_tools_sfc_dism": (
        "SFC и DISM",
        "Инструменты исправления целостности и скрипт восстановления образа.",
      ),
      "tool_star_ethernet_analyzer_folder": (
        "Звездный Ethernet-анализатор",
        "Набор инструментов для диагностики Ethernet и джиттера.",
      ),
      "tool_star_ethernet_analyzer_start_bat": (
        "Программа запуска анализатора Star Ethernet",
        "Запускает встроенную пакетную программу запуска Star Ethernet Analyser.",
      ),
      "tool_star_ethernet_analyzer_script": (
        "Сценарий анализатора Star Ethernet",
        "Интерактивный вспомогательный скрипт для Star Ethernet Analyzer.",
      ),
      "tool_star_ethernet_analyzer_video": (
        "Видеоруководство по анализатору Star Ethernet",
        "Открывает прилагаемое видеоруководство с помощью приложения Windows по умолчанию.",
      ),
      "tool_tcp_optimizer_folder": (
        "TCP-оптимизатор",
        "Инструмент оптимизации и диагностики сетевого стека.",
      ),
      "tool_testmem5_folder": (
        "ТестМем5",
        "Утилита стресс-тестирования оперативной памяти.",
      ),
      "tool_usb_latency_analyzer_v2_marius_heier": (
        "Анализатор задержки USB V2 от Мариуса Хейера",
        "Запускает диагностический инструмент Мариуса Хейера в видимом окне PowerShell с повышенными правами. Это не применяет твики и предназначено для вывода консольной диагностики.",
      ),
      "tool_unpark_cpu": (
        "Разпарковать процессор",
        "Утилита для разпарковки ядра процессора.",
      ),
      "tool_vivetool_folder": (
        "ViVeTool",
        "Утилита управления флагами функций Windows.",
      ),
      "tool_winscript_batch": (
        "Пакетная утилита WinScript",
        "Запускает пакетные действия обслуживания WinScript.",
      ),
      "tool_hidusbf_folder": (
        "хидусбф",
        "Набор инструментов для разгона с опросом USB для HID-устройств.",
      ),
    },
    "zh": <String, (String, String)>{
      "shortcut_advanced_system_settings": ("高级系统设置", "表演、视觉效果和环境设置。"),
      "shortcut_bluetooth": ("蓝牙和设备", "配对设备、打印机和鼠标设置。"),
      "shortcut_computer_management": ("电脑管理", "系统工具的统一控制台。"),
      "shortcut_device_manager": ("设备管理器", "打开设备管理器。"),
      "shortcut_directx_diagnostic": ("DirectX 诊断", "GPU、DirectX 版本和音频诊断。"),
      "shortcut_disk_management": ("磁盘管理", "分区、卷和驱动器号。"),
      "shortcut_display": ("显示", "分辨率、缩放比例、HDR 和刷新率。"),
      "shortcut_environment_variables": ("环境变量", "系统和用户的PATH、TEMP等变量。"),
      "shortcut_event_viewer": ("事件查看器", "系统和应用程序日志。"),
      "shortcut_game_mode": ("游戏模式设置", "Windows 游戏模式设置。"),
      "shortcut_graphics_settings": ("图形设置", "每个应用程序的 GPU 首选项和 HAGS。"),
      "shortcut_hosts_file": ("主机文件", "在记事本中打开主机文件。"),
      "shortcut_installed_apps": ("已安装的应用程序", "卸载并修复已安装的应用程序。"),
      "shortcut_network": ("网络", "以太网、Wi-Fi、VPN 和代理设置。"),
      "shortcut_optional_features": ("可选功能", "管理 Windows 可选功能。"),
      "shortcut_performance_monitor": ("性能监视器", "实时计数器和数据集。"),
      "shortcut_personalization": ("个性化", "背景、颜色和锁屏设置。"),
      "shortcut_power_battery": ("电源和电池", "睡眠、屏幕超时和电池设置。"),
      "shortcut_privacy_security": ("隐私和安全", "隐私权限和 Windows 安全。"),
      "shortcut_registry_editor": ("注册表编辑器", "直接注册表访问。"),
      "shortcut_reliability_history": ("可靠性历史", "崩溃、故障和稳定性历史记录。"),
      "shortcut_resource_monitor": ("资源监控器", "CPU、内存、磁盘和网络活动。"),
      "shortcut_services": ("服务", "启动、停止和配置 Windows 服务。"),
      "shortcut_sound": ("声音", "输出、输入和音量设置。"),
      "shortcut_startup_folder": ("启动文件夹", "每用户启动应用程序。"),
      "shortcut_system_configuration": ("系统配置", "启动选项和启动服务。"),
      "shortcut_task_scheduler": ("任务调度程序", "计划任务和触发器。"),
      "shortcut_windows_features": ("Windows 功能", "打开或关闭 Windows 功能。"),
      "shortcut_windows_update": ("Windows更新", "检查并安装更新。"),
      "gaming_amd_gpu_extreme_profile": (
        "AMD GPU 极限配置文件",
        "禁用 AMD 热节流、Crash Defender、电源门控、时钟门控、ULPS、ASPM 和其他节能行为。仅桌面故障排除。",
      ),
      "gaming_amd_gpu_safe_profile": (
        "AMD GPU 安全配置文件",
        "应用可逆 AMD 驱动程序配置文件，而不禁用热保护、崩溃防护、时钟门控或电源门控。",
      ),
      "gpu_amd_optimizations": (
        "AMD GPU ULPS 故障排除",
        "禁用 AMD ULPS 进行故障排除；它不会禁用热保护或电源门控。",
      ),
      "cpu_amd_optimizations": ("AMD 锐龙优化", "应用 AMD 特定的功率和延迟调整。"),
      "gaming_amd_ulps_off": (
        "AMD ULPS 关闭",
        "在 AMD 显示类键上禁用 EnableUlps。对于延迟测试很有用。",
      ),
      "cpu_unparking": ("CPU核心解锁", "释放所有 CPU 核心以实现低延迟工作负载。"),
      "cpu_power_management": ("CPU电源管理", "禁用限制并优化调度程序行为。"),
      "gaming_mpo_off": ("禁用多平面叠加 (MPO)", "仅针对显示闪烁或卡顿进行故障排除的解决方法；需要重新启动。"),
      "gaming_extended_gpu_timeout": (
        "延长 GPU 超时",
        "设置 10 秒的 GPU 超时检测延迟，以解决不稳定的繁重 GPU 工作负载问题。",
      ),
      "gaming_legacy_flip_fse": (
        "全屏独家传统翻盖",
        "将 GameConfigStore 切换为面向 FSE 的行为以进行旧版全屏测试。",
      ),
      "game_mode": ("游戏模式开启", "启用 Windows 游戏模式，无需更改 Xbox 游戏栏或游戏 DVR。"),
      "gaming_composed_flip_immediate_mode": (
        "硬件组成独立翻转",
        "在图形调度程序中强制 ForceFlipTrueImmediateMode=1。",
      ),
      "cpu_intel_optimizations": ("英特尔CPU优化", "调整 Intel P 和 E 核心调度配置文件。"),
      "gpu_intel_optimizations": ("英特尔 GPU 优化", "应用英特尔图形堆栈性能调整。"),
      "gpu_nvidia_optimizations": ("NVIDIA 优化", "应用 NVIDIA 图形调度和延迟调整。"),
      "gaming_windowed_optimizations_on": (
        "针对窗口游戏的优化",
        "为兼容的窗口和无边框游戏启用 Windows 11 交换效果升级。",
      ),
      "ram_optimizations": ("内存优化", "调整内存管理器和缓存行为。"),
      "storage_optimizations": ("存储优化", "调整 NTFS、TRIM 和存储电源行为。"),
      "timer_latency": ("定时器和延迟", "调整 MMCSS 和计时器请求行为。"),
      "gaming_variable_refresh_rate_on": (
        "可变刷新率打开",
        "为兼容游戏启用 Windows 可变刷新率首选项。",
      ),
      "network_adapter_power_savings_wake_off": (
        "适配器省电和唤醒",
        "禁用物理网络适配器上的省电和唤醒功能，并提供精确的备份以进行恢复。",
      ),
      "network_delivery_optimization_off": (
        "交付优化 P2P 关闭",
        "停止 Windows 更新点对点上传和下载。",
      ),
      "device_power_savings_off": ("设备省电关闭", "禁用 WMI 设备节能。这会增加空闲功耗，适用于台式机。"),
      "network_ecn_disabled": ("禁用 ECN", "禁用显式拥塞通知以支持可预测的低延迟行为。"),
      "network_timestamps_disabled": (
        "禁用 TCP 时间戳",
        "禁用 TCP 时间戳以减少注重延迟的场景中的协议开销。",
      ),
      "network_rss_enabled": ("启用RSS", "启用接收端扩展以跨 CPU 内核分配数据包处理。"),
      "network_fast_udp_datagram_send": (
        "快速 UDP 数据报发送",
        "提高 UDP 工作负载的 AFD 数据报发送阈值。",
      ),
      "network_ipv4_only": ("仅 IPv4 绑定", "禁用非必要的适配器绑定并在所有适配器上保持 IPv4 启用。"),
      "network_llmnr_off": ("LLMNR 关闭", "禁用旧版本地多播名称解析。"),
      "network_low_latency_bandwidth_profile": (
        "低延迟网络配置文件",
        "应用激进的低延迟网络配置文件，这可能会降低吞吐量和整体带宽效率。",
      ),
      "network_mmagent_features_off": (
        "MMAgent 功能关闭",
        "禁用 MMAgent 预取/预启动/OperationAPI 功能并将 Prefetcher 设置为 0。",
      ),
      "network_optimizations": ("网络优化", "调整 TCP 配置文件并消除多媒体限制。"),
      "network_throttling_index_off": (
        "网络节流指数关闭",
        "将 NetworkThrotdlingIndex 设置为 0xFFFFFFFF 以删除多媒体限制。",
      ),
      "network_prefer_ipv4": (
        "优先选择 IPv4 而不是 IPv6",
        "保持 IPv6 启用，但优先考虑 IPv4。无法与仅 IPv4 绑定结合使用。",
      ),
      "network_itr_interactive_config": (
        "网卡ITR交互配置",
        "打开提升的交互式工具，为支持的 Realtek/Intel/Killer 适配器配置 NIC 中断调节率 (ITR)。",
      ),
      "power_amd_preferred_cores": (
        "AMD 首选核心",
        "启用 AMD Precision Boost - 让 CPU 优先处理单线程工作负载的最强核心。仅限 AMD CPU。",
      ),
      "power_cpu_core_parking_off": (
        "CPU 核心停车关闭",
        "取消隐藏活动计划核心停车最小/最大核心并将其设置为 100%。",
      ),
      "power_disable_cstates": (
        "禁用 CPU C 状态",
        "限制 CPU 睡眠状态以获得最大响应能力和即时提升。仅限台式机 - 显着增加温度和空闲功耗。",
      ),
      "power_cpu_idle_demote_promote": (
        "禁用 CPU 空闲降级/升级",
        "将空闲降级/升级阈值设置为 100%，以减少 CPU 进入/退出空闲状态所花费的时间。较低的延迟但较高的电力成本。",
      ),
      "power_disable_dynamic_tick": (
        "禁用动态刻度",
        "运行 bcdedit /set disabledynamictick yes - 使系统计时器更加一致，减少游戏和低延迟应用程序中的微卡顿。 2026 年在 Windows 11 上仍然有效。",
      ),
      "power_fast_startup_hibernate_off": (
        "快速启动和休眠关闭",
        "禁用休眠和快速启动，以实现更低的延迟和更干净的关闭行为。",
      ),
      "power_global_timer_resolution": (
        "全局计时器解析请求",
        "设置 GlobalTimerResolutionRequests=1 - 在 Windows 11 上恢复系统范围的高分辨率计时器行为。对于依赖 1 毫秒或 0.5 毫秒计时器精度的应用/游戏至关重要。",
      ),
      "power_hardware_pstates_intel": (
        "英特尔硬件 P 状态 (HWP)",
        "配置 Intel Speed Shift/硬件 P 状态以实现最大性能偏差。仅限英特尔 CPU。",
      ),
      "power_max_processor_state": (
        "最大处理器状态 (100%)",
        "将最大 CPU 频率设置为 100%，以防止在负载下大幅降频。",
      ),
      "power_throttling_off": ("功率节流关闭", "禁用 Windows 电源限制，以在负载下实现更一致的 CPU 调度。"),
      "power_processor_boost_mode": (
        "处理器性能提升模式",
        "启用主动 CPU 加速模式 (Intel/AMD)。改进多线程工作负载的持续升压时钟。推荐用于冷却良好的台式机。",
      ),
      "power_processor_time_check_interval": (
        "处理器时间检查间隔（5ms）",
        "将 CPU 调度程序检查间隔从 15 毫秒减少到 5 毫秒，以实现更快的频率缩放响应。",
      ),
      "power_system_responsiveness_registry": (
        "系统响应能力 (10)",
        "将 SystemResponsiveness 设置为 10（默认为 20）- 为前台应用程序提供比系统服务更多的 CPU 时间。改善游戏和多任务处理的感觉。",
      ),
      "power_tsc_sync_policy": (
        "TSC 同步策略（增强）",
        "将 tscsyncpolicy 设置为增强 - 改进多核系统上的 CPU 核心计时器同步。风险低，特别适用于较旧的多插槽系统。",
      ),
      "power_ultimate_performance_plan": ("终极性能电源计划", "导入并激活终极性能。恢复切换回平衡。"),
      "power_win32_priority_separation": (
        "Win32 优先级分离（游戏）",
        "将 Win32PrioritySeparation 设置为 26（十六进制 0x1a） - 优先考虑前台应用程序 CPU 时间。经典游戏调整可降低输入延迟。",
      ),
      "graphics_amd_settings": ("AMD 设置", "Fr33thy 的互动脚本。"),
      "graphics_cpp_runtime": ("C++ 运行时", "Fr33thy 的互动脚本。"),
      "graphics_directx": ("DirectX运行时", "Fr33thy 的互动脚本。"),
      "graphics_driver_clean": ("驱动清洁", "Fr33thy 的互动脚本。"),
      "graphics_driver_install_debloat_settings": (
        "驱动程序安装膨胀和设置",
        "Fr33thy 的互动脚本。",
      ),
      "graphics_driver_install_latest": ("驱动程序安装最新", "Fr33thy 的互动脚本。"),
      "graphics_hags_windowed": ("HAGS 窗口式", "Fr33thy 的互动脚本。"),
      "graphics_hdcp": ("HDCP", "Fr33thy 的互动脚本。"),
      "graphics_intel_settings": ("英特尔设置", "Fr33thy 的互动脚本。"),
      "graphics_msi_mode_script": ("MSI 模式（脚本变体）", "Fr33thy 的互动脚本。"),
      "graphics_nvidia_settings": ("NVIDIA 设置", "Fr33thy 的互动脚本。"),
      "graphics_p0_state": ("P0状态", "Fr33thy 的互动脚本。"),
      "graphics_resolution_refresh_rate": ("分辨率刷新率", "Fr33thy 的互动脚本。"),
      "windows_auto_reboot_after_bsod_off": (
        "BSOD 关闭后自动重新启动",
        "在屏幕上保留停止代码，而不是在崩溃后自动重新启动。",
      ),
      "toggle_automatic_driver_updates_off": (
        "自动驱动程序更新关闭",
        "阻止 Windows Update 自动安装驱动程序更新。",
      ),
      "windows_automatic_maintenance_off": ("自动维护关闭", "禁用计划的自动维护，同时保留手动维护工具。"),
      "windows_ntfs_last_access_updates_off": (
        "NTFS 上次访问更新关闭",
        "阻止 NTFS 在每次读取文件时更新时间戳。",
      ),
      "toggle_scheduled_defrag_off": ("计划碎片整理/修剪关闭", "禁用计划的优化驱动器任务；手动优化仍然可用。"),
      "toggle_storage_sense_off": ("存储感应关闭", "禁用自动临时文件清理。"),
      "system_responsiveness": ("系统响应能力", "减少 UI 延迟和任务超时值。"),
      "windows_update": ("Windows 更新行为", "调整以游戏为中心的工作流程的更新行为。"),
      "windows_autoruns_startup_tasks_apps_check": (
        "自动运行启动任务和应用程序检查",
        "Fr33thy 的互动脚本。",
      ),
      "windows_bloatware_script": ("英国媒体报道软件（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_bloatware_legacy_apps_check_script": (
        "Bloatware 旧版应用程序检查（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "windows_bloatware_legacy_features_check_script": (
        "Bloatware 遗留功能检查（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "windows_bloatware_taskmgr_check_script": (
        "Bloatware TaskMgr 检查（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "windows_bloatware_uwp_apps_check_script": (
        "Bloatware UWP 应用检查（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "windows_bloatware_uwp_features_check_script": (
        "Bloatware UWP 功能检查（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "windows_cleanup": ("清理", "Fr33thy 的互动脚本。"),
      "windows_context_menu_script": ("上下文菜单（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_control_panel_settings_script": (
        "控制面板设置（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "windows_copilot_script": ("副驾驶（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_core_isolation_script": ("核心隔离（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_defender_optimize": ("后卫优化", "Fr33thy 的互动脚本。"),
      "windows_device_manager_power_savings_wake": (
        "设备管理器节能和唤醒",
        "Fr33thy 的互动脚本。",
      ),
      "windows_edge_webview_script": ("Edge 和 WebView（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_gamebar_script": ("游戏栏（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_gamemode": ("游戏模式", "Fr33thy 的互动脚本。"),
      "windows_loudness_eq": ("响度均衡器", "Fr33thy 的互动脚本。"),
      "windows_nvme_faster_driver": ("NVME 更快的驱动程序", "Fr33thy 的互动脚本。"),
      "windows_network_adapter_power_savings_script": (
        "网络适配器节能和唤醒（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "windows_network_ipv4_only_script": ("仅网络 IPv4（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_notepad_settings": ("记事本设置", "Fr33thy 的互动脚本。"),
      "windows_pointer_precision_script": ("指针精度（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_power_plan_script": ("电源计划（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_restore_point": ("还原点", "Fr33thy 的互动脚本。"),
      "windows_scaling": ("缩放", "Fr33thy 的互动脚本。"),
      "windows_signout_lockscreen_wallpaper_black": (
        "退出锁屏壁纸黑色",
        "Fr33thy 的互动脚本。",
      ),
      "windows_sound": ("声音", "Fr33thy 的互动脚本。"),
      "windows_start_menu_layout_script": ("开始菜单布局（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_start_menu_shortcuts_script": (
        "开始菜单快捷方式（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "windows_start_menu_taskbar_script": ("开始菜单任务栏（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_theme_black_script": ("主题黑色（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_timer_resolution_script": ("计时器分辨率（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_uac_script": ("UAC（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_user_account_pictures_black": ("用户帐户图片黑色", "Fr33thy 的互动脚本。"),
      "windows_widgets_script": ("小部件（脚本变体）", "Fr33thy 的互动脚本。"),
      "windows_write_cache_buffer_flushing": ("写入缓存缓冲区刷新", "Fr33thy 的互动脚本。"),
      "checks_core_isolation_off": (
        "核心隔离内存完整性关闭",
        "通过 DeviceGuard 注册表方案禁用 HVCI 内存完整性。",
      ),
      "checks_dep_off": (
        "数据执行保护关闭",
        "将 bcdedit nx 设置为 AlwaysOff。恢复会删除 nx 覆盖（Windows 默认值）。",
      ),
      "checks_firewall_off": ("防火墙关闭", "禁用公共和标准防火墙配置文件。恢复恢复默认启用状态。"),
      "checks_memory_compression_off": (
        "内存压缩关闭",
        "在 MMAgent 中禁用内存压缩，以降低突发负载下的 CPU 开销。",
      ),
      "checks_smart_screen_off": ("智能屏幕关闭", "禁用 Windows 信誉检查。仅用于受控测试。"),
      "checks_spectre_meltdown_off": (
        "幽灵/崩溃缓解措施关闭",
        "将FeatureSettingsOverride 和FeatureSettingsOverrideMask 设置为3。",
      ),
      "checks_uac_off": ("UAC 关闭", "将用户帐户控制设置为禁用。需要重新启动才能完全生效。"),
      "checks_vbs_off": ("基于虚拟化的安全性关闭", "禁用 VBS 策略。这会削弱 Windows 隔离保护并需要重新启动。"),
      "checks_vulnerable_driver_blocklist_off": (
        "易受攻击的驱动程序阻止列表已关闭",
        "禁用 Microsoft 的易受攻击的驱动程序阻止列表。这会削弱内核保护并需要重新启动。",
      ),
      "check_bios_settings": ("BIOS 设置指南", "Fr33thy 的交互式 BIOS 指导脚本。"),
      "check_bios_update": ("BIOS 更新搜索", "打开 Fr33thy 的主板搜索脚本。"),
      "check_cpu_test": ("CPU测试", "Fr33thy 的交互式压力测试脚本。"),
      "check_gpu_check": ("GPU检查", "Fr33thy 的交互式诊断脚本。"),
      "check_gpu_test": ("GPU测试", "Fr33thy 的交互式压力测试脚本。"),
      "check_hw_info": ("硬件信息", "Fr33thy 的交互式硬件信息脚本。"),
      "check_ram_check": ("内存检查", "Fr33thy 的交互式诊断脚本。"),
      "check_ram_test": ("内存测试", "Fr33thy 的交互式压力测试脚本。"),
      "check_space_check": ("空间检查", "Fr33thy 的交互式诊断脚本。"),
      "service_diagtrack_off": ("互联用户体验和遥测关闭", "禁用连接的用户体验和遥测，并在恢复时恢复其之前的启动状态。"),
      "service_pimindexmaintenancesvc_off": (
        "联系数据关闭",
        "禁用联系人数据并在恢复时恢复其之前的启动状态。",
      ),
      "service_devquerybroker_off": (
        "DevQuery 后台发现代理关闭",
        "禁用 DevQuery 后台发现代理并在恢复时恢复其之前的启动状态。",
      ),
      "service_diagsvc_off": ("诊断执行服务关闭", "禁用诊断执行服务并在恢复时恢复其之前的启动状态。"),
      "service_trkwks_off": ("分布式链接跟踪客户端关闭", "禁用分布式链接跟踪客户端并在恢复时恢复其之前的启动状态。"),
      "service_mapsbroker_off": ("下载的地图管理器关闭", "禁用“下载的地图管理器”并在恢复时恢复其之前的启动状态。"),
      "service_efs_off": ("加密文件系统关闭", "禁用加密文件系统并在恢复时恢复其之前的启动状态。"),
      "service_inventorysvc_off": ("库存和兼容性评估关闭", "禁用库存和兼容性评估并在恢复时恢复其之前的启动状态。"),
      "service_wpcmonsvc_off": ("家长控制关闭", "禁用家长控制并在恢复时恢复其之前的启动状态。"),
      "service_semgrsvc_off": (
        "支付和 NFC/SE 管理器关闭",
        "禁用支付和 NFC/SE 管理器并在恢复时恢复其之前的启动状态。",
      ),
      "toggle_printing_off": ("打印关闭", "禁用打印后台处理程序服务，直至恢复。"),
      "service_pcasvc_off": ("程序兼容性助手服务关闭", "禁用程序兼容性助手服务并在恢复时恢复其之前的启动状态。"),
      "service_troubleshootingsvc_off": (
        "建议的故障排除服务关闭",
        "禁用推荐的故障排除服务并在恢复时恢复其之前的启动状态。",
      ),
      "service_remoteregistry_off": ("远程注册表关闭", "禁用远程注册表并在恢复时恢复其之前的启动状态。"),
      "service_retaildemo_off": (
        "零售演示服务关闭",
        "禁用 Retail Demo Service 并在恢复时恢复其之前的启动状态。",
      ),
      "service_remoteaccess_off": ("路由和远程访问关闭", "禁用路由和远程访问并在恢复时恢复其之前的启动状态。"),
      "service_shpamsvc_off": ("共享 PC 客户经理关闭", "禁用共享 PC 帐户管理器并在恢复时恢复其之前的启动状态。"),
      "service_scdeviceenum_off": ("智能卡设备枚举关闭", "禁用智能卡设备枚举并在恢复时恢复其之前的启动状态。"),
      "service_scardsvr_off": ("智能卡关闭", "禁用智能卡并在恢复时恢复其之前的启动状态。"),
      "service_svsvc_off": ("现场验证器关闭", "禁用 Spot Verifier 并在恢复时恢复其之前的启动状态。"),
      "service_lmhosts_off": (
        "TCP/IP NetBIOS 帮助程序关闭",
        "禁用 TCP/IP NetBIOS Helper 并在恢复时恢复其之前的启动状态。",
      ),
      "service_messagingservice_off": ("短信关闭", "禁用短信并在恢复时恢复其之前的启动状态。"),
      "service_dmwappushservice_off": (
        "WAP 推送消息路由服务关闭",
        "禁用 WAP 推送消息路由服务并在恢复时恢复其之前的启动状态。",
      ),
      "service_wersvc_off": (
        "Windows 错误报告服务关闭",
        "禁用 Windows 错误报告服务并在恢复时恢复其之前的启动状态。",
      ),
      "service_wecsvc_off": (
        "Windows 事件收集器关闭",
        "禁用 Windows 事件收集器并在恢复时恢复其之前的启动状态。",
      ),
      "service_wisvc_off": (
        "Windows Insider 服务关闭",
        "禁用 Windows Insider 服务并在恢复时恢复其之前的启动状态。",
      ),
      "service_wmpnetworksvc_off": (
        "Windows Media Player 网络共享关闭",
        "禁用 Windows Media Player 网络共享并在恢复时恢复其之前的启动状态。",
      ),
      "service_wpnservice_off": (
        "Windows 推送通知系统服务关闭",
        "禁用 Windows 推送通知系统服务并在恢复时恢复其之前的启动状态。",
      ),
      "service_xblauthmanager_off": (
        "Xbox Live 身份验证管理器关闭",
        "禁用 Xbox Live Auth Manager 并在恢复时恢复其之前的启动状态。",
      ),
      "service_xblgamesave_off": (
        "Xbox Live 游戏保存关闭",
        "禁用 Xbox Live 游戏保存并在恢复时恢复其之前的启动状态。",
      ),
      "service_xboxnetapisvc_off": (
        "Xbox Live 网络服务关闭",
        "禁用 Xbox Live 网络服务并在恢复时恢复其之前的启动状态。",
      ),
      "refresh_account_local": ("本地账户", "Fr33thy 的互动脚本。"),
      "refresh_autounattend": ("自动无人值守", "Fr33thy 的互动脚本。"),
      "refresh_factory_reset": ("恢复出厂设置", "Fr33thy 的互动脚本。"),
      "refresh_network_driver": ("网络驱动程序", "Fr33thy 的互动脚本。"),
      "refresh_reinstall": ("重新安装", "Fr33thy 的互动脚本。"),
      "restore_clipchamp_clipchamp": (
        "恢复 Clipchamp",
        "从配置的 Windows 包源安装 Clipchamp。",
      ),
      "restore_microsoft_windowsalarms": ("恢复时钟", "从配置的 Windows 包源安装时钟。"),
      "restore_microsoft_devhome": ("恢复开发主页", "从配置的 Windows 包源安装 Dev Home。"),
      "restore_microsoft_windowsfeedbackhub": (
        "恢复反馈中心",
        "从配置的 Windows 包源安装反馈中心。",
      ),
      "restore_microsoft_family": (
        "恢复微软家庭",
        "从配置的 Windows 软件包源安装 Microsoft 系列。",
      ),
      "restore_microsoft_windowsstore": (
        "恢复微软商店",
        "从配置的 Windows 包源安装 Microsoft Store。",
      ),
      "restore_microsoft_todos": (
        "恢复微软待办事项",
        "从配置的 Windows 包源安装 Microsoft To Do。",
      ),
      "restore_microsoft_microsoftofficehub": (
        "恢复 Office 中心",
        "从配置的 Windows 包源安装 Office Hub。",
      ),
      "restore_microsoft_onedrive": (
        "恢复 OneDrive",
        "从配置的 Windows 包源安装 OneDrive。",
      ),
      "restore_microsoft_outlookforwindows": (
        "恢复 Outlook（新）",
        "从配置的 Windows 包源安装 Outlook（新）。",
      ),
      "restore_microsoft_yourphone": (
        "恢复电话链接",
        "从配置的 Windows 软件包源安装 Phone Link。",
      ),
      "restore_microsoft_powerautomatedesktop": (
        "自动恢复电源",
        "从配置的 Windows 包源安装 Power Automate。",
      ),
      "restore_microsoft_quickassist": (
        "恢复快速协助",
        "从配置的 Windows 软件包源安装 Quick Assist。",
      ),
      "restore_microsoft_stickynotes": ("恢复便笺", "从配置的 Windows 软件包源安装粘滞便笺。"),
      "restore_microsoft_gamingapp": (
        "恢复 Xbox 应用程序",
        "从配置的 Windows 包源安装 Xbox 应用程序。",
      ),
      "restore_microsoft_xboxgamingoverlay": (
        "恢复 Xbox 游戏栏",
        "从配置的 Windows 包源安装 Xbox Game Bar。",
      ),
      "restore_microsoft_xboxidentityprovider": (
        "恢复 Xbox 身份提供商",
        "从配置的 Windows 包源安装 Xbox 身份提供程序。",
      ),
      "refresh_to_bios": ("至BIOS", "Fr33thy 的互动脚本。"),
      "refresh_updates_drivers_block": ("更新驱动程序块", "Fr33thy 的互动脚本。"),
      "setup_activation_script": ("激活（脚本变体）", "Fr33thy 的互动脚本。"),
      "setup_background_apps_script": ("后台应用程序（脚本变体）", "Fr33thy 的互动脚本。"),
      "setup_bitlocker": ("比特锁", "Fr33thy 的互动脚本。"),
      "setup_convert_home_to_pro": ("将家庭版转换为专业版", "Fr33thy 的互动脚本。"),
      "setup_date_language_region_time": ("日期 语言 地区 时间", "Fr33thy 的互动脚本。"),
      "setup_edge_settings_script": ("边缘设置（脚本变体）", "Fr33thy 的互动脚本。"),
      "setup_keys": ("按键", "Fr33thy 的互动脚本。"),
      "setup_memory_compression_script": ("内存压缩（脚本变体）", "Fr33thy 的互动脚本。"),
      "setup_startup_apps_7": ("启动应用程序 (7)", "Fr33thy 的互动脚本。"),
      "setup_startup_apps_8": ("启动应用程序 (8)", "Fr33thy 的互动脚本。"),
      "setup_store_settings_script": ("商店设置（脚本变体）", "Fr33thy 的互动脚本。"),
      "setup_updates_pause": ("更新暂停", "Fr33thy 的互动脚本。"),
      "bcd_optimizations": ("高级启动优化", "调整 BCD 和引导路径以减少开销。"),
      "services_disable": ("诊断服务", "限制诊断服务活动以实现精益概况。"),
      "tool_amdvbflash_download": (
        "AMDVBFlash下载",
        "打开 TechPowerUp AMDVBFlash 下载。 ZapTweaks 从不选择 ROM 或运行闪存命令。",
      ),
      "advanced_core_1_thread_1": ("核心 1 线程 1", "Fr33thy 的互动脚本。"),
      "advanced_dep_script": ("数据执行预防（脚本变体）", "Fr33thy 的互动脚本。"),
      "advanced_defender": ("后卫", "Fr33thy 的互动脚本。"),
      "advanced_driver_whql_secure_boot_bypass": (
        "驱动程序 WHQL 安全启动绕过",
        "Fr33thy 的互动脚本。",
      ),
      "advanced_file_download_security_warning": ("文件下载安全警告", "Fr33thy 的互动脚本。"),
      "advanced_firewall_script": ("防火墙（脚本变体）", "Fr33thy 的互动脚本。"),
      "advanced_hardware_composed_flip_script": (
        "硬件组成的独立翻转（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "advanced_hardware_legacy_flip_script": (
        "硬件旧版翻转（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "advanced_keyboard_shortcuts": ("键盘快捷键", "Fr33thy 的互动脚本。"),
      "advanced_mmagent_features_script": (
        "MMAgent 功能（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "advanced_mpo_script": ("MPO（脚本变体）", "Fr33thy 的互动脚本。"),
      "tool_nvidia_nvflash_download": (
        "NVIDIA NVFlash 下载",
        "打开 TechPowerUp NVFlash 下载。 ZapTweaks 从不选择 ROM 或运行闪存命令。",
      ),
      "advanced_priority": ("优先级", "Fr33thy 的互动脚本。"),
      "advanced_rebar_force": ("钢筋力", "Fr33thy 的互动脚本。"),
      "tool_scewin_gui_releases": (
        "SCEWIN-GUI 版本",
        "打开 MIT 许可的 SCEWIN-GUI 版本。它编辑SCEWIN/AMISCE NVRAM文件；它不包括 SCEWIN 本身。",
      ),
      "advanced_smt_ht": ("表面贴装技术", "Fr33thy 的互动脚本。"),
      "advanced_services": ("服务", "Fr33thy 的互动脚本。"),
      "advanced_spectre_meltdown_script": ("幽灵崩溃（脚本变体）", "Fr33thy 的互动脚本。"),
      "advanced_start_search_shell_mobsync": (
        "开始搜索 Shell Mobsync",
        "Fr33thy 的互动脚本。",
      ),
      "advanced_ulps_script": ("ULPS（脚本变体）", "Fr33thy 的互动脚本。"),
      "toggle_activity_history_off": ("活动历史记录关闭", "阻止 Windows 发布和上传活动历史记录。"),
      "privacy_consumer_content": (
        "消费者内容和自动应用程序建议",
        "禁用“开始”推荐、消费者内容建议和静默预装应用程序推送。",
      ),
      "privacy_copilot": ("副驾驶禁用", "禁用 Copilot 策略并删除当前的 Copilot 应用程序包注册。"),
      "telemetry_disable": ("禁用遥测", "禁用遥测和诊断通道。"),
      "privacy_gamebar": ("游戏栏和捕获叠加", "禁用游戏栏捕获和覆盖相关策略值。"),
      "toggle_location_off": ("位置关闭", "通过策略禁用 Windows 位置服务。"),
      "privacy_online_search_suggestions": (
        "在线搜索建议关闭",
        "在 Windows 搜索中禁用网络支持的建议，而不禁用本地搜索。",
      ),
      "privacy_powershell_telemetry": (
        "PowerShell 7 遥测关闭",
        "选择将新的 PowerShell 7 进程排除在应用程序遥测之外。需要重新启动。",
      ),
      "privacy_tracking": ("隐私和跟踪", "减少广告跟踪和后台活动信号。"),
      "privacy_widgets": ("小部件和新闻源", "禁用小部件策略标志并停止运行小部件进程。"),
      "privacy_safe_debloat": (
        "安全消胀预设",
        "仅删除选定的 UWP 膨胀应用程序，同时保留商店和 Xbox 基础组件。",
      ),
      "tool_winsux_debloat": (
        "Fr33hty 的 WinSux",
        "运行 Fr33hty 的远程 WinSux debloat 命令。侵入性操作，没有应用内恢复。",
      ),
      "ui_background_apps_off": ("后台应用程序关闭", "通过 AppPrivacy 策略阻止后台应用程序执行。"),
      "toggle_center_taskbar_icons": ("中心任务栏图标", "使用 Windows 11 居中任务栏图标对齐方式。"),
      "ui_context_menu_clean": ("上下文菜单干净", "启用经典上下文菜单并删除选定的 shell 混乱条目。"),
      "visual_effects": ("禁用视觉效果", "减少动画和视觉开销。"),
      "explorer_optimizations": ("资源管理器优化", "调整文件浏览器行为和缓存。"),
      "ui_folder_discovery_off": (
        "文件夹类型发现关闭",
        "防止资源管理器自动检测文件夹模板，这可以加快大型媒体文件夹的速度。",
      ),
      "ui_hide_explorer_gallery": ("隐藏文件资源管理器库", "从文件资源管理器中隐藏图库导航项。"),
      "notifications_minimal": ("最少的通知", "减少吐司和锁屏干扰。"),
      "ui_pointer_precision_off": ("指针精度关闭", "禁用指针精度并设置 6/11 样式鼠标阈值。"),
      "ui_start_taskbar_clean": (
        "开始菜单和任务栏清理",
        "隐藏小部件/搜索/任务视图/聊天并应用左对齐+列表视图首选项。",
      ),
      "ui_sticky_keys_shortcut_off": ("粘滞键快捷键关闭", "防止 Shift 五次快捷键打开粘滞键。"),
      "ui_taskbar_end_task": (
        "任务栏结束任务",
        "在受支持的 Windows 11 版本上将结束任务添加到任务栏应用程序上下文菜单。",
      ),
      "ui_dark_theme": ("主题黑色", "应用深色 Windows UI 配置文件并禁用透明效果。"),
      "ui_optimizations": ("用户界面优化", "应用任务栏和外壳清理设置。"),
      "hardware_background_polling_rate_cap": (
        "后台轮询率上限",
        "关闭 = 解锁后台轮询。恢复恢复默认行为。",
      ),
      "tool_autoruns_folder": ("自动运行", "启动和计划任务分析器套件。"),
      "hardware_background_polling_rate_cap_script": (
        "后台轮询率上限（脚本变体）",
        "Fr33thy 的互动脚本。",
      ),
      "tool_fix_tools_battery_report": ("电池报告", "修复工具诊断脚本。"),
      "tool_beyond_performance_device_tweaker_discord": (
        "超越性能设备调整器",
        "打开分发 Device Tweaker 的公共 Beyond Performance Discord 频道。",
      ),
      "tool_cpuz_folder": ("CPU-Z", "CPU 和内存信息实用程序。"),
      "tool_cru_folder": ("克鲁格鲁", "用于显示模式的自定义分辨率实用程序。"),
      "installers_cru_sre": ("CRU SRE 脚本安装程序", "Fr33thy 的互动脚本。"),
      "tool_fix_tools_change_name": ("更改姓名", "修复工具帮助程序脚本。"),
      "tool_cleanmgrplus_folder": ("清洁管理器+", "扩展磁盘清理和临时文件管理实用程序。"),
      "hardware_controller_overclock_script": ("控制器超频", "Fr33thy 的互动脚本。"),
      "hardware_controller_polling_rate_script": ("控制器轮询率测试", "Fr33thy 的互动脚本。"),
      "tool_device_cleanup_folder": ("设备清理", "从 Windows 中清除虚拟/不存在的设备条目。"),
      "tool_dismpp_folder": ("忧郁++", "高级 DISM 和维修操作工具包。"),
      "tool_winslopr_releases": (
        "下载Winslopr",
        "在浏览器中打开 GitHub 上的官方 Winslopr 发布页面。",
      ),
      "tool_driver_store_explorer_folder": (
        "驱动程序存储资源管理器 (RAPR)",
        "检查并修剪旧的/未使用的驱动程序包。",
      ),
      "tool_fix_tools_fastclean": ("快速清洁", "修复工具清理脚本。"),
      "tool_fix_tools_runner": ("修复工具启动器", "运行“修复工具”批处理启动器菜单。"),
      "tool_fortnite_diagnostic_ping": (
        "Alexanderthedad 的 Fortnite 诊断 Ping 工具",
        "运行官方远程诊断命令以进行 Fortnite ping 故障排除。",
      ),
      "tool_furmark_setup": ("FurMark 安装程序", "GPU 压力测试安装程序包。"),
      "tool_gpu_dword_manager": ("GPU 双字管理器", "GPU 注册表 DWORD 调整实用程序。"),
      "tool_gpuz": ("GPU-Z", "详细的 GPU 诊断和传感器。"),
      "tool_gaming_net_diagnostic": ("游戏网络诊断", "用于游戏会话的快速网络诊断脚本。"),
      "tool_hwinfo_folder": ("HWiNFO", "系统传感器和硬件遥测套件。"),
      "tool_import_disable_advanced_services_profile": (
        "导入禁用高级服务配置文件",
        "从 Sapphire 捆绑的 .reg 文件导入高级服务硬禁用配置文件。",
      ),
      "tool_import_minimal_services_profile": (
        "导入最小服务配置文件",
        "从 Sapphire 捆绑的 .reg 文件中导入最小服务启动策略。",
      ),
      "tool_sysinternals_suite_winget": (
        "安装 Sysinternals 套件",
        "使用 Winget 安装 Microsoft Sysinternals Suite。 PowerShell 窗口保持打开状态，以便您可以读取最终的 PATH/工具输出。",
      ),
      "tool_install_win11_debloat_raphire": (
        "安装Win11 膨胀",
        "在可见的提升的 PowerShell 窗口中运行官方 Win11Debloat 远程命令。",
      ),
      "tool_install_winhance": (
        "安装Winhance",
        "安装 Winhance 和 Winget 以进行常见的 Windows 自定义和基线优化。",
      ),
      "installers_menu": ("安装人员菜单", "Fr33thy 的互动脚本。"),
      "tool_winget_interactive_uninstaller": (
        "交互式应用程序卸载程序",
        "列出终端中已安装的 Winget 应用程序，以便您可以选择要删除的应用程序。",
      ),
      "tool_interrupt_affinity_policy": ("中断亲和性策略工具", "中断关联和 IRQ 策略调整实用程序。"),
      "tool_interrupt_affinity_policy_ia64": (
        "中断亲和性策略工具 (IA64)",
        "中断关联策略实用程序的 IA64 构建。",
      ),
      "tool_interrupt_affinity_policy_x86": (
        "中断关联策略工具 (x86)",
        "x86 构建的中断关联策略实用程序。",
      ),
      "tool_msi_afterburner_setup": ("MSI 加力燃烧器安装程序", "GPU 超频和监控安装程序。"),
      "installers_msi_afterburner": (
        "MSI Afterburner 脚本安装程序",
        "Fr33thy 的互动脚本。",
      ),
      "tool_msi_util_folder": ("MSI 实用程序 v3", "消息信号中断策略实用程序。"),
      "tool_more_clock_tool": ("更多时钟工具", "AMD 时钟/电压控制实用程序。"),
      "installers_more_clock_tool": ("更多时钟工具脚本安装程序", "Fr33thy 的互动脚本。"),
      "tool_more_power_tool_setup": ("更多PowerTool安装程序", "AMD 功率表调整安装程序。"),
      "tool_mouse_flat_curve": ("鼠标平坦曲线", "应用平坦的鼠标加速曲线设置。"),
      "tool_mouse_movement_recorder": ("鼠标移动记录器", "检查有效的鼠标轮询行为。"),
      "hardware_mouse_polling_rate_test_script": ("鼠标轮询率测试", "Fr33thy 的互动脚本。"),
      "tool_nvidia_profile_inspector_nip_profile": (
        "NVIDIA 性能设置 (.nip)",
        "以性能为中心的配置文件。如果您追求视觉质量，请勿使用。",
      ),
      "tool_nvidia_profile_inspector_folder": (
        "NVIDIA 配置文件检查器",
        "高级 NVIDIA 配置文件编辑器。",
      ),
      "installers_nvidia_profile_inspector": (
        "NVIDIA 配置文件检查器脚本安装程序",
        "Fr33thy 的互动脚本。",
      ),
      "tool_fix_tools_permessi": ("佩尔梅西", "修复工具权限修复脚本。"),
      "tool_polling_rate_tester_app": ("轮询率测试仪应用程序", "专用鼠标轮询率验证实用程序。"),
      "tool_controller_polling": ("投票工具", "控制器轮询率测量工具。"),
      "tool_power_settings_explorer": (
        "电源设置资源管理器",
        "Advanced Windows power-plan settings editor.",
      ),
      "tool_prime95_folder": ("总理95", "CPU压力测试和稳定性验证。"),
      "tool_queue_size_tuner": ("队列大小调节器", "存储队列调整实用程序。"),
      "tool_rammap_folder": ("RAM映射表", "Microsoft Sysinternals 物理内存分析实用程序。"),
      "tool_rtl_utility": ("RTL实用程序", "Realtek 实用程序和诊断工具。"),
      "tool_radeon_tuner_folder": ("Radeon 调谐器", "AMD Radeon 驱动程序调整和配置文件实用程序。"),
      "tool_fix_tools_reset_network": ("重置网络", "修复工具网络重置脚本。"),
      "tool_fix_tools_ripristina_anteprime": ("里普里斯蒂娜·安泰普莱姆", "修复工具缩略图缓存修复脚本。"),
      "tool_ctt_winutil": (
        "运行 CTT WinUtil",
        "打开 Chris Titus Tech WinUtil 以执行常见的 Windows 设置、修复和基线优化任务。",
      ),
      "tool_fix_tools_sfc_dism": ("证监会及DISM", "修复工具完整性和图像修复脚本。"),
      "tool_star_ethernet_analyzer_folder": ("星型以太网分析仪", "以太网和抖动诊断工具包。"),
      "tool_star_ethernet_analyzer_start_bat": (
        "星形以太网分析仪启动器",
        "运行 Star 以太网分析仪的捆绑批处理启动器。",
      ),
      "tool_star_ethernet_analyzer_script": (
        "星形以太网分析器脚本",
        "Star 以太网分析仪的交互式帮助程序脚本。",
      ),
      "tool_star_ethernet_analyzer_video": (
        "Star 以太网分析仪视频指南",
        "使用默认 Windows 应用程序打开捆绑的视频指南。",
      ),
      "tool_tcp_optimizer_folder": ("TCP优化器", "网络堆栈优化和诊断工具。"),
      "tool_testmem5_folder": ("测试内存5", "RAM 压力测试实用程序。"),
      "tool_usb_latency_analyzer_v2_marius_heier": (
        "USB 延迟分析器 V2，作者：marius heier",
        "在可见的提升的 PowerShell 窗口中运行 Marius Heier 的诊断工具。这不应用调整，用于控制台诊断输出。",
      ),
      "tool_unpark_cpu": ("取消CPU停放", "CPU 核心卸载实用程序。"),
      "tool_vivetool_folder": (
        "维维工具",
        "Windows feature flag management utility.",
      ),
      "tool_winscript_batch": ("WinScript 批处理实用程序", "运行捆绑的 WinScript 维护批处理操作。"),
      "tool_hidusbf_folder": (
        "希杜斯布夫",
        "USB polling overclock toolkit for HID devices.",
      ),
    },
  };

  static const Map<String, Map<String, String>> _actionLabels =
      <String, Map<String, String>>{
        "it": <String, String>{
          "Configure ITR": "Configura ITR",
          "Import": "Importa",
          "Install": "Installa",
          "Open": "Aperto",
          "Open Discord": "Apri Discordia",
          "Open Download": "Apri Scarica",
          "Open Releases": "Rilasci aperti",
          "Play Video": "Riproduci video",
          "Restore": "Ripristina",
          "Run": "Corri",
          "Run Script": "Esegui script",
          "Run Tool": "Esegui strumento",
          "Run WinSux": "Esegui WinSux",
          "Run WinUtil": "Esegui WinUtil",
          "Run debloat": "Esegui il debloat",
          "Show in Explorer": "Mostra in Esplora risorse",
        },
        "de": <String, String>{
          "Configure ITR": "Konfigurieren Sie ITR",
          "Import": "Importieren",
          "Install": "Installieren",
          "Open": "Offen",
          "Open Discord": "Öffne Discord",
          "Open Download": "Öffnen Sie den Download",
          "Open Releases": "Offene Veröffentlichungen",
          "Play Video": "Video abspielen",
          "Restore": "Wiederherstellen",
          "Run": "Lauf",
          "Run Script": "Skript ausführen",
          "Run Tool": "Tool ausführen",
          "Run WinSux": "Führen Sie WinSux aus",
          "Run WinUtil": "Führen Sie WinUtil aus",
          "Run debloat": "Führen Sie Debloat aus",
          "Show in Explorer": "Im Explorer anzeigen",
        },
        "es": <String, String>{
          "Configure ITR": "Configurar ITR",
          "Import": "Importar",
          "Install": "Instalar",
          "Open": "Abierto",
          "Open Discord": "Abrir discordia",
          "Open Download": "Abrir Descargar",
          "Open Releases": "Lanzamientos abiertos",
          "Play Video": "Reproducir vídeo",
          "Restore": "Restaurar",
          "Run": "correr",
          "Run Script": "Ejecutar secuencia de comandos",
          "Run Tool": "Ejecutar herramienta",
          "Run WinSux": "Ejecute WinSux",
          "Run WinUtil": "Ejecute WinUtil",
          "Run debloat": "ejecutar debloat",
          "Show in Explorer": "Mostrar en el Explorador",
        },
        "fr": <String, String>{
          "Configure ITR": "Configurer l'ITR",
          "Import": "Importer",
          "Install": "Installer",
          "Open": "Ouvert",
          "Open Discord": "Ouvrir Discorde",
          "Open Download": "Ouvrir le téléchargement",
          "Open Releases": "Versions ouvertes",
          "Play Video": "Lire la vidéo",
          "Restore": "Restaurer",
          "Run": "Courir",
          "Run Script": "Exécuter le script",
          "Run Tool": "Exécuter l'outil",
          "Run WinSux": "Exécutez WinSux",
          "Run WinUtil": "Exécutez WinUtil",
          "Run debloat": "Exécuter le déblot",
          "Show in Explorer": "Afficher dans l'Explorateur",
        },
        "ru": <String, String>{
          "Configure ITR": "Настроить ITR",
          "Import": "Импорт",
          "Install": "Установить",
          "Open": "Открыть",
          "Open Discord": "Открыть Дискорд",
          "Open Download": "Открыть загрузку",
          "Open Releases": "Открытые релизы",
          "Play Video": "Воспроизвести видео",
          "Restore": "Восстановить",
          "Run": "Беги",
          "Run Script": "Запустить сценарий",
          "Run Tool": "Запустить инструмент",
          "Run WinSux": "Запустите WinSux",
          "Run WinUtil": "Запустите WinUtil",
          "Run debloat": "Запустить разблокировку",
          "Show in Explorer": "Показать в проводнике",
        },
        "zh": <String, String>{
          "Configure ITR": "配置 ITR",
          "Import": "进口",
          "Install": "安装",
          "Open": "打开",
          "Open Discord": "开放不和谐",
          "Open Download": "打开下载",
          "Open Releases": "开放版本",
          "Play Video": "播放视频",
          "Restore": "恢复",
          "Run": "运行",
          "Run Script": "运行脚本",
          "Run Tool": "运行工具",
          "Run WinSux": "运行WinSux",
          "Run WinUtil": "运行WinUtil",
          "Run debloat": "运行膨胀",
          "Show in Explorer": "在资源管理器中显示",
        },
      };

  static const Map<String, Map<String, String>>
  _warnings = <String, Map<String, String>>{
    "it": <String, String>{
      "Experimental graphics scheduler override. Revert if games show flicker, black screens, or instability.":
          "Override dello scheduler grafico sperimentale. Ripristina se i giochi mostrano sfarfallio, schermate nere o instabilità.",
      "Firmware/NVRAM changes can make a system unbootable. Back up the original file and use only on supported hardware.":
          "Le modifiche al firmware/NVRAM possono rendere il sistema non avviabile. Eseguire il backup del file originale e utilizzarlo solo su hardware supportato.",
      "HIGH RISK: CPU will run much hotter at idle. Only for desktops with premium cooling. Do NOT use on laptops.":
          "RISCHIO ALTO: la CPU si surriscalda molto quando è inattiva. Solo per desktop con raffreddamento premium. NON utilizzare su laptop.",
      "HIGH RISK: this can increase temperatures, idle power draw, instability, and GPU damage risk. It disables thermal and crash-recovery safeguards. Create a restore point and monitor temperatures.":
          "RISCHIO ALTO: ciò può aumentare le temperature, il consumo energetico in modalità inattiva, l'instabilità e il rischio di danni alla GPU. Disabilita le protezioni termiche e di ripristino in caso di incidente. Crea un punto di ripristino e monitora le temperature.",
      "Increases AMD GPU idle power and can reduce stability on laptops.":
          "Aumenta la potenza inattiva della GPU AMD e può ridurre la stabilità sui laptop.",
      "Increases CPU temperature. Recommended only for desktops with good cooling.":
          "Aumenta la temperatura della CPU. Consigliato solo per desktop con un buon raffreddamento.",
      "Increases idle power usage and CPU temperature slightly. A restart is required to take effect.":
          "Aumenta leggermente il consumo energetico in modalità inattiva e la temperatura della CPU. Per avere effetto è necessario un riavvio.",
      "Legacy compatibility experiment. Test one game at a time and revert if presentation breaks.":
          "Esperimento di compatibilità legacy. Prova un gioco alla volta e ripristina se la presentazione si interrompe.",
      "This action changes advanced NIC interrupt moderation registry values. Restart is recommended after applying changes.":
          "Questa azione modifica i valori avanzati del registro di sistema relativi alla moderazione delle interruzioni della scheda NIC. Si consiglia di riavviare dopo aver applicato le modifiche.",
      "This action executes a remote PowerShell command from alexanderthedad.com. Continue only if you trust the source.":
          "Questa azione esegue un comando remoto di PowerShell da alexanderthedad.com. Continua solo se ti fidi della fonte.",
      "This action executes a remote PowerShell command from debloat.raphi.re and can change system configuration. Continue only if you trust the source.":
          "Questa azione esegue un comando PowerShell remoto da debloat.raphi.re e può modificare la configurazione del sistema. Continua solo se ti fidi della fonte.",
      "This action executes a remote PowerShell command from github.com/FR33THYFR33THY and applies invasive debloat changes. There is no in-app revert for this action. Continue only if you fully trust the source.":
          "Questa azione esegue un comando remoto di PowerShell da github.com/FR33THYFR33THY e applica modifiche invasive al debloat. Non è previsto il ripristino in-app per questa azione. Continua solo se ti fidi completamente della fonte.",
      "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.":
          "Questa azione esegue un comando remoto di PowerShell da tools.mariusheier.com. Continua solo se ti fidi della fonte.",
      "This action runs the official remote WinUtil script from christitus.com. Review its choices before applying changes.":
          "Questa azione esegue lo script WinUtil remoto ufficiale da christitus.com. Rivedi le sue scelte prima di applicare le modifiche.",
      "This opens the author-provided public Discord source. Review the shared file, version, and instructions before running any device tweak.":
          "Questo apre la fonte Discord pubblica fornita dall'autore. Esamina il file condiviso, la versione e le istruzioni prima di eseguire qualsiasi modifica del dispositivo.",
      "Uninstall only software you recognize. Removed desktop applications cannot be restored by ZapTweaks.":
          "Disinstalla solo il software che riconosci. Le applicazioni desktop rimosse non possono essere ripristinate da ZapTweaks.",
      "Use only to diagnose display issues. MPO is enabled by default in Windows.":
          "Utilizzare solo per diagnosticare problemi di visualizzazione. MPO è abilitato per impostazione predefinita in Windows.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and do not use patched protection-bypass builds.":
          "Il flashing del VBIOS può bloccare permanentemente una GPU. Eseguire il backup della ROM, verificare la scheda esatta e non utilizzare build di bypass della protezione con patch.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and remove any temporary driver after use.":
          "Il flashing del VBIOS può bloccare permanentemente una GPU. Eseguire il backup della ROM, verificare la scheda esatta e rimuovere eventuali driver temporanei dopo l'uso.",
    },
    "de": <String, String>{
      "Experimental graphics scheduler override. Revert if games show flicker, black screens, or instability.":
          "Experimentelle Überschreibung des Grafikplaners. Stellen Sie die Funktion wieder her, wenn bei Spielen Flimmern, schwarze Bildschirme oder Instabilität auftreten.",
      "Firmware/NVRAM changes can make a system unbootable. Back up the original file and use only on supported hardware.":
          "Firmware-/NVRAM-Änderungen können dazu führen, dass ein System nicht mehr gestartet werden kann. Sichern Sie die Originaldatei und verwenden Sie sie nur auf unterstützter Hardware.",
      "HIGH RISK: CPU will run much hotter at idle. Only for desktops with premium cooling. Do NOT use on laptops.":
          "HOHES RISIKO: Die CPU wird im Leerlauf viel heißer. Nur für Desktops mit Premium-Kühlung. NICHT auf Laptops verwenden.",
      "HIGH RISK: this can increase temperatures, idle power draw, instability, and GPU damage risk. It disables thermal and crash-recovery safeguards. Create a restore point and monitor temperatures.":
          "HOHES RISIKO: Dies kann die Temperaturen, den Stromverbrauch im Leerlauf, die Instabilität und das Risiko von GPU-Schäden erhöhen. Es deaktiviert thermische und Crash-Recovery-Schutzmaßnahmen. Erstellen Sie einen Wiederherstellungspunkt und überwachen Sie die Temperaturen.",
      "Increases AMD GPU idle power and can reduce stability on laptops.":
          "Erhöht die Leerlaufleistung der AMD-GPU und kann die Stabilität auf Laptops verringern.",
      "Increases CPU temperature. Recommended only for desktops with good cooling.":
          "Erhöht die CPU-Temperatur. Nur für Desktop-PCs mit guter Kühlung empfohlen.",
      "Increases idle power usage and CPU temperature slightly. A restart is required to take effect.":
          "Erhöht den Stromverbrauch im Leerlauf und die CPU-Temperatur leicht. Um wirksam zu werden, ist ein Neustart erforderlich.",
      "Legacy compatibility experiment. Test one game at a time and revert if presentation breaks.":
          "Experiment zur Legacy-Kompatibilität. Testen Sie jeweils ein Spiel und kehren Sie zurück, wenn die Präsentation unterbrochen wird.",
      "This action changes advanced NIC interrupt moderation registry values. Restart is recommended after applying changes.":
          "Diese Aktion ändert die erweiterten Registrierungswerte für die NIC-Interrupt-Moderation. Nach der Übernahme der Änderungen wird ein Neustart empfohlen.",
      "This action executes a remote PowerShell command from alexanderthedad.com. Continue only if you trust the source.":
          "Diese Aktion führt einen Remote-PowerShell-Befehl von alexanderthedad.com aus. Fahren Sie nur fort, wenn Sie der Quelle vertrauen.",
      "This action executes a remote PowerShell command from debloat.raphi.re and can change system configuration. Continue only if you trust the source.":
          "Diese Aktion führt einen Remote-PowerShell-Befehl von debloat.raphi.re aus und kann die Systemkonfiguration ändern. Fahren Sie nur fort, wenn Sie der Quelle vertrauen.",
      "This action executes a remote PowerShell command from github.com/FR33THYFR33THY and applies invasive debloat changes. There is no in-app revert for this action. Continue only if you fully trust the source.":
          "Diese Aktion führt einen Remote-PowerShell-Befehl von github.com/FR33THYFR33THY aus und wendet invasive Debloat-Änderungen an. Für diese Aktion gibt es keine In-App-Rückgängigmachung. Fahren Sie nur fort, wenn Sie der Quelle völlig vertrauen.",
      "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.":
          "Diese Aktion führt einen Remote-PowerShell-Befehl von tools.mariusheier.com aus. Fahren Sie nur fort, wenn Sie der Quelle vertrauen.",
      "This action runs the official remote WinUtil script from christitus.com. Review its choices before applying changes.":
          "Diese Aktion führt das offizielle Remote-WinUtil-Skript von christitus.com aus. Überprüfen Sie die Auswahl, bevor Sie Änderungen vornehmen.",
      "This opens the author-provided public Discord source. Review the shared file, version, and instructions before running any device tweak.":
          "Dadurch wird die vom Autor bereitgestellte öffentliche Discord-Quelle geöffnet. Überprüfen Sie die freigegebene Datei, Version und Anweisungen, bevor Sie eine Geräteoptimierung durchführen.",
      "Uninstall only software you recognize. Removed desktop applications cannot be restored by ZapTweaks.":
          "Deinstallieren Sie nur Software, die Sie kennen. Entfernte Desktop-Anwendungen können von ZapTweaks nicht wiederhergestellt werden.",
      "Use only to diagnose display issues. MPO is enabled by default in Windows.":
          "Nur zur Diagnose von Anzeigeproblemen verwenden. MPO ist in Windows standardmäßig aktiviert.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and do not use patched protection-bypass builds.":
          "VBIOS-Flashing kann eine GPU dauerhaft blockieren. Sichern Sie das ROM, überprüfen Sie die genaue Platine und verwenden Sie keine gepatchten Schutz-Bypass-Builds.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and remove any temporary driver after use.":
          "VBIOS-Flashing kann eine GPU dauerhaft blockieren. Sichern Sie das ROM, überprüfen Sie die genaue Platine und entfernen Sie nach der Verwendung alle temporären Treiber.",
    },
    "es": <String, String>{
      "Experimental graphics scheduler override. Revert if games show flicker, black screens, or instability.":
          "Anulación del programador de gráficos experimental. Revertir si los juegos muestran parpadeos, pantallas negras o inestabilidad.",
      "Firmware/NVRAM changes can make a system unbootable. Back up the original file and use only on supported hardware.":
          "Los cambios de firmware/NVRAM pueden hacer que un sistema no se pueda iniciar. Haga una copia de seguridad del archivo original y utilícelo solo en hardware compatible.",
      "HIGH RISK: CPU will run much hotter at idle. Only for desktops with premium cooling. Do NOT use on laptops.":
          "ALTO RIESGO: La CPU se calentará mucho más cuando esté inactiva. Solo para computadoras de escritorio con refrigeración premium. NO lo use en computadoras portátiles.",
      "HIGH RISK: this can increase temperatures, idle power draw, instability, and GPU damage risk. It disables thermal and crash-recovery safeguards. Create a restore point and monitor temperatures.":
          "ALTO RIESGO: esto puede aumentar las temperaturas, el consumo de energía en inactivo, la inestabilidad y el riesgo de daños a la GPU. Desactiva las salvaguardas térmicas y de recuperación de fallos. Cree un punto de restauración y controle las temperaturas.",
      "Increases AMD GPU idle power and can reduce stability on laptops.":
          "Aumenta la potencia inactiva de la GPU AMD y puede reducir la estabilidad en las computadoras portátiles.",
      "Increases CPU temperature. Recommended only for desktops with good cooling.":
          "Aumenta la temperatura de la CPU. Recomendado solo para computadoras de escritorio con buena refrigeración.",
      "Increases idle power usage and CPU temperature slightly. A restart is required to take effect.":
          "Aumenta ligeramente el uso de energía inactiva y la temperatura de la CPU. Es necesario reiniciar para que surta efecto.",
      "Legacy compatibility experiment. Test one game at a time and revert if presentation breaks.":
          "Experimento de compatibilidad heredada. Pruebe un juego a la vez y revierta si se rompe la presentación.",
      "This action changes advanced NIC interrupt moderation registry values. Restart is recommended after applying changes.":
          "Esta acción cambia los valores avanzados del registro de moderación de interrupciones de NIC. Se recomienda reiniciar después de aplicar los cambios.",
      "This action executes a remote PowerShell command from alexanderthedad.com. Continue only if you trust the source.":
          "Esta acción ejecuta un comando remoto de PowerShell desde alexanderthedad.com. Continúe solo si confía en la fuente.",
      "This action executes a remote PowerShell command from debloat.raphi.re and can change system configuration. Continue only if you trust the source.":
          "Esta acción ejecuta un comando remoto de PowerShell desde debloat.raphi.re y puede cambiar la configuración del sistema. Continúe solo si confía en la fuente.",
      "This action executes a remote PowerShell command from github.com/FR33THYFR33THY and applies invasive debloat changes. There is no in-app revert for this action. Continue only if you fully trust the source.":
          "Esta acción ejecuta un comando remoto de PowerShell desde github.com/FR33THYFR33THY y aplica cambios de eliminación invasivos. No hay reversión en la aplicación para esta acción. Continúe solo si confía plenamente en la fuente.",
      "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.":
          "Esta acción ejecuta un comando remoto de PowerShell desde tools.mariusheier.com. Continúe solo si confía en la fuente.",
      "This action runs the official remote WinUtil script from christitus.com. Review its choices before applying changes.":
          "Esta acción ejecuta el script WinUtil remoto oficial de christitus.com. Revise sus opciones antes de aplicar cambios.",
      "This opens the author-provided public Discord source. Review the shared file, version, and instructions before running any device tweak.":
          "Esto abre la fuente pública de Discord proporcionada por el autor. Revise el archivo compartido, la versión y las instrucciones antes de ejecutar cualquier modificación del dispositivo.",
      "Uninstall only software you recognize. Removed desktop applications cannot be restored by ZapTweaks.":
          "Desinstale sólo el software que reconozca. ZapTweaks no puede restaurar las aplicaciones de escritorio eliminadas.",
      "Use only to diagnose display issues. MPO is enabled by default in Windows.":
          "Úselo únicamente para diagnosticar problemas de visualización. MPO está habilitado de forma predeterminada en Windows.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and do not use patched protection-bypass builds.":
          "La actualización de VBIOS puede bloquear permanentemente una GPU. Haga una copia de seguridad de la ROM, verifique la placa exacta y no utilice compilaciones de omisión de protección parcheadas.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and remove any temporary driver after use.":
          "La actualización de VBIOS puede bloquear permanentemente una GPU. Haga una copia de seguridad de la ROM, verifique la placa exacta y elimine cualquier controlador temporal después de su uso.",
    },
    "fr": <String, String>{
      "Experimental graphics scheduler override. Revert if games show flicker, black screens, or instability.":
          "Remplacement du planificateur graphique expérimental. Annulez si les jeux affichent un scintillement, des écrans noirs ou une instabilité.",
      "Firmware/NVRAM changes can make a system unbootable. Back up the original file and use only on supported hardware.":
          "Les modifications du micrologiciel/NVRAM peuvent rendre un système impossible à démarrer. Sauvegardez le fichier original et utilisez-le uniquement sur le matériel pris en charge.",
      "HIGH RISK: CPU will run much hotter at idle. Only for desktops with premium cooling. Do NOT use on laptops.":
          "RISQUE ÉLEVÉ : le processeur fonctionnera beaucoup plus à chaud au repos. Uniquement pour les ordinateurs de bureau dotés d'un refroidissement premium. Ne PAS utiliser sur les ordinateurs portables.",
      "HIGH RISK: this can increase temperatures, idle power draw, instability, and GPU damage risk. It disables thermal and crash-recovery safeguards. Create a restore point and monitor temperatures.":
          "RISQUE ÉLEVÉ : cela peut augmenter les températures, la consommation d'énergie au ralenti, l'instabilité et le risque de dommages au GPU. Il désactive les protections thermiques et de récupération en cas de crash. Créez un point de restauration et surveillez les températures.",
      "Increases AMD GPU idle power and can reduce stability on laptops.":
          "Augmente la puissance d'inactivité du GPU AMD et peut réduire la stabilité des ordinateurs portables.",
      "Increases CPU temperature. Recommended only for desktops with good cooling.":
          "Augmente la température du processeur. Recommandé uniquement pour les ordinateurs de bureau dotés d'un bon refroidissement.",
      "Increases idle power usage and CPU temperature slightly. A restart is required to take effect.":
          "Augmente légèrement la consommation d'énergie au ralenti et la température du processeur. Un redémarrage est nécessaire pour prendre effet.",
      "Legacy compatibility experiment. Test one game at a time and revert if presentation breaks.":
          "Expérience de compatibilité héritée. Testez un jeu à la fois et revenez si la présentation est interrompue.",
      "This action changes advanced NIC interrupt moderation registry values. Restart is recommended after applying changes.":
          "Cette action modifie les valeurs avancées du registre de modération des interruptions de la carte réseau. Le redémarrage est recommandé après avoir appliqué les modifications.",
      "This action executes a remote PowerShell command from alexanderthedad.com. Continue only if you trust the source.":
          "Cette action exécute une commande PowerShell distante depuis alexanderthedad.com. Continuez seulement si vous faites confiance à la source.",
      "This action executes a remote PowerShell command from debloat.raphi.re and can change system configuration. Continue only if you trust the source.":
          "Cette action exécute une commande PowerShell distante depuis debloat.raphi.re et peut modifier la configuration du système. Continuez seulement si vous faites confiance à la source.",
      "This action executes a remote PowerShell command from github.com/FR33THYFR33THY and applies invasive debloat changes. There is no in-app revert for this action. Continue only if you fully trust the source.":
          "Cette action exécute une commande PowerShell à distance à partir de github.com/FR33THYFR33THY et applique des modifications de débloquement invasives. Il n'y a pas de retour dans l'application pour cette action. Continuez uniquement si vous faites entièrement confiance à la source.",
      "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.":
          "Cette action exécute une commande PowerShell distante à partir de tools.mariusheier.com. Continuez seulement si vous faites confiance à la source.",
      "This action runs the official remote WinUtil script from christitus.com. Review its choices before applying changes.":
          "Cette action exécute le script WinUtil distant officiel de christitus.com. Revoyez ses choix avant d’appliquer les modifications.",
      "This opens the author-provided public Discord source. Review the shared file, version, and instructions before running any device tweak.":
          "Cela ouvre la source Discord publique fournie par l'auteur. Vérifiez le fichier partagé, la version et les instructions avant d'exécuter un réglage de l'appareil.",
      "Uninstall only software you recognize. Removed desktop applications cannot be restored by ZapTweaks.":
          "Désinstallez uniquement les logiciels que vous reconnaissez. Les applications de bureau supprimées ne peuvent pas être restaurées par ZapTweaks.",
      "Use only to diagnose display issues. MPO is enabled by default in Windows.":
          "À utiliser uniquement pour diagnostiquer les problèmes d'affichage. MPO est activé par défaut dans Windows.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and do not use patched protection-bypass builds.":
          "Le flashage du VBIOS peut bloquer définitivement un GPU. Sauvegardez la ROM, vérifiez la carte exacte et n'utilisez pas de versions de contournement de protection corrigées.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and remove any temporary driver after use.":
          "Le flashage du VBIOS peut bloquer définitivement un GPU. Sauvegardez la ROM, vérifiez la carte exacte et supprimez tout pilote temporaire après utilisation.",
    },
    "ru": <String, String>{
      "Experimental graphics scheduler override. Revert if games show flicker, black screens, or instability.":
          "Переопределение экспериментального графического планировщика. Выполните возврат, если в играх наблюдается мерцание, черный экран или нестабильность.",
      "Firmware/NVRAM changes can make a system unbootable. Back up the original file and use only on supported hardware.":
          "Изменения прошивки/NVRAM могут привести к невозможности загрузки системы. Создайте резервную копию исходного файла и используйте его только на поддерживаемом оборудовании.",
      "HIGH RISK: CPU will run much hotter at idle. Only for desktops with premium cooling. Do NOT use on laptops.":
          "ВЫСОКИЙ РИСК: ЦП в режиме простоя будет сильно нагреваться. Только для настольных компьютеров с системой охлаждения премиум-класса. НЕ используйте на ноутбуках.",
      "HIGH RISK: this can increase temperatures, idle power draw, instability, and GPU damage risk. It disables thermal and crash-recovery safeguards. Create a restore point and monitor temperatures.":
          "ВЫСОКИЙ РИСК: это может привести к повышению температуры, энергопотреблению в режиме ожидания, нестабильности и риску повреждения графического процессора. Он отключает защиту от перегрева и аварийного восстановления. Создайте точку восстановления и контролируйте температуру.",
      "Increases AMD GPU idle power and can reduce stability on laptops.":
          "Увеличивает мощность графического процессора AMD в режиме ожидания и может снизить стабильность работы ноутбуков.",
      "Increases CPU temperature. Recommended only for desktops with good cooling.":
          "Увеличивает температуру процессора. Рекомендуется только для настольных компьютеров с хорошим охлаждением.",
      "Increases idle power usage and CPU temperature slightly. A restart is required to take effect.":
          "Немного увеличивает энергопотребление в режиме ожидания и температуру процессора. Чтобы изменения вступили в силу, требуется перезагрузка.",
      "Legacy compatibility experiment. Test one game at a time and revert if presentation breaks.":
          "Эксперимент по совместимости с устаревшими версиями. Тестируйте одну игру за раз и возвращайтесь, если презентация не работает.",
      "This action changes advanced NIC interrupt moderation registry values. Restart is recommended after applying changes.":
          "Это действие изменяет расширенные значения реестра модерации прерываний NIC. После применения изменений рекомендуется перезагрузить компьютер.",
      "This action executes a remote PowerShell command from alexanderthedad.com. Continue only if you trust the source.":
          "Это действие выполняет удаленную команду PowerShell с сайта alexanderthedad.com. Продолжайте, только если вы доверяете источнику.",
      "This action executes a remote PowerShell command from debloat.raphi.re and can change system configuration. Continue only if you trust the source.":
          "Это действие выполняет удаленную команду PowerShell из debloat.raphi.re и может изменить конфигурацию системы. Продолжайте, только если вы доверяете источнику.",
      "This action executes a remote PowerShell command from github.com/FR33THYFR33THY and applies invasive debloat changes. There is no in-app revert for this action. Continue only if you fully trust the source.":
          "Это действие выполняет удаленную команду PowerShell с сайта github.com/FR33THYFR33THY и применяет инвазивные изменения раздутия. Для этого действия нет возможности возврата в приложении. Продолжайте, только если вы полностью доверяете источнику.",
      "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.":
          "Это действие выполняет удаленную команду PowerShell с сайта tools.mariusheier.com. Продолжайте, только если вы доверяете источнику.",
      "This action runs the official remote WinUtil script from christitus.com. Review its choices before applying changes.":
          "Это действие запускает официальный удаленный сценарий WinUtil с сайта christitus.com. Прежде чем применять изменения, просмотрите его варианты.",
      "This opens the author-provided public Discord source. Review the shared file, version, and instructions before running any device tweak.":
          "Откроется предоставленный автором общедоступный источник Discord. Прежде чем запускать какую-либо настройку устройства, просмотрите общий файл, версию и инструкции.",
      "Uninstall only software you recognize. Removed desktop applications cannot be restored by ZapTweaks.":
          "Удаляйте только программное обеспечение, которое вы знаете. Удаленные настольные приложения не могут быть восстановлены с помощью ZapTweaks.",
      "Use only to diagnose display issues. MPO is enabled by default in Windows.":
          "Используйте только для диагностики проблем с отображением. MPO включено по умолчанию в Windows.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and do not use patched protection-bypass builds.":
          "Перепрошивка VBIOS может навсегда вывести из строя графический процессор. Сделайте резервную копию ПЗУ, проверьте точную плату и не используйте исправленные сборки обхода защиты.",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and remove any temporary driver after use.":
          "Перепрошивка VBIOS может навсегда вывести из строя графический процессор. Создайте резервную копию ПЗУ, проверьте точную плату и удалите все временные драйверы после использования.",
    },
    "zh": <String, String>{
      "Experimental graphics scheduler override. Revert if games show flicker, black screens, or instability.":
          "实验性图形调度程序覆盖。如果游戏出现闪烁、黑屏或不稳定的情况，请进行恢复。",
      "Firmware/NVRAM changes can make a system unbootable. Back up the original file and use only on supported hardware.":
          "固件/NVRAM 更改可能导致系统无法启动。备份原始文件并仅在支持的硬件上使用。",
      "HIGH RISK: CPU will run much hotter at idle. Only for desktops with premium cooling. Do NOT use on laptops.":
          "高风险：CPU 在空闲时运行温度会更高。仅适用于具有高级冷却功能的台式机。请勿在笔记本电脑上使用。",
      "HIGH RISK: this can increase temperatures, idle power draw, instability, and GPU damage risk. It disables thermal and crash-recovery safeguards. Create a restore point and monitor temperatures.":
          "高风险：这可能会增加温度、空闲功耗、不稳定和 GPU 损坏风险。它禁用热和崩溃恢复保护措施。创建还原点并监控温度。",
      "Increases AMD GPU idle power and can reduce stability on laptops.":
          "增加 AMD GPU 空闲功耗并降低笔记本电脑的稳定性。",
      "Increases CPU temperature. Recommended only for desktops with good cooling.":
          "提高CPU温度。仅推荐用于散热良好的台式机。",
      "Increases idle power usage and CPU temperature slightly. A restart is required to take effect.":
          "略微增加闲置功耗和 CPU 温度。需要重启才能生效。",
      "Legacy compatibility experiment. Test one game at a time and revert if presentation breaks.":
          "遗留兼容性实验。一次测试一款游戏，如果演示中断则恢复。",
      "This action changes advanced NIC interrupt moderation registry values. Restart is recommended after applying changes.":
          "此操作更改高级 NIC 中断调节注册表值。建议在应用更改后重新启动。",
      "This action executes a remote PowerShell command from alexanderthedad.com. Continue only if you trust the source.":
          "此操作从 alexanderthedad.com 执行远程 PowerShell 命令。仅当您信任来源时才继续。",
      "This action executes a remote PowerShell command from debloat.raphi.re and can change system configuration. Continue only if you trust the source.":
          "此操作从 debloat.raphi.re 执行远程 PowerShell 命令，并且可以更改系统配置。仅当您信任来源时才继续。",
      "This action executes a remote PowerShell command from github.com/FR33THYFR33THY and applies invasive debloat changes. There is no in-app revert for this action. Continue only if you fully trust the source.":
          "此操作从 github.com/FR33THYFR33THY 执行远程 PowerShell 命令并应用侵入式 debloat 更改。此操作没有应用内恢复。仅当您完全信任来源时才继续。",
      "This action executes a remote PowerShell command from tools.mariusheier.com. Continue only if you trust the source.":
          "此操作从tools.marisheier.com 执行远程PowerShell 命令。仅当您信任来源时才继续。",
      "This action runs the official remote WinUtil script from christitus.com. Review its choices before applying changes.":
          "此操作运行来自 christitus.com 的官方远程 WinUtil 脚本。在应用更改之前检查其选择。",
      "This opens the author-provided public Discord source. Review the shared file, version, and instructions before running any device tweak.":
          "这将打开作者提供的公共 Discord 源。在运行任何设备调整之前查看共享文件、版本和说明。",
      "Uninstall only software you recognize. Removed desktop applications cannot be restored by ZapTweaks.":
          "仅卸载您认识的软件。 ZapTweaks 无法恢复已删除的桌面应用程序。",
      "Use only to diagnose display issues. MPO is enabled by default in Windows.":
          "仅用于诊断显示问题。 Windows 中默认启用 MPO。",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and do not use patched protection-bypass builds.":
          "VBIOS 刷新可能会导致 GPU 永久变砖。备份 ROM，验证确切的主板，并且不要使用修补的保护绕过版本。",
      "VBIOS flashing can permanently brick a GPU. Back up the ROM, verify the exact board, and remove any temporary driver after use.":
          "VBIOS 刷新可能会导致 GPU 永久变砖。备份 ROM，验证确切的板，并在使用后删除所有临时驱动程序。",
    },
  };
}
