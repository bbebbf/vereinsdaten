inherited fmReportOneUnitMembersPrintout: TfmReportOneUnitMembersPrintout
  Left = 0
  Top = 0
  Caption = 'fmReportOneUnitMembersPrintout'
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
      Height = 138
      inherited lbReportTitle: TLabel
        Visible = False
      end
      object lbDataConfirmedCaption: TLabel
        Left = 0
        Top = 89
        Width = 79
        Height = 17
        Caption = 'Datenstand:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbMemberCountCaption: TLabel
        Left = 0
        Top = 67
        Width = 115
        Height = 17
        Caption = 'Anzahl Personen:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbUnitKindCaption: TLabel
        Left = 0
        Top = 44
        Width = 27
        Height = 17
        Caption = 'Typ:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object rdUnitname: TRLDBText
        Left = 0
        Top = 0
        Width = 86
        Height = 19
        DataField = 'unit_name'
        DataSource = dsDataSource
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -17
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        Text = ''
      end
      object rdUnitDataConfirmed: TRLDBText
        Left = 125
        Top = 89
        Width = 160
        Height = 17
        DataField = 'unit_data_confirmed_on'
        DataSource = dsDataSource
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        Text = ''
      end
      object rdMemberCount: TRLDBText
        Left = 125
        Top = 67
        Width = 134
        Height = 17
        DataField = 'unit_member_count'
        DataSource = dsDataSource
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        Text = ''
        BeforePrint = rdMemberCountBeforePrint
      end
      object rdUnitKind: TRLDBText
        Left = 125
        Top = 44
        Width = 61
        Height = 17
        DataField = 'unit_kind'
        DataSource = dsDataSource
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        Text = ''
        BeforePrint = rdUnitKindBeforePrint
      end
    end
    object bdColumnHeader: TRLBand
      Left = 47
      Top = 185
      Width = 898
      Height = 25
      BandType = btColumnHeader
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      ParentFont = False
      object lbPerson: TLabel
        Left = 0
        Top = 3
        Width = 43
        Height = 18
        Caption = 'Person'
      end
      object lbRole: TLabel
        Left = 520
        Top = 3
        Width = 32
        Height = 18
        Caption = 'Rolle'
      end
      object lbAddress: TLabel
        Left = 240
        Top = 3
        Width = 50
        Height = 18
        Caption = 'Adresse'
      end
      object rdUnitDivider: TRLDraw
        Left = 0
        Top = 23
        Width = 898
        Height = 2
        Align = faClientBottom
        DrawKind = dkLine
      end
    end
    object bdDetail: TRLBand
      Left = 47
      Top = 210
      Width = 898
      Height = 23
      GreenBarPrint = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      AfterPrint = bdDetailAfterPrint
      object rdPersonname: TRLDBText
        Left = 0
        Top = 2
        Width = 88
        Height = 18
        DataField = 'person_name'
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
      end
      object rtAddress: TRLDBText
        Left = 240
        Top = 2
        Width = 84
        Height = 18
        DataField = 'address_title'
        DataSource = dsDataSource
        Text = ''
      end
    end
  end
end
