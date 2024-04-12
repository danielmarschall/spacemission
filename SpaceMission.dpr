program SpaceMission;

{$Description 'SpaceMission 1.1'}

uses
  Windows,
  {$IF CompilerVersion >= 23.0}System.UITypes,{$IFEND}
  Forms,
  Dialogs,
  SysUtils,
  MMSystem,
  GamMain in 'GamMain.pas' {MainForm},
  GamSplash in 'GamSplash.pas' {SplashForm},
  GamSpeicherung in 'GamSpeicherung.pas' {SpeicherungForm},
  ComInfo in 'ComInfo.pas' {InfoForm},
  GamCheat in 'GamCheat.pas' {CheatForm},
  ComLevelReader in 'ComLevelReader.pas',
  Global in 'Global.pas',
  ComSaveGameReader in 'ComSaveGameReader.pas';

{$R *.RES}

var
  Sem: THandle;

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
  if WaveOutGetNumDevs < 1 then
  begin
    MessageDlg('Es wurde keine Soundkarte gefunden!' + #13#10 +
    'Entweder ist keine Soundkarte angeschlossen oder sie ist nicht ' +
    'ordnungsgemäß installiert.' + #13#10 + 'Es können daher keine Musik und ' +
    'keine Geräusche abgespielt werden.', mtError, [mbOK], 0);
  end;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSpeicherungForm, SpeicherungForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.CreateForm(TCheatForm, CheatForm);
  Application.Run;
end.

