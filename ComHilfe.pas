unit ComHilfe;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleCtrls, SHDocVw;

type
  THilfeForm = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure WebBrowser1BeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
  public
    procedure ShowHTMLHelp(AHTML: string);
    procedure ShowMarkDownHelp(AMarkDownFile: string);
  end;

var
  HilfeForm: THilfeForm;

implementation

uses
  MarkDownProcessor, ShellAPI;

{$R *.dfm}

procedure THilfeForm.ShowHTMLHelp(AHTML: string);
var
  DOC: Variant;
begin
  if not Assigned(WebBrowser1.Document) then
    WebBrowser1.Navigate('about:blank');

  DOC := WebBrowser1.Document;
  DOC.Clear;
  DOC.Write(AHTML);
  Doc.Close;
end;

procedure THilfeForm.ShowMarkDownHelp(AMarkDownFile: string);
var
  md: TMarkdownProcessor;
  sl: TStringList;
begin
  sl := TStringList.Create();
  try
    sl.LoadFromFile(AMarkDownFile);
    md := TMarkdownProcessor.CreateDialect(mdCommonMark);
    try
      //md.AllowUnsafe := true;
      sl.Text := md.process(UTF8Decode(sl.Text));
      ShowHTMLHelp(sl.Text);
    finally
      FreeAndNil(md);
    end;
  finally
    FreeAndNil(sl);
  end;
end;

procedure THilfeForm.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
begin
  if SameText(Copy(URL,1,7),'http://') or
     SameText(Copy(URL,1,8),'https://') or
     SameText(Copy(URL,1,7),'mailto:') then
  begin
    // Links in default Browser anzeigen
    ShellExecute(handle, 'open', PChar(string(URL)), '', '', SW_NORMAL);
    Cancel := true;
  end
  else
  begin
    Cancel := false;
  end;
end;

end.
