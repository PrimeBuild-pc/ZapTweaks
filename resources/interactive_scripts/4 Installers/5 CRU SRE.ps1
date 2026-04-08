        # SCRIPT RUN AS ADMIN
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator"))
        {Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
        Exit}
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.PrivateData.ProgressBackgroundColor = "Black"
        $Host.PrivateData.ProgressForegroundColor = "White"
        Clear-Host

        # SCRIPT CHECK INTERNET
        if (!(Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction SilentlyContinue)) {
        Write-Host "Internet Connection Required`n" -ForegroundColor Red
        Pause
        exit
        }

        # SCRIPT SILENT
        $progresspreference = 'silentlycontinue'

## explorer "https://www.monitortests.com/forum/Thread-Custom-Resolution-Utility-CRU"
## explorer "https://www.monitortests.com/forum/Thread-Scaled-Resolution-Editor-SRE"
Write-Host "Installing:"
Write-Host "- Custom Resolution Utility..."
Write-Host "- Scaled Resolution Editor..."

# download custom resolution utility
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/cru.zip" -OutFile "$env:SystemRoot\Temp\cru.zip"

# extract file
Expand-Archive -Path "$env:SystemRoot\Temp\cru.zip" -DestinationPath "$env:SystemDrive\Program Files (x86)\CRUSRE" -Force

# download scaled resolution editor
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/sre.zip" -OutFile "$env:SystemRoot\Temp\sre.zip"

# extract file
Expand-Archive -Path "$env:SystemRoot\Temp\sre.zip" -DestinationPath "$env:SystemDrive\Program Files (x86)\CRUSRE" -Force

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Custom Resolution Utility.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\CRUSRE\CRU.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\CRUSRE"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Custom Resolution Utility.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\CRUSRE\CRU.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\CRUSRE"
$Shortcut.Save()

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\Scaled Resolution Editor.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\CRUSRE\SRE.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\CRUSRE"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Scaled Resolution Editor.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\CRUSRE\SRE.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\CRUSRE"
$Shortcut.Save()