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
    li4: TLabel;
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
    procedure FormCreate(Sender: TObject);
  private
    function GetListBoxSelectedLevelNumber: integer;
  public
    procedure SearchLevels;
  end;

var
  SpeicherungForm: TSpeicherungForm;

implementation

uses
  Global, LevMain, ComLevelReader;

{$R *.DFM}

resourcestring
  SLevelListBox = 'Level %d';
  SSelbsterstellt = 'Selbsterstellt';

procedure TSpeicherungForm.SearchLevels;
var
  i: integer;
  fil: TLevelFile;
begin
  //SpinEdit.Value := 1;
  LevelListBox.items.clear;
  li1a.visible := false;
  li2a.visible := false;
  li3a.visible := false;
  li1b.visible := false;
  li2b.visible := false;
  li3b.visible := false;
  li4.visible := false;
  liu.Visible := false;
  liw.visible := true;
  LadenBtn.enabled := false;
  LoeschenBtn.enabled := false;
  for i := 1 to MaxPossibleLevels do
  begin
    fil := GetLevelFileName(i, false);
    if fil.found then
    begin
      if fil.isUser then
        LevelListBox.items.Add(Format(SLevelListBox, [i])+' ('+SSelbsterstellt+')')
      else
        LevelListBox.items.Add(Format(SLevelListBox, [i]));
    end;
  end;
end;

procedure TSpeicherungForm.LoeschenBtnClick(Sender: TObject);
var
  fil: TLevelFile;
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
    li4.visible := false;
    liu.visible := false;
    liw.visible := true;
    LadenBtn.enabled := false;
    LoeschenBtn.enabled := false;
    fil := GetLevelFileName(GetListBoxSelectedLevelNumber,false);
    if not fil.found then raise Exception.Create('Leveldatei nicht gefunden');
    deletefile(fil.fileLocation);
    SearchLevels;
  end;
end;

procedure TSpeicherungForm.LadenBtnClick(Sender: TObject);
var
  fil: TLevelFile;
begin
  if LevelListBox.ItemIndex = -1 then exit;

  if MainForm.LevChanged and (MainForm.LevData.CountEnemies>0) then
  begin
    if MessageDlg('Neues Level laden und Änderungen verwerfen?', mtConfirmation, mbYesNoCancel, 0) <> mrYes then exit;
  end;

  // Da Button bei ungültigen Level deaktiviert wird, ist das nicht mehr nötig.
  {if liu.visible or (LevelListBox.items.count=0) then
    exit;}

  MainForm.DestroyLevel;
  MainForm.LevData.RasterErzwingen := true;
  fil := GetLevelFileName(GetListBoxSelectedLevelNumber,false);
  if not fil.found then raise Exception.Create('Leveldatei nicht gefunden');
  MainForm.LevData.LoadFromFile(fil.fileLocation);
  MainForm.RefreshFromLevData;
  MainForm.LevChanged := false;
  MainForm.AnzeigeAct;
  close;
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
  if LevelListBox.items.IndexOf(Format(SLevelListBox, [LevelNumber.Value])) > -1 then
  begin
    if MessageDlg('Level ist bereits vorhanden. Ersetzen?', mtConfirmation, mbYesNoCancel, 0) <> mrYes then
      exit;
  end;

  // Speichern
  MainForm.LevData.LevelEditorLength := MainForm.ScrollBar.Max;
  MainForm.LevData.SaveToFile(GetLevelFileName(LevelNumber.Value,true).fileLocation);

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
  anzahlEinheiten: integer;
  fil: TLevelFile;
begin
  li1a.visible := false;
  li2a.visible := false;
  li3a.visible := false;
  li1b.visible := false;
  li2b.visible := false;
  li3b.visible := false;
  li4.visible := false;
  liu.visible := false;
  liw.visible := false;
  if (LevelListBox.items.count=0) or (LevelListBox.itemindex = -1) then
  begin
    ladenbtn.enabled := false;
    loeschenbtn.enabled := false;
    liw.visible := true;
    exit;
  end;
  LevelNumber.Value := GetListBoxSelectedLevelNumber;

  LevelData := TLevelData.Create;
  try
    try
      LevelData.RasterErzwingen := true;

      fil := GetLevelFileName(GetListBoxSelectedLevelNumber,false);
      if not fil.found then raise Exception.Create('Leveldatei nicht gefunden');
      LevelData.LoadFromFile(fil.fileLocation);

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
      li4.visible := true;
      LadenBtn.enabled := true;
      LoeschenBtn.enabled := true;
      li1b.caption := inttostr(anzahlEinheiten);
      if boss then
        li2b.caption := 'Ja'
      else
        li2b.caption := 'Nein';
      li3b.caption := IntToStr(LevelData.LevelEditorLength) + ' Felder';
      li4.Caption := Trim(LevelData.LevelName + ' von ' + LevelData.LevelAuthor);
    finally
      FreeAndNil(LevelData);
    end;
  except
    liu.visible := true;
    LadenBtn.enabled := false;
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

function TSpeicherungForm.GetListBoxSelectedLevelNumber: integer;
var
  i: integer;
begin
  result := -1;
  if LevelListBox.itemindex = -1 then exit;
  for i := 1 to MaxPossibleLevels do
  begin
    if (LevelListBox.Items.strings[LevelListBox.itemindex] = Format(SLevelListBox, [i])) or
       (LevelListBox.Items.strings[LevelListBox.itemindex] = Format(SLevelListBox, [i])+' ('+SSelbstErstellt+')') then
    begin
      result := i;
      exit;
    end;
  end;
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

procedure TSpeicherungForm.FormCreate(Sender: TObject);
begin
  LevelNumber.MinValue := 1;
  LevelNumber.MaxValue := MaxPossibleLevels;
  LevelNumber.Value := 1;
end;

procedure TSpeicherungForm.FormHide(Sender: TObject);
begin
  mainform.dxtimer.enabled := true;
end;

end.

