inherited fmExporterParamsBirthdays: TfmExporterParamsBirthdays
  Caption = 'Geburtstage exportieren'
  ClientHeight = 239
  ClientWidth = 442
  StyleElements = [seFont, seClient, seBorder]
  OnDestroy = nil
  ExplicitWidth = 458
  ExplicitHeight = 278
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
    Top = 183
    Width = 442
    TabOrder = 4
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 175
    ExplicitWidth = 440
    inherited btCancel: TButton
      Left = 308
      ExplicitLeft = 306
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
