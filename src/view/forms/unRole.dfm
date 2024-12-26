object fmRole: TfmRole
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Rollen bearbeiten'
  ClientHeight = 695
  ClientWidth = 995
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
    object lvListview: TListView
      Left = 0
      Top = 41
      Width = 350
      Height = 629
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
    end
    object btStartNewRecord: TButton
      Left = 0
      Top = 670
      Width = 350
      Height = 25
      Action = acStartNewEntry
      Align = alBottom
      TabOrder = 2
    end
  end
  object pnDetails: TPanel
    Left = 357
    Top = 0
    Width = 638
    Height = 695
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 356
    object lbRoleName: TLabel
      Left = 23
      Top = 19
      Width = 68
      Height = 15
      Caption = 'Bezeichnung'
    end
    object lbSorting: TLabel
      Left = 23
      Top = 83
      Width = 55
      Height = 15
      Caption = 'Sortierung'
    end
    object edRoleName: TEdit
      Left = 23
      Top = 40
      Width = 442
      Height = 23
      MaxLength = 100
      TabOrder = 0
    end
    object btSave: TButton
      Left = 23
      Top = 188
      Width = 154
      Height = 25
      Action = acSaveCurrentEntry
      Default = True
      TabOrder = 2
    end
    object btReload: TButton
      Left = 190
      Top = 188
      Width = 154
      Height = 25
      Action = acReloadCurrentEntry
      Cancel = True
      TabOrder = 3
    end
    object edRoleSorting: TEdit
      Left = 23
      Top = 107
      Width = 55
      Height = 23
      NumbersOnly = True
      TabOrder = 1
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
