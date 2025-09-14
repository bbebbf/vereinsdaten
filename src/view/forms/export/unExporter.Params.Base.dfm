inherited fmExporterParamsBase: TfmExporterParamsBase
  Caption = 'Exporter.Params.Base'
  StyleElements = [seFont, seClient, seBorder]
  TextHeight = 15
  inherited pnBottom: TPanel
    StyleElements = [seFont, seClient, seBorder]
    inherited btCancel: TButton
      Left = 334
      ExplicitLeft = 336
    end
  end
  object pnTarget: TPanel
    Left = 0
    Top = 194
    Width = 470
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      470
      28)
    object lbTargets: TLabel
      Left = 16
      Top = 3
      Width = 22
      Height = 15
      Caption = 'Ziel:'
    end
    object cbTargets: TComboBox
      Left = 56
      Top = 0
      Width = 385
      Height = 23
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
  end
end
