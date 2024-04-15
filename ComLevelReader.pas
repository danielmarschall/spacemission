unit ComLevelReader;

interface

uses
  Classes;

const
  NumEnemyTypes = 7;

type
  TEnemyType = (
    etUnknown,
    etEnemyAttacker,
    etEnemyAttacker2,
    etEnemyAttacker3,
    etEnemyMeteor,
    etEnemyUFO,
    etEnemyUFO2,
    etEnemyBoss
  );

  TEnemyAdvent = record
    enemyType: TEnemyType;
    x: integer;
    y: integer;
    lifes: integer;
  end;

  TLevelData = class(TPersistent)
  strict private
    procedure SortEnemies;
  strict protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    RasterErzwingen: boolean;
    LevelEditorLength: integer;
    LevelName: string;
    LevelAuthor: string;
    EnemyAdventTable: array of TEnemyAdvent;
    function IndexOfEnemy(x,y:integer;enemyType:TEnemyType;lifes:integer): integer;
    procedure AddEnemy(x,y:integer;enemyType:TEnemyType;lifes:integer);
    procedure DeleteEnemy(i: integer); overload;
    procedure DeleteEnemy(x,y:integer;enemyType:TEnemyType;lifes:integer); overload;
    function CountEnemies: integer;
    function HasBoss: boolean;
    procedure Clear;
    procedure LoadFromStrings(sl: TStrings); // version 0.3 - version 1.2 files
    procedure LoadFromFile(filename: string); // version 0.2 - version 1.2 files
    procedure SaveToStrings(sl: TStrings);
    procedure SaveToFile(filename: string);
    destructor Destroy; override;
  end;

  TGameMode = (gmUnknown, gmLevels, gmRandom);

  TSaveData = class(TPersistent)
  strict protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    Score: integer;
    Life: integer;
    Level: integer;
    GameMode: TGameMode;
    LevelData: TLevelData;
    procedure Clear;
    procedure LoadFromStrings(sl: TStrings);
    procedure LoadFromFile(filename: string);
    procedure SaveToStrings(sl: TStrings);
    procedure SaveToFile(filename: string);
    destructor Destroy; override;
  end;

function GetLevelFileName(lev: integer): string;

implementation

uses
  SysUtils, StrUtils, Global;

const
  DefaultLevelLength = 1200;

function GetLevelFileName(lev: integer): string;
begin
  result := OwnDirectory+'Levels\Level '+inttostr(lev)+'.lev'; // Version 0.3+ Level Files
  if not FileExists(Result) then
    result := OwnDirectory+'Levels\Lev'+inttostr(lev)+'A1.lev'; // Version 0.2 Level Files
end;

{ TLevelData }

procedure TLevelData.AssignTo(Dest: TPersistent);
var
  DestLevelData: TLevelData;
  i: integer;
begin
  DestLevelData := Dest as TLevelData;
  if Assigned(DestLevelData) then
  begin
    DestLevelData.RasterErzwingen := Self.RasterErzwingen;
    DestLevelData.LevelEditorLength := Self.LevelEditorLength;
    DestLevelData.LevelName := Self.LevelName;
    DestLevelData.LevelAuthor := Self.LevelAuthor;
    SetLength(DestLevelData.EnemyAdventTable, Length(Self.EnemyAdventTable));
    for i := 0 to Length(Self.EnemyAdventTable) do
    begin
      DestLevelData.EnemyAdventTable[i] := Self.EnemyAdventTable[i];
    end;
  end
  else
  begin
    inherited;
  end;
end;

procedure TLevelData.Clear;
begin
  SetLength(EnemyAdventTable, 0);
  LevelEditorLength := DefaultLevelLength;
  LevelName := '';
  LevelAuthor := '';
end;

function TLevelData.CountEnemies: integer;
begin
  result := Length(EnemyAdventTable);
end;

procedure TLevelData.DeleteEnemy(i: integer);
var
  j: integer;
begin
  for j := i+1 to CountEnemies-1 do
  begin
    EnemyAdventTable[j-1] := EnemyAdventTable[j];
  end;
  SetLength(EnemyAdventTable, Length(EnemyAdventTable)-1);
end;

procedure TLevelData.DeleteEnemy(x, y: integer; enemyType: TEnemyType;
  lifes: integer);
begin
  DeleteEnemy(IndexOfEnemy(x, y, enemyType, lifes));
end;

destructor TLevelData.Destroy;
begin
  Clear;
  inherited;
end;

function TLevelData.HasBoss: boolean;
var
  i: integer;
begin
  for i := 0 to Length(EnemyAdventTable) - 1 do
  begin
    if EnemyAdventTable[i].enemyType = etEnemyBoss then
    begin
      result := true;
      exit;
    end;
  end;
  result := false;
end;

procedure TLevelData.AddEnemy(x,y:integer;enemyType:TEnemyType;lifes:integer);
begin
  SetLength(EnemyAdventTable, Length(EnemyAdventTable)+1);

  if enemyType = etEnemyMeteor then lifes := 0;
  if RasterErzwingen then
  begin
    if x mod RasterW <> 0 then raise Exception.CreateFmt('X-Koordinate muss ohne Rest durch %d teilbar sein', [RasterW]);
    if y mod RasterH <> 0 then raise Exception.CreateFmt('Y-Koordinate muss ohne Rest durch %d teilbar sein', [RasterH]);
  end;
  if lifes > MaxPossibleEnemyLives then lifes := MaxPossibleEnemyLives;

  EnemyAdventTable[Length(EnemyAdventTable)-1].x         := x;
  EnemyAdventTable[Length(EnemyAdventTable)-1].y         := y;
  EnemyAdventTable[Length(EnemyAdventTable)-1].enemyType := enemyType;
  EnemyAdventTable[Length(EnemyAdventTable)-1].lifes     := lifes;
end;

function TLevelData.IndexOfEnemy(x, y: integer; enemyType: TEnemyType;
  lifes: integer): integer;
var
  i: integer;
begin
  for i := 0 to Length(EnemyAdventTable) - 1 do
  begin
    if (EnemyAdventTable[i].x = x) and
       (EnemyAdventTable[i].y = y) and
       (EnemyAdventTable[i].enemyType = enemyType) and
       (EnemyAdventTable[i].lifes = lifes) then
    begin
      result := i;
      exit;
    end;
  end;
  result := -1;
end;

procedure TLevelData.LoadFromStrings(sl: TStrings);
var
  curline: integer;
  z, act: integer;
  sl2: TStringList;
  tmpX, tmpY, tmpLifes: integer;
  tmpEnemy: TEnemyType;
  tmpRest: string;
  ergebnis: string;
begin
  Clear;

  LevelEditorLength := DefaultLevelLength;
  LevelName := '';
  LevelAuthor := '';

  if sl.Strings[0] = '; SpaceMission 0.3' then
  begin
    {$REGION 'Backwards compatibility level format 0.3 (convert to 0.4)'}
    sl.Strings[0] := '; SpaceMission 0.4';
    sl.Insert(1, '; LEV-File');
    {$ENDREGION}
  end;

  if (sl.Strings[0] = '; SpaceMission 0.4') and
     (sl.Strings[1] = '; LEV-File') then
  begin
    {$REGION 'Backwards compatibility level format 0.4 (convert to 1.0)'}
    sl2 := TStringList.Create;
    try
      z := 0;
      act := 0;
      while z < sl.Count do
      begin
        inc(z);
        if z > 2 then inc(act);
        if act = 5 then act := 1;
        ergebnis := sl.Strings[z-1];
        if ergebnis = '; SpaceMission 0.4' then
          sl2.Add('; SpaceMission 1.0')
        else
        begin
          if (ergebnis = '30000') and (z = 3) then
            sl2.Add(IntTostr(DefaultLevelLength))
          else
          begin
            //if not (((ergebnis = '0') and (z = 4)) or ((ergebnis = '-624') and (z = 5)) or ((ergebnis = '222') and (z = 6)) or ((ergebnis = '3') and (z = 7))) then
            if (z < 4) or (z > 7) then
            begin
              if act = 4 then
                sl2.Add(inttostr(strtoint(ergebnis) + 32 - (5 * (strtoint(ergebnis) div 37))))
              else
                sl2.Add(Ergebnis);
            end;
          end;
        end;
      end;
      sl.Text := sl2.Text;
    finally
      FreeAndNil(sl2);
    end;
    {$ENDREGION}
  end;

  if (sl.Strings[0] = '; SpaceMission 1.0') and
     (sl.Strings[1] = '; LEV-File') then
  begin
    {$REGION 'Level format 1.0'}
    LevelEditorLength := StrToInt(sl.Strings[2]);
    curline := 3;
    while curline < sl.Count do
    begin
      tmpEnemy := TEnemyType(strtoint(sl.Strings[curline]));
      Inc(curline);
      tmpX := strtoint(sl.Strings[curline]);
      Inc(curline);
      tmpY := strtoint(sl.Strings[curline]);
      Inc(curline);
      tmpLifes := strtoint(sl.Strings[curline]);
      Inc(curline);
      AddEnemy(tmpX, tmpY, tmpEnemy, tmpLifes);
    end;
    {$ENDREGION}
  end
  else if (SameText(sl.Strings[0], '[SpaceMission Level, Format 1.2]')) or
          (SameText(sl.Strings[0], '[SpaceMission Savegame, Format 1.2]')) then
  begin
    {$REGION 'Level format 1.2'}
    for curline := 1 to sl.Count-1 do
    begin
      // 1234567890123456789012345678901234567890
      // 123456 123456 123456 123456 123456 ; Kommentar
      if (sl.Strings[curline].Trim = '') or
         (Copy(sl.Strings[curline], 1, 1) = ';') then
        // Do nothing
      else if Copy(sl.Strings[curline], 1, 6).TrimRight = 'Width' then
      begin
        LevelEditorLength := StrToInt(TrimRight(Copy(sl.Strings[curline], 8, 6)))
      end
      else if Copy(sl.Strings[curline], 1, 6).TrimRight = 'Name' then
      begin
        LevelName := TrimRight(Copy(sl.Strings[curline], 8, Length(sl.Strings[curline])))
      end
      else if Copy(sl.Strings[curline], 1, 6).TrimRight = 'Author' then
      begin
        LevelAuthor := TrimRight(Copy(sl.Strings[curline], 8, Length(sl.Strings[curline])))
      end
      else if Copy(sl.Strings[curline], 1, 6).TrimRight = 'Enemy' then
      begin
        tmpEnemy := TEnemyType(strtoint(TrimRight(Copy(sl.Strings[curline], 8, 6))));
        tmpX     := strtoint(TrimRight(Copy(sl.Strings[curline], 15, 6)));
        tmpY     := strtoint(TrimRight(Copy(sl.Strings[curline], 22, 6)));
        tmpLifes := strtoint(TrimRight(Copy(sl.Strings[curline], 29, 6)));
        tmpRest  := Copy(sl.Strings[curline], 36, Length(sl.Strings[curline])-36+1);
        if (Copy(tmpRest, 1, 1) <> ';') and (Trim(tmpRest) <> '') then
          raise Exception.CreateFmt('Zeile %d ist ungültig (Zusatzinfo am Ende)', [curline+1]);
        AddEnemy(tmpX, tmpY, tmpEnemy, tmpLifes);
      end;
    end;
    {$ENDREGION}
  end
  else
  begin
    raise Exception.Create('Level-Format nicht unterstützt oder Datei ist beschädigt');
  end;

  SortEnemies; // Sortierung nach X-Koordinate ist sehr wichtig für das Spiel!
end;

procedure TLevelData.LoadFromFile(filename: string);
var
  sl: TStringList;
  i, j: integer;
  temp: string;
  m: array[1..6] of tstrings;
begin
  sl := TStringList.Create;
  try
    if EndsText('A1.lev', filename) then
    begin
      {$REGION 'Backwards compatibility level format 0.2 (split into 5-6 files; convert to 0.3)'}
      m[1] := TStringList.create;
      m[2] := TStringList.create;
      m[3] := TStringList.create;
      m[4] := TStringList.create;
      m[5] := TStringList.create;
      m[6] := TStringList.create;
      try
        for i := 1 to 6 do
        begin
          filename[Length(filename)-4] := IntToStr(i)[1]; // ...A2.sav, ...A3.sav, etc.
          if FileExists(filename) then
            m[i].loadfromfile(filename);
        end;
        m[1].strings[0] := '-624';
        if m[6].Text = '' then m[6].Text := '30000';

        sl.Add('; SpaceMission 0.3');
        sl.Add(temp);
        for j := 0 to m[1].count-2 do
        begin
          for i := 0 to m[1].count-2 do
          begin
            if strtoint(m[1].strings[i]) > strtoint(m[1].strings[i+1]) then
            begin
              m[1].exchange(i, i+1);
              m[2].exchange(i, i+1);
              m[3].exchange(i, i+1);
              m[4].exchange(i, i+1);
              m[5].exchange(i, i+1);
            end;
          end;
        end;
        for i := 0 to m[3].count-1 do
        begin
          for j := 1 to 4 do
          begin
            if j = 1 then sl.Add(m[3].strings[i]);
            if j = 2 then sl.Add(m[1].strings[i]);
            if j = 3 then sl.Add(m[2].strings[i]);
            if j = 4 then sl.Add(m[4].strings[i]);
          end;
        end;
      finally
        FreeAndNil(m[1]);
        FreeAndNil(m[2]);
        FreeAndNil(m[3]);
        FreeAndNil(m[4]);
        FreeAndNil(m[5]);
        FreeAndNil(m[6]);
      end;
      {$ENDREGION}
    end
    else
    begin
      sl.LoadFromFile(filename);
    end;

    LoadFromStrings(sl);
  finally
    FreeAndNil(sl);
  end;
end;

procedure TLevelData.SaveToStrings(sl: TStrings);
var
  i: integer;
begin
  sl.Clear;
  sl.Add('[SpaceMission Level, Format 1.2]');
  if LevelName   <> '' then sl.Add('Name   ' + LevelName);
  if LevelAuthor <> '' then sl.Add('Author ' + LevelAuthor);
  sl.Add('Width  ' + IntToStr(LevelEditorLength));
  SortEnemies;
  for i := 0 to Length(EnemyAdventTable)-1 do
  begin
    sl.Add(
      'Enemy'.PadRight(6, ' ')+
      ' '+
      IntToStr(Ord(EnemyAdventTable[i].enemyType)).PadRight(6, ' ')+
      ' '+
      IntToStr(EnemyAdventTable[i].x).PadRight(6, ' ')+
      ' '+
      IntToStr(EnemyAdventTable[i].y).PadRight(6, ' ')+
      ' '+
      IntToStr(EnemyAdventTable[i].lifes).PadRight(6, ' ')+
      ' '
    );
  end;
end;

procedure TLevelData.SaveToFile(filename: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    SaveToStrings(sl);
    sl.SaveToFile(filename);
  finally
    FreeAndNil(sl);
  end;
end;

procedure TLevelData.SortEnemies;
var
  i, n: integer;
  e: TEnemyAdvent;
begin
  // Bubble Sort Algorithmus
  for n := Length(EnemyAdventTable) downto 2 do
  begin
    for i := 0 to n - 2 do
    begin
      if
        // Sort by X-coord (important for the game!)
        (EnemyAdventTable[i].x > EnemyAdventTable[i+1].x)
        or
        // Sort by Y-coord (just cosmetics)
        ((EnemyAdventTable[i].x = EnemyAdventTable[i+1].x) and (EnemyAdventTable[i].y > EnemyAdventTable[i+1].y))
      then
      begin
        e := EnemyAdventTable[i];
        EnemyAdventTable[i] := EnemyAdventTable[i + 1];
        EnemyAdventTable[i + 1] := e;
      end;
    end;
  end;
end;

{ TSaveData }

procedure TSaveData.AssignTo(Dest: TPersistent);
var
  DestSaveData: TSaveData;
begin
  DestSaveData := Dest as TSaveData;
  if Assigned(DestSaveData) then
  begin
    DestSaveData.Score := Self.Score;
    DestSaveData.Life := Self.Life;
    DestSaveData.Level := Self.Level;
    DestSaveData.GameMode := Self.GameMode;
    if not Assigned(DestSaveData.LevelData) then DestSaveData.LevelData := TLevelData.Create;
    DestSaveData.LevelData.Assign(Self.LevelData);
  end
  else
  begin
    inherited;
  end;
end;

procedure TSaveData.Clear;
begin
  Score := 0;
  Life := 0;
  Level := 0;
  GameMode := gmUnknown;
  FreeAndNil(LevelData);
end;

destructor TSaveData.Destroy;
begin
  Clear;
  inherited;
end;

procedure TSaveData.SaveToStrings(sl: TStrings);
var
  sl2: TStringList;
begin
  sl2 := TStringList.Create;
  try
    sl.Add('[SpaceMission Savegame, Format 1.2]');
    sl.Add('Score  ' + IntToStr(Score));
    sl.Add('Lives  ' + IntToStr(Life));
    sl.Add('Level  ' + IntToStr(Level));
    sl.Add('Mode   ' + IntToStr(Ord(GameMode)));
    LevelData.SaveToStrings(sl2);
    sl2.Delete(0); // Signature
    sl.AddStrings(sl2);
  finally
    FreeAndNil(sl2);
  end;
end;

procedure TSaveData.LoadFromStrings(sl: TStrings);
var
  curline: Integer;
begin
  if (sl.Strings[0] = '; SpaceMission 1.0') and
     (sl.Strings[1] = '; SAV-File') then
  begin
    Score    := StrToInt(sl.Strings[2]);
    Life     := StrToInt(sl.Strings[3]);
    Level    := StrToInt(sl.Strings[4]);
    GameMode := TGameMode(StrToInt(sl.Strings[5]));
    if Assigned(LevelData) then FreeAndNil(LevelData);
  end
  else if SameText(sl.Strings[0], '[SpaceMission Savegame, Format 1.2]') then
  begin
    Score    := 0;
    Life     := 0;
    Level    := 0;
    GameMode := gmUnknown;
    for curline := 1 to sl.Count-1 do
    begin
      // 1234567890123456789012345678901234567890
      // 123456 123456 123456 123456 123456 ; Kommentar
      if (sl.Strings[curline].Trim = '') or
         (Copy(sl.Strings[curline], 1, 1) = ';') then
        // Do nothing
      else if Copy(sl.Strings[curline], 1, 6).TrimRight = 'Score' then
      begin
        Score := StrToInt(TrimRight(Copy(sl.Strings[curline], 8, 6)))
      end
      else if Copy(sl.Strings[curline], 1, 6).TrimRight = 'Lives' then
      begin
        Life := StrToInt(TrimRight(Copy(sl.Strings[curline], 8, 6)))
      end
      else if Copy(sl.Strings[curline], 1, 6).TrimRight = 'Level' then
      begin
        Level := StrToInt(TrimRight(Copy(sl.Strings[curline], 8, 6)))
      end
      else if Copy(sl.Strings[curline], 1, 6).TrimRight = 'Mode' then
      begin
        GameMode := TGameMode(StrToInt(TrimRight(Copy(sl.Strings[curline], 8, 6))))
      end;
    end;
    if Assigned(LevelData) then FreeAndNil(LevelData);
    LevelData := TLevelData.Create;
    LevelData.RasterErzwingen := false;
    LevelData.LoadFromStrings(sl);
  end
  else
  begin
    raise Exception.Create('Spielstand-Format nicht unterstützt oder Datei beschädigt');
  end;
end;

procedure TSaveData.LoadFromFile(filename: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromFile(filename);
    LoadFromStrings(sl);
  finally
    FreeAndNil(sl);
  end;
end;

procedure TSaveData.SaveToFile(filename: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    SaveToStrings(sl);
    sl.SaveToFile(filename);
  finally
    FreeAndNil(sl);
  end;
end;

end.
