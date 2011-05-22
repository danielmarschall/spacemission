unit SplInfo;
                                        
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellAPI, ExtCtrls;

type
  TInfoForm = class(TForm)
    ElPopupButton1: TButton;
    HomeLbl: TLabel;
    Image: TImage;
    FirmaLbl: TLabel;
    NameLbl: TLabel;
    VersionLbl: TLabel;
    EMailLbl: TLabel;
    CopyrightLbl: TLabel;
    Copyright2Lbl: TLabel;
    URL2: TLabel;
    URL1: TLabel;
    procedure ElPopupButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure URL2Click(Sender: TObject);
    procedure URL1Click(Sender: TObject);
  end;

var
  InfoForm: TInfoForm;

implementation

uses
  SplMain;

{$R *.DFM}

procedure TInfoForm.ElPopupButton1Click(Sender: TObject);
begin
  close;
end;

procedure TInfoForm.FormCreate(Sender: TObject);
begin
  VersionLbl.caption := 'Version ' + mainform.fengineversion;
  CopyrightLbl.caption := mainform.versioninfo.LegalCopyright + '.';
  FirmaLbl.caption := mainform.versioninfo.CompanyName;
  NameLbl.caption := 'SpaceMission';
  image.picture.loadfromfile(mainform.FDirectory + 'Bilder\Delphi.bmp');
end;

procedure TInfoForm.FormShow(Sender: TObject);
begin
  mainform.dxtimer.enabled := false;
end;

procedure TInfoForm.FormHide(Sender: TObject);
begin
  if not mainform.gamepause.checked then mainform.dxtimer.enabled := true;
end;

procedure TInfoForm.URL2Click(Sender: TObject);
begin
  shellexecute(application.Handle, 'open', pchar('http://'+url2.caption+'/'), nil, nil, SW_SHOW);
end;

procedure TInfoForm.URL1Click(Sender: TObject);
begin
  shellexecute(application.Handle, 'open', pchar('mailto:'+url1.Caption+'?subject=SpaceMission ' + mainform.fengineversion), nil, nil, SW_SHOW);
end;

end.

