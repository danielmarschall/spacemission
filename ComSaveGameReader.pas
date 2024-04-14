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
    if (sl.Strings[0] = '; SpaceMission 1.0') and
       (sl.Strings[1] = '; SAV-File') then
    begin
      FScore    := StrToInt(sl.Strings[2]);
      FLife     := StrToInt(sl.Strings[3]);
      FLevel    := StrToInt(sl.Strings[4]);
      FGameMode := TGameMode(StrToInt(sl.Strings[5]));
    end
    else if (sl.Strings[0] = '[SpaceMission Savegame, Format 1.2]') then
    begin
      FScore    := StrToInt(sl.Strings[1]);
      FLife     := StrToInt(sl.Strings[2]);
      FLevel    := StrToInt(sl.Strings[3]);
      FGameMode := TGameMode(StrToInt(sl.Strings[4]));
    end
    else
    begin
      raise Exception.Create('Spielstand-Format nicht unterstützt oder Datei beschädigt');
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
    sl.Add('[SpaceMission Savegame, Format 1.2]');
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
