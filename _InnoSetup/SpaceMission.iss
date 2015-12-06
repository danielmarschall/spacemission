; SpaceMission Setup Script for InnoSetup
; by Daniel Marschall

; http://www.daniel-marschall.de/

; Shut-Down Game?!

[Setup]
AppName=SpaceMission
AppVerName=SpaceMission 1.1e
AppVersion=1.1.4          
AppCopyright=© Copyright 2001 - 2015 ViaThinkSoft.
AppPublisher=ViaThinkSoft
AppPublisherURL=http://www.viathinksoft.de/
AppSupportURL=http://www.daniel-marschall.de/
AppUpdatesURL=http://www.viathinksoft.de/
DefaultDirName={pf}\SpaceMission
DefaultGroupName=SpaceMission
VersionInfoCompany=ViaThinkSoft
VersionInfoCopyright=© Copyright 2001 - 2015 ViaThinkSoft.
VersionInfoDescription=SpraceMission Setup
VersionInfoTextVersion=1.0.0.0
VersionInfoVersion=1.1.4
Compression=zip/9

[Languages]
Name: de; MessagesFile: "compiler:Languages\German.isl"

[LangOptions]
LanguageName=Deutsch
LanguageID=$0407

[Tasks]
Name: "desktopicon"; Description: "Erstelle eine Verknüpfung auf dem &Desktop"; GroupDescription: "Programmverknüpfungen:"; MinVersion: 4,4
Name: "levedit"; Description: "Installiere den &Leveleditor"; GroupDescription: "Zusatzprogramme:"; MinVersion: 4,4
;Name: "converter"; Description: "Installiere den Level&converter"; GroupDescription: "Zusatzprogramme:"; MinVersion: 4,4; Flags: unchecked

[Files]
Source: "..\SpaceMission.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LevEdit.exe"; DestDir: "{app}"; Flags: ignoreversion; Tasks: levedit
;Source: "..\Converter.exe"; DestDir: "{app}"; Flags: ignoreversion; Tasks: converter
Source: "..\Dokumentation.pdf"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Bilder\Auswahl.bmp"; DestDir: "{app}\Bilder"; Flags: ignoreversion; Tasks: levedit
Source: "..\Bilder\Delphi.bmp"; DestDir: "{app}\Bilder"; Flags: ignoreversion
Source: "..\Bilder\LevSplash.jpg"; DestDir: "{app}\Bilder"; Flags: ignoreversion; Tasks: levedit
Source: "..\Bilder\SplSplash.jpg"; DestDir: "{app}\Bilder"; Flags: ignoreversion
Source: "..\DirectX\Sound.dxw"; DestDir: "{app}\DirectX"; Flags: ignoreversion
Source: "..\DirectX\Graphic.dxg"; DestDir: "{app}\DirectX"; Flags: ignoreversion
Source: "..\Einstellungen\SpaceMission.ini"; DestDir: "{app}\Einstellungen"; Flags: ignoreversion
Source: "..\Levels\*.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Musik\*.mid"; DestDir: "{app}\Musik"; Flags: ignoreversion

[Dirs]
Name: "{app}\Spielstände"
Name: "{app}\Levels"
;Name: "{app}\Eingabe"; Tasks: converter
;Name: "{app}\Ausgabe"; Tasks: converter
;Name: "{app}\Temp"; Tasks: converter
;Name: "{app}\Temp\1"; Tasks: converter
;Name: "{app}\Temp\2"; Tasks: converter
Name: "{group}\Webseiten"
Name: "{group}\Ordner"

[Icons]
Name: "{group}\Webseiten\Daniel Marschall"; Filename: "http://www.daniel-marschall.de/"
Name: "{group}\Webseiten\ViaThinkSoft"; Filename: "http://www.viathinksoft.de/"
Name: "{group}\Webseiten\Projektseite auf ViaThinkSoft"; Filename: "http://www.viathinksoft.de/index.php?page=projektanzeige&seite=projekt-19"
Name: "{group}\SpaceMission"; Filename: "{app}\SpaceMission.exe"
Name: "{group}\Dokumentation"; Filename: "{app}\Dokumentation.pdf"
Name: "{group}\Leveleditor"; Filename: "{app}\LevEdit.exe"; Tasks: levedit
;Name: "{group}\Levelconverter"; Filename: "{app}\Converter.exe"; Tasks: converter
Name: "{group}\Ordner\Levelordner"; Filename: "{app}\Levels\"
Name: "{group}\Ordner\Spielstände"; Filename: "{app}\Spielstände\"
;Name: "{group}\Ordner\Converter Eingabeordner"; Filename: "{app}\Eingabe\"; Tasks: converter
;Name: "{group}\Ordner\Converter Ausgabeordner"; Filename: "{app}\Ausgabe\"; Tasks: converter
Name: "{userdesktop}\SpaceMission"; Filename: "{app}\SpaceMission.exe"; MinVersion: 4,4; Tasks: desktopicon
Name: "{group}\SpaceMission deinstallieren"; Filename: "{uninstallexe}"

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

