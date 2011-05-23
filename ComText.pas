unit ComText;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,                     
  StdCtrls;

type
  TTextForm = class(TForm)
    OKBtn: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  end;

var
  TextForm: TTextForm;

implementation

{$R *.DFM}

procedure TTextForm.Button1Click(Sender: TObject);
begin
  close;
end;

end.

