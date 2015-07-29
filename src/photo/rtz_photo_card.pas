unit rtz_photo_card;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, DB, ExtCtrls, Jpeg, StdCtrls,
  ide3050_intf, ide3050_core_level3,
  idf3050_fibp,
  rtz_dev_cntr, rtz_const, rtz_const_sql;

type
  IrtzPhotoCardComp = interface ['{43BFAA1E-1553-46B0-BFA3-63C55890529B}'] end;
  TrtzPhotoCardComp = class(TmdoCompWithParams, IrtzPhotoCardComp)
  private
    function GetID: Int64;
    procedure SetID(Value: Int64);
  protected
    procedure DesignData; override;
    property ID: Int64 read GetID write SetID;
  end;

  IrtzPhotoCardForm = interface ['{792D1B47-02FF-4420-AE49-07363B683935}'] end;
  TrtzPhotoCardForm = class(TmdoForm, IrtzPhotoCardForm)
  private
    FControlPanel: TmdoLayoutControl;
    function GetDataSource: TDataSource;
  protected
    procedure DesignData; override;
    procedure DesignControls; override;
  public
    property DataSource: TDataSource read GetDataSource;
    property ControlPanel: TmdoLayoutControl read FControlPanel;
  end;

  IrtzPhotoPictureForm = interface ['{24B680AB-D773-4F5C-936F-F372BEA8BF08}'] end;
  TrtzPhotoPictureForm = class(TmdoForm, IrtzPhotoPictureForm)
  private
    FPicture: TmdoDBImage;
  protected
    procedure DesignControls; override;
  end;

  IrtzPhotoCardAction = interface(IIDEActn) ['{5AAB2E51-D843-4F69-B4B0-AA0F05D2347C}']end;
  TrtzPhotoCardAction = class(TmdoActnCPanelGeneric<TrtzPhotoCardComp>, IrtzPhotoCardAction) end;

implementation

//{$R *.dfm}

{ TrtzPhotoCardComp }

procedure TrtzPhotoCardComp.DesignData;
begin
  ParamSet := Data.AddDataSet('rtzApCardParamSet', [sql_ap_photo_decision_params, '', '', sql_mdo_empty_select, '']);
  DataSet  := Data.AddDataSet('rtzApCardSet', [sql_ap_photo_decision_get, sql_ap_photo_decision_get, '', '', ''], 'rtzApCardParamSet');
end;

function TrtzPhotoCardComp.GetID: Int64;
begin
  Result := ParamSet.FieldByName('ID').AsLargeInt;
end;

procedure TrtzPhotoCardComp.SetID(Value: Int64);
begin
  DataSet.Close;
  if not (ParamSet.State in dsWriteModes) then
    ParamSet.Edit;
  ParamSet.FieldByName('ID').AsVariant := Value;
  DataSet.Open;
end;

{ TrtzPhotoPictureForm }

procedure TrtzPhotoPictureForm.DesignControls;
begin
  inherited DesignControls;
  FPicture := TmdoDBImage.Create(Self);
  FPicture.Parent := Self;
  FPicture.Align := alClient;
  FPicture.Properties.Center       := True;
  FPicture.Properties.Proportional := True;
  FPicture.Properties.ReadOnly     := True;
  FPicture.Properties.Stretch      := True;
  FPicture.Properties.GraphicClass := TJPEGImage;
  SetObjectLookAndFeel(FPicture);
  if Assigned(Comp) then
  begin
    FPicture.DataBinding.DataField  := 'PHOTO';
    FPicture.DataBinding.DataSource := Comp.DataSource;
  end;
end;

{ TrtzPhotoCardForm }

procedure TrtzPhotoCardForm.DesignControls;

  function NewGroup(ACaption: string = ''): TmdoLayoutGroup;
  var
    ControlPanel: TmdoLayoutControl;
  begin
//    ControlPanel := TmdoLayoutControl.Create(Self);
//    ControlPanel.Align := alTop;
//    ControlPanel.Root.LayoutDirection := TmdoLayoutDirection.ldVertical;
//    ControlPanel.Top := MaxInt;
    Result := FControlPanel.Root.AddGroup;
    Result.LayoutDirection := TmdoLayoutDirection.ldHorizontal;
    Result.Caption := ACaption;
  end;

  function NewSubGroup(AParent: TmdoLayoutGroup): TmdoLayoutGroup;
  begin
    AParent.LayoutDirection := TmdoLayoutDirection.ldVertical;
    Result := AParent.AddGroup;
    Result.LayoutDirection := TmdoLayoutDirection.ldHorizontal;
    Result.ShowBorder  := False;
    Result.ShowCaption := False;
  end;

  procedure CreateParamControl(AClass: TControlClass; AGroup: TmdoLayoutGroup; ACaption: string; AFieldName: string; AWidth: Integer);
  var
    Control: TControl;
    LayItem: TmdoLayoutItem;
  begin
    Control := AClass.Create(Self);
    SetControlDataBindingProps(Control, DataSource, AFieldName);
    Control.Width := AWidth;
    LayItem := AGroup.AddControl(Control, alLeft);
    LayItem.Caption := ACaption;
    LayItem.CaptionOptions.Width := Canvas.TextWidth(ACaption) + 4;
    LayItem.CaptionOptions.AlignHorz := taLeftJustify;
  end;

var
  Group, SubGroup: TmdoLayoutGroup;
begin
  inherited DesignControls;

  FControlPanel := TmdoLayoutControl.Create(Self);
  FControlPanel.Align := alClient;
  FControlPanel.Root.LayoutDirection := TmdoLayoutDirection.ldVertical;
//  FControlPanel.OptionsItem.AutoControlAreaAlignment := False;
  FControlPanel.OptionsItem.ShowLockedGroupChildren := False;

  //
  Group := NewGroup;
  CreateParamControl(TmdoDBStringEdit, Group, '���',       'OVS_NAME',       300);
  CreateParamControl(TmdoDBStringEdit, Group, '���������', 'INSPECTOR_NAME', 100);
  CreateParamControl(TmdoDBStringEdit, Group, '����',      'DECISION_DATE',  100);
  //
  Group := NewGroup('����������� �������� ����');
  CreateParamControl(TmdoDBStringEdit, Group, '�����', 'DEVICE_NAME', 100);
  CreateParamControl(TmdoDBStringEdit, Group, '�����', 'DEVICE_NO',   100);
  CreateParamControl(TmdoDBStringEdit, Group, '����������� ������ ����� ��', 'DEVICE_VALID_DATE', 100);
  //
  Group := NewGroup('������ ��������������');
  //
  SubGroup := NewSubGroup(Group);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '���',    'DNZ_NUMBER', 100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�����',  'MARK',       100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������', 'MODEL',      100);
  //
  SubGroup := NewSubGroup(Group);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�������',  'LAST_NAME',   100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '��''�',     'FIRST_NAME',  100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�� �����.', 'MIDDLE_NAME', 100);
  //
  SubGroup := NewSubGroup(Group);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�������',    'PASS_NO',     100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '���� ���.',  'BIRTHDAY',    100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '̳��� ���.', 'BIRTH_PLACE', 100);
  //
  SubGroup := NewSubGroup(Group);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '̳���',  'REGION_NAME', 100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������', 'STREET_NAME', 100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '���.',   'HOUSE_NO',    100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '��.',    'FLAT_NO',     100);
  //
  Group := NewGroup('���������');
  //
  SubGroup := NewSubGroup(Group);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '����',   'VIOLATION_DATE',  100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������', 'VIOLATION_PLACE', 100);
  //
  SubGroup := NewSubGroup(Group);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������� ����', 'TRAFFIC_SIGN', 100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '����� ���',     'ROADRULE_NO',  100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������',        'ARTICLE_NO',   100);
  //
  SubGroup := NewSubGroup(Group);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '��������� ��������', 'LIMIT_SPEED',  100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '��������',           'ACTUAL_SPEED', 100);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�����',               'PENALTY',      100);
  //
  Group := NewGroup('�������� �������');
  CreateParamControl(TmdoDBStringEdit, Group, '���������', 'RECIPIENT_NAME', 100);
  CreateParamControl(TmdoDBStringEdit, Group, '���',       'RECIPIENT_OKPO', 100);
  CreateParamControl(TmdoDBStringEdit, Group, '�/�',       'BANK_ACCOUNT',   100);
  CreateParamControl(TmdoDBStringEdit, Group, '���',       'BANK_MFO',       100);
  //
end;

procedure TrtzPhotoCardForm.DesignData;
begin
  if not DataSet.Active then
   DataSet.Open;
end;

function TrtzPhotoCardForm.GetDataSource: TDataSource;
begin
  Result := nil;
  if Assigned(Comp) then
    Result := Comp.DataSource;
end;

initialization

  IDEDesigner.RegisterClasses([
    TrtzPhotoCardAction,
    TrtzPhotoCardComp,
    TrtzPhotoCardForm,
    TrtzPhotoPictureForm
  ], PROTECTION_MODE_FREE);

end.
