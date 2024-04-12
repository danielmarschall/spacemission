unit LevMain;

// TODO 2024:
// - Wenn man ein Level "X" lädt, und dann Verwalten wieder öffnet, sollte diese Level-Nummer vorgeschlagen werden, sodass man direkt Speichern klicken kann

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, MMSystem,
  Dialogs, StdCtrls, ExtCtrls, Menus, DIB, DXClass, DXSprite, DXDraws,
  DXSounds, Spin, ComCtrls{$IF CompilerVersion >= 23.0}, System.UITypes,
  WinAPI.DirectDraw{$ENDIF}, DirectX;

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
    Quelltext1: TMenuItem;
    StatusBar: TStatusBar;
    N1: TMenuItem;
    Spielfelderweitern1: TMenuItem;
    LivesEdt: TEdit;
    Lives: TUpDown;
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
    procedure EnemyAdd(x, y, art, lives: integer);
    procedure NeuClick(Sender: TObject);
    procedure DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Quelltext1Click(Sender: TObject);
    procedure Spielfelderweitern1Click(Sender: TObject);
    procedure ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure LivesClick(Sender: TObject; Button: TUDBtnType);
    procedure LivesEdtKeyPress(Sender: TObject; var Key: Char);
    procedure LivesEdtChange(Sender: TObject);
  public
    { VCL-Ersatz }
    spriteengine: tdxspriteengine;
    dxtimer: tdxtimer;
    imagelist: tdximagelist;
    dxdraw: tdxdraw;
    { Variablen }
    FMenuItem: integer;
    Enemys: TStrings;
    ArtChecked: integer;
    LiveEdit: integer;
    ScrollP: integer;
    AltScrollPos: integer;
    Boss: boolean;
    LevChanged: boolean;
    NumEnemys: integer;
    { Level-Routinen }
    procedure EnemyCreate(x, y: integer);
    procedure DestroyLevel;
    procedure AnzeigeAct;
    { Initialisiations-Routinen }
    procedure DXInit;
    procedure ProgramInit;
    { Farb-Routinen }
    function ComposeColor(Dest, Src: TRGBQuad; Percent: Integer): TRGBQuad;
    procedure PalleteAnim(Col: TRGBQuad; Time: Integer);
    { Sonstiges }
    procedure LivesChange(newval: integer);
  end;

var
  MainForm: TMainForm;

implementation

uses
  Global, LevSplash, LevSpeicherung, ComInfo, LevSource, LevOptions,
  ComLevelReader;

const
  FileError = 'Die Datei kann von SpaceMission nicht geöffnet werden!';
  status_info = ' Zeigen Sie mit dem Mauszeiger auf eine Einheit, um deren Eigenschaften anzuzeigen...';
  status_lives = ' Leben: ';
  status_nolives = ' Einheit hat keine Lebensangabe';
  RasterW = 48;
  RasterH = 32;

{$R *.DFM}

type
  TBackground = class(TBackgroundSprite)
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

  TEnemy = class(TImageSprite)
  private
    Lives: integer;
    Art: integer;
    XCor: integer;
    CorInit: boolean;
  protected
    procedure DoMove(MoveCount: Integer); override;
  public
    constructor Create(AParent: TSprite); override;
  end;

procedure TMainForm.DXInit;
begin
  Imagelist.Items.LoadFromFile(FDirectory+'DirectX\Graphic.dxg');
  ImageList.Items.MakeColorTable;
  DXDraw.ColorTable := ImageList.Items.ColorTable;
  DXDraw.DefColorTable := ImageList.Items.ColorTable;
  DXDraw.UpdatePalette;
  DXDraw.Initialize;
end;

procedure TEnemy.DoMove(MoveCount: Integer);
begin
  if not CorInit then
  begin
    XCor := trunc(x) + (MainForm.ScrollP * RasterW);
    CorInit := true;
  end;
  if MainForm.Enemys.IndexOf(floattostr(XCor)+'-'+floattostr(y)+':'+
    inttostr(Art)+'('+inttostr(Lives)+')') = -1 then dead;
  X := XCor - (MainForm.ScrollP * RasterW);
end;

procedure TBackground.DoMove(MoveCount: Integer);
begin
  X := -(MainForm.ScrollP * RasterW);
end;

constructor TEnemy.Create(AParent: TSprite);
begin
  inherited Create(AParent);
  if MainForm.ArtChecked = 1 then Image := MainForm.ImageList.Items.Find('Enemy-Attacker');
  if MainForm.ArtChecked = 2 then Image := MainForm.ImageList.Items.Find('Enemy-Attacker2');
  if MainForm.ArtChecked = 3 then Image := MainForm.ImageList.Items.Find('Enemy-Attacker3');
  if MainForm.ArtChecked = 4 then Image := MainForm.ImageList.Items.Find('Enemy-Meteor');
  if MainForm.ArtChecked = 5 then Image := MainForm.ImageList.Items.Find('Enemy-Disk');
  if MainForm.ArtChecked = 6 then Image := MainForm.ImageList.Items.Find('Enemy-Disk2');
  if MainForm.ArtChecked = 7 then Image := MainForm.ImageList.Items.Find('Enemy-Boss');
  if MainForm.ArtChecked = 4 then Lives := 0 else Lives := MainForm.LiveEdit;
  Art := MainForm.ArtChecked;
  Width := Image.Width;
  Height := Image.Height;
  PixelCheck := True;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  LevelData: TLevelData;
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

  ArtChecked := 1;
  LiveEdit := 1;
  // Leeres Level am Anfang braucht keine Beenden-Bestätigung.
  // LevChanged := true;

  //Application.Title := 'SpaceMission '+ProgramVersion+' - Leveleditor';
  Caption := 'SpaceMission '+ProgramVersion+' - Leveleditor';
  DXInit;
  if (paramcount > 0) and (fileexists(paramstr(1))) then
  begin
    LevelData := TLevelData.Create;
    try
      try
        LevelData.Load(paramstr(1));
      except
        showmessage(FileError);
        ProgramInit;
        exit;
      end;
    finally
      FreeAndNil(LevelData);
    end;
    { Laden }
    exit;
  end;
  if fileexists(fdirectory+'Bilder\Auswahl.bmp') then
    Image1.Picture.LoadFromFile(fdirectory+'Bilder\Auswahl.bmp');
  {else
    SelPanel.visible := false;}
  ProgramInit;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Enemys.Free;
  //spriteengine.Free;
  dxtimer.Free;
  imagelist.Free;
  dxdraw.free;
end;

procedure TMainForm.BeendenClick(Sender: TObject);
begin
  close;
end;

procedure TMainForm.DXDrawInitialize(Sender: TObject);
begin
  DXTimer.Enabled := True;
end;

procedure TMainForm.DXDrawFinalize(Sender: TObject);
begin
  DXTimer.Enabled := False;
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
  Enemys := TStringList.create;
  sleep(500);
  //PlayerSprite
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := mainform.ImageList.Items.Find('Star3');
    Z := -13;
    Y := 40;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := mainform.ImageList.Items.Find('Star2');
    Z := -12;
    Y := 30;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := mainform.ImageList.Items.Find('Star1');
    Z := -11;
    Y := 10;
    Tile := True;
  end;
  with TBackground.Create(SpriteEngine.Engine) do
  begin
    SetMapSize(1, 1);
    Image := mainform.ImageList.Items.Find('Matrix');
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

procedure TMainForm.LevelClick(Sender: TObject);
begin
  speicherungform.showmodal;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  SplashForm.Hide;
  SplashForm.Free;

  dxtimer.Enabled := true;
  dxtimer.ActiveOnly := true;
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
  i, j, k, l, ex, ey: integer;
  ok, breaked: boolean;
begin
  ex := trunc(x/RasterW) * RasterW;
  ey := trunc(y/RasterH) * RasterH;
  EnemyCreate(ex, ey);
  breaked := false;
  { Setzen }
  if Button = mbLeft then
  begin
    ok := true;
    if (ArtChecked = 7) and boss then ok := false
    else
    begin
      for i := 1 to 7 do
      begin
        for j := 0 to 999 do
        begin
          if boss then
          begin
            for k := 0 to 3 do
            begin
              for l := 0 to 1 do
              begin
                if Enemys.IndexOf(floattostr(ex + ((ScrollP - k) * RasterW))+'-'+floattostr(ey - (RasterH * l))+':7('+inttostr(j)+')') <> -1 then
                begin
                  ok := false;
                  break;
                end;
              end;
              if not ok then break;
            end;
            if not ok then break;
          end;
          if Enemys.IndexOf(floattostr(ex + (ScrollP * RasterW))+'-'+floattostr(ey)+':'+
            inttostr(i)+'('+inttostr(j)+')') <> -1 then
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
      if ArtChecked <> 4 then
        Enemys.Add(floattostr(ex + (ScrollP * RasterW))+'-'+floattostr(ey)+':'+
          inttostr(ArtChecked)+'('+inttostr(LiveEdit)+')')
      else
        Enemys.Add(floattostr(ex + (ScrollP * RasterW))+'-'+floattostr(ey)+':'+
          inttostr(ArtChecked)+'(0)');
      inc(NumEnemys);
      if ArtChecked = 7 then boss := true;
    end
    else beep;
  end
  { Löschen }
  else if Button = mbRight then
  begin
    for i := 1 to 7 do
    begin
      for j := 0 to 999 do
      begin
        if boss and (i = 7) then
        begin
          for k := 0 to 3 do
          begin
            for l := 0 to 1 do
            begin
              if Enemys.IndexOf(floattostr(ex + ((ScrollP - k) * RasterW))+'-'+floattostr(ey - (RasterH * l))+':'+inttostr(i)+'('+inttostr(j)+')') <> -1 then
              begin
                Enemys.Delete(Enemys.IndexOf(floattostr(ex + ((ScrollP - k) * RasterW))+'-'+floattostr(ey - (RasterH * l))+':'+inttostr(i)+'('+inttostr(j)+')'));
                Boss := false;
                dec(NumEnemys);
                breaked := true;
                break;
              end;
            end;
            if breaked then break;
          end;
        end;
        if Enemys.IndexOf(floattostr(ex + (ScrollP * RasterW))+'-'+floattostr(ey)+':'+
          inttostr(i)+'('+inttostr(j)+')') <> -1 then
        begin
          Enemys.Delete(Enemys.IndexOf(floattostr(ex + (ScrollP * RasterW))+'-'+floattostr(ey)+
            ':'+inttostr(i)+'('+inttostr(j)+')'));
          if i = 7 then Boss := false;
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
begin
  if sender = Enemy1 then ArtChecked := 1;
  if sender = Enemy2 then ArtChecked := 2;
  if sender = Enemy3 then ArtChecked := 3;
  if sender = Enemy4 then ArtChecked := 4;
  if sender = Enemy5 then ArtChecked := 5;
  if sender = Enemy6 then ArtChecked := 6;
  if sender = Enemy7 then ArtChecked := 7;
  Image1.Left := -(87 * (ArtChecked - 1)) + 1;
  Lives.Enabled := sender <> Enemy4;
  LivesLabel.Enabled := sender <> Enemy4;
  if sender = Enemy4 then LivesEdt.Font.Color := clBtnShadow // andere farbe?
    else LivesEdt.Font.Color := clWindowText;
end;

procedure TMainForm.EnemyCreate(x, y: integer);
var
  Enemy: TSprite;
begin
  Enemy := TEnemy.Create(SpriteEngine.Engine);
  Enemy.x := x;
  Enemy.y := y;
end;

procedure TMainForm.DestroyLevel;
begin
  ScrollBar.Position := 0; // this doesn't call ScrollBarScroll()
  ScrollP := 0;
  Enemys.Clear;
  NumEnemys := 0;
  Boss := false;
  LevChanged := true;
  Lives.Position := 1;
  LivesChange(Lives.Position);
  Enemy1.Checked := true;
  EnemyClick(Enemy1);
  AnzeigeAct;
end;

procedure TMainForm.AnzeigeAct;
begin
  SLabel1b.Caption := inttostr(NumEnemys);
  if Boss then SLabel2b.Caption := 'Ja' else SLabel2b.Caption := 'Nein';
  SLabel3b.Caption := inttostr(ScrollBar.Max);
  if LevChanged then
  begin
    SLabel4a.Font.Color := $00000096;
    SLabel4b.Font.Color := $00000096;
    SLabel4b.Caption := 'Nein';
  end
  else
  begin
    SLabel4a.Font.Color := $00009600;
    SLabel4b.Font.Color := $00009600;
    SLabel4b.Caption := 'Ja';
  end;
end;

procedure TMainForm.EnemyAdd(x, y, art, lives: integer);
begin
  Enemys.Add(inttostr(x)+'-'+inttostr(y)+':'+inttostr(art)+'('+inttostr(lives)+')');
end;

procedure TMainForm.NeuClick(Sender: TObject);
begin
  if MessageDlg('Level wirklich löschen?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    DestroyLevel;
end;

procedure TMainForm.DXDrawMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ex, ey, i, j, k, l, wert: integer;
  breaked: boolean;
begin
  if sender <> DxDraw then
  begin
    StatusBar.SimpleText := status_info;
    exit;
  end;
  ex := trunc(x/RasterW) * RasterW;
  ey := trunc(y/RasterH) * RasterH;
  wert := -1;
  breaked := false;
  for i := 1 to 7 do
  begin
    for j := 0 to 999 do
    begin
      if boss and (i = 7) then
      begin
        for k := 0 to 3 do
        begin
          for l := 0 to 1 do
          begin
            if Enemys.IndexOf(floattostr(ex + ((ScrollP - k) * RasterW))+'-'+floattostr(ey - (RasterH * l))+':'+inttostr(i)+'('+inttostr(j)+')') <> -1 then
            begin
              wert := j;
              breaked := true;
              break;
            end;
          end;
          if breaked then break;
        end;
      end;
      if (breaked = false) and (Enemys.IndexOf(floattostr(ex + (ScrollP * RasterW))+'-'+floattostr(ey)+':'+
        inttostr(i)+'('+inttostr(j)+')') <> -1) then
      begin
        wert := j;
        breaked := true;
        break;
      end;
    end;
    if breaked then break;
  end;
  if wert <> -1 then
  begin
    if wert > 0 then
      StatusBar.SimpleText := status_lives + inttostr(wert)
    else
      StatusBar.SimpleText := status_nolives;
  end
  else
    StatusBar.SimpleText := status_info;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if LevChanged then
    CanClose := MessageDlg('Beenden ohne abspeichern?', mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

procedure TMainForm.Quelltext1Click(Sender: TObject);
begin
  SourceForm.Aktualisieren;
  SourceForm.showmodal;
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

procedure TMainForm.LivesChange(newval: integer);
begin
  LiveEdit := newval;
  livesedt.Text := inttostr(LiveEdit);
  lives.Position := newval;
end;

procedure TMainForm.LivesClick(Sender: TObject; Button: TUDBtnType);
begin
  LivesChange(lives.Position);
end;

procedure TMainForm.LivesEdtKeyPress(Sender: TObject; var Key: Char);
begin
  {$IFDEF UNICODE}
  if not CharInSet(Key, [#13, #08, '0'..'9']) then
  {$ELSE}
  if not (Key in [#13, #08, '0'..'9']) then
  {$ENDIF}
    Key := #0;
end;

procedure TMainForm.LivesEdtChange(Sender: TObject);
begin
  LivesChange(strtoint(livesedt.text));
end;

end.

