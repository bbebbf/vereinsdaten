object fmReportPersons: TfmReportPersons
  Left = 0
  Top = 0
  Caption = 'fmReportPersons'
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
    object bdReportHeader: TRLBand
      Left = 47
      Top = 47
      Width = 898
      Height = 50
      BandType = btHeader
      object lbReportTitle: TLabel
        Left = 0
        Top = 0
        Width = 83
        Height = 23
        Caption = 'Personen'
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
      object lbSpecialPersonsInfo: TRLLabel
        Left = 0
        Top = 28
        Width = 186
        Height = 17
        Caption = 'Inaktive Personen enthalten.'
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
      Top = 97
      Width = 898
      Height = 26
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
        Width = 37
        Height = 18
        Caption = 'Name'
      end
      object lbInactive: TLabel
        Left = 258
        Top = 3
        Width = 42
        Height = 18
        Alignment = taCenter
        Caption = 'Inaktiv'
      end
      object lbAddress: TLabel
        Left = 410
        Top = 3
        Width = 50
        Height = 18
        Caption = 'Adresse'
      end
      object lbBirthday: TLabel
        Left = 320
        Top = 3
        Width = 75
        Height = 18
        Caption = 'Geb.-Datum'
      end
      object lbExternal: TLabel
        Left = 195
        Top = 3
        Width = 40
        Height = 18
        Alignment = taCenter
        Caption = 'Extern'
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
      Top = 123
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
      object rtInactive: TRLDBText
        Left = 258
        Top = 2
        Width = 58
        Height = 18
        Alignment = taCenter
        DataField = 'person_inactive'
        DataSource = dsDataSource
        Text = ''
      end
      object rtAddress: TRLDBText
        Left = 410
        Top = 2
        Width = 84
        Height = 18
        DataField = 'address_title'
        DataSource = dsDataSource
        Text = ''
      end
      object rtBirthday: TRLDBText
        Left = 320
        Top = 2
        Width = 105
        Height = 18
        DataField = 'person_date_of_birth'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rtBirthdayBeforePrint
      end
      object rtExternal: TRLDBText
        Left = 195
        Top = 2
        Width = 58
        Height = 18
        Alignment = taCenter
        AutoSize = False
        DataField = 'person_external_x'
        DataSource = dsDataSource
        Text = ''
      end
    end
    object bdPageFooter: TRLBand
      Left = 47
      Top = 146
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
