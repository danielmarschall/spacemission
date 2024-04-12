unit ComLevelReader;

interface

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
  public
    LevelEditorLength: integer;
    EnemyAdventTable: array of TEnemyAdvent;
    procedure Clear;
    procedure Load(filename: string);
    procedure Save(filename: string);
  end;

implementation

uses
  SysUtils, Classes;

{ TLevelData }

procedure TLevelData.Clear;
begin
  SetLength(EnemyAdventTable, 0);
  LevelEditorLength := 0;
end;

procedure TLevelData.Load(filename: string);
var
  sl: TStringList;
  curline: integer;
  ergebniss: string;
  e: TEnemyAdvent;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromFile(filename);
    curline := 0;

    ergebniss := sl.Strings[curline]; Inc(curline);
    if ergebniss = '; SpaceMission 1.0' then
    begin
      ergebniss := sl.Strings[curline]; Inc(curline);
      if ergebniss <> '; LEV-File' then
      begin
        raise Exception.Create('Dies ist keine SpaceMission Level-Datei');
      end;

      ergebniss := sl.Strings[curline]; Inc(curline);
      LevelEditorLength := StrToInt(ergebniss);

      while curline < sl.Count do
      begin
        ergebniss := sl.Strings[curline]; Inc(curline);
        e.enemyType := TEnemyType(strtoint(ergebniss));
        ergebniss := sl.Strings[curline]; Inc(curline);
        e.x := strtoint(ergebniss);
        ergebniss := sl.Strings[curline]; Inc(curline);
        e.y := strtoint(ergebniss);
        ergebniss := sl.Strings[curline]; Inc(curline);
        e.lifes := strtoint(ergebniss);

        SetLength(EnemyAdventTable, Length(EnemyAdventTable)+1);
        EnemyAdventTable[Length(EnemyAdventTable)-1] := e;
      end;
    end
    else
    begin
      // TODO: Support 0.2, 0.3, 0.4
      raise Exception.CreateFmt('Level-Format "%s" nicht unterstützt', [Copy(ergebniss, 3, Length(ergebniss)-2)]);
    end;
  finally
    FreeAndNil(sl);
  end;
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

end.
