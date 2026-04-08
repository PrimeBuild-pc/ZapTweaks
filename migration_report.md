# Migration Report

Data: 2026-04-03
Obiettivo: mappare ogni file .ps1 originale di resources/script a una destinazione esplicita (Convertito, Unito, Scartato) per consentire la rimozione sicura della cartella script.

Moduli Dart coinvolti:
- lib/models/action_tweaks.dart
- lib/models/check_tweaks.dart
- lib/models/program_tools_tweaks.dart
- lib/models/recovered_script_tweaks.dart
- lib/models/system_checks_tweaks.dart
- lib/models/power_cpu_tweaks.dart
- lib/models/privacy_bloatware_tweaks.dart
- lib/models/networking_tweaks.dart
- lib/models/gaming_optimizations_tweaks.dart
- lib/models/ui_visuals_tweaks.dart
- lib/models/hardware_tweaks.dart

Legenda:
- Convertito: funzionalita portata in tweak Dart con onApply/onRevert/checkState.
- Unito: funzionalita consolidata in un tweak Dart gia esistente.
- Recuperato: funzionalita esposta come Launcher o ScriptInteractive nell'app.
- Scartato: workflow manuale, non idempotente, rischioso o dipendente da tool esterni.

## 1 Check
- [x] 1 Space Check.ps1 | source: 1 Check/1 Space Check.ps1 | Recuperato in System Checks: diagnostica one-shot/manuale.
- [x] 2 Ram Check.ps1 | source: 1 Check/2 Ram Check.ps1 | Recuperato in System Checks: diagnostica one-shot/manuale.
- [x] 3 Gpu Check.ps1 | source: 1 Check/3 Gpu Check.ps1 | Recuperato in System Checks: diagnostica one-shot/manuale.
- [x] 4 Bios Update.ps1 | source: 1 Check/4 Bios Update.ps1 | Recuperato in System Checks: update firmware OEM fuori scope tweak app.
- [x] 5 Bios Settings.ps1 | source: 1 Check/5 Bios Settings.ps1 | Recuperato in System Checks: guida BIOS manuale non automatizzabile in sicurezza.
- [x] 6 Cpu Test.ps1 | source: 1 Check/6 Cpu Test.ps1 | Recuperato in System Checks: benchmark/stress test esterno.
- [x] 7 Ram Test.ps1 | source: 1 Check/7 Ram Test.ps1 | Recuperato in System Checks: benchmark/stress test esterno.
- [x] 8 Gpu Test.ps1 | source: 1 Check/8 Gpu Test.ps1 | Recuperato in System Checks: benchmark/stress test esterno.
- [x] 9 Hw Info.ps1 | source: 1 Check/9 Hw Info.ps1 | Recuperato in System Checks: launcher informativo, non stato persistente.

## 2 Refresh
- [x] 1 Factory Reset.ps1 | source: 2 Refresh/1 Factory Reset.ps1 | Recuperato in Refresh & Recovery: operazione distruttiva/reset OS.
- [x] 2 Account Local.ps1 | source: 2 Refresh/2 Account Local.ps1 | Recuperato in Refresh & Recovery: procedura guidata dipendente da input utente.
- [x] 3 Reinstall.ps1 | source: 2 Refresh/3 Reinstall.ps1 | Recuperato in Refresh & Recovery: reinstallazione OS fuori scope tweak runtime.
- [x] 4 Autounattend.ps1 | source: 2 Refresh/4 Autounattend.ps1 | Recuperato in Refresh & Recovery: provisioning/installazione unattended.
- [x] 5 Updates Drivers Block.ps1 | source: 2 Refresh/5 Updates Drivers Block.ps1 | Recuperato in Refresh & Recovery: policy invasive update/driver.
- [x] 6 Network Driver.ps1 | source: 2 Refresh/6 Network Driver.ps1 | Recuperato in Refresh & Recovery: installazione driver guidata/manuale.
- [x] 7 To Bios.ps1 | source: 2 Refresh/7 To Bios.ps1 | Recuperato in Refresh & Recovery: launcher BIOS/UEFI, non tweak persistente.

## 3 Setup
- [x] 1 BitLocker.ps1 | source: 3 Setup/1 BitLocker.ps1 | Recuperato in Setup Scripts: workflow crittografia guidato e device-specific.
- [x] 2 Memory Compression.ps1 | source: 3 Setup/2 Memory Compression.ps1 | Convertito in System Checks -> MemoryCompressionOffTweak.
- [x] 3 Convert Home To Pro.ps1 | source: 3 Setup/3 Convert Home To Pro.ps1 | Recuperato in Setup Scripts: licensing/edition upgrade fuori scope.
- [x] 4 Keys.ps1 | source: 3 Setup/4 Keys.ps1 | Recuperato in Setup Scripts: gestione chiavi/licenze sensibile.
- [x] 5 Activation.ps1 | source: 3 Setup/5 Activation.ps1 | Unito: flusso attivazione dedicato app (non toggle script tweak).
- [x] 6 Date Language Region Time.ps1 | source: 3 Setup/6 Date Language Region Time.ps1 | Recuperato in Setup Scripts: impostazioni utente/localizzazione guidate.
- [x] 7 Startup Apps.ps1 | source: 3 Setup/7 Startup Apps.ps1 | Recuperato in Setup Scripts: script reference non operativo.
- [x] 8 Startup Apps.ps1 | source: 3 Setup/8 Startup Apps.ps1 | Recuperato in Setup Scripts: script reference non operativo.
- [x] 9 Background Apps.ps1 | source: 3 Setup/9 Background Apps.ps1 | Convertito in UI & Visuals -> BackgroundAppsOffTweak.
- [x] 10 Edge Settings.ps1 | source: 3 Setup/10 Edge Settings.ps1 | Unito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 11 Store Settings.ps1 | source: 3 Setup/11 Store Settings.ps1 | Unito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 12 Updates Pause.ps1 | source: 3 Setup/12 Updates Pause.ps1 | Recuperato in Setup Scripts: stato temporaneo non stabile come preset.

## 4 Installers
- [x] 1 Installers.ps1 | source: 4 Installers/1 Installers.ps1 | Recuperato in Drivers & Installers: menu downloader/launcher esterni.
- [x] 2 MSI Afterburner.ps1 | source: 4 Installers/2 MSI Afterburner.ps1 | Recuperato in Drivers & Installers: installer tool esterno.
- [x] 3 Nvidia Profile Inspector.ps1 | source: 4 Installers/3 Nvidia Profile Inspector.ps1 | Recuperato in Drivers & Installers: installer tool esterno.
- [x] 4 More Clock Tool.ps1 | source: 4 Installers/4 More Clock Tool.ps1 | Recuperato in Drivers & Installers: utility OC esterna.
- [x] 5 CRU SRE.ps1 | source: 4 Installers/5 CRU SRE.ps1 | Recuperato in Drivers & Installers: utility risoluzione esterna.

## 5 Graphics
- [x] 1 Driver Clean.ps1 | source: 5 Graphics/1 Driver Clean.ps1 | Recuperato in Graphics Scripts: workflow DDU/download esterno.
- [x] 2 Driver Install Latest.ps1 | source: 5 Graphics/2 Driver Install Latest.ps1 | Recuperato in Graphics Scripts: installazione driver online guidata.
- [x] 3 Driver Install Debloat & Settings.ps1 | source: 5 Graphics/3 Driver Install Debloat & Settings.ps1 | Recuperato in Graphics Scripts: pipeline dipendente da tool/driver esterni.
- [x] 4 Nvidia Settings.ps1 | source: 5 Graphics/4 Nvidia Settings.ps1 | Recuperato in Graphics Scripts: tuning vendor-specific ad alta variabilita.
- [x] 5 Amd Settings.ps1 | source: 5 Graphics/5 Amd Settings.ps1 | Recuperato in Graphics Scripts: tuning vendor-specific ad alta variabilita.
- [x] 6 Intel Settings.ps1 | source: 5 Graphics/6 Intel Settings.ps1 | Recuperato in Graphics Scripts: tuning vendor-specific ad alta variabilita.
- [x] 7 Hdcp.ps1 | source: 5 Graphics/7 Hdcp.ps1 | Recuperato in Graphics Scripts: modifica DRM/HDCP ad alto rischio compatibilita.
- [x] 8 P0 State.ps1 | source: 5 Graphics/8 P0 State.ps1 | Recuperato in Graphics Scripts: forzatura power state GPU non universalmente safe.
- [x] 9 Msi Mode.ps1 | source: 5 Graphics/9 Msi Mode.ps1 | Unito in core tweak engine (supporto MSI gia presente in TweakManager).
- [x] 10 DirectX.ps1 | source: 5 Graphics/10 DirectX.ps1 | Recuperato in Graphics Scripts: installer runtime esterno.
- [x] 11 C++.ps1 | source: 5 Graphics/11 C++.ps1 | Recuperato in Graphics Scripts: installer runtime esterno.
- [x] 12 Resolution Refresh Rate.ps1 | source: 5 Graphics/12 Resolution Refresh Rate.ps1 | Recuperato in Graphics Scripts: launcher UI/driver panel, non stato persistente globale.
- [x] 13 Hags Windowed.ps1 | source: 5 Graphics/13 Hags Windowed.ps1 | Unito in Gaming Optimizations -> MpoWindowedOptimizationsOffTweak (parte windowed optimization). Recuperato in Graphics Scripts come script interattivo.

## 6 Windows
- [x] 1 Start Menu Taskbar.ps1 | source: 6 Windows/1 Start Menu Taskbar.ps1 | Convertito in UI & Visuals -> StartMenuTaskbarCleanTweak.
- [x] 2 Start Menu Layout.ps1 | source: 6 Windows/2 Start Menu Layout.ps1 | Unito in UI & Visuals -> StartMenuTaskbarCleanTweak.
- [x] 3 Start Menu Shortcuts.ps1 | source: 6 Windows/3 Start Menu Shortcuts.ps1 | Unito in UI & Visuals -> StartMenuTaskbarCleanTweak.
- [x] 4 Context Menu.ps1 | source: 6 Windows/4 Context Menu.ps1 | Convertito in UI & Visuals -> ContextMenuCleanTweak.
- [x] 5 Theme Black.ps1 | source: 6 Windows/5 Theme Black.ps1 | Convertito in UI & Visuals -> DarkThemeTweak.
- [x] 6 Signout Lockscreen Wallpaper Black.ps1 | source: 6 Windows/6 Signout Lockscreen Wallpaper Black.ps1 | Recuperato in Windows Scripts: dipendenza da asset wallpaper specifico e reset visuale aggressivo.
- [x] 7 User Account Pictures Black.ps1 | source: 6 Windows/7 User Account Pictures Black.ps1 | Recuperato in Windows Scripts: branding visuale non tecnico.
- [x] 8 Widgets.ps1 | source: 6 Windows/8 Widgets.ps1 | Convertito in Privacy & Bloatware -> WidgetsTweak.
- [x] 9 Copilot.ps1 | source: 6 Windows/9 Copilot.ps1 | Convertito in Privacy & Bloatware -> CopilotTweak.
- [x] 10 Gamemode.ps1 | source: 6 Windows/10 Gamemode.ps1 | Recuperato in Windows Scripts: script reference solo launcher ms-settings.
- [x] 11 Pointer Precision.ps1 | source: 6 Windows/11 Pointer Precision.ps1 | Convertito in UI & Visuals -> PointerPrecisionOffTweak (launcher pannello scartato).
- [x] 12 Scaling.ps1 | source: 6 Windows/12 Scaling.ps1 | Recuperato in Windows Scripts: preferenza DPI utente/device-specific.
- [x] 13 Notepad Settings.ps1 | source: 6 Windows/13 Notepad Settings.ps1 | Recuperato in Windows Scripts: personalizzazione app-specific a basso impatto.
- [x] 14 Control Panel Settings.ps1 | source: 6 Windows/14 Control Panel Settings.ps1 | Unito: impostazioni distribuite nei moduli UI & Visuals, System Checks e Power & CPU; parti legacy invasive scartate.
- [x] 15 Sound.ps1 | source: 6 Windows/15 Sound.ps1 | Recuperato in Windows Scripts: dipendenza da driver/audio stack OEM.
- [x] 16 Loudness EQ.ps1 | source: 6 Windows/16 Loudness EQ.ps1 | Recuperato in Windows Scripts: dipendenza tab enhancements driver-specific.
- [x] 17 Device Manager Power Savings & Wake.ps1 | source: 6 Windows/17 Device Manager Power Savings & Wake.ps1 | Unito parzialmente in Networking -> NetworkAdapterPowerSavingsTweak. Recuperato in Windows Scripts come script interattivo completo.
- [x] 18 Network Adapter Power Savings & Wake.ps1 | source: 6 Windows/18 Network Adapter Power Savings & Wake.ps1 | Convertito in Networking -> NetworkAdapterPowerSavingsTweak.
- [x] 19 Network IPv4 Only.ps1 | source: 6 Windows/19 Network IPv4 Only.ps1 | Convertito in Networking -> NetworkIpv4OnlyTweak.
- [x] 20 NVME Faster Driver.ps1 | source: 6 Windows/20 NVME Faster Driver.ps1 | Recuperato in Windows Scripts: override storage driver ad alto rischio compatibilita/boot.
- [x] 21 Write Cache Buffer Flushing.ps1 | source: 6 Windows/21 Write Cache Buffer Flushing.ps1 | Recuperato in Windows Scripts: tuning write-cache ad alto rischio integrita dati.
- [x] 22 Gamebar.ps1 | source: 6 Windows/22 Gamebar.ps1 | Convertito in Privacy & Bloatware -> GameBarTweak.
- [x] 23 Edge & WebView.ps1 | source: 6 Windows/23 Edge & WebView.ps1 | Unito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 24 Bloatware.ps1 | source: 6 Windows/24 Bloatware.ps1 | Convertito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 25 Bloatware Legacy Apps Check.ps1 | source: 6 Windows/25 Bloatware Legacy Apps Check.ps1 | Unito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 26 Bloatware Legacy Features Check.ps1 | source: 6 Windows/26 Bloatware Legacy Features Check.ps1 | Unito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 27 Bloatware UWP Apps Check.ps1 | source: 6 Windows/27 Bloatware UWP Apps Check.ps1 | Unito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 28 Bloatware UWP Features Check.ps1 | source: 6 Windows/28 Bloatware UWP Features Check.ps1 | Unito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 29 Bloatware TaskMgr Check.ps1 | source: 6 Windows/29 Bloatware TaskMgr Check.ps1 | Unito in Privacy & Bloatware -> SafeDebloatPresetTweak.
- [x] 30 Power Plan.ps1 | source: 6 Windows/30 Power Plan.ps1 | Convertito in Power & CPU -> UltimatePerformancePlanTweak + FastStartupHibernateTweak + PowerThrottlingTweak + CpuCoreParkingTweak.
- [x] 31 Timer Resolution.ps1 | source: 6 Windows/31 Timer Resolution.ps1 | Convertito in Gaming Optimizations -> TimerResolutionRequestsTweak.
- [x] 32 UAC.ps1 | source: 6 Windows/32 UAC.ps1 | Convertito in System Checks -> UacOffTweak.
- [x] 33 Core Isolation.ps1 | source: 6 Windows/33 Core Isolation.ps1 | Convertito in System Checks -> CoreIsolationOffTweak.
- [x] 34 Defender Optimize.ps1 | source: 6 Windows/34 Defender Optimize.ps1 | Recuperato in Windows Scripts: hardening/dehardening Defender molto invasivo.
- [x] 35 Autoruns Startup Tasks & Apps Check.ps1 | source: 6 Windows/35 Autoruns Startup Tasks & Apps Check.ps1 | Recuperato in Windows Scripts: tool esterno + pulizia autorun aggressiva.
- [x] 36 Cleanup.ps1 | source: 6 Windows/36 Cleanup.ps1 | Recuperato in Windows Scripts: manutenzione one-shot non stato persistente.
- [x] 37 Restore Point.ps1 | source: 6 Windows/37 Restore Point.ps1 | Recuperato in Windows Scripts: azione one-shot non persistente.

## 7 Hardware
- [x] 2 Background Polling Rate Cap.ps1 | source: 7 Hardware/2 Background Polling Rate Cap.ps1 | Convertito in Drivers & Installers -> BackgroundPollingRateCapTweak.
- [x] 3 Mouse Polling Rate Test.ps1 | source: 7 Hardware/3 Mouse Polling Rate Test.ps1 | Convertito in Drivers & Installers -> MousePollingRateTestTweak.
- [x] 4 Controller Overclock.ps1 | source: 7 Hardware/4 Controller Overclock.ps1 | Convertito in Drivers & Installers -> ControllerOverclockTweak.
- [x] 5 Controller Polling Rate Test.ps1 | source: 7 Hardware/5 Controller Polling Rate Test.ps1 | Convertito in Drivers & Installers -> ControllerPollingRateTestTweak.

## 8 Advanced
- [x] 1 Defender.ps1 | source: 8 Advanced/1 Defender.ps1 | Recuperato in Advanced Scripts: hard-disable Defender/servizi/driver ad alto rischio sicurezza.
- [x] 2 Firewall.ps1 | source: 8 Advanced/2 Firewall.ps1 | Convertito in System Checks -> FirewallOffTweak.
- [x] 3 Spectre Meltdown.ps1 | source: 8 Advanced/3 Spectre Meltdown.ps1 | Convertito in System Checks -> SpectreMeltdownOffTweak.
- [x] 4 Data Execution Prevention.ps1 | source: 8 Advanced/4 Data Execution Prevention.ps1 | Convertito in System Checks -> DataExecutionPreventionOffTweak.
- [x] 5 File Download Security Warning.ps1 | source: 8 Advanced/5 File Download Security Warning.ps1 | Recuperato in Advanced Scripts: indebolimento sicurezza download/browser non raccomandato.
- [x] 6 MMAgent Features.ps1 | source: 8 Advanced/6 MMAgent Features.ps1 | Convertito in Networking -> NetworkMmAgentTweak e in System Checks -> MemoryCompressionOffTweak.
- [x] 7 ReBar Force.ps1 | source: 8 Advanced/7 ReBar Force.ps1 | Recuperato in Advanced Scripts: dipendenza da tool esterni/profili per-game.
- [x] 8 Smt Ht.ps1 | source: 8 Advanced/8 Smt Ht.ps1 | Recuperato in Advanced Scripts: tuning temporaneo per processo, non persistente.
- [x] 9 Core 1 Thread 1.ps1 | source: 8 Advanced/9 Core 1 Thread 1.ps1 | Recuperato in Advanced Scripts: tuning temporaneo per processo, non persistente.
- [x] 10 Priority.ps1 | source: 8 Advanced/10 Priority.ps1 | Recuperato in Advanced Scripts: priorita per-process temporanea, non persistente.
- [x] 11 Mpo.ps1 | source: 8 Advanced/11 Mpo.ps1 | Convertito in Gaming Optimizations -> MpoWindowedOptimizationsOffTweak.
- [x] 12 Hardware Legacy Flip.ps1 | source: 8 Advanced/12 Hardware Legacy Flip.ps1 | Convertito in Gaming Optimizations -> LegacyFlipFseTweak.
- [x] 13 Hardware Composed Independent Flip.ps1 | source: 8 Advanced/13 Hardware Composed Independent Flip.ps1 | Convertito in Gaming Optimizations -> ComposedFlipImmediateModeTweak.
- [x] 14 Ulps.ps1 | source: 8 Advanced/14 Ulps.ps1 | Convertito in Gaming Optimizations -> AmdUlpsOffTweak.
- [x] 15 Driver Whql Secure Boot Bypass.ps1 | source: 8 Advanced/15 Driver Whql Secure Boot Bypass.ps1 | Recuperato in Advanced Scripts: bypass WHQL/SecureBoot ad alto rischio sicurezza.
- [x] 16 Keyboard Shortcuts.ps1 | source: 8 Advanced/16 Keyboard Shortcuts.ps1 | Recuperato in Advanced Scripts: remap globale tastiera aggressivo e lock-out risk.
- [x] 17 Services.ps1 | source: 8 Advanced/17 Services.ps1 | Recuperato in Advanced Scripts: mass-disable servizi molto invasivo con potenziali regressioni critiche.
- [x] 18 Start Search Shell Mobsync.ps1 | source: 8 Advanced/18 Start Search Shell Mobsync.ps1 | Recuperato in Advanced Scripts: tweak servizi shell/search legacy scenario-dependent.

## Note finali
- Tutte le voci Convertito/Unito sono ora tracciate nel codice Dart.
- Le voci precedentemente Scartato nelle sezioni migrate sono state recuperate come Launcher o ScriptInteractive con avvisi aggressivi dove necessario.
- Verifica tecnica eseguita dopo la migrazione: flutter analyze -> nessun errore.
