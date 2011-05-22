program Compiler;

uses
  SysUtils,
  Windows,
  Forms,
  Dialogs,
  ComMain in 'ComMain.pas' {MainForm};

{$Description 'SpaceMission 1.1 Compiler'}

var
  Sem: THandle;

{$R *.RES}

begin
  { Programm schon gestartet? }
  Sem := CreateSemaphore(nil, 0, 1, 'SpaceMission Compiler');
  if (Sem <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    CloseHandle(Sem);
    MessageDlg('Das Programm wurde bereits gestartet.', mtInformation, [mbOK], 0);
    exit;
  end;
  Application.Initialize;
  Application.Title := 'Levelcompiler';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
