; SpaceMission Setup Script for InnoSetup
; by Daniel Marschall

; Shut-Down Game?!

[Setup]
AppName=SpaceMission
AppVerName=SpaceMission 1.2.1
AppVersion=1.2.1
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
VersionInfoVersion=1.2.1
OutputBaseFilename=SpaceMission_Setup
OutputDir=.
; Configure Sign Tool in InnoSetup at "Tools => Configure Sign Tools" (adjust the path to your SVN repository location)
; Name    = sign_single   
; Command = "C:\SVN\...\sign_single.bat" $f
SignTool=sign_single
SignedUninstaller=yes

[Languages]
Name: de; MessagesFile: "compiler:Languages\German.isl"

[LangOptions]
LanguageName=Deutsch
LanguageID=$0407

[Tasks]
Name: "desktopicon"; Description: "Erstelle eine Verknüpfung auf dem &Desktop"; GroupDescription: "Programmverknüpfungen:"; MinVersion: 4,4

[Files]
Source: "..\SpaceMission.exe"; DestDir: "{app}"; Flags: ignoreversion signonce
Source: "..\LevEdit.exe"; DestDir: "{app}"; Flags: ignoreversion signonce
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

