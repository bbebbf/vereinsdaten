inherited fmExporterParamsUnitMember: TfmExporterParamsUnitMember
  Caption = 'Einheiten und Personen exportieren'
  ClientHeight = 186
  ClientWidth = 513
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 529
  ExplicitHeight = 225
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 130
    Width = 513
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 122
    ExplicitWidth = 511
    inherited btCancel: TButton
      Left = 383
      ExplicitLeft = 381
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
