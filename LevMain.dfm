object MainForm: TMainForm
  Left = 217
  Top = 117
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Leveleditor'
  ClientHeight = 536
  ClientWidth = 753
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  OldCreateOrder = True
  Position = poDesktopCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseMove = DXDrawMouseMove
  OnShow = FormShow
  PixelsPerInch = 106
  TextHeight = 13
  object Bevel1: TBevel
    Left = 648
    Top = 200
    Width = 97
    Height = 2
    Shape = bsBottomLine
  end
  object Bevel2: TBevel
    Left = 648
    Top = 392
    Width = 97
    Height = 2
    Shape = bsBottomLine
  end
  object SelLabel: TLabel
    Left = 648
    Top = 0
    Width = 43
    Height = 13
    Caption = 'Auswahl:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnMouseMove = DXDrawMouseMove
  end
  object Bevel3: TBevel
    Left = 648
    Top = 320
    Width = 97
    Height = 2
    Shape = bsBottomLine
  end
  object SLabel1a: TLabel
    Left = 652
    Top = 424
    Width = 47
    Height = 13
    Caption = 'Einheiten:'
    OnMouseMove = DXDrawMouseMove
  end
  object SLabel2a: TLabel
    Left = 652
    Top = 440
    Width = 26
    Height = 13
    Caption = 'Boss:'
    OnMouseMove = DXDrawMouseMove
  end
  object SLabel1b: TLabel
    Left = 720
    Top = 424
    Width = 6
    Height = 13
    Caption = '0'
    OnMouseMove = DXDrawMouseMove
  end
  object SLabel2b: TLabel
    Left = 720
    Top = 440
    Width = 22
    Height = 13
    Caption = 'Nein'
    OnMouseMove = DXDrawMouseMove
  end
  object SLabel0: TLabel
    Left = 648
    Top = 400
    Width = 84
    Height = 13
    Caption = 'Level-Information:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnMouseMove = DXDrawMouseMove
  end
  object SLabel3a: TLabel
    Left = 652
    Top = 456
    Width = 32
    Height = 13
    Caption = 'Gr'#246#223'e:'
    OnMouseMove = DXDrawMouseMove
  end
  object SLabel3b: TLabel
    Left = 720
    Top = 456
    Width = 24
    Height = 13
    Caption = '1200'
    OnMouseMove = DXDrawMouseMove
  end
  object SLabel4a: TLabel
    Left = 652
    Top = 480
    Width = 60
    Height = 13
    Caption = 'Gespeichert:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 150
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnMouseMove = DXDrawMouseMove
  end
  object SLabel4b: TLabel
    Left = 720
    Top = 480
    Width = 22
    Height = 13
    Caption = 'Nein'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 150
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnMouseMove = DXDrawMouseMove
  end
  object LivesLabel: TLabel
    Left = 648
    Top = 332
    Width = 33
    Height = 13
    Caption = 'Leben:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnMouseMove = DXDrawMouseMove
  end
  object Enemy1: TRadioButton
    Left = 652
    Top = 24
    Width = 73
    Height = 17
    Caption = 'Attackierer'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = EnemyClick
    OnMouseMove = DXDrawMouseMove
  end
  object Enemy2: TRadioButton
    Left = 652
    Top = 48
    Width = 82
    Height = 17
    Caption = 'Attackierer 2'
    TabOrder = 1
    OnClick = EnemyClick
    OnMouseMove = DXDrawMouseMove
  end
  object Enemy3: TRadioButton
    Left = 652
    Top = 72
    Width = 82
    Height = 17
    Caption = 'Attackierer 3'
    TabOrder = 2
    OnClick = EnemyClick
    OnMouseMove = DXDrawMouseMove
  end
  object Enemy4: TRadioButton
    Left = 652
    Top = 96
    Width = 55
    Height = 17
    Caption = 'Meteor'
    TabOrder = 3
    OnClick = EnemyClick
    OnMouseMove = DXDrawMouseMove
  end
  object Enemy5: TRadioButton
    Left = 652
    Top = 120
    Width = 44
    Height = 17
    Caption = 'UFO'
    TabOrder = 4
    OnClick = EnemyClick
    OnMouseMove = DXDrawMouseMove
  end
  object Enemy6: TRadioButton
    Left = 652
    Top = 144
    Width = 53
    Height = 17
    Caption = 'UFO 2'
    TabOrder = 5
    OnClick = EnemyClick
    OnMouseMove = DXDrawMouseMove
  end
  object Enemy7: TRadioButton
    Left = 652
    Top = 168
    Width = 45
    Height = 17
    Caption = 'Boss'
    TabOrder = 6
    OnClick = EnemyClick
    OnMouseMove = DXDrawMouseMove
  end
  object ScrollBar: TScrollBar
    Left = 0
    Top = 480
    Width = 640
    Height = 17
    Max = 1200
    PageSize = 0
    TabOrder = 7
    OnScroll = ScrollBarScroll
  end
  object SelPanel: TPanel
    Left = 652
    Top = 216
    Width = 89
    Height = 89
    Color = clWhite
    TabOrder = 8
    OnMouseMove = DXDrawMouseMove
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 610
      Height = 88
      AutoSize = True
      OnMouseMove = DXDrawMouseMove
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 517
    Width = 753
    Height = 19
    Panels = <>
    SimpleText = 
      ' Zeigen Sie mit dem Mauszeiger auf eine Einheit, um deren Eigens' +
      'chaften anzuzeigen...'
    OnMouseMove = DXDrawMouseMove
  end
  object LivesEdt: TEdit
    Left = 648
    Top = 360
    Width = 73
    Height = 21
    TabOrder = 10
    Text = '1'
    OnChange = LivesEdtChange
    OnKeyPress = LivesEdtKeyPress
    OnMouseMove = DXDrawMouseMove
  end
  object Lives: TUpDown
    Left = 720
    Top = 360
    Width = 17
    Height = 19
    Min = 1
    Max = 999
    Position = 1
    TabOrder = 11
    OnClick = LivesClick
    OnMouseMove = DXDrawMouseMove
  end
  object MainMenu: TMainMenu
    Left = 8
    Top = 8
    object Spiel: TMenuItem
      Caption = '&Datei'
      object Level: TMenuItem
        Caption = '&Verwaltung...'
        ShortCut = 115
        OnClick = LevelClick
      end
      object Quelltext1: TMenuItem
        Caption = '&Quelltext...'
        ShortCut = 116
        OnClick = Quelltext1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Neu: TMenuItem
        Caption = '&Neu'
        ShortCut = 117
        OnClick = NeuClick
      end
      object Spielfelderweitern1: TMenuItem
        Caption = 'Leveleigenschaften...'
        ShortCut = 118
        OnClick = Spielfelderweitern1Click
      end
      object Leer1: TMenuItem
        Caption = '-'
      end
      object Beenden: TMenuItem
        Caption = '&Beenden'
        ShortCut = 32883
        OnClick = BeendenClick
      end
    end
    object Hilfe: TMenuItem
      Caption = '&Hilfe'
      object Mitarbeiter: TMenuItem
        Caption = '&Mitwirkende...'
        ShortCut = 120
        OnClick = MitarbeiterClick
      end
      object Leer2: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object Informationen: TMenuItem
        Caption = '&Informationen...'
        GroupIndex = 1
        ShortCut = 121
        OnClick = InformationenClick
      end
    end
  end
end
