inherited fmReportMemberUnitsPrintout: TfmReportMemberUnitsPrintout
  Left = 0
  Top = 0
  Caption = 'fmReportMemberUnitsPrintout'
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
      Height = 54
    end
    object bdColumnHeader: TRLBand
      Left = 47
      Top = 101
      Width = 898
      Height = 30
      BandType = btColumnHeader
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      ParentFont = False
      object Label3: TLabel
        Left = 0
        Top = 3
        Width = 43
        Height = 18
        Caption = 'Person'
      end
      object Label4: TLabel
        Left = 280
        Top = 3
        Width = 44
        Height = 18
        Caption = 'Einheit'
      end
      object Label5: TLabel
        Left = 520
        Top = 3
        Width = 32
        Height = 18
        Caption = 'Rolle'
      end
      object lbStatus: TLabel
        Left = 210
        Top = 3
        Width = 38
        Height = 18
        Caption = 'Status'
      end
    end
    object bdDetail: TRLBand
      Left = 47
      Top = 131
      Width = 898
      Height = 41
      GreenBarPrint = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      AfterPrint = bdDetailAfterPrint
      BeforePrint = bdDetailBeforePrint
      object rdPersonname: TRLDBText
        Left = 0
        Top = 2
        Width = 88
        Height = 18
        DataField = 'person_name'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rdPersonnameBeforePrint
      end
      object rdUnitname: TRLDBText
        Left = 280
        Top = 2
        Width = 70
        Height = 18
        DataField = 'unit_name'
        DataSource = dsDataSource
        Text = ''
      end
      object rdRolename: TRLDBText
        Left = 520
        Top = 2
        Width = 70
        Height = 18
        DataField = 'role_name'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rdRolenameBeforePrint
      end
      object rdPersonid: TRLDBText
        Left = 660
        Top = 2
        Width = 65
        Height = 18
        DataField = 'person_id'
        DataSource = dsDataSource
        Text = ''
        Visible = False
      end
      object rdUnitDivider: TRLDraw
        Left = 0
        Top = 0
        Width = 898
        Height = 2
        Align = faClientTop
        DrawKind = dkLine
        BeforePrint = rdUnitDividerBeforePrint
      end
      object rtStatus: TRLDBText
        Left = 210
        Top = 2
        Width = 58
        Height = 18
        AutoSize = False
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rtStatusBeforePrint
      end
      object rdInactiveInfo: TRLLabel
        Left = 280
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
