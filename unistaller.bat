@echo off
setlocal EnableExtensions
color 0C
title ZapTweaks Uninstaller

echo ========================================================
echo                ZAPTWEAKS - CLEAN UNINSTALLER
echo ========================================================
echo.
echo WARNING: This script removes ZapTweaks application files
echo from your system (including tools copied to AppData).
echo.
echo IMPORTANT: This script DOES NOT undo Windows tweaks.
echo If you want to restore Windows settings, close this window,
echo open ZapTweaks, run the relevant Revert actions first,
echo and only then run this uninstaller.
echo.
pause

echo.
echo Force-closing ZapTweaks (if running)...
taskkill /F /IM ZapTweaks.exe >nul 2>&1

echo.
echo Removing AppData data (tools and temporary files)...
rmdir /S /Q "%APPDATA%\ZapTweaks" >nul 2>&1

echo.
echo Removing LocalAppData cache (if present)...
rmdir /S /Q "%LOCALAPPDATA%\ZapTweaks" >nul 2>&1

echo.
echo Cleanup completed.
echo You can now manually delete the folder that contains
echo ZapTweaks.exe and this uninstaller.
echo.
pause

endlocal
