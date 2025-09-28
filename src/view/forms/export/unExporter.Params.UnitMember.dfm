inherited fmExporterParamsUnitMember: TfmExporterParamsUnitMember
  Caption = 'Einheiten und Personen exportieren'
  ClientHeight = 228
  ClientWidth = 425
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 441
  ExplicitHeight = 267
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 172
    Width = 425
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 164
    ExplicitWidth = 423
    inherited btCancel: TButton
      Left = 307
      ExplicitLeft = 305
    end
  end
  inherited pnTarget: TPanel
    Top = 118
    Width = 425
    TabOrder = 4
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 110
    ExplicitWidth = 423
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lbFilePath: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 356
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 354
    end
    inherited edFilePath: TEdit
      Width = 318
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 316
    end
    inherited btOpenFileDlg: TButton
      Left = 380
      ExplicitLeft = 378
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
