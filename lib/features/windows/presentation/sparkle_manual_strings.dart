/// Integration keys for the host's generated locales; no locale files changed.
const sparkleManualEnglish = <String, String>{
  'sparkleManualTitle': 'Manual controls',
  'sparkleManualIntro':
      'Native Windows controls. Nothing is preselected, recommended or run automatically. Source links are reference only; no upstream scripts are executed.',
  'sparkleManualSafe': 'Current-user appearance and content',
  'sparkleManualSafeNotice':
      'Exact previous Registry value/type/presence snapshots. Read-back verifies the configured value, not its visible effect. Sign out may be needed; Explorer is never restarted automatically. Restore snapshots from Recovery.',
  'sparkleClock': '24-hour clock · HH:mm / HH:mm:ss',
  'sparkleSeconds': 'Show seconds in the system clock · DWORD 1',
  'sparkleMenuDelay': 'MenuShowDelay · REG_SZ milliseconds (0–4000)',
  'sparkleLockScreen':
      'Disable lock-screen overlays and subscribed content · DWORD 0',
  'sparkleSearch': 'Hide taskbar search · SearchboxTaskbarMode DWORD 0',
  'sparklePreview': 'Preview selected changes',
  'sparkleApply': 'Apply selected changes',
  'sparkleCancel': 'Cancel',
  'sparkleExpert': 'Expert · security and services',
  'sparkleExpertLocked':
      'Enable Expert mode explicitly in Settings to access high-risk manual controls. These are never included in guided setup or recommendations.',
  'sparkleExpertConsent':
      'I understand the security/functional risks and explicitly consent to these changes.',
  'sparkleHvci': 'Configure HVCI Enabled = 0',
  'sparkleHvciWarning':
      'Reduces memory-integrity protection. Changes only the configured HVCI Enabled value. A reboot is required; effective HVCI is not verified. Does not disable VBS or Secure Boot. Managed/UEFI-locked configurations are rejected; no bypass.',
  'sparkleRdp': 'RDP redirection warning policy · version 1',
  'sparkleRdpWarning':
      'High-risk security policy: changes HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services\\Client\\RedirectionWarningDialogVersion to DWORD 1. Can alter RDP redirection warning behavior; no claim that warnings or security are improved. Reopen the RDP client; exact raw snapshot rollback.',
  'sparkleServices': 'Explicit service startup changes',
  'sparkleServicesWarning':
      'Only the existing nonessential service allowlist. Each selected service gets its own snapshot. Review required dependencies and dependent services. Startup changes can break features after reboot. No running service is stopped and no reboot is automatic.',
  'sparkleScanServices': 'Inspect allowlisted services',
  'sparkleServiceChoice': 'Select startup type (no default)',
  'sparkleServiceAutomatic': 'Automatic · delayed start off',
  'sparkleServiceManual': 'Manual · delayed start off',
  'sparkleServiceDisabled': 'Disabled · delayed start off',
  'sparkleServiceUnchanged': 'Leave unchanged',
  'sparkleServiceCurrent': 'Current startup / delayed / live state',
  'sparkleServiceDependencies': 'Required dependencies',
  'sparkleServiceDependents': 'Dependent services',
  'sparkleUnavailable': 'Unavailable in ZapTweaks · external guidance only',
  'sparkleDefender': 'Defender real-time protection',
  'sparkleDefenderUnavailable':
      'Unavailable: a reliable provider-only managed/tamper preflight is not implemented. No Registry/service changes, policy bypass or security bypass. The external project is not executed by ZapTweaks.',
  'sparkleEdge': 'Edge uninstall (preserve profile)',
  'sparkleEdgeUnavailable':
      'Unavailable: supported official uninstall depends on Windows region/build. Use Windows Settings only when Uninstall is offered and leave profile deletion unchecked. No forced removal, profile deletion or invented success.',
  'sparkleNvidia': 'NVIDIA presets and telemetry',
  'sparkleNvidiaUnavailable':
      'Unavailable: no verified supported script or provider. No invented driver tweaks; external source only.',
  'sparkleExternal': 'Open official Sparkle source (external)',
  'sparkleDone':
      'Configured values verified. Consult each restart/sign-out notice; this does not verify effective security state.',
  'sparkleDryRun': 'Dry run completed. No Windows settings were changed.',
  'sparkleFailed': 'Operation did not complete',
};

const sparkleManualItalian = <String, String>{
  'sparkleManualTitle': 'Controlli manuali',
  'sparkleManualIntro':
      'Controlli nativi di Windows. Nessuna preselezione, raccomandazione o esecuzione automatica. I link sono solo riferimenti: nessuno script upstream viene eseguito.',
  'sparkleManualSafe': 'Aspetto e contenuti dell’utente corrente',
  'sparkleManualSafeNotice':
      'Snapshot esatti di valore/tipo/presenza nel Registro. La rilettura verifica il valore configurato, non l’effetto visibile. Può servire disconnettersi; Explorer non viene riavviato automaticamente. Ripristina gli snapshot da Recupero.',
  'sparkleClock': 'Orologio 24 ore · HH:mm / HH:mm:ss',
  'sparkleSeconds': 'Mostra secondi nell’orologio · DWORD 1',
  'sparkleMenuDelay': 'MenuShowDelay · millisecondi REG_SZ (0–4000)',
  'sparkleLockScreen':
      'Disattiva overlay e contenuti della schermata di blocco · DWORD 0',
  'sparkleSearch':
      'Nascondi ricerca sulla barra · SearchboxTaskbarMode DWORD 0',
  'sparklePreview': 'Anteprima modifiche selezionate',
  'sparkleApply': 'Applica modifiche selezionate',
  'sparkleCancel': 'Annulla',
  'sparkleExpert': 'Expert · sicurezza e servizi',
  'sparkleExpertLocked':
      'Abilita esplicitamente Expert nelle Impostazioni per i controlli manuali ad alto rischio. Non sono mai inclusi nella configurazione guidata o nelle raccomandazioni.',
  'sparkleExpertConsent':
      'Comprendo i rischi per sicurezza e funzionalità e acconsento esplicitamente a queste modifiche.',
  'sparkleHvci': 'Configura HVCI Enabled = 0',
  'sparkleHvciWarning':
      'Riduce la protezione dell’integrità della memoria. Cambia solo il valore configurato HVCI Enabled. Serve un riavvio; HVCI effettivo non è verificato. Non disabilita VBS o Secure Boot. Configurazioni gestite/bloccate UEFI rifiutate; nessun bypass.',
  'sparkleRdp': 'Policy avviso reindirizzamento RDP · versione 1',
  'sparkleRdpWarning':
      'Policy di sicurezza ad alto rischio: imposta HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows NT\\Terminal Services\\Client\\RedirectionWarningDialogVersion a DWORD 1. Può alterare gli avvisi RDP; nessuna promessa di migliore sicurezza. Riapri il client RDP; rollback esatto dello snapshot grezzo.',
  'sparkleServices': 'Modifiche esplicite all’avvio dei servizi',
  'sparkleServicesWarning':
      'Solo l’allowlist esistente di servizi non essenziali. Uno snapshot per servizio selezionato. Controlla dipendenze necessarie e servizi dipendenti. L’avvio può compromettere funzionalità dopo il riavvio. Nessun servizio attivo viene fermato e nessun riavvio è automatico.',
  'sparkleScanServices': 'Ispeziona servizi consentiti',
  'sparkleServiceChoice': 'Scegli tipo di avvio (nessun default)',
  'sparkleServiceAutomatic': 'Automatico · avvio ritardato disattivato',
  'sparkleServiceManual': 'Manuale · avvio ritardato disattivato',
  'sparkleServiceDisabled': 'Disabilitato · avvio ritardato disattivato',
  'sparkleServiceUnchanged': 'Non modificare',
  'sparkleServiceCurrent': 'Avvio / ritardato / stato attuale',
  'sparkleServiceDependencies': 'Dipendenze necessarie',
  'sparkleServiceDependents': 'Servizi dipendenti',
  'sparkleUnavailable': 'Non disponibile in ZapTweaks · solo guida esterna',
  'sparkleDefender': 'Protezione in tempo reale Defender',
  'sparkleDefenderUnavailable':
      'Non disponibile: manca un preflight affidabile provider-only per gestione/tamper. Nessuna modifica a Registro/servizi, nessun bypass di policy o sicurezza. ZapTweaks non esegue il progetto esterno.',
  'sparkleEdge': 'Disinstallazione Edge (conserva profilo)',
  'sparkleEdgeUnavailable':
      'Non disponibile: la disinstallazione ufficiale dipende da area geografica/build Windows. Usa Impostazioni solo quando Disinstalla è disponibile, senza selezionare l’eliminazione del profilo. Nessuna rimozione forzata o falso successo.',
  'sparkleNvidia': 'Preset e telemetria NVIDIA',
  'sparkleNvidiaUnavailable':
      'Non disponibile: nessuno script o provider verificato e supportato. Nessun tweak driver inventato; solo fonte esterna.',
  'sparkleExternal': 'Apri fonte ufficiale Sparkle (esterno)',
  'sparkleDone':
      'Valori configurati verificati. Leggi gli avvisi su riavvio/disconnessione: lo stato effettivo della sicurezza non è verificato.',
  'sparkleDryRun':
      'Dry run completato. Nessuna impostazione Windows modificata.',
  'sparkleFailed': 'Operazione non completata',
};
