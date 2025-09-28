inherited fmExporterParamsZeroParams: TfmExporterParamsZeroParams
  Caption = 'fmExporterParamsZeroParams'
  ClientHeight = 123
  ClientWidth = 462
  StyleElements = [seFont, seClient, seBorder]
  ExplicitLeft = 3
  ExplicitTop = 3
  ExplicitWidth = 478
  ExplicitHeight = 162
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 67
    Width = 462
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 59
    ExplicitWidth = 468
    inherited btCancel: TButton
      Left = 336
      ExplicitLeft = 336
    end
  end
  inherited pnTarget: TPanel
    Top = 13
    Width = 462
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 5
    ExplicitWidth = 468
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lbFilePath: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 385
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 385
    end
    inherited edFilePath: TEdit
      Top = 30
      Width = 349
      StyleElements = [seFont, seClient, seBorder]
      ExplicitTop = 30
      ExplicitWidth = 349
    end
    inherited btOpenFileDlg: TButton
      Left = 409
      Top = 30
      ExplicitLeft = 409
      ExplicitTop = 30
    end
  end
  inherited dlgSave: TSaveDialog
    Left = 328
    Top = 8
  end
end
