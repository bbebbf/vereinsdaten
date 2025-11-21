inherited fmExporterParamsUnitMember: TfmExporterParamsUnitMember
  Caption = 'Einheiten und Personen exportieren'
  ClientHeight = 535
  ClientWidth = 372
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 388
  ExplicitHeight = 574
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 479
    Width = 372
    StyleElements = [seFont, seClient, seBorder]
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
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 369
    ExplicitWidth = 370
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lbFilePath: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 297
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 295
    end
    inherited edFilePath: TEdit
      Width = 259
      StyleElements = [seFont, seClient, seBorder]
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
      inherited lbActiveRange: TLabel
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited lbTo: TLabel
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited deActiveRangeFrom: TDateEdit
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited deActiveRangeTo: TDateEdit
        StyleElements = [seFont, seClient, seBorder]
      end
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
      inherited lbActiveRange: TLabel
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited lbTo: TLabel
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited deActiveRangeFrom: TDateEdit
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited deActiveRangeTo: TDateEdit
        StyleElements = [seFont, seClient, seBorder]
      end
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
