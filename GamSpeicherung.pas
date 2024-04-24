unit GamSpeicherung;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin{$IF CompilerVersion >= 23.0}, System.UITypes{$IFEND};

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
  private
    function GetSpielstandVerzeichnisSystem: string;
    function GetSpielstandVerzeichnisUser: string;
    function GetSaveGameFileName(SpielstandName: string; forceuserdir: boolean): string;
  public
    procedure SearchSaves;
  end;

var
  SpeicherungForm: TSpeicherungForm;

implementation

uses
  Global, GamMain, ComLevelReader;

{$R *.DFM}

resourcestring
  SSaveGameFileNotFound = 'Spielstandsdatei nicht gefunden';
  SNa = 'n/a';
  SSaveGameFolder = 'Spielstände';
  SSaveGameSubFolder = 'SpaceMission';

{ TSpeicherungForm }

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
  li1.caption := SNa;
  li2b.caption := SNa;
  li3b.caption := SNa;
  li4b.caption := SNa;
  LadenBtn.enabled := false;
  LoeschenBtn.enabled := false;
  res := FindFirst(IncludeTrailingPathDelimiter(GetSpielstandVerzeichnisSystem)+'*.sav', 0, sr);
  try
    while (res = 0) do
    begin
      if (sr.name <> '.') and (sr.name <> '..') then
        LevelListBox.items.Add(ChangeFileExt(sr.Name, ''));
      res := FindNext(sr);
    end;
  finally
    FindClose(sr);
  end;
  res := FindFirst(IncludeTrailingPathDelimiter(GetSpielstandVerzeichnisUser)+'*.sav', 0, sr);
  try
    while (res = 0) do
    begin
      // Anmerkung: Contains() oder IndexOf() sind nicht case-sensitive
      if (sr.name <> '.') and (sr.name <> '..') and (LevelListBox.Items.IndexOf(ChangeFileExt(sr.Name, ''))=-1) then
        LevelListBox.items.Add(ChangeFileExt(sr.Name, ''));
      res := FindNext(sr);
    end;
  finally
    FindClose(sr);
  end;
  LevelListBox.Sorted := true;
end;

procedure TSpeicherungForm.LoeschenBtnClick(Sender: TObject);
resourcestring
  SDeleteSaveGame = 'Diesen Spielstand wirklich löschen?';
var
  fil: string;
begin
  if LevelListBox.ItemIndex = -1 then exit;

  if MessageDlg(SDeleteSaveGame, mtConfirmation, mbYesNoCancel, 0) = mrYes then
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
    li1.caption := SNa;
    li2b.caption := SNa;
    li3b.caption := SNa;
    li4b.caption := SNa;
    LadenBtn.enabled := false;
    LoeschenBtn.enabled := false;
    fil := GetSaveGameFileName(LevelListBox.Items.strings[LevelListBox.itemindex], false);
    if not fileexists(fil) then raise Exception.Create(SSaveGameFileNotFound);
    deletefile(fil);
    searchsaves;
  end;
end;

function TSpeicherungForm.GetSaveGameFileName(SpielstandName: string; forceuserdir: boolean): string;
var
  usr, sys: string;
begin
  usr := IncludeTrailingPathDelimiter(GetSpielstandVerzeichnisUser) + SpielstandName + '.sav'; // ab SpaceMission 1.2+ // do not localize
  sys := IncludeTrailingPathDelimiter(GetSpielstandVerzeichnisSystem) + SpielstandName + '.sav'; // alte Versionen von SpaceMission <1.2 // do not localize
  if fileexists(usr) or forceuserdir then exit(usr);
  if fileexists(sys) then exit(sys);
  exit(usr);
end;

procedure TSpeicherungForm.LadenBtnClick(Sender: TObject);
var
  SavGame: TSaveData;
  fil: string;
begin
  if LevelListBox.ItemIndex = -1 then exit;

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
    li1.caption := SNa;
    li2b.caption := SNa;
    li3b.caption := SNa;
    li4b.caption := SNa;
    LadenBtn.enabled := false;
    LoeschenBtn.enabled := false;
  end;
  {if liu.visible or (LevelListBox.items.count=0) then
    exit;}
  SavGame := TSaveData.Create;
  try
    fil := GetSaveGameFileName(LevelListBox.Items.strings[LevelListBox.itemindex], false);
    if not fileexists(fil) then raise Exception.Create(SSaveGameFileNotFound);
    SavGame.LoadFromFile(fil);
    mainform.FScore := SavGame.Score;
    mainform.FLife := SavGame.Life;
    mainform.FLevel := SavGame.Level;
    mainform.FGameMode := SavGame.GameMode;
    MainForm.FLevelDataAlreadyLoaded := true; // do not call NewLevel() in StartSceneMain
    if Assigned(SavGame.LevelData) then
    begin
      MainForm.LevelData.Assign(SavGame.LevelData);
    end;
  finally
    FreeAndNil(SavGame);
  end;
  mainform.playsound(smsSceneMov, false);
  mainform.FNextScene := gsNewLevel;
  mainform.FCheats := [];
  close;
end;

procedure TSpeicherungForm.SpeichernBtnClick(Sender: TObject);
resourcestring
  SNoValidSaveGameName = 'Dies ist kein gültiger Spielstandname!';
  SEmptySaveGameName = 'Bitte geben Sie einen Namen für den Spielstand ein';
  SReplaceSaveGame = 'Spielstand ist bereits vorhanden. Ersetzen?';
var
  SavGame: TSaveData;
  i: integer;
begin
  if Levelname.text = '' then
  begin
    MessageDlg(SEmptySaveGameName, mtError, [mbOK], 0);
    LevelName.setfocus;
    exit;
  end;
  for i := 1 to length(LevelName.text) do
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
      MessageDlg(SNoValidSaveGameName, mtError, [mbOK], 0);
      LevelName.setfocus;
      exit;
    end;
  end;
  if LevelListBox.items.IndexOf(LevelName.text) > -1 then
  begin
    if MessageDlg(SReplaceSaveGame, mtConfirmation, mbYesNoCancel, 0) <> mrYes then
      exit;
  end;

  SavGame := TSaveData.Create;
  try
    SavGame.Score := mainform.FScoreAtLevelStart;//mainform.FScore;
    SavGame.Life := mainform.FLifeAtLevelStart;//mainform.FLife;
    SavGame.Level := mainform.FLevel;
    SavGame.GameMode := mainform.FGameMode;
    if not Assigned(SavGame.LevelData) then SavGame.LevelData := TLevelData.Create;
    SavGame.LevelData.Assign(mainForm.LevelData);
    SavGame.SaveToFile(GetSaveGameFileName(LevelName.text, true));
  finally
    FreeAndNil(SavGame);
  end;

  SearchSaves;
end;

procedure TSpeicherungForm.LevelListBoxClick(Sender: TObject);
resourcestring
  SNoNA = 'n/a';
  SIsNormalLevel = 'Das Level ist ein norm. Level';
  SIsRandomLevel = 'Das Level ist ein Zufallslevel';
  SHasAttachedLevel = '%s mit Karte';
var
  SavGame: TSaveData;
  Punkte, Leben, Level: integer;
  BeinhaltetLevelDaten: boolean;
  Art: TGameMode;
  fil: string;
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
  li1.caption := SNoNA;
  li2b.caption := SNoNA;
  li3b.caption := SNoNA;
  li4b.caption := SNoNA;
  if (LevelListBox.items.count=0) or (LevelListBox.itemindex = -1) then
  begin
    ladenbtn.enabled := false;
    loeschenbtn.enabled := false;
    liw.visible := true;
    exit;
  end;
  LevelName.Text := LevelListBox.Items.strings[LevelListBox.itemindex];

  SavGame := TSaveData.Create;
  try
    try
      fil := GetSaveGameFileName(LevelListBox.Items.strings[LevelListBox.itemindex], false);
      if not fileexists(fil) then raise Exception.Create(SSaveGameFileNotFound);
      SavGame.LoadFromFile(fil);
      Punkte := SavGame.Score;
      Leben := SavGame.Life;
      Level := SavGame.Level;
      Art := SavGame.GameMode;
      BeinhaltetLevelDaten := Assigned(SavGame.LevelData);
    except
      liu.visible := true;
      ladenbtn.enabled := false;
      exit;
    end;
  finally
    FreeAndNil(SavGame);
  end;
  li1.visible := true;
  li2a.visible := true;
  li2b.visible := true;
  li3a.visible := true;
  li3b.visible := true;
  li4a.visible := true;
  li4b.visible := true;
  if Art = gmLevels then
    li1.caption := SIsNormalLevel
  else
    li1.caption := SIsRandomLevel;
  if BeinhaltetLevelDaten then
    li1.Caption := Format(SHasAttachedLevel, [li1.Caption]);
  li2b.caption := FloatToStrF(Punkte,ffNumber,14,0);
  li3b.caption := inttostr(Level);
  li4b.caption := inttostr(Leben);
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

function TSpeicherungForm.GetSpielstandVerzeichnisSystem: string;
begin
  // nicht mehr verwendet seit version 1.2
  result := OwnDirectory + SSaveGameFolder;
end;

function TSpeicherungForm.GetSpielstandVerzeichnisUser: string;
begin
  try
    result := GetKnownFolderPath(FOLDERID_SavedGames);
  except
    result := '';
  end;
  if result = '' then
  begin
    // Pre Vista
    result := OwnDirectory + SSaveGameFolder;
  end
  else
  begin
    result := IncludeTrailingPathDelimiter(result);
    result := result + SSaveGameSubFolder;
  end;
  result := IncludeTrailingPathDelimiter(result);
  ForceDirectories(result);
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

