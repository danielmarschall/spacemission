object InfoForm: TInfoForm
  Left = 289
  Top = 184
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Informationen'
  ClientHeight = 337
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object HomeLbl: TLabel
    Left = 32
    Top = 136
    Width = 48
    Height = 13
    Caption = 'Webseite:'
    Transparent = True
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
    Width = 74
    Height = 13
    Caption = 'ViaThinkSoft'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object NameLbl: TLabel
    Left = 104
    Top = 24
    Width = 66
    Height = 13
    Caption = 'SpaceMission'
    Transparent = True
  end
  object VersionLbl: TLabel
    Left = 232
    Top = 24
    Width = 35
    Height = 13
    Caption = 'Version'
    Transparent = True
  end
  object EMailLbl: TLabel
    Left = 32
    Top = 120
    Width = 32
    Height = 13
    Caption = 'E-Mail:'
    Transparent = True
  end
  object CopyrightLbl: TLabel
    Left = 8
    Top = 80
    Width = 264
    Height = 13
    Caption = #169' Copyright 2001 - 2015 Daniel Marschall, ViaThinkSoft'
    Transparent = True
  end
  object Copyright2Lbl: TLabel
    Left = 8
    Top = 96
    Width = 117
    Height = 13
    Caption = 'Alle Rechte vorbehalten!'
    Transparent = True
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
    OnClick = WebsiteClick
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
    OnClick = EMailClick
  end
  object OkBtn: TButton
    Left = 270
    Top = 303
    Width = 107
    Height = 25
    Cancel = True
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = OkBtnClick
  end
  object MemoMitwirkende: TMemo
    Left = 8
    Top = 168
    Width = 369
    Height = 121
    Lines.Strings = (
      
        'SpaceMission wurde von Daniel Marschall aus einer Codevorlage vo' +
        'n '
      
        'Hiroyuki Hori heraus erstellt. Das Original ist ein Codebeispiel' +
        ' f'#252'r DelphiX '
      '2000.'
      ''
      'Musik von Savage Peachers Software, Grafikquellen unbekannt.'
      ''
      'Levels von Daniel Marschall, Patrick B'#252'ssecker und Andreas '
      'K'#252'belsbeck.'
      ''
      'Entwickelt mit Borland Turbo Delphi.'
      ''
      'Verwendete Komponenten: (un)DelphiX')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
