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
  private
    FDirectory: string;
  public
    procedure ShowHTMLHelp(AHTML: string);
    procedure ShowMarkDownHelp(AMarkDownFile: string);
  end;

var
  HilfeForm: THilfeForm;

implementation

uses
  MarkDownProcessor, ShellAPI, Global;

{$R *.dfm}

procedure THilfeForm.ShowHTMLHelp(AHTML: string);
var
  DOC: Variant;
begin
  if not Assigned(WebBrowser1.Document) then
    WebBrowser1.Navigate('about:blank'); // do not localize

  DOC := WebBrowser1.Document;
  DOC.Clear;
  DOC.Write(AHTML);
  Doc.Close;
end;

procedure THilfeForm.ShowMarkDownHelp(AMarkDownFile: string);
var
  md: TMarkdownProcessor;
  slHtml, slCss: TStringList;
  cssFile: string;
begin
  FDirectory := ExtractFilePath(AMarkDownFile);
  slHtml := TStringList.Create();
  slCss := TStringList.Create();
  try
    slHtml.LoadFromFile(AMarkDownFile);
    cssFile := IncludeTrailingPathDelimiter(FDirectory) + 'Style.css'; // do not localize
    if FileExists(cssFile) then
      slCss.LoadFromFile(cssFile);
    md := TMarkdownProcessor.CreateDialect(mdCommonMark);
    try
      //md.AllowUnsafe := true;
      ShowHTMLHelp(
        '<html>'+                                                                // do not localize
        '<head>'+                                                                // do not localize
        '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'+   // do not localize
        '<style>'+slCss.Text+'</style>'+                                         // do not localize
        '</head>'+                                                               // do not localize
        '<body>'+                                                                // do not localize
        md.process(UTF8ToString(RawByteString(slHtml.Text)))+
        '</body>'+                                                               // do not localize
        '</html>');                                                              // do not localize
    finally
      FreeAndNil(md);
    end;
  finally
    FreeAndNil(slHtml);
    FreeAndNil(slCss);
  end;
end;

procedure THilfeForm.WebBrowser1BeforeNavigate2(ASender: TObject;
  const pDisp: IDispatch; const URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
begin
  if SameText(Copy(URL,1,7),'http://') or      // do not localize
     SameText(Copy(URL,1,8),'https://') or     // do not localize
     SameText(Copy(URL,1,7),'mailto:') then    // do not localize
  begin
    // Links in default Browser anzeigen
    ShellExecute(handle, 'open', PChar(string(URL)), '', '', SW_NORMAL);  // do not localize
    Cancel := true;
  end
  else if SameText(ExtractFileExt(URL), '.md') then // do not localize
  begin
    if SameText(Copy(URL,1,6), 'about:') then // do not localize
      ShowMarkDownHelp(IncludeTrailingPathDelimiter(FDirectory) + Copy(URL,7,Length(URL)))
    else
      ShowMarkDownHelp(URL);
    Cancel := true;
  end
  else
  begin
    Cancel := false;
  end;
end;

end.
