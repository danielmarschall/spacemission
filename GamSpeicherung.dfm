object SpeicherungForm: TSpeicherungForm
  Left = 280
  Top = 152
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Spielst'#228'nde'
  ClientHeight = 425
  ClientWidth = 451
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
  object Bevel1: TBevel
    Left = 8
    Top = 56
    Width = 433
    Height = 2
    Shape = bsBottomLine
  end
  object Label2: TLabel
    Left = 8
    Top = 72
    Width = 58
    Height = 13
    Caption = 'Spielst'#228'nde:'
  end
  object Label3: TLabel
    Left = 8
    Top = 336
    Width = 67
    Height = 13
    Caption = 'Informationen:'
  end
  object Label1: TLabel
    Left = 8
    Top = 20
    Width = 78
    Height = 13
    Caption = 'Spielstandname:'
    Enabled = False
  end
  object LadenBtn: TButton
    Left = 336
    Top = 72
    Width = 105
    Height = 25
    Caption = '&Laden'
    Enabled = False
    TabOrder = 0
    OnClick = LadenBtnClick
  end
  object LoeschenBtn: TButton
    Left = 336
    Top = 104
    Width = 105
    Height = 25
    Caption = 'L'#246'&schen'
    Enabled = False
    TabOrder = 1
    OnClick = LoeschenBtnClick
  end
  object AktualisierenBtn: TButton
    Left = 336
    Top = 144
    Width = 105
    Height = 25
    Caption = '&Aktualisieren'
    TabOrder = 2
    OnClick = DsFancyButton2Click
  end
  object SpeichernBtn: TButton
    Left = 336
    Top = 16
    Width = 105
    Height = 25
    Caption = '&Speichern'
    Enabled = False
    TabOrder = 3
    OnClick = SpeichernBtnClick
  end
  object AbbrechenBtn: TButton
    Left = 336
    Top = 392
    Width = 105
    Height = 25
    Cancel = True
    Caption = 'Schli&e'#223'en'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = AbbrechenBtnClick
  end
  object LevelListBox: TListBox
    Left = 112
    Top = 72
    Width = 201
    Height = 249
    ItemHeight = 13
    TabOrder = 5
    OnClick = LevelListBoxClick
    OnDblClick = LevelListBoxDblClick
  end
  object LevelName: TEdit
    Left = 112
    Top = 16
    Width = 201
    Height = 21
    Enabled = False
    TabOrder = 6
  end
  object ElPanel1: TPanel
    Left = 112
    Top = 336
    Width = 201
    Height = 81
    BevelOuter = bvLowered
    Color = clWindow
    TabOrder = 7
    object li4a: TLabel
      Left = 8
      Top = 56
      Width = 33
      Height = 13
      Caption = 'Leben:'
    end
    object li1: TLabel
      Left = 8
      Top = 8
      Width = 17
      Height = 13
      Caption = 'n/a'
    end
    object li3b: TLabel
      Left = 96
      Top = 40
      Width = 17
      Height = 13
      Caption = 'n/a'
    end
    object li3a: TLabel
      Left = 8
      Top = 40
      Width = 29
      Height = 13
      Caption = 'Level:'
    end
    object li4b: TLabel
      Left = 96
      Top = 56
      Width = 17
      Height = 13
      Caption = 'n/a'
    end
    object liu: TLabel
      Left = 8
      Top = 8
      Width = 156
      Height = 13
      Caption = 'Der Spielstand ist nicht einlesbar!'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object liw: TLabel
      Left = 8
      Top = 8
      Width = 139
      Height = 13
      Caption = 'W'#228'hlen Sie einen Spielstand.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object li2a: TLabel
      Left = 8
      Top = 24
      Width = 37
      Height = 13
      Caption = 'Punkte:'
    end
    object li2b: TLabel
      Left = 96
      Top = 24
      Width = 17
      Height = 13
      Caption = 'n/a'
    end
  end
end
