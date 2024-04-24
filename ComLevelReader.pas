unit ComLevelReader;

interface

uses
  Classes;

type
  // If you add a new enemy or item, please edit
  // - ComLevelReader.pas : EnemyTypeHasLives()
  // - GamMain.pas : TMainForm.SceneMain
  // - LevMain.pas : * GUI
  //                 * TMainForm.SelectedEnemyType
  //                 * TEnemyOrItem.Create
  //                 * TMainForm.DXDrawMouseMove
  //                 * TMainForm.DXDrawMouseDown
  TEnemyType = (
    etUnknown,
    etEnemyAttacker,
    etEnemyAttacker2,
    etEnemyAttacker3,
    etEnemyMeteor,
    etEnemyUFO,
    etEnemyUFO2,
    etEnemyBoss,
    etItemMedikit
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

  TGameMode = (gmUnknown, gmLevels, gmRandom, gmEditor);

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

  TLevelFile = record
    levelNumber: integer;
    fileLocation: string;
    isUser: boolean;
    found: boolean;
  end;

function GetLevelFileName(lev: integer; forceuserdir: boolean): TLevelFile;

function EnemyTypeHasLives(et: TEnemyType): boolean;

implementation

uses
  SysUtils, StrUtils, Global, Windows, System.Types;

const
  // { iso(1) identified-organization(3) dod(6) internet(1) private(4) enterprise(1) 37476 products(2) spacemission(8) file-format(1) lev-sav-v12(1) }
  // https://hosted.oidplus.com/viathinksoft/?goto=oid%3A1.3.6.1.4.1.37476.2.8.1.1
  OID_LEVSAV_VER12 = '1.3.6.1.4.1.37476.2.8.1.1'; // do not localize

resourcestring
  SLevelFileFolder = 'Levels';
  SLevelFileSubFolder = 'SpaceMission';
  SExtraContentAfterLine = 'Zeile %d ist ungültig (Zusatzinfo am Ende)';

function GetLevelFileName(lev: integer; forceuserdir: boolean): TLevelFile;

  function _GetLevelVerzeichnisSystem: string;
  begin
    // Für die Auslieferungs-Levels
    result := OwnDirectory + SLevelFileFolder;
  end;

  function _GetLevelVerzeichnisUser: string;
  begin
    try
      result := GetKnownFolderPath(FOLDERID_SavedGames);
    except
      result := '';
    end;
    if result = '' then
    begin
      // Pre Vista
      result := OwnDirectory + SLevelFileFolder;
    end
    else
    begin
      result := IncludeTrailingPathDelimiter(result);
      result := result + SLevelFileSubFolder;
    end;
    result := IncludeTrailingPathDelimiter(result);
    ForceDirectories(result);
  end;

  function _GetLevelFileNameUser(lev: integer): string;
  var
    old, new: string;
  begin
    new := IncludeTrailingPathDelimiter(_GetLevelVerzeichnisUser)+'Level '+inttostr(lev)+'.lev'; // Version 0.3+ Level Files // do not localize
    old := IncludeTrailingPathDelimiter(_GetLevelVerzeichnisUser)+'Lev'+inttostr(lev)+'A1.lev'; // Version 0.2 Level Files // do not localize
    if fileexists(new) then exit(new);
    if fileexists(old) then exit(old);
    exit(new);
  end;

  function _GetLevelFileNameSystem(lev: integer): string;
  var
    old, new: string;
  begin
    new := IncludeTrailingPathDelimiter(_GetLevelVerzeichnisSystem)+'Level '+inttostr(lev)+'.lev'; // Version 0.3+ Level Files // do not localize
    old := IncludeTrailingPathDelimiter(_GetLevelVerzeichnisSystem)+'Lev'+inttostr(lev)+'A1.lev'; // Version 0.2 Level Files // do not localize
    if fileexists(new) then exit(new);
    if fileexists(old) then exit(old);
    exit(new);
  end;

var
  usr, sys: string;
  bfound: boolean;
begin
  result.levelNumber := lev;
  usr := _GetLevelFileNameUser(lev);
  sys := _GetLevelFileNameSystem(lev);
  bfound := fileexists(usr);
  if bfound or forceuserdir then
  begin
    result.isUser := true;
    result.fileLocation := usr;
    result.found := bfound;
    exit;
  end;
  bfound := fileexists(sys);
  if bfound then
  begin
    result.isUser := false;
    result.fileLocation := sys;
    result.found := bfound;
    exit;
  end;
  result.isUser := true;
  result.fileLocation := usr;
  result.found := false;
end;

// this is just an example, there are many
// different ways you can implement this
// more efficiently, ie using a TStringBuilder,
// or even modifying the String in-place...
function CollapseSpaces(const S: string): string;
var
  P: PChar;
  AddSpace: Boolean;
begin
  Result := '';
  AddSpace := False;
  P := PChar(S);
  while P^ <> #0 do
  begin
    while CharInSet(P^, [#1..' ']) do Inc(P);
    if P^ = #0 then Exit;
    if AddSpace then
      Result := Result + ' '
    else
      AddSpace := True;
    repeat
      Result := Result + P^;
      Inc(P);
    until P^ <= ' ';
  end;
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
    for i := 0 to Length(Self.EnemyAdventTable)-1 do
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
resourcestring
  SInvalidXCoord = 'X-Koordinate muss ohne Rest durch %d teilbar sein';
  SInvalidYCoord = 'Y-Koordinate muss ohne Rest durch %d teilbar sein';
begin
  SetLength(EnemyAdventTable, Length(EnemyAdventTable)+1);

  if enemyType = etEnemyMeteor then lifes := 0;
  if RasterErzwingen then
  begin
    if x mod LevEditRasterW <> 0 then raise Exception.CreateFmt(SInvalidXCoord, [LevEditRasterW]);
    if y mod LevEditRasterH <> 0 then raise Exception.CreateFmt(SInvalidYCoord, [LevEditRasterH]);
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
resourcestring
  SInvalidLevelFile = 'Level-Format nicht unterstützt oder Datei ist beschädigt';
  SEnemyTypeNotImplemented = 'Gegner-Typ %d wird nicht unterstützt (Alte Spielversion?)';
var
  curline: integer;
  z, act: integer;
  sl2: TStringList;
  tmpX, tmpY, tmpLifes: integer;
  tmpEnemy: TEnemyType;
  ergebnis: string;
  ary: TStringDynArray;
  sLine: string;
  iEnemy: Integer;
begin
  Clear;

  LevelEditorLength := DefaultLevelLength;
  LevelName := '';
  LevelAuthor := '';

  if sl.Strings[0] = '; SpaceMission 0.3' then // do not localize
  begin
    {$REGION 'Backwards compatibility level format 0.3 (convert to 0.4)'}
    sl.Strings[0] := '; SpaceMission 0.4'; // do not localize
    sl.Insert(1, '; LEV-File'); // do not localize
    {$ENDREGION}
  end;

  if (sl.Strings[0] = '; SpaceMission 0.4') and // do not localize
     (sl.Strings[1] = '; LEV-File') then // do not localize
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
        if ergebnis = '; SpaceMission 0.4' then // do not localize
          sl2.Add('; SpaceMission 1.0') // do not localize
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

  if (sl.Strings[0] = '; SpaceMission 1.0') and // do not localize
     (sl.Strings[1] = '; LEV-File') then // do not localize
  begin
    {$REGION 'Level format 1.0'}
    LevelEditorLength := StrToInt(sl.Strings[2]);
    curline := 3;
    while curline < sl.Count do
    begin
      iEnemy := strtoint(sl.Strings[curline]);
      if TEnemyType(iEnemy) = etUnknown then // <-- for some reason, etUnknown will also be set if iEnemy is too large. This is actually good!
        raise Exception.CreateFmt(SEnemyTypeNotImplemented, [iEnemy]);
      tmpEnemy := TEnemyType(iEnemy);
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
  else if (SameText(sl.Strings[0], '['+OID_LEVSAV_VER12+']')) then
  begin
    {$REGION 'Level format 1.2'}
    for curline := 1 to sl.Count-1 do
    begin
      sLine := sl.Strings[curline].Trim;
      if (sLine = '') or (Copy(sLine, 1, 1) = ';') then continue;
      ary := SplitString(CollapseSpaces(sLine), ' ');
      if SameText(ary[0], 'Width') then // do not localize
      begin
        LevelEditorLength := StrToInt(ary[1]);
        if (Length(ary) > 2) and (Copy(ary[2], 1, 1) <> ';') then
          raise Exception.CreateFmt(SExtraContentAfterLine, [curline+1]);
      end
      else if SameText(ary[0], 'Name') then // do not localize
      begin
        LevelName := Trim(Copy(sLine, Length(ary[0])+2, Length(sLine)));
      end
      else if SameText(ary[0], 'Author') then // do not localize
      begin
        LevelAuthor := Trim(Copy(sLine, Length(ary[0])+2, Length(sLine)));
      end
      else if SameText(ary[0], 'Enemy') then // do not localize
      begin
        iEnemy := strtoint(ary[1]);
        if TEnemyType(iEnemy) = etUnknown then // <-- for some reason, etUnknown will also be set if iEnemy is too large. This is actually good!
          raise Exception.CreateFmt(SEnemyTypeNotImplemented, [iEnemy]);
        tmpEnemy := TEnemyType(iEnemy);
        tmpX     := strtoint(ary[2]);
        tmpY     := strtoint(ary[3]);
        tmpLifes := strtoint(ary[4]);
        if (Length(ary) > 5) and (Copy(ary[5], 1, 1) <> ';') then
          raise Exception.CreateFmt(SExtraContentAfterLine, [curline+1]);
        AddEnemy(tmpX, tmpY, tmpEnemy, tmpLifes);
      end;
    end;
    {$ENDREGION}
  end
  else
  begin
    raise Exception.Create(SInvalidLevelFile);
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
    if EndsText('A1.lev', filename) then // do not localize
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

        sl.Add('; SpaceMission 0.3'); // do not localize
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
resourcestring
  SLevelEnemyLineComment = ';      Type   XCoord YCoord Lives';
var
  i: integer;
begin
  sl.Clear;
  sl.Add('['+OID_LEVSAV_VER12+']');
  if LevelName   <> '' then sl.Add('Name   ' + LevelName); // do not localize
  if LevelAuthor <> '' then sl.Add('Author ' + LevelAuthor); // do not localize
  sl.Add('Width  ' + IntToStr(LevelEditorLength)); // do not localize
  SortEnemies;
  sl.Add(SLevelEnemyLineComment);
  for i := 0 to Length(EnemyAdventTable)-1 do
  begin
    sl.Add(Trim(
      'Enemy'.PadRight(6, ' ')+ // do not localize
      ' '+
      IntToStr(Ord(EnemyAdventTable[i].enemyType)).PadRight(6, ' ')+
      ' '+
      IntToStr(EnemyAdventTable[i].x).PadRight(6, ' ')+
      ' '+
      IntToStr(EnemyAdventTable[i].y).PadRight(6, ' ')+
      ' '+
      IntToStr(EnemyAdventTable[i].lifes).PadRight(6, ' ')+
      ' '
    ));
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
    sl.Add('['+OID_LEVSAV_VER12+']');
    sl.Add('Score  ' + IntToStr(Score)); // do not localize
    sl.Add('Lives  ' + IntToStr(Life)); // do not localize
    sl.Add('Level  ' + IntToStr(Level)); // do not localize
    sl.Add('Mode   ' + IntToStr(Ord(GameMode))); // do not localize
    LevelData.SaveToStrings(sl2);
    sl2.Delete(0); // Delete additional level signature
    sl.AddStrings(sl2);
  finally
    FreeAndNil(sl2);
  end;
end;

procedure TSaveData.LoadFromStrings(sl: TStrings);
resourcestring
  SInvalidFile = 'Spielstand-Format nicht unterstützt oder Datei beschädigt';
var
  curline: Integer;
  ary: TStringDynArray;
  sLine: string;
begin
  if (sl.Strings[0] = '; SpaceMission 1.0') and // do not localize
     (sl.Strings[1] = '; SAV-File') then // do not localize
  begin
    Score    := StrToInt(sl.Strings[2]);
    Life     := StrToInt(sl.Strings[3]);
    Level    := StrToInt(sl.Strings[4]);
    GameMode := TGameMode(StrToInt(sl.Strings[5]));
    if Assigned(LevelData) then FreeAndNil(LevelData);
  end
  else if SameText(sl.Strings[0], '['+OID_LEVSAV_VER12+']') then
  begin
    Score    := 0;
    Life     := 0;
    Level    := 0;
    GameMode := gmUnknown;
    for curline := 1 to sl.Count-1 do
    begin
      sLine := sl.Strings[curline].Trim;
      if (sLine = '') or (Copy(sLine, 1, 1) = ';') then continue;
      ary := SplitString(CollapseSpaces(sLine), ' ');
      if SameText(ary[0], 'Score') then // do not localize
      begin
        Score := StrToInt(ary[1]);
        if (Length(ary) > 2) and (Copy(ary[2], 1, 1) <> ';') then
          raise Exception.CreateFmt(SExtraContentAfterLine, [curline+1]);
      end
      else if SameText(ary[0], 'Lives') then // do not localize
      begin
        Life := StrToInt(ary[1]);
        if (Length(ary) > 2) and (Copy(ary[2], 1, 1) <> ';') then
          raise Exception.CreateFmt(SExtraContentAfterLine, [curline+1]);
      end
      else if SameText(ary[0], 'Level') then // do not localize
      begin
        Level := StrToInt(ary[1]);
        if (Length(ary) > 2) and (Copy(ary[2], 1, 1) <> ';') then
          raise Exception.CreateFmt(SExtraContentAfterLine, [curline+1]);
      end
      else if SameText(ary[0], 'Mode') then // do not localize
      begin
        GameMode := TGameMode(StrToInt(ary[1]));
        if (Length(ary) > 2) and (Copy(ary[2], 1, 1) <> ';') then
          raise Exception.CreateFmt(SExtraContentAfterLine, [curline+1]);
      end;
    end;
    if Assigned(LevelData) then FreeAndNil(LevelData);
    LevelData := TLevelData.Create;
    LevelData.RasterErzwingen := false;
    LevelData.LoadFromStrings(sl);
  end
  else
  begin
    raise Exception.Create(SInvalidFile);
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

function EnemyTypeHasLives(et: TEnemyType): boolean;
begin
  result := (et <> etEnemyMeteor) and (et <> etItemMedikit);
end;

end.
