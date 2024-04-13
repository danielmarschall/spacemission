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
    Groesse: TSpinEdit;
    procedure ElPopupButton1Click(Sender: TObject);
    procedure ElPopupButton2Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
  Groesse.Value := MainForm.ScrollBar.Max;
end;

procedure TLevelForm.ElPopupButton1Click(Sender: TObject);
begin
  MainForm.ScrollBar.Max := Groesse.Value;
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

end.
