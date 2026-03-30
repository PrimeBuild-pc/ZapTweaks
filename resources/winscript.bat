@echo off
setlocal EnableExtensions DisableDelayedExpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    color 4
    echo This script requires administrator privileges.
    echo Please run WinScript as Administrator.
    pause
    exit /b 1
)

echo ==========================================
echo   ZapTweaks Safe Debloat ^(Windows 11 2026^)
echo ==========================================
echo This script removes only selected UWP bloat apps.
echo Critical services and platform components are preserved.
echo.

PowerShell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='SilentlyContinue';" ^
  "$targets=@('Clipchamp.Clipchamp','Microsoft.3DBuilder','Microsoft.BingFinance','Microsoft.BingNews','Microsoft.BingSports','Microsoft.BingWeather','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.MicrosoftOfficeHub','Microsoft.MicrosoftSolitaireCollection','Microsoft.MixedReality.Portal','Microsoft.Office.OneNote','Microsoft.People','Microsoft.SkypeApp','Microsoft.Todos','Microsoft.WindowsFeedbackHub','Microsoft.YourPhone','Microsoft.ZuneMusic','Microsoft.ZuneVideo','MicrosoftTeams');" ^
  "$protected=@('Microsoft.WindowsStore','Microsoft.StorePurchaseApp','Microsoft.DesktopAppInstaller','Microsoft.VCLibs','Microsoft.UI.Xaml','Microsoft.XboxIdentityProvider','Microsoft.Xbox.TCUI','Microsoft.GamingServices','Microsoft.XboxGamingOverlay','Microsoft.XboxGameOverlay','Microsoft.XboxSpeechToTextOverlay','Microsoft.GamingApp');" ^
  "function IsProtected([string]$name){ foreach($p in $protected){ if($name -like ($p + '*')){ return $true } } return $false };" ^
  "Write-Host 'Removing selected UWP packages...';" ^
  "foreach($target in $targets){" ^
  "  $packages = Get-AppxPackage -AllUsers -Name ($target + '*');" ^
  "  foreach($pkg in $packages){" ^
  "    if(-not (IsProtected $pkg.Name)){" ^
  "      Write-Host (' - Removing: ' + $pkg.Name);" ^
  "      Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction SilentlyContinue;" ^
  "    }" ^
  "  }" ^
  "  $provisioned = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like ($target + '*') };" ^
  "  foreach($prov in $provisioned){" ^
  "    if(-not (IsProtected $prov.DisplayName)){" ^
  "      Write-Host (' - Deprovisioning: ' + $prov.DisplayName);" ^
  "      Remove-AppxProvisionedPackage -Online -PackageName $prov.PackageName | Out-Null;" ^
  "    }" ^
  "  }" ^
  "}" ^
  "Write-Host 'UWP debloat completed.';"

echo.
echo Applying safe consumer-content privacy policy...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t REG_DWORD /d 0 /f >nul

echo.
echo [OK] Safe debloat complete.
echo Notes:
echo  - Windows Update service was NOT disabled.
echo  - Microsoft Store components were NOT removed.
echo  - Xbox base services/components for PC Game Pass were preserved.
echo.
pause
endlocal
