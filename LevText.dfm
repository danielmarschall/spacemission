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
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ElPopupButton1: TButton
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
