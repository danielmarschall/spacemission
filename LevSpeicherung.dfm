object SpeicherungForm: TSpeicherungForm
  Left = 281
  Top = 153
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Levels'
  ClientHeight = 409
  ClientWidth = 449
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
    Width = 92
    Height = 13
    Caption = 'Levelinformationen:'
  end
  object Label1: TLabel
    Left = 8
    Top = 20
    Width = 78
    Height = 13
    Caption = 'Spielstandname:'
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
    TabOrder = 3
    OnClick = SpeichernBtnClick
  end
  object AbbrechenBtn: TButton
    Left = 336
    Top = 376
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
  object ElPanel1: TPanel
    Left = 112
    Top = 336
    Width = 201
    Height = 65
    BevelOuter = bvLowered
    Color = clWindow
    TabOrder = 6
    object li3a: TLabel
      Left = 8
      Top = 40
      Width = 32
      Height = 13
      Caption = 'Gr'#246#223'e:'
    end
    object li1b: TLabel
      Left = 96
      Top = 8
      Width = 17
      Height = 13
      Caption = 'n/a'
    end
    object li1a: TLabel
      Left = 8
      Top = 8
      Width = 47
      Height = 13
      Caption = 'Einheiten:'
    end
    object li2b: TLabel
      Left = 96
      Top = 24
      Width = 17
      Height = 13
      Caption = 'n/a'
    end
    object li2a: TLabel
      Left = 8
      Top = 24
      Width = 26
      Height = 13
      Caption = 'Boss:'
    end
    object li3b: TLabel
      Left = 96
      Top = 40
      Width = 17
      Height = 13
      Caption = 'n/a'
    end
    object liu: TLabel
      Left = 8
      Top = 8
      Width = 135
      Height = 13
      Caption = 'Das Level ist nicht einlesbar!'
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
      Width = 104
      Height = 13
      Caption = 'W'#228'hlen Sie ein Level.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
  end
  object SpinEditEdt: TEdit
    Left = 112
    Top = 20
    Width = 185
    Height = 21
    MaxLength = 4
    TabOrder = 7
    Text = '1'
    OnChange = SpinEditEdtChange
    OnKeyPress = SpinEditEdtKeyPress
  end
  object SpinEdit: TUpDown
    Left = 296
    Top = 22
    Width = 17
    Height = 19
    Min = 1
    Max = 9999
    Position = 1
    TabOrder = 8
    OnClick = SpinEditClick
  end
end
