unit MessageDialogs;

interface

uses Vcl.Dialogs;

type
  TMessageDialogs = class
  public
    class procedure Ok(const aText: string; const aType: TMsgDlgType);
    class constructor ClassCreate;
  end;

implementation

uses System.UITypes;

{ TMessageDialogs }

class constructor TMessageDialogs.ClassCreate;
begin
  Vcl.Dialogs.MsgDlgIcons[TMsgDlgType.mtInformation] := TMsgDlgIcon.mdiInformation;
end;

class procedure TMessageDialogs.Ok(const aText: string; const aType: TMsgDlgType);
begin
  MessageDlg(aText, aType, [TMsgDlgBtn.mbOK], 0);
end;

end.
