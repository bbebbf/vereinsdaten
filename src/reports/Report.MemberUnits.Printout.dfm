object fmReportMemberUnitsPrintout: TfmReportMemberUnitsPrintout
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
  object RLReport: TRLReport
    Left = 0
    Top = 8
    Width = 992
    Height = 1403
    DataSource = dsDataSource
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    JobTitle = 'Einheiten und Personen'
    BeforePrint = RLReportBeforePrint
    OnPageStarting = RLReportPageStarting
    object bdReportHeader: TRLBand
      Left = 47
      Top = 47
      Width = 898
      Height = 54
      BandType = btHeader
      object lbReportTitle: TLabel
        Left = 0
        Top = 0
        Width = 205
        Height = 23
        Caption = 'Personen und Einheiten'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -20
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbTenantTitle: TLabel
        Left = 633
        Top = 0
        Width = 78
        Height = 21
        Alignment = taRightJustify
        Caption = 'Vereinstitel'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -17
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
      end
      object memFilterInfo: TRLMemo
        Left = 3
        Top = 29
        Width = 518
        Height = 16
        Behavior = [beSiteExpander]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
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
    object bdPageFooter: TRLBand
      Left = 47
      Top = 172
      Width = 898
      Height = 27
      BandType = btFooter
      object lbAppTitle: TLabel
        Left = 234
        Top = 10
        Width = 250
        Height = 14
        Alignment = taCenter
        AutoSize = False
        Caption = 'lbAppTitle'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Calibri'
        Font.Style = [fsItalic]
        ParentFont = False
      end
      object lbSysDate: TRLSystemInfo
        Left = 0
        Top = 6
        Width = 65
        Height = 18
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Calibri'
        Font.Style = []
        Info = itFullDate
        ParentFont = False
        Text = ''
      end
      object RLSystemInfo3: TRLSystemInfo
        Left = 630
        Top = 6
        Width = 36
        Height = 18
        Alignment = taRightJustify
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Calibri'
        Font.Style = []
        Info = itPageNumber
        ParentFont = False
        Text = ''
      end
      object RLSystemInfo4: TRLSystemInfo
        Left = 665
        Top = 6
        Width = 42
        Height = 18
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Calibri'
        Font.Style = []
        Info = itLastPageNumber
        ParentFont = False
        Text = '/ '
      end
    end
  end
  object dsDataSource: TDataSource
    Left = 480
    Top = 432
  end
end
