object fmUnit: TfmUnit
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Einheiten bearbeiten'
  ClientHeight = 695
  ClientWidth = 1098
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 350
    Top = 0
    Width = 7
    Height = 695
    Beveled = True
    ExplicitLeft = 185
    ExplicitHeight = 528
  end
  object pnListview: TPanel
    Left = 0
    Top = 0
    Width = 350
    Height = 695
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 687
    object lbListviewItemCount: TLabel
      Left = 0
      Top = 645
      Width = 350
      Height = 25
      Align = alBottom
      Alignment = taCenter
      AutoSize = False
      Caption = '000'
      ExplicitTop = 586
      ExplicitWidth = 285
    end
    object lvListview: TListView
      Left = 0
      Top = 41
      Width = 350
      Height = 604
      Align = alClient
      Columns = <
        item
          Width = 320
        end>
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 1
      ViewStyle = vsReport
      OnCustomDrawItem = lvListviewCustomDrawItem
      OnSelectItem = lvListviewSelectItem
    end
    object pnFilter: TPanel
      Left = 0
      Top = 0
      Width = 350
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object cbShowInactiveUnits: TCheckBox
        Left = 16
        Top = 13
        Width = 169
        Height = 17
        Caption = 'Inaktive Einheiten anzeigen'
        TabOrder = 0
        OnClick = cbShowInactiveUnitsClick
      end
    end
    object btStartNewRecord: TButton
      Left = 0
      Top = 670
      Width = 350
      Height = 25
      Action = acStartNewEntry
      Align = alBottom
      TabOrder = 2
      ExplicitTop = 662
    end
  end
  object pnDetails: TPanel
    Left = 357
    Top = 0
    Width = 741
    Height = 695
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 739
    ExplicitHeight = 687
    object lbUnitName: TLabel
      Left = 23
      Top = 19
      Width = 68
      Height = 15
      Caption = 'Bezeichnung'
    end
    object lbUnitActiveSince: TLabel
      Left = 23
      Top = 118
      Width = 48
      Height = 15
      Caption = 'Aktiv seit'
    end
    object lbUnitActiveUntil: TLabel
      Left = 263
      Top = 118
      Width = 45
      Height = 15
      Caption = 'Aktiv bis'
    end
    object edUnitName: TEdit
      Left = 23
      Top = 40
      Width = 442
      Height = 23
      MaxLength = 100
      TabOrder = 0
    end
    object cbUnitActiveSinceKnown: TCheckBox
      Left = 23
      Top = 141
      Width = 26
      Height = 16
      TabOrder = 2
    end
    object dtUnitActiveSince: TDateTimePicker
      Left = 49
      Top = 139
      Width = 176
      Height = 23
      Date = 2.000000000000000000
      Time = 2.000000000000000000
      MaxDate = 69763.999988425930000000
      TabOrder = 3
    end
    object cbUnitActive: TCheckBox
      Left = 23
      Top = 82
      Width = 145
      Height = 16
      Caption = 'Aktiv'
      TabOrder = 1
    end
    object dtUnitActiveUntil: TDateTimePicker
      Left = 289
      Top = 139
      Width = 176
      Height = 23
      Date = 2.000000000000000000
      Time = 2.000000000000000000
      MaxDate = 69763.999988425930000000
      TabOrder = 5
    end
    object cbUnitActiveUntilKnown: TCheckBox
      Left = 263
      Top = 141
      Width = 26
      Height = 16
      TabOrder = 4
    end
    object btSave: TButton
      Left = 23
      Top = 188
      Width = 154
      Height = 25
      Action = acSaveCurrentEntry
      Default = True
      TabOrder = 6
    end
    object btReload: TButton
      Left = 190
      Top = 188
      Width = 154
      Height = 25
      Action = acReloadCurrentEntry
      Cancel = True
      TabOrder = 7
    end
    object lvMemberOf: TListView
      Left = 0
      Top = 240
      Width = 741
      Height = 455
      Align = alBottom
      Columns = <
        item
          Caption = 'Person'
          Width = 200
        end
        item
          Caption = 'Rolle'
          Width = 200
        end
        item
          Caption = 'Eintritt'
          Width = 120
        end
        item
          Caption = 'Status'
          Width = 70
        end
        item
          Caption = 'Austritt'
          Width = 120
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 8
      ViewStyle = vsReport
      OnCustomDrawItem = lvMemberOfCustomDrawItem
    end
  end
  object alActionList: TActionList
    Left = 52
    Top = 154
    object acSaveCurrentEntry: TAction
      Caption = #196'nderungen speichern'
      OnExecute = acSaveCurrentEntryExecute
    end
    object acReloadCurrentEntry: TAction
      Caption = #196'nderungen verwerfen'
      OnExecute = acReloadCurrentEntryExecute
    end
    object acStartNewEntry: TAction
      Caption = 'Neuen Datensatz starten'
      OnExecute = acStartNewEntryExecute
    end
  end
end
