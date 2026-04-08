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

## explorer "https://www.igorslab.de/en/download-area-new-version-of-morepowertool-mpt-and-final-release-of-redbioseditor-rbe"
## explorer "https://www.igorslab.de/installer/MoreClockTool_v1111_2.zip"
Write-Host "Installing: More Clock Tool..."
Write-Host "Navi GPUS only, 5000 series and above`n"

Pause

# new folder
New-Item -Path "$env:SystemDrive\Program Files (x86)\More Clock Tool" -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

# download more clock tool
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/moreclocktool.exe" -OutFile "$env:SystemDrive\Program Files (x86)\More Clock Tool\More Clock Tool.exe"

# create desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Desktop = (New-Object -ComObject Shell.Application).Namespace('shell:Desktop').Self.Path
$Shortcut = $WshShell.CreateShortcut("$Desktop\More Clock Tool.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\More Clock Tool\More Clock Tool.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\More Clock Tool"
$Shortcut.Save()

# create start menu shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\More Clock Tool.lnk")
$Shortcut.TargetPath = "$env:SystemDrive\Program Files (x86)\More Clock Tool\More Clock Tool.exe"
$Shortcut.WorkingDirectory = "$env:SystemDrive\Program Files (x86)\More Clock Tool"
$Shortcut.Save()