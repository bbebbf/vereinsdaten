object fmAddress: TfmAddress
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Adressen bearbeiten'
  ClientHeight = 695
  ClientWidth = 964
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
    Left = 570
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
    Width = 570
    Height = 695
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 687
    object lbListviewItemCount: TLabel
      Left = 0
      Top = 670
      Width = 570
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
      Width = 570
      Height = 629
      Align = alClient
      Columns = <
        item
          Caption = 'Ort'
          Width = 175
        end
        item
          Caption = 'Stra'#223'e'
          Width = 270
        end
        item
          Caption = 'PLZ'
          Width = 80
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      OnDblClick = lvListviewDblClick
      OnSelectItem = lvListviewSelectItem
    end
    object pnFilter: TPanel
      Left = 0
      Top = 0
      Width = 570
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
    end
  end
  object pnDetails: TPanel
    Left = 577
    Top = 0
    Width = 387
    Height = 695
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 385
    ExplicitHeight = 687
    object lbAddressPostalcode: TLabel
      Left = 23
      Top = 86
      Width = 20
      Height = 15
      Caption = 'PLZ'
    end
    object lbAddressCity: TLabel
      Left = 80
      Top = 86
      Width = 17
      Height = 15
      Caption = 'Ort'
    end
    object lbAddressStreet: TLabel
      Left = 23
      Top = 36
      Width = 33
      Height = 15
      Caption = 'Stra'#223'e'
    end
    object lbVersionInfo: TLabel
      Left = 23
      Top = 191
      Width = 322
      Height = 38
      AutoSize = False
      Caption = 'lbVersionInfo'
      WordWrap = True
    end
    object btSave: TButton
      Left = 23
      Top = 152
      Width = 154
      Height = 25
      Action = acSaveCurrentEntry
      Default = True
      TabOrder = 3
    end
    object btReload: TButton
      Left = 190
      Top = 152
      Width = 154
      Height = 25
      Action = acReloadCurrentEntry
      Cancel = True
      TabOrder = 4
    end
    object lvMemberOf: TListView
      Left = 0
      Top = 240
      Width = 387
      Height = 455
      Align = alBottom
      Columns = <
        item
          AutoSize = True
          Caption = 'Person'
        end>
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 5
      ViewStyle = vsReport
    end
    object edAddressStreet: TEdit
      Left = 23
      Top = 57
      Width = 321
      Height = 23
      MaxLength = 100
      TabOrder = 0
    end
    object edAddressPostalcode: TEdit
      Left = 23
      Top = 107
      Width = 50
      Height = 23
      MaxLength = 5
      TabOrder = 1
    end
    object edAddressCity: TEdit
      Left = 79
      Top = 107
      Width = 265
      Height = 23
      MaxLength = 50
      TabOrder = 2
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
    object acDeleteCurrentEntry: TAction
      Caption = 'Diese Adresse l'#246'schen'
    end
  end
end
