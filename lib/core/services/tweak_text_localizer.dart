import '../models/tweak_descriptor.dart';

class LocalizedTweakText {
  const LocalizedTweakText({
    required this.title,
    required this.description,
    required this.details,
  });

  final String title;
  final String description;
  final String details;
}

class TweakTextLocalizer {
  static LocalizedTweakText resolve(TweakDescriptor descriptor, String locale) {
    final copy = _copy[locale]?[descriptor.id];
    final title = copy?.$1 ?? descriptor.title;
    final description =
        copy?.$2 ??
        _generatedDescription(locale, descriptor) ??
        descriptor.description;
    final detailParts = <String>[description, '', _detail(locale, descriptor)];
    final warning = descriptor.scriptTweak?.warningMessage;
    if (warning != null && warning.trim().isNotEmpty) {
      detailParts.add('\n${_label(locale, 'warning')}: $warning');
    }
    return LocalizedTweakText(
      title: title,
      description: description,
      details: detailParts.join('\n'),
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
  _copy = <String, Map<String, (String, String)>>{
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
}
