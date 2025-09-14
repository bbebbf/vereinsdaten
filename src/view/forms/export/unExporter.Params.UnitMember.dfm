inherited fmExporterParamsUnitMember: TfmExporterParamsUnitMember
  Caption = 'Einheiten und Personen exportieren'
  ClientHeight = 205
  ClientWidth = 425
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 441
  ExplicitHeight = 244
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 149
    Width = 425
    StyleElements = [seFont, seClient, seBorder]
    ExplicitLeft = 8
    ExplicitTop = 158
    ExplicitWidth = 513
    inherited btCancel: TButton
      Left = 293
      ExplicitLeft = 379
    end
  end
  inherited pnTarget: TPanel
    Top = 121
    Width = 425
    TabOrder = 4
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 150
    ExplicitWidth = 511
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 342
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 384
    end
  end
  object rbAllUnits: TRadioButton
    Left = 16
    Top = 24
    Width = 476
    Height = 17
    Caption = 'Alle Einheiten exportieren'
    TabOrder = 1
  end
  object rbAllCheckedUnits: TRadioButton
    Left = 16
    Top = 56
    Width = 476
    Height = 17
    Caption = 'Ausgew'#228'hlte Einheiten exportieren'
    TabOrder = 2
  end
  object rbSelectedUnitDetails: TRadioButton
    Left = 16
    Top = 88
    Width = 476
    Height = 17
    Caption = 'Ausgew'#228'hlte Einheit exportieren mit Details'
    TabOrder = 3
  end
end
