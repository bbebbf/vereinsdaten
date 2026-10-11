inherited fmReportUnitMembersPrintout: TfmReportUnitMembersPrintout
  Left = 0
  Top = 0
  Caption = 'fmReportUnitMembersPrintout'
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
      Height = 22
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
        Width = 44
        Height = 18
        Caption = 'Einheit'
      end
      object Label4: TLabel
        Left = 340
        Top = 3
        Width = 43
        Height = 18
        Caption = 'Person'
      end
      object Label5: TLabel
        Left = 520
        Top = 3
        Width = 32
        Height = 18
        Caption = 'Rolle'
      end
      object Label1: TLabel
        Left = 275
        Top = 3
        Width = 35
        Height = 18
        Caption = 'Stand'
      end
      object Label2: TLabel
        Left = 225
        Top = 3
        Width = 22
        Height = 18
        Caption = 'Typ'
      end
    end
    object bdDetail: TRLBand
      Left = 47
      Top = 121
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
        Left = 275
        Top = 2
        Width = 156
        Height = 18
        DataField = 'unit_data_confirmed_on'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rdUnitnameBeforePrint
      end
      object rdUnitname: TRLDBText
        Left = 0
        Top = 2
        Width = 70
        Height = 18
        DataField = 'unit_name'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rdUnitnameBeforePrint
      end
      object rdPersonname: TRLDBText
        Left = 340
        Top = 2
        Width = 88
        Height = 18
        DataField = 'person_name'
        DataSource = dsDataSource
        Text = ''
      end
      object RLDBText3: TRLDBText
        Left = 520
        Top = 2
        Width = 70
        Height = 18
        DataField = 'role_name'
        DataSource = dsDataSource
        Text = ''
      end
      object rdUinitId: TRLDBText
        Left = 660
        Top = 2
        Width = 47
        Height = 18
        DataField = 'unit_id'
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
      object rdMemberCount: TRLDBText
        Left = 713
        Top = 2
        Width = 130
        Height = 18
        DataField = 'unit_member_count'
        DataSource = dsDataSource
        Text = ''
        Visible = False
      end
      object rdUnitKind: TRLDBText
        Left = 225
        Top = 2
        Width = 62
        Height = 18
        DataField = 'unit_kind'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rdUnitnameBeforePrint
      end
      object rdInactiveInfo: TRLLabel
        Left = 340
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
      object rdInactiveInfoUnit: TRLLabel
        Left = 0
        Top = 21
        Width = 104
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -13
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
        BeforePrint = rdUnitnameBeforePrint
      end
    end
  end
end
