object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'fmMain'
  ClientHeight = 670
  ClientWidth = 995
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 220
    Top = 0
    Width = 7
    Height = 648
    Beveled = True
    ExplicitLeft = 185
    ExplicitHeight = 528
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 648
    Width = 995
    Height = 22
    Panels = <>
    SimplePanel = True
    ExplicitTop = 640
    ExplicitWidth = 993
  end
  object pnPersonListview: TPanel
    Left = 0
    Top = 0
    Width = 220
    Height = 648
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitHeight = 640
    object lvPersonListview: TListView
      Left = 0
      Top = 41
      Width = 220
      Height = 582
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
      OnCustomDrawItem = lvPersonListviewCustomDrawItem
      OnSelectItem = lvPersonListviewSelectItem
      ExplicitLeft = 1
      ExplicitTop = 36
    end
    object pnFilter: TPanel
      Left = 0
      Top = 0
      Width = 220
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object cbShowInactivePersons: TCheckBox
        Left = 16
        Top = 13
        Width = 169
        Height = 17
        Caption = 'Inaktive Personen anzeigen'
        TabOrder = 0
        OnClick = cbShowInactivePersonsClick
      end
    end
    object btPersonStartNewRecord: TButton
      Left = 0
      Top = 623
      Width = 220
      Height = 25
      Action = acPersonStartNewRecord
      Align = alBottom
      TabOrder = 2
      ExplicitTop = 615
    end
  end
  object pnPersonDetails: TPanel
    Left = 227
    Top = 0
    Width = 768
    Height = 648
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 766
    ExplicitHeight = 640
    object pcPersonDetails: TPageControl
      Left = 0
      Top = 0
      Width = 768
      Height = 648
      ActivePage = tsPersonaldata
      Align = alClient
      TabOrder = 0
      OnChange = pcPersonDetailsChange
      OnChanging = pcPersonDetailsChanging
      ExplicitWidth = 766
      ExplicitHeight = 640
      object tsPersonaldata: TTabSheet
        Caption = 'Personendaten'
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
          Width = 41
          Height = 15
          Caption = 'Adresse'
        end
        object lbNewAddressPostalcode: TLabel
          Left = 247
          Top = 166
          Width = 20
          Height = 15
          Caption = 'PLZ'
        end
        object lbNewAddressCity: TLabel
          Left = 304
          Top = 166
          Width = 17
          Height = 15
          Caption = 'Ort'
        end
        object lbMembership: TLabel
          Left = 23
          Top = 232
          Width = 76
          Height = 15
          Caption = 'Mitgliedschaft'
        end
        object lbMembershipnumber: TLabel
          Left = 23
          Top = 285
          Width = 95
          Height = 15
          Caption = 'Mitgliedsnummer'
        end
        object lbMembershipBegin: TLabel
          Left = 23
          Top = 338
          Width = 75
          Height = 15
          Caption = 'Eintrittsdatum'
        end
        object lbMembershipEnd: TLabel
          Left = 23
          Top = 386
          Width = 79
          Height = 15
          Caption = 'Austrittsdatum'
        end
        object lbMembershipEndReason: TLabel
          Left = 23
          Top = 436
          Width = 76
          Height = 15
          Caption = 'Austrittsgrund'
        end
        object lbMembershipEndText: TLabel
          Left = 247
          Top = 386
          Width = 111
          Height = 15
          Caption = 'Austrittsdatum (Text)'
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
        object dtPersonBirthday: TDateTimePicker
          Left = 409
          Top = 40
          Width = 176
          Height = 23
          Date = 2.000000000000000000
          Time = 2.000000000000000000
          MaxDate = 69763.999988425930000000
          TabOrder = 4
        end
        object cbPersonBirthdayKnown: TCheckBox
          Left = 383
          Top = 42
          Width = 26
          Height = 16
          TabOrder = 3
        end
        object btPersonSave: TButton
          Left = 22
          Top = 500
          Width = 154
          Height = 25
          Action = acPersonSaveCurrentRecord
          Default = True
          TabOrder = 19
        end
        object btPersonReload: TButton
          Left = 182
          Top = 500
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
          Style = csDropDownList
          TabOrder = 6
        end
        object cbCreateNewAddress: TCheckBox
          Left = 23
          Top = 165
          Width = 170
          Height = 16
          Caption = 'oder neue Adrese: Stra'#223'e'
          TabOrder = 7
          OnClick = cbCreateNewAddressClick
        end
        object edNewAddressStreet: TEdit
          Left = 23
          Top = 187
          Width = 210
          Height = 23
          MaxLength = 100
          TabOrder = 8
        end
        object edNewAddressPostalcode: TEdit
          Left = 247
          Top = 187
          Width = 50
          Height = 23
          MaxLength = 5
          TabOrder = 9
        end
        object edNewAddressCity: TEdit
          Left = 303
          Top = 187
          Width = 160
          Height = 23
          MaxLength = 50
          TabOrder = 10
        end
        object cbMembership: TComboBox
          Left = 23
          Top = 253
          Width = 170
          Height = 23
          Style = csDropDownList
          TabOrder = 11
          Items.Strings = (
            'kein Mitglied'
            'Mitglied'
            'ehemaliges Mitglied')
        end
        object edMembershipNumber: TEdit
          Left = 23
          Top = 306
          Width = 34
          Height = 23
          MaxLength = 3
          NumbersOnly = True
          TabOrder = 12
        end
        object cbMembershipBeginKnown: TCheckBox
          Left = 23
          Top = 361
          Width = 26
          Height = 16
          TabOrder = 13
        end
        object dtMembershipBegin: TDateTimePicker
          Left = 51
          Top = 359
          Width = 182
          Height = 23
          Date = 2.000000000000000000
          Time = 2.000000000000000000
          MaxDate = 69763.999988425930000000
          TabOrder = 14
        end
        object cbMembershipEndKnown: TCheckBox
          Left = 23
          Top = 409
          Width = 26
          Height = 16
          TabOrder = 15
          OnClick = cbMembershipEndKnownClick
        end
        object dtMembershipEnd: TDateTimePicker
          Left = 51
          Top = 407
          Width = 182
          Height = 23
          Date = 2.000000000000000000
          Time = 2.000000000000000000
          MaxDate = 69763.999988425930000000
          TabOrder = 16
        end
        object edMembershipEndText: TEdit
          Left = 247
          Top = 407
          Width = 216
          Height = 23
          MaxLength = 100
          TabOrder = 17
        end
        object edMembershipEndReason: TEdit
          Left = 23
          Top = 458
          Width = 440
          Height = 23
          MaxLength = 100
          TabOrder = 18
        end
      end
      object tsMemberOf: TTabSheet
        Caption = 'Mitglied von ...'
        ImageIndex = 1
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 52
    Top = 85
    object Datei1: TMenuItem
      Caption = 'Datei'
    end
    object Stammdaten1: TMenuItem
      Caption = 'Stammdaten'
      object Adressen1: TMenuItem
        Action = acMasterdataAddresses
      end
      object Einheiten1: TMenuItem
        Action = acMasterdataUnits
      end
      object Rollen1: TMenuItem
        Action = acMasterdataRoles
      end
    end
  end
  object alActionList: TActionList
    Left = 52
    Top = 154
    object acPersonSaveCurrentRecord: TAction
      Caption = #196'nderungen speichern'
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
    object acMasterdataUnits: TAction
      Caption = 'Einheiten bearbeiten'
      OnExecute = acMasterdataUnitsExecute
    end
    object acMasterdataAddresses: TAction
      Caption = 'Adressen bearbeiten'
    end
    object acMasterdataRoles: TAction
      Caption = 'Rollen bearbeiten'
    end
  end
end
