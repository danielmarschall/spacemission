unit GamSplash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls;

type
  TSplashForm = class(TForm)
    SplashImage: TImage;
  end;

var
  SplashForm: TSplashForm;

implementation

{$R *.DFM}

end.

