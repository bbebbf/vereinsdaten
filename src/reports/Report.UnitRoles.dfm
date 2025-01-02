object fmReportUnitRoles: TfmReportUnitRoles
  Left = 0
  Top = 0
  Caption = 'fmReportUnitRoles'
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
    Top = 0
    Width = 794
    Height = 1123
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
      Left = 38
      Top = 38
      Width = 718
      Height = 35
      BandType = btHeader
      object lbReportTitle: TLabel
        Left = 0
        Top = 0
        Width = 271
        Height = 23
        Caption = 'Rollen, Einheiten und Personen'
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
    end
    object bdColumnHeader: TRLBand
      Left = 38
      Top = 73
      Width = 718
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
        Width = 32
        Height = 18
        Caption = 'Rolle'
      end
      object Label4: TLabel
        Left = 450
        Top = 3
        Width = 43
        Height = 18
        Caption = 'Person'
      end
      object Label5: TLabel
        Left = 230
        Top = 3
        Width = 44
        Height = 18
        Caption = 'Einheit'
      end
    end
    object bdDetail: TRLBand
      Left = 38
      Top = 103
      Width = 718
      Height = 23
      GreenBarPrint = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      AfterPrint = bdDetailAfterPrint
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
      object RLDBText2: TRLDBText
        Left = 450
        Top = 2
        Width = 88
        Height = 18
        DataField = 'person_name'
        DataSource = dsDataSource
        Text = ''
      end
      object RLDBText3: TRLDBText
        Left = 230
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
        Width = 718
        Height = 2
        Align = faClientTop
        DrawKind = dkLine
        BeforePrint = rdDividerBeforePrint
      end
    end
    object bdPageFooter: TRLBand
      Left = 38
      Top = 126
      Width = 718
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
