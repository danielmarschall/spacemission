unit LevOptions;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, ComCtrls;

type
  TLevelForm = class(TForm)
    ElPopupButton1: TButton;
    ElPopupButton2: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Panel1: TPanel;
    ElLabel1: TLabel;
    ElLabel2: TLabel;
    GroesseEdt: TEdit;
    Groesse: TUpDown;
    procedure ElPopupButton1Click(Sender: TObject);
    procedure ElPopupButton2Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GroesseClick(Sender: TObject; Button: TUDBtnType);
    procedure GroesseEdtKeyPress(Sender: TObject; var Key: Char);
    procedure GroesseEdtChange(Sender: TObject);
  public
    procedure Aktualisieren;
  end;

var
  LevelForm: TLevelForm;

implementation

uses LevMain;

{$R *.DFM}

procedure TLevelForm.Aktualisieren;
begin
  Groesse.Position := MainForm.ScrollBar.Max;
end;

procedure TLevelForm.ElPopupButton1Click(Sender: TObject);
begin
  MainForm.ScrollBar.Max := Groesse.Position;
  MainForm.AnzeigeAct;
  close;
end;

procedure TLevelForm.ElPopupButton2Click(Sender: TObject);
begin
  close;
end;

procedure TLevelForm.FormHide(Sender: TObject);
begin
  mainform.dxtimer.enabled := true;
end;

procedure TLevelForm.FormShow(Sender: TObject);
begin
  mainform.dxtimer.enabled := false;
end;

procedure TLevelForm.GroesseClick(Sender: TObject; Button: TUDBtnType);
begin
  groesseedt.Text := inttostr(groesse.position);
end;

procedure TLevelForm.GroesseEdtKeyPress(Sender: TObject; var Key: Char);
begin
  {$IFDEF UNICODE}
  if not CharInSet(Key, [#13, #08, '0'..'9']) then
  {$ELSE}
  if not (Key in [#13, #08, '0'..'9']) then
  {$ENDIF}
    Key := #0;
end;

procedure TLevelForm.GroesseEdtChange(Sender: TObject);
begin
  groesse.Position := strtoint(groesseedt.text);
end;

end.
