unit LevSource;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellAPI;

type
  TSourceForm = class(TForm)        
    ElLabel1: TLabel;
    ElLabel2: TLabel;
    ElPopupButton1: TButton;
    ListBox1: TListBox;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    procedure ElPopupButton1Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  public
    procedure Aktualisieren;
  end;

var
  SourceForm: TSourceForm;

const
  FCompVersion = '1.0';

implementation

uses
  LevMain, LevSpeicherung;

{$R *.DFM}

procedure TSourceForm.ElPopupButton1Click(Sender: TObject);
begin
  close;
end;

procedure TSourceForm.Aktualisieren;
var
  i, j: integer;
  puffer: string;
begin
  ListBox1.Items := MainForm.Enemys;
  Memo1.lines.clear;
  for j := 0 to mainform.enemys.Count - 2 do
  begin
    for i := 0 to mainform.enemys.Count - 2 do
    begin
      if strtoint(speicherungform.filter(1, mainform.enemys.Strings[i])) > strtoint(speicherungform.filter(1, mainform.enemys.Strings[i + 1])) then
      begin
        puffer := mainform.enemys.Strings[i];
        mainform.enemys.Strings[i] := mainform.enemys.Strings[i + 1];
        mainform.enemys.Strings[i + 1] := puffer;
      end;
    end;
  end;
  Memo1.lines.add('; SpaceMission ' + FCompVersion);
  Memo1.lines.add('; LEV-File');
  Memo1.lines.add(inttostr(MainForm.ScrollBar.Max)); // --> Länge der Karte
  for i := 0 to mainform.enemys.count-1 do
  begin
    Memo1.lines.add(speicherungform.filter(3, mainform.enemys.Strings[i]));
    Memo1.lines.add(speicherungform.filter(1, mainform.enemys.Strings[i]));
    Memo1.lines.add(speicherungform.filter(2, mainform.enemys.Strings[i]));
    Memo1.lines.add(speicherungform.filter(4, mainform.enemys.Strings[i]));
  end;
end;

procedure TSourceForm.FormHide(Sender: TObject);
begin
  mainform.dxtimer.enabled := true;
end;

procedure TSourceForm.FormShow(Sender: TObject);
begin
  mainform.dxtimer.enabled := false;
end;

procedure TSourceForm.Label1Click(Sender: TObject);
begin
  if not fileexists(mainform.fdirectory+'Dokumentation.pdf') then
  begin
    MessageDLG('Die Datei "Dokumentation.pdf" ist nicht mehr vorhanden. Die Aktion wird abgebrochen!',
      mtWarning, [mbOK], 0);
  end
  else
    shellexecute(handle, 'open', pchar(mainform.fdirectory+'Dokumentation.pdf'), '', '', 1);
end;

end.

