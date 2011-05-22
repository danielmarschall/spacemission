unit SplText;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,                     
  StdCtrls;

type
  TTextForm = class(TForm)
    OKBtn: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  end;

var
  TextForm: TTextForm;

implementation

uses
  SplMain;

{$R *.DFM}

procedure TTextForm.Button1Click(Sender: TObject);
begin
  close;
end;

procedure TTextForm.FormShow(Sender: TObject);
begin
  mainform.dxtimer.enabled := false;
end;

procedure TTextForm.FormHide(Sender: TObject);
begin
  mainform.dxtimer.enabled := true;
end;

end.

