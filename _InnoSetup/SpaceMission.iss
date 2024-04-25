; SpaceMission Setup Script for InnoSetup
; by Daniel Marschall

; Shut-Down Game?!

[Setup]
AppName=SpaceMission
AppVerName=SpaceMission 1.2.2
AppVersion=1.2.2
AppCopyright=© Copyright 2001 - 2024 ViaThinkSoft
AppPublisher=ViaThinkSoft
AppPublisherURL=https://www.viathinksoft.de/
AppSupportURL=https://www.daniel-marschall.de/
AppUpdatesURL=https://www.viathinksoft.de/
DefaultDirName={autopf}\SpaceMission
DefaultGroupName=SpaceMission
VersionInfoCompany=ViaThinkSoft
VersionInfoCopyright=© Copyright 2001 - 2024 ViaThinkSoft
VersionInfoDescription=SpraceMission Setup
VersionInfoTextVersion=1.0.0.0
VersionInfoVersion=1.2.2
OutputBaseFilename=SpaceMission_Setup
OutputDir=.
; Configure Sign Tool in InnoSetup at "Tools => Configure Sign Tools" (adjust the path to your SVN repository location)
; Name    = sign_single   
; Command = "C:\SVN\...\sign_single.bat" $f
SignTool=sign_single
SignedUninstaller=yes

[Languages]
Name: en; MessagesFile: "compiler:Default.isl"
Name: de; MessagesFile: "compiler:Languages\German.isl"

[LangOptions]
LanguageName=Deutsch
LanguageID=$0407

[Tasks]
Name: "desktopicon"; Description: "Erstelle eine Verknüpfung auf dem &Desktop"; GroupDescription: "Programmverknüpfungen:"; MinVersion: 4,4

[Files]
Source: "..\SpaceMission.exe"; DestDir: "{app}"; Flags: ignoreversion signonce
Source: "..\LevEdit.exe"; DestDir: "{app}"; Flags: ignoreversion signonce
Source: "..\SpaceMission.enu"; DestDir: "{app}"; Flags: ignoreversion signonce
Source: "..\LevEdit.enu"; DestDir: "{app}"; Flags: ignoreversion signonce
Source: "..\Help\*.md"; DestDir: "{app}\Help"; Flags: ignoreversion
Source: "..\Help\*.css"; DestDir: "{app}\Help"; Flags: ignoreversion
Source: "..\DirectX\Graphics.dxg"; DestDir: "{app}\DirectX"; Flags: ignoreversion
Source: "..\DirectX\Music.dxm"; DestDir: "{app}\DirectX"; Flags: ignoreversion
Source: "..\DirectX\Sound.dxw"; DestDir: "{app}\DirectX"; Flags: ignoreversion
Source: "..\Levels\*.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion

;[Dirs]
;Name: "{group}\Webseiten"

[Icons]
;Name: "{group}\Webseiten\Daniel Marschall"; Filename: "https://www.daniel-marschall.de/"
;Name: "{group}\Webseiten\ViaThinkSoft"; Filename: "https://www.viathinksoft.de/"
;Name: "{group}\Webseiten\Projektseite auf ViaThinkSoft"; Filename: "https://www.viathinksoft.de/index.php?page=projektanzeige&seite=projekt-19"
Name: "{group}\SpaceMission"; Filename: "{app}\SpaceMission.exe"
Name: "{group}\SpaceMission Level Editor"; Filename: "{app}\LevEdit.exe"
Name: "{autodesktop}\SpaceMission"; Filename: "{app}\SpaceMission.exe"; MinVersion: 4,4; Tasks: desktopicon
Name: "{autodesktop}\SpaceMission Level Editor"; Filename: "{app}\LevEdit.exe"; MinVersion: 4,4; Tasks: desktopicon

[Run]
Filename: "{app}\SpaceMission.exe"; Description: "SpaceMission starten"; Flags: nowait postinstall skipifsilent

[Registry]
; We need this because of a tricky problem...
; Our base language is German (DE), and we have a translation for English USA (ENU)
; If the system locale is not exactly ENU (even ENG is not accepted), then the base language DE will be used.
; But much more people are speaking English than German. So we need to force the system to use ENU instead of DE.
; This decision if we choose DE or ENU is done by the language selected during setup.
Root: HKCU; Subkey: "Software\Embarcadero\Locales"; ValueType: string; ValueName: "{app}\SpaceMission.exe"; ValueData: "ENU"; Languages: en
Root: HKCU; Subkey: "Software\Embarcadero\Locales"; ValueType: string; ValueName: "{app}\SpaceMission.exe"; ValueData: "DE"; Languages: de
Root: HKCU; Subkey: "Software\Embarcadero\Locales"; ValueType: string; ValueName: "{app}\LevEdit.exe"; ValueData: "ENU"; Languages: en
Root: HKCU; Subkey: "Software\Embarcadero\Locales"; ValueType: string; ValueName: "{app}\LevEdit.exe"; ValueData: "DE"; Languages: de

[Code]
function InitializeSetup(): Boolean;
begin
  if CheckForMutexes('SpaceMission11Setup')=false then
  begin
    Createmutex('SpaceMission11Setup');
    Result := true;
  end
  else
  begin
    Result := False;
  end;
end;

