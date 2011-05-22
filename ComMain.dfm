object MainForm: TMainForm
  Left = 268
  Top = 153
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SpaceMission Levelcompiler'
  ClientHeight = 201
  ClientWidth = 345
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 136
    Width = 329
    Height = 2
    Shape = bsBottomLine
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 295
    Height = 26
    Caption = 
      'Der SpaceMission Levelcompiler wandelt die Levels Ihrer alten'#13#10'S' +
      'paceMission-Version in die aktuelle Version 1.0 / 1.1 um.'
    Transparent = True
  end
  object Label2: TLabel
    Left = 8
    Top = 184
    Width = 322
    Height = 13
    Caption = 
      'Die korrekte Umschreibung der Levels kann nicht garantiert werde' +
      'n!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Run: TButton
    Left = 176
    Top = 96
    Width = 161
    Height = 25
    Caption = 'Compiler starten'
    Default = True
    TabOrder = 0
    OnClick = RunClick
  end
  object Button1: TButton
    Left = 8
    Top = 152
    Width = 105
    Height = 25
    Caption = 'Eingabeordner'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 120
    Top = 152
    Width = 105
    Height = 25
    Caption = 'Ausgabeordner'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 232
    Top = 152
    Width = 105
    Height = 25
    Caption = 'Levelordner'
    TabOrder = 3
    OnClick = Button3Click
  end
  object comb: TComboBox
    Left = 8
    Top = 96
    Width = 161
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
    Items.Strings = (
      'Version 0.2 --> Version 0.3'
      'Version 0.2 --> Version 0.4'
      'Version 0.3 --> Version 0.4'
      'Version 0.4 --> Version 1.0'
      'Version 0.2 --> Version 1.0'
      'Version 0.3 --> Version 1.0')
  end
  object gauge: TProgressBar
    Left = 8
    Top = 48
    Width = 329
    Height = 33
    Smooth = True
    TabOrder = 5
  end
end
