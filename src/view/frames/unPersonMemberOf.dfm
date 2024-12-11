object fraPersonMemberOf: TfraPersonMemberOf
  Left = 0
  Top = 0
  Width = 941
  Height = 722
  TabOrder = 0
  object lvMemberOf: TListView
    Left = 0
    Top = 0
    Width = 941
    Height = 672
    Align = alClient
    Columns = <
      item
        Caption = 'Einheit'
        Width = 200
      end
      item
        Caption = 'Rolle'
        Width = 150
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
    TabOrder = 0
    ViewStyle = vsReport
    OnCustomDrawItem = lvMemberOfCustomDrawItem
  end
  object pnCommands: TPanel
    Left = 0
    Top = 672
    Width = 941
    Height = 50
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      941
      50)
    object cbShowInactiveMemberOfs: TCheckBox
      Left = 728
      Top = 16
      Width = 193
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Inaktive Verbindungen anzeigen'
      TabOrder = 0
      OnClick = cbShowInactiveMemberOfsClick
    end
  end
end
