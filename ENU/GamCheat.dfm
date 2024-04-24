object CheatForm: TCheatForm
  Left = 275
  Top = 165
  BorderStyle = bsDialog
  Caption = 'Cheats'
  ClientHeight = 233
  ClientWidth = 313
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 152
    Height = 13
    Caption = 'Please enter a cheat code'
  end
  object Label3: TLabel
    Left = 200
    Top = 8
    Width = 106
    Height = 13
    Cursor = crHandPoint
    Caption = 'Ask author'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    Visible = False
    OnClick = Label3Click
  end
  object CheatEdit: TEdit
    Left = 8
    Top = 32
    Width = 297
    Height = 21
    Cursor = crIBeam
    Ctl3D = True
    ParentCtl3D = False
    PasswordChar = '*'
    TabOrder = 0
    OnKeyPress = CheatEditKeyPress
  end
  object OKBtn: TButton
    Left = 192
    Top = 200
    Width = 115
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = OKBtnClick
  end
  object AbbBtn: TButton
    Left = 8
    Top = 200
    Width = 113
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = AbbBtnClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 64
    Width = 297
    Height = 129
    Caption = 'Activated cheats'
    TabOrder = 3
    object Label2: TLabel
      Left = 8
      Top = 104
      Width = 89
      Height = 13
      Cursor = crHandPoint
      Caption = 'Disable cheat'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = Label2Click
    end
    object CheatBox: TListBox
      Left = 8
      Top = 24
      Width = 281
      Height = 73
      ItemHeight = 13
      TabOrder = 0
    end
  end
end
