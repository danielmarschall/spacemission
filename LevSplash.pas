unit LevSplash;

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

uses
  LevMain;

{$R *.DFM}

end.

