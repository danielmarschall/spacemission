unit GamMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, DIB, DXClass, DXSprite, DXDraws, DXInput, DXSounds,
  ShellAPI, DirectX{$IF CompilerVersion >= 23.0},
  System.UITypes{$IFEND}, ComLevelReader, DirectMusic, Global;

type
  TGameScene = (
    gsNone,
    gsTitle,
    gsMain,
    gsGameOver,
    gsNewLevel,
    gsWin
  );

  TGameInterval = (
    giLeicht,
    giMittel,
    giSchwer,
    giMaster
  );

  TBackground = class(TBackgroundSprite)
  strict private
    FSpeed: Double;
  strict protected
    procedure DoMove(MoveCount: Integer); override;
  public
    property Speed: Double read FSpeed write FSpeed;
  end;

  TBackgroundSpecial = class(TBackgroundSprite)
  strict private
    FSpeed: Double;
  strict protected
    procedure DoMove(MoveCount: Integer); override;
  public
    property Speed: Double read FSpeed write FSpeed;
  end;

  TExplosion = class(TImageSprite)
  strict private
    FCounter: Integer;
  strict protected
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TPlayerOrEnemyOrItemState = (
    pesUnknown,
    pesNormal,
    pesExploding, // only boss, as preparation of pesDead
    pesDead,
    pesDeadVanished,
    pesFlyaway, // only player at mission end
    pesEntering,
    pesHovering // only some kind of enemies
  );

  TPlayerOrEnemyOrItem = class abstract (TImageSprite)
  strict protected
    FState: TPlayerOrEnemyOrItemState;
  public
    property State: TPlayerOrEnemyOrItemState read FState;
  end;

  TPlayerSprite = class(TPlayerOrEnemyOrItem)
  private
    FTamaCount: Integer; // accessed by TPlayerTamaSprite.Destroy
  strict private
    FCounter: Integer;
    FOldTamaTime: Integer;
  strict protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
    procedure FlyAway;
  end;

  TPlayerTamaSprite = class(TImageSprite)
  strict private
    FPlayerSprite: TPlayerSprite;
  strict protected
    property PlayerSprite: TPlayerSprite read FPlayerSprite write FPlayerSprite;
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite; APlayerSprite: TPlayerSprite); reintroduce;
    destructor Destroy; override;
  end;

  TEnemyClass = class of TEnemy;
  TEnemy = class abstract (TPlayerOrEnemyOrItem)
  strict protected
    FCounter: Integer;
    FLife: integer;
    procedure HitEnemy(ADead: Boolean); virtual;
  public
    property Life: integer read FLife;
    procedure Hit(AHitStrength: integer = 1);
    constructor Create(AParent: TSprite; ALifes: integer); reintroduce; virtual;
    destructor Destroy; override;
  end;

  TEnemyTama = class(TImageSprite)
  strict private
    FEnemySprite: TSprite;
  strict protected
    property EnemySprite: TSprite read FEnemySprite write FEnemySprite;
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite; AEnemySprite: TSprite); reintroduce;
  end;

  TEnemyMeteor = class(TEnemy)
  strict protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyUFO = class(TEnemy)
  strict protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyUFO2 = class(TEnemy)
  strict private
    FCounter: Integer;
    FTamaCount: Integer;
    FOldTamaTime: Integer;
  strict protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyAttacker = class(TEnemy)
  strict protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyAttacker2 = class(TEnemy)
  strict private
    FCounter: Integer;
    FTamaF: Integer;
    FTamaT: Integer;
    FPutTama: Boolean;
  strict protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyAttacker3 = class(TEnemy)
  strict private
    FCounter: Integer;
    FTamaCount: Integer;
    FOldTamaTime: Integer;
  strict protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyBoss = class(TEnemy)
  strict private
    FCounter: Integer;
    FTamaF: Integer;
    FTamaT: Integer;
    FPutTama: Boolean;
    waiter1, waiter2: integer;
  strict protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
    destructor Destroy; override;
  end;

  TItemClass = class of TItem;
  TItem = class abstract (TPlayerOrEnemyOrItem)
  strict protected
    procedure DoMove(MoveCount: Integer); override;
  public
    procedure Collected; virtual;
  end;

  TItemMedikit = class(TItem)
  public
    procedure Collected; override;
    constructor Create(AParent: TSprite); override;
  end;

  TMainForm = class(TDXForm)
    MainMenu: TMainMenu;
    Spiel: TMenuItem;
    GameStart: TMenuItem;
    GamePause: TMenuItem;
    Beenden: TMenuItem;
    Einstellungen: TMenuItem;
    OptionMusic: TMenuItem;
    Hilfe: TMenuItem;
    OptionSound: TMenuItem;
    Leer3: TMenuItem;
    Spielstand: TMenuItem;
    Leer5: TMenuItem;
    Neustart: TMenuItem;
    Spielgeschwindigkeit: TMenuItem;
    Leicht: TMenuItem;
    Mittel: TMenuItem;
    Schwer: TMenuItem;
    Informationen: TMenuItem;
    Leer6: TMenuItem;
    Leer1: TMenuItem;
    Cheat: TMenuItem;
    CheckUpdates: TMenuItem;
    Master: TMenuItem;
    Hilfe1: TMenuItem;
    N1: TMenuItem;
    Wasgibtesneues1: TMenuItem;
    procedure DXDrawFinalize(Sender: TObject);
    procedure DXDrawInitialize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DXTimerTimer(Sender: TObject; LagCount: Integer);
    procedure DXTimerActivate(Sender: TObject);
    procedure DXTimerDeactivate(Sender: TObject);
    procedure DXDrawInitializing(Sender: TObject);
    procedure GameStartClick(Sender: TObject);
    procedure GamePauseClick(Sender: TObject);
    procedure BeendenClick(Sender: TObject);
    procedure OptionSoundClick(Sender: TObject);
    procedure OptionMusicClick(Sender: TObject);
    procedure SpielstandClick(Sender: TObject);
    procedure NeustartClick(Sender: TObject);
    procedure LeichtClick(Sender: TObject);
    procedure MittelClick(Sender: TObject);
    procedure SchwerClick(Sender: TObject);
    procedure MasterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InformationenClick(Sender: TObject);
    procedure CheatClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure CheckUpdatesClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HilfeTopicClick(Sender: TObject);
  private
    ProgrammGestartet: boolean;
    FSpeed: integer;
    FScene: TGameScene;
    FMusic: TSpaceMissionMusicTrack;
    FBlink: DWORD;
    FBlinkTime: DWORD;
    FFrame, FAngle, FCounter, FEnemyAdventPos: Integer;
    PlayerSprite: TPlayerSprite;
    TimerCS: TRTLCriticalSection;
    procedure StartScene(Scene: TGameScene);
    procedure EndScene;
    procedure BlinkStart;
    procedure BlinkUpdate;
    procedure StartSceneTitle;
    procedure SceneTitle;
    procedure EndSceneTitle;
    procedure StartSceneMain;
    procedure SceneMain;
    procedure EndSceneMain;
    procedure StartSceneGameOver;
    procedure SceneGameOver;
    procedure EndSceneGameOver;
    procedure StartSceneWin;
    procedure SceneWin;
    procedure EndSceneWin;
    procedure StartSceneNewLevel;
    procedure SceneNewLevel;
    procedure EndSceneNewLevel;
    procedure LevelNeuStarten;
  private
    { Diverse temporäre Variablen }
    Crash2: integer;
    EnemyCounter: integer;
    Crash: boolean;
    crashsound: boolean;
  public
    FNextScene: TGameScene;
    FScore: Integer;
    FBoss: TEnemyBoss;
    FNotSave: boolean;
    FLife: integer;
    FLevel: integer;
    FGameMode: TGameMode;
    FLifeAtLevelStart: integer;
    FScoreAtLevelStart: integer;
    FLevelDataAlreadyLoaded: boolean;
    FRestEnemies: integer;
    FCheats: TCheatSet;
    { VCL-Ersatz }
    dxdraw: TDxDraw;
    imagelist: TDxImageList;
    spriteengine: tdxspriteengine;
    dxsound: tdxsound;
    dxmusic: tdxmusic;
    wavelist: tdxwavelist;
    dxinput: tdxinput;
    dxtimer: tdxtimer;
    { Level-Routinen }
    LevelData: TLevelData;
    procedure NewLevel(lev: integer);
    procedure ResetLevelData;
    { Musik-Routinen }
    procedure MusicSwitchTrack(Name: TSpaceMissionMusicTrack);
    procedure PlayMusic(Name: TSpaceMissionMusicTrack);
    procedure StopMusic(Name: TSpaceMissionMusicTrack);
    procedure ResumeMusic(Name: TSpaceMissionMusicTrack);
    procedure PauseMusic(Name: TSpaceMissionMusicTrack);
    { Sound-Routinen }
    procedure PlaySound(Sound: TSpaceMissionSound; Wait: Boolean);
    { Grafik-Routinen }
    function GetSpriteGraphic(Sprite: TSpaceMissionGraphicSprite): TPictureCollectionItem;
    { Initialisiations-Routinen }
    procedure DXInit;
    procedure SoundInit;
    procedure MusicInit;
    { Einstellungs-Routinen }
    procedure LoadOptions;
    procedure WriteOptions;
    { Farb-Routinen }
    function ComposeColor(Dest, Src: TRGBQuad; Percent: Integer): TRGBQuad;
    procedure PalleteAnim(Col: TRGBQuad; Time: Integer);
  end;

var
  MainForm: TMainForm;

implementation

uses
  GamSplash, GamSpeicherung, ComInfo, GamCheat, MMSystem, Registry,
  ComHilfe;

{$R *.DFM}

const
  DXInputButton = [isButton1, isButton2, isButton3,
    isButton4, isButton5, isButton6, isButton7, isButton8, isButton9, isButton10, isButton11,
    isButton12, isButton13, isButton14, isButton15, isButton16, isButton17, isButton18,
    isButton19, isButton20, isButton21, isButton22, isButton23, isButton24, isButton25,
    isButton26, isButton27, isButton28, isButton29, isButton30, isButton31, isButton32];

resourcestring
  SWeiterMitLeertaste = 'Weiter mit Leertaste';

{ TBackground }

procedure TBackground.DoMove(MoveCount: Integer);
var
  ran: integer;
  bgs: TBackgroundSpecial;
begin
  inherited DoMove(MoveCount);
  X := X - MoveCount*(60/1000)*FSpeed;
  ran := Random(1500);
  if ran = 150 then
  begin
    bgs := TBackgroundSpecial.Create(mainform.SpriteEngine.Engine);
    bgs.SetMapSize(1, 1);
    bgs.Image := MainForm.GetSpriteGraphic(smgBackgroundPlanet1);
    bgs.Width := Image.Width;
    bgs.Height := Image.Height;
    bgs.Y := random(mainform.dxdraw.height);
    bgs.X := mainform.dxdraw.width;
    ran := Random(2);
    if ran = 0 then
    begin
      bgs.Z := -20;
      bgs.Speed := 1.8;
    end
    else if ran = 1 then
    begin
      bgs.Z := -40;
      bgs.Speed := 0.8;
    end
    else if ran = 2 then
    begin
      bgs.Z := -60;
      bgs.Speed := 0.3;
    end;
  end
  else if ran = 500 then
  begin
    bgs := TBackgroundSpecial.Create(mainform.SpriteEngine.Engine);
    bgs.SetMapSize(1, 1);
    ran := Random(4);
    if ran = 0 then
      bgs.Image := MainForm.GetSpriteGraphic(smgBackgroundRed)
    else if ran = 1 then
      bgs.Image := MainForm.GetSpriteGraphic(smgBackgroundBlue)
    else if ran = 2 then
      bgs.Image := MainForm.GetSpriteGraphic(smgBackgroundYellow)
    else if ran = 3 then
      bgs.Image := MainForm.GetSpriteGraphic(smgHintergrundRot);
    bgs.Width := Image.Width;
    bgs.Height := Image.Height;

    bgs.Y := random(mainform.dxdraw.height);
    bgs.X := mainform.dxdraw.width;

    { ran := Random(2);
    if ran = 0 then
    begin
      bgs.Z := -20;
      bgs.Speed := 1.8;
    end
    else if ran = 1 then
    begin
      bgs.Z := -40;
      bgs.Speed := 0.8;
    end
    else if ran = 2 then
    begin }
      bgs.Z := -60;
      bgs.Speed := 0.3;
    { end; }
  end;
end;

{ TBackgroundSpecial }

procedure TBackgroundSpecial.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  X := X - MoveCount*(60/1000)*FSpeed;
  if X < -Width then Dead;
end;

{ TExplosion }

constructor TExplosion.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  mainform.PlaySound(smsExplosion, false);
  Image := MainForm.GetSpriteGraphic(smgExplosion);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  AnimPos := Random(AnimCount);
end;

procedure TExplosion.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  inc(FCounter, MoveCount);
  if FCounter > 2999 then dead;
end;

{ TPlayerSprite }

constructor TPlayerSprite.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  FState := pesEntering;
  Image := MainForm.GetSpriteGraphic(smgMachine);
  Width := Image.Width;
  Height := Image.Height;
  X := -70{20};
  Y := mainform.dxdraw.surfaceHeight / 2 - (height / 2);
  Z := 2;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
end;

procedure TPlayerSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if (Sprite is TItem) then
  begin
    TItem(Sprite).Collected;
  end
  else if ((Sprite is TEnemy) or (Sprite is TEnemyTama)) and not (ctInfiniteLives in mainform.FCheats) then
  begin
    if not mainform.crash then
    begin
      dec(MainForm.FLife);
      mainform.Crash := true;
      if MainForm.Flife=0 then
      begin
        MainForm.PlaySound(smsExplosion, false);
        Collisioned := false;
        FCounter := 0;
        FState := pesDead;
        Done := false;
        Image := MainForm.GetSpriteGraphic(smgExplosion);
        Width := Image.Width;
        Height := Image.Height;
        AnimCount := Image.PatternCount;
        AnimLooped := False;
        AnimSpeed := DEFAULT_ANIMSPEED;
        AnimPos := 0;
      end;
    end
    else
    begin
      if not mainform.crashsound then
      begin
        MainForm.PlaySound(smsHit, False);
        mainform.crashsound := true;
      end;
    end;
  end;
end;

procedure TPlayerSprite.DoMove(MoveCount: Integer);
const
  WegduesKonstante = 1.75;
begin
  inherited DoMove(MoveCount);
  if State = pesNormal then
  begin
    if isUp in MainForm.DXInput.States then Y := Y - (250/1000)*MoveCount;
    if isDown in MainForm.DXInput.States then Y := Y + (250/1000)*MoveCount;
    if isLeft in MainForm.DXInput.States then X := X - (250/1000)*MoveCount;
    if isRight in MainForm.DXInput.States then X := X + (250/1000)*MoveCount;
    if X<0 then X := 0;
    if X>mainform.dxdraw.surfacewidth-Width then X := mainform.dxdraw.surfacewidth-Width;
    if Y<0 then Y := 0;
    if Y>mainform.dxdraw.surfaceheight-Height then Y := mainform.dxdraw.surfaceheight-Height;
    if isButton1 in MainForm.DXInput.States then
    begin
      if (FTamaCount<8) and (FCounter-FOldTamaTime>=100) then
      begin
        Inc(FTamaCount);
        with TPlayerTamaSprite.Create(Engine, Self) do
        begin
          X := Self.X+Self.Width;
          Y := Self.Y+Self.Height div 2-Height div 2;
          Z := 10;
        end;
        FOldTamaTime := FCounter;
      end;
    end;
    Collision;
  end
  else if State = pesDead then
  begin
    if FCounter>200 then
    begin
      FCounter := 0;
      FState := pesDeadVanished;
      Visible := false; // Cannot use "Dead;" because we need to still be able to handle pesDeadVanished
    end;
  end
  else if State = pesDeadVanished then
  begin
    if FCounter>2000 then
    begin
      MainForm.LevelNeuStarten;
      (*
      MainForm.FNextScene := gsGameOver;
      MainForm.PlaySound(smsSceneMov, false);
      MainForm.PalleteAnim(RGBQuad(0, 0, 0), 300);
      Sleep(200);
      *)
    end;
  end
  else if State = pesFlyaway then
  begin
    X := X + MoveCount*(300/1000) * (X/MainForm.DXDraw.Width + WegduesKonstante);
    if X > MainForm.DXDraw.Width+Width then
    begin
      Dead;
      inc(mainform.FLevel);
      MainForm.FLevelDataAlreadyLoaded := false; // allow NewLevel() to work again
      MainForm.FNextScene := gsNewLevel;
      MainForm.PlaySound(smsSceneMov, false);
      MainForm.PalleteAnim(RGBQuad(0, 0, 0), 300);
    end;
  end
  else if State = pesEntering then
  begin
    X := X + MoveCount*(300/1000);
    if X > 19 then FState := pesNormal;
  end;
  inc(FCounter, MoveCount);
end;

procedure TPlayerSprite.FlyAway;
begin
  FState := pesFlyaway;
end;

{ TPlayerTamaSprite }

constructor TPlayerTamaSprite.Create(AParent: TSprite; APlayerSprite: TPlayerSprite);
begin
  inherited Create(AParent);
  FPlayerSprite := APlayerSprite;
  Image := MainForm.GetSpriteGraphic(smgBounce);
  Z := 2;
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  MainForm.PlaySound(smsShoot, False);
end;

destructor TPlayerTamaSprite.Destroy;
begin
  inherited Destroy;
  Dec(FPlayerSprite.FTamaCount);
end;

procedure TPlayerTamaSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if (Sprite is TEnemy) and not (Sprite is TEnemyTama) then
  begin
    TEnemy(Sprite).Hit;
    Dead;
  end;
  Done := False;
end;

procedure TPlayerTamaSprite.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  X := X+(800/1000)*MoveCount;
  if X>=mainform.dxdraw.surfacewidth then Dead;
  Collision;
end;

{ TEnemy }

constructor TEnemy.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent);
  FLife := ALifes;
  inc(mainform.EnemyCounter);
end;

destructor TEnemy.Destroy;
begin
  inherited Destroy;
  dec(mainform.EnemyCounter);
end;

procedure TEnemy.Hit(AHitStrength: integer = 1);
begin
  Dec(FLife, AHitStrength);
  if FLife<=0 then
  begin
    Collisioned := False;
    HitEnemy(True);
  end
  else
    HitEnemy(False);
end;

procedure TEnemy.HitEnemy(ADead: Boolean);
begin
  if ADead then
    MainForm.PlaySound(smsExplosion, False)
  else
    MainForm.PlaySound(smsHit, False);
end;

{ TEnemyTama }

constructor TEnemyTama.Create(AParent: TSprite; AEnemySprite: TSprite);
begin
  inherited Create(AParent);
  FEnemySprite := AEnemySprite;
  Image := MainForm.GetSpriteGraphic(smgBounce2);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  MainForm.PlaySound(smsShoot, False);
end;

procedure TEnemyTama.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  X := X - MoveCount*(600/1000);
  if X < -Width then Dead;
end;

{ TEnemyMeteor }

constructor TEnemyMeteor.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  FState := pesNormal;
  Image := MainForm.GetSpriteGraphic(smgEnemyMeteor);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
end;

procedure TEnemyMeteor.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(False);

  if ADead then Collisioned := True;
end;

procedure TEnemyMeteor.DoMove(MoveCount: Integer);
begin
  X := X - MoveCount*(250/1000);
  if X < -Width then Dead;
end;

{ TEnemyUFO }

constructor TEnemyUFO.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  FState := pesNormal;
  Image := MainForm.GetSpriteGraphic(smgEnemyDisk);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
end;

procedure TEnemyUFO.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FState := pesDead;
    FCounter := 0;
    Inc(MainForm.FScore, 1000);
    Image := MainForm.GetSpriteGraphic(smgExplosion);
    Width := Image.Width;
    Height := Image.Height;
    AnimCount := Image.PatternCount;
    AnimLooped := False;
    AnimSpeed := DEFAULT_ANIMSPEED;
    AnimPos := 0;
  end
  else
  begin
    Inc(MainForm.FScore, 100);
  end;
end;

procedure TEnemyUFO.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  if State = pesNormal then
  begin
    X := X - MoveCount*(300/1000);
    Y := Y + Cos256(FCounter div 15)*2;
    if X < -Width then Dead;
  end
  else if State = pesDead then
  begin
    X := X - MoveCount*(300/1000);
    if FCounter>200 then
    begin
      FState := pesDeadVanished;
      Dead;
    end;
  end;
  inc(FCounter, MoveCount);
end;

{ TEnemyUFO2 }

constructor TEnemyUFO2.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  FState := pesNormal;
  Image := MainForm.GetSpriteGraphic(smgEnemyDisk2);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
end;

procedure TEnemyUFO2.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FState := pesDead;
    FCounter := 0;
    Inc(MainForm.FScore, 1000);
    Image := MainForm.GetSpriteGraphic(smgExplosion);
    Width := Image.Width;
    Height := Image.Height;
    AnimCount := Image.PatternCount;
    AnimLooped := False;
    AnimSpeed := DEFAULT_ANIMSPEED;
    AnimPos := 0;
  end
  else
  begin
    Inc(MainForm.FScore, 100);
  end;
end;

procedure TEnemyUFO2.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  if State = pesNormal then
  begin
    X := X - MoveCount*(300/1000);
    Y := Y + Cos256(FCounter div 15)*2;
    if X < -Width then Dead;
    if FCounter-FOldTamaTime>=100 then
    begin
      Inc(FTamaCount);
      with TEnemyTama.Create(Engine, Self) do
      begin
        X := Self.X;
        Y := Self.Y+Self.Height div 2-Height div 2;
        Z := 10;
      end;
      FOldTamaTime := FCounter;
    end;
  end
  else if State = pesDead then
  begin
    X := X - MoveCount*(300/1000);
    if FCounter>200 then
    begin
      FState := pesDeadVanished;
      Dead;
    end;
  end;
  inc(FCounter, MoveCount);
end;

{ TEnemyAttacker }

constructor TEnemyAttacker.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  FState := pesNormal;
  Image := MainForm.GetSpriteGraphic(smgEnemyAttacker);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
end;

procedure TEnemyAttacker.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FState := pesDead;
    FCounter := 0;
    Inc(MainForm.FScore, 1000);
    Image := MainForm.GetSpriteGraphic(smgExplosion);
    Width := Image.Width;
    Height := Image.Height;
    AnimCount := Image.PatternCount;
    AnimLooped := False;
    AnimSpeed := DEFAULT_ANIMSPEED;
    AnimPos := 0;
  end
  else
  begin
    Inc(MainForm.FScore, 100);
  end;
end;

procedure TEnemyAttacker.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  if State = pesNormal then
  begin
    X := X - MoveCount*(300/1000)-FCounter div 128;
    if X < -Width then Dead;
  end
  else if State = pesDead then
  begin
    X := X - MoveCount*(300/1000);
    if FCounter>200 then
    begin
      FState := pesDeadVanished;
      Dead;
    end;
  end;
  inc(FCounter, MoveCount);
end;

{ TEnemyAttacker2 }

constructor TEnemyAttacker2.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  FState := pesEntering;
  Image := MainForm.GetSpriteGraphic(smgEnemyAttacker2);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
end;

procedure TEnemyAttacker2.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FState := pesDead;
    FCounter := 0;
    Inc(MainForm.FScore, 5000);
    Image := MainForm.GetSpriteGraphic(smgExplosion);
    Width := Image.Width;
    Height := Image.Height;
    AnimCount := Image.PatternCount;
    AnimLooped := False;
    AnimSpeed := DEFAULT_ANIMSPEED;
    AnimPos := 0;
  end
  else
  begin
    Inc(MainForm.FScore, 100);
  end;
end;

procedure TEnemyAttacker2.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  if State = pesEntering then
  begin
    if X>((mainform.dxdraw.width/4) + (mainform.dxdraw.width/2) - (width/2)){450} then
      X := X - MoveCount*(300/1000)
    else
    begin
      Collisioned := True;
      FState := pesHovering;
      FPutTama := True;
    end;
    Y := Y + Cos256(FCounter div 15)*5;
  end
  else if State = pesHovering then
  begin
    Y := Y + Cos256(FCounter div 15)*5;
    if FPutTama then
    begin
      if FTamaT>100 then
      begin
        with TEnemyTama.Create(Engine, Self) do
        begin
          Z := 1;
          X := Self.X-Width;
          Y := Self.Y+Self.Height div 2-Height div 2;
        end;
        Inc(FTamaF);
        if FTamaF>Random(30) then FPutTama := False;
        FTamaT := 0;
      end;
      FTamaT := FTamaT + MoveCount;
    end
    else
    begin
      FTamaT := FTamaT + MoveCount;
      if FTamaT>2000+Random(500) then
      begin
        FPutTama := True;
        FTamaF := 0;
        FTamaT := 0;
      end;
    end;
  end
  else if State = pesDead then
  begin
    if FCounter>200 then
    begin
      FState := pesDeadVanished;
      Dead;
    end;
  end;
  inc(FCounter, MoveCount);
end;

{ TEnemyAttacker3 }

constructor TEnemyAttacker3.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  FState := pesNormal;
  Image := MainForm.GetSpriteGraphic(smgEnemyAttacker3);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
end;

procedure TEnemyAttacker3.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FState := pesDead;
    FCounter := 0;
    Inc(MainForm.FScore, 5000);
    Image := MainForm.GetSpriteGraphic(smgExplosion);
    Width := Image.Width;
    Height := Image.Height;
    AnimCount := Image.PatternCount;
    AnimLooped := False;
    AnimSpeed := DEFAULT_ANIMSPEED;
    AnimPos := 0;
  end
  else
  begin
    Inc(MainForm.FScore, 100);
  end;
end;

procedure TEnemyAttacker3.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  if State = pesNormal then
  begin
    X := X - (250/1000)*MoveCount;
    if X < -Width then Dead;
    if FCounter-FOldTamaTime>=100 then
    begin
      Inc(FTamaCount);
      with TEnemyTama.Create(Engine, Self) do
      begin
        X := Self.X;
        Y := Self.Y+Self.Height div 2-Height div 2;
        Z := 10;
      end;
      FOldTamaTime := FCounter;
     end;
  end
  else if State = pesDead then
  begin
    if FCounter>200 then
    begin
      FState := pesDeadVanished;
      Dead;
    end;
  end;
  inc(FCounter, MoveCount);
end;

{ TEnemyBoss }

constructor TEnemyBoss.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  FState := pesEntering;
  Image := MainForm.GetSpriteGraphic(smgEnemyBoss);
  Width := Image.Width;
  Height := Image.Height;
  MainForm.MusicSwitchTrack(smmBoss);
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
  Collisioned := False;
  MainForm.FBoss := Self;
  waiter1 := 0;
  waiter2 := 0;
end;

procedure TEnemyBoss.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FState := pesExploding; // not pesDead for the boss!
    FCounter := 0;
    Inc(MainForm.FScore, 100000);
  end
  else
  begin
    Inc(MainForm.FScore, 100);
  end;
end;

destructor TEnemyBoss.Destroy;
begin
  MainForm.FBoss := nil;
  inherited;
end;

procedure TEnemyBoss.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  if State = pesEntering then
  begin
    if X>((mainform.dxdraw.width/4) + (mainform.dxdraw.width/2) - (width/4)){450} then
      X := X - MoveCount*(300/1000)
    else
    begin
      Collisioned := True;
      FState := pesHovering;
      FPutTama := True;
    end;
    Y := Y + Cos256(FCounter div 15)*5;
  end
  else if State = pesHovering then
  begin
    Y := Y + Cos256(FCounter div 15)*5;
    if FPutTama then
    begin
      if FTamaT>100 then
      begin
        with TEnemyTama.Create(Engine, Self) do
        begin
          Z := 1;
          X := Self.X-Width;
          Y := Self.Y+Self.Height div 2-Height div 2;
        end;
        Inc(FTamaF);
        if FTamaF>Random(30) then FPutTama := False;
        FTamaT := 0;
      end;
      FTamaT := FTamaT + MoveCount;
    end
    else
    begin
      FTamaT := FTamaT + MoveCount;
      if FTamaT>2000+Random(500) then
      begin
        FPutTama := True;
        FTamaF := 0;
        FTamaT := 0;
      end;
    end;
  end
  else if State = pesExploding then
  begin
    inc(waiter1);
    if waiter1 = 3 then
    begin
      waiter1 := 0;
      inc(waiter2);
      if waiter2 <= 20 then
      begin
        with TExplosion.Create(Engine) do
        begin
          Z := 10;
          X := Self.X+Random(Self.Width)-16;
          Y := Self.Y+Random(Self.Height)-16;
        end;
      end
      else
      begin
        Inc(MainForm.FScore, 10000);
        FState := pesDead;
      end;
    end;
  end
  else if State = pesDead then
  begin
    if FCounter>4000 then
    begin
      FState := pesDeadVanished;
      Dead;
    end;
  end;
  inc(FCounter, MoveCount);
end;

{ TItem }

procedure TItem.Collected;
begin
  MainForm.PlaySound(smsItemCollected, false);
  Dead;
end;

procedure TItem.DoMove(MoveCount: Integer);
begin
  X := X - MoveCount*(250/1000);
  if X < -Width then Dead;
end;

{ TItemMedikit }

procedure TItemMedikit.Collected;
begin
  Inc(MainForm.FLife);
  inherited;
end;

constructor TItemMedikit.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  FState := pesNormal;
  Image := MainForm.GetSpriteGraphic(smgItemMedikit);
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
end;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
resourcestring
  SAppTitle = 'SpaceMission %s';
begin
  Randomize;

  LevelData := TLevelData.Create;

  { Beginne VCL-Ersatz }
  dxtimer := tdxtimer.Create(self);
  dxtimer.Interval := 33;
  dxtimer.OnActivate := DXTimerActivate;
  dxtimer.OnDeactivate := DXTimerDeactivate;
  dxtimer.OnTimer := DXTimerTimer;
  dxtimer.ActiveOnly := false;
  dxtimer.Enabled := false;

  dxdraw := tdxdraw.Create(self);
  dxdraw.Parent := self;
  dxdraw.Align := alClient;
  dxdraw.Left := 0;
  dxdraw.Top := 0;
  dxdraw.Width := ClientWidth;
  dxdraw.Height := ClientHeight;
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
  dxdraw.TabOrder := 0;
  dxdraw.Visible := true;
  dxdraw.OnFinalize := DXDrawFinalize;
  dxdraw.OnInitialize := DXDrawInitialize;
  dxdraw.OnInitializing := DXDrawInitializing;

  dxsound := tdxsound.Create(self);
  dxsound.AutoInitialize := false;

  dxmusic := TDXMusic.Create(self);
  dxmusic.DXSound := dxsound;

  dxinput := tdxinput.Create(self);
  dxinput.Joystick.ForceFeedback := true;
  dxinput.Keyboard.ForceFeedback := true;

  wavelist := tdxwavelist.Create(self);
  wavelist.DXSound := dxsound;

  imagelist := tdximagelist.create(self);
  imagelist.DXDraw := dxdraw;

  spriteengine := tdxspriteengine.create(self);
  spriteengine.DXDraw := dxdraw;

  InitializeCriticalSection(TimerCS);

  { Ende VCL-Ersatz }

  Application.Title := Format(SAppTitle, [ProgramVersion]);
  LoadOptions;
  DXInit;
  SoundInit;
  MusicInit;

  GameStartClick(GameStart);
end;

procedure TMainForm.GameStartClick(Sender: TObject);
begin
  StartScene(gsTitle);
end;

function TMainForm.GetSpriteGraphic(
  Sprite: TSpaceMissionGraphicSprite): TPictureCollectionItem;
begin
  if (Sprite<>smgNone) and (imagelist.Items.Count >= Ord(Sprite)) then
    result := imagelist.Items.Items[Ord(Sprite)-1]
  else
    result := nil;
end;

procedure TMainForm.HilfeTopicClick(Sender: TObject);
// Please keep this code in-sync with LevMain.pas
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

procedure TMainForm.GamePauseClick(Sender: TObject);
begin
  GamePause.Checked := not GamePause.Checked;
  DXTimer.Enabled := not GamePause.Checked;
  if GamePause.Checked then
  begin
    if Assigned(DXTimer.OnDeactivate) then
      DXTimer.OnDeactivate(DXTimer);
  end
  else
  begin
    if Assigned(DXTimer.OnActivate) then
      DXTimer.OnActivate(DXTimer);
  end;
end;

procedure TMainForm.DXInit;
begin
  try
    Imagelist.Items.LoadFromFile(OwnDirectory+DxgFile);
    ImageList.Items.MakeColorTable;
    DXDraw.ColorTable := ImageList.Items.ColorTable;
    DXDraw.DefColorTable := ImageList.Items.ColorTable;
    DXDraw.UpdatePalette;
    DXDraw.Finalize;
    DXDraw.Options := DXDraw.Options - [doFullScreen];
    DXDraw.autosize := true;
    DXDraw.Initialize;
  except
    //Imagelist.Items.clear;
    //application.terminate;
  end;
end;

procedure TMainForm.CheckUpdatesClick(Sender: TObject);
begin
  CheckForUpdates('spacemission', ProgramVersion); // do not localize
end;

procedure TMainForm.BeendenClick(Sender: TObject);
begin
  close;
end;

procedure TMainForm.OptionSoundClick(Sender: TObject);
begin
  OptionSound.Checked := not OptionSound.Checked;
  SoundInit;
  WriteOptions;
end;

procedure TMainForm.SoundInit;
begin
  if (WaveOutGetNumDevs < 1) or not FileExists(OwnDirectory+DxwFile) then
  begin
    OptionSound.Checked := false;
    OptionSound.Enabled := False;
    exit;
  end;

  if OptionSound.Checked then
  begin
    if not DXSound.Initialized then
    begin
      try
        DXSound.Initialize;
        WaveList.Items.LoadFromFile(OwnDirectory+DxwFile);
      except
        OptionSound.enabled := False;
        WaveList.items.clear;
      end;
    end;
  end
  else DXSound.Finalize;
end;

procedure TMainForm.MusicInit;
var
  i: integer;
begin
  if (WaveOutGetNumDevs < 1) or not FileExists(OwnDirectory+DxmFile) then
  begin
    optionmusic.Checked := false;
    optionmusic.Enabled := False;
    exit;
  end;

  try
    dxmusic.Midis.LoadFromFile(OwnDirectory+DxmFile);
    for i := 0 to dxmusic.Midis.Count-1 do
    begin
      if not dxmusic.Midis.Items[i].IsInitialized then
      begin
        dxmusic.Midis.Items[i].Init;
        dxmusic.Midis.Items[i].Load;
      end;
    end;
  except
    optionmusic.enabled := false;
  end;
end;

procedure TMainForm.DXDrawInitializing(Sender: TObject);
begin
  if doFullScreen in DXDraw.Options then
  begin
    BorderStyle := bsNone;
    DXDraw.Cursor := crNone;
  end
  else
  begin
    BorderStyle := bsSingle;
    DXDraw.Cursor := crDefault;
  end;
end;

procedure TMainForm.DXDrawInitialize(Sender: TObject);
begin
  if Assigned(DXTimer) then DXTimer.Enabled := True;
end;

procedure TMainForm.DXDrawFinalize(Sender: TObject);
begin
  if Assigned(DXTimer) then DXTimer.Enabled := False;
end;

procedure TMainForm.DXTimerActivate(Sender: TObject);
begin
  if TDxTimer(Sender).Tag > 0 then
    TDxTimer(Sender).Tag := TDxTimer(Sender).Tag - 1; // es können mehrere activate/deactivate vorkommen, wegen dem Pause-Button
  if TDxTimer(Sender).Tag > 0 then
    exit;
  Caption := Application.Title;
  if not ProgrammGestartet then
  begin
    Programmgestartet := true;
    exit;
  end;
  ResumeMusic(FMusic);
end;

procedure TMainForm.DXTimerDeactivate(Sender: TObject);
resourcestring
  SPauseTitle = '%s [Pause]';
begin
  TDxTimer(Sender).Tag := TDxTimer(Sender).Tag + 1;
  Caption := Format(SPauseTitle, [Application.Title]);
  PauseMusic(FMusic);
end;

procedure TMainForm.DXTimerTimer(Sender: TObject; LagCount: Integer);
begin
  EnterCriticalSection(TimerCS);
  try
    if crash then
    begin
      inc(Crash2);
      if crash2 = 30 then
      begin
        Crash2 := 0;
        crash := false;
        crashsound := false;
      end;
    end;
    if not DXDraw.CanDraw then exit;
    DXInput.Update;
    case FScene of
      gsTitle   : SceneTitle;
      gsMain    : SceneMain;
      gsGameOver: SceneGameOver;
      gsWin     : SceneWin;
      gsNewLevel: SceneNewLevel;
    end;
    if FNextScene<>gsNone then
    begin
      StartScene(FNextScene);
      FNextScene := gsNone;
    end;
    DXDraw.Flip;
  finally
    LeaveCriticalSection(TimerCS);
  end;
end;

procedure TMainForm.BlinkStart;
begin
  FBlink := 0;
  FBlinkTime := GetTickCount;
end;

procedure TMainForm.WriteOptions;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(RegistrySettingsKey, true) then
    begin
      Reg.WriteBool(MusicSettingKey, OptionMusic.checked);
      Reg.WriteBool(SoundSettingKey, OptionSound.checked);
      Reg.WriteInteger(SpeedSettingKey, Ord(FSpeed));
      Reg.DeleteValue('Speed'); // deprecated. Replaced by GameSpeed
      Reg.CloseKey;
    end;
  finally
    FreeAndNil(Reg);
  end;
end;

procedure TMainForm.LoadOptions;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(RegistrySettingsKey, true) then
    begin
      if Reg.ValueExists(MusicSettingKey) then
        optionmusic.checked := Reg.ReadBool(MusicSettingKey)
      else
        optionmusic.checked := true; // default

      if Reg.ValueExists(SoundSettingKey) then
        optionsound.checked := Reg.ReadBool(SoundSettingKey)
      else
        optionsound.checked := true; // default

      if Reg.ValueExists(SpeedSettingKey) then
        FSpeed := Reg.ReadInteger(SpeedSettingKey)
      else
        FSpeed := SpeedMedium; // default

      Leicht.Checked := FSpeed = SpeedEasy;
      Mittel.Checked := FSpeed = SpeedMedium;
      Schwer.Checked := FSpeed = SpeedHard;
      Master.Checked := FSpeed = SpeedMaster;

      Reg.CloseKey;
    end;
  finally
    FreeAndNil(Reg);
  end;
  WriteOptions;
end;

procedure TMainForm.BlinkUpdate;
begin
  if GetTickCount<>FBlinkTime then
  begin
    FBlink := FBlink + (GetTickCount-FBlinkTime);
    FBlinkTime := GetTickCount;
  end;
end;

procedure TMainForm.PlaySound(Sound: TSpaceMissionSound; Wait: Boolean);
begin
  if (Sound<>smsNone) and (OptionSound.Checked) and (OptionSound.Enabled) and (WaveList.Items.Count >= Ord(Sound)) then
    WaveList.Items.Items[Ord(Sound)-1].Play(Wait);
end;

procedure TMainForm.MusicSwitchTrack(Name: TSpaceMissionMusicTrack);
begin
  if (not mainform.active) and (mainform.visible) then //1st Programmstart
    exit;
  if (OptionMusic.checked) and (OptionMusic.enabled) then
  begin
    StopMusic(FMusic);
    PlayMusic(Name);
  end;
  FMusic := Name;
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
    end
    else
    begin
      Sleep(Time);
    end;
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

procedure TMainForm.StartScene(Scene: TGameScene);
begin
  EndScene;
  DXInput.States := DXInput.States - DXInputButton;
  FScene := Scene;
  BlinkStart;
  case FScene of
    gsTitle   : StartSceneTitle;
    gsMain    : StartSceneMain;
    gsGameOver: StartSceneGameOver;
    gsWin     : StartSceneWin;
    gsNewLevel: StartSceneNewLevel;
  end;
end;

procedure TMainForm.StartSceneTitle;
begin
  sleep(500);
  FCheats := [];
  FLife := StartLives;
  FLevel := 0;
  FScore := 0;
  FLevelDataAlreadyLoaded := false; // do allow NewLevel() to work again
  FNotSave := true;
  Cheat.enabled := false;
  Neustart.enabled := false;
  GamePause.enabled := false;
  GameStart.enabled := false;
  Spielgeschwindigkeit.enabled := false;
  mainform.Visible := true;
  MusicSwitchTrack(smmTitle);
end;

procedure TMainForm.StartSceneMain;
{var
  i, j: Integer;}
begin
  sleep(500);
  FCounter := 0;
  if not FLevelDataAlreadyLoaded then NewLevel(FLevel);
  FRestEnemies := Length(LevelData.EnemyAdventTable);
  FLifeAtLevelStart := FLife;     // Das ist wichtig, wenn man neu starten möchte
  FScoreAtLevelStart := FScore;   //
  MusicSwitchTrack(smmGame);
  FEnemyAdventPos := 0;
  FFrame := -4;
  PlayerSprite := TPlayerSprite.Create(SpriteEngine.Engine);
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := MainForm.GetSpriteGraphic(smgStar3);
    Z := -13;
    Y := 40;
    Speed := 1 / 2;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := MainForm.GetSpriteGraphic(smgStar2);
    Z := -12;
    Y := 30;
    Speed := 1;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := MainForm.GetSpriteGraphic(smgStar1);
    Z := -11;
    Y := 10;
    Speed := 2;
    Tile := True;
  end;
  {with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(200, 10);
    Y := 10;
    Z := -13;
    Speed := 1 / 2;
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
    Speed := 1;
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
    Speed := 2;
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
  FNotSave := false;
  Cheat.enabled := true;
  Neustart.enabled := true;
  GamePause.enabled := true;
  GameStart.enabled := true;
  Spielgeschwindigkeit.enabled := true;
end;

procedure TMainForm.StartSceneGameOver;
begin
  sleep(500);
  FNotSave := true; // Wenn man speichert, würde man LevelAdventTable vom vorherigen Level machen, das wär müll!
  Cheat.enabled := false;
  Spielgeschwindigkeit.enabled := false;
  Neustart.enabled := false;
  GamePause.enabled := false;
  MusicSwitchTrack(smmScene);
end;

procedure TMainForm.StartSceneWin;
begin
  sleep(500);
  FNotSave := true; // Wenn man speichert, würde man LevelAdventTable vom vorherigen Level machen, das wär müll!
  Cheat.enabled := false;
  Spielgeschwindigkeit.enabled := false;
  Neustart.enabled := false;
  GamePause.enabled := false;
  MusicSwitchTrack(smmScene);
end;

procedure TMainForm.EndScene;
begin
  case FScene of
    gsTitle   : EndSceneTitle;
    gsMain    : EndSceneMain;
    gsGameOver: EndSceneGameOver;
    gsWin     : EndSceneWin;
    gsNewLevel: EndSceneNewLevel;
  end;
end;

procedure TMainForm.EndSceneTitle;
begin
  {  Ende Title  }
end;

procedure TMainForm.EndSceneMain;
begin
  SpriteEngine.Engine.Clear;
end;

procedure TMainForm.EndSceneGameOver;
begin
  {  Ende GameOver  }
end;

procedure TMainForm.EndSceneWin;
begin
  {  Ende Win  }
end;

procedure TMainForm.ResetLevelData;
begin
  LevelData.Clear;
  FRestEnemies := 0;
end;

procedure TMainForm.NewLevel(lev: integer);
resourcestring
  SLevelInvalid = 'Die Datei für Level %d ist ungültig. Level wird übersprungen!';
var
  act: integer;
  Enemies: array[1..32] of TEnemyType;
  numEnemies: integer;
  e: TEnemyAdvent;
  bossPosition: integer;
  levFile: TLevelFile;
begin
  ResetLevelData;
  if FGameMode = gmRandom then
  begin
    {$REGION 'Random game'}
    Enemies[1] := etEnemyAttacker;     // ab Lev 1
    Enemies[2] := etEnemyMeteor;       // ab Lev 1
    Enemies[3] := etEnemyUFO;          // ab Lev 1
    Enemies[4] := etEnemyAttacker;     // ab Lev 2
    Enemies[5] := etEnemyMeteor;       // ab Lev 3
    Enemies[6] := etEnemyUFO;          // ab Lev 4
    Enemies[7] := etEnemyAttacker;     // ab Lev 5
    Enemies[8] := etEnemyMeteor;       // ab Lev 6
    Enemies[9] := etEnemyUFO;          // ab Lev 7
    Enemies[10] := etEnemyAttacker;    // ab Lev 8
    Enemies[11] := etEnemyMeteor;      // ab Lev 9
    Enemies[12] := etEnemyUFO;         // ab Lev 10
    Enemies[13] := etEnemyAttacker;    // ab Lev 11
    Enemies[14] := etEnemyMeteor;      // ab Lev 12
    Enemies[15] := etEnemyUFO;         // ab Lev 13
    Enemies[16] := etEnemyAttacker3;   // ab Lev 14
    Enemies[17] := etEnemyAttacker;    // ab Lev 15
    Enemies[18] := etEnemyMeteor;      // ab Lev 16
    Enemies[19] := etEnemyUFO;         // ab Lev 17
    Enemies[20] := etEnemyUFO2;        // ab Lev 18
    Enemies[21] := etEnemyAttacker;    // ab Lev 19
    Enemies[22] := etEnemyMeteor;      // ab Lev 20
    Enemies[23] := etEnemyUFO;         // ab Lev 21
    Enemies[24] := etEnemyAttacker2;   // ab Lev 22
    Enemies[25] := etEnemyMeteor;      // ab Lev 23
    Enemies[26] := etEnemyUFO;         // ab Lev 24
    Enemies[27] := etEnemyAttacker;    // ab Lev 25
    Enemies[28] := etEnemyAttacker;    // ab Lev 26
    Enemies[29] := etEnemyAttacker2;   // ab Lev 27
    Enemies[30] := etEnemyAttacker3;   // ab Lev 28
    Enemies[31] := etEnemyUFO;         // ab Lev 29
    Enemies[32] := etEnemyUFO2;        // ab Lev 30
    numEnemies := lev*RandomLevelAdditionalEnemiesPerLevel;
    SetLength(LevelData.EnemyAdventTable, numEnemies);
    for act := 0 to numEnemies-1 do
    begin
      e.enemyType := Enemies[min(random(lev+2)+1, High(Enemies))];
      if e.enemyType = etEnemyAttacker2 then
      begin
        //e.enemyType := Enemies[min(random(lev+2)+1, High(Enemies))];
        if Random(2) = 0 then e.enemyType := etEnemyAttacker3;
      end;
      e.x := 85-(lev+(random(lev))*2){O_o};
      if e.x < 1 then e.x := 1; // passiert bei großen Levels
      e.x := act*30 + random(e.x);
      e.y := random((LevEditRows-1)*LevEditRasterH);
      if e.enemyType = etEnemyAttacker2 then
      begin
        e.lifes := random(6)+1{O_o};
      end
      else
      begin
        if lev > RandomLevelMaxEnemyLives then
        begin
          e.lifes := random(RandomLevelMaxEnemyLives)+1;
        end
        else
        begin
          e.lifes := random(lev)+1;
        end;
      end;

      if (act-1) mod RandomLevelMedikitEveryX = 0 then
      begin
        e.enemyType := etItemMedikit;
        e.lifes := 0;
      end;

      LevelData.EnemyAdventTable[act] := e;
    end;

    if lev < 5 then
    begin
      // Level 1-4: No boss
      bossPosition := -1;
    end
    else if lev < 10 then
    begin
      // Level 5-9: Boss is at the end of the level
      bossPosition := numEnemies-1;
    end
    else
    begin
      // Starting with Level 10: Boss at 75% of the level
      bossPosition := round(0.75 * numEnemies);
    end;

    if LevelData.EnemyAdventTable[bossPosition].enemyType = etItemMedikit then
      Inc(bossPosition);

    if bossPosition >= 0 then
    begin
      e.enemyType := etEnemyBoss;
      //e.x := lev*75*30{O_o} div lev;
      e.x := LevelData.EnemyAdventTable[bossPosition-1].x;
      e.y := (dxdraw.surfaceheight div 2) - (MainForm.GetSpriteGraphic(smgEnemyBoss).height div 2);
      e.lifes := lev*5;
      LevelData.EnemyAdventTable[bossPosition] := e;
    end;

    {$ENDREGION}
  end
  else
  begin
    {$REGION 'Normal game'}
    levFile := GetLevelFileName(lev,false);
    if levFile.found then
    begin
      try
        LevelData.RasterErzwingen := false;
        LevelData.LoadFromFile(levFile.fileLocation);
      except
        showmessage(Format(SLevelInvalid, [lev]));
        ResetLevelData; // empty level = the player will continue with the next level
      end;
    end;
    {$ENDREGION}
  end;
  FLevelDataAlreadyLoaded := true; // nicht nochmal NewLevel() aufrufen. Erst wieder wenn man gewonnen hat.
end;

var
  TitleWasPressed: TDxInputState = isButton32;

procedure TMainForm.SceneTitle;
resourcestring
  SNormalGame = 'Normales Spiel';
  SRandomGame = 'Zufalls-Level';
  SLevelEditor = 'Level-Editor';
var
  Logo: TPictureCollectionItem;
  colo1, colo2: TColor;
begin
  DXDraw.Surface.Fill(0);
  Logo := GetSpriteGraphic(smgLogo);
  {Logo.DrawWaveX(DXDraw.Surface, (dxdraw.surfaceWidth div 2) - 181, 65, Logo.Width, Logo.Height, 0,
    Trunc(16 - Cos256(FBlink div 60) * 16), 32, -FBlink div 5);}
  Logo.DrawWaveX(DXDraw.Surface, trunc((dxdraw.surfaceWidth / 2) - (Logo.Width / 2)), 65, Logo.Width, Logo.Height, 0,
    2, 80, Fangle * 4);
  inc(Fangle);

  if FGameMode = gmUnknown then FGameMode := gmLevels;

  if (isUp in MainForm.DXInput.States) then TitleWasPressed := isUp;
  if (TitleWasPressed=isUp) and not (isUp in MainForm.DXInput.States) then
  begin
    TitleWasPressed := isButton32;
    if (Ord(FGameMode) <> 1) then
      FGameMode := TGameMode(Ord(FGameMode)-1);
  end;

  if (isDown in MainForm.DXInput.States) then TitleWasPressed := isDown;
  if (TitleWasPressed=isDown) and not (isDown in MainForm.DXInput.States) then
  begin
    TitleWasPressed := isButton32;
    if (FGameMode <> High(TGameMode)) then
      FGameMode := TGameMode(Ord(FGameMode)+1);
  end;

  DXDraw.Surface.Canvas.Brush.Style := bsClear;
  DXDraw.Surface.Canvas.Font.Size := 30;

  {$REGION 'Menu point: Normal Level'}
  if FGameMode = gmLevels then
  begin
    colo1 := clMaroon;
    colo2 := clRed;
  end
  else
  begin
    colo1 := clOlive;
    colo2 := clYellow;
  end;
  DXDraw.Surface.Canvas.Font.Color := colo1;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-152, (dxdraw.surfaceheight div 2)-52, SNormalGame);
  if FGameMode = gmLevels then
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, (dxdraw.surfaceheight div 2)-52, '>');
  DXDraw.Surface.Canvas.Font.Color := colo2;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-150, (dxdraw.surfaceheight div 2)-50, SNormalGame);
  if FGameMode = gmLevels then
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, (dxdraw.surfaceheight div 2)-50, '>');
  {$ENDREGION}

  {$REGION 'Menu point: Random Level'}
  if FGameMode = gmRandom then
  begin
    colo1 := clMaroon;
    colo2 := clRed;
  end
  else
  begin
    colo1 := clOlive;
    colo2 := clYellow;
  end;
  DXDraw.Surface.Canvas.Font.Color := colo1;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-152, (dxdraw.surfaceheight div 2)-2, SRandomGame);
  if FGameMode = gmRandom then
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-187, (dxdraw.surfaceheight div 2)-2, '>');
  DXDraw.Surface.Canvas.Font.Color := colo2;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-150, (dxdraw.surfaceheight div 2), SRandomGame);
  if FGameMode = gmRandom then
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, (dxdraw.surfaceheight div 2), '>');
  {$ENDREGION}

  {$REGION 'Menu point: Level Editor'}
  if FGameMode = gmEditor then
  begin
    colo1 := clMaroon;
    colo2 := clRed;
  end
  else
  begin
    colo1 := clOlive;
    colo2 := clYellow;
  end;
  DXDraw.Surface.Canvas.Font.Color := colo1;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-152, (dxdraw.surfaceheight div 2)+48, SLevelEditor);
  if FGameMode = gmEditor then
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, (dxdraw.surfaceheight div 2)+48, '>');
  DXDraw.Surface.Canvas.Font.Color := colo2;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-150, (dxdraw.surfaceheight div 2)+50, SLevelEditor);
  if FGameMode = gmEditor then
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, (dxdraw.surfaceheight div 2)+50, '>');
  {$ENDREGION}

  { if (FBlink div 300) mod 2=0 then
  begin
    DXDraw.Surface.Canvas.Font.Color := clGreen;
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-187, dxdraw.surfaceheight-117, SWeiterMitLeertaste);
    DXDraw.Surface.Canvas.Font.Color := clLime;
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, dxdraw.surfaceheight-115, SWeiterMitLeertaste);
  end; }
  BlinkUpdate;
  DXDraw.Surface.Canvas.Release;

  // Weiter mit Leertaste oder Enter
  if (isButton1 in DXInput.States) or (isButton2 in DXInput.States) then
  begin
    FLevel := 1;
    if FGameMode = gmEditor then
    begin
      ShellExecute(0, 'open', PChar(OwnDirectory+LevEditExe), '', PChar(OwnDirectory), SW_NORMAL); // do not localize
      Close;
      exit;
    end;
    if ((FGameMode=gmLevels) and not GetLevelFileName(FLevel,false).found) or
       ((FGameMode=gmRandom) and (FLevel > MaxPossibleLevels)) then
    begin
      //PlaySound('Frage', False);
      exit;
    end;
    PlaySound(smsSceneMov, False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsMain);
  end;
end;

procedure TMainForm.SceneMain;
resourcestring
  SMissionSuccessful = 'Mission erfolgreich!';
  SMissionFailed = 'Mission gescheitert!';
  SPunkte = 'Punkte: %s';
  SLevel = 'Level: %d';
  SLifes = 'Leben: %d';
  SInfLifes = '';
  SBossLifes = 'Boss: %d';
  SEinheiten = 'Einheiten: %d';
var
  Enemy: TSprite;
  spriteClass: TClass;
  tmpEnemyAnzeige: integer;
begin
  SpriteEngine.Move(FSpeed);
  SpriteEngine.Dead;
  while (FEnemyAdventPos >= Low(LevelData.EnemyAdventTable)) and
    (FEnemyAdventPos <= High(LevelData.EnemyAdventTable)) and
    ((LevelData.EnemyAdventTable[FEnemyAdventPos].x / 4) <= FFrame) and
    (FRestEnemies > 0) do
  begin
    Dec(FRestEnemies);
    with LevelData.EnemyAdventTable[FEnemyAdventPos] do
    begin
      spriteClass := nil;
      case enemyType of
        //etUnknown: ;
        etEnemyAttacker:  spriteClass := TEnemyAttacker;
        etEnemyAttacker2: spriteClass := TEnemyAttacker2;
        etEnemyAttacker3: spriteClass := TEnemyAttacker3;
        etEnemyMeteor:    spriteClass := TEnemyMeteor;
        etEnemyUFO:       spriteClass := TEnemyUFO;
        etEnemyUFO2:      spriteClass := TEnemyUFO2;
        etEnemyBoss:      spriteClass := TEnemyBoss;
        etItemMedikit:    spriteClass := TItemMedikit;
      end;
      if spriteClass <> nil then
      begin
        Enemy := nil;
        if spriteClass.InheritsFrom(TEnemy) then
          Enemy := TEnemyClass(spriteClass).Create(SpriteEngine.Engine, lifes)
        else if spriteClass.InheritsFrom(TItem) then
          Enemy := TItemClass(spriteClass).Create(SpriteEngine.Engine)
        else
          Assert(False);
        Enemy.x := dxdraw.surfacewidth;
        //Enemy.y := y;
        if y <> 0 then
          Enemy.y := dxdraw.surfaceheight / ((LevEditRows*LevEditRasterH) / y)
        else
          Enemy.y := 0;
      end;
    end;
    Inc(FEnemyAdventPos);
  end;
  Inc(FFrame);
  DXDraw.Surface.Fill(0);
  if FNextScene=gsNone then
  begin
    SpriteEngine.Draw;
    DXDraw.Surface.Canvas.Brush.Style := bsClear;
    DXDraw.Surface.Canvas.Font.Size := 20;
    if flife > 0 then
    begin
      {$REGION 'Anzeige Punkte'}
      DXDraw.Surface.Canvas.Font.Color := clOlive;
      DXDraw.Surface.Canvas.Textout(9, 9, Format(SPunkte, [FloatToStrF(FScore,ffNumber,14,0)]));
      DXDraw.Surface.Canvas.Font.Color := clYellow;
      DXDraw.Surface.Canvas.Textout(10, 10, Format(SPunkte, [FloatToStrF(FScore,ffNumber,14,0)]));
      {$ENDREGION}

      {$REGION 'Anzeige Level'}
      DXDraw.Surface.Canvas.Font.Color := clMaroon;
      DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-141, 9, Format(SLevel, [flevel]));
      DXDraw.Surface.Canvas.Font.Color := clRed;
      DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-140, 10, Format(SLevel, [flevel]));
      {$ENDREGION}

      {$REGION 'Lebensanzeige'}
      if FLife<0 then FLife := 0;
      if ctInfiniteLives in FCheats then
      begin
        DXDraw.Surface.Canvas.Font.Color := clPurple;
        DXDraw.Surface.Canvas.Textout(9, dxdraw.surfaceheight-41, SInfLifes);
        DXDraw.Surface.Canvas.Font.Color := clFuchsia;
        DXDraw.Surface.Canvas.Textout(10, dxdraw.surfaceheight-40, SInfLifes);
      end
      else
      begin
        if ((Flife = 1) and ((FBlink div 300) mod 2=0)) or (Flife <> 1) then
        begin
          DXDraw.Surface.Canvas.Font.Color := clPurple;
          DXDraw.Surface.Canvas.Textout(9, dxdraw.surfaceheight-41, Format(SLifes, [flife]));
          DXDraw.Surface.Canvas.Font.Color := clFuchsia;
          DXDraw.Surface.Canvas.Textout(10, dxdraw.surfaceheight-40, Format(SLifes, [flife]));
        end;
        if Flife = 1 then BlinkUpdate;
      end;
      {$ENDREGION}

      {$REGION 'Anzeige Einheiten und Boss Leben'}

      tmpEnemyAnzeige := EnemyCounter{Auf Bildschirm} + FRestEnemies{In der Warteschlange};
      if Assigned(FBoss) and (FBoss.State<>pesDeadVanished) then Dec(tmpEnemyAnzeige);

      if Assigned(FBoss) and (FBoss.Life>0) then
      begin
        if (tmpEnemyAnzeige>0) then
        begin
          DXDraw.Surface.Canvas.Font.Color := clGreen;
          DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-191, dxdraw.surfaceheight-81, Format(SBossLifes, [FBoss.Life]));
          DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-191, dxdraw.surfaceheight-41, Format(SEinheiten, [tmpEnemyAnzeige]));
          DXDraw.Surface.Canvas.Font.Color := clLime;
          DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-190, dxdraw.surfaceheight-80, Format(SBossLifes, [FBoss.Life]));
          DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-190, dxdraw.surfaceheight-40, Format(SEinheiten, [tmpEnemyAnzeige]));
        end
        else
        begin
          DXDraw.Surface.Canvas.Font.Color := clGreen;
          DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-191, dxdraw.surfaceheight-41, Format(SBossLifes, [FBoss.Life]));
          DXDraw.Surface.Canvas.Font.Color := clLime;
          DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-190, dxdraw.surfaceheight-40, Format(SBossLifes, [FBoss.Life]));
        end;
      end
      else if tmpEnemyAnzeige>0 then
      begin
        DXDraw.Surface.Canvas.Font.Color := clGreen;
        DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-191, dxdraw.surfaceheight-41, Format(SEinheiten, [tmpEnemyAnzeige]));
        DXDraw.Surface.Canvas.Font.Color := clLime;
        DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-190, dxdraw.surfaceheight-40, Format(SEinheiten, [tmpEnemyAnzeige]));
      end;
      {$ENDREGION}

      {$REGION 'Anzeige Mission erfolgreich/gescheitert'}
      if (EnemyCounter=0) and (FRestEnemies=0) then
      begin
        DXDraw.Surface.Canvas.Font.Color := clGreen;
        DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-251, dxdraw.surfaceheight-41, SMissionSuccessful);
        DXDraw.Surface.Canvas.Font.Color := clLime;
        DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-250, dxdraw.surfaceheight-40, SMissionSuccessful);
        DXDraw.Surface.Canvas.Release;
        Sleep(1);
        inc(FCounter);
        if FCounter>150{200} then PlayerSprite.FlyAway;
      end;
      {$ENDREGION}
    end
    else
    begin
      DXDraw.Surface.Canvas.Font.Color := clMaroon;
      DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-251, dxdraw.surfaceheight-41, SMissionFailed);
      DXDraw.Surface.Canvas.Font.Color := clRed;
      DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-250, dxdraw.surfaceheight-40, SMissionFailed);
    end;
    DXDraw.Surface.Canvas.Release;
  end;
end;

procedure TMainForm.SceneGameOver;
resourcestring
  SGameOver = 'Game Over!';
begin
  DXDraw.Surface.Fill(0);

  FNotSave := true;
  Cheat.enabled := false;
  GamePause.enabled := false;
  Neustart.enabled := false;
  Brush.Style := bsClear;
  DXDraw.Surface.Canvas.Font.Size := 35;
  DXDraw.Surface.Canvas.Font.Color := clMaroon;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfacewidth div 2)-127, 98, SGameOver);
  DXDraw.Surface.Canvas.Font.Color := clRed;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfacewidth div 2)-125, 100, SGameOver);
  if (FBlink div 300) mod 2=0 then
  begin
    DXDraw.Surface.Canvas.Font.Size := 30;
    DXDraw.Surface.Canvas.Font.Color := clOlive;
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-187, dxdraw.surfaceheight-117, SWeiterMitLeertaste);
    DXDraw.Surface.Canvas.Font.Color := clYellow;
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, dxdraw.surfaceheight-115, SWeiterMitLeertaste);
  end;
  BlinkUpdate;
  DXDraw.Surface.Canvas.Release;

  // Weiter mit Leertaste oder Enter
  if (isButton1 in DXInput.States) or (isButton2 in DXInput.States) then
  begin
    PlaySound(smsSceneMov, False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsTitle);
  end;
end;

procedure TMainForm.SceneWin;
resourcestring
  SGewonnen = 'Gewonnen!';
begin
  DXDraw.Surface.Fill(0);

  FNotSave := true;
  Cheat.enabled := false;
  GamePause.enabled := false;
  Neustart.enabled := false;

  DXDraw.Surface.Canvas.Brush.Style := bsClear;
  DXDraw.Surface.Canvas.Font.Size := 35;
  DXDraw.Surface.Canvas.Font.Color := clMaroon;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-127, 98, SGewonnen);
  DXDraw.Surface.Canvas.Font.Color := clRed;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-125, 100, SGewonnen);
  if (FBlink div 300) mod 2=0 then
  begin
    DXDraw.Surface.Canvas.Font.Size := 30;
    DXDraw.Surface.Canvas.Font.Color := clOlive;
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-187, dxdraw.surfaceheight-117, SWeiterMitLeertaste);
    DXDraw.Surface.Canvas.Font.Color := clYellow;
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, dxdraw.surfaceheight-115, SWeiterMitLeertaste);
  end;
  BlinkUpdate;
  DXDraw.Surface.Canvas.Release;

  // Weiter mit Leertaste oder Enter
  if (isButton1 in DXInput.States) or (isButton2 in DXInput.States) then
  begin
    PlaySound(smsSceneMov, False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsTitle);
  end;
end;

procedure TMainForm.StartSceneNewLevel;
begin
  sleep(500);
  FNotSave := true; // Wenn man speichert, würde man LevelAdventTable vom vorherigen Level machen, das wär müll!
  Cheat.enabled := false;
  Neustart.enabled := false;
  GamePause.enabled := false;
  GameStart.enabled := true;
  Spielgeschwindigkeit.enabled := false;
  Spielgeschwindigkeit.enabled := false;
  if ((FGameMode=gmLevels) and not GetLevelFileName(FLevel,false).found)
     // or ((FGameMode=gmRandom) and (FLevel > 25))
     or (FLevel > MaxPossibleLevels) then
  begin
    //PlaySound('SceneMov', False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsWin);
    exit;
  end;
  MusicSwitchTrack(smmScene);
end;

procedure TMainForm.EndSceneNewLevel;
begin
  {  Ende NewLevel  }
end;

procedure TMainForm.SceneNewLevel;
resourcestring
  SLevelScene = 'Level %d';
begin
  DXDraw.Surface.Fill(0);

  DXDraw.Surface.Canvas.Brush.Style := bsClear;
  DXDraw.Surface.Canvas.Font.Size := 40;
  DXDraw.Surface.Canvas.Font.Color := clMaroon;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-(83+(length(inttostr(flevel))*22)), 98, Format(SLevelScene, [flevel]));
  DXDraw.Surface.Canvas.Font.Color := clRed;
  DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-(81+(length(inttostr(flevel))*22)), 100, Format(SLevelScene, [flevel]));
  if (FBlink div 300) mod 2=0 then
  begin
    DXDraw.Surface.Canvas.Font.Size := 30;
    DXDraw.Surface.Canvas.Font.Color := clOlive;
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-187, dxdraw.surfaceheight-117, SWeiterMitLeertaste);
    DXDraw.Surface.Canvas.Font.Color := clYellow;
    DXDraw.Surface.Canvas.Textout((dxdraw.surfaceWidth div 2)-185, dxdraw.surfaceheight-115, SWeiterMitLeertaste);
  end;
  BlinkUpdate;
  DXDraw.Surface.Canvas.Release;

  // Weiter mit Leertaste oder Enter
  if (isButton1 in DXInput.States) or (isButton2 in DXInput.States) then
  begin
    PlaySound(smsSceneMov, False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsMain);
  end;
end;

procedure TMainForm.OptionMusicClick(Sender: TObject);
begin
  OptionMusic.Checked := not OptionMusic.Checked;
  if OptionMusic.Checked then
  begin
    MusicSwitchTrack(FMusic)
  end
  else
  begin
    StopMusic(FMusic);
  end;
  WriteOptions;
end;

procedure TMainForm.PlayMusic(Name: TSpaceMissionMusicTrack);
begin
  if not OptionMusic.checked then exit;
  if Ord(Name) > dxmusic.Midis.Count then exit;
  dxmusic.Midis.Items[Ord(Name)-1].Play;
end;

procedure TMainForm.StopMusic(Name: TSpaceMissionMusicTrack);
begin
  if Name = smmNone then exit;
  if Ord(Name) > dxmusic.Midis.Count then exit;
  dxmusic.Midis.Items[Ord(Name)-1].Stop;
end;

procedure TMainForm.ResumeMusic(Name: TSpaceMissionMusicTrack);
begin
  if not OptionMusic.checked then exit;
  if Ord(Name) > dxmusic.Midis.Count then exit;
  dxmusic.Midis.Items[Ord(Name)-1].Play; // TODO: how to pause/resume instead play/stop
end;

procedure TMainForm.PauseMusic(Name: TSpaceMissionMusicTrack);
begin
  if Name = smmNone then exit;
  if Ord(Name) > dxmusic.Midis.Count then exit;
  dxmusic.Midis.Items[Ord(Name)-1].Stop; // TODO: how to pause/resume instead play/stop
end;

procedure TMainForm.SpielstandClick(Sender: TObject);
begin
  speicherungform.showmodal;
end;

procedure TMainForm.LevelNeuStarten;
begin
  FNextScene := gsNewLevel;
  FLife := FLifeAtLevelStart;
  FScore := FScoreAtLevelStart;
end;

procedure TMainForm.NeustartClick(Sender: TObject);
begin
  LevelNeuStarten;
end;

procedure TMainForm.LeichtClick(Sender: TObject);
begin
  leicht.checked := true;
  FSpeed := SpeedEasy;
  writeoptions;
end;

procedure TMainForm.MittelClick(Sender: TObject);
begin
  mittel.checked := true;
  FSpeed := SpeedMedium;
  writeoptions;
end;

procedure TMainForm.SchwerClick(Sender: TObject);
begin
  schwer.checked := true;
  FSpeed := SpeedHard;
  writeoptions;
end;

procedure TMainForm.MasterClick(Sender: TObject);
begin
  master.checked := true;
  FSpeed := SpeedMaster;
  writeoptions;
end;

procedure TMainForm.FormShow(Sender: TObject);
resourcestring
  SFileError = 'Die Datei kann von SpaceMission nicht geöffnet werden!';
var
  SavGame: TSaveData;
begin
  if Assigned(SplashForm) then
  begin
    SplashForm.Hide;
    FreeAndNil(SplashForm);
  end;

  dxtimer.Enabled := true;
  dxtimer.ActiveOnly := true;

  ResetLevelData;
  if (paramcount > 0) and (fileexists(paramstr(1))) and (ExtractFileExt(paramstr(1)).ToLower = '.sav') then
  begin
    SavGame := TSaveData.Create;
    try
      try
        SavGame.LoadFromFile(paramstr(1));
        FScore := SavGame.Score;
        FLife := SavGame.Life;
        FLevel := SavGame.Level;
        FGameMode := SavGame.GameMode;
        FLevelDataAlreadyLoaded := true; // do not call NewLevel() in StartSceneMain
        if Assigned(SavGame.LevelData) then
        begin
          LevelData.Assign(SavGame.LevelData);
        end;
      except
        on E: Exception do
        begin
          showmessage(SFileError + ' ' +E.Message);
          GameStartClick(GameStart);
          exit;
        end;
      end;
    finally
      FreeAndNil(SavGame);
    end;
    //FNextScene := gsNewLevel;
    StartScene(gsNewLevel);
    exit;
  end;
end;

procedure TMainForm.InformationenClick(Sender: TObject);
begin
  dxtimer.enabled := false;
  InfoForm.showmodal;
  if not mainform.gamepause.checked then mainform.dxtimer.enabled := true;
end;

procedure TMainForm.CheatClick(Sender: TObject);
begin
  CheatForm.showmodal;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if optionMusic.checked then StopMusic(FMusic);
  SpriteEngine.Engine.Clear;
  dxsound.Finalize;
  dxinput.Destroy;
  DXTimer.Enabled := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(imagelist);
  FreeAndNil(spriteengine);
  FreeAndNil(dxdraw);
  FreeAndNil(wavelist);
  FreeAndNil(dxmusic);
  FreeAndNil(dxsound);
  //FreeAndNil(dxinput);
  FreeAndNil(dxtimer);
  DeleteCriticalSection(TimerCS);
  FreeAndNil(LevelData);
end;

procedure PostKeyEx32(key: Word; const shift: TShiftState; specialkey: Boolean);
{************************************************************
* Procedure PostKeyEx32
*
* Parameters:
*  key    : virtual keycode of the key to send. For printable
*           keys this is simply the ANSI code (Ord(character)).
*  shift  : state of the modifier keys. This is a set, so you
*           can set several of these keys (shift, control, alt,
*           mouse buttons) in tandem. The TShiftState type is
*           declared in the Classes Unit.
*  specialkey: normally this should be False. Set it to True to
*           specify a key on the numeric keypad, for example.
* Description:
*  Uses keybd_event to manufacture a series of key events matching
*  the passed parameters. The events go to the control with focus.
*  Note that for characters key is always the upper-case version of
*  the character. Sending without any modifier keys will result in
*  a lower-case character, sending it with [ssShift] will result
*  in an upper-case character!
// Code by P. Below
************************************************************}
type
  TShiftKeyInfo = record
    shift: Byte;
    vkey: Byte;
  end;
  byteset = set of 0..7;
const
  shiftkeys: array [1..3] of TShiftKeyInfo =
    ((shift: Ord(ssCtrl); vkey: VK_CONTROL),
    (shift: Ord(ssShift); vkey: VK_SHIFT),
    (shift: Ord(ssAlt); vkey: VK_MENU));
var
  flag: DWORD;
  bShift: ByteSet absolute shift;
  i: Integer;
begin
  for i := 1 to 3 do
  begin
    if shiftkeys[i].shift in bShift then
      keybd_event(shiftkeys[i].vkey, MapVirtualKey(shiftkeys[i].vkey, 0), 0, 0);
  end; { For }
  if specialkey then
    flag := KEYEVENTF_EXTENDEDKEY
  else
    flag := 0;

  keybd_event(key, MapvirtualKey(key, 0), flag, 0);
  flag := flag or KEYEVENTF_KEYUP;
  keybd_event(key, MapvirtualKey(key, 0), flag, 0);

  for i := 3 downto 1 do
  begin
    if shiftkeys[i].shift in bShift then
      keybd_event(shiftkeys[i].vkey, MapVirtualKey(shiftkeys[i].vkey, 0),
        KEYEVENTF_KEYUP, 0);
  end; { For }
end; { PostKeyEx32 }

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    // TODO: Unfortunately, you cannot see if it is already popup. It would be great if ESC closes the main menu...
    Key := 0;
    PostKeyEx32(Ord('S'), [ssAlt], False);
  end;
end;

end.

