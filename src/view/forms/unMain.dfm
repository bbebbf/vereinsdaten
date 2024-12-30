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
  object shaTestConnectionWarning: TShape
    Left = 0
    Top = 397
    Width = 624
    Height = 25
    Align = alBottom
    Brush.Color = clHighlight
    Pen.Style = psClear
    ExplicitLeft = 192
    ExplicitTop = 296
    ExplicitWidth = 257
  end
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
      object Adressenbearbeiten1: TMenuItem
        Action = acMasterdataAddress
      end
      object Einheitenbearbeiten1: TMenuItem
        Action = acMasterdataUnit
      end
      object Rollenbearbeiten1: TMenuItem
        Action = acMasterdataRole
      end
    end
  end
  object ActionList: TActionList
    Left = 40
    Top = 208
    object acMasterdataAddress: TAction
      Caption = 'Adressen bearbeiten'
      OnExecute = acMasterdataAddressExecute
    end
    object acMasterdataUnit: TAction
      Caption = 'Einheiten bearbeiten'
      OnExecute = acMasterdataUnitExecute
    end
    object acMasterdataRole: TAction
      Caption = 'Rollen bearbeiten'
      OnExecute = acMasterdataRoleExecute
    end
  end
end
