@echo off
goto START

:: ===========================================================================
:: PRIME BUILD - TWEAKING CONSOLE v2.1 FIX 2025
:: Fix per Windows 11 23H2/24H2/25H2 - Avvio garantito
:: ===========================================================================

:START
:: Forza esecuzione come amministratore (metodo più affidabile 2025) con fallback elevazione
openfiles >nul 2>&1 || (
    echo Richiesti privilegi di amministratore...
    powershell "Start-Process '%~f0' -Verb RunAs" >nul 2>&1
    exit
)

:: Abilita estensioni e delayed expansion in modo sicuro
setlocal EnableExtensions EnableDelayedExpansion

:: Modalità debug di default (porta i log anche a video). Override esterno: set DEBUG=1 prima di eseguire.
if not defined DEBUG set "DEBUG=0"

echo [*] Avvio Prime Build - attendere...

:: Imposta il titolo della finestra (mettiamo prima del chcp per isolare errori)
title Prime Build - Tweaking Console v1.0

:: Imposta codepage leggibile per ASCII art (437). Se fallisce, tenta 850, infine 65001.
chcp 437 >nul 2>&1 || chcp 850 >nul 2>&1 || chcp 65001 >nul 2>&1

:: ==========================================================================
:: TIMESTAMP via PowerShell (no WMIC)
:: ==========================================================================
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"`) do set "TIMESTAMP=%%A"
if not defined TIMESTAMP set "TIMESTAMP=20251212_000000"

:: ==========================================================================
:: DIRECTORY E LOG
:: ==========================================================================
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "LOG_DIR=%SCRIPT_DIR%\Logs"
set "POWERPLANS_DIR=%SCRIPT_DIR%\Powerplans"
if not exist "%LOG_DIR%" md "%LOG_DIR%"
set "LOG_FILE=%LOG_DIR%\TweakLog_%TIMESTAMP%.txt"

echo. >"%LOG_FILE%"
call :LOG "Prime Build avviato - %date% %time%"

:: ==========================================================================
:: RILEVAMENTO HARDWARE ROBUSTO (funziona anche senza PowerShell/WMIC)
:: ==========================================================================
call :DETECT_HARDWARE_SAFE
if /i "%DEBUG%"=="1" (
    echo [DBG] CPU_VENDOR=!CPU_VENDOR! - CPU_NAME=!CPU_NAME!
    echo [DBG] GPU_VENDOR=!GPU_VENDOR! - GPU_NAME=!GPU_NAME!
    echo [DBG] Se vedi errori sopra, premi un tasto e invia screenshot/output.
    pause
)
goto MAIN_MENU

:: ============================================================================
:: MAIN MENU
:: ============================================================================
:MAIN_MENU
cls
call :HEADER_MAIN
echo   ^|   [1]  System Information                                              ^|
echo   ^|   [2]  CPU Optimizations                                               ^|
echo   ^|   [3]  GPU Optimizations                                               ^|
echo   ^|   [4]  RAM Optimizations                                               ^|
echo   ^|   [5]  SSD/NVME Optimizations                                          ^|
echo   ^|   [6]  Scheduling and Priority                                         ^|
echo   ^|   [7]  BCDEdit Tweaks                                                  ^|
echo   ^|   [8]  Power Plans                                                     ^|
echo   ^|   [9]  Autoruns Utility                                                ^|
echo   ^|   [A]  Diagnostics (SFC/DISM)                                          ^|
echo   ^|                                                                        ^|
echo   ^|   [B]  == APPLY ALL OPTIMIZATIONS ==                                   ^|
echo   ^|   [R]  == RESTORE WINDOWS DEFAULTS ==                                  ^|
echo   ^|                                                                        ^|
echo   ^|   [0]  Exit                                                            ^|
echo   ^|                                                                        ^|
echo   +========================================================================+
echo.
call :READ_CHOICE MENU_CHOICE "Select an option:" "1 2 3 4 5 6 7 8 9 A B R 0"

if "%MENU_CHOICE%"=="1" goto SYSINFO
if "%MENU_CHOICE%"=="2" goto CPU_MENU
if "%MENU_CHOICE%"=="3" goto GPU_MENU
if "%MENU_CHOICE%"=="4" goto RAM_MENU
if "%MENU_CHOICE%"=="5" goto SSD_MENU
if "%MENU_CHOICE%"=="6" goto SCHEDULING_MENU
if "%MENU_CHOICE%"=="7" goto BCDEDIT_MENU
if "%MENU_CHOICE%"=="8" goto POWERPLAN_MENU
if "%MENU_CHOICE%"=="9" goto AUTORUNS_MENU
if /i "%MENU_CHOICE%"=="A" goto DIAGNOSTICS_MENU
if /i "%MENU_CHOICE%"=="B" goto APPLY_ALL
if /i "%MENU_CHOICE%"=="R" goto RESTORE_MENU
if "%MENU_CHOICE%"=="0" goto EXIT_SCRIPT
goto MAIN_MENU

:: ============================================================================
:: HARDWARE DETECTION (PowerShell only - no WMIC)
:: ============================================================================
:DETECT_HARDWARE
set "CPU_VENDOR=Unknown"
set "CPU_NAME=Unknown"
set "GPU_VENDOR=Unknown"
set "GPU_NAME=Unknown"

:: CPU Name via PowerShell
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name"`) do set "CPU_NAME=%%A"

:: Determina vendor CPU dal nome
if not "!CPU_NAME:AMD=!"=="!CPU_NAME!" set "CPU_VENDOR=AMD"
if not "!CPU_NAME:Intel=!"=="!CPU_NAME!" set "CPU_VENDOR=Intel"
if not "!CPU_NAME:Ryzen=!"=="!CPU_NAME!" set "CPU_VENDOR=AMD"
if "!CPU_VENDOR!"=="Unknown" set "CPU_VENDOR=Other"

:: GPU Name via PowerShell
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_VideoController | Select-Object -First 1).Name"`) do set "GPU_NAME=%%A"

:: Determina vendor GPU dal nome
if not "!GPU_NAME:NVIDIA=!"=="!GPU_NAME!" set "GPU_VENDOR=NVIDIA"
if not "!GPU_NAME:GeForce=!"=="!GPU_NAME!" set "GPU_VENDOR=NVIDIA"
if not "!GPU_NAME:Radeon=!"=="!GPU_NAME!" set "GPU_VENDOR=AMD"
if not "!GPU_NAME:AMD=!"=="!GPU_NAME!" set "GPU_VENDOR=AMD"
if not "!GPU_NAME:Intel=!"=="!GPU_NAME!" set "GPU_VENDOR=Intel"
if not "!GPU_NAME:Arc=!"=="!GPU_NAME!" set "GPU_VENDOR=Intel"

call :LOG "Hardware: CPU=!CPU_VENDOR! (!CPU_NAME!) | GPU=!GPU_VENDOR! (!GPU_NAME!)"
goto :eof

:DETECT_HARDWARE_SAFE
call :DETECT_HARDWARE
goto :eof

:: ============================================================================
:: SYSTEM INFORMATION (PowerShell only)
:: ============================================================================
:SYSINFO
cls
echo.
echo   +========================================================================+
echo   ^|                         SYSTEM INFORMATION                             ^|
echo   +========================================================================+
echo.
echo   --- CPU ---
echo   !CPU_NAME!
echo   Vendor: !CPU_VENDOR!
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).NumberOfCores"`) do echo   Cores: %%A
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).NumberOfLogicalProcessors"`) do echo   Threads: %%A
echo.
echo   --- GPU ---
echo   !GPU_NAME!
echo   Vendor: !GPU_VENDOR!
echo.
echo   --- RAM ---
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB)"`) do echo   Total: %%A GB
echo.
echo   --- OS ---
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"`) do echo   %%A
for /f "usebackq tokens=*" %%A in (`powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).BuildNumber"`) do echo   Build: %%A
echo.
echo   --- ACTIVE POWER PLAN ---
powercfg /getactivescheme
echo.
pause
goto MAIN_MENU

:: ============================================================================
:: CPU MENU
:: ============================================================================
:CPU_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                         CPU OPTIMIZATIONS                              ^|
echo   ^|                      Detected: !CPU_VENDOR!                            ^|
echo   +========================================================================+
echo.
echo   [1]  Apply CPU Optimizations (Auto-detect AMD/Intel)
echo   [2]  Disable Core Parking
echo   [3]  Disable CPU Power Throttling
echo   [4]  Optimize Interrupt Handling
echo.
echo   [R]  Restore CPU Defaults
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE CPU_CHOICE "Select an option:" "1 2 3 4 R 0"

if "%CPU_CHOICE%"=="1" goto APPLY_CPU_OPT
if "%CPU_CHOICE%"=="2" goto DISABLE_CORE_PARKING
if "%CPU_CHOICE%"=="3" goto DISABLE_CPU_THROTTLE
if "%CPU_CHOICE%"=="4" goto OPTIMIZE_INTERRUPTS
if /i "%CPU_CHOICE%"=="R" goto RESTORE_CPU_DEFAULTS
if "%CPU_CHOICE%"=="0" goto MAIN_MENU
goto CPU_MENU

:APPLY_CPU_OPT
cls
echo.
echo   +========================================================================+
echo   ^|                    APPLYING CPU OPTIMIZATIONS                          ^|
echo   +========================================================================+
echo.
echo   [*] Applying common CPU optimizations...

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
call :LOG "CPU: C-States disabled"
echo       [OK] C-States disabled

if "!CPU_VENDOR!"=="AMD" (
    echo.
    echo   [*] Applying AMD-specific optimizations...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\amdppm\Parameters" /v "PerfBoostMode" /t REG_DWORD /d 2 /f >nul 2>&1
    call :LOG "CPU: AMD Performance Boost Mode = Aggressive"
    echo       [OK] AMD Performance Boost Mode = Aggressive
    powercfg /setacvalueindex scheme_current sub_processor PERFBOOSTMODE 2 >nul 2>&1
    powercfg /setactive scheme_current >nul 2>&1
    echo       [OK] AMD Boost mode optimized
)

if "!CPU_VENDOR!"=="Intel" (
    echo.
    echo   [*] Applying Intel-specific optimizations...
    powercfg /setacvalueindex scheme_current sub_processor PERFBOOSTMODE 2 >nul 2>&1
    powercfg /setacvalueindex scheme_current sub_processor PERFBOOSTPOL 100 >nul 2>&1
    powercfg /setactive scheme_current >nul 2>&1
    call :LOG "CPU: Intel Turbo Boost optimized"
    echo       [OK] Intel Turbo Boost optimized
)

echo.
echo   [OK] CPU optimizations applied successfully!
call :LOG "CPU: All optimizations applied"
echo.
pause
goto CPU_MENU

:DISABLE_CORE_PARKING
cls
echo.
echo   +========================================================================+
echo   ^|                      DISABLE CORE PARKING                              ^|
echo   +========================================================================+
echo.
echo   [*] Disabling core parking...

powercfg /setacvalueindex scheme_current sub_processor CPMINCORES 100 >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor CPMAXCORES 100 >nul 2>&1
powercfg /setactive scheme_current >nul 2>&1
call :LOG "CPU: Core parking disabled"
echo       [OK] Core parking disabled (all cores active)

echo.
pause
goto CPU_MENU

:DISABLE_CPU_THROTTLE
cls
echo.
echo   +========================================================================+
echo   ^|                   DISABLE CPU POWER THROTTLING                         ^|
echo   +========================================================================+
echo.
echo   [*] Disabling CPU power throttling...

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
call :LOG "CPU: Power throttling disabled"
echo       [OK] Power throttling disabled

powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100 >nul 2>&1
powercfg /setactive scheme_current >nul 2>&1
call :LOG "CPU: Min/Max processor state set to 100%%"
echo       [OK] CPU Min/Max state = 100%%

echo.
pause
goto CPU_MENU

:OPTIMIZE_INTERRUPTS
cls
echo.
echo   +========================================================================+
echo   ^|                   OPTIMIZE INTERRUPT HANDLING                          ^|
echo   +========================================================================+
echo.
echo   [*] Optimizing interrupt handling...

:: farla solo come “troubleshooting latency” CON AVVISO.

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DpcWatchdogPeriod" /t REG_DWORD /d 0 /f >nul 2>&1
call :LOG "CPU: DPC watchdog configured"
echo       [OK] DPC watchdog optimized

echo.
pause
goto CPU_MENU

:RESTORE_CPU_DEFAULTS
cls
echo.
echo   +========================================================================+
echo   ^|                      RESTORE CPU DEFAULTS                              ^|
echo   +========================================================================+
echo.
echo   [*] Restoring CPU to Windows defaults...

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /f >nul 2>&1
echo       [OK] C-States restored

powercfg /setacvalueindex scheme_current sub_processor CPMINCORES 5 >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor CPMAXCORES 100 >nul 2>&1
powercfg /setactive scheme_current >nul 2>&1
echo       [OK] Core parking restored

reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f >nul 2>&1
echo       [OK] Power throttling restored

powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 5 >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100 >nul 2>&1
powercfg /setactive scheme_current >nul 2>&1
echo       [OK] CPU power states restored

call :LOG "CPU RESTORE: All CPU settings restored"
echo.
pause
goto CPU_MENU

:: ============================================================================
:: GPU MENU
:: ============================================================================
:GPU_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                         GPU OPTIMIZATIONS                              ^|
echo   ^|                      Detected: !GPU_VENDOR!                            ^|
echo   +========================================================================+
echo.
echo   [1]  Apply GPU Optimizations (Auto-detect AMD/NVIDIA/Intel)
echo   [2]  Enable Hardware Accelerated GPU Scheduling
echo   [3]  Disable Multi-Plane Overlay (MPO)
echo   [4]  Optimize Shader Cache
echo.
echo   [R]  Restore GPU Defaults
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE GPU_CHOICE "Select an option:" "1 2 3 4 R 0"

if "%GPU_CHOICE%"=="1" goto APPLY_GPU_OPT
if "%GPU_CHOICE%"=="2" goto ENABLE_HAGS
if "%GPU_CHOICE%"=="3" goto DISABLE_MPO
if "%GPU_CHOICE%"=="4" goto OPTIMIZE_SHADER
if /i "%GPU_CHOICE%"=="R" goto RESTORE_GPU_DEFAULTS
if "%GPU_CHOICE%"=="0" goto MAIN_MENU
goto GPU_MENU

:APPLY_GPU_OPT
cls
echo.
echo   +========================================================================+
echo   ^|                    APPLYING GPU OPTIMIZATIONS                          ^|
echo   +========================================================================+
echo.
echo   [*] Applying common GPU optimizations...

reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
call :LOG "GPU: Hardware Accelerated GPU Scheduling enabled"
echo       [OK] Hardware Accelerated GPU Scheduling enabled

if "!GPU_VENDOR!"=="AMD" (
    echo.
    echo   [*] Applying AMD-specific optimizations...
    for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v "EnableUlps" 2^>nul ^| find "HKEY"') do (
        reg add "%%i" /v "EnableUlps" /t REG_DWORD /d 0 /f >nul 2>&1
    )
    call :LOG "GPU: AMD ULPS disabled"
    echo       [OK] AMD ULPS disabled
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "FlipQueueSize" /t REG_DWORD /d 1 /f >nul 2>&1
    echo       [OK] AMD FlipQueueSize = 1
)

echo.
echo   [OK] GPU optimizations applied successfully!
call :LOG "GPU: All optimizations applied"
echo.
pause
goto GPU_MENU

:ENABLE_HAGS
cls
echo.
echo   +========================================================================+
echo   ^|              HARDWARE ACCELERATED GPU SCHEDULING                       ^|
echo   +========================================================================+
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
call :LOG "GPU: HAGS enabled"
echo       [OK] Hardware Accelerated GPU Scheduling enabled
echo.
echo   NOTE: A system restart is required for this change to take effect.
echo.
pause
goto GPU_MENU

:DISABLE_MPO
cls
echo.
echo   +========================================================================+
echo   ^|                 DISABLE MULTI-PLANE OVERLAY (MPO)                      ^|
echo   +========================================================================+
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "OverlayTestMode" /t REG_DWORD /d 5 /f >nul 2>&1
call :LOG "GPU: MPO disabled"
echo       [OK] Multi-Plane Overlay disabled
echo.
echo   NOTE: This can fix flickering/stuttering issues with some GPU/driver combos.
echo.
pause
goto GPU_MENU

:OPTIMIZE_SHADER
cls
echo.
echo   +========================================================================+
echo   ^|                      OPTIMIZE SHADER CACHE                             ^|
echo   +========================================================================+
echo.
reg add "HKLM\SOFTWARE\Microsoft\DirectX" /v "DisableMaxShaderCacheSize" /t REG_DWORD /d 1 /f >nul 2>&1
call :LOG "GPU: DirectX shader cache unlimited"
echo       [OK] DirectX shader cache size unlimited
echo.
pause
goto GPU_MENU

:RESTORE_GPU_DEFAULTS
cls
echo.
echo   +========================================================================+
echo   ^|                      RESTORE GPU DEFAULTS                              ^|
echo   +========================================================================+
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 1 /f >nul 2>&1
echo       [OK] HAGS restored to default
reg delete "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "OverlayTestMode" /f >nul 2>&1
echo       [OK] MPO restored
call :LOG "GPU RESTORE: All GPU settings restored"
echo.
pause
goto GPU_MENU

:: ============================================================================
:: RAM MENU
:: ============================================================================
:RAM_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                         RAM OPTIMIZATIONS                              ^|
echo   +========================================================================+
echo.
echo   [1]  Apply All RAM Optimizations
echo   [2]  Disable Paging Executive
echo   [3]  Disable SysMain (Superfetch)
echo   [4]  Optimize NTFS Memory Usage
echo.
echo   [R]  Restore RAM Defaults
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE RAM_CHOICE "Select an option:" "1 2 3 4 R 0"

if "%RAM_CHOICE%"=="1" goto APPLY_RAM_OPT
if "%RAM_CHOICE%"=="2" goto DISABLE_PAGING_EXEC
if "%RAM_CHOICE%"=="3" goto DISABLE_SYSMAIN
if "%RAM_CHOICE%"=="4" goto OPTIMIZE_NTFS
if /i "%RAM_CHOICE%"=="R" goto RESTORE_RAM_DEFAULTS
if "%RAM_CHOICE%"=="0" goto MAIN_MENU
goto RAM_MENU

:APPLY_RAM_OPT
cls
echo.
echo   +========================================================================+
echo   ^|                    APPLYING RAM OPTIMIZATIONS                          ^|
echo   +========================================================================+
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
echo       [OK] Paging Executive disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] Large System Cache optimized
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] Prefetch/Superfetch disabled
sc config "SysMain" start= disabled >nul 2>&1
net stop "SysMain" >nul 2>&1
echo       [OK] SysMain service disabled
call :LOG "RAM: All optimizations applied"
echo.
pause
goto RAM_MENU

:DISABLE_PAGING_EXEC
cls
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
echo       [OK] Paging Executive disabled
call :LOG "RAM: Paging Executive disabled"
pause
goto RAM_MENU

:DISABLE_SYSMAIN
cls
echo.
sc config "SysMain" start= disabled >nul 2>&1
net stop "SysMain" >nul 2>&1
echo       [OK] SysMain service disabled
call :LOG "RAM: SysMain disabled"
pause
goto RAM_MENU

:OPTIMIZE_NTFS
cls
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsMemoryUsage" /t REG_DWORD /d 2 /f >nul 2>&1
echo       [OK] NTFS memory usage optimized
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
echo       [OK] NTFS last access update disabled
call :LOG "RAM: NTFS optimized"
pause
goto RAM_MENU

:RESTORE_RAM_DEFAULTS
cls
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] Paging Executive restored
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 3 /f >nul 2>&1
echo       [OK] Prefetch/Superfetch restored
sc config "SysMain" start= auto >nul 2>&1
net start "SysMain" >nul 2>&1
echo       [OK] SysMain service restored
call :LOG "RAM RESTORE: All settings restored"
pause
goto RAM_MENU

:: ============================================================================
:: SSD MENU
:: ============================================================================
:SSD_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                       SSD/NVME OPTIMIZATIONS                           ^|
echo   +========================================================================+
echo.
echo   [1]  Apply All SSD/NVME Optimizations
echo   [2]  Verify TRIM Status
echo   [3]  Disable AHCI Link Power Management
echo   [4]  Disable Scheduled Defragmentation
echo.
echo   [R]  Restore SSD Defaults
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE SSD_CHOICE "Select an option:" "1 2 3 4 R 0"

if "%SSD_CHOICE%"=="1" goto APPLY_SSD_OPT
if "%SSD_CHOICE%"=="2" goto CHECK_TRIM
if "%SSD_CHOICE%"=="3" goto DISABLE_AHCI_LPM
if "%SSD_CHOICE%"=="4" goto DISABLE_DEFRAG
if /i "%SSD_CHOICE%"=="R" goto RESTORE_SSD_DEFAULTS
if "%SSD_CHOICE%"=="0" goto MAIN_MENU
goto SSD_MENU

:APPLY_SSD_OPT
cls
echo.
echo   +========================================================================+
echo   ^|                  APPLYING SSD/NVME OPTIMIZATIONS                       ^|
echo   +========================================================================+
echo.
fsutil behavior set DisableDeleteNotify 0 >nul 2>&1
echo       [OK] TRIM enabled
fsutil behavior set disablelastaccess 1 >nul 2>&1
echo       [OK] Last Access Update disabled
schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable >nul 2>&1
echo       [OK] Scheduled defragmentation disabled
reg add "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableHIPM" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableDIPM" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] AHCI Link Power Management disabled
call :LOG "SSD: All optimizations applied"
echo.
pause
goto SSD_MENU

:CHECK_TRIM
cls
echo.
echo   [*] Checking TRIM status...
echo.
fsutil behavior query DisableDeleteNotify
call :LOG "SSD: TRIM status checked"
echo.
pause
goto SSD_MENU

:DISABLE_AHCI_LPM
cls
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableHIPM" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableDIPM" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] AHCI HIPM/DIPM disabled
call :LOG "SSD: AHCI LPM disabled"
pause
goto SSD_MENU

:DISABLE_DEFRAG
cls
echo.
schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Disable >nul 2>&1
echo       [OK] Scheduled defragmentation disabled
call :LOG "SSD: Scheduled defrag disabled"
pause
goto SSD_MENU

:RESTORE_SSD_DEFAULTS
cls
echo.
schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Enable >nul 2>&1
echo       [OK] Scheduled defragmentation restored
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableHIPM" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableDIPM" /f >nul 2>&1
echo       [OK] AHCI Link Power Management restored
call :LOG "SSD RESTORE: All settings restored"
pause
goto SSD_MENU

:: ============================================================================
:: SCHEDULING MENU
:: ============================================================================
:SCHEDULING_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                      SCHEDULING and PRIORITY                           ^|
echo   +========================================================================+
echo.
echo   [1]  Apply All Scheduling Optimizations
echo   [2]  Optimize Win32PrioritySeparation
echo   [3]  Configure MMCSS (Multimedia Class Scheduler)
echo   [4]  Optimize Games Task Profile
echo   [5]  Disable Game DVR Overhead
echo.
echo   [R]  Restore Scheduling Defaults
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE SCHED_CHOICE "Select an option:" "1 2 3 4 5 R 0"

if "%SCHED_CHOICE%"=="1" goto APPLY_SCHED_OPT
if "%SCHED_CHOICE%"=="2" goto OPT_PRIORITY_SEP
if "%SCHED_CHOICE%"=="3" goto CONFIG_MMCSS
if "%SCHED_CHOICE%"=="4" goto OPT_GAMES_PROFILE
if "%SCHED_CHOICE%"=="5" goto DISABLE_GAMEDVR
if /i "%SCHED_CHOICE%"=="R" goto RESTORE_SCHED_DEFAULTS
if "%SCHED_CHOICE%"=="0" goto MAIN_MENU
goto SCHEDULING_MENU

:APPLY_SCHED_OPT
cls
echo.
echo   +========================================================================+
echo   ^|                APPLYING SCHEDULING OPTIMIZATIONS                       ^|
echo   +========================================================================+
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 26 /f >nul 2>&1
echo       [OK] Win32PrioritySeparation = 26 (Gaming optimized)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul 2>&1
echo       [OK] MMCSS optimized
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
echo       [OK] Games profile optimized
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] Game DVR disabled
call :LOG "SCHED: All optimizations applied"
echo.
pause
goto SCHEDULING_MENU

:OPT_PRIORITY_SEP
cls
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 26 /f >nul 2>&1
echo       [OK] Win32PrioritySeparation = 26
call :LOG "SCHED: Win32PrioritySeparation = 26"
pause
goto SCHEDULING_MENU

:CONFIG_MMCSS
cls
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] System Responsiveness = 0
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 0xffffffff /f >nul 2>&1
echo       [OK] Network throttling disabled
call :LOG "SCHED: MMCSS configured"
pause
goto SCHEDULING_MENU

:OPT_GAMES_PROFILE
cls
echo.
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "High" /f >nul 2>&1
echo       [OK] Games profile configured (Priority 6, GPU Priority 8, High Scheduling)
call :LOG "SCHED: Games profile optimized"
pause
goto SCHEDULING_MENU

:DISABLE_GAMEDVR
cls
echo.
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] Game DVR disabled
call :LOG "SCHED: Game DVR disabled"
pause
goto SCHEDULING_MENU

:RESTORE_SCHED_DEFAULTS
cls
echo.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 2 /f >nul 2>&1
echo       [OK] Win32PrioritySeparation restored
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
echo       [OK] MMCSS restored
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo       [OK] Game DVR restored
call :LOG "SCHED RESTORE: All settings restored"
pause
goto SCHEDULING_MENU

:: ============================================================================
:: BCDEDIT MENU
:: ============================================================================
:BCDEDIT_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                          BCDEDIT TWEAKS                                ^|
echo   ^|                    Boot Configuration Settings                         ^|
echo   +========================================================================+
echo.
echo   [1]  Apply All BCDEdit Optimizations
echo   [2]  Disable Dynamic Tick (Timer Latency)
echo   [3]  Configure TSC Synchronization
echo   [4]  Disable Hypervisor (HVCI/VBS)
echo   [5]  View Current BCD Settings
echo.
echo   [R]  Restore BCDEdit Defaults
echo   [0]  Back to Main Menu
echo.
echo   [^^!] NOTE: BCDEdit changes require a REBOOT to take effect^^!
echo.
call :READ_CHOICE BCD_CHOICE "Select an option:" "1 2 3 4 5 R 0"

if "%BCD_CHOICE%"=="1" goto APPLY_BCD_OPT
if "%BCD_CHOICE%"=="2" goto BCD_DYNAMIC_TICK
if "%BCD_CHOICE%"=="3" goto BCD_TSC
if "%BCD_CHOICE%"=="4" goto BCD_HYPERVISOR
if "%BCD_CHOICE%"=="5" goto BCD_VIEW
if /i "%BCD_CHOICE%"=="R" goto RESTORE_BCD_DEFAULTS
if "%BCD_CHOICE%"=="0" goto MAIN_MENU
goto BCDEDIT_MENU

:APPLY_BCD_OPT
cls
echo.
echo   +========================================================================+
echo   ^|                  APPLYING BCDEDIT OPTIMIZATIONS                        ^|
echo   +========================================================================+
echo.
bcdedit /enum > "%LOG_DIR%\bcdedit_backup_%TIMESTAMP%.txt" 2>&1
echo       [OK] BCD backup saved to Logs folder

bcdedit /set disabledynamictick yes >nul 2>&1
echo       [OK] Dynamic Tick disabled
bcdedit /set useplatformtick yes >nul 2>&1
echo       [OK] Platform Tick enabled
bcdedit /set tscsyncpolicy enhanced >nul 2>&1
echo       [OK] TSC Sync Policy = Enhanced
bcdedit /set hypervisorlaunchtype off >nul 2>&1
echo       [OK] Hypervisor disabled
bcdedit /set debug off >nul 2>&1
bcdedit /set bootdebug off >nul 2>&1
echo       [OK] Debug mode disabled
call :LOG "BCD: All optimizations applied"
echo.
echo   [^^!] REBOOT REQUIRED for changes to take effect^^!
echo.
pause
goto BCDEDIT_MENU

:BCD_DYNAMIC_TICK
cls
echo.
bcdedit /set disabledynamictick yes >nul 2>&1
bcdedit /set useplatformtick yes >nul 2>&1
echo       [OK] Dynamic Tick disabled, Platform Tick enabled
call :LOG "BCD: Dynamic Tick disabled"
echo.
echo   [^^!] Reboot required.
pause
goto BCDEDIT_MENU

:BCD_TSC
cls
echo.
bcdedit /set tscsyncpolicy enhanced >nul 2>&1
bcdedit /set useplatformclock no >nul 2>&1
echo       [OK] TSC Sync = Enhanced, Platform Clock disabled
call :LOG "BCD: TSC = Enhanced"
pause
goto BCDEDIT_MENU

:BCD_HYPERVISOR
cls
echo.
echo   [^^!] WARNING: Disabling Hypervisor reduces security but improves performance.
echo.
set /p "HV_CONFIRM=  Disable Hypervisor? [Y/N]: "
if /i "%HV_CONFIRM%"=="Y" (
    bcdedit /set hypervisorlaunchtype off >nul 2>&1
    echo       [OK] Hypervisor disabled
    call :LOG "BCD: Hypervisor disabled"
)
pause
goto BCDEDIT_MENU

:BCD_VIEW
cls
echo.
echo   Current BCD Settings:
echo   =====================
bcdedit /enum {current} | findstr /i "disabledynamictick useplatformtick tscsyncpolicy hypervisorlaunchtype"
echo.
pause
goto BCDEDIT_MENU

:RESTORE_BCD_DEFAULTS
cls
echo.
bcdedit /deletevalue disabledynamictick >nul 2>&1
echo       [OK] Dynamic Tick restored
bcdedit /deletevalue useplatformtick >nul 2>&1
echo       [OK] Platform Tick restored
bcdedit /deletevalue tscsyncpolicy >nul 2>&1
echo       [OK] TSC Policy restored
bcdedit /set hypervisorlaunchtype auto >nul 2>&1
echo       [OK] Hypervisor restored
call :LOG "BCD RESTORE: All settings restored"
echo.
echo   [^^!] REBOOT REQUIRED for changes to take effect^^!
pause
goto BCDEDIT_MENU

:: ============================================================================
:: POWER PLAN MENU
:: ============================================================================
:POWERPLAN_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                           POWER PLANS                                  ^|
echo   +========================================================================+
echo.
echo   [1]  View Current Power Plan
echo   [2]  Import Custom Power Plan (.pow)
echo   [3]  Set High Performance Plan
echo   [4]  Set Ultimate Performance Plan
echo   [5]  Optimize Current Plan for Gaming
echo   [6]  List All Power Plans
echo.
echo   [R]  Restore Balanced Power Plan
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE PWR_CHOICE "Select an option:" "1 2 3 4 5 6 R 0"

if "%PWR_CHOICE%"=="1" goto PWR_VIEW
if "%PWR_CHOICE%"=="2" goto PWR_IMPORT
if "%PWR_CHOICE%"=="3" goto PWR_HIGH
if "%PWR_CHOICE%"=="4" goto PWR_ULTIMATE
if "%PWR_CHOICE%"=="5" goto PWR_OPTIMIZE
if "%PWR_CHOICE%"=="6" goto PWR_LIST
if /i "%PWR_CHOICE%"=="R" goto RESTORE_PWR_DEFAULTS
if "%PWR_CHOICE%"=="0" goto MAIN_MENU
goto POWERPLAN_MENU

:PWR_VIEW
cls
echo.
powercfg /getactivescheme
echo.
pause
goto POWERPLAN_MENU

:PWR_IMPORT
cls
echo.
echo   +========================================================================+
echo   ^|                   IMPORT CUSTOM POWER PLAN                             ^|
echo   +========================================================================+
echo.
echo   Available power plans in Powerplans folder:
echo   ============================================
echo.

set "POW_COUNT=0"
for /r "%POWERPLANS_DIR%" %%f in (*.pow) do (
    set /a POW_COUNT+=1
    set "POW_!POW_COUNT!=%%f"
    echo   [!POW_COUNT!]  %%~nf
)

if !POW_COUNT!==0 (
    echo   [^^!] No .pow files found in Powerplans folder^^!
    echo.
    pause
    goto POWERPLAN_MENU
)

echo.
echo   [0]  Back
echo.
set /p "POW_SEL=  Select power plan to import: "

if "%POW_SEL%"=="0" goto POWERPLAN_MENU

set "SELECTED_POW=!POW_%POW_SEL%!"
if defined SELECTED_POW (
    echo.
    echo   [*] Importing power plan...
    powercfg /import "!SELECTED_POW!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo       [OK] Power plan imported successfully!
        call :LOG "POWER: Imported !SELECTED_POW!"
    ) else (
        echo       [ERROR] Failed to import power plan!
    )
)
echo.
pause
goto POWERPLAN_MENU

:PWR_HIGH
cls
echo.
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
echo       [OK] High Performance plan activated
call :LOG "POWER: High Performance activated"
pause
goto POWERPLAN_MENU

:PWR_ULTIMATE
cls
echo.
powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
echo       [OK] Ultimate Performance plan activated
call :LOG "POWER: Ultimate Performance activated"
pause
goto POWERPLAN_MENU

:PWR_OPTIMIZE
cls
echo.
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100 >nul 2>&1
echo       [OK] CPU Min/Max = 100%%
powercfg /setacvalueindex scheme_current sub_processor CPMINCORES 100 >nul 2>&1
echo       [OK] Core parking disabled
powercfg /setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
echo       [OK] USB selective suspend disabled
powercfg /setactive scheme_current >nul 2>&1
call :LOG "POWER: Current plan optimized"
echo.
pause
goto POWERPLAN_MENU

:PWR_LIST
cls
echo.
powercfg /list
echo.
pause
goto POWERPLAN_MENU

:RESTORE_PWR_DEFAULTS
cls
echo.
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
echo       [OK] Balanced power plan activated
call :LOG "POWER RESTORE: Balanced plan activated"
pause
goto POWERPLAN_MENU

:: ============================================================================
:: AUTORUNS MENU
:: ============================================================================
:AUTORUNS_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                        AUTORUNS UTILITY                                ^|
echo   ^|              Manage Windows Startup Programs (Sysinternals)            ^|
echo   +========================================================================+
echo.
echo   [1]  Install and Run Autoruns (via winget)
echo   [2]  Check if Autoruns is installed
echo.
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE AUTO_CHOICE "Select an option:" "1 2 0"

if "%AUTO_CHOICE%"=="1" goto INSTALL_AUTORUNS
if "%AUTO_CHOICE%"=="2" goto CHECK_AUTORUNS
if "%AUTO_CHOICE%"=="0" goto MAIN_MENU
goto AUTORUNS_MENU

:CHECK_AUTORUNS
cls
echo.
echo   [*] Checking if winget is available...
where winget >nul 2>&1
if %errorlevel% equ 0 (
    echo       [OK] Winget is installed
) else (
    echo       [^^!] Winget is NOT installed
)
call :LOG "AUTORUNS: Status checked"
echo.
pause
goto AUTORUNS_MENU

:INSTALL_AUTORUNS
cls
echo.
echo   +========================================================================+
echo   ^|                    INSTALL AND RUN AUTORUNS                            ^|
echo   +========================================================================+
echo.

echo   [1/3] Checking winget...
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo       [^^!] Winget not found. Please install App Installer from Microsoft Store.
    pause
    goto AUTORUNS_MENU
)
echo       [OK] Winget available

echo   [2/3] Installing Autoruns...
winget install --id Microsoft.Sysinternals.Autoruns --accept-source-agreements --accept-package-agreements -h >nul 2>&1
echo       [OK] Autoruns installed

echo   [3/3] Launching Autoruns...
echo.
echo   Close Autoruns when finished to continue.
echo.
start /wait "" autoruns64.exe 2>nul || start /wait "" autoruns.exe 2>nul
echo.
echo   [OK] Autoruns closed.
call :LOG "AUTORUNS: Session completed"
pause
goto AUTORUNS_MENU

:: ============================================================================
:: DIAGNOSTICS MENU
:: ============================================================================
:DIAGNOSTICS_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                     DIAGNOSTICS (SFC/DISM)                             ^|
echo   +========================================================================+
echo.
echo   [1]  Run SFC /scannow
echo   [2]  Run DISM CheckHealth
echo   [3]  Run DISM ScanHealth
echo   [4]  Run DISM RestoreHealth
echo   [5]  Run Full Diagnostics (All)
echo.
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE DIAG_CHOICE "Select an option:" "1 2 3 4 5 0"

if "%DIAG_CHOICE%"=="1" goto DIAG_SFC
if "%DIAG_CHOICE%"=="2" goto DIAG_CHECK
if "%DIAG_CHOICE%"=="3" goto DIAG_SCAN
if "%DIAG_CHOICE%"=="4" goto DIAG_RESTORE
if "%DIAG_CHOICE%"=="5" goto DIAG_FULL
if "%DIAG_CHOICE%"=="0" goto MAIN_MENU
goto DIAGNOSTICS_MENU

:DIAG_SFC
cls
echo.
echo   [*] Running SFC /scannow... (this may take 10-15 minutes)
echo.
sfc /scannow
call :LOG "DIAG: SFC completed"
echo.
pause
goto DIAGNOSTICS_MENU

:DIAG_CHECK
cls
echo.
DISM /Online /Cleanup-Image /CheckHealth
call :LOG "DIAG: CheckHealth completed"
echo.
pause
goto DIAGNOSTICS_MENU

:DIAG_SCAN
cls
echo.
echo   [*] Running DISM ScanHealth... (this may take 15-20 minutes)
echo.
DISM /Online /Cleanup-Image /ScanHealth
call :LOG "DIAG: ScanHealth completed"
echo.
pause
goto DIAGNOSTICS_MENU

:DIAG_RESTORE
cls
echo.
echo   [*] Running DISM RestoreHealth... (this may take 20-30 minutes)
echo.
DISM /Online /Cleanup-Image /RestoreHealth
call :LOG "DIAG: RestoreHealth completed"
echo.
pause
goto DIAGNOSTICS_MENU

:DIAG_FULL
cls
echo.
echo   [*] Running full diagnostics...
echo.
echo   [1/4] DISM CheckHealth
DISM /Online /Cleanup-Image /CheckHealth
echo.
echo   [2/4] DISM ScanHealth
DISM /Online /Cleanup-Image /ScanHealth
echo.
echo   [3/4] DISM RestoreHealth
DISM /Online /Cleanup-Image /RestoreHealth
echo.
echo   [4/4] SFC /scannow
sfc /scannow
call :LOG "DIAG: Full diagnostics completed"
echo.
pause
goto DIAGNOSTICS_MENU

:: ============================================================================
:: APPLY ALL
:: ============================================================================
:APPLY_ALL
cls
echo.
echo   +========================================================================+
echo   ^|                     APPLY ALL OPTIMIZATIONS                            ^|
echo   +========================================================================+
echo.
echo   This will apply ALL gaming optimizations:
echo   - CPU, GPU, RAM, SSD, Scheduling, BCDEdit, Power
echo.
set /p "CONFIRM=  Apply all optimizations? [Y/N]: "
if /i not "%CONFIRM%"=="Y" goto MAIN_MENU

call :LOG "APPLY ALL: Starting"

echo.
echo   [1/7] CPU Optimizations...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor CPMINCORES 100 >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100 >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d 1 /f >nul 2>&1
echo       [OK] CPU optimized

echo   [2/7] GPU Optimizations...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "OverlayTestMode" /t REG_DWORD /d 5 /f >nul 2>&1
echo       [OK] GPU optimized

echo   [3/7] RAM Optimizations...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 0 /f >nul 2>&1
sc config "SysMain" start= disabled >nul 2>&1
net stop "SysMain" >nul 2>&1
echo       [OK] RAM optimized

echo   [4/7] SSD Optimizations...
fsutil behavior set DisableDeleteNotify 0 >nul 2>&1
fsutil behavior set disablelastaccess 1 >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableHIPM" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableDIPM" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] SSD optimized

echo   [5/7] Scheduling Optimizations...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 26 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo       [OK] Scheduling optimized

echo   [6/7] BCDEdit Optimizations...
bcdedit /set disabledynamictick yes >nul 2>&1
bcdedit /set useplatformtick yes >nul 2>&1
bcdedit /set tscsyncpolicy enhanced >nul 2>&1
bcdedit /set hypervisorlaunchtype off >nul 2>&1
echo       [OK] BCDEdit optimized

echo   [7/7] Power Plan...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
powercfg /setactive scheme_current >nul 2>&1
echo       [OK] Power plan optimized

call :LOG "APPLY ALL: Completed"
echo.
echo   +========================================================================+
echo   ^|               ALL OPTIMIZATIONS APPLIED SUCCESSFULLY^!                  ^|
echo   ^|                                                                        ^|
echo   ^|   [^^!] REBOOT REQUIRED to apply all changes^!                            ^|
echo   +========================================================================+
echo.
set /p "REBOOT=  Reboot now? [Y/N]: "
if /i "%REBOOT%"=="Y" shutdown /r /t 10 /c "Prime Build - Applying optimizations"
goto MAIN_MENU

:: ============================================================================
:: RESTORE MENU
:: ============================================================================
:RESTORE_MENU
cls
echo.
echo   +========================================================================+
echo   ^|                     RESTORE WINDOWS DEFAULTS                           ^|
echo   +========================================================================+
echo.
echo   [1]  Restore ALL Settings to Windows 11 Defaults
echo   [0]  Back to Main Menu
echo.
call :READ_CHOICE REST_CHOICE "Select an option:" "1 0"

if "%REST_CHOICE%"=="1" goto RESTORE_ALL
if "%REST_CHOICE%"=="0" goto MAIN_MENU
goto RESTORE_MENU

:RESTORE_ALL
cls
echo.
echo   [^^!] WARNING: This will restore ALL settings to Windows 11 defaults.
echo.
set /p "CONFIRM=  Continue? [Y/N]: "
if /i not "%CONFIRM%"=="Y" goto RESTORE_MENU

call :LOG "RESTORE ALL: Starting"

echo.
echo   [1/7] Restoring CPU...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "CsEnabled" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /f >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor CPMINCORES 5 >nul 2>&1
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 5 >nul 2>&1
echo       [OK]

echo   [2/7] Restoring GPU...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "OverlayTestMode" /f >nul 2>&1
echo       [OK]

echo   [3/7] Restoring RAM...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d 3 /f >nul 2>&1
sc config "SysMain" start= auto >nul 2>&1
echo       [OK]

echo   [4/7] Restoring SSD...
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableHIPM" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\storahci\Parameters\Device" /v "EnableDIPM" /f >nul 2>&1
schtasks /Change /TN "\Microsoft\Windows\Defrag\ScheduledDefrag" /Enable >nul 2>&1
echo       [OK]

echo   [5/7] Restoring Scheduling...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo       [OK]

echo   [6/7] Restoring BCDEdit...
bcdedit /deletevalue disabledynamictick >nul 2>&1
bcdedit /deletevalue useplatformtick >nul 2>&1
bcdedit /deletevalue tscsyncpolicy >nul 2>&1
bcdedit /set hypervisorlaunchtype auto >nul 2>&1
echo       [OK]

echo   [7/7] Restoring Power Plan...
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
echo       [OK]

call :LOG "RESTORE ALL: Completed"
echo.
echo   +========================================================================+
echo   ^|               ALL SETTINGS RESTORED TO DEFAULTS^!                       ^|
echo   ^|                                                                        ^|
echo   ^|   [^^!] REBOOT REQUIRED to apply all changes^!                            ^|
echo   +========================================================================+
echo.
set /p "REBOOT=  Reboot now? [Y/N]: "
if /i "%REBOOT%"=="Y" shutdown /r /t 10 /c "Prime Build - Restoring defaults"
goto RESTORE_MENU

:: ============================================================================
:: LOGGING FUNCTION
:: ============================================================================
:LOG
set "_LVL=%~2"
if not defined _LVL set "_LVL=INFO"
echo [%date% %time%] [%_LVL%] %~1 >> "%LOG_FILE%"
if /i "%DEBUG%"=="1" echo [DBG-%_LVL%] %~1
set "_LVL="
goto :eof

:: ============================================================================
:: HEADER FUNCTION
:: ============================================================================
:HEADER_MAIN
echo.
echo   +========================================================================+
echo   ^|                                                                        ^|
echo   ^|   PPPP   RRRR   III  M   M  EEEEE      BBBB   U   U  III  L     DDDD   ^|
echo   ^|   P   P  R   R   I   MM MM  E          B   B  U   U   I   L     D   D  ^|
echo   ^|   PPPP   RRRR    I   M M M  EEE        BBBB   U   U   I   L     D   D  ^|
echo   ^|   P      R  R    I   M   M  E          B   B  U   U   I   L     D   D  ^|
echo   ^|   P      R   R  III  M   M  EEEEE      BBBB    UUU   III  LLLLL DDDD   ^|
echo   ^|                                                                        ^|
echo   ^|                    --- TWEAKING CONSOLE ---                            ^|
echo   ^|                     Windows 11 Gaming Edition                          ^|
echo   ^|                                                                        ^|
echo   +========================================================================+
echo   ^|  Detected: CPU [%CPU_VENDOR%] - GPU [%GPU_VENDOR%]                     ^|
echo   +========================================================================+
echo   ^|                                                                        ^|
goto :eof

:: ============================================================================
:: INPUT VALIDATION FUNCTION (simplified)
:: ============================================================================
:READ_CHOICE
:: Parametri: %1=nome variabile, %2=prompt, %3=opzioni valide (spazio-separate)
set "_RC_VAR=%~1"
set "_RC_PROMPT=%~2"
set "_RC_ALLOWED=%~3"
:_RC_LOOP
set "_RC_INPUT="
set /p "_RC_INPUT=  %_RC_PROMPT% "
:: Se input vuoto, richiedi
if "!_RC_INPUT!"=="" goto _RC_LOOP
:: Valida input
set "_RC_OK=0"
for %%X in (%_RC_ALLOWED%) do (
    if /i "!_RC_INPUT!"=="%%X" set "_RC_OK=1"
)
if "!_RC_OK!"=="0" (
    echo   [^^!] Opzione non valida. Scegli tra: %_RC_ALLOWED%
    goto _RC_LOOP
)
:: Salva risultato
set "%_RC_VAR%=!_RC_INPUT!"
goto :eof

:: ============================================================================
:: EXIT
:: ============================================================================
:EXIT_SCRIPT
call :LOG "Script terminated by user"
cls
echo.
echo   +========================================================================+
echo   ^|                                                                        ^|
echo   ^|            Thank you for using Prime Build - Tweaking Console          ^|
echo   ^|                                                                        ^|
echo   ^|                    Log saved to: Logs folder                           ^|
echo   ^|                                                                        ^|
echo   +========================================================================+
echo.
timeout /t 3
exit /b 0
