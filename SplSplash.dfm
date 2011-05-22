object SplashForm: TSplashForm
  Left = 241
  Top = 158
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Bitte warten...'
  ClientHeight = 497
  ClientWidth = 658
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SplashImage: TImage
    Left = 8
    Top = 8
    Width = 640
    Height = 480
    AutoSize = True
    Transparent = True
  end
end
