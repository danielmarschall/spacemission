unit GamSplash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls;

type
  TSplashForm = class(TForm)
    SplashImage: TImage;
    Label1: TLabel;
    Label2: TLabel;
  end;

var
  SplashForm: TSplashForm;

implementation

{$R *.DFM}

end.

