object SplashForm: TSplashForm
  Left = 241
  Top = 158
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Bitte warten...'
  ClientHeight = 388
  ClientWidth = 533
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SplashImage: TImage
    Left = 8
    Top = 8
    Width = 515
    Height = 373
    AutoSize = True
    Transparent = True
  end
end
