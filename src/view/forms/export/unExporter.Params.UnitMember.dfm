inherited fmExporterParamsUnitMember: TfmExporterParamsUnitMember
  Caption = 'Einheiten und Personen exportieren'
  ClientHeight = 211
  ClientWidth = 425
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 441
  ExplicitHeight = 250
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 155
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
    Top = 101
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
  object rbAllUnits: TRadioButton [2]
    Left = 16
    Top = 24
    Width = 476
    Height = 17
    Caption = 'Alle Einheiten exportieren'
    TabOrder = 1
  end
  object rbAllCheckedUnits: TRadioButton [3]
    Left = 16
    Top = 48
    Width = 476
    Height = 17
    Caption = 'Ausgew'#228'hlte Einheiten exportieren'
    TabOrder = 2
  end
  object rbSelectedUnitDetails: TRadioButton [4]
    Left = 16
    Top = 72
    Width = 476
    Height = 17
    Caption = 'Ausgew'#228'hlte Einheit exportieren mit Details'
    TabOrder = 3
  end
end
