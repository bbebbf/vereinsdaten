object fmSimpleMasterdataForm: TfmSimpleMasterdataForm
  Left = 0
  Top = 0
  Caption = 'fmSimpleMasterdataForm'
  ClientHeight = 616
  ClientWidth = 992
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 250
    Top = 0
    Height = 616
    ExplicitLeft = 220
  end
  object pnList: TPanel
    Left = 0
    Top = 0
    Width = 250
    Height = 616
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object pnFilter: TPanel
      Left = 0
      Top = 0
      Width = 250
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitTop = 8
      ExplicitWidth = 185
    end
    object lvListview: TListView
      Left = 0
      Top = 41
      Width = 250
      Height = 543
      Align = alClient
      Columns = <
        item
          AutoSize = True
        end>
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 1
      ViewStyle = vsReport
      ExplicitLeft = -3
      ExplicitTop = 35
      ExplicitWidth = 185
      ExplicitHeight = 368
    end
    object btNewRecord: TButton
      Left = 0
      Top = 584
      Width = 250
      Height = 32
      Align = alBottom
      TabOrder = 2
      ExplicitTop = 409
      ExplicitWidth = 185
    end
  end
  object pnRecord: TPanel
    Left = 253
    Top = 0
    Width = 739
    Height = 616
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 256
    object pnActions: TPanel
      Left = 0
      Top = 581
      Width = 739
      Height = 35
      Align = alBottom
      BevelInner = bvLowered
      TabOrder = 0
      ExplicitTop = 403
      ExplicitWidth = 550
      object btPersonSave: TButton
        Left = 30
        Top = 2
        Width = 154
        Height = 25
        Default = True
        TabOrder = 0
      end
      object btPersonReload: TButton
        Left = 190
        Top = 2
        Width = 154
        Height = 25
        Cancel = True
        TabOrder = 1
      end
    end
  end
end
