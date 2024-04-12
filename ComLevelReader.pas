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

function GetLevelFileName(lev: integer): string;

implementation

uses
  SysUtils, StrUtils, Classes, Global;

function GetLevelFileName(lev: integer): string;
begin
  result := FDirectory+'Levels\Lev'+inttostr(lev)+'A1.lev'; // Version 0.2 Level Files
  if not FileExists(Result) then
    result := FDirectory+'Levels\Level '+inttostr(lev)+'.lev'; // Version 0.3+ Level Files
end;

{ TLevelData }

procedure TLevelData.Clear;
begin
  SetLength(EnemyAdventTable, 0);
  LevelEditorLength := 0;
end;

procedure TLevelData.Load(filename: string);
var
  sl, sl2: TStringList;
  curline: integer;
  ergebnis: string;
  e: TEnemyAdvent;
  z, act: integer;
  i, j: integer;
  temp: string;
  m: array[1..6] of tstrings;
begin
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
              sl2.Add('1200')
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
        ergebnis := sl.Strings[curline]; Inc(curline);
        e.enemyType := TEnemyType(strtoint(ergebnis));
        ergebnis := sl.Strings[curline]; Inc(curline);
        e.x := strtoint(ergebnis);
        ergebnis := sl.Strings[curline]; Inc(curline);
        e.y := strtoint(ergebnis);
        ergebnis := sl.Strings[curline]; Inc(curline);
        e.lifes := strtoint(ergebnis);

        SetLength(EnemyAdventTable, Length(EnemyAdventTable)+1);
        EnemyAdventTable[Length(EnemyAdventTable)-1] := e;
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
