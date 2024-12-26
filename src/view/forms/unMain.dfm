object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'fmMain'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object StatusBar: TStatusBar
    Left = 0
    Top = 422
    Width = 624
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 414
    ExplicitWidth = 622
  end
  object MainMenu: TMainMenu
    Left = 40
    Top = 128
    object Stammdaten1: TMenuItem
      Caption = 'Stammdaten'
    end
  end
  object ActionList: TActionList
    Left = 40
    Top = 208
  end
end
