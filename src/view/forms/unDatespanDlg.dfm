object fmDatespanDlg: TfmDatespanDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmDatespanDlg'
  ClientHeight = 86
  ClientWidth = 284
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object Label1: TLabel
    Left = 16
    Top = 20
    Width = 20
    Height = 15
    Caption = 'von'
  end
  object Label2: TLabel
    Left = 160
    Top = 20
    Width = 15
    Height = 15
    Caption = 'bis'
  end
  object dtFromDate: TDateTimePicker
    Left = 46
    Top = 16
    Width = 89
    Height = 23
    Date = 45829.000000000000000000
    Time = 0.722089803239214200
    TabOrder = 0
    OnChange = dtFromDateChange
  end
  object dtToDate: TDateTimePicker
    Left = 184
    Top = 16
    Width = 89
    Height = 23
    Date = 45829.000000000000000000
    Time = 0.722089803239214200
    TabOrder = 1
    OnChange = dtToDateChange
  end
  object btConfirm: TButton
    Left = 108
    Top = 53
    Width = 75
    Height = 25
    Caption = 'Weiter'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object btCancel: TButton
    Left = 198
    Top = 53
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 3
  end
end
