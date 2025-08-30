object fmDatespanDlg: TfmDatespanDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'fmDatespanDlg'
  ClientHeight = 107
  ClientWidth = 287
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    287
    107)
  TextHeight = 15
  object lbFromDate: TLabel
    Left = 16
    Top = 28
    Width = 20
    Height = 15
    Caption = 'von'
  end
  object lbToDate: TLabel
    Left = 160
    Top = 28
    Width = 15
    Height = 15
    Caption = 'bis'
  end
  object btConfirm: TButton
    Left = 111
    Top = 74
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Weiter'
    Default = True
    TabOrder = 2
    OnClick = btConfirmClick
    ExplicitLeft = 109
    ExplicitTop = 66
  end
  object btCancel: TButton
    Left = 201
    Top = 74
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 3
    ExplicitLeft = 199
    ExplicitTop = 66
  end
  object deFromDate: TDateEdit
    Left = 56
    Top = 25
    Width = 81
    Height = 23
    TabOrder = 0
    ValueMandatory = True
    OnValueChanged = deFromDateValueChanged
  end
  object deToDate: TDateEdit
    Left = 198
    Top = 25
    Width = 81
    Height = 23
    TabOrder = 1
    ValueMandatory = True
    OnValueChanged = deToDateValueChanged
  end
end
