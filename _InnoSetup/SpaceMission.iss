; SpaceMission Setup Script for InnoSetup 5.1.12
; by Daniel Marschall

; http://www.daniel-marschall.de/

; Shut-Down Game?!

[Setup]
AppName=SpaceMission
AppVerName=SpaceMission 1.1
AppVersion=1.1
AppCopyright=© Copyright 2001 - 2007 ViaThinkSoft.
AppPublisher=ViaThinkSoft
AppPublisherURL=http://www.viathinksoft.de/
AppSupportURL=http://www.daniel-marschall.de/
AppUpdatesURL=http://www.viathinksoft.de/
DefaultDirName={pf}\SpaceMission
DefaultGroupName=SpaceMission
VersionInfoCompany=ViaThinkSoft
VersionInfoCopyright=© Copyright 2001 - 2007 ViaThinkSoft.
VersionInfoDescription=SpraceMission Setup
VersionInfoTextVersion=1.0.0.0
VersionInfoVersion=1.1
Compression=zip/9

[Languages]
Name: de; MessagesFile: "compiler:Languages\German.isl"

[LangOptions]
LanguageName=Deutsch
LanguageID=$0407

[Tasks]
Name: "desktopicon"; Description: "Erstelle eine Verknüpfung auf dem &Desktop"; GroupDescription: "Programmverknüpfungen:"; MinVersion: 4,4
Name: "levedit"; Description: "Installiere den &Leveleditor"; GroupDescription: "Zusatzprogramme:"; MinVersion: 4,4
Name: "compiler"; Description: "Installiere den Level&compiler"; GroupDescription: "Zusatzprogramme:"; MinVersion: 4,4

[Files]
Source: "..\SpaceMission.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\LevEdit.exe"; DestDir: "{app}"; Flags: ignoreversion; Tasks: levedit
Source: "..\Compiler.exe"; DestDir: "{app}"; Flags: ignoreversion; Tasks: compiler
Source: "..\Dokumentation.pdf"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Bilder\Auswahl.bmp"; DestDir: "{app}\Bilder"; Flags: ignoreversion; Tasks: levedit
Source: "..\Bilder\Delphi.bmp"; DestDir: "{app}\Bilder"; Flags: ignoreversion
Source: "..\Bilder\LevSplash.jpg"; DestDir: "{app}\Bilder"; Flags: ignoreversion; Tasks: levedit
Source: "..\Bilder\SplSplash.jpg"; DestDir: "{app}\Bilder"; Flags: ignoreversion
Source: "..\DirectX\Sound.dxw"; DestDir: "{app}\DirectX"; Flags: ignoreversion
Source: "..\DirectX\Graphic.dxg"; DestDir: "{app}\DirectX"; Flags: ignoreversion
Source: "..\Einstellungen\SpaceMission.ini"; DestDir: "{app}\Einstellungen"; Flags: ignoreversion
Source: "..\Levels\Level 1.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 2.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 3.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 4.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 5.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 6.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 7.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 8.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 9.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 10.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 11.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 12.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 13.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 14.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 15.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 16.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 17.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 18.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 19.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 20.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 21.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 22.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 23.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 24.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 25.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 26.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 27.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 28.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 29.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 30.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Levels\Level 31.lev"; DestDir: "{app}\Levels"; Flags: ignoreversion
Source: "..\Musik\Boss.mid"; DestDir: "{app}\Musik"; Flags: ignoreversion
Source: "..\Musik\Game.mid"; DestDir: "{app}\Musik"; Flags: ignoreversion
Source: "..\Musik\Scene.mid"; DestDir: "{app}\Musik"; Flags: ignoreversion
Source: "..\Musik\Title.mid"; DestDir: "{app}\Musik"; Flags: ignoreversion
Source: "..\Texte\Mitwirkende.txt"; DestDir: "{app}\Texte"; Flags: ignoreversion

[Dirs]
Name: "{app}\Spielstände"
Name: "{app}\Levels"
Name: "{app}\Eingabe"; Tasks: compiler
Name: "{app}\Ausgabe"; Tasks: compiler
Name: "{app}\Temp"; Tasks: compiler
Name: "{app}\Temp\1"; Tasks: compiler
Name: "{app}\Temp\2"; Tasks: compiler
Name: "{group}\Webseiten"
Name: "{group}\Ordner"

[Icons]
Name: "{group}\Webseiten\Daniel Marschalls Webportal"; Filename: "http://www.daniel-marschall.de/"
Name: "{group}\Webseiten\ViaThinkSoft"; Filename: "http://www.viathinksoft.de/"
Name: "{group}\Webseiten\Projektseite auf ViaThinkSoft"; Filename: "http://www.viathinksoft.de/index.php?page=projektanzeige&seite=projekt-19"
Name: "{group}\SpaceMission"; Filename: "{app}\SpaceMission.exe"
Name: "{group}\Dokumentation"; Filename: "{app}\Dokumentation.pdf"
Name: "{group}\Leveleditor"; Filename: "{app}\LevEdit.exe"; Tasks: levedit
Name: "{group}\Levelcompiler"; Filename: "{app}\Compiler.exe"; Tasks: compiler
Name: "{group}\Ordner\Levelordner"; Filename: "{app}\Levels\"
Name: "{group}\Ordner\Spielstände"; Filename: "{app}\Spielstände\"
Name: "{group}\Ordner\Compiler Eingabeordner"; Filename: "{app}\Eingabe\"; Tasks: compiler
Name: "{group}\Ordner\Compiler Ausgabeordner"; Filename: "{app}\Ausgabe\"; Tasks: compiler
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

