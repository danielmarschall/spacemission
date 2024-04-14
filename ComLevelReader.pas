unit ComLevelReader;

interface

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

  TLevelData = class(TObject)
  strict private
    procedure SortEnemies;
  public
    LevelEditorLength: integer;
    EnemyAdventTable: array of TEnemyAdvent;
    function IndexOfEnemy(x,y:integer;enemyType:TEnemyType;lifes:integer): integer;
    procedure AddEnemy(x,y:integer;enemyType:TEnemyType;lifes:integer);
    procedure DeleteEnemy(i: integer); overload;
    procedure DeleteEnemy(x,y:integer;enemyType:TEnemyType;lifes:integer); overload;
    function CountEnemies: integer;
    function HasBoss: boolean;
    procedure Clear;
    procedure Load(filename: string);
    procedure Save(filename: string);
  end;

function GetLevelFileName(lev: integer): string;

implementation

uses
  SysUtils, StrUtils, Classes, Global;

const
  DefaultLevelLength = 1200;

function GetLevelFileName(lev: integer): string;
begin
  result := FDirectory+'Levels\Level '+inttostr(lev)+'.lev'; // Version 0.3+ Level Files
  if not FileExists(Result) then
    result := FDirectory+'Levels\Lev'+inttostr(lev)+'A1.lev'; // Version 0.2 Level Files
end;

{ TLevelData }

procedure TLevelData.Clear;
begin
  SetLength(EnemyAdventTable, 0);
  LevelEditorLength := DefaultLevelLength;
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

procedure TLevelData.Load(filename: string);
var
  sl, sl2: TStringList;
  curline: integer;
  ergebnis: string;
  z, act: integer;
  i, j: integer;
  temp: string;
  m: array[1..6] of tstrings;
  tmpX, tmpY, tmpLifes: integer;
  tmpEnemy: TEnemyType;
begin
  Clear;

  sl := TStringList.Create;
  try
    if EndsText('A1.lev', filename) then
    begin
      {$REGION 'Backwards compatibility level format 0.2 (split into 5-6 files)'}
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

    if sl.Strings[0] = '; SpaceMission 0.3' then
    begin
      {$REGION 'Backwards compatibility level format 0.3'}
      sl.Strings[0] := '; SpaceMission 0.4';
      sl.Insert(1, '; SAV-File');
      {$ENDREGION}
    end;

    if sl.Strings[0] = '; SpaceMission 0.4' then
    begin
      {$REGION 'Backwards compatibility level format 0.4'}
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

    if sl.Strings[0] = '; SpaceMission 1.0' then
    begin
      {$REGION 'Level format 1.0'}
      if sl.Strings[1]  <> '; LEV-File' then
      begin
        raise Exception.Create('Dies ist keine SpaceMission Level-Datei');
      end;

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
    else
    begin
      raise Exception.CreateFmt('Level-Format "%s" nicht unterstützt', [Copy(ergebnis, 3, Length(ergebnis)-2)]);
    end;
  finally
    FreeAndNil(sl);
  end;
  SortEnemies;
end;

procedure TLevelData.Save(filename: string);
var
  sl: TStringList;
  i: integer;
begin
  sl := TStringList.Create;
  try
    sl.Add('; SpaceMission 1.0');
    sl.Add('; LEV-File');
    sl.Add(IntToStr(LevelEditorLength));
    SortEnemies;
    for i := 0 to Length(EnemyAdventTable)-1 do
    begin
      sl.Add(IntToStr(Ord(EnemyAdventTable[i].enemyType)));
      sl.Add(IntToStr(EnemyAdventTable[i].x));
      sl.Add(IntToStr(EnemyAdventTable[i].y));
      sl.Add(IntToStr(EnemyAdventTable[i].lifes));
    end;
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

end.
