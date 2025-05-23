object fmTenant: TfmTenant
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Vereinsdaten bearbeiten'
  ClientHeight = 154
  ClientWidth = 558
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  TextHeight = 15
  object lbTenantTitle: TLabel
    Left = 23
    Top = 19
    Width = 68
    Height = 15
    Caption = 'Bezeichnung'
  end
  object edTenantTitle: TEdit
    Left = 23
    Top = 40
    Width = 442
    Height = 23
    MaxLength = 100
    TabOrder = 0
  end
  object btSave: TButton
    Left = 23
    Top = 100
    Width = 154
    Height = 25
    Action = acSaveCurrentEntry
    Default = True
    TabOrder = 1
  end
  object btReload: TButton
    Left = 190
    Top = 100
    Width = 154
    Height = 25
    Action = acReloadCurrentEntry
    Cancel = True
    TabOrder = 2
  end
  object alActionList: TActionList
    Left = 268
    Top = 34
    object acSaveCurrentEntry: TAction
      Caption = #196'nderungen speichern'
      ShortCut = 16467
      OnExecute = acSaveCurrentEntryExecute
    end
    object acReloadCurrentEntry: TAction
      Caption = #196'nderungen verwerfen'
      OnExecute = acReloadCurrentEntryExecute
    end
  end
end
