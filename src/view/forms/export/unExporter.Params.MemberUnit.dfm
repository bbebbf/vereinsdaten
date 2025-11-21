inherited fmExporterParamsMemberUnit: TfmExporterParamsMemberUnit
  Caption = 'Personen und Einheiten exportieren'
  ClientHeight = 503
  ClientWidth = 423
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 439
  ExplicitHeight = 542
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 447
    Width = 423
    TabOrder = 1
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 389
    ExplicitWidth = 421
    inherited btCancel: TButton
      Left = 303
      ExplicitLeft = 301
    end
  end
  inherited pnTarget: TPanel
    Top = 393
    Width = 423
    TabOrder = 0
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 335
    ExplicitWidth = 421
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lbFilePath: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 346
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 344
    end
    inherited edFilePath: TEdit
      Width = 308
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 306
    end
    inherited btOpenFileDlg: TButton
      Left = 370
      ExplicitLeft = 368
    end
  end
  object pnPersons: TPanel [2]
    Left = 0
    Top = 0
    Width = 423
    Height = 63
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 2
    ExplicitWidth = 421
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
  object pnMembers: TPanel [3]
    Left = 0
    Top = 63
    Width = 423
    Height = 137
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 3
    ExplicitWidth = 421
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
  object pnUnits: TPanel [4]
    Left = 0
    Top = 200
    Width = 423
    Height = 185
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 4
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
    object cbIncludeOneTimeUnits: TCheckBox
      Left = 9
      Top = 133
      Width = 169
      Height = 17
      Caption = 'Einmalige Einheiten'
      TabOrder = 1
    end
    object cbIncludeExternalUnits: TCheckBox
      Left = 9
      Top = 156
      Width = 169
      Height = 17
      Caption = 'Externe Einheiten'
      TabOrder = 2
    end
  end
  inherited dlgSave: TSaveDialog
    Left = 344
    Top = 136
  end
end
