unit rtz_connect;

interface

uses
  ide3050_intf,
  idf3050_fibp,
  rtz_const;

type
  IrtzCompLogin = interface ['{C7E67918-80F6-4953-AE4F-728B64617752}'] end;
  TrtzCompLogin = class(TIDEComp, IrtzCompLogin)
  public
    procedure AfterConstruction; override;
  end;

  IrtzFormLogin = interface ['{2E2FB2CD-1BF9-46C7-A842-C98C7BFE54C4}'] end;
  TrtzFormLogin = class(TIDEForm, IrtzFormLogin)
  public
    procedure AfterConstruction; override;
    procedure StayForeground; override;
  end;

function DBConnect(ADB_IID: TGUID): Boolean;

implementation

function PromtLogin(var AUserName, APassword: string): boolean;
begin
  AUserName := 'SYSDBA';
  APassword := 'masterkey';
  Result := True;
end;

function _DBConnect(ADB_IID: TGUID): Boolean;
begin
  IDEDesigner.ShowMessage('', 'No connection.');
  Result := False;
end;

function DBConnect(ADB_IID: TGUID): Boolean;
var
  DB: TIDFDatabase;
  UserName,
  Password: string;
begin
  Result := False;
  try
    DB := DBList[ADB_IID];
    if not Assigned(DB) then
    begin
      DBList.RegisterDB(ADB_IID);
      DB := DBList[ADB_IID];
    end;

    Assert(Assigned(DB));

    Result := DB.Connected;
    if not Result then
      if PromtLogin(UserName, Password) then
      begin
        DB.DBUser := UserName;
        DB.DBPass := Password;
        Result := DBList.OpenDB(ADB_IID);
      end;

    IDEDesigner.IsAuthorized := Result;
  except
    Result := False;
  end;
end;

{ TrtzCompLogin }

procedure TrtzCompLogin.AfterConstruction;
begin
  inherited AfterConstruction;
end;

{ TrtzFormLogin }

procedure TrtzFormLogin.AfterConstruction;
begin
  inherited AfterConstruction;
end;

procedure TrtzFormLogin.StayForeground;
var
  LoginComp: TIDEComp;
begin
  inherited StayForeground;
  if DBConnect(MDO_DB_IID) then
  begin
    LoginComp := IDEDesigner.ActiveComp;
    if IDEDesigner.CreateAndShowComp(StrToIID('{D296AAE8-F15E-4D76-8D9C-AEAEDC7B589E}')) then
      IDEDesigner.HideComp(LoginComp);
  end else
    IDEDesigner.Close(False);
end;

initialization
  IDEDesigner.RegisterClasses([
    TrtzCompLogin,
    TrtzFormLogin
  ], PROTECTION_MODE_FREE);


end.
