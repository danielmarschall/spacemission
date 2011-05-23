unit LevSpeicherung;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, ComCtrls;

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
  Global, LevMain;

{$R *.DFM}

procedure TSpeicherungForm.SearchLevels;
var
  {sr: TSearchRec;
  res: integer;}
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
  {res := FindFirst(mainform.fdirectory+'Levels\*.lev', 0, sr);
  try
    while (res = 0) do
    begin
      if (sr.name <> '.') and (sr.name <> '..') then
        LevelListBox.items.Add(copy(sr.Name, 0, length(sr.name)-4));
      res := FindNext(sr);
    end;
  finally
    FindClose(sr);
  end;}
  for i := 1 to 9999 do
  begin
    if fileexists(fdirectory+'Levels\Level '+inttostr(i)+'.lev') then
      LevelListBox.items.Add('Level ' + inttostr(i));
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
  if MessageDlg('Dieses Level wirklich lˆschen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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
    deletefile(FDirectory+'Levels\'+
      LevelListBox.Items.strings[LevelListBox.itemindex]+'.lev');
    SearchLevels;
  end;
end;

procedure TSpeicherungForm.LadenBtnClick(Sender: TObject);
var
  Markiert: boolean;
  i, TempArtMain, TempLiveMain: integer;
  SavGame: textfile;
  Ergebnis: array[1..5] of string;
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
  // Da Button bei ung¸ltigen Level deaktiviert wird, ist das nicht mehr nˆtig.
  {if liu.visible or (LevelListBox.items.count=0) then
    exit;}
  // Vorbereiten
  MainForm.DestroyLevel;
  MainForm.LevChanged := false;
  // ÷ffnen
  AssignFile(SavGame, FDirectory+'Levels\'+
    LevelListBox.Items.strings[LevelListBox.itemindex]+'.lev');
  Reset(SavGame);
  // Laden
  ReadLN(SavGame); // --> Copyrightinfo
  ReadLN(SavGame); // --> Copyrightinfo
  ReadLN(SavGame, Ergebnis[5]); // --> L‰nge der Karte
  MainForm.ScrollBar.Max := strtoint(Ergebnis[5]);
  MainForm.Enemys.Clear;
  TempArtMain := MainForm.ArtChecked;
  TempLiveMain := MainForm.LiveEdit;
  while not seekEoF(SavGame) do
  begin
    ReadLN(SavGame, Ergebnis[3]);
    ReadLN(SavGame, Ergebnis[1]);
    ReadLN(SavGame, Ergebnis[2]);
    ReadLN(SavGame, Ergebnis[4]);
    MainForm.EnemyAdd(strtoint(Ergebnis[1]), strtoint(Ergebnis[2]), strtoint(Ergebnis[3]), strtoint(Ergebnis[4]));
    MainForm.ArtChecked := strtoint(Ergebnis[3]);
    MainForm.LiveEdit := strtoint(Ergebnis[4]);
    MainForm.EnemyCreate(strtoint(Ergebnis[1]), strtoint(Ergebnis[2]));
    inc(MainForm.NumEnemys);
    if Ergebnis[3] = '7' then MainForm.Boss := true;
  end;
  MainForm.LiveEdit := TempLiveMain;
  MainForm.ArtChecked := TempArtMain;
  // Schlieﬂen
  CloseFile(SavGame);
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
  SavGame: textfile;
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
      MessageDlg('Dies ist kein g¸ltiger Levelname!', mtError, [mbOK], 0);
      LevelName.SetFocus;
      exit;
    end;
  end;}
  if LevelListBox.items.IndexOf('Level ' + inttostr(SpinEdit.Position)) > -1 then
  begin
    if MessageDlg('Level ist bereits vorhanden. Ersetzen?', mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      exit;
  end;
  // ÷ffnen oder erstellen
  AssignFile(SavGame, FDirectory+'Levels\Level '+inttostr(SpinEdit.Position)+'.lev');
  Rewrite(SavGame);
  // Sortierung
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
  WriteLN(SavGame, '; SpaceMission ' + FCompVersion);
  WriteLN(SavGame, '; LEV-File');
  WriteLN(SavGame, inttostr(MainForm.ScrollBar.Max)); // --> L‰nge der Karte
  for i := 0 to mainform.enemys.count-1 do
  begin
    WriteLN(SavGame, filter(3, mainform.enemys.Strings[i]));
    WriteLN(SavGame, filter(1, mainform.enemys.Strings[i]));
    WriteLN(SavGame, filter(2, mainform.enemys.Strings[i]));
    WriteLN(SavGame, filter(4, mainform.enemys.Strings[i]));
  end;
  // Schlieﬂen
  CloseFile(SavGame);
  // Nacharbeiten
  MainForm.LevChanged := false;
  MainForm.AnzeigeAct;
  SearchLevels;
end;

procedure TSpeicherungForm.LevelListBoxClick(Sender: TObject);
var
  Ergebnis, boss, l, temp: string;
  SavGame: textfile;
  x, a: integer;
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
  AssignFile(SavGame, FDirectory+'Levels\'+
    LevelListBox.Items.strings[LevelListBox.itemindex]+'.lev');
  Reset(SavGame);
  ReadLN(SavGame, Ergebnis);
  if Ergebnis <> '; SpaceMission '+FCompVersion then
  begin
    liu.visible := true;
    LadenBtn.enabled := false;
    CloseFile(SavGame);
    exit;
  end;
  ReadLN(SavGame, Ergebnis);
  if Ergebnis <> '; LEV-File' then
  begin
    liu.visible := true;
    LadenBtn.enabled := false;
    CloseFile(SavGame);
    exit;
  end;
  ReadLN(SavGame, l);
  x := 0;
  a := 0;
  boss := 'Nein';
  while not SeekEOF(SavGame) do
  begin
    ReadLN(SavGame, Ergebnis);
    inc(a);
    if a = 5 then a := 1;
    if (a = 1) and (Ergebnis = '7') then boss := 'Ja';
    inc(x);
  end;
  CloseFile(SavGame);
  if a <> 4 then
  begin
    liu.visible := true;
    LadenBtn.enabled := false;
  end
  else
  begin
    li1a.visible := true;
    li2a.visible := true;
    li3a.visible := true;
    li1b.visible := true;
    li2b.visible := true;
    li3b.visible := true;
    LadenBtn.enabled := true;
    LoeschenBtn.enabled := true;
    li1b.caption := inttostr(trunc(x / 4));
    li2b.caption := boss;
    li3b.caption := l + ' Felder';
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
  if not (Key in [#13, #08, '0'..'9']) then
    Key := #0;
end;

procedure TSpeicherungForm.SpinEditEdtChange(Sender: TObject);
begin
  SpinEdit.Position := strtoint(SpinEditEdt.text);
end;

end.

