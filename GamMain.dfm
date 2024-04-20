object MainForm: TMainForm
  Left = 320
  Top = 196
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'SpaceMission'
  ClientHeight = 562
  ClientWidth = 640
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
      Caption = '&Spiel'
      object GameStart: TMenuItem
        Caption = '&Zur'#252'ck zum Hauptmen'#252
        Enabled = False
        ShortCut = 112
        OnClick = GameStartClick
      end
      object Neustart: TMenuItem
        Caption = '&Neustart'
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
        Caption = '&Spielst'#228'nde...'
        ShortCut = 115
        OnClick = SpielstandClick
      end
      object Cheat: TMenuItem
        Caption = '&Cheatverwaltung...'
        Enabled = False
        ShortCut = 116
        OnClick = CheatClick
      end
      object Leer3: TMenuItem
        Caption = '-'
      end
      object Beenden: TMenuItem
        Caption = '&Beenden'
        ShortCut = 32883
        OnClick = BeendenClick
      end
    end
    object Einstellungen: TMenuItem
      Caption = '&Einstellungen'
      object OptionSound: TMenuItem
        Caption = '&Soundeffekte'
        Checked = True
        GroupIndex = 1
        OnClick = OptionSoundClick
      end
      object OptionMusic: TMenuItem
        Caption = '&Hintergrundmusik'
        Checked = True
        GroupIndex = 1
        OnClick = OptionMusicClick
      end
      object Leer5: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object Spielgeschwindigkeit: TMenuItem
        Caption = '&Spielgeschwindigkeit'
        Enabled = False
        GroupIndex = 1
        object Leicht: TMenuItem
          Caption = '&Leicht'
          RadioItem = True
          ShortCut = 49
          OnClick = LeichtClick
        end
        object Mittel: TMenuItem
          Caption = '&Mittel'
          Checked = True
          RadioItem = True
          ShortCut = 50
          OnClick = MittelClick
        end
        object Schwer: TMenuItem
          Caption = '&Schwer'
          RadioItem = True
          ShortCut = 51
          OnClick = SchwerClick
        end
        object Master: TMenuItem
          Caption = 'Meist&er'
          RadioItem = True
          ShortCut = 52
          OnClick = MasterClick
        end
      end
    end
    object Hilfe: TMenuItem
      Caption = '&Hilfe'
      object Hilfe1: TMenuItem
        Caption = 'Allgemeines'
        GroupIndex = 1
        Hint = 'Help\Allgemeines.md'
        OnClick = HilfeTopicClick
      end
      object Wasgibtesneues1: TMenuItem
        Caption = 'Was gibt es Neues?'
        GroupIndex = 1
        Hint = 'Help\Neuerungen.md'
        OnClick = HilfeTopicClick
      end
      object N1: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object CheckUpdates: TMenuItem
        Caption = 'Auf Updates pr'#252'fen...'
        GroupIndex = 1
        OnClick = CheckUpdatesClick
      end
      object Leer6: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
      object Informationen: TMenuItem
        Caption = '&Informationen...'
        GroupIndex = 1
        OnClick = InformationenClick
      end
    end
  end
end
