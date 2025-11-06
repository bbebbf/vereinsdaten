inherited fmExporterParamsPersons: TfmExporterParamsPersons
  Caption = 'Personen exportieren'
  ClientHeight = 173
  ClientWidth = 394
  ExplicitWidth = 412
  ExplicitHeight = 220
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 117
    Width = 394
    ExplicitTop = 109
    ExplicitWidth = 392
    inherited btCancel: TButton
      Left = 274
      ExplicitLeft = 272
    end
  end
  inherited pnTarget: TPanel
    Top = 63
    Width = 394
    TabOrder = 3
    ExplicitTop = 63
    ExplicitWidth = 394
    inherited cbTargets: TComboBox
      Width = 323
      ExplicitWidth = 323
    end
    inherited edFilePath: TEdit
      Width = 287
      ExplicitWidth = 285
    end
    inherited btOpenFileDlg: TButton
      Left = 347
      ExplicitLeft = 345
    end
  end
  object cbShowInactivePersons: TCheckBox [2]
    Left = 16
    Top = 13
    Width = 169
    Height = 17
    Caption = 'Inaktive Personen anzeigen'
    TabOrder = 1
  end
  object cbShowExternalPersons: TCheckBox [3]
    Left = 16
    Top = 36
    Width = 169
    Height = 17
    Caption = 'Externe Personen anzeigen'
    TabOrder = 2
  end
end
