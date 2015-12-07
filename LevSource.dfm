object SourceForm: TSourceForm
  Left = 197
  Top = 104
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Levelquelltext'
  ClientHeight = 392
  ClientWidth = 489
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
  object ElLabel1: TLabel
    Left = 8
    Top = 8
    Width = 85
    Height = 13
    Caption = 'Tempor'#228'rer Code:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object ElLabel2: TLabel
    Left = 248
    Top = 8
    Width = 84
    Height = 13
    Caption = 'Endg'#252'ltiger Code:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 368
    Width = 104
    Height = 13
    Cursor = crHandPoint
    Caption = 'Weitere Informationen'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label1Click
  end
  object Label2: TLabel
    Left = 116
    Top = 368
    Width = 165
    Height = 13
    Caption = #252'ber den Aufbau von Quelltexten...'
  end
  object ElPopupButton1: TButton
    Left = 392
    Top = 360
    Width = 89
    Height = 25
    Cancel = True
    Caption = 'Schlie'#223'en'
    Default = True
    TabOrder = 0
    OnClick = ElPopupButton1Click
  end
  object ListBox1: TListBox
    Left = 8
    Top = 32
    Width = 233
    Height = 321
    ItemHeight = 13
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 248
    Top = 32
    Width = 233
    Height = 321
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
