object fmMemberOfsEditDlg: TfmMemberOfsEditDlg
  Left = 0
  Top = 0
  ActiveControl = cbDetailItem
  BorderStyle = bsDialog
  Caption = 'Verbindung ...'
  ClientHeight = 359
  ClientWidth = 507
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object lbDetailItem: TLabel
    Left = 23
    Top = 19
    Width = 36
    Height = 15
    Caption = 'Einheit'
  end
  object lbRole: TLabel
    Left = 23
    Top = 83
    Width = 26
    Height = 15
    Caption = 'Rolle'
  end
  object lbMembershipBegin: TLabel
    Left = 23
    Top = 186
    Width = 75
    Height = 15
    Caption = 'Eintrittsdatum'
  end
  object lbMembershipEnd: TLabel
    Left = 158
    Top = 186
    Width = 79
    Height = 15
    Caption = 'Austrittsdatum'
  end
  object cbDetailItem: TComboBox
    Left = 23
    Top = 40
    Width = 457
    Height = 23
    TabOrder = 0
  end
  object cbActive: TCheckBox
    Left = 23
    Top = 152
    Width = 145
    Height = 16
    Caption = 'Aktiv'
    TabOrder = 2
  end
  object btSave: TButton
    Left = 23
    Top = 307
    Width = 154
    Height = 25
    Caption = #196'nderungen '#252'bernehmen'
    Default = True
    TabOrder = 5
    OnClick = btSaveClick
  end
  object btReload: TButton
    Left = 326
    Top = 307
    Width = 154
    Height = 25
    Cancel = True
    Caption = #196'nderungen verwerfen'
    ModalResult = 2
    TabOrder = 6
  end
  object cbRole: TComboBox
    Left = 23
    Top = 104
    Width = 457
    Height = 23
    TabOrder = 1
  end
  object deMembershipBegin: TDateEdit
    Left = 23
    Top = 207
    Width = 121
    Height = 23
    TabOrder = 3
  end
  object deMembershipEnd: TDateEdit
    Left = 158
    Top = 207
    Width = 121
    Height = 23
    TabOrder = 4
  end
end
