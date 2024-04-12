unit GamMain;

// TODO 2024 Review
// ----------------
//              Quellcode optimieren und klassen-namen überdenken
// [OK SVN 12]  Form Screen center anstelle Desktop Center
//              Vollbild entf.
// [OK SVN 10]  DPlayX.dll auskommentieren => OK!
//              EV CodeSign
//              Spielstände usw. "Spiele" Ordner speichern, Config in Registry sichern, etc.
//              Neue Einheiten => Medikit, Ufo das im Kreis fliegt und nicht weggeht
//              Bei Pause => Entweder alles grau werden lassen, oder irgendwo "Pause" hinschreiben (nur Not in die Form Caption)
//              Alle Notizen durchschauen
//              Boss schwieriger machen: Er soll auch nach links und rechts gehen?
//              Cooldown für Laser?
//              Improve Sound effects
// [OK SVN 18]  MCI hangs a lot! Use new unDelphiX DXMusic component for MIDI!
//              Pausiertes Spiel: Fenster bewegen lässt das Spiel wieder starten
//              Zwei Fenster in Taskleiste
//              "Doku" in Hilfemenü einbinden, ggf. auch den Leveleditor ins Menü machen
//              Highscore Liste
//              Multilingual (all strings in resourcestrings)
// [OK SVN 17]  Levelconverter entfernen, stattdessen einlesen abwärtskompatibel machen
//              Credits: unDelphiX (micrel.cz/Dx)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, DIB, DXClass, DXSprite, DXDraws, DXInput, DXSounds,
  INIFiles, ShellAPI, wininet, DirectX{$IF CompilerVersion >= 23.0},
  System.UITypes{$IFEND}, ComLevelReader, ComSaveGameReader, DirectMusic;

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
    giMittel,
    giLeicht,
    giSchwer,
    giMaster
  );

  TMusicTrack = (
    mtNone,
    mtBoss,   // dxmusic.Midi[0]
    mtGame,   // dxmusic.Midi[1]
    mtScene,  // ...
    mtTitle
  );

  {TSoundFile = (
    sfNone,
    sfSceneMov,
    sfExplosion,
    sfHit,
    sfShoot,
    sfDanger,
    sfEnde,
    sfFrage,
    sfLevIntro
  );}

  TBackground = class(TBackgroundSprite)
  private
    FSpeed: Double;
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

  TBackgroundSpecial = class(TBackgroundSprite)
  private
    FSpeed: Double;
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

  TExplosion = class(TImageSprite)
  private
    FCounter: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TPlayerSprite = class(TImageSprite)
  private
    FCounter: Integer;
    FMode: Integer;
    FTamaCount: Integer;
    FOldTamaTime: Integer;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
    procedure FlyAway;
  end;

  TTamaSprite = class(TImageSprite)
  private
    FPlayerSprite: TPlayerSprite;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
    destructor Destroy; override;
  end;

  TEnemyClass = class of TEnemy;
  TEnemy = class(TImageSprite)
  private
    FCounter: Integer;
    FLife: integer;
    FMode: Integer;
  protected
    procedure HitEnemy(ADead: Boolean); virtual;
  public
    procedure Hit(AHitStrength: integer = 1);
    constructor Create(AParent: TSprite; ALifes: integer); reintroduce; virtual;
    destructor Destroy; override;
  end;

  TEnemyTama = class(TImageSprite)
  private
    FPlayerSprite: TSprite;
  protected
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

  TEnemyMeteor = class(TEnemy)
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyUFO = class(TEnemy)
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyUFO2 = class(TEnemy)
  private
    FCounter: Integer;
    FTamaCount: Integer;
    FOldTamaTime: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyAttacker = class(TEnemy)
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyAttacker2 = class(TEnemy)
  private
    FCounter: Integer;
    FTamaF: Integer;
    FTamaT: Integer;
    FPutTama: Boolean;
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyAttacker3 = class(TEnemy)
  private
    FCounter: Integer;
    FTamaCount: Integer;
    FOldTamaTime: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TEnemyBoss = class(TEnemy)
  private
    FCounter: Integer;
    FTamaF: Integer;
    FTamaT: Integer;
    FPutTama: Boolean;
    waiter1, waiter2: integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure HitEnemy(ADead: Boolean); override;
  public
    constructor Create(AParent: TSprite; ALifes: integer); override;
  end;

  TMainForm = class(TDXForm)
    MainMenu: TMainMenu;
    Spiel: TMenuItem;
    GameStart: TMenuItem;
    GamePause: TMenuItem;
    Beenden: TMenuItem;
    Einstellungen: TMenuItem;
    OptionFullScreen: TMenuItem;
    OptionMusic: TMenuItem;
    Leer2: TMenuItem;
    Leer4: TMenuItem;
    Hilfe: TMenuItem;
    OptionSound: TMenuItem;
    Leer3: TMenuItem;
    Spielstand: TMenuItem;
    Leer5: TMenuItem;
    Neustart: TMenuItem;
    OptionBreitbild: TMenuItem;
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
    procedure DXDrawFinalize(Sender: TObject);
    procedure DXDrawInitialize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DXTimerTimer(Sender: TObject; LagCount: Integer);
    procedure DXTimerActivate(Sender: TObject);
    procedure DXTimerDeactivate(Sender: TObject);
    procedure OptionFullScreenClick(Sender: TObject);
    procedure DXDrawInitializing(Sender: TObject);
    procedure GameStartClick(Sender: TObject);
    procedure GamePauseClick(Sender: TObject);
    procedure BeendenClick(Sender: TObject);
    procedure OptionSoundClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OptionMusicClick(Sender: TObject);
    procedure SpielstandClick(Sender: TObject);
    procedure NeustartClick(Sender: TObject);
    procedure OptionBreitbildClick(Sender: TObject);
    procedure LeichtClick(Sender: TObject);
    procedure MittelClick(Sender: TObject);
    procedure SchwerClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure InformationenClick(Sender: TObject);
    procedure CheatClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure CheckUpdatesClick(Sender: TObject);
    procedure MasterClick(Sender: TObject);
  private
    ProgrammGestartet: boolean;
    FInterval: TGameInterval;
    FScene: TGameScene;
    FMusic: TMusicTrack;
    FBlink: DWORD;
    FBlinkTime: DWORD;
    FFrame, FAngle, FCounter, FEnemyAdventPos: Integer;
    PlayerSprite: TPlayerSprite;
    TimerCS: TRTLCriticalSection;
    LevelData: TLevelData;
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
  public
    FNextScene: TGameScene;
    FScore: Integer;
    FNotSave: boolean;
    FLife: integer;
    FLevel: integer;
    FGameMode: TGameMode;
    FBossLife: integer;
    FRestEnemies: integer;
    FCheat: boolean;
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
    procedure NewLevel(lev: integer);
    procedure ResetLevelData;
    { MCI-Routinen }
    procedure PlayMusic(Name: TMusicTrack);
    //procedure StopMusic(Name: TMusicTrack);
    procedure PauseMusic(Name: TMusicTrack);
    procedure ResumeMusic(Name: TMusicTrack);
    procedure DestroyMusic(Name: TMusicTrack);
    procedure OpenMusic(Name: TMusicTrack);
    { Sound-Routinen }
    procedure PlaySound(Name: string; Wait: Boolean);
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
  GamSplash, GamSpeicherung, ComInfo, GamCheat, Global;

const
  // TODO: ini file
  conleicht = 650 div 60; // 10
  conmittel = 1000 div 60; // 16
  conschwer = 1350 div 60; // 22
  conmaster = 2000 div 60; // 33
  lives = 6;

  // TODO: Auch für Enemies
  PLAYER_MODE_NORMAL = 0;
  PLAYER_MODE_DEAD = 1;
  PLAYER_MODE_DEAD_VANISHED = 2;
  PLAYER_MODE_FLYAWAY = 3;
  PLAYER_MODE_ENTER = 4;

  DEFAULT_ANIMSPEED = 15/1000;

resourcestring
  FileError = 'Die Datei kann von SpaceMission nicht geöffnet werden!';

{$R *.DFM}

var // TODO: irgendwo hinpacken. irgendwo!!!
  Crash2, EnemyCounter: integer;
  BossExists, Crash, crashsound: boolean;

const
  DXInputButton = [isButton1, isButton2, isButton3,
    isButton4, isButton5, isButton6, isButton7, isButton8, isButton9, isButton10, isButton11,
    isButton12, isButton13, isButton14, isButton15, isButton16, isButton17, isButton18,
    isButton19, isButton20, isButton21, isButton22, isButton23, isButton24, isButton25,
    isButton26, isButton27, isButton28, isButton29, isButton30, isButton31, isButton32];

// TODO: Code komplett überarbeiten. Bessere Ableitungen machen

constructor TPlayerSprite.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Machine');
  Width := Image.Width;
  Height := Image.Height;
  X := -70{20};
  Y := mainform.dxdraw.surfaceHeight / 2 - (height / 2);
  Z := 2;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  FMode := PLAYER_MODE_ENTER;
end;

procedure TPlayerSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if mainform.FCheat then exit;
  if (Sprite is TEnemy) or (Sprite is TEnemyTama) then
  begin
    if not crash then
    begin
      dec(MainForm.FLife);
      Crash := true;
      if MainForm.Flife=0 then
      begin
        MainForm.PlaySound('Explosion', false);
        Collisioned := false;
        FCounter := 0;
        FMode := PLAYER_MODE_DEAD;
        Done := false;
        Image := MainForm.ImageList.Items.Find('Explosion');
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
      if not crashsound then
      begin
        MainForm.PlaySound('Hit', False);
        crashsound := true;
      end;
    end;
  end;
end;

procedure TPlayerSprite.DoMove(MoveCount: Integer);
const
  WegduesKonstante = 1.75;
begin
  inherited DoMove(MoveCount);
  if FMode=PLAYER_MODE_NORMAL then
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
        with TTamaSprite.Create(Engine) do
        begin
          FPlayerSprite := Self;
          X := Self.X+Self.Width;
          Y := Self.Y+Self.Height div 2-Height div 2;
          Z := 10;
        end;
        FOldTamaTime := FCounter;
      end;
    end;
    Collision;
  end
  else if FMode=PLAYER_MODE_DEAD then
  begin
    if FCounter>200 then
    begin
      FCounter := 0;
      FMode := PLAYER_MODE_DEAD_VANISHED;
      Visible := false;
    end;
  end
  else if FMode=PLAYER_MODE_DEAD_VANISHED then
  begin
    if FCounter>1500 then
    begin
      MainForm.FNextScene := gsGameOver;
      MainForm.PlaySound('SceneMov', false);
      MainForm.PalleteAnim(RGBQuad(0, 0, 0), 300);
      Sleep(200);
    end;
  end
  else if FMode=PLAYER_MODE_FLYAWAY then
  begin
    // FUT: "Wusch" sound?
    X := X + MoveCount*(300/1000) * (X/MainForm.DXDraw.Width + WegduesKonstante);
    if X > MainForm.DXDraw.Width+Width then
    begin
      Dead;
      inc(mainform.FLevel);
      MainForm.FNextScene := gsNewLevel;
      MainForm.PlaySound('SceneMov', false);
      MainForm.PalleteAnim(RGBQuad(0, 0, 0), 300);
    end;
  end
  else if FMode = PLAYER_MODE_ENTER then
  begin
    X := X + MoveCount*(300/1000);
    if X > 19 then FMode := PLAYER_MODE_NORMAL;
  end;
  inc(FCounter, MoveCount);
end;

procedure TPlayerSprite.FlyAway;
begin
  FMode := PLAYER_MODE_FLYAWAY;
end;

procedure TMainForm.DXInit;
begin
  try
    Imagelist.Items.LoadFromFile(FDirectory+'DirectX\Graphic.dxg');
    ImageList.Items.MakeColorTable;
    DXDraw.ColorTable := ImageList.Items.ColorTable;
    DXDraw.DefColorTable := ImageList.Items.ColorTable;
    DXDraw.UpdatePalette;
    OptionBreitBild.enabled := OptionFullScreen.checked;
    DXDraw.Finalize;
    if OptionFullScreen.Checked then
    begin
      if not (doFullScreen in DXDraw.Options) then StoreWindow;
      DXDraw.Options := DXDraw.Options + [doFullScreen];
    end
    else
    begin
      if doFullScreen in DXDraw.Options then RestoreWindow;
      DXDraw.Options := DXDraw.Options - [doFullScreen];
    end;
    if not OptionBreitBild.checked then
    begin
      dxdraw.autosize := false;
      dxdraw.Top := 0;
      dxdraw.Left := 0;
      dxdraw.width := 640;    // TODO: besser die dimensionen des fensters
      dxdraw.height := 480;
      dxdraw.surfacewidth := 640;
      dxdraw.surfaceheight := 480;
    end
    else dxdraw.autosize := true;
    DXDraw.Initialize;
  except
    //Imagelist.Items.clear;
    //application.terminate;
  end;
end;

constructor TTamaSprite.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Bounce');
  Z := 2;
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  MainForm.PlaySound('Shoot', False);
end;

destructor TTamaSprite.Destroy;
begin
  inherited Destroy;
  Dec(FPlayerSprite.FTamaCount);
end;

procedure TTamaSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if (Sprite is TEnemy) and not (Sprite is TEnemyTama) then
  begin
    TEnemy(Sprite).Hit;
    Dead;
  end;
  Done := False;
end;

procedure TTamaSprite.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  X := X+(800/1000)*MoveCount;
  if X>=mainform.dxdraw.surfacewidth then Dead;
  Collision;
end;

procedure TBackground.DoMove(MoveCount: Integer);
var
  ran: integer;
begin
  inherited DoMove(MoveCount);
  X := X - MoveCount*(60/1000)*FSpeed;
  randomize;
  ran := Random(1500);
  if ran = 150 then
  begin
    with TBackgroundSpecial.Create(mainform.SpriteEngine.Engine) do
    begin
      SetMapSize(1, 1);
      Image := mainform.ImageList.Items.Find('Background-Planet1');
      Width := Image.Width;
      Height := Image.Height;

      Y := random(mainform.dxdraw.height);
      X := mainform.dxdraw.width;

      ran := Random(2);
      if ran = 0 then
      begin
        Z := -20;
        FSpeed := 1.8;
      end
      else if ran = 1 then
      begin
        Z := -40;
        FSpeed := 0.8;
      end
      else if ran = 2 then
      begin
        Z := -60;
        FSpeed := 0.3;
      end;
    end;
  end
  else if ran = 500 then
  begin
    with TBackgroundSpecial.Create(mainform.SpriteEngine.Engine) do
    begin
      SetMapSize(1, 1);
      ran := Random(4);
      if ran = 0 then
        Image := mainform.ImageList.Items.Find('Background-Red')
      else if ran = 1 then
        Image := mainform.ImageList.Items.Find('Background-Blue')
      else if ran = 2 then
        Image := mainform.ImageList.Items.Find('Background-Yellow')
      else if ran = 3 then
        Image := mainform.ImageList.Items.Find('Hintergrund-Rot');
      Width := Image.Width;
      Height := Image.Height;

      Y := random(mainform.dxdraw.height);
      X := mainform.dxdraw.width;

      { ran := Random(2);
      if ran = 0 then
      begin
        Z := -20;
        FSpeed := 1.8;
      end
      else if ran = 1 then
      begin
        Z := -40;
        FSpeed := 0.8;
      end
      else if ran = 2 then
      begin }
        Z := -60;
        FSpeed := 0.3;
      { end; }
    end;
  end;
end;

procedure TBackgroundSpecial.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  X := X - MoveCount*(60/1000)*FSpeed;
  if X<-Width then Dead;
end;

constructor TExplosion.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  mainform.PlaySound('Explosion', false);
  Image := MainForm.ImageList.Items.Find('Explosion');
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

constructor TEnemyTama.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  Image := MainForm.ImageList.Items.Find('Bounce2');
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  MainForm.PlaySound('Shoot', False);
end;

procedure TEnemyTama.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  X := X - MoveCount*(600/1000);
  if X<-Width then Dead;
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
    MainForm.PlaySound('Explosion', False)
  else
    MainForm.PlaySound('Hit', False);
end;

constructor TEnemyUFO.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  Image := MainForm.ImageList.Items.Find('Enemy-disk');
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
end;

constructor TEnemy.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent);
  FLife := ALifes;
  inc(EnemyCounter);
end;

destructor TEnemy.Destroy;
begin
  inherited Destroy;
  dec(EnemyCounter);
end;

procedure TEnemyUFO.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FMode := 2;
    FCounter := 0;
    Inc(MainForm.FScore, 1000);
    Image := MainForm.ImageList.Items.Find('Explosion');
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
  if FMode=0 then
  begin
    X := X - MoveCount*(300/1000);
    Y := Y + Cos256(FCounter div 15)*2;
    if X<-Width then Dead;
    if FCounter-FOldTamaTime>=100 then
    begin
      Inc(FTamaCount);
      with TEnemyTama.Create(Engine) do
      begin
        FPlayerSprite := Self;
        X := Self.X;
        Y := Self.Y+Self.Height div 2-Height div 2;
        Z := 10;
      end;
      FOldTamaTime := FCounter;
    end;
  end
  else if FMode=2 then
  begin
    X := X - MoveCount*(300/1000);
    if FCounter>200 then Dead;
  end;
  inc(FCounter, MoveCount);
end;

procedure TEnemyUFO2.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FMode := 2;
    FCounter := 0;
    Inc(MainForm.FScore, 1000);
    Image := MainForm.ImageList.Items.Find('Explosion');
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

constructor TEnemyUFO2.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  Image := MainForm.ImageList.Items.Find('Enemy-disk2');
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
end;

procedure TEnemyUFO.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  if FMode=0 then
  begin
    X := X - MoveCount*(300/1000);
    Y := Y + Cos256(FCounter div 15)*2;
    if X<-Width then Dead;
  end
  else if FMode=2 then
  begin
    X := X - MoveCount*(300/1000);
    if FCounter>200 then Dead;
  end;
  inc(FCounter, MoveCount);
end;

constructor TEnemyAttacker.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  Image := MainForm.ImageList.Items.Find('Enemy-Attacker');
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
    FMode := 2;
    FCounter := 0;
    Inc(MainForm.FScore, 1000);
    Image := MainForm.ImageList.Items.Find('Explosion');
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
  if FMode=0 then
  begin
    X := X - MoveCount*(300/1000)-FCounter div 128;
    if X < -Width then Dead;
  end
  else if FMode=2 then
  begin
    X := X - MoveCount*(300/1000);
    if FCounter>200 then Dead;
  end;
  inc(FCounter, MoveCount);
end;

constructor TEnemyBoss.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  Image := MainForm.ImageList.Items.Find('Enemy-boss');
  Width := Image.Width;
  Height := Image.Height;
  BossExists := true;
  MainForm.PlayMusic(mtBoss);
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
  Collisioned := False;
  MainForm.FBossLife := FLife;
  waiter1 := 0;
  waiter2 := 0;
end;

procedure TEnemyBoss.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FMode := 2;
    FCounter := 0;
    Inc(MainForm.FScore, 100000);
    BossExists := false;
    dec(MainForm.FBossLife);
  end
  else
  begin
    Inc(MainForm.FScore, 100);
    dec(MainForm.FBossLife);
  end;
end;

procedure TEnemyBoss.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);
  if FMode=0 then
  begin
    if X>((mainform.dxdraw.width/4) + (mainform.dxdraw.width/2) - (width/4)){450} then
      X := X - MoveCount*(300/1000)
    else
    begin
      Collisioned := True;
      FMode := 1;
      FPutTama := True;
    end;
    Y := Y + Cos256(FCounter div 15)*5;
  end
  else if FMode=1 then
  begin
    Y := Y + Cos256(FCounter div 15)*5;
    if FPutTama then
    begin
      if FTamaT>100 then
      begin
        with TEnemyTama.Create(Engine) do
        begin
          FPlayerSprite := Self;
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
  else if FMode=2 then
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
        Inc(MainForm.FScore, 1000);
        FMode := 3;
      end;
    end;
  end
  else if FMode=3 then
  begin
    if FCounter>4000 then Dead;
  end;
  inc(FCounter, MoveCount);
end;

constructor TEnemyAttacker2.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  Image := MainForm.ImageList.Items.Find('Enemy-Attacker2');
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
    FMode := 2;
    FCounter := 0;
    Inc(MainForm.FScore, 5000);
    Image := MainForm.ImageList.Items.Find('Explosion');
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
  if FMode=0 then
  begin
    if X>((mainform.dxdraw.width/4) + (mainform.dxdraw.width/2) - (width/2)){450} then
      X := X - MoveCount*(300/1000)
    else
    begin
      Collisioned := True;
      FMode := 1;
      FPutTama := True;
    end;
    Y := Y + Cos256(FCounter div 15)*5;
  end
  else if FMode=1 then
  begin
    Y := Y + Cos256(FCounter div 15)*5;
    if FPutTama then
    begin
      if FTamaT>100 then
      begin
        with TEnemyTama.Create(Engine) do
        begin
          FPlayerSprite := Self;
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
  else if FMode=2 then
  begin
    if FCounter>200 then Dead;
  end;
  inc(FCounter, MoveCount);
end;

procedure TEnemyAttacker3.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(ADead);

  if ADead then
  begin
    FMode := 1;
    FCounter := 0;
    Inc(MainForm.FScore, 5000);
    Image := MainForm.ImageList.Items.Find('Explosion');
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
  if FMode=0 then
  begin
    X := X - (250/1000)*MoveCount;
    if X<-Width then Dead;
    if FCounter-FOldTamaTime>=100 then
    begin
      Inc(FTamaCount);
      with TEnemyTama.Create(Engine) do
      begin
        FPlayerSprite := Self;
        X := Self.X;
        Y := Self.Y+Self.Height div 2-Height div 2;
        Z := 10;
      end;
      FOldTamaTime := FCounter;
     end;
  end
  else if FMode=1 then
  begin
    if FCounter>200 then Dead;
  end;
  inc(FCounter, MoveCount);
end;

constructor TEnemyAttacker3.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  Image := MainForm.ImageList.Items.Find('Enemy-Attacker3');
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  SavGame: TSaveData;
begin
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
  dxdraw.Width := 640;
  dxdraw.Height := 480;
  dxdraw.AutoInitialize := False;
  dxdraw.AutoSize := False;
  dxdraw.Color := clBlack;
  dxdraw.Display.BitCount := 24;
  dxdraw.Display.FixedBitCount := False;
  dxdraw.Display.FixedRatio := False;
  dxdraw.Display.FixedSize := False;
  dxdraw.Display.Height := 600;
  dxdraw.Display.Width := 800;
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

  Application.Title := 'SpaceMission '+ProgramVersion;
  LoadOptions;
  DXInit;
  SoundInit;
  MusicInit;
  ResetLevelData;
  if (paramcount = 0) and (fileexists(paramstr(1))) then // (paramcount > 0)
  begin
    SavGame := TSaveData.Create;
    try
      try
        SavGame.Load(paramstr(1));
        mainform.FScore := SavGame.FScore;
        mainform.FLife := SavGame.FLife;
        mainform.FLevel := SavGame.FLevel;
        mainform.FGameMode := SavGame.FGameMode;
      except
        showmessage(FileError);
        GameStartClick(GameStart);
        exit;
      end;
    finally
      FreeAndNil(SavGame);
    end;
    mainform.FNextScene := gsNewLevel;
    exit;
  end;
  GameStartClick(GameStart);
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssAlt in Shift) and (Key=VK_RETURN) then
    OptionFullScreenClick(OptionFullScreen);
end;

procedure TMainForm.GameStartClick(Sender: TObject);
begin
  StartScene(gsTitle);
end;

procedure TMainForm.GamePauseClick(Sender: TObject);
begin
  GamePause.Checked := not GamePause.Checked;
  DXTimer.Enabled := not GamePause.Checked;
  if GamePause.Checked then
    PauseMusic(FMusic)
  else
    ResumeMusic(FMusic);
end;

// http://www.delphipraxis.net/post43515.html
Function GetHTML(AUrl: string): string;
var
  databuffer : array[0..4095] of char;
  ResStr : string;
  hSession, hfile: hInternet;
  dwindex,dwcodelen,dwread,dwNumber: cardinal;
  dwcode : array[1..20] of char;
  res    : pchar;
  Str    : pchar;
begin
  ResStr:='';
  if system.pos('http://',lowercase(AUrl))=0 then
     AUrl:='http://'+AUrl;

  // Hinzugefügt
  application.ProcessMessages;

  hSession:=InternetOpen('InetURL:/1.0',
                         INTERNET_OPEN_TYPE_PRECONFIG,
                         nil,
                         nil,
                         0);
  if assigned(hsession) then
  begin
    // Hinzugefügt
    application.ProcessMessages;

    hfile:=InternetOpenUrl(
           hsession,
           pchar(AUrl),
           nil,
           0,
           INTERNET_FLAG_RELOAD,
           0);
    dwIndex  := 0;
    dwCodeLen := 10;

    // Hinzugefügt
    application.ProcessMessages;

    HttpQueryInfo(hfile,
                  HTTP_QUERY_STATUS_CODE,
                  @dwcode,
                  dwcodeLen,
                  dwIndex);
    res := pchar(@dwcode);
    dwNumber := sizeof(databuffer)-1;
    if (res ='200') or (res ='302') then
    begin
      while (InternetReadfile(hfile,
                              @databuffer,
                              dwNumber,
                              DwRead)) do
      begin

        // Hinzugefügt
        application.ProcessMessages;

        if dwRead =0 then
          break;
        databuffer[dwread]:=#0;
        Str := pchar(@databuffer);
        resStr := resStr + Str;
      end;
    end
    else
      ResStr := 'Status:'+res;
    if assigned(hfile) then
      InternetCloseHandle(hfile);
  end;

  // Hinzugefügt
  application.ProcessMessages;

  InternetCloseHandle(hsession);
  Result := resStr; 
end;

procedure TMainForm.CheckUpdatesClick(Sender: TObject);
var
  cont: string;
begin
  cont := GetHTML('http://www.viathinksoft.de/update/?id=spacemission');
  if copy(cont, 0, 7) = 'Status:' then
  begin
    Application.MessageBox('Ein Fehler ist aufgetreten. Wahrscheinlich ist keine Internetverbindung aufgebaut, oder der der ViaThinkSoft-Server vorübergehend offline.', 'Fehler', MB_OK + MB_ICONERROR)
  end
  else
  begin
    if GetHTML('http://www.viathinksoft.de/update/?id=spacemission') <> ProgramVersion then
    begin
      if Application.MessageBox('Eine neue Programmversion ist vorhanden. Möchten Sie diese jetzt herunterladen?', 'Information', MB_YESNO + MB_ICONASTERISK) = ID_YES then
        shellexecute(application.handle, 'open', pchar('http://www.viathinksoft.de/update/?id=@spacemission'), '', '', sw_normal);
    end
    else
    begin
      Application.MessageBox('Es ist keine neue Programmversion vorhanden.', 'Information', MB_OK + MB_ICONASTERISK);
    end;
  end;
end;

procedure TMainForm.BeendenClick(Sender: TObject);
begin
  close;
end;

procedure TMainForm.OptionFullScreenClick(Sender: TObject);
begin
  OptionFullScreen.Checked := not OptionFullScreen.Checked;
  DXInit;
  writeoptions;
end;

procedure TMainForm.OptionSoundClick(Sender: TObject);
begin
  OptionSound.Checked := not OptionSound.Checked;
  SoundInit;
  WriteOptions;
end;

procedure TMainForm.SoundInit;
begin
  if OptionSound.Checked then
  begin
    if not DXSound.Initialized then
    begin
      try
        DXSound.Initialize;
        WaveList.Items.LoadFromFile(FDirectory+'DirectX\Sound.dxw');
      except
        OptionSound.enabled := False;
        WaveList.items.clear;
      end;
    end;
  end
  else DXSound.Finalize;
end;

procedure TMainForm.MusicInit;
begin
  try
    dxmusic.Midis.LoadFromFile(FDirectory+'DirectX\Music.dxm');
  except
    optionmusic.enabled := false;
  end;
end;

procedure TMainForm.DestroyMusic(Name: TMusicTrack);
begin
  if Name = mtNone then exit;
  dxmusic.Midis.Items[Ord(Name)-1].Stop;
end;

procedure TMainForm.OpenMusic(Name: TMusicTrack);
begin
  // Nothing to do
end;

procedure TMainForm.PauseMusic(Name: TMusicTrack);
begin
  if Name = mtNone then exit;
  dxmusic.Midis.Items[Ord(Name)-1].Stop;
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
  DXTimer.Enabled := True;
end;

procedure TMainForm.DXDrawFinalize(Sender: TObject);
begin
  DXTimer.Enabled := False;
end;

procedure TMainForm.DXTimerActivate(Sender: TObject);
begin
  Caption := Application.Title;
  if not ProgrammGestartet then
  begin
    Programmgestartet := true;
    exit;
  end;
  ResumeMusic(FMusic);
end;

procedure TMainForm.DXTimerDeactivate(Sender: TObject);
begin
  Caption := Application.Title + ' [Pause]';
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
  INIDatei: TIniFile;
begin
  INIDatei := TIniFile.Create(FDirectory+'Einstellungen\SpaceMission.ini');
  try
    if OptionMusic.checked then INIDatei.WriteBool('Settings', 'Music', true)
      else INIDatei.WriteBool('Settings', 'Music', false);
    if OptionSound.checked then INIDatei.WriteBool('Settings', 'Sound', true)
      else INIDatei.WriteBool('Settings', 'Sound', false);
    if OptionFullScreen.checked then INIDatei.WriteBool('Settings', 'FullScreen', true)
      else INIDatei.WriteBool('Settings', 'FullScreen', false);
    if OptionBreitbild.checked then INIDatei.WriteBool('Settings', 'ScreenAutoSize', true)
      else INIDatei.WriteBool('Settings', 'ScreenAutoSize', false);
    if FInterval = giLeicht then INIDatei.WriteInteger('Settings', 'Speed', 1);
    if FInterval = giMittel then INIDatei.WriteInteger('Settings', 'Speed', 2);
    if FInterval = giSchwer then INIDatei.WriteInteger('Settings', 'Speed', 3);
    if FInterval = giMaster then INIDatei.WriteInteger('Settings', 'Speed', 4);
  finally
    INIDatei.Free;
  end;
end;

procedure TMainForm.LoadOptions;
var
  INIDatei: TIniFile;
begin
  INIDatei := TIniFile.Create(FDirectory+'Einstellungen\SpaceMission.ini');
  try
    optionmusic.checked := INIDatei.ReadBool('Settings', 'Music', true);
    optionsound.checked := INIDatei.ReadBool('Settings', 'Sound', true);
    optionfullscreen.checked := INIDatei.ReadBool('Settings', 'fullscreen', false);
    OptionBreitBild.checked := INIDatei.ReadBool('Settings', 'ScreenAutoSize', true);
    if INIDatei.ReadInteger('Settings', 'Speed', 2) = 1 then
    begin
      FInterval := giLeicht;
      Leicht.checked := true;
    end;
    if INIDatei.ReadInteger('Settings', 'Speed', 2) = 2 then
    begin
      FInterval := giMittel;
      Mittel.checked := true;
    end;
    if INIDatei.ReadInteger('Settings', 'Speed', 2) = 3 then
    begin
      FInterval := giSchwer;
      Schwer.checked := true;
    end;
    if INIDatei.ReadInteger('Settings', 'Speed', 2) = 4 then
    begin
      FInterval := giMaster;
      Master.checked := true;
    end;
  finally
    INIDatei.Free;
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

procedure TMainForm.PlaySound(Name: string; Wait: Boolean);
begin
  if (OptionSound.Checked) and (OptionSound.Enabled) then
    WaveList.Items.Find(Name).Play(Wait);
end;

procedure TMainForm.PlayMusic(Name: TMusicTrack);
begin
  if (not mainform.active) and (mainform.visible) then //1st Programmstart
    exit;
  if (OptionMusic.checked) and (OptionMusic.enabled) then
  begin
    DestroyMusic(FMusic);
    OpenMusic(Name);
    ResumeMusic(Name);
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
  FCheat := false;
  BossExists := false;
  FLife := Lives;
  FLevel := 0;
  FScore := 0;
  FNotSave := true;
  Cheat.enabled := false;
  Neustart.enabled := false;
  GamePause.enabled := false;
  GameStart.enabled := false;
  Spielgeschwindigkeit.enabled := false;
  mainform.Visible := true;
  PlayMusic(mtTitle);
end;

procedure TMainForm.StartSceneMain;
{var
  i, j: Integer;}
begin
  sleep(500);
  FCounter := 0;
  NewLevel(FLevel);
  BossExists := false;
  PlayMusic(mtGame);
  FEnemyAdventPos := 0;
  FFrame := -4;
  PlayerSprite := TPlayerSprite.Create(SpriteEngine.Engine);
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := mainform.ImageList.Items.Find('Star3');
    Z := -13;
    Y := 40;
    FSpeed := 1 / 2;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := mainform.ImageList.Items.Find('Star2');
    Z := -12;
    Y := 30;
    FSpeed := 1;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := mainform.ImageList.Items.Find('Star1');
    Z := -11;
    Y := 10;
    FSpeed := 2;
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
  FNotSave := true;
  Cheat.enabled := false;
  Spielgeschwindigkeit.enabled := false;
  Neustart.enabled := false;
  GamePause.enabled := false;
  PlayMusic(mtScene);
  BossExists := false;
end;

procedure TMainForm.StartSceneWin;
begin
  sleep(500);
  FNotSave := true;
  Cheat.enabled := false;
  Spielgeschwindigkeit.enabled := false;
  Neustart.enabled := false;
  GamePause.enabled := false;
  PlayMusic(mtScene);
  BossExists := false;
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

const
  ADDITIONAL_ENEMIES_PER_LEVEL = 75;

procedure TMainForm.NewLevel(lev: integer);
resourcestring
  LNG_LEVEL_INVALID = 'Das Level Nr. %d ist ungültig!'+#13#10+'Das Programm wird beendet.';
var
  act: integer;
  Enemies: array[1..27] of TEnemyType;
  e: TEnemyAdvent;
begin
  ResetLevelData;
  if FGameMode = gmRandom then
  begin
    {$REGION 'Random game'}
    Enemies[1] := etEnemyAttacker;
    Enemies[2] := etEnemyMeteor;
    Enemies[3] := etEnemyUFO;
    Enemies[4] := etEnemyAttacker;
    Enemies[5] := etEnemyMeteor;
    Enemies[6] := etEnemyUFO;
    Enemies[7] := etEnemyAttacker;
    Enemies[8] := etEnemyMeteor;
    Enemies[9] := etEnemyUFO;
    Enemies[10] := etEnemyAttacker;
    Enemies[11] := etEnemyMeteor;
    Enemies[12] := etEnemyUFO;
    Enemies[13] := etEnemyAttacker;
    Enemies[14] := etEnemyMeteor;
    Enemies[15] := etEnemyUFO;
    Enemies[16] := etEnemyAttacker3;
    Enemies[17] := etEnemyAttacker;
    Enemies[18] := etEnemyMeteor;
    Enemies[19] := etEnemyUFO;
    Enemies[20] := etEnemyUFO2;
    Enemies[21] := etEnemyAttacker;
    Enemies[22] := etEnemyMeteor;
    Enemies[23] := etEnemyUFO;
    Enemies[24] := etEnemyAttacker2;
    Enemies[25] := etEnemyMeteor;
    Enemies[26] := etEnemyUFO;
    Enemies[27] := etEnemyAttacker;
    randomize;
    FRestEnemies := lev*ADDITIONAL_ENEMIES_PER_LEVEL+1;
    SetLength(LevelData.EnemyAdventTable, FRestEnemies);
    for act := 0 to lev*ADDITIONAL_ENEMIES_PER_LEVEL-1 do
    begin
      e.enemyType := Enemies[min(random(lev+2)+1, High(Enemies))];
      if e.enemyType = etEnemyAttacker2 then
      begin
        e.enemyType := Enemies[min(random(lev+2)+1, High(Enemies))]; {O_o}
      end;
      e.x := act*30 + random(85-(lev+(random(lev))*2)){O_o};
      e.y := random(dxdraw.surfaceheight);
      if e.enemyType = etEnemyAttacker2 then
      begin
        e.lifes := random(6)+1{O_o};
      end
      else
      begin
        e.lifes := random(lev)+1;
      end;

      LevelData.EnemyAdventTable[act] := e;
    end;
    e.enemyType := etEnemyBoss;
    e.x := lev*75*30{O_o} div lev;
    e.y := (dxdraw.surfaceheight div 2) - (MainForm.ImageList.Items.Find('Enemy-boss').height div 2);
    e.lifes := lev*5;
    LevelData.EnemyAdventTable[lev*ADDITIONAL_ENEMIES_PER_LEVEL] := e;
    Assert(FRestEnemies = Length(LevelData.EnemyAdventTable));
    {$ENDREGION}
  end
  else
  begin
    {$REGION 'Normal game'}
    if fileexists(GetLevelFileName(lev)) then
    begin
      try
        LevelData.Load(GetLevelFileName(lev));
        FRestEnemies := Length(LevelData.EnemyAdventTable);
      except
        showmessage(Format(LNG_LEVEL_INVALID, [lev]));
        ResetLevelData;
      end;
    end;
    {$ENDREGION}
  end;
end;

procedure TMainForm.SceneTitle;
var
  Logo: TPictureCollectionItem;
begin
  DXDraw.Surface.Fill(0);
  Logo := ImageList.Items.Find('Logo');
  {Logo.DrawWaveX(DXDraw.Surface, (dxdraw.surfaceWidth div 2) - 181, 65, Logo.Width, Logo.Height, 0,
    Trunc(16 - Cos256(FBlink div 60) * 16), 32, -FBlink div 5);}
  Logo.DrawWaveX(DXDraw.Surface, trunc((dxdraw.surfaceWidth / 2) - (Logo.Width / 2)), 65, Logo.Width, Logo.Height, 0,
    2, 80, Fangle * 4);
  inc(Fangle);
  with DXDraw.Surface.Canvas do
  begin
    if (isDown in MainForm.DXInput.States) and (FGameMode=gmLevels) then FGameMode := gmRandom;
    if ((isUp in MainForm.DXInput.States) and (FGameMode=gmRandom)) or (FGameMode=gmUnknown) then FGameMode := gmLevels;
    Brush.Style := bsClear;
    Font.Size := 30;
    if FGameMode = gmLevels then
    begin
      Font.Color := clMaroon;
      Textout((dxdraw.surfaceWidth div 2)-152, (dxdraw.surfaceheight div 2)-52, 'Normales Spiel');
      Textout((dxdraw.surfaceWidth div 2)-187, (dxdraw.surfaceheight div 2)-52, '>');
      Font.Color := clRed;
      Textout((dxdraw.surfaceWidth div 2)-150, (dxdraw.surfaceheight div 2)-50, 'Normales Spiel');
      Textout((dxdraw.surfaceWidth div 2)-185, (dxdraw.surfaceheight div 2)-50, '>');
      Font.Color := clOlive;
      Textout((dxdraw.surfaceWidth div 2)-152, (dxdraw.surfaceheight div 2)-2, 'Zufallslevel');
      Font.Color := clYellow;
      Textout((dxdraw.surfaceWidth div 2)-150, (dxdraw.surfaceheight div 2), 'Zufallslevel');
    end
    else
    begin
      Font.Color := clOlive;
      Textout((dxdraw.surfaceWidth div 2)-152, (dxdraw.surfaceheight div 2)-52, 'Normales Spiel');
      Font.Color := clYellow;
      Textout((dxdraw.surfaceWidth div 2)-150, (dxdraw.surfaceheight div 2)-50, 'Normales Spiel');
      Font.Color := clMaroon;
      Textout((dxdraw.surfaceWidth div 2)-152, (dxdraw.surfaceheight div 2)-2, 'Zufallslevel');
      Textout((dxdraw.surfaceWidth div 2)-187, (dxdraw.surfaceheight div 2)-2, '>');
      Font.Color := clRed;
      Textout((dxdraw.surfaceWidth div 2)-150, (dxdraw.surfaceheight div 2), 'Zufallslevel');
      Textout((dxdraw.surfaceWidth div 2)-185, (dxdraw.surfaceheight div 2), '>');
    end;
    { if (FBlink div 300) mod 2=0 then
    begin
      Font.Color := clGreen;
      Textout((dxdraw.surfaceWidth div 2)-187, dxdraw.surfaceheight-117, 'Weiter mit Leertaste');
      Font.Color := clLime;
      Textout((dxdraw.surfaceWidth div 2)-185, dxdraw.surfaceheight-115, 'Weiter mit Leertaste');
    end; }
    BlinkUpdate;
    Release;
  end;
  // Weiter mit Leertaste oder Enter
  if (isButton1 in DXInput.States) or (isButton2 in DXInput.States) then
  begin
    FLevel := 1;
    if ((FGameMode=gmLevels) and not fileexists(GetLevelFileName(FLevel))) or ((FGameMode=gmRandom) and (FLevel > 20)) then
    begin
      //PlaySound('Frage', False);
      exit;
    end;
    NewLevel(FLevel);
    PlaySound('SceneMov', False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsMain);
  end;
end;

procedure TMainForm.SceneMain;
var
  Enemy: TSprite;
  spriteClass: TEnemyClass;
begin
  case FInterval of
    giMittel: SpriteEngine.Move(conleicht);
    giLeicht: SpriteEngine.Move(conmittel);
    giSchwer: SpriteEngine.Move(conschwer);
    giMaster: SpriteEngine.Move(conmaster);
  end;
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
      end;
      if spriteClass <> nil then
      begin
        Enemy := spriteClass.Create(SpriteEngine.Engine, lifes);
        Enemy.x := dxdraw.surfacewidth;
        //Enemy.y := y;
        if y <> 0 then
          Enemy.y := dxdraw.surfaceheight / (480{maximale Bandbreite im alten Format} / y)
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
    if MainForm.flife > 0 then
    begin
      with DXDraw.Surface.Canvas do
      begin
        Brush.Style := bsClear;
        Font.Size := 20;
        Font.Color := clOlive;
        Textout(9, 9, 'Punkte: ' + FloatToStrF(FScore,ffNumber,14,0));
        Font.Color := clYellow;
        Textout(10, 10, 'Punkte: ' + FloatToStrF(FScore,ffNumber,14,0));
        Font.Color := clMaroon;
        Textout(dxdraw.surfacewidth-141, 9, 'Level: ' + IntToStr(MainForm.flevel));
        Font.Color := clRed;
        Textout(dxdraw.surfacewidth-140, 10, 'Level: ' + IntToStr(MainForm.flevel));
        if FLife<0 then mainform.FLife := 0;
        if FCheat then
        begin
          Font.Color := clPurple;
          Textout(9, dxdraw.surfaceheight-41, 'Leben: ?');
          Font.Color := clFuchsia;
          Textout(10, dxdraw.surfaceheight-40, 'Leben: ?');
        end
        else
        begin
          if ((Flife = 1) and ((FBlink div 300) mod 2=0)) or (Flife <> 1) then
          begin
            Font.Color := clPurple;
            Textout(9, dxdraw.surfaceheight-41, 'Leben: ' + IntToStr(MainForm.flife));
            Font.Color := clFuchsia;
            Textout(10, dxdraw.surfaceheight-40, 'Leben: ' + IntToStr(MainForm.flife));
          end;
          if Flife = 1 then BlinkUpdate;
        end;
        {if BossExists and (FBossLife>0) then
        begin
          Font.Color := clPurple;
          Textout(449, 439, 'Boss: ' + IntToStr(FBossLife));
          Font.Color := clFuchsia;
          Textout(450, 440, 'Boss: ' + IntToStr(FBossLife));
        end
        else
          if RestlicheEinheiten>0 then
          begin
            Font.Color := clPurple;
            Textout(449, 439, 'Einheiten: ' + IntToStr(RestlicheEinheiten));
            Font.Color := clFuchsia;
            Textout(450, 440, 'Einheiten: ' + IntToStr(RestlicheEinheiten));
          end;}
        if BossExists and (FBossLife>0) then
        begin
          if (FRestEnemies>0) then
          begin
            Font.Color := clGreen;
            Textout(dxdraw.surfacewidth-191, dxdraw.surfaceheight-81, 'Boss: ' + IntToStr(FBossLife));
            Textout(dxdraw.surfacewidth-191, dxdraw.surfaceheight-41, 'Einheiten: ' + IntToStr(FRestEnemies));
            Font.Color := clLime;
            Textout(dxdraw.surfacewidth-190, dxdraw.surfaceheight-80, 'Boss: ' + IntToStr(FBossLife));
            Textout(dxdraw.surfacewidth-190, dxdraw.surfaceheight-40, 'Einheiten: ' + IntToStr(FRestEnemies));
          end;
          if (FRestEnemies<1) then
          begin
            Font.Color := clGreen;
            Textout(dxdraw.surfacewidth-191, dxdraw.surfaceheight-41, 'Boss: ' + IntToStr(FBossLife));
            Font.Color := clLime;
            Textout(dxdraw.surfacewidth-190, dxdraw.surfaceheight-40, 'Boss: ' + IntToStr(FBossLife));
          end;
        end;
        if (FRestEnemies>0) and not Bossexists then
        begin
          Font.Color := clGreen;
          Textout(dxdraw.surfacewidth-191, dxdraw.surfaceheight-41, 'Einheiten: ' + IntToStr(FRestEnemies));
          Font.Color := clLime;
          Textout(dxdraw.surfacewidth-190, dxdraw.surfaceheight-40, 'Einheiten: ' + IntToStr(FRestEnemies));
        end;
        Release;
      end;
    end
    else
    begin
      DXDraw.Surface.Canvas.Font.Color := clGreen; // Grüne schrift bei gescheitert? FIXME
      DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-251, dxdraw.surfaceheight-41, 'Mission gescheitert!');
      DXDraw.Surface.Canvas.Font.Color := clLime;
      DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-250, dxdraw.surfaceheight-40, 'Mission gescheitert!');
      DXDraw.Surface.Canvas.Release;
    end;
    if (EnemyCounter=0) and (FRestEnemies=0){ and (SpielerFliegtFort = false)}
    and ((BossExists and (FBossLife=0)) or not BossExists) then
    begin
      DXDraw.Surface.Canvas.Font.Color := clGreen;
      DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-251, dxdraw.surfaceheight-41, 'Mission erfolgreich!');
      DXDraw.Surface.Canvas.Font.Color := clLime;
      DXDraw.Surface.Canvas.Textout(dxdraw.surfacewidth-250, dxdraw.surfaceheight-40, 'Mission erfolgreich!');
      DXDraw.Surface.Canvas.Release;
      Sleep(1);
      inc(FCounter);
      if FCounter>150{200} then PlayerSprite.FlyAway;
    end;
  end;
end;

procedure TMainForm.SceneGameOver;
begin
  DXDraw.Surface.Fill(0);
  with DXDraw.Surface.Canvas do
  begin
    FNotSave := true;
    Cheat.enabled := false;
    GamePause.enabled := false;
    Neustart.enabled := false;
    Brush.Style := bsClear;
    Font.Size := 35;
    Font.Color := clMaroon;
    Textout((dxdraw.surfacewidth div 2)-127, 98, 'Game Over!');
    Font.Color := clRed;
    Textout((dxdraw.surfacewidth div 2)-125, 100, 'Game Over!');
    if (FBlink div 300) mod 2=0 then
    begin
      Font.Size := 30;
      Font.Color := clOlive;
      Textout((dxdraw.surfaceWidth div 2)-187, dxdraw.surfaceheight-117, 'Weiter mit Leertaste');
      Font.Color := clYellow;
      Textout((dxdraw.surfaceWidth div 2)-185, dxdraw.surfaceheight-115, 'Weiter mit Leertaste');
    end;
    BlinkUpdate;
    Release;
  end;
  if isButton1 in DXInput.States then
  begin
    PlaySound('SceneMov', False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsTitle);
  end;
end;

procedure TMainForm.SceneWin;
begin
  DXDraw.Surface.Fill(0);
  with DXDraw.Surface.Canvas do
  begin
    FNotSave := true;
    Cheat.enabled := false;
    GamePause.enabled := false;
    Neustart.enabled := false;
    Brush.Style := bsClear;
    Font.Size := 35;
    Font.Color := clMaroon;
    Textout((dxdraw.surfaceWidth div 2)-127, 98, 'Gewonnen!');
    Font.Color := clRed;
    Textout((dxdraw.surfaceWidth div 2)-125, 100, 'Gewonnen!');
    if (FBlink div 300) mod 2=0 then
    begin
      Font.Size := 30;
      Font.Color := clOlive;
      Textout((dxdraw.surfaceWidth div 2)-187, dxdraw.surfaceheight-117, 'Weiter mit Leertaste');
      Font.Color := clYellow;
      Textout((dxdraw.surfaceWidth div 2)-185, dxdraw.surfaceheight-115, 'Weiter mit Leertaste');
    end;
    BlinkUpdate;
    Release;
  end;
  if isButton1 in DXInput.States then
  begin
    PlaySound('SceneMov', False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsTitle);
  end;
end;

procedure TMainForm.StartSceneNewLevel;
begin
  sleep(500);
  FNotSave := false;
  Cheat.enabled := false;
  Neustart.enabled := false;
  GamePause.enabled := false;
  GameStart.enabled := true;
  Spielgeschwindigkeit.enabled := false;
  BossExists := false;
  Spielgeschwindigkeit.enabled := false;
  if ((FGameMode=gmLevels) and (not fileexists(GetLevelFileName(FLevel)))) or ((FGameMode=gmRandom) and (FLevel > 25)) then
  begin
    //PlaySound('SceneMov', False);
    PalleteAnim(RGBQuad(0, 0, 0), 300);
    Sleep(200);
    StartScene(gsWin);
    exit;
  end;
  PlayMusic(mtScene);
end;

procedure TMainForm.EndSceneNewLevel;
begin
  {  Ende NewLevel  }
end;

procedure TMainForm.SceneNewLevel;
begin
  DXDraw.Surface.Fill(0);
  with DXDraw.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Size := 40;
    Font.Color := clMaroon;
    Textout((dxdraw.surfaceWidth div 2)-(83+(length(inttostr(flevel))*22)), 98, 'Level '+inttostr(flevel));
    Font.Color := clRed;
    Textout((dxdraw.surfaceWidth div 2)-(81+(length(inttostr(flevel))*22)), 100, 'Level '+inttostr(flevel));
    if (FBlink div 300) mod 2=0 then
    begin
      Font.Size := 30;
      Font.Color := clOlive;
      Textout((dxdraw.surfaceWidth div 2)-187, dxdraw.surfaceheight-117, 'Weiter mit Leertaste');
      Font.Color := clYellow;
      Textout((dxdraw.surfaceWidth div 2)-185, dxdraw.surfaceheight-115, 'Weiter mit Leertaste');
    end;
    BlinkUpdate;
    Release;
  end;
  if isButton1 in DXInput.States then
  begin
    PlaySound('SceneMov', False);
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
    PlayMusic(FMusic)
  end
  else
  begin
    DestroyMusic(FMusic);
  end;
  WriteOptions;
end;

procedure TMainForm.MasterClick(Sender: TObject);
begin
  master.checked := true;
  FInterval := giMaster;
  writeoptions;
end;

procedure TEnemyMeteor.DoMove(MoveCount: Integer);
begin
  X := X - MoveCount*(250/1000);
  if X < -Width then Dead;
end;

procedure TEnemyMeteor.HitEnemy(ADead: Boolean);
begin
  inherited HitEnemy(False);

  if ADead then Collisioned := True;
end;

{procedure TMainForm.StopMusic;
begin
  PauseMusic(FMusic);
  MCISendString(pchar('seek "'+FDirectory+'Musik\Boss.mid" to start'), nil, 255, 0);
  MCISendString(pchar('seek "'+FDirectory+'Musik\Game.mid" to start'), nil, 255, 0);
  MCISendString(pchar('seek "'+FDirectory+'Musik\Title.mid" to start'), nil, 255, 0);
  MCISendString(pchar('seek "'+FDirectory+'Musik\Scene.mid" to start'), nil, 255, 0);
end;}

procedure TMainForm.ResumeMusic(Name: TMusicTrack);
begin
  if not OptionMusic.checked then exit;
  dxmusic.Midis.Items[Ord(Name)-1].Play;
end;

constructor TEnemyMeteor.Create(AParent: TSprite; ALifes: integer);
begin
  inherited Create(AParent, ALifes);
  Image := MainForm.ImageList.Items.Find('Enemy-Meteor');
  Width := Image.Width;
  Height := Image.Height;
  AnimCount := Image.PatternCount;
  AnimLooped := True;
  AnimSpeed := DEFAULT_ANIMSPEED;
  PixelCheck := True;
end;

procedure TMainForm.SpielstandClick(Sender: TObject);
begin
  speicherungform.showmodal;
end;

procedure TMainForm.NeustartClick(Sender: TObject);
begin
  FLife := Lives;
  FLevel := 1; // ???
  FScore := 0;
  EnemyCounter := 0;
  StartScene(gsMain);
  PlayMusic(mtGame);
end;

procedure TMainForm.OptionBreitbildClick(Sender: TObject);
begin
  OptionBreitbild.Checked := not OptionBreitbild.Checked;
  DXInit;
  writeoptions;
end;

procedure TMainForm.LeichtClick(Sender: TObject);
begin
  leicht.checked := true;
  FInterval := giLeicht;
  writeoptions;
end;

procedure TMainForm.MittelClick(Sender: TObject);
begin
  mittel.checked := true;
  FInterval := giMittel;
  writeoptions;
end;

procedure TMainForm.SchwerClick(Sender: TObject);
begin
  schwer.checked := true;
  FInterval := giSchwer;
  writeoptions;
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
  if optionMusic.checked then DestroyMusic(FMusic);
  SpriteEngine.Engine.Clear;
  dxsound.Finalize;
  dxinput.Destroy;
  DXTimer.Enabled := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  imagelist.Free;
  spriteengine.Free;
  dxdraw.Free;
  wavelist.Free;
  dxsound.Free;
  //dxinput.Free;
  dxtimer.Free;
  dxmusic.Free;
  DeleteCriticalSection(TimerCS);
  LevelData.Free;
end;

end.

