unit SplSplash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  jpeg, ExtCtrls, StdCtrls;

type
  TSplashForm = class(TForm)
    SplashImage: TImage;
    procedure FormCreate(Sender: TObject);
  end;

var
  SplashForm: TSplashForm;

implementation

uses
  SplMain;

{$R *.DFM}

procedure TSplashForm.FormCreate(Sender: TObject);
var
  FDirectory: string;
begin
  if copy(extractfiledir(application.ExeName), length(extractfiledir(application.ExeName))-1, 2) = ':\' then FDirectory := ''
    else FDirectory := extractfiledir(application.ExeName)+'\';
  SplashImage.Picture.loadfromfile(FDirectory+'Bilder/SplSplash.jpg');
end;

end.

