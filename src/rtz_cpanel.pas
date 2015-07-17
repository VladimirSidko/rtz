unit rtz_cpanel;

interface

uses
  Forms, SysUtils, Windows, Messages,
  ide3050_core_comp, ide3050_core_form, ide3050_core_intf, ide3050_intf,
  ide3050_core_actn, ide3050_core_level3,
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
    function CanDestroy(CheckForClose: Boolean = False): Boolean; override;
  end;

  IrtzFormCPanel = interface ['{EC9A6414-0210-4B92-90DD-6E7D8C3F0804}'] end;
  TrtzFormCPanel = class(TIDEFormCPanel, IrtzFormCPanel)
  protected
    function ActnVisible(Actn: TAction): Boolean; override;
    function ActnEnabled(Actn: TAction): Boolean; override;
    function ActnExecute(Actn: TAction): Boolean; override;
  public
    procedure AfterConstruction; override;
  end;

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
begin
  inherited AfterConstruction;
end;

function TrtzCompCPanel.CanDestroy(CheckForClose: Boolean): Boolean;
begin
  Result := not CheckForClose;
end;

{ TrtzFormCPanel }

function TrtzFormCPanel.ActnEnabled(Actn: TAction): Boolean;
begin
  Result := inherited ActnEnabled(Actn);
end;

function TrtzFormCPanel.ActnExecute(Actn: TAction): Boolean;
begin
  Result := inherited ActnExecute(Actn);
end;

function TrtzFormCPanel.ActnVisible(Actn: TAction): Boolean;
begin
  Result := inherited ActnVisible(Actn);
end;

procedure TrtzFormCPanel.AfterConstruction;
begin
  inherited AfterConstruction;
  if Self.Parent is TIDELevel3 then
  begin
    TIDELevel3(Self.Parent).TBLeft.Parent.Visible := False;
    TIDELevel3(Self.Parent).TBLeft.Items.Clear;
    TIDELevel3(Self.Parent).TBRight.Items.Clear;
  end;
end;

initialization

  IDEDesigner.Caption := 'À²Ñ "ÄÀ²"';

  IDEDesigner.RegisterClasses([
    TrtzActnCPanelOld,
    TrtzCompCPanel,
    TrtzFormCPanel
  ], PROTECTION_MODE_FREE);

end.
