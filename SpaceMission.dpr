program SpaceMission;

uses
  Windows,
  {$IF CompilerVersion >= 23.0}
  System.UITypes,
  {$IFEND }
  Forms,
  Dialogs,
  SysUtils,
  GamMain in 'GamMain.pas' {MainForm},
  GamSplash in 'GamSplash.pas' {SplashForm},
  GamSpeicherung in 'GamSpeicherung.pas' {SpeicherungForm},
  ComInfo in 'ComInfo.pas' {InfoForm},
  GamCheat in 'GamCheat.pas' {CheatForm},
  ComLevelReader in 'ComLevelReader.pas',
  Global in 'Global.pas',
  ComHilfe in 'ComHilfe.pas' {HilfeForm};

{$R *.RES}

var
  Sem: THandle;


resourcestring
  SAlreadyStarted = 'Das Spiel wurde bereits gestartet.';
  STitel = 'SpaceMission';
  SFileMissing = '%s fehlt. Bitte installieren Sie SpaceMission erneut.';

const
  SemaphoreName = 'SpaceMission';

begin
  { Programm schon gestartet? }
  Sem := CreateSemaphore(nil, 0, 1, SemaphoreName);
  if (Sem <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    CloseHandle(Sem);
    MessageDlg(SAlreadyStarted, mtInformation, [mbOK], 0);
    exit;
  end;
  SplashForm := TSplashForm.Create(Application);
  SplashForm.Show;
  SplashForm.Update;
  Application.Initialize;
  Application.ShowMainform := False;
  Application.MainFormOnTaskBar := true;
  Application.Title := STitel;
  if not fileexists(OwnDirectory+DxgFile) then
  begin
    MessageDLG(Format(SFileMissing, [DxgFile]), mtError, [mbOK], 0);
    exit;
  end;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSpeicherungForm, SpeicherungForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.CreateForm(TCheatForm, CheatForm);
  Application.CreateForm(THilfeForm, HilfeForm);
  Application.Run;
end.

