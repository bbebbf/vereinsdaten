inherited fmExporterParamsUnitMember: TfmExporterParamsUnitMember
  Caption = 'Einheiten und Personen exportieren'
  ClientHeight = 535
  ClientWidth = 372
  ExplicitWidth = 390
  ExplicitHeight = 582
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 479
    Width = 372
    ExplicitTop = 423
    ExplicitWidth = 370
    inherited btCancel: TButton
      Left = 248
      ExplicitLeft = 246
    end
  end
  inherited pnTarget: TPanel
    Top = 425
    Width = 372
    ExplicitTop = 425
    ExplicitWidth = 372
    inherited cbTargets: TComboBox
      Width = 297
      ExplicitWidth = 297
    end
    inherited edFilePath: TEdit
      Width = 259
      ExplicitWidth = 257
    end
    inherited btOpenFileDlg: TButton
      Left = 321
      ExplicitLeft = 319
    end
  end
  object pnUnits: TPanel [2]
    Left = 0
    Top = 0
    Width = 372
    Height = 217
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 2
    inline fraParamsUnitsRange: TfraExporterActiveRangeParams
      Left = 0
      Top = 8
      Width = 356
      Height = 121
      TabOrder = 0
      ExplicitTop = 8
      ExplicitHeight = 121
    end
    object rbAllCheckedUnits: TRadioButton
      Left = 9
      Top = 135
      Width = 339
      Height = 17
      Caption = 'Ausgew'#228'hlte 0 Einheit(en)'
      TabOrder = 1
      OnClick = rbAllCheckedUnitsClick
    end
    object cbIncludeOneTimeUnits: TCheckBox
      Left = 9
      Top = 165
      Width = 169
      Height = 17
      Caption = 'Einmalige Einheiten'
      TabOrder = 2
    end
    object cbIncludeExternalUnits: TCheckBox
      Left = 9
      Top = 188
      Width = 169
      Height = 17
      Caption = 'Externe Einheiten'
      TabOrder = 3
    end
  end
  object pnMembers: TPanel [3]
    Left = 0
    Top = 217
    Width = 372
    Height = 137
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 3
    ExplicitTop = 169
    ExplicitWidth = 370
    inline fraParamsMembersRange: TfraExporterActiveRangeParams
      Left = 0
      Top = 8
      Width = 356
      Height = 125
      TabOrder = 0
      ExplicitTop = 8
    end
  end
  object pnPersons: TPanel [4]
    Left = 0
    Top = 354
    Width = 372
    Height = 63
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 4
    ExplicitTop = 306
    ExplicitWidth = 370
    object cbIncludeInactivePersons: TCheckBox
      Left = 9
      Top = 13
      Width = 169
      Height = 17
      Caption = 'Inaktive Personen'
      TabOrder = 0
    end
    object cbIncludeExternalPersons: TCheckBox
      Left = 9
      Top = 36
      Width = 169
      Height = 17
      Caption = 'Externe Personen'
      TabOrder = 1
    end
  end
  inherited dlgSave: TSaveDialog
    Left = 328
    Top = 8
  end
end
