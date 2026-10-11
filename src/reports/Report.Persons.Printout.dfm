inherited fmReportPersonsPrintout: TfmReportPersonsPrintout
  Left = 0
  Top = 0
  Caption = 'fmReportPersonsPrintout'
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
    inherited bdReportHeader: TRLBand
      Height = 50
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
      object lbAddress: TLabel
        Left = 350
        Top = 3
        Width = 50
        Height = 18
        Caption = 'Adresse'
      end
      object lbBirthday: TLabel
        Left = 260
        Top = 3
        Width = 75
        Height = 18
        Caption = 'Geb.-Datum'
      end
      object lbStatus: TLabel
        Left = 195
        Top = 3
        Width = 38
        Height = 18
        Caption = 'Status'
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
      object rtAddress: TRLDBText
        Left = 350
        Top = 2
        Width = 84
        Height = 18
        DataField = 'address_title'
        DataSource = dsDataSource
        Text = ''
      end
      object rtBirthday: TRLDBText
        Left = 260
        Top = 2
        Width = 105
        Height = 18
        DataField = 'person_date_of_birth'
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rtBirthdayBeforePrint
      end
      object rtStatus: TRLDBText
        Left = 195
        Top = 2
        Width = 58
        Height = 18
        AutoSize = False
        DataSource = dsDataSource
        Text = ''
        BeforePrint = rtStatusBeforePrint
      end
    end
  end
end
