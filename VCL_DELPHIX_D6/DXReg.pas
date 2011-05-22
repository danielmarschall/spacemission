unit DXReg;


interface


uses
  Windows, SysUtils, Classes, Forms, Dialogs, Graphics, TypInfo,
  DXDraws, DXSounds, DIB, Wave, DXInput, DXPlay, DXSprite,
  DXClass;


procedure Register;


implementation


const
  SNone = '(None)';
  SSettingImage = '&Image...';
  SSettingWave = '&Wave...';
  SDXGFileFilter = 'DXG file(*.dxg)|*.dxg|All files(*.*)|*.*';
  SDXGOpenFileFilter = 'DXG file(*.dxg)|*.dxg|Bitmap file(*.bmp)|*.bmp|All files(*.*)|*.*';
  SDXWFileFilter = 'DXW file(*.dxw)|*.dxw|All files(*.*)|*.*';
  SDXWOpenFileFilter = 'DXW file(*.dxw)|*.dxw|Wave file(*.wav)|*.wav|All files(*.*)|*.*';
  SSinglePlayer = '&Single player';
  SMultiPlayer1 = 'Multi player &1';
  SMultiPlayer2 = 'Multi player &2';

  SOpen = '&Open...';
  SSave = '&Save..';

procedure Register;
begin
  RegisterComponents('DelphiX',
    [TDXDraw,
    TDXDIB,
    TDXImageList,
    TDX3D,
    TDXSound,
    TDXWave,
    TDXWaveList,
    TDXInput,
    TDXPlay,
    TDXSpriteEngine,
    TDXTimer,
    TDXPaintBox]);
end;

end.


