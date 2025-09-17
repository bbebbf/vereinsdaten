object fraPerson: TfraPerson
  Left = 0
  Top = 0
  Width = 907
  Height = 727
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 285
    Top = 40
    Width = 7
    Height = 687
    Beveled = True
    ExplicitLeft = 185
    ExplicitTop = 0
    ExplicitHeight = 528
  end
  object pnPersonListview: TPanel
    Left = 0
    Top = 40
    Width = 285
    Height = 687
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object lbListviewItemCount: TLabel
      Left = 0
      Top = 637
      Width = 285
      Height = 25
      Align = alBottom
      Alignment = taCenter
      AutoSize = False
      Caption = '000'
      ExplicitTop = 586
    end
    object lvPersonListview: TListView
      Left = 0
      Top = 89
      Width = 285
      Height = 548
      Align = alClient
      Columns = <
        item
          Width = 260
        end>
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 1
      ViewStyle = vsReport
      OnCustomDrawItem = lvPersonListviewCustomDrawItem
      OnDblClick = lvPersonListviewDblClick
      OnSelectItem = lvPersonListviewSelectItem
    end
    object pnFilter: TPanel
      Left = 0
      Top = 0
      Width = 285
      Height = 89
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        285
        89)
      object lbFilter: TLabel
        Left = 16
        Top = 63
        Width = 29
        Height = 15
        Anchors = [akLeft, akBottom]
        Caption = 'Filter:'
      end
      object cbShowInactivePersons: TCheckBox
        Left = 16
        Top = 13
        Width = 169
        Height = 17
        Caption = 'Inaktive Personen anzeigen'
        TabOrder = 0
        OnClick = cbCheckboxFilterPersonsClick
      end
      object edFilter: TEdit
        Left = 53
        Top = 60
        Width = 226
        Height = 23
        Anchors = [akLeft, akRight, akBottom]
        TabOrder = 2
        OnChange = edFilterChange
      end
      object cbShowExternalPersons: TCheckBox
        Left = 16
        Top = 36
        Width = 169
        Height = 17
        Caption = 'Externe Personen anzeigen'
        TabOrder = 1
        OnClick = cbCheckboxFilterPersonsClick
      end
    end
    object btPersonStartNewRecord: TButton
      Left = 0
      Top = 662
      Width = 285
      Height = 25
      Action = acPersonStartNewRecord
      Align = alBottom
      TabOrder = 2
    end
  end
  object pnPersonDetails: TPanel
    Left = 292
    Top = 40
    Width = 615
    Height = 687
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object pcPersonDetails: TPageControl
      Left = 0
      Top = 0
      Width = 615
      Height = 687
      ActivePage = tsPersonaldata
      Align = alClient
      TabOrder = 0
      OnChange = pcPersonDetailsChange
      OnChanging = pcPersonDetailsChanging
      object tsPersonaldata: TTabSheet
        Caption = '&Personendaten'
        object lbPersonFirstname: TLabel
          Left = 23
          Top = 19
          Width = 47
          Height = 15
          Caption = 'Vorname'
        end
        object lbPersonLastname: TLabel
          Left = 215
          Top = 19
          Width = 58
          Height = 15
          Caption = 'Nachname'
        end
        object lbPersonBirthday: TLabel
          Left = 383
          Top = 19
          Width = 76
          Height = 15
          Caption = 'Geburtsdatum'
        end
        object lbPersonAdress: TLabel
          Left = 23
          Top = 115
          Width = 244
          Height = 15
          Caption = 'Adresse ausw'#228'hlen bzw. neue Stra'#223'e / Hausnr.'
        end
        object lbNewAddressPostalcodeCity: TLabel
          Left = 23
          Top = 166
          Width = 93
          Height = 15
          Caption = 'neue PLZ und Ort'
        end
        object lbMembership: TLabel
          Left = 23
          Top = 319
          Width = 76
          Height = 15
          Caption = 'Mitgliedschaft'
        end
        object lbMembershipnumber: TLabel
          Left = 215
          Top = 319
          Width = 95
          Height = 15
          Caption = 'Mitgliedsnummer'
        end
        object lbMembershipBegin: TLabel
          Left = 23
          Top = 367
          Width = 75
          Height = 15
          Caption = 'Eintrittsdatum'
        end
        object lbMembershipEnd: TLabel
          Left = 23
          Top = 415
          Width = 79
          Height = 15
          Caption = 'Austrittsdatum'
        end
        object lbMembershipEndReason: TLabel
          Left = 23
          Top = 465
          Width = 76
          Height = 15
          Caption = 'Austrittsgrund'
        end
        object lbMembershipEndText: TLabel
          Left = 142
          Top = 415
          Width = 111
          Height = 15
          Caption = 'Austrittsdatum (Text)'
        end
        object lbBasedataVersionInfo: TLabel
          Left = 22
          Top = 564
          Width = 116
          Height = 15
          Caption = 'lbBasedataVersionInfo'
        end
        object lbEMailaddress: TLabel
          Left = 23
          Top = 219
          Width = 76
          Height = 15
          Caption = 'E-Mailadresse:'
        end
        object lbPhonenumber: TLabel
          Left = 383
          Top = 219
          Width = 88
          Height = 15
          Caption = 'Telefonnummer:'
        end
        object edPersonFirstname: TEdit
          Left = 23
          Top = 40
          Width = 145
          Height = 23
          MaxLength = 100
          TabOrder = 0
        end
        object edPersonPraeposition: TEdit
          Left = 175
          Top = 40
          Width = 34
          Height = 23
          MaxLength = 10
          TabOrder = 1
        end
        object edPersonLastname: TEdit
          Left = 215
          Top = 40
          Width = 145
          Height = 23
          MaxLength = 100
          TabOrder = 2
        end
        object btPersonSave: TButton
          Left = 22
          Top = 529
          Width = 154
          Height = 25
          Action = acPersonSaveCurrentRecord
          Default = True
          TabOrder = 19
        end
        object btPersonReload: TButton
          Left = 182
          Top = 529
          Width = 154
          Height = 25
          Action = acPersonReloadCurrentRecord
          Cancel = True
          TabOrder = 20
        end
        object cbPersonActive: TCheckBox
          Left = 23
          Top = 82
          Width = 145
          Height = 16
          Caption = 'Aktiv'
          TabOrder = 5
        end
        object cbPersonAddress: TComboBox
          Left = 23
          Top = 136
          Width = 440
          Height = 23
          TabOrder = 7
          OnChange = cbPersonAddressChange
          OnSelect = cbPersonAddressSelect
        end
        object edNewAddressPostalcode: TEdit
          Left = 23
          Top = 187
          Width = 50
          Height = 23
          MaxLength = 5
          TabOrder = 8
        end
        object edNewAddressCity: TEdit
          Left = 80
          Top = 187
          Width = 280
          Height = 23
          MaxLength = 50
          TabOrder = 9
        end
        object cbMembership: TComboBox
          Left = 23
          Top = 340
          Width = 170
          Height = 23
          Style = csDropDownList
          TabOrder = 13
          Items.Strings = (
            'kein Mitglied'
            'Mitglied'
            'ehemaliges Mitglied')
        end
        object edMembershipEndText: TEdit
          Left = 142
          Top = 436
          Width = 321
          Height = 23
          MaxLength = 100
          TabOrder = 17
        end
        object edMembershipEndReason: TEdit
          Left = 23
          Top = 487
          Width = 440
          Height = 23
          MaxLength = 100
          TabOrder = 18
        end
        object cbPersonOnBirthdaylist: TCheckBox
          Left = 383
          Top = 82
          Width = 203
          Height = 16
          Caption = 'auf Geburtstagsliste anzeigen'
          TabOrder = 4
        end
        object cbPersonExternal: TCheckBox
          Left = 215
          Top = 82
          Width = 145
          Height = 16
          Caption = 'Extern'
          TabOrder = 6
        end
        object dePersonBirthday: TDateEdit
          Left = 384
          Top = 40
          Width = 113
          Height = 23
          TabOrder = 3
          OnChange = dePersonBirthdayChange
          OptionalYear = True
        end
        object deMembershipBegin: TDateEdit
          Left = 23
          Top = 388
          Width = 113
          Height = 23
          TabOrder = 15
        end
        object deMembershipEnd: TDateEdit
          Left = 23
          Top = 436
          Width = 113
          Height = 23
          TabOrder = 16
          OnValueChanged = deMembershipEndValueChanged
        end
        object ieMembershipNumber: TIntegerEdit
          Left = 215
          Top = 340
          Width = 50
          Height = 23
          TabOrder = 14
          BoundsLower.Null = False
          BoundsLower.Value = 1
          BoundsUpper.Null = False
          BoundsUpper.Value = 9999
        end
        object edEMailaddress: TEdit
          Left = 23
          Top = 240
          Width = 337
          Height = 23
          MaxLength = 100
          TabOrder = 10
          OnExit = edEMailaddressExit
        end
        object edPhonenumber: TEdit
          Left = 383
          Top = 240
          Width = 193
          Height = 23
          MaxLength = 50
          TabOrder = 11
          OnExit = edPhonenumberExit
        end
        object cbPhonePriority: TCheckBox
          Left = 23
          Top = 273
          Width = 337
          Height = 16
          Caption = 'Telefonnummer hat Vorrang gegen'#252'ber der E-Mailadresse'
          TabOrder = 12
        end
      end
      object tsMemberOf: TTabSheet
        Caption = '&Teil von ...'
        ImageIndex = 1
      end
    end
  end
  object pnTop: TPanel
    Left = 0
    Top = 0
    Width = 907
    Height = 40
    Align = alTop
    TabOrder = 2
    object lbTitle: TLabel
      Left = 16
      Top = 7
      Width = 135
      Height = 20
      Caption = 'Personen bearbeiten'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object alActionList: TActionList
    Left = 52
    Top = 154
    object acPersonSaveCurrentRecord: TAction
      Caption = #196'nderungen speichern'
      ShortCut = 16467
      OnExecute = acPersonSaveCurrentRecordExecute
    end
    object acPersonReloadCurrentRecord: TAction
      Caption = #196'nderungen verwerfen'
      OnExecute = acPersonReloadCurrentRecordExecute
    end
    object acPersonStartNewRecord: TAction
      Caption = 'Neuen Datensatz starten'
      OnExecute = acPersonStartNewRecordExecute
    end
  end
end
