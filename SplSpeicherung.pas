unit SplSpeicherung;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin;

type
  TSpeicherungForm = class(TForm)
    Bevel1: TBevel;
    LadenBtn: TButton;
    LoeschenBtn: TButton;
    AktualisierenBtn: TButton;
    SpeichernBtn: TButton;
    AbbrechenBtn: TButton;
    LevelListBox: TListBox;
    Label2: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    LevelName: TEdit;
    ElPanel1: TPanel;
    li4a: TLabel;
    li1: TLabel;
    li3b: TLabel;
    li3a: TLabel;
    li4b: TLabel;
    liu: TLabel;
    liw: TLabel;
    li2a: TLabel;
    li2b: TLabel;
    procedure LoeschenBtnClick(Sender: TObject);
    procedure LadenBtnClick(Sender: TObject);
    procedure SpeichernBtnClick(Sender: TObject);
    procedure LevelListBoxClick(Sender: TObject);
    procedure LevelNameChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DsFancyButton2Click(Sender: TObject);
    procedure AbbrechenBtnClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure LevelListBoxDblClick(Sender: TObject);
  public
    procedure SearchSaves;
  end;

var
  SpeicherungForm: TSpeicherungForm;

const
  FCompVersion = '1.0';

implementation

uses
  SplMain;

{$R *.DFM}

procedure TSpeicherungForm.SearchSaves;
var
  sr: TSearchRec;
  res: integer;
begin
  LevelName.text := '';
  LevelListBox.items.clear;
  li1.visible := false;
  li2a.visible := false;
  li2b.visible := false;
  li3a.visible := false;
  li3b.visible := false;
  li4a.visible := false;
  li4b.visible := false;
  liu.visible := false;
  liw.visible := true;
  li1.caption := 'n/a';
  li2b.caption := 'n/a';
  li3b.caption := 'n/a';
  li4b.caption := 'n/a';
  LadenBtn.enabled := false;
  LoeschenBtn.enabled := false;
  res := FindFirst(mainform.fdirectory+'Spielstände\*.sav', 0, sr);
  try
    while (res = 0) do
    begin
      if (sr.name <> '.') and (sr.name <> '..') then
        LevelListBox.items.Add(copy(sr.Name, 0, length(sr.name)-4));
      res := FindNext(sr);
    end;
  finally
    FindClose(sr);
  end;
end;

procedure TSpeicherungForm.LoeschenBtnClick(Sender: TObject);
var
  Markiert: boolean;
  i: integer;
begin
  Markiert := false;
  for i := 0 to LevelListBox.items.Count-1 do
  begin
    if LevelListBox.Selected[i] then Markiert := true;
  end;
  if not Markiert then exit;
  if MessageDlg('Diesen Spielstand wirklich löschen?',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    li1.visible := false;
    li2a.visible := false;
    li2b.visible := false;
    li3a.visible := false;
    li3b.visible := false;
    li4a.visible := false;
    li4b.visible := false;
    liu.visible := false;
    liw.visible := false;
    li1.caption := 'n/a';
    li2b.caption := 'n/a';
    li3b.caption := 'n/a';
    li4b.caption := 'n/a';
    LadenBtn.enabled := false;
    LoeschenBtn.enabled := false;
    deletefile(mainform.FDirectory+'Spielstände\'+LevelListBox.Items.strings[LevelListBox.itemindex]+'.sav');
    searchsaves;
  end;
end;

procedure TSpeicherungForm.LadenBtnClick(Sender: TObject);
var
  Markiert: boolean;
  i: integer;
  SavGame: textfile;
begin
  Markiert := false;
  for i := 0 to LevelListBox.items.Count-1 do
  begin
    if LevelListBox.Selected[i] then Markiert := true;
  end;
  if not Markiert then exit;
  if LevelListBox.items.count = 0 then
  begin
    li1.visible := false;
    li2a.visible := false;
    li2b.visible := false;
    li3a.visible := false;
    li3b.visible := false;
    li4a.visible := false;
    li4b.visible := false;
    liu.visible := false;
    liw.visible := false;
    li1.caption := 'n/a';
    li2b.caption := 'n/a';
    li3b.caption := 'n/a';
    li4b.caption := 'n/a';
    LadenBtn.enabled := false;
    LoeschenBtn.enabled := false;
  end;
  {if liu.visible or (LevelListBox.items.count=0) then
    exit;}
  AssignFile(SavGame, mainform.FDirectory+'Spielstände\'+LevelListBox.Items.strings[LevelListBox.itemindex]+'.sav');
  Reset(SavGame);
  ReadLN(SavGame);
  ReadLN(SavGame);
  ReadLN(SavGame, mainform.FScore);
  ReadLN(SavGame, mainform.FLife);
  ReadLN(SavGame, mainform.Flevel);
  ReadLN(SavGame, mainform.FMenuItem);
  CloseFile(SavGame);
  mainform.playsound('SceneMov', false);
  mainform.FNextScene := gsNewLevel;
  mainform.FCheat := false;
  close;
end;

procedure TSpeicherungForm.SpeichernBtnClick(Sender: TObject);
var
  SavGame: textfile;
  i: integer;
begin
  if Levelname.text = '' then
  begin
    MessageDlg('Dies ist kein gültiger Spielstandname!', mtError, [mbOK], 0);
    LevelName.setfocus;
    exit;
  end;
  for i := 0 to length(LevelName.text) do
  begin
    if (copy(LevelName.text, i, 1) = '\') or
      (copy(LevelName.text, i, 1) = '/') or
      (copy(LevelName.text, i, 1) = ':') or
      (copy(LevelName.text, i, 1) = '*') or
      (copy(LevelName.text, i, 1) = '?') or
      (copy(LevelName.text, i, 1) = '"') or
      (copy(LevelName.text, i, 1) = '<') or
      (copy(LevelName.text, i, 1) = '>') or
      (copy(LevelName.text, i, 1) = '|') then
    begin
      MessageDlg('Dies ist kein gültiger Spielstandname!', mtError, [mbOK], 0);
      LevelName.setfocus;
      exit;
    end;
  end;
  if LevelListBox.items.IndexOf(LevelName.text) > -1 then
  begin
    if MessageDlg('Spielstand ist bereits vorhanden. Ersetzen?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      exit;
  end;
  AssignFile(SavGame, mainform.FDirectory+'Spielstände\'+LevelName.text+'.sav');
  Rewrite(SavGame);
  WriteLN(SavGame, '; SpaceMission '+FCompVersion);
  WriteLN(SavGame, '; SAV-File');
  WriteLN(SavGame, mainform.FScore);
  WriteLN(SavGame, mainform.FLife);
  WriteLN(SavGame, mainform.FLevel);
  WriteLN(SavGame, mainform.FMenuItem);
  CloseFile(SavGame);
  SearchSaves;
end;

procedure TSpeicherungForm.LevelListBoxClick(Sender: TObject);
var
  Ergebniss: String;
  SavGame: textfile;
  Punkte, Leben, Level, Art: integer;
begin
  ladenbtn.enabled := true;
  loeschenbtn.enabled := true;
  li1.visible := false;
  li2a.visible := false;
  li2b.visible := false;
  li3a.visible := false;
  li3b.visible := false;
  li4a.visible := false;
  li4b.visible := false;
  liu.visible := false;
  liw.visible := false;
  li1.caption := 'n/a';
  li2b.caption := 'n/a';
  li3b.caption := 'n/a';
  li4b.caption := 'n/a';
  if (LevelListBox.items.count=0) or (LevelListBox.itemindex = -1) then
  begin
    ladenbtn.enabled := false;
    loeschenbtn.enabled := false;
    liw.visible := true;
    exit;
  end;
  LevelName.Text := LevelListBox.Items.strings[LevelListBox.itemindex];
  AssignFile(SavGame, mainform.FDirectory+'Spielstände\'+LevelListBox.Items.strings[LevelListBox.itemindex]+'.sav');
  Reset(SavGame);
  ReadLN(SavGame, Ergebniss);
  if Ergebniss <> '; SpaceMission '+FCompVersion then
  begin
    liu.visible := true;
    ladenbtn.enabled := false;
    CloseFile(SavGame);
    exit;
  end;
  ReadLN(SavGame, Ergebniss);
  if Ergebniss <> '; SAV-File' then
  begin
    liu.visible := true;
    ladenbtn.enabled := false;
    CloseFile(SavGame);
    exit;
  end;
  ReadLN(SavGame, Punkte);
  ReadLN(SavGame, Leben);
  ReadLN(SavGame, Level);
  ReadLN(SavGame, Art);
  CloseFile(SavGame);
  li1.visible := true;
  li2a.visible := true;
  li2b.visible := true;
  li3a.visible := true;
  li3b.visible := true;
  li4a.visible := true;
  li4b.visible := true;
  if Art = 1 then
    li1.caption := 'Das Level ist ein normales Level.'
  else
    li1.caption := 'Das Level ist ein Zufallslevel.';
  li3b.caption := inttostr(Level);
  li4b.caption := inttostr(Leben);
  li2b.caption := inttostr(Punkte);
end;

procedure TSpeicherungForm.LevelNameChange(Sender: TObject);
begin
  //listbox1.Items.indexof('Level '+spinedit1.text);
end;

procedure TSpeicherungForm.Button4Click(Sender: TObject);
begin
  mainform.dxtimer.enabled := not mainform.gamepause.checked;
  close;
end;

procedure TSpeicherungForm.FormShow(Sender: TObject);
begin
  mainform.dxtimer.enabled := false;
  SearchSaves;
  if mainform.FNotSave then
  begin
    label1.enabled := false;
    LevelName.enabled := false;
    SpeichernBtn.enabled := false;
  end
  else
  begin
    label1.enabled := true;
    LevelName.enabled := true;
    SpeichernBtn.enabled := true;
  end;
end;

procedure TSpeicherungForm.DsFancyButton2Click(Sender: TObject);
begin
  SearchSaves;
end;

procedure TSpeicherungForm.AbbrechenBtnClick(Sender: TObject);
begin
  close;
end;

procedure TSpeicherungForm.FormHide(Sender: TObject);
begin
  if not mainform.gamepause.checked then mainform.dxtimer.enabled := true;
end;

procedure TSpeicherungForm.LevelListBoxDblClick(Sender: TObject);
begin
  LadenBtn.click;
end;

end.

