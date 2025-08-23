object fmReportBirthdays: TfmReportBirthdays
  Left = 0
  Top = 0
  Caption = 'fmReportBirthdays'
  ClientHeight = 934
  ClientWidth = 996
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
    JobTitle = 'Geburtstagsliste'
    BeforePrint = RLReportBeforePrint
    object bdReportHeader: TRLBand
      Left = 47
      Top = 47
      Width = 898
      Height = 66
      BandType = btHeader
      object lbReportTitle: TLabel
        Left = 0
        Top = 0
        Width = 144
        Height = 23
        Caption = 'Geburtstagsliste'
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
      object Label2: TLabel
        Left = 0
        Top = 40
        Width = 27
        Height = 17
        Caption = 'von:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object Label1: TLabel
        Left = 120
        Top = 40
        Width = 23
        Height = 17
        Caption = 'bis:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbFromDate: TLabel
        Left = 32
        Top = 40
        Width = 27
        Height = 17
        Caption = 'von:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbToDate: TLabel
        Left = 152
        Top = 40
        Width = 23
        Height = 17
        Caption = 'bis:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
    end
    object bdColumnHeader: TRLBand
      Left = 47
      Top = 113
      Width = 898
      Height = 26
      BandType = btColumnHeader
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      ParentFont = False
      object lbName: TLabel
        Left = 0
        Top = 3
        Width = 37
        Height = 18
        Caption = 'Name'
      end
      object lbAddress: TLabel
        Left = 458
        Top = 3
        Width = 90
        Height = 18
        Caption = 'Geburtsdatum'
      end
      object lbBirthday: TLabel
        Left = 220
        Top = 3
        Width = 69
        Height = 18
        Caption = 'Geburtstag'
      end
      object lbAge: TLabel
        Left = 368
        Top = 3
        Width = 50
        Height = 18
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Alter'
      end
      object rdColumnHeaderHLine: TRLDraw
        Left = 0
        Top = 24
        Width = 898
        Height = 2
        Align = faClientBottom
        DrawKind = dkLine
      end
    end
    object bdDetail: TRLBand
      Left = 47
      Top = 139
      Width = 898
      Height = 23
      GreenBarPrint = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = []
      ParentFont = False
      object rdPersonname: TRLDBText
        Left = 0
        Top = 2
        Width = 88
        Height = 18
        DataField = 'person_name'
        DataSource = dsDataSource
        Text = ''
      end
      object rtAddress: TRLDBText
        Left = 458
        Top = 2
        Width = 105
        Height = 18
        DataField = 'person_date_of_birth'
        DataSource = dsDataSource
        Text = ''
      end
      object rdBirthdayWeekday: TRLDBText
        Left = 220
        Top = 2
        Width = 72
        Height = 18
        DataField = 'birthday'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rdBirthdayWeekdayBeforePrint
      end
      object RLDBText1: TRLDBText
        Left = 368
        Top = 2
        Width = 50
        Height = 18
        Alignment = taRightJustify
        DataField = 'age'
        DataSource = dsDataSource
        Text = ''
      end
      object rdBirthday: TRLDBText
        Left = 298
        Top = 2
        Width = 55
        Height = 18
        DataField = 'birthday'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rdBirthdayBeforePrint
      end
    end
    object bdPageFooter: TRLBand
      Left = 47
      Top = 162
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
