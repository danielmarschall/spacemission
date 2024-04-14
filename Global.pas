unit Global;

interface

const
  ProgramVersion = '1.2';

  RasterW = 48;
  RasterH = 32;

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
    smgNone,              // ImageList.Items.Item[0]
    smgEnemyDisk,         // ImageList.Items.Item[1]
    smgEnemyAttacker,     // ImageList.Items.Item[2]
    smgEnemyBoss,         // ImageList.Items.Item[3]
    smgBounce,            // ImageList.Items.Item[4]
    smgMachine,           // ImageList.Items.Item[5]
    smgEnemyAttacker2,    // ImageList.Items.Item[6]
    smgEnemyAttacker3,    // ImageList.Items.Item[7]
    smgEnemyMeteor,       // ImageList.Items.Item[8]
    smgBounce2,           // ImageList.Items.Item[9]
    smgEnemyDisk2,        // ImageList.Items.Item[10]
    smgLogo,              // ImageList.Items.Item[11]
    smgExplosion,         // ImageList.Items.Item[12]
    smgBackgroundPlanet1, // ImageList.Items.Item[13]
    smgMatrix,            // ImageList.Items.Item[14]
    smgStar1,             // ImageList.Items.Item[15]
    smgStar2,             // ImageList.Items.Item[16]
    smgStar3,             // ImageList.Items.Item[17]
    smgBackgroundBlue,    // ImageList.Items.Item[18]
    smgBackgroundRed,     // ImageList.Items.Item[19]
    smgBackgroundYellow,  // ImageList.Items.Item[20]
    smgHintergrundRot     // ImageList.Items.Item[21]
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
