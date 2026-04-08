@echo off
setlocal ENABLEDELAYEDEXPANSION

echo ==========================================
echo  ZapTweaks Uninstaller
echo ==========================================

set "APPDATA_DIR=%APPDATA%\ZapTweaks"
set "APP_DIR=%~dp0"

echo [1/4] Removing app data folder: "%APPDATA_DIR%"
if exist "%APPDATA_DIR%" (
  rmdir /s /q "%APPDATA_DIR%"
)

echo [2/4] Removing app-specific registry keys
reg delete "HKCU\Software\PrimeBuild\ZapTweaks" /f >nul 2>&1
reg delete "HKLM\Software\PrimeBuild\ZapTweaks" /f >nul 2>&1

echo [3/4] Removing Start Menu shortcut folder (if present)
set "START_MENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\ZapTweaks"
if exist "%START_MENU_DIR%" (
  rmdir /s /q "%START_MENU_DIR%"
)

echo [4/4] Scheduling install folder removal
pushd "%APP_DIR%" >nul 2>&1
for %%I in (.) do set "APP_DIR_ABS=%%~fI"
popd >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Sleep -Seconds 2; Remove-Item -Path '%APP_DIR_ABS%' -Recurse -Force" >nul 2>&1

echo Done. If any files are still locked, reboot and delete folder manually.
endlocal
