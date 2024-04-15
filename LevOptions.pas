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
    Label2: TLabel;
    Label3: TLabel;
    LevName: TEdit;
    LevAuthor: TEdit;
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
  LevName.Text := MainForm.LevData.LevelName;
  LevAuthor.Text := MainForm.LevData.LevelAuthor;
end;

procedure TLevelForm.ElPopupButton1Click(Sender: TObject);
begin
  MainForm.ScrollBar.Max := Groesse.Value;
  MainForm.LevData.LevelName := LevName.Text;
  MainForm.LevData.LevelAuthor := LevAuthor.Text;
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
