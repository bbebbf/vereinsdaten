inherited fmExporterParamsBase: TfmExporterParamsBase
  TextHeight = 15
  inherited pnBottom: TPanel
    inherited btCancel: TButton
      Left = 320
      ExplicitLeft = 318
    end
  end
  object pnTarget: TPanel
    Left = 0
    Top = 168
    Width = 470
    Height = 54
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 160
    ExplicitWidth = 468
    DesignSize = (
      470
      54)
    object lbTargets: TLabel
      Left = 16
      Top = 3
      Width = 22
      Height = 15
      Caption = 'Ziel:'
    end
    object lbFilePath: TLabel
      Left = 16
      Top = 30
      Width = 30
      Height = 15
      Caption = 'Datei:'
    end
    object cbTargets: TComboBox
      Left = 56
      Top = 0
      Width = 371
      Height = 23
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = cbTargetsChange
    end
    object edFilePath: TEdit
      Left = 56
      Top = 27
      Width = 335
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 1
      ExplicitWidth = 333
    end
    object btOpenFileDlg: TButton
      Left = 397
      Top = 27
      Width = 32
      Height = 24
      Anchors = [akTop, akRight]
      Caption = '...'
      TabOrder = 2
      OnClick = btOpenFileDlgClick
      ExplicitLeft = 395
    end
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'CSV-Dateien|*.csv'
    Title = 'Ausgabedatei ausw'#228'hlen'
    Left = 376
    Top = 112
  end
end
