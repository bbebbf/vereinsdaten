unit MessageDialogs;

interface

uses Vcl.Dialogs;

type
  TMessageDialogs = class
  public
    class procedure Ok(const aText: string; const aType: TMsgDlgType);
    class function YesNo(const aText: string; const aType: TMsgDlgType): Integer;
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

class function TMessageDialogs.YesNo(const aText: string; const aType: TMsgDlgType): Integer;
begin
  Result := MessageDlg(aText, aType, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0, TMsgDlgBtn.mbNo);
end;

end.
