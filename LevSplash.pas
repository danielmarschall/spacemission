unit LevSplash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls, Vcl.Imaging.pngimage;

type
  TSplashForm = class(TForm)
    SplashImage: TImage;
    v: TLabel;
    Label1: TLabel;
  end;

var
  SplashForm: TSplashForm;                      

implementation

uses
  LevMain;

{$R *.DFM}

end.

