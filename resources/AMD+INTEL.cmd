@echo off
:: Script di Ottimizzazione Gaming Avanzata
:: Sistema: AMD Ryzen + Intel Arc
:: Esegui come AMMINISTRATORE

echo ================================================
echo    Ottimizzazione Gaming Sistema AMD/Intel
echo ================================================
echo.
echo Sistema Target: AMD Ryzen + Intel Arc
echo.
echo ATTENZIONE: Verranno applicate modifiche avanzate
echo Assicurati di aver fatto un backup del sistema
echo.
pause

:: Verifica privilegi amministratore
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERRORE: Esegui come Amministratore!
    pause
    exit /b 1
)

echo.
echo [1/11] Configurazione BCDedit - Boot e Sistema...
:: Disabilita Dynamic Tick (migliora latenza timer)
bcdedit /set disabledynamictick yes

:: Disabilita HPET (High Precision Event Timer)
bcdedit /deletevalue useplatformclock

:: TSC come timer principale (migliore per Ryzen)
bcdedit /set useplatformtick yes
bcdedit /set tscsyncpolicy enhanced

:: Ottimizzazioni memoria e CPU
bcdedit /set firstmegabytepolicy UseAll
bcdedit /set avoidlowmemory 0x8000000
bcdedit /set nolowmem yes

:: MSI mode e interrupt handling
bcdedit /set x2apicpolicy Enable
bcdedit /set configaccesspolicy Default
bcdedit /set MSI Default

:: Ottimizzazioni varie
bcdedit /set bootux disabled
bcdedit /set bootmenupolicy legacy
bcdedit /set quietboot yes

echo BCDedit configurato.

echo.
echo [2/11] CPU Unparking - Tutti i thread...
:: Disabilita Parking per tutti i core
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMax" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "ValueMin" /t REG_DWORD /d "0" /f

:: Disabilita Core Parking
reg add "HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583" /v "Attributes" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CoreParkingDisabled" /t REG_DWORD /d "1" /f


powercfg -setactive scheme_current

echo.
echo [4/11] Win32PrioritySeparation - Priorità ai giochi...
:: Ottimizza scheduling per foreground applications (giochi)
:: Valore 0x26 = ottimale per gaming (short, variable, foreground boost)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "0x00000026" /f

echo Win32PrioritySeparation configurato per gaming.

echo.
echo [5/11] Ottimizzazioni GPU Intel Arc...
:: Priorità GPU massima
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d "6" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f

:: Hardware Accelerated GPU Scheduling - ABILITATO (Intel Arc ne beneficia)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f

:: TdrDelay aumentato (Intel Arc può avere timeout driver sotto carichi pesanti)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDelay" /t REG_DWORD /d "60" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "TdrDdiDelay" /t REG_DWORD /d "60" /f

:: INTEL ARC SPECIFICO - Disabilita Panel Self Refresh (PSR)
:: Riduce latenza display ma aumenta consumo
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Disable_OverlayDSQualityEnhancement" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001" /v "Disable_OverlayDSQualityEnhancement" /t REG_DWORD /d "1" /f

:: INTEL ARC SPECIFICO - Disabilita Display Power Saving Technology (DPST)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DpstEnable" /t REG_DWORD /d "0" /f

:: INTEL ARC SPECIFICO - Xe Super Sampling (XeSS) preparazione
:: Assicura che i driver abbiano accesso completo alle risorse
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_EnableComputePreemption" /t REG_DWORD /d "0" /f

:: INTEL ARC SPECIFICO - Disabilita Frame Rate Target Control
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "KMD_FRTCEnable" /t REG_DWORD /d "0" /f

:: INTEL ARC SPECIFICO - Media acceleration sempre on
reg add "HKLM\SOFTWARE\Intel\Display\igfxcui\Media" /v "EnableIntelHWAccel" /t REG_DWORD /d "1" /f

:: INTEL ARC SPECIFICO - Disabilita GPU power saving states
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_GPUPowerDownEnabled" /t REG_DWORD /d "0" /f

:: INTEL ARC SPECIFICO - Disabilita Render Standby
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "RenderStandbyEnabled" /t REG_DWORD /d "0" /f

:: INTEL ARC SPECIFICO - Memory clock sempre massimo
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PP_MemClockStateDisable" /t REG_DWORD /d "1" /f

:: INTEL ARC SPECIFICO - Disabilita ASPM (Active State Power Management) PCIe
:: Importante per Arc che usa PCIe 4.0/5.0
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableASPM" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001" /v "EnableASPM" /t REG_DWORD /d "0" /f

:: INTEL ARC SPECIFICO - Disabilita ULPS (Ultra Low Power State)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001" /v "EnableUlps" /t REG_DWORD /d "0" /f

:: INTEL ARC SPECIFICO - Disabilita Deep Link Hyper Encode (se causa problemi)
:: Questa feature aiuta con encoding video ma può interferire con gaming
reg add "HKLM\SOFTWARE\Intel\Display\igfxcui\Media" /v "EnableDeepLink" /t REG_DWORD /d "0" /f

:: INTEL ARC SPECIFICO - VRR/Adaptive Sync ottimizzato
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "Adaptive Sync" /t REG_DWORD /d "1" /f

:: INTEL ARC SPECIFICO - Disabilita Intel Application Optimization
:: Lascia controllo manuale delle impostazioni
reg add "HKLM\SOFTWARE\Intel\Display\igfxcui\profiles" /v "DisableAppOpt" /t REG_DWORD /d "1" /f

:: INTEL ARC SPECIFICO - DirectX 12 Ultimate ottimizzazioni
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "DirectXUserGlobalSettings" /t REG_SZ /d "PreferMaximumPerformance=1" /f

:: INTEL ARC SPECIFICO - Resizable BAR forzato (se supportato dal BIOS)
:: Arc beneficia enormemente da ReBAR
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableResizableBAR" /t REG_DWORD /d "1" /f

:: INTEL ARC SPECIFICO - Shader Cache Size aumentato (Arc compila molti shader)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ShaderCache" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "ShaderCacheSize" /t REG_QWORD /d "0x0000000100000000" /f

echo GPU Intel Arc ottimizzata.

echo.
echo [6/11] Ottimizzazioni RAM...
:: Disabilita paging executive
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f

:: Large System Cache disabilitato (migliore per gaming)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f

:: ClearPageFileAtShutdown disabilitato (velocizza shutdown)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "ClearPageFileAtShutdown" /t REG_DWORD /d "0" /f

:: Disabilita superfetch e prefetch per SSD NVMe
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f

:: Feature Settings Override (disabilita paging aggressivo)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f

echo RAM ottimizzata.

echo.
echo [7/11] Ottimizzazioni SSD NVMe...
:: Disabilita indicizzazione (inutile per gaming)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableBootTrace" /t REG_DWORD /d "0" /f

:: NTFS performance
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d "2" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMftZoneReservation" /t REG_DWORD /d "1" /f

:: Disabilita compressione NTFS
fsutil behavior set disablecompression 1

:: Ottimizza NTFS
fsutil behavior set encryptpagingfile 0

echo SSD NVMe ottimizzato.

echo.
echo [8/11] Network e Interrupt Moderation...
:: NetworkThrottlingIndex disabilitato (massime prestazioni rete)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d "0xffffffff" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d "0" /f

:: TCP Optimizer
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxDupAcks" /t REG_DWORD /d "2" /f

:: Interrupt moderation
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DpcWatchdogProfileOffset" /t REG_DWORD /d "10000" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DpcTimeout" /t REG_DWORD /d "0" /f

echo Network e interrupt ottimizzati.

echo.
echo [9/11] Timer Resolution e Latenza Sistema...

:: MMCSS (Multimedia Class Scheduler Service) ottimizzato
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NoLazyMode" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "AlwaysOn" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "LazyModeTimeout" /t REG_DWORD /d "10000" /f

:: Audio latency ridotta
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Affinity" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Background Only" /t REG_SZ /d "False" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Clock Rate" /t REG_DWORD /d "10000" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "GPU Priority" /t REG_DWORD /d "8" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Priority" /t REG_DWORD /d "6" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "Scheduling Category" /t REG_SZ /d "High" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" /v "SFIO Priority" /t REG_SZ /d "High" /f

echo Timer e latenza ottimizzati.

echo.
echo [10/11] Servizi Windows e tweaks finali...
:: Disabilita Spectre/Meltdown mitigations
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f

:: Disabilita Windows Search
sc config "WSearch" start=disabled

:: Disabilita SysMain (Superfetch/Prefetch)
sc config "SysMain" start=disabled

:: Power Throttling disabilitato
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f

:: Disabilita Fullscreen Optimizations (migliore per alcuni giochi)
reg add "HKCU\SYSTEM\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
reg add "HKCU\SYSTEM\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
reg add "HKCU\SYSTEM\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f
reg add "HKCU\SYSTEM\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f

:: Disabilita Game DVR
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f

echo.
echo [11/11] Ottimizzazioni Sistema - Fluidita e Responsivita...

:: ====== GAME MODE - DISABILITATO ======
:: Game Mode può causare micro-stutter e problemi di scheduling
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f

echo Game Mode disabilitato.

:: ====== EFFETTI VISIVI - PRESTAZIONI MASSIME ======
:: Disabilita animazioni e trasparenze
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d "2" /f

:: Disabilita animazioni finestre
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d "0" /f

:: Disabilita animazioni taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAnimations" /t REG_DWORD /d "0" /f

:: Disabilita peek preview
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisablePreviewDesktop" /t REG_DWORD /d "1" /f

:: Disabilita Aero Shake
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisallowShaking" /t REG_DWORD /d "1" /f

:: Disabilita suggerimenti Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /t REG_DWORD /d "0" /f

echo Effetti visivi disabilitati.

:: ====== TRASPARENZA E BLUR - COMPLETAMENTE OFF ======
:: Disabilita trasparenza (Acrylic/Mica)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f

:: Disabilita blur effetti
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "0" /f

:: Disabilita animazioni Start Menu
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d "0" /f

:: Disabilita notifiche animazioni
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "EnableBalloonTips" /t REG_DWORD /d "0" /f

echo Trasparenza e blur disabilitati.

:: ====== RESPONSIVITA SISTEMA ======
:: Menu veloce (riduce delay apertura menu contestuale)
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f

:: Riduce hover time (tooltip e preview)
reg add "HKCU\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "10" /f

:: Velocizza animazioni finestre
reg add "HKCU\Control Panel\Desktop" /v "UserPreferencesMask" /t REG_BINARY /d "9012038010000000" /f

:: Kill app non responsive immediate
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "2000" /f

:: Servizi non responsive veloce kill
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "2000" /f

echo Responsivita sistema migliorata.

:: ====== TELEMETRIA - DISABILITAZIONE COMPLETA ======
:: Telemetry Service disabilitato
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f

:: Disabilita DiagTrack
sc config "DiagTrack" start=disabled
sc stop "DiagTrack" >nul 2>&1

:: Disabilita dmwappushservice
sc config "dmwappushservice" start=disabled
sc stop "dmwappushservice" >nul 2>&1

:: Disabilita servizi telemetria
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f

:: Disabilita feedback automatico
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d "0" /f

:: Disabilita Cortana telemetry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f

:: Disabilita app background
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d "1" /f

:: Disabilita advertising ID
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d "0" /f

:: Disabilita sync settings
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync" /v "SyncPolicy" /t REG_DWORD /d "5" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d "0" /f

:: Disabilita Activity History
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f

:: Disabilita Windows Error Reporting
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f
sc config "WerSvc" start=disabled
sc stop "WerSvc" >nul 2>&1

:: Disabilita Customer Experience Improvement Program
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient" /v "CEIPEnable" /t REG_DWORD /d "0" /f

:: Disabilita Application Telemetry
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d "1" /f

:: Disabilita Steps Recorder
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f

echo Telemetria completamente disabilitata.

:: ====== SERVIZI INUTILI - DISABILITAZIONE ======
:: Xbox Services (se non usi Xbox)
sc config "XblAuthManager" start=disabled
sc config "XblGameSave" start=disabled
sc config "XboxGipSvc" start=disabled
sc config "XboxNetApiSvc" start=disabled

:: Diagnostica
sc config "DPS" start=disabled
sc config "WdiServiceHost" start=disabled
sc config "WdiSystemHost" start=disabled

:: Remote Registry e Desktop
sc config "RemoteRegistry" start=disabled
sc config "RemoteAccess" start=disabled

:: Maps
sc config "MapsBroker" start=disabled

:: Retail Demo
sc config "RetailDemo" start=disabled

:: Print Spooler (se non usi stampanti)
:: sc config "Spooler" start=disabled

:: Fax (se non usi fax)
sc config "Fax" start=disabled

:: Windows Insider
sc config "wisvc" start=disabled

:: Parental Controls
sc config "WpcMonSvc" start=disabled

echo Servizi inutili disabilitati.

:: ====== TASKBAR E START MENU OTTIMIZZATI ======
:: Disabilita widgets
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d "0" /f

:: Disabilita Task View
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f

:: Disabilita Search Box (usa solo icona)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f

:: Disabilita Meet Now
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d "1" /f

:: Disabilita News and Interests
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f

:: Disabilita People sulla taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /t REG_DWORD /d "0" /f

:: Combina pulsanti taskbar (mai = più responsive)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d "2" /f

:: Disabilita notifiche badge su taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarBadges" /t REG_DWORD /d "0" /f

echo Taskbar ottimizzata.

:: ====== PRIVACY E TRACKING ======
:: Disabilita location tracking
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d "1" /f

:: Disabilita suggerimenti in Start
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t REG_DWORD /d "0" /f

:: Disabilita apps suggerite
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d "0" /f

:: Disabilita tips Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t REG_DWORD /d "0" /f

:: Disabilita Windows Spotlight
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d "0" /f

:: Disabilita app silently install
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d "0" /f

:: Disabilita pre-installed apps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d "0" /f

:: Disabilita OEM pre-installed apps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OEMPreInstalledAppsEnabled" /t REG_DWORD /d "0" /f

echo Privacy e tracking disabilitati.

:: ====== EXPLORER OTTIMIZZAZIONI ======
:: Disabilita thumbnails cache
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisableThumbnailCache" /t REG_DWORD /d "1" /f

:: Disabilita thumbnails su network
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "DisableThumbsDBOnNetworkFolders" /t REG_DWORD /d "1" /f

:: Mostra file nascosti e estensioni (utile per gaming mods)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

:: Disabilita Quick Access tracking
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d "0" /f

:: Launch folder windows in separate process (più stabile)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t REG_DWORD /d "1" /f

echo Explorer ottimizzato.

:: ====== NOTIFICHE - MINIMAL ======
:: Disabilita notifiche sistema
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f

:: Disabilita focus assist auto-rules
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" /v "FocusAssistAutoRules" /t REG_DWORD /d "0" /f

:: Disabilita notifiche lockscreen
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f

echo Notifiche minimizzate.

:: ====== WINDOWS UPDATE - OTTIMIZZATO (NON DISABILITATO) ======
:: Disabilita riavvio automatico
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "1" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUPowerManagement" /t REG_DWORD /d "0" /f

:: Disabilita delivery optimization (P2P updates)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "DODownloadMode" /t REG_DWORD /d "0" /f

:: Limita bandwidth updates (lascia 50% per gaming)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "PercentageMaxBackgroundBandwidth" /t REG_DWORD /d "50" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v "PercentageMaxForegroundBandwidth" /t REG_DWORD /d "50" /f

echo Servizi e tweaks completati.

echo.
echo ================================================
echo    OTTIMIZZAZIONE COMPLETATA CON SUCCESSO!
echo ================================================
echo.
echo Modifiche applicate:
echo - BCDedit: timer, HPET, TSC, mitigazioni
echo - CPU: all thread unparked, C-States disabilitati
echo - GPU: Priorità massima, preemption disabilitata
echo - RAM: ottimizzata, paging executive off
echo - SSD: NTFS ottimizzato, indicizzazione off
echo - Network: Throttling off, TCP ottimizzato
echo - Timer: Resolution migliorata, latenza ridotta
echo - Sistema: Servizi inutili disabilitati
echo.
echo RIAVVIA IL SISTEMA per applicare tutte le modifiche.
echo.
pause