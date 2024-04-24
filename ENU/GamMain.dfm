object MainForm: TMainForm
  Left = 320
  Top = 196
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SpaceMission'
  ClientHeight = 561
  ClientWidth = 636
  Color = clBlack
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clYellow
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 13
  object MainMenu: TMainMenu
    Left = 24
    Top = 8
    object Spiel: TMenuItem
      Caption = '&Game'
      object GameStart: TMenuItem
        Caption = 'Back to &main menu'
        Enabled = False
        ShortCut = 112
        OnClick = GameStartClick
      end
      object Neustart: TMenuItem
        Caption = '&Restart'
        Enabled = False
        ShortCut = 113
        OnClick = NeustartClick
      end
      object GamePause: TMenuItem
        Caption = '&Pause'
        Enabled = False
        ShortCut = 114
        OnClick = GamePauseClick
      end
      object Leer1: TMenuItem
        Caption = '-'
      end
      object Spielstand: TMenuItem
        Caption = '&Savegames...'
        ShortCut = 115
        OnClick = SpielstandClick
      end
      object Cheat: TMenuItem
        Caption = '&Cheats...'
        Enabled = False
        ShortCut = 116
        OnClick = CheatClick
      end
      object Leer3: TMenuItem
        Caption = '-'
      end
      object Beenden: TMenuItem
        Caption = '&Exit'
        ShortCut = 32883
        OnClick = BeendenClick
      end
    end
    object Einstellungen: TMenuItem
      Caption = '&Settings'
      object OptionSound: TMenuItem
        Caption = '&Sound effects'
        Checked = True
        GroupIndex = 1
        OnClick = OptionSoundClick
      end
      object OptionMusic: TMenuItem
        Caption = '&Music'
        Checked = True
        GroupIndex = 1
        OnClick = OptionMusicClick
      end
      object Leer5: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object Spielgeschwindigkeit: TMenuItem
        Caption = '&Speed'
        Enabled = False
        GroupIndex = 1
        object Leicht: TMenuItem
          Caption = '&Easy'
          RadioItem = True
          ShortCut = 49
          OnClick = LeichtClick
        end
        object Mittel: TMenuItem
          Caption = '&Medium'
          Checked = True
          RadioItem = True
          ShortCut = 50
          OnClick = MittelClick
        end
        object Schwer: TMenuItem
          Caption = '&Hard'
          RadioItem = True
          ShortCut = 51
          OnClick = SchwerClick
        end
        object Master: TMenuItem
          Caption = '&Master'
          RadioItem = True
          ShortCut = 52
          OnClick = MasterClick
        end
      end
    end
    object Hilfe: TMenuItem
      Caption = '&Help'
      object Hilfe1: TMenuItem
        Caption = 'General topics'
        GroupIndex = 1
        Hint = 'Help\EN_General.md'
        OnClick = HilfeTopicClick
      end
      object Wasgibtesneues1: TMenuItem
        Caption = 'What'#39's new?'
        GroupIndex = 1
        Hint = 'Help\EN_Changelog.md'
        OnClick = HilfeTopicClick
      end
      object N1: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object CheckUpdates: TMenuItem
        Caption = 'Check for updates'
        GroupIndex = 1
        OnClick = CheckUpdatesClick
      end
      object Leer6: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object Informationen: TMenuItem
        Caption = '&About this game...'
        GroupIndex = 1
        OnClick = InformationenClick
      end
    end
  end
end
