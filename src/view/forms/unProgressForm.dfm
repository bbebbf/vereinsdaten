object fmProgressForm: TfmProgressForm
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'fmProgressForm'
  ClientHeight = 114
  ClientWidth = 538
  Color = clHighlight
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Padding.Left = 4
  Padding.Top = 4
  Padding.Right = 4
  Padding.Bottom = 4
  Position = poScreenCenter
  TextHeight = 15
  object pnMain: TPanel
    Left = 4
    Top = 4
    Width = 530
    Height = 106
    Align = alClient
    Padding.Left = 7
    Padding.Top = 7
    Padding.Right = 7
    Padding.Bottom = 7
    ParentBackground = False
    TabOrder = 0
    object lbPrimarytext: TLabel
      Left = 8
      Top = 8
      Width = 514
      Height = 56
      Align = alClient
      Alignment = taCenter
      Caption = 'Primarytext'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitWidth = 89
      ExplicitHeight = 25
    end
    object lbSecondarytext: TLabel
      Left = 8
      Top = 81
      Width = 514
      Height = 17
      Align = alBottom
      Alignment = taCenter
      Caption = 'Secondarytext'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitTop = 78
      ExplicitWidth = 82
    end
    object pbProgress: TProgressBar
      Left = 8
      Top = 64
      Width = 514
      Height = 17
      Align = alBottom
      TabOrder = 0
      ExplicitTop = 61
    end
  end
end
