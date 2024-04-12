program LevEdit;

{$Description 'SpaceMission Leveleditor 1.1'}



uses
  Windows,
  {$IF CompilerVersion >= 23.0}System.UITypes,{$IFEND}
  Forms,
  Dialogs,
  SysUtils,
  MMSystem,
  LevMain in 'LevMain.pas' {MainForm},
  LevSplash in 'LevSplash.pas' {SplashForm},
  LevSpeicherung in 'LevSpeicherung.pas' {SpeicherungForm},
  ComInfo in 'ComInfo.pas' {InfoForm},
  LevSource in 'LevSource.pas' {SourceForm},
  LevOptions in 'LevOptions.pas' {LevelForm},
  ComLevelReader in 'ComLevelReader.pas',
  Global in 'Global.pas';

{$R *.RES}

var
  Fehler: boolean;
  Sem: THandle;
  directory: string;

begin
  { Programm schon gestartet? }
  Sem := CreateSemaphore(nil, 0, 1, 'SpaceMission Leveleditor');
  if (Sem <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    CloseHandle(Sem);
    MessageDlg('Der Editor wurde bereits gestartet.', mtInformation, [mbOK], 0);
    exit;
  end;
  SplashForm := TSplashForm.Create(Application);
  SplashForm.Show;
  SplashForm.Update;                                        
  Application.Initialize;
  Application.showmainform := False;
  Application.Title := 'SpaceMission 1.1 - Leveleditor';
  Fehler := false;
  directory := extractfilepath(paramstr(0));
  // if not fileexists(directory+'Bilder\Auswahl.bmp') then Fehler := true;
  if not fileexists(directory+'DirectX\Graphic.dxg') then Fehler := true;
  // if not fileexists(directory+'Texte\Mitwirkende.txt') then Fehler := true;
  // if not fileexists(directory+'Dateien.doc') then Fehler := true;
  if Fehler then
  begin
    MessageDLG('Dateien, die die Programmstabilität gewährleisten, sind ' +
      'nicht mehr vorhanden!'+#13#10+'Bitte installieren Sie SpaceMission erneut...',
      mtWarning, [mbOK], 0);
    exit;
  end;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSpeicherungForm, SpeicherungForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.CreateForm(TSourceForm, SourceForm);
  Application.CreateForm(TLevelForm, LevelForm);
  Application.Run;
end.

