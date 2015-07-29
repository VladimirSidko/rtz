unit rtz_photo_find;

interface

uses
  Windows, Controls, Classes, DB, SysUtils, ExtDlgs, Forms, ComCtrls, Graphics,
  CommCtrl, ExtCtrls, TypInfo, StrUtils, Variants,
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
    procedure DesignGrid;
    procedure FindClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
  protected
    procedure DesignControls; override;
    function ImmediatlyOpen: Boolean; override;
    function ActnVisible(Actn: TAction): Boolean; override;
    function ActnEnabled(Actn: TAction): Boolean; override;
    function ActnExecute(Actn: TAction): Boolean; override;
  end;

  IrtzPhotoFindAction = interface(IIDEActn) ['{A3D232BD-5DFA-4FBE-9796-EF792C3FF238}'] end;
  TrtzPhotoFindAction = class(TmdoActnCPanelGeneric<TrtzPhotoFindComp>, IrtzPhotoFindAction) end;

  IrtzPhotoSearchAction = interface(IIDEActn) ['{9EC1B569-E689-428E-9671-9B49D51EFD0A}'] end;
  TrtzPhotoSearchAction = class(TIDEActn, IrtzPhotoSearchAction) end;
  IrtzPhotoClearAction = interface(IIDEActn) ['{25A87AEA-9385-48A5-BEFF-785E7E674416}'] end;
  TrtzPhotoClearAction = class(TIDEActn, IrtzPhotoClearAction) end;

implementation

{ TrtzPhotoFindComp }

procedure TrtzPhotoFindComp.AfterConstruction;
begin
  inherited AfterConstruction;
end;

procedure TrtzPhotoFindComp.DesignData;
begin
  ParamSet := Data.AddDataSet('rtzApParamSet', [sql_ap_photo_find_param_get, '', '', sql_mdo_empty_select, '']);
  DataSet  := Data.AddDataSet('rtzApFindSet', [sql_ap_photo_find_get, sql_ap_photo_find_get_row, '', '', ''], 'rtzApParamSet');
end;

{ TrtzPhotoFindForm }

function TrtzPhotoFindForm.ActnVisible(Actn: TAction): Boolean;
begin
  Result := True;
end;

function TrtzPhotoFindForm.ActnEnabled(Actn: TAction): Boolean;
begin
  Result := True;
end;

function TrtzPhotoFindForm.ActnExecute(Actn: TAction): Boolean;
begin
  Result := True;
  if SupportIID(Actn, IrtzPhotoSearchAction) then
    FindClick(Actn)
  else
  if SupportIID(Actn, IrtzPhotoClearAction) then
    ClearClick(Actn)
  else
    Result := inherited ActnExecute(Actn);
end;

procedure TrtzPhotoFindForm.ClearClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to ParamPanel.ControlList.Count - 1 do
    if ParamPanel.ControlList.Items[I] is TmdoDBDateEdit then
      TmdoDBDateEdit(ParamPanel.ControlList.Items[I]).DataBinding.Field.AsVariant := NULL
    else
    if ParamPanel.ControlList.Items[I] is TmdoDBStringEdit then
      TmdoDBStringEdit(ParamPanel.ControlList.Items[I]).DataBinding.Field.AsString := '';
end;

procedure TrtzPhotoFindForm.DesignControls;
begin
  inherited DesignControls;
  DesignParamPanel;
  DesignGrid;
end;

procedure TrtzPhotoFindForm.DesignGrid;
var
  ColumnInfos: TmdoDBGridColumnInfoList;
begin
  ColumnInfos := TmdoDBGridColumnInfoList.Create;
  try
    ColumnInfos.KeyField := 'PHOTO_DECISION_ID';
    ColumnInfos.DataSource := DataSource;
    ColumnInfos.AddNew('DECISION_DATE',   'Дата постанови',   100);
    ColumnInfos.AddNew('INSPECTOR_NAME',  'Інспектор',        200);
    ColumnInfos.AddNew('OVS_NAME',        'ОВС',              200);
    ColumnInfos.AddNew('VIOLATION_DATE',  'Дата порушення',   100);
    ColumnInfos.AddNew('VIOLATION_PLACE', 'Адреса порушення', 200);
    ColumnInfos.AddNew('MARK',            'Марка',            200);
    ColumnInfos.AddNew('MODEL',           'Модель',           200);
    ColumnInfos.AddNew('DNZ_NUMBER',      'ДНЗ',              075);
    ColumnInfos.AddNew('VIOLATOR',        'Власник',          200);
    ColumnInfos.AddNew('ACTUAL_SPEED',    'Швидкість руху',   100);
    ColumnInfos.AddNew('LIMIT_SPEED',     'Обмеження швидкості',100);
    Grid.DesignView(ColumnInfos);
  finally
    FreeAndNil(ColumnInfos);
  end;
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

   ParamPanel.AddButton(FindClick).Caption := 'Пошук';

end;

procedure TrtzPhotoFindForm.FindClick(Sender: TObject);
begin
  ParamPanel.PostEditValue;
  DataSet.Close;
  DataSet.Open;
end;

function TrtzPhotoFindForm.ImmediatlyOpen: Boolean;
begin
  Result := False;
end;

initialization

  IDEDesigner.RegisterClasses([
    TrtzPhotoFindComp,
    TrtzPhotoFindForm,
    TrtzPhotoFindAction,
    TrtzPhotoSearchAction,
    TrtzPhotoClearAction
  ], PROTECTION_MODE_FREE);

end.
