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

Write-Host "Downloading: C++..."

# download c++ installers
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2005_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2005_x64.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2005_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2005_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2008_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2008_x64.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2008_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2008_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2010_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2010_x64.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2010_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2010_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2012_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2012_x64.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2012_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2012_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2013_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2013_x64.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2013_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2013_x86.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2015_2017_2019_2022_x64.exe" -OutFile "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x64.exe"
IWR "https://github.com/FR33THYFR33THY/Ultimate-Files/raw/refs/heads/main/vcredist2015_2017_2019_2022_x86.exe" -OutFile "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x86.exe"

Clear-Host

Write-Host "Installing: C++..."

# install c++ packages
Start-Process -wait "$env:SystemRoot\Temp\vcredist2005_x86.exe" -ArgumentList "/q"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2005_x64.exe" -ArgumentList "/q"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2008_x86.exe" -ArgumentList "/qb"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2008_x64.exe" -ArgumentList "/qb"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2010_x86.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2010_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2012_x86.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2012_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2013_x86.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2013_x64.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x86.exe" -ArgumentList "/passive /norestart"
Start-Process -wait "$env:SystemRoot\Temp\vcredist2015_2017_2019_2022_x64.exe" -ArgumentList "/passive /norestart"