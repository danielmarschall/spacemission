object TextForm: TTextForm
  Left = 432
  Top = 156
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Informationen'
  ClientHeight = 361
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 106
  TextHeight = 13
  object OKBtn: TButton
    Left = 64
    Top = 328
    Width = 169
    Height = 25
    Caption = '&OK'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 8
    Width = 281
    Height = 313
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
