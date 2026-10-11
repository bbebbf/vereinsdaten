inherited fmReportClubMembersPrintout: TfmReportClubMembersPrintout
  Caption = 'fmReportClubMembersPrintout'
  ClientHeight = 863
  ClientWidth = 1411
  StyleElements = [seFont, seClient, seBorder]
  ExplicitWidth = 1427
  ExplicitHeight = 902
  TextHeight = 15
  inherited RLReport: TRLReport
    Width = 1403
    Height = 992
    Margins.LeftMargin = 5.000000000000000000
    Margins.RightMargin = 5.000000000000000000
    PageSetup.Orientation = poLandscape
    PreviewOptions.ShowModal = True
    Title = 'Vereinsmitglieder'
    ExplicitWidth = 1403
    ExplicitHeight = 992
    inherited bdReportHeader: TRLBand
      Left = 24
      Width = 1355
      Height = 54
      ExplicitLeft = 24
      ExplicitWidth = 1355
      ExplicitHeight = 54
      inherited lbReportTitle: TLabel
        StyleElements = [seFont, seClient, seBorder]
      end
      inherited lbTenantTitle: TLabel
        StyleElements = [seFont, seClient, seBorder]
      end
    end
    inherited bdPageFooter: TRLBand
      Left = 24
      Top = 183
      Width = 1355
      ExplicitLeft = 24
      ExplicitTop = 183
      ExplicitWidth = 1355
      inherited lbAppTitle: TLabel
        StyleElements = [seFont, seClient, seBorder]
      end
    end
    object bdDetail: TRLBand
      Left = 24
      Top = 131
      Width = 1355
      Height = 28
      GreenBarPrint = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      object rdPersonname: TRLDBText
        Left = 55
        Top = 2
        Width = 165
        Height = 24
        AutoSize = False
        DataField = 'person_name'
        DataSource = dsDataSource
        Text = ''
      end
      object rdNumber: TRLDBText
        Left = 0
        Top = 2
        Width = 50
        Height = 18
        Alignment = taRightJustify
        DataField = 'clmb_number'
        DataSource = dsDataSource
        Text = ''
        AfterPrint = rdNumberAfterPrint
      end
      object rdBirthday: TRLDBText
        Left = 225
        Top = 3
        Width = 85
        Height = 24
        AutoSize = False
        DataField = 'person_date_of_birth'
        DataSource = dsDataSource
        Text = ''
      end
      object rdAddress: TRLDBText
        Left = 315
        Top = 2
        Width = 300
        Height = 24
        AutoSize = False
        DataField = 'address_title'
        DataSource = dsDataSource
        Text = ''
      end
      object rdStartDate: TRLDBText
        Left = 620
        Top = 2
        Width = 96
        Height = 18
        DataField = 'clmb_startdate'
        DataSource = dsDataSource
        Text = ''
      end
      object rdEndDate: TRLDBText
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
      end
      object rdEndReason: TRLDBText
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
      Left = 24
      Top = 101
      Width = 1355
      Height = 30
      BandType = btColumnHeader
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      ParentFont = False
      object lbNumber: TLabel
        Left = 0
        Top = 3
        Width = 50
        Height = 19
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Nr.'
      end
      object lbName: TLabel
        Left = 55
        Top = 3
        Width = 37
        Height = 18
        Caption = 'Name'
      end
      object lbBirthday: TLabel
        Left = 225
        Top = 3
        Width = 75
        Height = 18
        Caption = 'Geb.-Datum'
      end
      object lbAddress: TLabel
        Left = 315
        Top = 3
        Width = 56
        Height = 18
        Caption = 'Anschrift'
      end
      object lbStartDate: TLabel
        Left = 620
        Top = 3
        Width = 43
        Height = 18
        Caption = 'Eintritt'
      end
      object lbInactive: TLabel
        Left = 710
        Top = 3
        Width = 50
        Height = 17
        Alignment = taCenter
        AutoSize = False
        Caption = 'Inaktiv'
      end
      object lbEndDate: TLabel
        Left = 765
        Top = 3
        Width = 47
        Height = 18
        Caption = 'Austritt'
      end
      object lbEndReason: TLabel
        Left = 870
        Top = 3
        Width = 89
        Height = 18
        Caption = 'Austrittsgrund'
      end
    end
    object bdSummary: TRLBand
      Left = 24
      Top = 159
      Width = 1355
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
end
