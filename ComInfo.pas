unit ComInfo;
                                        
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ShellAPI, ExtCtrls;

type
  TInfoForm = class(TForm)
    OkBtn: TButton;
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
    MemoMitwirkende: TMemo;
    procedure OkBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WebsiteClick(Sender: TObject);
    procedure EMailClick(Sender: TObject);
  end;

var
  InfoForm: TInfoForm;

implementation

uses
  Global;

{$R *.DFM}

procedure TInfoForm.OkBtnClick(Sender: TObject);
begin
  close;
end;

procedure TInfoForm.FormCreate(Sender: TObject);
resourcestring
  SVersion = 'Version %s';
begin
  VersionLbl.caption := Format(SVersion, [ProgramVersion]);
end;

procedure TInfoForm.WebsiteClick(Sender: TObject);
begin
  ShellExecute(application.Handle, 'open', pchar('https://'+url2.caption+'/'), nil, nil, SW_SHOW); // do not localize
end;

procedure TInfoForm.EMailClick(Sender: TObject);
begin
  ShellExecute(application.Handle, 'open', pchar('mailto:'+url1.Caption+'?subject=SpaceMission ' + ProgramVersion), nil, nil, SW_SHOW); // do not localize
end;

end.

