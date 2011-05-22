object InfoForm: TInfoForm
  Left = 289
  Top = 184
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Informationen'
  ClientHeight = 193
  ClientWidth = 321
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object HomeLbl: TLabel
    Left = 32
    Top = 136
    Width = 48
    Height = 13
    Caption = 'Webseite:'
  end
  object Image: TImage
    Left = 8
    Top = 8
    Width = 65
    Height = 57
    Center = True
    Stretch = True
  end
  object FirmaLbl: TLabel
    Left = 88
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Firma'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object NameLbl: TLabel
    Left = 104
    Top = 24
    Width = 28
    Height = 13
    Caption = 'Name'
  end
  object VersionLbl: TLabel
    Left = 232
    Top = 24
    Width = 35
    Height = 13
    Caption = 'Version'
  end
  object EMailLbl: TLabel
    Left = 32
    Top = 120
    Width = 32
    Height = 13
    Caption = 'E-Mail:'
  end
  object CopyrightLbl: TLabel
    Left = 8
    Top = 80
    Width = 44
    Height = 13
    Caption = 'Copyright'
  end
  object Copyright2Lbl: TLabel
    Left = 8
    Top = 96
    Width = 117
    Height = 13
    Caption = 'Alle Rechte vorbehalten!'
  end
  object URL2: TLabel
    Left = 152
    Top = 136
    Width = 117
    Height = 13
    Cursor = crHandPoint
    Caption = 'www.daniel-marschall.de'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    Transparent = True
    OnClick = URL2Click
  end
  object URL1: TLabel
    Left = 152
    Top = 120
    Width = 118
    Height = 13
    Cursor = crHandPoint
    Caption = 'info@daniel-marschall.de'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    Transparent = True
    OnClick = URL1Click
  end
  object ElPopupButton1: TButton
    Left = 208
    Top = 160
    Width = 107
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = ElPopupButton1Click
  end
end
