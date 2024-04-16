unit Global;

interface

const
  ProgramVersion = '1.2';
  RasterW = 48;
  RasterH = 32;
  MaxPossibleEnemyLives = 999;
  MaxPossibleLevels = 9999;
  RegistrySettingsKey = 'SOFTWARE\ViaThinkSoft\SpaceMission\Settings';

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

implementation

uses
  SysUtils;

function OwnDirectory: string;
begin
  result := extractfilepath(paramstr(0));
end;

end.
