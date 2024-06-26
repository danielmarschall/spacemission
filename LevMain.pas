unit LevMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, MMSystem,
  Dialogs, StdCtrls, ExtCtrls, Menus, DIB, DXClass, DXSprite, DXDraws,
  DXSounds, Spin, ComCtrls{$IF CompilerVersion >= 23.0}, System.UITypes,
  WinAPI.DirectDraw{$ENDIF}, DirectX, ComLevelReader, Global, IOUtils;

type
  TMainForm = class(TDXForm)
    MainMenu: TMainMenu;
    Spiel: TMenuItem;
    Beenden: TMenuItem;
    Hilfe: TMenuItem;
    Leer1: TMenuItem;
    Level: TMenuItem;
    Informationen: TMenuItem;
    Enemy1: TRadioButton;
    Enemy2: TRadioButton;
    Enemy3: TRadioButton;
    Enemy4: TRadioButton;
    Enemy5: TRadioButton;
    Enemy6: TRadioButton;
    Enemy7: TRadioButton;
    ScrollBar: TScrollBar;
    Bevel1: TBevel;
    Bevel2: TBevel;
    SelLabel: TLabel;
    SelPanel: TPanel;
    Bevel3: TBevel;
    SLabel1a: TLabel;
    SLabel2a: TLabel;
    SLabel1b: TLabel;
    SLabel2b: TLabel;
    SLabel0: TLabel;
    Neu: TMenuItem;
    Image1: TImage;
    SLabel3a: TLabel;
    SLabel3b: TLabel;
    SLabel4a: TLabel;
    SLabel4b: TLabel;
    LivesLabel: TLabel;
    StatusBar: TStatusBar;
    N1: TMenuItem;
    Spielfelderweitern1: TMenuItem;
    SidePanel: TPanel;
    LivesEdit: TSpinEdit;
    AlleLeveldateienaktualisieren1: TMenuItem;
    N2: TMenuItem;
    Leveltesten1: TMenuItem;
    Hilfe1: TMenuItem;
    N3: TMenuItem;
    AufUpdatesprfen1: TMenuItem;
    N4: TMenuItem;
    WasgibtesNeues1: TMenuItem;
    Enemy8: TRadioButton;
    procedure DXDrawFinalize(Sender: TObject);
    procedure DXDrawInitialize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DXTimerTimer(Sender: TObject; LagCount: Integer);
    procedure BeendenClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LevelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InformationenClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EnemyClick(Sender: TObject);
    procedure NeuClick(Sender: TObject);
    procedure DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Spielfelderweitern1Click(Sender: TObject);
    procedure ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure AlleLeveldateienaktualisieren1Click(Sender: TObject);
    procedure Leveltesten1Click(Sender: TObject);
    procedure HilfeTopicClick(Sender: TObject);
    procedure AufUpdatesprfen1Click(Sender: TObject);
  private
    function GetTestlevelFilename: string;
  public
    { VCL-Ersatz }
    spriteengine: tdxspriteengine;
    dxtimer: tdxtimer;
    imagelist: tdximagelist;
    dxdraw: tdxdraw;
    { Variablen }
    FMenuItem: integer;
    LevData: TLevelData;
    ScrollP: integer;
    AltScrollPos: integer;
    Boss: boolean;
    LevChanged: boolean;
    NumEnemys: integer;
    function SelectedEnemyType: TEnemyType;
    { Grafik-Routinen }
    function GetSpriteGraphic(Sprite: TSpaceMissionGraphicSprite): TPictureCollectionItem;
    { Level-Routinen }
    procedure EnemyCreateSprite(x, y: integer; AEnemyType: TEnemyType; ALives: integer);
    procedure DestroyLevel;
    procedure RefreshFromLevData;
    procedure AnzeigeAct;
    { Initialisiations-Routinen }
    procedure DXInit;
    procedure ProgramInit;
    { Farb-Routinen }
    function ComposeColor(Dest, Src: TRGBQuad; Percent: Integer): TRGBQuad;
    procedure PalleteAnim(Col: TRGBQuad; Time: Integer);
  end;

var
  MainForm: TMainForm;

implementation

uses
  LevSplash, LevSpeicherung, ComInfo, LevOptions, ShellAPI, ComHilfe;

{$R *.DFM}

resourcestring
  status_info = 'Zeigen Sie mit dem Mauszeiger auf eine Einheit, um deren Eigenschaften anzuzeigen...';

type
  TBackground = class(TBackgroundSprite)
  strict protected
    procedure DoMove(MoveCount: Integer); override;
  end;

  TEnemyOrItem = class(TImageSprite)
  strict private
    FLives: integer;
    FEnemyType: TEnemyType;
    FXCor: integer;
    FCorInit: boolean;
  strict protected
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite; AEnemyType: TEnemyType; ALives: Integer); reintroduce;
  end;

{ TBackground }

procedure TBackground.DoMove(MoveCount: Integer);
begin
  X := -(MainForm.ScrollP * LevEditRasterW);
end;

{ TEnemy }

procedure TEnemyOrItem.DoMove(MoveCount: Integer);
begin
  if not FCorInit then
  begin
    FXCor := trunc(x) + (MainForm.ScrollP * LevEditRasterW);
    FCorInit := true;
  end;
  if MainForm.LevData.IndexOfEnemy(FXCor, integer(round(Y)), FEnemyType, FLives) = -1 then dead;
  X := FXCor - (MainForm.ScrollP * LevEditRasterW);
end;

constructor TEnemyOrItem.Create(AParent: TSprite; AEnemyType: TEnemyType; ALives: Integer);
begin
  inherited Create(AParent);
  if AEnemyType = etEnemyAttacker  then Image := MainForm.GetSpriteGraphic(smgEnemyAttacker);
  if AEnemyType = etEnemyAttacker2 then Image := MainForm.GetSpriteGraphic(smgEnemyAttacker2);
  if AEnemyType = etEnemyAttacker3 then Image := MainForm.GetSpriteGraphic(smgEnemyAttacker3);
  if AEnemyType = etEnemyMeteor    then Image := MainForm.GetSpriteGraphic(smgEnemyMeteor);
  if AEnemyType = etEnemyUFO       then Image := MainForm.GetSpriteGraphic(smgEnemyDisk);
  if AEnemyType = etEnemyUFO2      then Image := MainForm.GetSpriteGraphic(smgEnemyDisk2);
  if AEnemyType = etEnemyBoss      then Image := MainForm.GetSpriteGraphic(smgEnemyBoss);
  if AEnemyType = etItemMedikit    then Image := MainForm.GetSpriteGraphic(smgItemMedikit);

  if not EnemyTypeHasLives(AEnemyType) then
    FLives := 0
  else
    FLives := ALives;
  FEnemyType := AEnemyType;
  Width := Image.Width;
  Height := Image.Height;
  PixelCheck := True;
end;

{ TMainForm }

procedure TMainForm.DXInit;
begin
  Imagelist.Items.LoadFromFile(OwnDirectory+DxgFile);
  ImageList.Items.MakeColorTable;
  DXDraw.ColorTable := ImageList.Items.ColorTable;
  DXDraw.DefColorTable := ImageList.Items.ColorTable;
  DXDraw.UpdatePalette;
  DXDraw.Initialize;
end;

procedure TMainForm.FormCreate(Sender: TObject);
resourcestring
  SFileError = 'Die Datei kann von SpaceMission nicht ge�ffnet werden!';
  SCaption = 'SpaceMission %s - Level-Editor';
begin
  { VCL-Ersatz start }
  dxtimer := tdxtimer.create(self);
  dxtimer.Interval := 100;
  dxtimer.ActiveOnly := false;
  dxtimer.Enabled := false;
  dxtimer.OnTimer := DxTimerTimer;

  dxdraw := tdxdraw.Create(self);
  dxdraw.Parent := self;
  dxdraw.Left := 0;
  dxdraw.Top := 0;
  dxdraw.Width := SidePanel.Left;
  dxdraw.Height := ScrollBar.Top;
  dxdraw.AutoInitialize := False;
  dxdraw.AutoSize := False;
  dxdraw.Color := clBlack;
  (*
  dxdraw.Display.BitCount := 24;
  dxdraw.Display.FixedBitCount := False;
  dxdraw.Display.FixedRatio := False;
  dxdraw.Display.FixedSize := False;
  dxdraw.Display.Height := 600;
  dxdraw.Display.Width := 800;
  *)
  dxdraw.Options := [doAllowReboot, doWaitVBlank, doAllowPalette256, doCenter, {doRetainedMode,} doHardware, doSelectDriver];
  dxdraw.OnFinalize := DXDrawFinalize;
  dxdraw.OnInitialize := DXDrawInitialize;
  dxdraw.ParentShowHint := False;
  dxdraw.ShowHint := False;
  dxdraw.TabOrder := 0;
  dxdraw.OnMouseDown := DXDrawMouseDown;
  dxdraw.OnMouseMove := DXDrawMouseMove;

  spriteengine := tdxspriteengine.create(self);
  spriteengine.DXDraw := dxdraw;

  imagelist := tdximagelist.create(self);
  imagelist.DXDraw := dxdraw;

  { VCL-Ersatz ende }

  StatusBar.SimpleText := ' ' + status_info;

  LivesEdit.MinValue := 1;
  LivesEdit.MaxValue := MaxPossibleEnemyLives;
  LivesEdit.Value := 1;

  Enemy1.Checked := true;
  EnemyClick(Enemy1);
  // Leeres Level am Anfang braucht keine Beenden-Best�tigung.
  // LevChanged := true;

  //Application.Title := Format(SCaption, [ProgramVersion]);
  Caption := Format(SCaption, [ProgramVersion]);
  DXInit;
  LevData := TLevelData.create;
  ProgramInit;
  DestroyLevel;
  if (paramcount > 0) and (fileexists(paramstr(1))) and (ExtractFileExt(paramstr(1)).ToLower = '.lev') then
  begin
    try
      LevData.RasterErzwingen := true;
      LevData.LoadFromFile(paramstr(1));
    except
      on E: Exception do
      begin
        showmessage(SFileError + ' ' +E.Message);
        DestroyLevel;
      end;
    end;
    RefreshFromLevData;
    LevChanged := false;
    AnzeigeAct;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  tmp: string;
begin
  FreeAndNil(dxdraw);
  FreeAndNil(LevData);
  //FreeAndNil(spriteengine);
  FreeAndNil(dxtimer);
  FreeAndNil(imagelist);
  tmp := GetTestlevelFilename;

  // SpaceMission.exe only loads a file once, so we can delete any test level
  if FileExists(tmp) then DeleteFile(GetTestlevelFilename);
end;

procedure TMainForm.BeendenClick(Sender: TObject);
begin
  close;
end;

procedure TMainForm.DXDrawInitialize(Sender: TObject);
begin
  if Assigned(DXTimer) then DXTimer.Enabled := True;
end;

procedure TMainForm.DXDrawFinalize(Sender: TObject);
begin
  if Assigned(DXTimer) then DXTimer.Enabled := False;
end;

procedure TMainForm.DXTimerTimer(Sender: TObject; LagCount: Integer);
begin
  if not DXDraw.CanDraw then exit;
  LagCount := 1000 div 60;
  SpriteEngine.Move(LagCount);
  SpriteEngine.Dead;
  DxDraw.Surface.Fill(0);
  SpriteEngine.Draw;
  DXDraw.Flip;
end;

function TMainForm.ComposeColor(Dest, Src: TRGBQuad; Percent: Integer): TRGBQuad;
begin
  with Result do
  begin
    rgbRed := Src.rgbRed+((Dest.rgbRed-Src.rgbRed)*Percent div 256);
    rgbGreen := Src.rgbGreen+((Dest.rgbGreen-Src.rgbGreen)*Percent div 256);
    rgbBlue := Src.rgbBlue+((Dest.rgbBlue-Src.rgbBlue)*Percent div 256);
    rgbReserved := 0;
  end;
end;

procedure TMainForm.PalleteAnim(Col: TRGBQuad; Time: Integer);
var
  i: Integer;
  t, t2: DWORD;
  ChangePalette: Boolean;
  c: Integer;
begin
  if DXDraw.Initialized then
  begin
    c := DXDraw.Surface.ColorMatch(RGB(Col.rgbRed, Col.rgbGreen, Col.rgbBlue));
    ChangePalette := False;
    if DXDraw.CanPaletteAnimation then
    begin
      t := GetTickCount;
      while Abs(GetTickCount-t)<Time do
      begin
        t2 := Trunc(Abs(GetTickCount-t)/Time*255);
        for i := 0 to 255 do
          DXDraw.ColorTable[i] := ComposeColor(Col, DXDraw.DefColorTable[i], t2);
        DXDraw.UpdatePalette;
        ChangePalette := True;
      end;
    end else
      Sleep(Time);
    for i := 0 to 4 do
    begin
      DXDraw.Surface.Fill(c);
      DXDraw.Flip;
    end;
    if ChangePalette then
    begin
      DXDraw.ColorTable := DXDraw.DefColorTable;
      DXDraw.UpdatePalette;
    end;
    DXDraw.Surface.Fill(c);
    DXDraw.Flip;
  end;
end;

procedure TMainForm.ProgramInit;
{var
  i, j: Integer;}
begin
  sleep(500);
  //PlayerSprite
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := MainForm.GetSpriteGraphic(smgStar3);
    Z := -13;
    Y := 40;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := MainForm.GetSpriteGraphic(smgStar2);
    Z := -12;
    Y := 30;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := MainForm.GetSpriteGraphic(smgStar1);
    Z := -11;
    Y := 10;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := MainForm.GetSpriteGraphic(smgMatrix);
    Z := -10;
    Tile := True;
  end;
  {with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(200, 10);
    Y := 10;
    Z := -13;
    FSpeed := 1 / 2;
    Tile := True;
    for i := 0 to MapHeight-1 do
    begin
      for j := 0 to MapWidth-1 do
      begin
        Chips[j, i] := Image.PatternCount-Random(Image.PatternCount div 8);
        if Random(100)<95 then Chips[j, i] := -1;
      end;
    end;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(200, 10);
    Y := 30;
    Z := -12;
    FSpeed := 1;
    Tile := True;
    for i := 0 to MapHeight-1 do
    begin
      for j := 0 to MapWidth-1 do
      begin
        Chips[j, i] := Image.PatternCount-Random(Image.PatternCount div 4);
        if Random(100)<95 then Chips[j, i] := -1;
      end;
    end;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(200, 10);
    Y := 40;
    Z := -11;
    FSpeed := 2;
    Tile := True;
    for i := 0 to MapHeight-1 do
    begin
      for j := 0 to MapWidth-1 do
      begin
        Chips[j, i] := Image.PatternCount-Random(Image.PatternCount div 2);
        if Random(100)<95 then Chips[j, i] := -1;
      end;
    end;
  end;}
  PalleteAnim(RGBQuad(0, 0, 0), 300);
  mainform.Visible := true;
end;

procedure TMainForm.RefreshFromLevData;
var
  i: integer;
begin
  MainForm.ScrollBar.Max := MainForm.LevData.LevelEditorLength;
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
  AnzeigeAct;
end;

procedure TMainForm.LevelClick(Sender: TObject);
begin
  speicherungform.showmodal;
end;

procedure TMainForm.Leveltesten1Click(Sender: TObject);
var
  sav: TSaveData;
  tmp: string;
begin
  KillTask(SpaceMissionExe);

  sav := TSaveData.Create;
  try
    sav.Score := 0;
    sav.Life := 6;
    if Assigned(SpeicherungForm) then
      sav.Level := SpeicherungForm.LevelNumber.Value
    else
      sav.Level := 1;
    sav.GameMode := gmLevels;
    sav.LevelData := TlevelData.Create;
    sav.LevelData.Assign(LevData);
    tmp := GetTestlevelFilename;
    sav.SaveToFile(tmp);
    ShellExecute(Handle, 'open', PChar(OwnDirectory+SpaceMissionExe), PChar('"'+tmp+'"'), PChar(OwnDirectory), SW_NORMAL); // do not localize
  finally
    FreeAndNil(sav);
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if Assigned(SplashForm) then
  begin
    SplashForm.Hide;
    FreeAndNil(SplashForm);
  end;

  dxtimer.Enabled := true;
  dxtimer.ActiveOnly := true;
end;

function TMainForm.GetSpriteGraphic(
  Sprite: TSpaceMissionGraphicSprite): TPictureCollectionItem;
begin
  if (Sprite<>smgNone) and (imagelist.Items.Count >= Ord(Sprite)) then
    result := imagelist.Items.Items[Ord(Sprite)-1]
  else
    result := nil;
end;

function TMainForm.GetTestlevelFilename: string;
begin
  result := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'SpaceMissionTest.sav'; // do not localize
end;

procedure TMainForm.HilfeTopicClick(Sender: TObject);
// Please keep this code in-sync with GamMain.pas
var
  bakTimerEnabled: boolean;
begin
  bakTimerEnabled := dxtimer.Enabled;
  try
    dxtimer.Enabled := false;
    HilfeForm.Caption := TMenuItem(Sender).Caption;
    HilfeForm.Caption := StringReplace(HilfeForm.Caption, '&&', #1, [rfReplaceAll]);
    HilfeForm.Caption := StringReplace(HilfeForm.Caption, '&', '', [rfReplaceAll]);
    HilfeForm.Caption := StringReplace(HilfeForm.Caption, #1, '&', [rfReplaceAll]);
    HilfeForm.ShowMarkDownHelp(OwnDirectory+TMenuItem(Sender).Hint);
    HilfeForm.ShowModal;
  finally
    dxtimer.Enabled := bakTimerEnabled;
  end;
end;

procedure TMainForm.InformationenClick(Sender: TObject);
begin
  mainform.dxtimer.enabled := false;
  InfoForm.showmodal;
  mainform.dxtimer.enabled := true;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SpriteEngine.Engine.Clear;
  DXTimer.Enabled := False;
end;

procedure TMainForm.DXDrawMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: TEnemyType;
  j, k, l, ex, ey: integer;
  ok, breaked: boolean;
begin
  ex := trunc(x/LevEditRasterW) * LevEditRasterW;
  ey := trunc(y/LevEditRasterH) * LevEditRasterH;
  EnemyCreateSprite(ex, ey, SelectedEnemyType, LivesEdit.Value);
  breaked := false;
  { Setzen }
  if Button = mbLeft then
  begin
    ok := true;
    if (SelectedEnemyType = etEnemyBoss) and boss then
      ok := false // boss already exists
    else
    begin
      for i := Low(TEnemyType) to High(TEnemyType) do
      begin
        for j := 0 to MaxPossibleEnemyLives do
        begin
          if boss then
          begin
            for k := 0 to BossWidth-1 do
            begin
              for l := 0 to BossHeight-2 do
              begin
                if LevData.IndexOfEnemy(ex + ((ScrollP - k) * LevEditRasterW), ey - (LevEditRasterH * l), etEnemyBoss, j) <> -1 then
                begin
                  ok := false;
                  break;
                end;
              end;
              if not ok then break;
            end;
            if not ok then break;
          end;
          if LevData.IndexOfEnemy(ex + (ScrollP * LevEditRasterW), ey, i, j) <> -1 then
          begin
            ok := false;
            break;
          end;
        end;
        if not ok then break;
      end;
    end;
    if ok then
    begin
      if EnemyTypeHasLives(SelectedEnemyType) then
        LevData.AddEnemy(ex + (ScrollP * LevEditRasterW), ey, SelectedEnemyType, LivesEdit.Value)
      else
        LevData.AddEnemy(ex + (ScrollP * LevEditRasterW), ey, SelectedEnemyType, 0);
      inc(NumEnemys);
      if SelectedEnemyType = etEnemyBoss then boss := true;
    end
    else beep;
  end
  { L�schen }
  else if Button = mbRight then
  begin
    for i := Low(TEnemyType) to High(TEnemyType) do
    begin
      for j := 0 to MaxPossibleEnemyLives do
      begin
        if boss and (i = etEnemyBoss) then
        begin
          for k := 0 to BossWidth - 1 do
          begin
            for l := 0 to BossHeight - 1 do
            begin
              if LevData.IndexOfEnemy(ex + ((ScrollP - k) * LevEditRasterW), ey - (LevEditRasterH * l), i, j) <> -1 then
              begin
                LevData.DeleteEnemy(ex + ((ScrollP - k) * LevEditRasterW), ey - (LevEditRasterH * l), i, j);
                Boss := false;
                dec(NumEnemys);
                breaked := true;
                break;
              end;
            end;
            if breaked then break;
          end;
        end;
        if LevData.IndexOfEnemy(ex + (ScrollP * LevEditRasterW), ey, i, j) <> -1 then
        begin
          LevData.DeleteEnemy(ex + (ScrollP * LevEditRasterW), ey, i, j);
          if i = etEnemyBoss then Boss := false;
          dec(NumEnemys);
          breaked := true;
          break;
        end;
      end;
      if breaked then break;
    end;
  end;
  LevChanged := true;
  AnzeigeAct;
end;

procedure TMainForm.EnemyClick(Sender: TObject);
var
  et: TEnemyType;
begin
  et := SelectedEnemyType;
  Image1.Left := -(87 * (Ord(et) - 1)) + 1;
  LivesEdit.Enabled := EnemyTypeHasLives(et);
  LivesLabel.Enabled := EnemyTypeHasLives(et);
end;

procedure TMainForm.EnemyCreateSprite(x, y: integer; AEnemyType: TEnemyType; ALives: integer);
var
  Enemy: TSprite;
begin
  Enemy := TEnemyOrItem.Create(SpriteEngine.Engine, AEnemyType, ALives);
  Enemy.x := x;
  Enemy.y := y;
end;

procedure TMainForm.DestroyLevel;
begin
  ScrollBar.Position := 0; // this doesn't call ScrollBarScroll()
  ScrollP := 0;
  LevData.Clear;
  ScrollBar.Max := LevData.LevelEditorLength;
  NumEnemys := 0;
  Boss := false;
  LevChanged := true;
  LivesEdit.Value := 1;
  Enemy1.Checked := true;
  EnemyClick(Enemy1);
  AnzeigeAct;
end;

procedure TMainForm.AlleLeveldateienaktualisieren1Click(Sender: TObject);
var
  i: integer;
begin
  // Just for internal/development purposes
  for i := 1 to MaxPossibleLevels do
  begin
    if FileExists('Levels\Level '+IntToStr(i)+'.lev') then
    begin
      LevData.RasterErzwingen := true;
      LevData.LoadFromFile('Levels\Level '+IntToStr(i)+'.lev');
      LevData.SaveToFile('Levels\Level '+IntToStr(i)+'.lev');
    end;
  end;
end;

procedure TMainForm.AnzeigeAct;
resourcestring
  SYes = 'Ja';
  SNo = 'Nein';
begin
  SLabel1b.Caption := inttostr(NumEnemys);
  if Boss then SLabel2b.Caption := SYes else SLabel2b.Caption := SNo;
  SLabel3b.Caption := inttostr(ScrollBar.Max);
  if LevChanged then
  begin
    SLabel4a.Font.Color := $00000096;
    SLabel4b.Font.Color := $00000096;
    SLabel4b.Caption := SNo;
  end
  else
  begin
    SLabel4a.Font.Color := $00009600;
    SLabel4b.Font.Color := $00009600;
    SLabel4b.Caption := SYes;
  end;
end;

procedure TMainForm.AufUpdatesprfen1Click(Sender: TObject);
begin
  CheckForUpdates('spacemission', ProgramVersion); // do not localize
end;

procedure TMainForm.NeuClick(Sender: TObject);
resourcestring
  SReallyDeleteLevel = 'Level wirklich l�schen?';
begin
  if MessageDlg(SReallyDeleteLevel, mtConfirmation, mbYesNoCancel, 0) = mrYes then
    DestroyLevel;
end;

procedure TMainForm.DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
resourcestring
  status_lives = 'Leben: ';
  status_nolives = 'Einheit hat keine Lebensangabe';
  SUnknownEnemyType = '???';
var
  i: TEnemyType;
  ex, ey, j, k, l: integer;
  lifes: integer;
  enemyType: TEnemyType;
  enemyName: string;
  breaked: boolean;
begin
  if sender <> DxDraw then
  begin
    StatusBar.SimpleText := ' ' + status_info;
    exit;
  end;
  ex := trunc(x/LevEditRasterW) * LevEditRasterW;
  ey := trunc(y/LevEditRasterH) * LevEditRasterH;
  lifes := -1;
  enemyType := etUnknown;
  breaked := false;
  for i := Low(TEnemyType) to High(TEnemyType) do
  begin
    for j := 0 to MaxPossibleEnemyLives do
    begin
      if boss and (i = etEnemyBoss) then
      begin
        for k := 0 to BossWidth - 1 do
        begin
          for l := 0 to BossHeight - 1 do
          begin
            if LevData.IndexOfEnemy(ex + ((ScrollP - k) * LevEditRasterW), ey - (LevEditRasterH * l), i, j) <> -1 then
            begin
              lifes := j;
              breaked := true;
              break;
            end;
          end;
          if breaked then break;
        end;
      end;
      if (breaked = false) and (LevData.IndexOfEnemy(ex + (ScrollP * LevEditRasterW), ey, i, j) <> -1) then
      begin
        lifes := j;
        enemyType := i;
        breaked := true;
        break;
      end;
    end;
    if breaked then break;
  end;
  if lifes <> -1 then
  begin
    if Ord(enemyType) = 1 then enemyName := Enemy1.Caption
    else if Ord(enemyType) = 2 then enemyName := Enemy2.Caption
    else if Ord(enemyType) = 3 then enemyName := Enemy3.Caption
    else if Ord(enemyType) = 4 then enemyName := Enemy4.Caption
    else if Ord(enemyType) = 5 then enemyName := Enemy5.Caption
    else if Ord(enemyType) = 6 then enemyName := Enemy6.Caption
    else if Ord(enemyType) = 7 then enemyName := Enemy7.Caption
    else if Ord(enemyType) = 8 then enemyName := Enemy8.Caption
    else enemyName := SUnknownEnemyType;
    if lifes > 0 then
      StatusBar.SimpleText := ' ' + enemyName + ' - ' + status_lives + inttostr(lifes)
    else
      StatusBar.SimpleText := ' ' + enemyName + ' - ' + status_nolives;
  end
  else
    StatusBar.SimpleText := ' ' + status_info;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
resourcestring
  SExitWithoutSave = 'Beenden ohne abspeichern?';
begin
  if Assigned(LevData) and LevChanged and (LevData.CountEnemies>0) then
    CanClose := MessageDlg(SExitWithoutSave, mtConfirmation, mbYesNoCancel, 0) = mrYes;
end;

procedure TMainForm.Spielfelderweitern1Click(Sender: TObject);
begin
  LevelForm.Aktualisieren;
  LevelForm.showmodal;
end;

procedure TMainForm.ScrollBarScroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  ScrollP := ScrollPos;
end;

function TMainForm.SelectedEnemyType: TEnemyType;
begin
  if Enemy1.Checked then result := etEnemyAttacker
  else if Enemy2.Checked then result := etEnemyAttacker2
  else if Enemy3.Checked then result := etEnemyAttacker3
  else if Enemy4.Checked then result := etEnemyMeteor
  else if Enemy5.Checked then result := etEnemyUFO
  else if Enemy6.Checked then result := etEnemyUFO2
  else if Enemy7.Checked then result := etEnemyBoss
  else if Enemy8.Checked then result := etItemMedikit
  else result := etUnknown;
end;

end.

