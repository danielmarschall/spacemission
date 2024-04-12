unit ComSaveGameReader;

interface

type
  TGameMode = (gmUnknown, gmLevels, gmRandom);

  TSaveData = class(TObject)
  public
    FScore: integer;
    FLife: integer;
    FLevel: integer;
    FGameMode: TGameMode;
    procedure Load(filename: string);
    procedure Save(filename: string);
  end;

implementation

uses
  Classes, SysUtils;

{ TSaveData }

procedure TSaveData.Load(filename: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.LoadFromFile(filename);
    if sl.Strings[0] = '; SpaceMission 1.0' then
    begin
      if sl.Strings[1] <> '; SAV-File' then
      begin
        raise Exception.Create('Dies ist kein SpaceMission-Spielstand.');
      end;
      FScore := StrToInt(sl.Strings[2]);
      FLife := StrToInt(sl.Strings[3]);
      FLevel := StrToInt(sl.Strings[4]);
      FGameMode := TGameMode(StrToInt(sl.Strings[5]));
    end
    else
    begin
      raise Exception.CreateFmt('Spielstand-Format "%s" nicht unterstützt', [Copy(sl.Strings[0], 3, Length(sl.Strings[0])-2)]);
    end;
  finally
    FreeAndNil(sl);
  end;
end;

procedure TSaveData.Save(filename: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Add('; SpaceMission 1.0');
    sl.Add('; SAV-File');
    sl.Add(IntToStr(FScore));
    sl.Add(IntToStr(FLife));
    sl.Add(IntToStr(FLevel));
    sl.Add(IntToStr(Ord(FGameMode)));
    sl.SaveToFile(filename);
  finally
    FreeAndNil(sl);
  end;
end;

end.
