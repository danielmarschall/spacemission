object LevelForm: TLevelForm
  Left = 195
  Top = 103
  BorderStyle = bsDialog
  Caption = 'Level properties'
  ClientHeight = 251
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poMainFormCenter
  OnHide = FormHide
  OnShow = FormShow
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
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = ElPopupButton2Click
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 369
    Height = 193
    Caption = 'Editor settings'
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 32
      Width = 106
      Height = 13
      Caption = 'Size of the map:'
    end
    object Label2: TLabel
      Left = 16
      Top = 136
      Width = 124
      Height = 13
      Caption = 'Internal level name:'
    end
    object Label3: TLabel
      Left = 16
      Top = 168
      Width = 57
      Height = 13
      Caption = 'Level author:'
    end
    object Panel1: TPanel
      Left = 16
      Top = 56
      Width = 329
      Height = 57
      Color = clInfoBk
      ParentBackground = False
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
        Width = 228
        Height = 39
        Caption = 'The size if only relevant for the editor, not the game.'
        Color = clInfoBk
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
    end
    object Groesse: TSpinEdit
      Left = 144
      Top = 28
      Width = 121
      Height = 22
      MaxValue = 65000
      MinValue = 100
      TabOrder = 1
      Value = 1200
    end
    object LevName: TEdit
      Left = 167
      Top = 133
      Width = 178
      Height = 21
      TabOrder = 2
    end
    object LevAuthor: TEdit
      Left = 167
      Top = 160
      Width = 178
      Height = 21
      TabOrder = 3
    end
  end
end
