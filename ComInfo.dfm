object InfoForm: TInfoForm
  Left = 289
  Top = 184
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Informationen'
  ClientHeight = 336
  ClientWidth = 381
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
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
    Picture.Data = {
      07544269746D617076020000424D760200000000000076000000280000002000
      0000200000000100040000000000000200000000000000000000100000000000
      000000000000000080000080000000808000800000008000800080800000C0C0
      C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
      FF00000000000000000000000000000000000EE8787878EEEEEEE03F30878EEE
      EEE00EE8787878EEEEEEE03F30878EEEEEE00EE8787878EEEEEEE03F30878EEE
      EEE00EE8787878EEEEEEE03F30878EEEEEE00887787877788888803F3088787E
      EEE00788787878878887803F3088887EEEE00788887888878887803F3088887E
      EEE00877888887788888703F308887EEEEE00888777778888888037883088888
      8EE007777777777777703787883087777EE00888888888888803787378830888
      8880088888888888803787378788308888800777777777880378737373788308
      88E00888888888803787373737378830EEE00887777778800001111111111100
      EEE00888888888888899B999B99999EEEEE00888888888888899B9B99BB9B9EE
      EEE0088888888888899BB9BB99BB99EEEEE0078888888888899B999B999999EE
      EEE0087788888778899B9B9BB9BB99EEEEE00888778778888E9B9B9BB9999EEE
      EEE0088888788888EE9B99B9BB9BEEEEEEE00EE8888888EEEEE999B9999EEEEE
      EEE00EEEE888EEEEEEEE99BB999EEEEEEEE00EEEEE8EEEEEEEEEE999B9EEEEEE
      EEE00EEEEE8EEEEEEEEEEEE999EEEEEEEEE00EEEEE8EEEEEEEEEEEEE99EEEEEE
      EEE00EEEEE8EEEEEEEEEEEEE9EEEEEEEEEE00EEEEE8EEEEEEEEEEEEEEEEEEEEE
      EEE00EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE00000000000000000000000000000
      0000}
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
    Caption = #169' Copyright 2001 - 2024 Daniel Marschall, ViaThinkSoft'
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
      
        'SpaceMission wurde von Daniel Marschall auf Basis eines Codebeis' +
        'piels '
      'von  Hiroyuki Hori f'#252'r DelphiX 2000 entwickelt.'
      ''
      'Entwickelt mit Embarcadero Delphi.'
      ''
      'Verwendete Komponenten: (un)DelphiX'
      'Source: http://www.micrel.cz/Dx/'
      '(C) Copyright 1996-2000 by Hiroyuki Hori'
      '(C) Copyright 2004-2023 by Jaro Benes.'
      ''
      'Musik von Savage Peachers Software, Grafikquellen unbekannt.'
      'Levels von Daniel Marschall, Patrick B'#252'ssecker und Andreas '
      'K'#252'belsbeck.')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
