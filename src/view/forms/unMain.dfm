object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'fmMain'
  ClientHeight = 433
  ClientWidth = 622
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object shaTestConnectionWarning: TShape
    Left = 0
    Top = 389
    Width = 622
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
    Top = 414
    Width = 622
    Height = 19
    Panels = <>
    SimplePanel = True
    ExplicitTop = 406
    ExplicitWidth = 620
  end
  object MainMenu: TMainMenu
    Left = 40
    Top = 128
    object Stammdaten1: TMenuItem
      Caption = 'Stammdaten'
      object acMasterdataPerson1: TMenuItem
        Action = acMasterdataPerson
      end
      object Einheitenbearbeiten1: TMenuItem
        Action = acMasterdataUnit
      end
      object Adressenbearbeiten1: TMenuItem
        Action = acMasterdataAddress
      end
      object Rollenbearbeiten1: TMenuItem
        Action = acMasterdataRole
      end
      object Vereinsdatenbearbeiten1: TMenuItem
        Action = acMasterdataTenant
      end
    end
    object Berichte1: TMenuItem
      Caption = 'Berichte'
      object Personen1: TMenuItem
        Action = acReportPersons
      end
      object acReportMemberUnits1: TMenuItem
        Action = acReportMemberUnits
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object EinheitenundPersonen1: TMenuItem
        Action = acReportUnitMembers
      end
      object RollenundEinheiten1: TMenuItem
        Action = acReportUnitRoles
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object miReportClubMembers: TMenuItem
        Action = acReportClubMembers
      end
      object Geburtstagsliste1: TMenuItem
        Action = acReportBirthdays
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
    object acMasterdataPerson: TAction
      Caption = 'Personen bearbeiten'
      OnExecute = acMasterdataPersonExecute
    end
    object acMasterdataUnit: TAction
      Caption = 'Einheiten bearbeiten'
      OnExecute = acMasterdataUnitExecute
    end
    object acMasterdataRole: TAction
      Caption = 'Rollen bearbeiten'
      OnExecute = acMasterdataRoleExecute
    end
    object acReportClubMembers: TAction
      Caption = 'Vereinsmitglieder'
      OnExecute = acReportClubMembersExecute
    end
    object acReportUnitMembers: TAction
      Caption = 'Einheiten und Personen'
      OnExecute = acReportUnitMembersExecute
    end
    object acMasterdataTenant: TAction
      Caption = 'Vereinsdaten bearbeiten'
      OnExecute = acMasterdataTenantExecute
    end
    object acReportUnitRoles: TAction
      Caption = 'Rollen und Einheiten'
      OnExecute = acReportUnitRolesExecute
    end
    object acReportMemberUnits: TAction
      Caption = 'Personen und Einheiten'
      OnExecute = acReportMemberUnitsExecute
    end
    object acReportPersons: TAction
      Caption = 'Personen'
      OnExecute = acReportPersonsExecute
    end
    object acReportBirthdays: TAction
      Caption = 'Geburtstagsliste'
      OnExecute = acReportBirthdaysExecute
    end
  end
end
