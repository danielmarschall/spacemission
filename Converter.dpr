program Converter;

uses
  SysUtils,
  Windows,
  Forms,
  Dialogs,
  CnvMain in 'CnvMain.pas' {MainForm},
  System.UITypes;

{$Description 'SpaceMission 1.1 Converter'}

var
  Sem: THandle;

{$R *.RES}

begin
  { Programm schon gestartet? }
  Sem := CreateSemaphore(nil, 0, 1, 'SpaceMission Converter');
  if (Sem <> 0) and (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    CloseHandle(Sem);
    MessageDlg('Das Programm wurde bereits gestartet.', mtInformation, [mbOK], 0);
    exit;
  end;
  Application.Initialize;
  Application.Title := 'Levelconverter';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
