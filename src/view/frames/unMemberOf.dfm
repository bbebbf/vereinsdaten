object fraMemberOf: TfraMemberOf
  Left = 0
  Top = 0
  Width = 941
  Height = 722
  TabOrder = 0
  object lvMemberOf: TListView
    Left = 0
    Top = 0
    Width = 941
    Height = 624
    Align = alClient
    Columns = <
      item
        Caption = 'Einheit'
        Width = 250
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
    PopupMenu = PopupMenu
    TabOrder = 0
    ViewStyle = vsReport
    OnCustomDrawItem = lvMemberOfCustomDrawItem
    OnDblClick = lvMemberOfDblClick
    OnSelectItem = lvMemberOfSelectItem
  end
  object pnCommands: TPanel
    Left = 0
    Top = 624
    Width = 941
    Height = 98
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      941
      98)
    object lbMemberOfsVersionInfo: TLabel
      Left = 367
      Top = 61
      Width = 132
      Height = 15
      Caption = 'lbMemberOfsVersionInfo'
    end
    object cbShowInactiveMemberOfs: TCheckBox
      Left = 728
      Top = 64
      Width = 193
      Height = 17
      Action = acShowInactiveMemberOfs
      Anchors = [akRight, akBottom]
      TabOrder = 5
    end
    object btSaveMemberOfs: TButton
      Left = 15
      Top = 57
      Width = 154
      Height = 25
      Action = acSaveMemberOfs
      TabOrder = 3
    end
    object btReloadMemberOfs: TButton
      Left = 191
      Top = 57
      Width = 154
      Height = 25
      Action = acReloadMemberOfs
      TabOrder = 4
    end
    object btNewMemberOf: TButton
      Left = 15
      Top = 11
      Width = 154
      Height = 25
      Action = acNewMemberOf
      TabOrder = 0
    end
    object btEditMemberOf: TButton
      Left = 191
      Top = 11
      Width = 154
      Height = 25
      Action = acEditMemberOf
      TabOrder = 1
    end
    object btDeleteMemberOf: TButton
      Left = 367
      Top = 11
      Width = 154
      Height = 25
      Action = acDeleteMemberOf
      TabOrder = 2
    end
  end
  object alMemberOfsActionList: TActionList
    Left = 48
    Top = 544
    object acNewMemberOf: TAction
      Caption = 'Verbindung hinzuf'#252'gen'
      OnExecute = acNewMemberOfExecute
    end
    object acEditMemberOf: TAction
      Caption = 'Verbindung bearbeiten'
      OnExecute = acEditMemberOfExecute
    end
    object acDeleteMemberOf: TAction
      Caption = 'Verbindung entfernen'
      OnExecute = acDeleteMemberOfExecute
    end
    object acSaveMemberOfs: TAction
      Caption = #196'nderungen speichern'
      ShortCut = 16467
      OnExecute = acSaveMemberOfsExecute
    end
    object acReloadMemberOfs: TAction
      Caption = #196'nderungen verwerfen'
      OnExecute = acReloadMemberOfsExecute
    end
    object acShowInactiveMemberOfs: TAction
      AutoCheck = True
      Caption = 'Inaktive Verbindungen anzeigen'
      OnExecute = acShowInactiveMemberOfsExecute
    end
  end
  object PopupMenu: TPopupMenu
    Left = 56
    Top = 336
    object Verbindunghinzufgen1: TMenuItem
      Action = acNewMemberOf
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Verbindungbearbeiten1: TMenuItem
      Action = acEditMemberOf
    end
    object Verbindungentfernen1: TMenuItem
      Action = acDeleteMemberOf
    end
  end
end
