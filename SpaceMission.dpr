program SpaceMission;

{$Description 'SpaceMission 1.1'}

uses
  Windows,
  Forms,
  Dialogs,
  SysUtils,
  MMSystem,
  SplMain in 'SplMain.pas' {MainForm},
  SplText in 'SplText.pas' {TextForm},
  SplSplash in 'SplSplash.pas' {SplashForm},
  SplSpeicherung in 'SplSpeicherung.pas' {SpeicherungForm},
  SplInfo in 'SplInfo.pas' {InfoForm},
  SplCheat in 'SplCheat.pas' {CheatForm};

{$R *.RES}

var
  Fehler: boolean;
  Sem: THandle;
  directory: string;

begin
  { Programm schon gestartet? }
  Sem := CreateSemaphore(nil, 0, 1, 'SpaceMission');
  if (Sem <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    CloseHandle(Sem);
    MessageDlg('Das Spiel wurde bereits gestartet.', mtInformation, [mbOK], 0);
    exit;
  end;
  SplashForm := TSplashForm.Create(Application);
  SplashForm.Show;
  SplashForm.Update;
  Application.Initialize;
  Application.showmainform := False;
  Application.Title := 'SpaceMission';
  { Dateien vorhanden? }
  Fehler := false;
  directory := extractfilepath(paramstr(0));
  if not fileexists(directory+'Bilder\Delphi.bmp') then Fehler := true;
  if not fileexists(directory+'Bilder\SplSplash.jpg') then Fehler := true;
  if not fileexists(directory+'DirectX\Graphic.dxg') then Fehler := true;
  if not fileexists(directory+'DirectX\Sound.dxw') then Fehler := true;
  if not fileexists(directory+'Musik\Boss.mid') then Fehler := true;
  if not fileexists(directory+'Musik\Game.mid') then Fehler := true;
  if not fileexists(directory+'Musik\Scene.mid') then Fehler := true;
  if not fileexists(directory+'Musik\Title.mid') then Fehler := true;
  //if not fileexists(directory+'Texte\Mitwirkende.txt') then Fehler := true;
  if Fehler then
  begin
    MessageDLG('Dateien, die die Programmstabilität gewährleisten, sind ' +
      'nicht mehr vorhanden!'+#13#10+'Bitte installieren Sie SpaceMission erneut...',
      mtWarning, [mbOK], 0);
    exit;
  end;
  { Keine Soundkarte?! }
  if WaveOutGetNumDevs < 1 then
    MessageDlg('Es wurde keine Soundkarte gefunden!' + #13#10 +
    'Entweder ist keine Soundkarte angeschlossen oder sie ist nicht ' +
    'ordnungsgemäß installiert.' + #13#10 + 'Es können daher keine Musik und ' +
    'keine Geräusche abgespielt werden.', mtError, [mbOK], 0);
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TTextForm, TextForm);
  Application.CreateForm(TSpeicherungForm, SpeicherungForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.CreateForm(TCheatForm, CheatForm);
  Application.Run;
end.

