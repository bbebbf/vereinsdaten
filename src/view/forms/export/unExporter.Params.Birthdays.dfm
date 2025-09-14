inherited fmExporterParamsBirthdays: TfmExporterParamsBirthdays
  Caption = 'Geburtstage exportieren'
  ClientHeight = 276
  ClientWidth = 449
  StyleElements = [seFont, seClient, seBorder]
  OnDestroy = nil
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 465
  ExplicitHeight = 315
  TextHeight = 15
  object lbFrom: TLabel [0]
    Left = 16
    Top = 22
    Width = 27
    Height = 15
    Caption = 'vom:'
  end
  object lbTo: TLabel [1]
    Left = 256
    Top = 22
    Width = 18
    Height = 15
    Caption = 'bis:'
  end
  inherited pnBottom: TPanel
    Top = 220
    Width = 449
    TabOrder = 4
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 175
    ExplicitWidth = 440
    inherited btCancel: TButton
      Left = 313
      ExplicitLeft = 304
    end
  end
  inherited pnTarget: TPanel
    Top = 192
    Width = 449
    TabOrder = 5
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 147
    ExplicitWidth = 440
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 362
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 353
    end
  end
  object deFromDate: TDateEdit
    Left = 56
    Top = 19
    Width = 121
    Height = 23
    TabOrder = 0
    OnValueChanged = deFromDateValueChanged
  end
  object deToDate: TDateEdit
    Left = 296
    Top = 19
    Width = 121
    Height = 23
    TabOrder = 1
    OnValueChanged = deToDateValueChanged
  end
  object cbConsiderBirthdaylistFlag: TCheckBox
    Left = 16
    Top = 59
    Width = 399
    Height = 17
    Caption = '"auf Geburtstagsliste anzeigen" ber'#252'cksichtigen'
    TabOrder = 2
  end
  object rgOrderBy: TRadioGroup
    Left = 16
    Top = 96
    Width = 401
    Height = 77
    Caption = 'Sortiert nach'
    Items.Strings = (
      'Datum'
      'Name')
    TabOrder = 3
  end
end
