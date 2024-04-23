program LevEdit;

uses
  Windows,
  {$IF CompilerVersion >= 23.0}
  System.UITypes,
  {$IFEND }
  Forms,
  Dialogs,
  SysUtils,
  MMSystem,
  LevMain in 'LevMain.pas' {MainForm},
  LevSplash in 'LevSplash.pas' {SplashForm},
  LevSpeicherung in 'LevSpeicherung.pas' {SpeicherungForm},
  ComInfo in 'ComInfo.pas' {InfoForm},
  LevOptions in 'LevOptions.pas' {LevelForm},
  ComLevelReader in 'ComLevelReader.pas',
  Global in 'Global.pas',
  ComHilfe in 'ComHilfe.pas' {HilfeForm};

{$R *.RES}

var
  Sem: THandle;

resourcestring
  SAlreadyStarted = 'Der Editor wurde bereits gestartet.';
  STitel = 'SpaceMission Leveleditor';
  SFileMissing = '%s fehlt. Bitte installieren Sie SpaceMission erneut.';

const
  SemaphoreName = 'SpaceMission Leveleditor';

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
    MessageDLG(Format(SFilemissing, [DxgFile]), mtError, [mbOK], 0);
    exit;
  end;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSpeicherungForm, SpeicherungForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.CreateForm(TLevelForm, LevelForm);
  Application.CreateForm(THilfeForm, HilfeForm);
  Application.Run;
end.

