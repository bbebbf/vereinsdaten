inherited fmExporterParamsClubMembers: TfmExporterParamsClubMembers
  Caption = 'Vereinsmitglieder exportieren'
  ClientHeight = 181
  ClientWidth = 431
  StyleElements = [seFont, seClient, seBorder]
  OnDestroy = nil
  ExplicitWidth = 447
  ExplicitHeight = 220
  TextHeight = 15
  inherited pnBottom: TPanel
    Top = 125
    Width = 431
    TabOrder = 2
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 117
    ExplicitWidth = 429
    inherited btCancel: TButton
      Left = 306
      ExplicitLeft = 304
    end
  end
  inherited pnTarget: TPanel
    Top = 71
    Width = 431
    TabOrder = 3
    StyleElements = [seFont, seClient, seBorder]
    ExplicitTop = 63
    ExplicitWidth = 429
    inherited lbTargets: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lbFilePath: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited cbTargets: TComboBox
      Width = 357
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 355
    end
    inherited edFilePath: TEdit
      Width = 319
      StyleElements = [seFont, seClient, seBorder]
      ExplicitWidth = 317
    end
    inherited btOpenFileDlg: TButton
      Left = 381
      ExplicitLeft = 379
    end
  end
  object cbIncludeInactive: TCheckBox [2]
    Left = 16
    Top = 16
    Width = 399
    Height = 17
    Caption = 'Auch inaktive Vereinsmitglieder anzeigen'
    TabOrder = 0
  end
  object cbSortedByName: TCheckBox [3]
    Left = 16
    Top = 39
    Width = 399
    Height = 17
    Caption = 'Nach Name sortieren anstatt nach Nummer'
    TabOrder = 1
  end
end
