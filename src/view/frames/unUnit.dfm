object fraUnit: TfraUnit
  Left = 0
  Top = 0
  Width = 1077
  Height = 694
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 350
    Top = 40
    Width = 7
    Height = 654
    Beveled = True
    ExplicitLeft = 185
    ExplicitTop = 0
    ExplicitHeight = 528
  end
  object pnListview: TPanel
    Left = 0
    Top = 40
    Width = 350
    Height = 654
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object lbListviewItemCount: TLabel
      Left = 0
      Top = 604
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
      Height = 563
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
      OnDblClick = lvListviewDblClick
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
      Top = 629
      Width = 350
      Height = 25
      Action = acStartNewEntry
      Align = alBottom
      TabOrder = 2
    end
  end
  object pnDetails: TPanel
    Left = 357
    Top = 40
    Width = 720
    Height = 654
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object lvMemberOf: TListView
      Left = 0
      Top = 337
      Width = 720
      Height = 152
      Align = alTop
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
      TabOrder = 1
      ViewStyle = vsReport
      OnCustomDrawItem = lvMemberOfCustomDrawItem
    end
    object pnTopRight: TPanel
      Left = 0
      Top = 0
      Width = 720
      Height = 337
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
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
      object lbVersionInfo: TLabel
        Left = 23
        Top = 299
        Width = 69
        Height = 15
        Caption = 'lbVersionInfo'
      end
      object lbDataConfirmedOn: TLabel
        Left = 23
        Top = 182
        Width = 103
        Height = 15
        Caption = 'Daten best'#228'tigt am:'
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
        TabOrder = 1
      end
      object dtUnitActiveSince: TDateTimePicker
        Left = 49
        Top = 139
        Width = 176
        Height = 23
        Date = 2.000000000000000000
        Time = 2.000000000000000000
        MaxDate = 69763.999988425930000000
        TabOrder = 2
      end
      object cbUnitActive: TCheckBox
        Left = 23
        Top = 82
        Width = 145
        Height = 16
        Caption = 'Aktiv'
        TabOrder = 3
      end
      object dtUnitActiveUntil: TDateTimePicker
        Left = 289
        Top = 139
        Width = 176
        Height = 23
        Date = 2.000000000000000000
        Time = 2.000000000000000000
        MaxDate = 69763.999988425930000000
        TabOrder = 4
      end
      object cbUnitActiveUntilKnown: TCheckBox
        Left = 263
        Top = 141
        Width = 26
        Height = 16
        TabOrder = 5
      end
      object btSave: TButton
        Left = 23
        Top = 252
        Width = 154
        Height = 25
        Action = acSaveCurrentEntry
        Default = True
        TabOrder = 6
      end
      object btReload: TButton
        Left = 190
        Top = 252
        Width = 154
        Height = 25
        Action = acReloadCurrentEntry
        Cancel = True
        TabOrder = 7
      end
      object cbDataConfirmedOnKnown: TCheckBox
        Left = 23
        Top = 205
        Width = 26
        Height = 16
        TabOrder = 8
      end
      object dtDataConfirmedOn: TDateTimePicker
        Left = 49
        Top = 203
        Width = 176
        Height = 23
        Date = 2.000000000000000000
        Time = 2.000000000000000000
        MaxDate = 69763.999988425930000000
        TabOrder = 9
      end
    end
    object pnMemberOf: TPanel
      Left = 0
      Top = 489
      Width = 720
      Height = 165
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      ExplicitLeft = 208
      ExplicitTop = 520
      ExplicitWidth = 289
      ExplicitHeight = 121
    end
  end
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 1077
    Height = 40
    Align = alTop
    TabOrder = 0
    DesignSize = (
      1077
      40)
    object lbTitle: TLabel
      Left = 16
      Top = 7
      Width = 137
      Height = 20
      Caption = 'Einheiten bearbeiten'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object btReturn: TButton
      Left = 984
      Top = 7
      Width = 78
      Height = 26
      Anchors = [akTop, akRight]
      Caption = 'Zur'#252'ck'
      TabOrder = 0
      OnClick = btReturnClick
    end
  end
  object alActionList: TActionList
    Left = 52
    Top = 154
    object acSaveCurrentEntry: TAction
      Caption = #196'nderungen speichern'
      ShortCut = 16467
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
