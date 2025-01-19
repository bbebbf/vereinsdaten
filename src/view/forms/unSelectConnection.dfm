object fmSelectConnection: TfmSelectConnection
  Left = 0
  Top = 0
  ActiveControl = cbConnections
  BorderStyle = bsDialog
  Caption = 'Datenbankverbing ausw'#228'hlen'
  ClientHeight = 145
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object btStartApp: TButton
    Left = 22
    Top = 99
    Width = 154
    Height = 25
    Caption = 'Starten'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btCancelAppStart: TButton
    Left = 246
    Top = 99
    Width = 154
    Height = 25
    Cancel = True
    Caption = 'Abbrechen'
    ModalResult = 2
    TabOrder = 2
  end
  object cbConnections: TComboBox
    Left = 22
    Top = 40
    Width = 378
    Height = 23
    Style = csDropDownList
    TabOrder = 0
  end
end
