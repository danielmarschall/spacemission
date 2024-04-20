unit Global;

interface

const
  ProgramVersion = '1.2';
  RasterW = 48;
  RasterH = 32;
  MaxPossibleEnemyLives = 999;
  MaxPossibleLevels = 999;
  RegistrySettingsKey = 'SOFTWARE\ViaThinkSoft\SpaceMission\Settings';
  DefaultLevelLength = 1200;
  StartLives = 6;
  conleicht =  650 div 60; // 10
  conmittel = 1000 div 60; // 16
  conschwer = 1350 div 60; // 22
  conmaster = 2000 div 60; // 33
  DEFAULT_ANIMSPEED = 15/1000;
  ADDITIONAL_ENEMIES_PER_LEVEL = 75;

type
  // DirectX\Music.dxm
  TSpaceMissionMusicTrack = (
    smmNone,
    smmBoss,   // dxmusic.Midis[0]
    smmGame,   // dxmusic.Midis[1]
    smmScene,  // dxmusic.Midis[2]
    smmTitle   // dxmusic.Midis[3]
  );

  // DirectX\Graphics.dxg
  TSpaceMissionGraphicSprite = (
    smgNone,
    smgEnemyDisk,         // ImageList.Items.Item[0]
    smgEnemyAttacker,     // ImageList.Items.Item[1]
    smgEnemyBoss,         // ImageList.Items.Item[2]
    smgBounce,            // ImageList.Items.Item[3]
    smgMachine,           // ImageList.Items.Item[4]
    smgEnemyAttacker2,    // ImageList.Items.Item[5]
    smgEnemyAttacker3,    // ImageList.Items.Item[6]
    smgEnemyMeteor,       // ImageList.Items.Item[7]
    smgBounce2,           // ImageList.Items.Item[8]
    smgEnemyDisk2,        // ImageList.Items.Item[9]
    smgLogo,              // ImageList.Items.Item[10]
    smgExplosion,         // ImageList.Items.Item[11]
    smgBackgroundPlanet1, // ImageList.Items.Item[12]
    smgMatrix,            // ImageList.Items.Item[13]
    smgStar1,             // ImageList.Items.Item[14]
    smgStar2,             // ImageList.Items.Item[15]
    smgStar3,             // ImageList.Items.Item[16]
    smgBackgroundBlue,    // ImageList.Items.Item[17]
    smgBackgroundRed,     // ImageList.Items.Item[18]
    smgBackgroundYellow,  // ImageList.Items.Item[19]
    smgHintergrundRot     // ImageList.Items.Item[20]
  );

  // DirectX\Sound.dxw
  TSpaceMissionSound = (
    smsNone,
    smsSceneMov,      // WaveList.Items.Item[0]
    smsExplosion,     // WaveList.Items.Item[1]
    smsHit,           // WaveList.Items.Item[2]
    smsShoot,         // WaveList.Items.Item[3]
    smsDanger,        // WaveList.Items.Item[4]
    smsEnde,          // WaveList.Items.Item[5]
    smsFrage,         // WaveList.Items.Item[6]
    smsLevIntro       // WaveList.Items.Item[7]
  );

function OwnDirectory: string;

const
  FOLDERID_SavedGames: TGuid = '{4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4}';

// Useful functions
function GetKnownFolderPath(const rfid: TGUID): string;
function KillTask(ExeFileName: string): Integer;

implementation

uses
  Windows, SysUtils, ActiveX, ShlObj, TlHelp32;

function GetKnownFolderPath(const rfid: TGUID): string;
var
  OutPath: PWideChar;
begin
  // https://www.delphipraxis.net/135471-unit-zur-verwendung-von-shgetknownfolderpath.html
  if ShGetKnownFolderPath(rfid, 0, 0, OutPath) {>= 0} = S_OK then
  begin
    Result := OutPath;
    // From MSDN
    // ppszPath [out]
    // Type: PWSTR*
    // When this method returns, contains the address of a pointer to a null-terminated Unicode string that specifies the path of the known folder
    // The calling process is responsible for freeing this resource once it is no longer needed by calling CoTaskMemFree.
    // The returned path does not include a trailing backslash. For example, "C:\Users" is returned rather than "C:\Users\".
    CoTaskMemFree(OutPath);
  end
  else
  begin
    Result := '';
  end;
end;

// https://stackoverflow.com/questions/43774320/how-to-kill-a-process-by-name
function KillTask(ExeFileName: string): Integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) =
      UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) =
      UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(
                        OpenProcess(PROCESS_TERMINATE,
                                    BOOL(0),
                                    FProcessEntry32.th32ProcessID),
                                    0));
     ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

function OwnDirectory: string;
begin
  result := extractfilepath(paramstr(0));
end;

end.
