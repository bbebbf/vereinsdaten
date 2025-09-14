object fmParamsDlg: TfmParamsDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 278
  ClientWidth = 470
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnBottom: TPanel
    Left = 0
    Top = 222
    Width = 470
    Height = 56
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      470
      56)
    object btOk: TButton
      Left = 16
      Top = 8
      Width = 105
      Height = 33
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btOkClick
    end
    object btCancel: TButton
      Left = 340
      Top = 8
      Width = 105
      Height = 33
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      TabOrder = 1
      OnClick = btCancelClick
    end
  end
end
