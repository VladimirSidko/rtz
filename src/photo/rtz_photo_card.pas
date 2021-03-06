unit rtz_photo_card;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, DB, ExtCtrls, Jpeg, StdCtrls,
  ide3050_intf,
  idf3050_intf, idf3050_fibp,
  rtz_dev_cntr, rtz_const, rtz_const_sql;

type
  IrtzPhotoCardComp = interface ['{43BFAA1E-1553-46B0-BFA3-63C55890529B}'] end;
  TrtzPhotoCardComp = class(TmdoCompWithParams, IrtzPhotoCardComp)
  private
    function GetID: Int64;
    procedure SetID(Value: Int64);
  protected
    procedure DesignData; override;
  public
    procedure RptParamLst(List: TStrings); override;
    function  RptParamVal(const Name: string): Variant; override;
  published
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
    function ActnVisible(Actn: TAction): Boolean; override;
    function ActnEnabled(Actn: TAction): Boolean; override;
    function ActnExecute(Actn: TAction): Boolean; override;
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
    function ActnVisible(Actn: TAction): Boolean; override;
    function ActnEnabled(Actn: TAction): Boolean; override;
    function ActnExecute(Actn: TAction): Boolean; override;
  end;

  IrtzPhotoCardAction = interface(IIDEActn) ['{5AAB2E51-D843-4F69-B4B0-AA0F05D2347C}'] end;
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
  Caption := Caption + ': ' + DataSet.FieldByName('NUMBER').AsString;

end;

procedure TrtzPhotoCardComp.RptParamLst(List: TStrings);
begin
  inherited RptParamLst(List);
  List.Add('ID=ID');
end;

function TrtzPhotoCardComp.RptParamVal(const Name: string): Variant;
begin
  if Name = 'ID' then
    Result := ID
  else
    Result := inherited RptParamVal(Name);
end;

{ TrtzPhotoPictureForm }

function TrtzPhotoPictureForm.ActnVisible(Actn: TAction): Boolean;
begin
  Result := SupportIID(Actn, IIDFRptPrintProxyActn);
  if not Result then
    Result := inherited ActnVisible(Actn);
end;

function TrtzPhotoPictureForm.ActnEnabled(Actn: TAction): Boolean;
begin
  Result := inherited ActnEnabled(Actn);
end;

function TrtzPhotoPictureForm.ActnExecute(Actn: TAction): Boolean;
begin
  Result := inherited ActnExecute(Actn);
end;

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

function TrtzPhotoCardForm.ActnVisible(Actn: TAction): Boolean;
begin
  Result := SupportIID(Actn, IIDFRptPrintProxyActn);
  if not Result then
    Result := inherited ActnVisible(Actn);
end;

function TrtzPhotoCardForm.ActnEnabled(Actn: TAction): Boolean;
begin
  Result := inherited ActnEnabled(Actn);
end;

function TrtzPhotoCardForm.ActnExecute(Actn: TAction): Boolean;
begin
  Result := inherited ActnExecute(Actn);
end;

procedure TrtzPhotoCardForm.DesignControls;

  function NewGroup(ACaption: string = ''; ADirection: TmdoLayoutDirection = TmdoLayoutDirection.ldHorizontal): TmdoLayoutGroup;
  begin
    Result := FControlPanel.Root.AddGroup;
    Result.LayoutDirection := ADirection;
    Result.ShowBorder  := ACaption <> '';
    Result.ShowCaption := ACaption <> '';
    Result.Caption := ACaption;
  end;

  function NewSubGroup(AParent: TmdoLayoutGroup; ACaption: string = ''; ADirection: TmdoLayoutDirection = TmdoLayoutDirection.ldHorizontal): TmdoLayoutGroup;
  begin
    Result := AParent.AddGroup;
    Result.LayoutDirection := ADirection;
    Result.ShowBorder  := ACaption <> '';
    Result.ShowCaption := ACaption <> '';
    Result.Caption := ACaption;
  end;

  procedure CreateParamControl(AClass: TControlClass; AGroup: TmdoLayoutGroup; ACaption: string; AFieldName: string; AWidth: Integer; ACaptionWidth: Integer = 0);
  var
    Control: TControl;
    LayItem: TmdoLayoutItem;
  begin
    Control := AClass.Create(Self);
    SetControlDataBindingProps(Control, DataSource, AFieldName);
    Control.Width := AWidth;
    LayItem := AGroup.AddControl(Control, alLeft);
    LayItem.Caption := ACaption;
    if ACaptionWidth = 0 then
      LayItem.CaptionOptions.Width := Canvas.TextWidth(ACaption) + 4
    else
      LayItem.CaptionOptions.Width := ACaptionWidth;
    LayItem.CaptionOptions.AlignHorz := taLeftJustify;
  end;

  function GetCaptionWidth(ACaption: string): Integer;
  begin
    Result := Canvas.TextWidth(ACaption) + 4;
  end;

var
  Group, SubGroup, SubGroup2: TmdoLayoutGroup;
  CaptionWidth: Integer;
begin
  inherited DesignControls;
  //
  FControlPanel := TmdoLayoutControl.Create(Self);
  FControlPanel.Align := alClient;
  FControlPanel.Root.LayoutDirection := TmdoLayoutDirection.ldVertical;
  FControlPanel.OptionsItem.AutoControlAreaAlignment := False;
  //
  Group := NewGroup('', TmdoLayoutDirection.ldHorizontal);
  //
  SubGroup := NewSubGroup(Group, '  ', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('���������');
  //
  SubGroup2 := NewSubGroup(SubGroup, '', TmdoLayoutDirection.ldHorizontal);
  CreateParamControl(TmdoDBStringEdit, SubGroup2, '�����',     'NUMBER',         120, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup2, '����',      'DECISION_DATE',  120, 50);
  //
  SubGroup2 := NewSubGroup(SubGroup, '', TmdoLayoutDirection.ldVertical);
  CreateParamControl(TmdoDBStringEdit, SubGroup2, '���',       'OVS_NAME',       300, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup2, '���������', 'INSPECTOR_NAME', 300, CaptionWidth);
  //
  SubGroup := NewSubGroup(Group, '����������� ��������� ����', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('����������� ������ ����� ��');
  //
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�����', 'DEVICE_NAME', 100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�����', 'DEVICE_NO',   100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '����������� ������ ����� ��', 'DEVICE_VALID_DATE', 100, CaptionWidth);
  //
  Group := NewGroup('', TmdoLayoutDirection.ldHorizontal);
  Group := NewSubGroup(Group, '������ ��������������', TmdoLayoutDirection.ldHorizontal);
  //
  SubGroup := NewSubGroup(Group, '', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('������');
  //
  CreateParamControl(TmdoDBStringEdit, SubGroup, '���',    'DNZ_NUMBER', 100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�����',  'MARK',       100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������', 'MODEL',      100, CaptionWidth);
  //
  SubGroup := NewSubGroup(Group, '', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('�� �����.');
  //
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�������',  'LAST_NAME',   100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '��''�',     'FIRST_NAME',  100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�� �����.', 'MIDDLE_NAME', 100, CaptionWidth);
  //
  SubGroup := NewSubGroup(Group, '', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('̳��� ���.');
  //
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�������',    'PASS_NO',     100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '���� ���.',  'BIRTHDAY',    100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '̳��� ���.', 'BIRTH_PLACE', 100, CaptionWidth);
  //
  SubGroup := NewSubGroup(Group, '', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('������');
  //
  CreateParamControl(TmdoDBStringEdit, SubGroup, '̳���',  'REGION_NAME', 127, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������', 'STREET_NAME', 127, CaptionWidth);
  SubGroup2 := NewSubGroup(SubGroup, '', TmdoLayoutDirection.ldHorizontal);
  CreateParamControl(TmdoDBStringEdit, SubGroup2, '���.',   'HOUSE_NO',    50, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup2, '��.',    'FLAT_NO',     50, 17);
  //
  Group := NewGroup('', TmdoLayoutDirection.ldHorizontal);
  Group := NewSubGroup(Group, '���������', TmdoLayoutDirection.ldHorizontal);
  //
  SubGroup := NewSubGroup(Group, '', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('������');
  //
  CreateParamControl(TmdoDBStringEdit, SubGroup, '����',   'VIOLATION_DATE',  100, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������', 'VIOLATION_PLACE', 100, CaptionWidth);
  //
  SubGroup := NewSubGroup(Group, '', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('�������� ����');
  //
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�������� ����', 'TRAFFIC_SIGN', 254, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '����� ���',     'ROADRULE_NO',  254, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '������',        'ARTICLE_NO',   254, CaptionWidth);
  //
  SubGroup := NewSubGroup(Group, '', TmdoLayoutDirection.ldVertical);
  CaptionWidth := GetCaptionWidth('��������� ��������');
  //
  CreateParamControl(TmdoDBStringEdit, SubGroup, '��������� ��������', 'LIMIT_SPEED',  40, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '��������',           'ACTUAL_SPEED', 40, CaptionWidth);
  CreateParamControl(TmdoDBStringEdit, SubGroup, '�����',               'PENALTY',      40, CaptionWidth);
  //
  Group := NewGroup('', TmdoLayoutDirection.ldHorizontal);
  Group := NewSubGroup(Group, '�������� �������', TmdoLayoutDirection.ldHorizontal);
  //
  CreateParamControl(TmdoDBStringEdit, Group, '���������', 'RECIPIENT_NAME', 188, 0);
  CreateParamControl(TmdoDBStringEdit, Group, '���',       'RECIPIENT_OKPO', 100, 0);
  CreateParamControl(TmdoDBStringEdit, Group, '�/�',       'BANK_ACCOUNT',   100, 0);
  CreateParamControl(TmdoDBStringEdit, Group, '���',       'BANK_MFO',       100, 0);
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
