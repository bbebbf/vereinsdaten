object fmReportOneUnitMembersPrintout: TfmReportOneUnitMembersPrintout
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
    BeforePrint = RLReportBeforePrint
    OnPageStarting = RLReportPageStarting
    object bdReportHeader: TRLBand
      Left = 47
      Top = 47
      Width = 898
      Height = 90
      BandType = btHeader
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
      object Label1: TLabel
        Left = 0
        Top = 65
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
      object Label2: TLabel
        Left = 0
        Top = 40
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
        Top = 65
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
        Top = 40
        Width = 96
        Height = 17
        DataField = 'MemberCount'
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
    end
    object bdColumnHeader: TRLBand
      Left = 47
      Top = 137
      Width = 898
      Height = 25
      BandType = btColumnHeader
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -15
      Font.Name = 'Calibri'
      Font.Style = [fsBold]
      ParentFont = False
      object Label4: TLabel
        Left = 0
        Top = 3
        Width = 43
        Height = 18
        Caption = 'Person'
      end
      object Label5: TLabel
        Left = 550
        Top = 3
        Width = 32
        Height = 18
        Caption = 'Rolle'
      end
      object lbBirthday: TLabel
        Left = 180
        Top = 3
        Width = 75
        Height = 18
        Caption = 'Geb.-Datum'
      end
      object lbAddress: TLabel
        Left = 270
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
      Top = 162
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
      object RLDBText2: TRLDBText
        Left = 0
        Top = 2
        Width = 88
        Height = 18
        DataField = 'person_name'
        DataSource = dsDataSource
        Text = ''
      end
      object RLDBText3: TRLDBText
        Left = 550
        Top = 2
        Width = 70
        Height = 18
        DataField = 'role_name'
        DataSource = dsDataSource
        Text = ''
      end
      object rtBirthday: TRLDBText
        Left = 180
        Top = 2
        Width = 105
        Height = 18
        DataField = 'person_date_of_birth'
        DataSource = dsDataSource
        Text = ''
      end
      object rtAddress: TRLDBText
        Left = 270
        Top = 2
        Width = 84
        Height = 18
        DataField = 'address_title'
        DataSource = dsDataSource
        Text = ''
      end
    end
    object bdPageFooter: TRLBand
      Left = 47
      Top = 185
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
