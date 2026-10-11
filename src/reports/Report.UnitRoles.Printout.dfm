inherited fmReportUnitRolesPrintout: TfmReportUnitRolesPrintout
  Left = 0
  Top = 0
  Caption = 'fmReportUnitRolesPrintout'
  ClientHeight = 942
  ClientWidth = 998
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  inherited RLReport: TRLReport
    OnPageStarting = RLReportPageStarting
    inherited bdReportHeader: TRLBand
      Height = 52
    end
    object bdColumnHeader: TRLBand
      Left = 47
      Top = 99
      Width = 898
      Height = 30
      BandType = btColumnHeader
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      ParentFont = False
      object lbRole: TLabel
        Left = 0
        Top = 3
        Width = 32
        Height = 18
        Caption = 'Rolle'
      end
      object lbPerson: TLabel
        Left = 510
        Top = 3
        Width = 43
        Height = 18
        Caption = 'Person'
      end
      object lbUnit: TLabel
        Left = 210
        Top = 3
        Width = 44
        Height = 18
        Caption = 'Einheit'
      end
      object lbDataConfirmed: TLabel
        Left = 420
        Top = 3
        Width = 71
        Height = 18
        Caption = 'Datenstand'
      end
    end
    object bdDetail: TRLBand
      Left = 47
      Top = 129
      Width = 898
      Height = 40
      GreenBarPrint = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      AfterPrint = bdDetailAfterPrint
      BeforePrint = bdDetailBeforePrint
      object rdUnitDataConfirmed: TRLDBText
        Left = 420
        Top = 2
        Width = 156
        Height = 18
        DataField = 'unit_data_confirmed_on'
        DataSource = dsDataSource
        Text = ''
      end
      object rdRoleName: TRLDBText
        Left = 0
        Top = 2
        Width = 70
        Height = 18
        DataField = 'role_name'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rdRoleNameBeforePrint
      end
      object rdPersonname: TRLDBText
        Left = 510
        Top = 2
        Width = 88
        Height = 18
        DataField = 'person_name'
        DataSource = dsDataSource
        Text = ''
      end
      object rdUnitname: TRLDBText
        Left = 210
        Top = 2
        Width = 70
        Height = 18
        DataField = 'unit_name'
        DataSource = dsDataSource
        Text = ''
      end
      object rdRoleId: TRLDBText
        Left = 641
        Top = 4
        Width = 47
        Height = 18
        DataField = 'role_id'
        DataSource = dsDataSource
        Text = ''
        Visible = False
      end
      object rdDivider: TRLDraw
        Left = 0
        Top = 0
        Width = 898
        Height = 2
        Align = faClientTop
        DrawKind = dkLine
        BeforePrint = rdDividerBeforePrint
      end
      object rdInactiveInfoUnit: TRLLabel
        Left = 210
        Top = 21
        Width = 104
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
      end
      object rdInactiveInfo: TRLLabel
        Left = 510
        Top = 21
        Width = 81
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
      end
    end
  end
end
