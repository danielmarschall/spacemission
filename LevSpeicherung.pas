unit LevSpeicherung;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, ComCtrls{$IF CompilerVersion >= 23.0}, System.UITypes{$IFEND};

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
    ElPanel1: TPanel;
    li3a: TLabel;
    li1b: TLabel;
    li1a: TLabel;
    li2b: TLabel;
    li2a: TLabel;
    li3b: TLabel;
    liu: TLabel;
    liw: TLabel;
    LevelNumber: TSpinEdit;
    procedure LoeschenBtnClick(Sender: TObject);
    procedure LadenBtnClick(Sender: TObject);
    procedure SpeichernBtnClick(Sender: TObject);
    procedure LevelListBoxClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DsFancyButton2Click(Sender: TObject);
    procedure AbbrechenBtnClick(Sender: TObject);
    procedure LevelNameChange(Sender: TObject);
    procedure FormHide(Sender: TObject);
  public
    procedure SearchLevels;
    function RightStr(str: string; count: integer): string;
  end;

var
  SpeicherungForm: TSpeicherungForm;

implementation

uses
  Global, LevMain, ComLevelReader;

{$R *.DFM}

procedure TSpeicherungForm.SearchLevels;
var
  i: integer;
begin
  //SpinEdit.Value := 1;
  LevelListBox.items.clear;
  li1a.visible := false;
  li2a.visible := false;
  li3a.visible := false;
  li1b.visible := false;
  li2b.visible := false;
  li3b.visible := false;
  liw.visible := true;
  LadenBtn.enabled := false;
  LoeschenBtn.enabled := false;
  for i := 1 to 9999 do
  begin
    if fileexists(GetLevelFileName(i)) then
      LevelListBox.items.Add(ChangeFileExt(ExtractFileName(GetLevelFileName(i)),''));
  end;
end;

procedure TSpeicherungForm.LoeschenBtnClick(Sender: TObject);
begin
  if LevelListBox.ItemIndex = -1 then exit;

  if MessageDlg('Dieses Level wirklich löschen?', mtConfirmation, mbYesNoCancel, 0) = mrYes then
  begin
    li1a.visible := false;
    li2a.visible := false;
    li3a.visible := false;
    li1b.visible := false;
    li2b.visible := false;
    li3b.visible := false;
    liu.visible := false;
    liw.visible := true;
    LadenBtn.enabled := false;
    LoeschenBtn.enabled := false;
    deletefile(IncludeTrailingPathDelimiter(ExtractFilePath(GetLevelFileName(1)))+
      LevelListBox.Items.strings[LevelListBox.itemindex]+'.lev');
    SearchLevels;
  end;
end;

procedure TSpeicherungForm.LadenBtnClick(Sender: TObject);
var
  i: integer;
begin
  if LevelListBox.ItemIndex = -1 then exit;

  if MainForm.LevChanged then
  begin
    if MessageDlg('Neues Level laden und Änderungen verwerfen?', mtConfirmation, mbYesNoCancel, 0) <> mrYes then exit;
  end;

  // Da Button bei ungültigen Level deaktiviert wird, ist das nicht mehr nötig.
  {if liu.visible or (LevelListBox.items.count=0) then
    exit;}
  // Vorbereiten
  MainForm.DestroyLevel;
  MainForm.LevChanged := false;

  MainForm.ScrollBar.Max := MainForm.LevData.LevelEditorLength;
  MainForm.LevData.Load(
    IncludeTrailingPathDelimiter(ExtractFilePath(GetLevelFileName(1)))+
    LevelListBox.Items.strings[LevelListBox.itemindex]+'.lev');
  for i := 0 to MainForm.LevData.CountEnemies - 1 do
  begin
    MainForm.EnemyCreateSprite(
      MainForm.LevData.EnemyAdventTable[i].x,
      MainForm.LevData.EnemyAdventTable[i].y,
      MainForm.LevData.EnemyAdventTable[i].enemyType,
      MainForm.LevData.EnemyAdventTable[i].lifes
    );
  end;
  MainForm.NumEnemys := MainForm.LevData.CountEnemies;
  MainForm.Boss := MainForm.LevData.HasBoss;

  // Nacharbeiten
  MainForm.AnzeigeAct;
  close;
end;

function TSpeicherungForm.RightStr(str: string; count: integer): string;
begin
  result := copy(str, length(str)-(count-1), count);
end;

procedure TSpeicherungForm.SpeichernBtnClick(Sender: TObject);
begin
  if MainForm.LevData.CountEnemies = 0 then
  begin
    MessageDlg('Das Level ist leer!', mtError, [mbOK], 0);
    LevelNumber.SetFocus;
    exit;
  end;
  {for i := 0 to length(LevelName.text) do
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
      MessageDlg('Dies ist kein gültiger Levelname!', mtError, [mbOK], 0);
      LevelName.SetFocus;
      exit;
    end;
  end;}
  if LevelListBox.items.IndexOf('Level ' + inttostr(LevelNumber.Value)) > -1 then
  begin
    if MessageDlg('Level ist bereits vorhanden. Ersetzen?', mtConfirmation, mbYesNoCancel, 0) <> mrYes then
      exit;
  end;

  // Speichern
  MainForm.LevData.LevelEditorLength := MainForm.ScrollBar.Max;
  MainForm.LevData.Save(GetLevelFileName(LevelNumber.Value));

  // Nacharbeiten
  MainForm.LevChanged := false;
  MainForm.AnzeigeAct;
  SearchLevels;
end;

procedure TSpeicherungForm.LevelListBoxClick(Sender: TObject);
var
  LevelData: TLevelData;
  boss: boolean;
  i: Integer;
  temp: string;
  anzahlEinheiten: integer;
begin
  li1a.visible := false;
  li2a.visible := false;
  li3a.visible := false;
  li1b.visible := false;
  li2b.visible := false;
  li3b.visible := false;
  liu.visible := false;
  liw.visible := false;
  if (LevelListBox.items.count=0) or (LevelListBox.itemindex = -1) then
  begin
    ladenbtn.enabled := false;
    loeschenbtn.enabled := false;
    liw.visible := true;
    exit;
  end;
  temp := LevelListBox.Items.strings[LevelListBox.itemindex];
  LevelNumber.Value := strtoint(RightStr(temp, length(temp)-Length('Level ')));

  LevelData := TLevelData.Create;
  try
    try
      LevelData.Load(IncludeTrailingPathDelimiter(ExtractFilePath(GetLevelFileName(1)))+
        LevelListBox.Items.strings[LevelListBox.itemindex]+'.lev');
    except
      liu.visible := true;
      LadenBtn.enabled := false;
    end;

    boss := false;
    anzahlEinheiten := Length(LevelData.EnemyAdventTable);
    for i := 0 to anzahlEinheiten - 1 do
    begin
      if LevelData.EnemyAdventTable[i].enemyType = etEnemyBoss then
      begin
        boss := true;
      end;
    end;

    li1a.visible := true;
    li2a.visible := true;
    li3a.visible := true;
    li1b.visible := true;
    li2b.visible := true;
    li3b.visible := true;
    LadenBtn.enabled := true;
    LoeschenBtn.enabled := true;
    li1b.caption := inttostr(anzahlEinheiten);
    if boss then
      li2b.caption := 'Ja'
    else
      li2b.caption := 'Nein';
    li3b.caption := IntToStr(LevelData.LevelEditorLength) + ' Felder';
  finally
    FreeAndNil(LevelData);
  end;
end;

procedure TSpeicherungForm.Button4Click(Sender: TObject);
begin
  close;
end;

procedure TSpeicherungForm.FormShow(Sender: TObject);
begin
  mainform.dxtimer.enabled := false;
  SearchLevels;
end;

procedure TSpeicherungForm.DsFancyButton2Click(Sender: TObject);
begin
  SearchLevels;
end;

procedure TSpeicherungForm.AbbrechenBtnClick(Sender: TObject);
begin
  close;
end;

procedure TSpeicherungForm.LevelNameChange(Sender: TObject);
begin
  {...}
end;

procedure TSpeicherungForm.FormHide(Sender: TObject);
begin
  mainform.dxtimer.enabled := true;
end;

end.

