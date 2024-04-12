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
  sl1: TStringList;
  curline: integer;
  ergebniss: string;
  e: TEnemyAdvent;
begin
  sl1 := TStringList.Create;
  try
    sl1.LoadFromFile(filename);
    curline := 0;

    ergebniss := sl1.Strings[curline]; Inc(curline);
    if ergebniss = '; SpaceMission 1.0' then
    begin
      ergebniss := sl1.Strings[curline]; Inc(curline);
      Assert(ergebniss = '; LEV-File');

      ergebniss := sl1.Strings[curline]; Inc(curline);
      LevelEditorLength := StrToInt(ergebniss);

      while curline < sl1.Count do
      begin
        ergebniss := sl1.Strings[curline]; Inc(curline);
        e.enemyType := TEnemyType(strtoint(ergebniss));
        ergebniss := sl1.Strings[curline]; Inc(curline);
        e.x := strtoint(ergebniss);
        ergebniss := sl1.Strings[curline]; Inc(curline);
        e.y := strtoint(ergebniss);
        ergebniss := sl1.Strings[curline]; Inc(curline);
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
    FreeAndNil(sl1);
  end;
end;

procedure TLevelData.Save(filename: string);
begin
  // TODO: Implement and use everywhere (Hint: Search for FCompVersion)!
end;

end.
