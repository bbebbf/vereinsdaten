inherited fmExporterParamsMemberUnit: TfmExporterParamsMemberUnit
  Caption = 'Personen und Einheiten exportieren'
  ClientHeight = 234
  ClientWidth = 423
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 439
  ExplicitHeight = 273
  TextHeight = 15
  object lbInactiveButActiveUntil: TLabel [0]
    Left = 271
    Top = 88
    Width = 48
    Height = 15
    Caption = 'Aktiv bis:'
  end
  inherited pnBottom: TPanel
    Top = 178
    Width = 423
    TabOrder = 6
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 156
    ExplicitWidth = 421
    inherited btCancel: TButton
      Left = 305
      ExplicitLeft = 303
    end
  end
  inherited pnTarget: TPanel
    Top = 124
    Width = 423
    TabOrder = 5
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 102
    ExplicitWidth = 421
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lbFilePath: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 348
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 346
    end
    inherited edFilePath: TEdit
      Width = 310
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 308
    end
    inherited btOpenFileDlg: TButton
      Left = 372
      ExplicitLeft = 370
    end
  end
  object rbActiveMembersOnly: TRadioButton [3]
    Left = 16
    Top = 65
    Width = 476
    Height = 17
    Caption = 'Nur aktive Verbindungen exportieren'
    TabOrder = 2
    TabStop = True
    OnClick = rbInactiveMembersTooClick
  end
  object rbInactiveMembersToo: TRadioButton [4]
    Left = 16
    Top = 88
    Width = 241
    Height = 17
    Caption = 'Auch inaktive Verbindungen exportieren'
    TabOrder = 3
    TabStop = True
    OnClick = rbInactiveMembersTooClick
  end
  object deInactiveButActiveUntil: TDateEdit [5]
    Left = 328
    Top = 85
    Width = 76
    Height = 23
    TabOrder = 4
  end
  object cbShowInactivePersons: TCheckBox [6]
    Left = 16
    Top = 13
    Width = 169
    Height = 17
    Caption = 'Inaktive Personen anzeigen'
    TabOrder = 0
  end
  object cbShowExternalPersons: TCheckBox [7]
    Left = 16
    Top = 36
    Width = 169
    Height = 17
    Caption = 'Externe Personen anzeigen'
    TabOrder = 1
  end
  inherited dlgSave: TSaveDialog
    Left = 344
    Top = 136
  end
end
