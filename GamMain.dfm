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
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
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
      object Cheat: TMenuItem
        Caption = '&Cheatverwaltung...'
        Enabled = False
        OnClick = CheatClick
      end
      object Leer2: TMenuItem
        Caption = '-'
      end
      object Spielstand: TMenuItem
        Caption = '&Spielst'#228'nde...'
        OnClick = SpielstandClick
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
      object OptionFullScreen: TMenuItem
        Caption = '&Vollbildschirm'
        ShortCut = 116
        OnClick = OptionFullScreenClick
      end
      object OptionBreitbild: TMenuItem
        Caption = '&Breitbild'
        Checked = True
        ShortCut = 117
        OnClick = OptionBreitbildClick
      end
      object Leer4: TMenuItem
        Caption = '-'
        GroupIndex = 1
      end
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
          OnClick = LeichtClick
        end
        object Mittel: TMenuItem
          Caption = '&Mittel'
          Checked = True
          RadioItem = True
          OnClick = MittelClick
        end
        object Schwer: TMenuItem
          Caption = '&Schwer'
          RadioItem = True
          OnClick = SchwerClick
        end
        object Master: TMenuItem
          Caption = 'Meist&er'
          RadioItem = True
          OnClick = MasterClick
        end
      end
    end
    object Hilfe: TMenuItem
      Caption = '&Hilfe'
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
