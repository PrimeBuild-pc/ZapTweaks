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
$localHidusbfFolder = Join-Path $programmiPath "hidusbf (BB11.5.25)"
$targetFolder = "$env:SystemDrive\Program Files (x86)\hidusbf"

if (!(Test-Path $localHidusbfFolder)) {
Write-Host "Missing local folder: $localHidusbfFolder" -ForegroundColor Red
Pause
exit
}

Write-Host "Installing: hidusbf..."

# use local hidusbf bundle
New-Item -Path $targetFolder -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
Copy-Item -Path "$localHidusbfFolder\*" -Destination $targetFolder -Recurse -Force

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Setup.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\hidusbf\DRIVER\Setup.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\hidusbf\DRIVER"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Setup.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\hidusbf\DRIVER\Setup.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\hidusbf\DRIVER"
$Shortcut.Save()

# start hidusbf
Start-Process "$env:SystemDrive\Program Files (x86)\hidusbf\DRIVER\Setup.exe"