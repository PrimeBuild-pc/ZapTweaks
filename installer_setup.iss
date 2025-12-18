; Script Inno Setup per ZapTweaks by PrimeBuild
; Creato per generare installer Windows professionale

#define MyAppName "ZapTweaks"
#define MyAppVersion "1.0"
#define MyAppPublisher "PrimeBuild"
#define MyAppExeName "script_utility.exe"
#define MyAppAssocName "ZapTweaks"
#define MyAppAssocExt ""
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
AppId={{8F7A2B1D-9C4E-4A3F-B5D6-1E8C9A0F2D4B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=
OutputDir=C:\Users\Lorenzo\Documents\Projects\script\app\script_utility\installer_output
OutputBaseFilename=ZapTweaks_Setup_v{#MyAppVersion}
SetupIconFile=C:\Users\Lorenzo\Documents\Projects\script\app\script_utility\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName} by {#MyAppPublisher}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\Users\Lorenzo\Documents\Projects\script\app\script_utility\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Lorenzo\Documents\Projects\script\app\script_utility\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\data\flutter_assets\resources\app_icon.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\data\flutter_assets\resources\app_icon.ico"; Tasks: desktopicon

[Run]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent runascurrentuser

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
  if not IsAdminInstallMode then
  begin
    MsgBox('This application requires administrator privileges to install properly.'#13#10#13#10'Please run the installer as administrator.', mbError, MB_OK);
    Result := False;
  end;
end;
