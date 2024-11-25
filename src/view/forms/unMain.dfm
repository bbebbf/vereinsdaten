object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'fmMain'
  ClientHeight = 550
  ClientWidth = 995
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 220
    Top = 0
    Width = 7
    Height = 528
    Beveled = True
    ExplicitLeft = 185
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 528
    Width = 995
    Height = 22
    Panels = <>
    ExplicitTop = 520
    ExplicitWidth = 993
  end
  object pnPersonListview: TPanel
    Left = 0
    Top = 0
    Width = 220
    Height = 528
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitHeight = 520
    object lvPersonListview: TListView
      Left = 0
      Top = 41
      Width = 220
      Height = 487
      Align = alClient
      Columns = <
        item
          AutoSize = True
        end>
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 0
      ViewStyle = vsReport
      OnCustomDrawItem = lvPersonListviewCustomDrawItem
      OnSelectItem = lvPersonListviewSelectItem
      ExplicitLeft = 1
      ExplicitTop = 62
      ExplicitHeight = 460
    end
    object pnFilter: TPanel
      Left = 0
      Top = 0
      Width = 220
      Height = 41
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitLeft = 16
      ExplicitWidth = 185
      object cbShowInactivePersons: TCheckBox
        Left = 8
        Top = 13
        Width = 169
        Height = 17
        Caption = 'Inaktive Personen anzeigen'
        TabOrder = 0
        OnClick = cbShowInactivePersonsClick
      end
    end
  end
  object pnPersonDetails: TPanel
    Left = 227
    Top = 0
    Width = 768
    Height = 528
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 766
    ExplicitHeight = 520
    object pcPersonDetails: TPageControl
      Left = 0
      Top = 0
      Width = 768
      Height = 528
      ActivePage = tsBasicdata
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 766
      ExplicitHeight = 520
      object tsBasicdata: TTabSheet
        Caption = 'Basisdaten'
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
        object dtPersonBithday: TDateTimePicker
          Left = 409
          Top = 40
          Width = 176
          Height = 23
          Date = 9133.000000000000000000
          Time = 9133.000000000000000000
          MaxDate = 69763.999988425930000000
          MinDate = 9133.000000000000000000
          TabOrder = 4
        end
        object cbPersonBirthdayKnown: TCheckBox
          Left = 383
          Top = 42
          Width = 26
          Height = 16
          TabOrder = 3
          OnClick = cbPersonBirthdayKnownClick
        end
        object btPersonSave: TButton
          Left = 23
          Top = 223
          Width = 154
          Height = 25
          Action = acPersonSaveCurrentRecord
          TabOrder = 11
        end
        object btPersonReload: TButton
          Left = 183
          Top = 223
          Width = 154
          Height = 25
          Action = acPersonReloadCurrentRecord
          TabOrder = 12
        end
        object cbPersonActive: TCheckBox
          Left = 23
          Top = 82
          Width = 145
          Height = 16
          Caption = 'Aktiv'
          TabOrder = 5
          OnClick = cbPersonBirthdayKnownClick
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
          Width = 218
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
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 52
    Top = 85
    object Datei1: TMenuItem
      Caption = 'Datei'
    end
  end
  object alPersonActionList: TActionList
    Left = 52
    Top = 154
    object acPersonSaveCurrentRecord: TAction
      Caption = 'Daten speichern'
      OnExecute = acPersonSaveCurrentRecordExecute
    end
    object acPersonReloadCurrentRecord: TAction
      Caption = 'Daten wiederherstellen'
      OnExecute = acPersonReloadCurrentRecordExecute
    end
  end
end
