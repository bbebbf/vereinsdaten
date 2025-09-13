inherited fmExporterParamsPersons: TfmExporterParamsPersons
  Caption = 'Personen exportieren'
  ClientHeight = 127
  ClientWidth = 272
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 288
  ExplicitHeight = 166
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 71
    Width = 272
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 63
    ExplicitWidth = 270
    inherited btCancel: TButton
      Left = 142
      ExplicitLeft = 140
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
