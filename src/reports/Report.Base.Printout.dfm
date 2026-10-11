object fmReportBasePrintout: TfmReportBasePrintout
  Left = 0
  Top = 0
  Caption = 'fmReportBasePrintout'
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
    Width = 992
    Height = 1403
    DataSource = dsDataSource
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    BeforePrint = RLReportBeforePrint
    object bdReportHeader: TRLBand
      Left = 47
      Top = 47
      Width = 898
      Height = 52
      BandType = btHeader
      object lbReportTitle: TLabel
        Left = 0
        Top = 0
        Width = 71
        Height = 23
        Caption = 'Ausdruck'
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
        Visible = False
      end
    end
    object bdPageFooter: TRLBand
      Left = 47
      Top = 99
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
      object lbPageNumber: TRLSystemInfo
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
      object lbLastPageNumber: TRLSystemInfo
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
