inherited fmExporterParamsPersons: TfmExporterParamsPersons
  Caption = 'Personen exportieren'
  ClientHeight = 152
  ClientWidth = 324
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 340
  ExplicitHeight = 191
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 96
    Width = 324
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 127
    ExplicitWidth = 340
    inherited btCancel: TButton
      Left = 190
      ExplicitLeft = 204
    end
  end
  inherited pnTarget: TPanel
    Top = 68
    Width = 324
    TabOrder = 3
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 116
    ExplicitWidth = 338
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 239
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 454
    end
  end
  object cbShowInactivePersons: TCheckBox
    Left = 16
    Top = 13
    Width = 169
    Height = 17
    Caption = 'Inaktive Personen anzeigen'
    TabOrder = 1
  end
  object cbShowExternalPersons: TCheckBox
    Left = 16
    Top = 36
    Width = 169
    Height = 17
    Caption = 'Externe Personen anzeigen'
    TabOrder = 2
  end
end
