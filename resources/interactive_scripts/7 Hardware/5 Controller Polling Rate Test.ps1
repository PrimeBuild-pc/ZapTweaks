        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

        # SCRIPT SILENT
        $progresspreference = 'silentlycontinue'

$resourcesPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$programmiPath = Join-Path $resourcesPath "programmi"
$localPollingExe = Join-Path $programmiPath "polling.exe"
$installPath = "$env:SystemDrive\Program Files (x86)\Polling\Polling.exe"

if (!(Test-Path $localPollingExe)) {
Write-Host "Missing local file: $localPollingExe" -ForegroundColor Red
Pause
exit
}

Write-Host "Installing: Polling..."

# new folder
New-Item -Path "$env:SystemDrive\Program Files (x86)\Polling" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# use local polling executable
Copy-Item -Path $localPollingExe -Destination $installPath -Force

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Polling.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Polling\Polling.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\Polling"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Polling.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\Polling\Polling.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\Polling"
$Shortcut.Save()

# open gamepadla
Start-Process "$env:SystemDrive\Program Files (x86)\Polling\Polling.exe"