unit rtz_photo_find;

interface

uses
  Windows, Controls, Classes, DB, SysUtils, ExtDlgs, Forms, ComCtrls, Graphics, CommCtrl, ExtCtrls, TypInfo, StrUtils,
  ide3050_intf, ide3050_core_level3,
  idf3050_fibp,
  rtz_dev_cntr, rtz_const, rtz_const_sql;

type
  IrtzPhotoFindComp = interface ['{832F7044-830E-4BB9-AF5D-339F14839566}'] end;
  TrtzPhotoFindComp = class(TmdoCompWithParams, IrtzPhotoFindComp)
  protected
    procedure DesignData; override;
  public
    procedure AfterConstruction; override;
  end;

  IrtzPhotoFindForm = interface ['{FA23F31F-01F6-401A-A3A1-5318D856BCA3}'] end;
  TrtzPhotoFindForm = class(TmdoFormWithGridAndParamPanel, IrtzPhotoFindForm)
  private
    procedure DesignParamPanel;
    procedure FindClick(Sender: TObject);
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
  ParamSet.Open;
end;

procedure TrtzPhotoFindComp.DesignData;
begin
  ParamSet := Data.AddDataSet('rtzApParamSet', [sql_ap_photo_find_param_get, '', '', sql_mdo_empty_select, '']);
  DataSet  := Data.AddDataSet('rtzApFindSet', [sql_ap_photo_find_get, sql_ap_photo_find_get_row, '', '', ''], 'rtzApParamSet');
end;

{ TrtzPhotoFindForm }

procedure TrtzPhotoFindForm.DesignControls;
begin
  inherited DesignControls;
  DesignParamPanel;
end;

procedure TrtzPhotoFindForm.DesignParamPanel;

  procedure CreateParamControl(AClass: TControlClass; AGroup: TmdoLayoutGroup; ACaption: string; AFieldName: string; AWidth: Integer; ACalcCaptiomWidth: Boolean);
  var
    Control: TControl;
    LayItem: TmdoLayoutItem;
  begin
    AGroup.ShowBorder := False;
    Control := AClass.Create(Self);
    if Control is TmdoDBStringEdit then
      TmdoDBStringEdit(Control).UpperCase := True;
    SetControlDataBindingProps(Control, ParamSource, AFieldName);
    Control.Width := AWidth;
    LayItem := AGroup.AddControl(Control, alTop);
    LayItem.Caption := ACaption;
    LayItem.CaptionOptions.AlignHorz := taRightJustify;
    if ACalcCaptiomWidth then
    begin
      LayItem.CaptionOptions.Width := Canvas.TextWidth(ACaption) + 4;
//      LayItem.CaptionOptions.Width := Canvas.TextWidth(DupeString('Z', Length(ACaption))) + 5;
    end;
    ParamPanel.ControlList.Add(Control);
  end;

var
  Group: TmdoLayoutGroup;
begin
  ParamPanel.Root.LayoutDirection := TmdoLayoutDirection.ldHorizontal;

  Group := ParamPanel.Root.AddGroup;
  CreateParamControl(TmdoDBDateEdit,   Group, 'Дата поруш з', 'VIOLATION_DATE_FROM', 80, True);
  CreateParamControl(TmdoDBDateEdit,   Group,           'по', 'VIOLATION_DATE_TO',   80, False);

  Group := ParamPanel.Root.AddGroup;
  CreateParamControl(TmdoDBDateEdit,   Group, 'Дата занес з', 'DECISION_DATE_FROM', 80, True);
  CreateParamControl(TmdoDBDateEdit,   Group,           'по', 'DECISION_DATE_TO',   80, False);

  Group := ParamPanel.Root.AddGroup;
  CreateParamControl(TmdoDBStringEdit, Group, 'ДНЗ', 'DNZ_NUMBER', 70, True);

  Group := ParamPanel.Root.AddGroup;
  CreateParamControl(TmdoDBStringEdit, Group, 'Прізвище',    'LAST_NAME',   100, False);
  CreateParamControl(TmdoDBStringEdit, Group, 'Ім''я',       'FIRST_NAME',  100, False);
  CreateParamControl(TmdoDBStringEdit, Group, 'По батькові', 'MIDDLE_NAME', 100, True);

  ParamPanel.AddButton(FindClick);

end;

procedure TrtzPhotoFindForm.FindClick(Sender: TObject);
begin
  ParamPanel.PostEditValue;
end;

initialization

  IDEDesigner.RegisterClasses([
    TrtzPhotoFindComp,
    TrtzPhotoFindForm,
    TrtzPhotoFindAction
  ], PROTECTION_MODE_FREE);

end.
