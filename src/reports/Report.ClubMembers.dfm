object fmReportClubMembers: TfmReportClubMembers
  Left = 0
  Top = 0
  Caption = 'fmReportClubMembers'
  ClientHeight = 863
  ClientWidth = 1411
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
    Width = 1123
    Height = 794
    Margins.LeftMargin = 5.000000000000000000
    Margins.RightMargin = 5.000000000000000000
    DataSource = dsDataSource
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -17
    Font.Name = 'Calibri'
    Font.Style = []
    PageSetup.Orientation = poLandscape
    PreviewOptions.ShowModal = True
    Title = 'Vereinsmitglieder'
    BeforePrint = RLReportBeforePrint
    object bdDetail: TRLBand
      Left = 19
      Top = 103
      Width = 1085
      Height = 28
      GreenBarPrint = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      object RLDBText1: TRLDBText
        Left = 55
        Top = 2
        Width = 165
        Height = 24
        AutoSize = False
        DataField = 'person_name'
        DataSource = dsDataSource
        Text = ''
      end
      object RLDBText2: TRLDBText
        Left = 0
        Top = 2
        Width = 50
        Height = 18
        Alignment = taRightJustify
        DataField = 'clmb_number'
        DataSource = dsDataSource
        Text = ''
      end
      object RLDBText3: TRLDBText
        Left = 225
        Top = 3
        Width = 85
        Height = 24
        AutoSize = False
        DataField = 'person_birthday'
        DataSource = dsDataSource
        Text = ''
      end
      object RLDBText4: TRLDBText
        Left = 315
        Top = 2
        Width = 300
        Height = 24
        AutoSize = False
        DataField = 'address_title'
        DataSource = dsDataSource
        Text = ''
      end
      object RLDBText5: TRLDBText
        Left = 620
        Top = 2
        Width = 96
        Height = 18
        DataField = 'clmb_startdate'
        DataSource = dsDataSource
        Text = ''
      end
      object RLDBText6: TRLDBText
        Left = 765
        Top = 2
        Width = 100
        Height = 24
        AutoSize = False
        DataField = 'clmb_enddate_calculated'
        DataSource = dsDataSource
        Text = ''
      end
      object rdInactive: TRLDBText
        Left = 710
        Top = 3
        Width = 50
        Height = 24
        Alignment = taCenter
        AutoSize = False
        DataField = 'clmb_inactive'
        DataSource = dsDataSource
        Text = ''
        AfterPrint = rdInactiveAfterPrint
      end
      object RLDBText8: TRLDBText
        Left = 870
        Top = 2
        Width = 106
        Height = 18
        DataField = 'clmb_endreason'
        DataSource = dsDataSource
        Text = ''
      end
    end
    object bdColumnHeader: TRLBand
      Left = 19
      Top = 73
      Width = 1085
      Height = 30
      BandType = btColumnHeader
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      ParentFont = False
      object Label2: TLabel
        Left = 0
        Top = 3
        Width = 50
        Height = 19
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Nr.'
      end
      object Label3: TLabel
        Left = 55
        Top = 3
        Width = 37
        Height = 18
        Caption = 'Name'
      end
      object Label4: TLabel
        Left = 225
        Top = 3
        Width = 75
        Height = 18
        Caption = 'Geb.-Datum'
      end
      object Label5: TLabel
        Left = 315
        Top = 3
        Width = 56
        Height = 18
        Caption = 'Anschrift'
      end
      object Label6: TLabel
        Left = 620
        Top = 3
        Width = 43
        Height = 18
        Caption = 'Eintritt'
      end
      object Label8: TLabel
        Left = 710
        Top = 3
        Width = 50
        Height = 17
        Alignment = taCenter
        AutoSize = False
        Caption = 'Inaktiv'
      end
      object Label9: TLabel
        Left = 765
        Top = 3
        Width = 47
        Height = 18
        Caption = 'Austritt'
      end
      object Label7: TLabel
        Left = 870
        Top = 3
        Width = 89
        Height = 18
        Caption = 'Austrittsgrund'
      end
    end
    object bdReportHeader: TRLBand
      Left = 19
      Top = 38
      Width = 1085
      Height = 35
      BandType = btHeader
      object lbReportTitle: TLabel
        Left = 0
        Top = 0
        Width = 150
        Height = 23
        Caption = 'Vereinsmitglieder'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -20
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbTenantTitle: TLabel
        Left = 999
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
    object bdPageFooter: TRLBand
      Left = 19
      Top = 155
      Width = 1085
      Height = 27
      BandType = btFooter
      object lbAppTitle: TLabel
        Left = 417
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
        Left = 1009
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
        Left = 1043
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
    object bdSummary: TRLBand
      Left = 19
      Top = 131
      Width = 1085
      Height = 24
      BandType = btSummary
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      BeforePrint = bdSummaryBeforePrint
      object lbActiveInactive: TLabel
        Left = 55
        Top = 2
        Width = 133
        Height = 18
        Caption = 'lcActiveInactiveCount'
      end
    end
  end
  object dsDataSource: TDataSource
    Left = 384
    Top = 360
  end
end
