unit rtz_cpanel;

interface

uses
  Forms, SysUtils, Windows, Messages,
  ide3050_core_comp, ide3050_core_form, ide3050_core_intf, ide3050_intf,
  idf3050_intf, idf3050_fibp,
  rtz_const;


type
  IrtzActnCPanelOld = interface ['{E1579B7B-27E8-4F29-8CBD-5E6750686D0C}'] end;
  TrtzActnCPanelOld = class(TIDEActn, IrtzActnCPanelOld)
  protected
    procedure EventExecute(Sender: TObject); override;
  end;

  IrtzCompCPanel = interface ['{D296AAE8-F15E-4D76-8D9C-AEAEDC7B589E}'] end;
  TrtzCompCPanel = class(TIDECompCPanel, IrtzCompCPanel)
  protected
    function ActnVisible(Actn: TAction): Boolean; override;
  public
    procedure AfterConstruction; override;
  end;

  IrtzFormCPanel = interface ['{EC9A6414-0210-4B92-90DD-6E7D8C3F0804}'] end;
  TrtzFormCPanel = class(TIDEFormCPanel, IrtzFormCPanel) end;

implementation

{ TMDSActnCPanelOld }

procedure TrtzActnCPanelOld.EventExecute(Sender: TObject);
begin
  IDEDesigner.CreateAndShowComp(IIDECompCPanel, 'SGeneralStart');
end;

{ TMDSCompCPanel }

function TrtzCompCPanel.ActnVisible(Actn: TAction): Boolean;
begin
  Result := True;
end;

procedure TrtzCompCPanel.AfterConstruction;
//var
//  S: string;
begin
  inherited AfterConstruction;
//  S := GetSysNameLocation;
//  if S <> '' then
//    S := S + ' (' + AuthManager.DB.DBUser + ')' + ' - ';
//  S := S + IDEDesigner.FindStr('SAppCaption2');
//  SetApplicationCaption(S);
end;

initialization

  IDEDesigner.RegisterClasses([
    TrtzActnCPanelOld,
    TrtzCompCPanel,
    TrtzFormCPanel
  ], PROTECTION_MODE_FREE);

end.
