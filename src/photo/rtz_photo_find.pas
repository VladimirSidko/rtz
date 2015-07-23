unit rtz_photo_find;

interface

uses
  Windows, Controls, Classes, DB, SysUtils, ExtDlgs, Forms, ComCtrls, Graphics, CommCtrl, ExtCtrls,
  ide3050_intf, ide3050_core_level3,
  idf3050_fibp,
  rtz_dev_cntr, rtz_const, rtz_const_sql;

type
  IrtzPhotoFindComp = interface ['{832F7044-830E-4BB9-AF5D-339F14839566}'] end;
  TrtzPhotoFindComp = class(TmdoComp, IrtzPhotoFindComp)
  private
    FParamSet: TDataSet;
    FFindSet: TDataSet;
  protected
    procedure DesignData; override;
  public
    procedure AfterConstruction; override;
    property ParamSet: TDataSet read FParamSet;
    property FindSet: TDataSet read FFindSet;
  end;

  IrtzPhotoFindForm = interface ['{FA23F31F-01F6-401A-A3A1-5318D856BCA3}'] end;
  TrtzPhotoFindForm = class(TmdoFormWithGridAndParamPanel, IrtzPhotoFindForm)
  protected
    procedure DesignControls; override;
  end;

  IrtzPhotoFindAction = interface(IIDEActn) ['{A3D232BD-5DFA-4FBE-9796-EF792C3FF238}'] end;
  TrtzPhotoFindAction = class(TmdoActnCPanelGeneric<TrtzPhotoFindComp>, IrtzPhotoFindAction) end;

implementation

{ TrtzPhotoFindComp }

procedure TrtzPhotoFindComp.AfterConstruction;
begin
  inherited AfterConstruction;
  FParamSet.Open;
end;

procedure TrtzPhotoFindComp.DesignData;
begin
  inherited DesignData;
  FParamSet := Data.AddDataSet('rtzApParamSet', [sql_ap_photo_find_param_get, '', '', sql_mdo_empty_select, '']);
  FFindSet := Data.AddDataSet('rtzApFindSet', [sql_ap_photo_find_get, sql_ap_photo_find_get_row, '', '', ''], 'rtzApParamSet');
end;

{ TrtzPhotoFindForm }

procedure TrtzPhotoFindForm.DesignControls;
begin
  inherited DesignControls;

end;

initialization

  IDEDesigner.RegisterClasses([
    TrtzPhotoFindComp,
    TrtzPhotoFindForm,
    TrtzPhotoFindAction
  ], PROTECTION_MODE_FREE);

end.
