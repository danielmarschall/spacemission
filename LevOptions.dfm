object LevelForm: TLevelForm
  Left = 195
  Top = 103
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Leveleigenschaften'
  ClientHeight = 252
  ClientWidth = 388
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
    Left = 280
    Top = 216
    Width = 99
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = ElPopupButton1Click
  end
  object ElPopupButton2: TButton
    Left = 8
    Top = 216
    Width = 99
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    TabOrder = 1
    OnClick = ElPopupButton2Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 369
    Height = 193
    Caption = 'Editoreigenschaften'
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 32
      Width = 106
      Height = 13
      Caption = 'Gr'#246#223'e des Spielfeldes:'
    end
    object Panel1: TPanel
      Left = 16
      Top = 56
      Width = 329
      Height = 57
      Color = clInfoBk
      TabOrder = 0
      object ElLabel1: TLabel
        Left = 8
        Top = 8
        Width = 55
        Height = 13
        Caption = 'Information:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsUnderline]
        ParentFont = False
      end
      object ElLabel2: TLabel
        Left = 80
        Top = 10
        Width = 225
        Height = 39
        Caption = 
          'Die Spielfeldgr'#246#223'e wird nur von dem Leveleditor'#13#10'ben'#246'tigt. Das '#228 +
          'ndern dieser Gr'#246#223'e wirkt sich'#13#10'nicht auf die Gr'#246#223'e der Levels au' +
          's.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
    end
    object GroesseEdt: TEdit
      Left = 144
      Top = 28
      Width = 185
      Height = 21
      MaxLength = 4
      TabOrder = 1
      Text = '1200'
      OnChange = GroesseEdtChange
      OnKeyPress = GroesseEdtKeyPress
    end
    object Groesse: TUpDown
      Left = 328
      Top = 30
      Width = 17
      Height = 19
      Max = 9999
      Position = 1
      TabOrder = 2
      OnClick = GroesseClick
    end
  end
end
