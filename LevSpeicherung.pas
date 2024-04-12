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
    SpinEditEdt: TEdit;
    SpinEdit: TUpDown;
    procedure LoeschenBtnClick(Sender: TObject);
    procedure LadenBtnClick(Sender: TObject);
    procedure SpeichernBtnClick(Sender: TObject);
    procedure LevelListBoxClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DsFancyButton2Click(Sender: TObject);
    procedure AbbrechenBtnClick(Sender: TObject);
    procedure LevelNameChange(Sender: TObject);
    procedure LevelListBoxDblClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure SpinEditClick(Sender: TObject; Button: TUDBtnType);
    procedure SpinEditEdtKeyPress(Sender: TObject; var Key: Char);
    procedure SpinEditEdtChange(Sender: TObject);
  public
    procedure SearchLevels;
    function RightStr(str: string; count: integer): string;
    function Filter(n: integer; s: string): string;
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
      LevelListBox.items.Add(ExtractFileName(GetLevelFileName(i)));
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
  if MessageDlg('Dieses Level wirklich löschen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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
  Markiert: boolean;
  i, TempArtMain, TempLiveMain: integer;
  LevelData: TLevelData;
begin
  Markiert := false;
  for i := 0 to LevelListBox.items.Count-1 do
  begin
    if LevelListBox.Selected[i] then Markiert := true;
  end;
  if not Markiert then exit;
  if LevelListBox.items.count = 0 then
  begin
    li1a.visible := false;
    li2a.visible := false;
    li3a.visible := false;
    li1b.visible := false;
    li2b.visible := false;
    li3b.visible := false;
    liw.visible := true;
    LadenBtn.enabled := false;
    LoeschenBtn.enabled := false;
  end;
  // Da Button bei ungültigen Level deaktiviert wird, ist das nicht mehr nötig.
  {if liu.visible or (LevelListBox.items.count=0) then
    exit;}
  // Vorbereiten
  MainForm.DestroyLevel;
  MainForm.LevChanged := false;

  LevelData := TLevelData.Create;
  try
    LevelData.Load(IncludeTrailingPathDelimiter(ExtractFilePath(GetLevelFileName(1)))+
      LevelListBox.Items.strings[LevelListBox.itemindex]+'.lev');
    MainForm.ScrollBar.Max := LevelData.LevelEditorLength;
    MainForm.Enemys.Clear;
    TempArtMain := MainForm.ArtChecked;
    TempLiveMain := MainForm.LiveEdit;
    MainForm.NumEnemys := Length(LevelData.EnemyAdventTable);
    for i := 0 to MainForm.NumEnemys-1 do
    begin
      MainForm.EnemyAdd(
        LevelData.EnemyAdventTable[i].x,
        LevelData.EnemyAdventTable[i].y,
        Ord(LevelData.EnemyAdventTable[i].enemyType),
        LevelData.EnemyAdventTable[i].lifes
      );
      MainForm.ArtChecked := Ord(LevelData.EnemyAdventTable[i].enemyType);
      MainForm.LiveEdit := LevelData.EnemyAdventTable[i].lifes;
      MainForm.EnemyCreate(
        LevelData.EnemyAdventTable[i].x,
        LevelData.EnemyAdventTable[i].y
      );
      if LevelData.EnemyAdventTable[i].enemyType = etEnemyBoss then MainForm.Boss := true;
    end;
  finally
    FreeAndNil(LevelData);
  end;
  MainForm.LiveEdit := TempLiveMain;
  MainForm.ArtChecked := TempArtMain;
  // Nacharbeiten
  MainForm.AnzeigeAct;
  close;
end;

function TSpeicherungForm.RightStr(str: string; count: integer): string;
begin
  result := copy(str, length(str)-(count-1), count);
end;

function TSpeicherungForm.Filter(n: integer; s: string): string;
var
  i, last: integer;
  start, start2: boolean;
  temp: string;
begin
  last := 0;
  start := false;
  start2 := false;
  temp := '';
  if n = 1 then
  begin
    for i := 1 to length(s)+1 do
    begin
      if copy(s, i, 1) = '-' then
      begin
        last := i;
        break;
      end;
    end;
    temp := copy(s, 1, last-1);
  end;
  if n = 2 then
  begin
    for i := 1 to length(s)+1 do
    begin
      if start2 then start := true;
      if copy(s, i, 1) = '-' then start2 := true;
      if (copy(s, i, 1) = ':') and start then break;
      if start then temp := temp + copy(s, i, 1)
    end;
  end;
  if n = 3 then
  begin
    for i := 1 to length(s)+1 do
    begin
      if start2 then start := true;
      if copy(s, i, 1) = ':' then start2 := true;
      if (copy(s, i, 1) = '(') and start then break;
      if start then temp := temp + copy(s, i, 1)
    end;
  end;
  if n = 4 then
  begin
    for i := 1 to length(s)+1 do
    begin
      if start2 then start := true;
      if copy(s, i, 1) = '(' then start2 := true;
      if (copy(s, i, 1) = ')') and start then break;
      if start then temp := temp + copy(s, i, 1)
    end;
  end;
  result := temp;
end;

procedure TSpeicherungForm.SpeichernBtnClick(Sender: TObject);
var
  LevelData: TLevelData;
  i, j: integer;
  puffer: string;
begin
  if mainform.Enemys.count = 0 then
  begin
    MessageDlg('Das Level ist leer!', mtError, [mbOK], 0);
    SpinEdit.SetFocus;
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
  if LevelListBox.items.IndexOf('Level ' + inttostr(SpinEdit.Position)) > -1 then
  begin
    if MessageDlg('Level ist bereits vorhanden. Ersetzen?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      exit;
  end;

  // Sortierung (wichtig)
  for j := 0 to mainform.enemys.Count - 2 do
  begin
    for i := 0 to mainform.enemys.Count - 2 do
    begin
      if strtoint(filter(1, mainform.enemys.Strings[i])) > strtoint(filter(1, mainform.enemys.Strings[i + 1])) then
      begin
        puffer := mainform.enemys.Strings[i];
        mainform.enemys.Strings[i] := mainform.enemys.Strings[i + 1];
        mainform.enemys.Strings[i + 1] := puffer;
      end;
    end;
  end;

  // Speichern
  LevelData := TLevelData.Create;
  try
    LevelData.LevelEditorLength := MainForm.ScrollBar.Max;
    SetLength(LevelData.EnemyAdventTable, mainform.enemys.count);
    for i := 0 to mainform.enemys.count-1 do
    begin
      LevelData.EnemyAdventTable[i].enemyType := TEnemyType(StrToInt(filter(3, mainform.enemys.Strings[i])));
      LevelData.EnemyAdventTable[i].x := StrToInt(filter(1, mainform.enemys.Strings[i]));
      LevelData.EnemyAdventTable[i].y := StrToInt(filter(2, mainform.enemys.Strings[i]));
      LevelData.EnemyAdventTable[i].lifes := StrToInt(filter(4, mainform.enemys.Strings[i]));
    end;
    LevelData.Save(GetLevelFileName(SpinEdit.Position));
  finally
    FreeAndNil(LevelData);
  end;

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
  SpinEdit.Position := strtoint(RightStr(temp, length(temp)-6));

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

procedure TSpeicherungForm.LevelListBoxDblClick(Sender: TObject);
begin
  LadenBtn.click;
end;

procedure TSpeicherungForm.FormHide(Sender: TObject);
begin
  mainform.dxtimer.enabled := true;
end;

procedure TSpeicherungForm.SpinEditClick(Sender: TObject;
  Button: TUDBtnType);
begin
  SpinEditEdt.Text := inttostr(SpinEdit.position);
end;

procedure TSpeicherungForm.SpinEditEdtKeyPress(Sender: TObject;
  var Key: Char);
begin
  {$IFDEF UNICODE}
  if not CharInSet(Key, [#13, #08, '0'..'9']) then
  {$ELSE}
  if not (Key in [#13, #08, '0'..'9']) then
  {$ENDIF}
    Key := #0;
end;

procedure TSpeicherungForm.SpinEditEdtChange(Sender: TObject);
begin
  SpinEdit.Position := strtoint(SpinEditEdt.text);
end;

end.

