object fraExporterActiveRangeParams: TfraExporterActiveRangeParams
  Left = 0
  Top = 0
  Width = 356
  Height = 125
  TabOrder = 0
  object lbActiveRange: TLabel
    Left = 83
    Top = 66
    Width = 48
    Height = 15
    Caption = 'aktiv von'
  end
  object lbTo: TLabel
    Left = 238
    Top = 66
    Width = 15
    Height = 15
    Caption = 'bis'
  end
  object rbAllEntries: TRadioButton
    Left = 9
    Top = 12
    Width = 339
    Height = 17
    Caption = 'Alle Eintr'#228'ge'
    TabOrder = 0
    OnClick = rbOptionClick
  end
  object rbActiveEntries: TRadioButton
    Left = 9
    Top = 38
    Width = 339
    Height = 17
    Caption = 'Aktive Eintr'#228'ge'
    TabOrder = 1
    OnClick = rbOptionClick
  end
  object rbInactiveEntriesOnly: TRadioButton
    Left = 9
    Top = 98
    Width = 339
    Height = 17
    Caption = 'Nur inaktive Eintr'#228'ge'
    TabOrder = 4
    OnClick = rbOptionClick
  end
  object deActiveRangeFrom: TDateEdit
    Left = 143
    Top = 63
    Width = 89
    Height = 23
    TabOrder = 2
    OnChange = deActiveRangeFromChange
  end
  object deActiveRangeTo: TDateEdit
    Left = 259
    Top = 63
    Width = 89
    Height = 23
    TabOrder = 3
    OnChange = deActiveRangeToChange
  end
end
