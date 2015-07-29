unit rtz_photo_folder;

interface

uses
  Windows, Controls, Classes, DB, SysUtils, ExtDlgs, Forms, ComCtrls, Graphics, CommCtrl, ExtCtrls,
  ide3050_intf,
  idf3050_fibp,
  rtz_dev_cntr, rtz_const, rtz_const_sql, rtz_photo_card;

type
  TrtzPhotoLoadThread = class;

  IrtzPhotoFolderComp = interface ['{89DDD507-3753-4893-95DA-793DC715924D}'] end;
  TrtzPhotoFolderComp = class(TmdoComp, IrtzPhotoFolderComp)
  private
    FFolderSet: TDataSet;
  protected
    procedure DesignData; override;
  public
    procedure AfterConstruction; override;
    property FolderSet: TDataSet read FFolderSet;
  end;

  TrtzListItem = class(TListItem)
  private
    FFileName: string;
    FDateTime: TDateTime;
    procedure SetFileName(AValue: string);
  public
    property FileName: string read FFileName write SetFileName;
    property DateTime: TDateTime read FDateTime write FDateTime;
  end;

  TrtzImageSlider = class(TmdoImageSlider);

  TrtzListView = class(TmdoListView)
  private
    function AddImageToList(AFileName: string): Integer;
    procedure DoOnCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
  public
    procedure AfterConstruction; override;
    procedure AddImage(AFileName: string; ADateTime: TDateTime);
    procedure SetListItemSelected(AItem: TListItem);
  end;

  IrtzPhotoFolderForm = interface ['{48FBCBDB-6C67-4A11-AE1E-9B8B121FCE21}'] end;
  TrtzPhotoFolderForm = class(TmdoForm, IrtzPhotoFolderForm)
  private
    FParamPanel: TmdoParamPanel;
    edFolder:      TmdoDBStringEdit;
    edAdress:      TmdoDBStringEdit;
    edOVSName:     TmdoDBStringEdit;
    edUserName:    TmdoDBStringEdit;
    edVisirName:   TmdoDBStringEdit;
    edVisirDate:   TmdoDBStringEdit;
    edDNZNumber:   TmdoDBStringEdit;
    edActualSpeed: TmdoDBStringEdit;
    edLimitSpeed:  TmdoDBStringEdit;
    edPenalty:     TmdoDBStringEdit;
    ListView: TrtzListView;
    Slider:   TrtzImageSlider;
    FThread: TrtzPhotoLoadThread;
    function GetFolderSet: TDataSet;
    function GetFolderSrc: TDataSource;
    function ExecOpenFolder: Boolean;
    function ExecUpdateData: Boolean;
    function ExecCreateCard: Boolean;
    function LoadPhotos: Boolean;
    procedure StopThread;
    procedure ClearImages;
    procedure ListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure SliderChange(Sender: TObject);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OpenDocument(AID: Int64);
  protected
    procedure DesignControls; override;
    function ActnVisible(Actn: TAction): Boolean; override;
    function ActnEnabled(Actn: TAction): Boolean; override;
    function ActnExecute(Actn: TAction): Boolean; override;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure AddImage(AFileName: string; ADateTime: TDateTime);

    property FolderSet: TDataSet read GetFolderSet;
    property FolderSrc: TDataSource read GetFolderSrc;
  end;

  TrtzPhotoLoadThread = class(TThread)
  private
    FWorking: Boolean;
    FForm: TrtzPhotoFolderForm;
    FPath: string;
    FFileName: string;
    FDateTime: TDateTime;
    procedure AddImage;
  protected
    procedure Execute; override;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    property Working: Boolean read FWorking;
    property Form: TrtzPhotoFolderForm write FForm;
    property Path: string write FPath;
  end;

  IrtzPhotoFolderAction = interface(IIDEActn) ['{A1B768D6-6AC9-4591-9E79-B7631D2CBAD4}'] end;
  TrtzPhotoFolderAction = class(TmdoActnCPanelGeneric<TrtzPhotoFolderComp>, IrtzPhotoFolderAction) end;

  IrtzPhotoOpenFolderAction = interface(IIDEActn) ['{0A3A7DCB-4D0D-4E49-9DAA-64D54F3BAE6C}'] end;
  TrtzPhotoOpenFolderAction = class(TIDEActn, IrtzPhotoOpenFolderAction) end;

  IrtzPhotoUpdateDataAction = interface(IIDEActn) ['{4F4A3118-F3AD-428E-9E0F-69EC7E160E42}'] end;
  TrtzPhotoUpdateDataAction = class(TIDEActn, IrtzPhotoUpdateDataAction) end;

  IrtzPhotoCreateCardAction = interface(IIDEActn) ['{60CE0D07-2506-46BB-B92B-8A185CDAABCF}'] end;
  TrtzPhotoCreateCardAction = class(TIDEActn, IrtzPhotoCreateCardAction) end;


implementation

function FileTimeToDateTime(FileTime: TFileTime): TDateTime;
var
  ModifiedTime: TFileTime;
  SystemTime: TSystemTime;
begin
  Result := 0;
  if (FileTime.dwLowDateTime = 0) and (FileTime.dwHighDateTime = 0) then
    Exit;
  try
    FileTimeToLocalFileTime(FileTime, ModifiedTime);
    FileTimeToSystemTime(ModifiedTime, SystemTime);
    Result := SystemTimeToDateTime(SystemTime);
  except
    Result := Now;  // Something to return in case of error
  end;
end;

{ TrtzPhotoFolderComp }

procedure TrtzPhotoFolderComp.AfterConstruction;
begin
  inherited AfterConstruction;
  FFolderSet.Open;
end;

procedure TrtzPhotoFolderComp.DesignData;
begin
  inherited DesignData;
  FFolderSet := Data.AddDataSet('FolderSet', [sql_ap_photo_folder_get, sql_ap_photo_folder_get, '', sql_ap_photo_folder_upd, '']);
end;

{ TrtzPhotoFolderForm }

procedure TrtzPhotoFolderForm.AfterConstruction;
begin
  inherited AfterConstruction;
  FThread := TrtzPhotoLoadThread.Create(True);
  if FolderSet.FieldByName('FOLDER').AsString <> '' then
    LoadPhotos;
end;

procedure TrtzPhotoFolderForm.BeforeDestruction;
begin
  StopThread;
  FreeAndNil(FThread);
  inherited BeforeDestruction;
end;

procedure TrtzPhotoFolderForm.DesignControls;

  function CreateStringEdit(AFieldName: string; AWidth: Integer; AReadOnly: Boolean = True): TmdoDBStringEdit;
  begin
    Result := TmdoDBStringEdit.Create(Self);
    Result.DataBinding.DataSource := FolderSrc;
    Result.DataBinding.DataField  := AFieldName;
    Result.Properties.ReadOnly := AReadOnly;
    Result.Width := AWidth;
  end;

var
  Group: TmdoLayoutGroup;
begin
  inherited DesignControls;
  FParamPanel := TmdoParamPanel.Create(Self);
  edFolder    := CreateStringEdit('FOLDER', 200);
  edAdress    := CreateStringEdit('ADRESS', 200);
  edVisirName := CreateStringEdit('DEVICE',      100);
  edVisirDate := CreateStringEdit('DEVICE_DATE', 100);
  //
  edDNZNumber   := CreateStringEdit('DNZ_NUMBER',   70, False);
  edActualSpeed := CreateStringEdit('ACTUAL_SPEED', 70, False);
  edLimitSpeed  := CreateStringEdit('LIMIT_SPEED',  70, False);
  edPenalty     := CreateStringEdit('PENALTY',      70, False);
  edDNZNumber.OnKeyUp   := EditKeyUp;
  edPenalty.OnKeyUp     := EditKeyUp;
  edLimitSpeed.OnKeyUp  := EditKeyUp;
  edActualSpeed.OnKeyUp := EditKeyUp;
  edDNZNumber.UpperCase := True;
  //
  FParamPanel.Root.LayoutDirection := TmdoLayoutDirection.ldHorizontal;
  Group := FParamPanel.Root.AddGroup;
  Group.AddControl(edFolder, alTop).Caption := 'Папка';
  Group.AddControl(edAdress, alTop).Caption := 'Адреса';
  //
  Group := FParamPanel.Root.AddGroup;
  Group.AddControl(edVisirName, alTop).Caption := 'Спеціальний технічний засіб';
  Group.AddControl(edVisirDate, alTop).Caption := 'Метрологічна повірка дійсна';
  //
  Group := FParamPanel.Root.AddGroup;
  Group.AddControl(edLimitSpeed,  alTop).Caption := 'Обмеження (км\ч)';
  Group.AddControl(edActualSpeed, alTop).Caption := 'Швидкість (км\ч)';
  //
  Group := FParamPanel.Root.AddGroup;
  Group.AddControl(edDNZNumber, alTop).Caption := 'ДНЗ';
  Group.AddControl(edPenalty,   alTop).Caption := 'Штраф (грн.)';
  // ListView
  ListView := TrtzListView.Create(Self);
  ListView.Align := alLeft;
  ListView.OnChange := ListViewChange;
  // Splitter
  with TmdoSplitter.Create(Self) do
  begin
    Align := alLeft;
    Control := ListView;
  end;
  // Slider
  Slider := TrtzImageSlider.Create(Self);
  Slider.Align := alClient;
  Slider.OnChange := SliderChange;
end;

procedure TrtzPhotoFolderForm.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  edDNZNumber.PostEditValue;
  edActualSpeed.PostEditValue;
  edLimitSpeed.PostEditValue;
  edPenalty.PostEditValue;
end;

function TrtzPhotoFolderForm.ActnVisible(Actn: TAction): Boolean;
begin
  Result := SupportIID(Actn, [IrtzPhotoOpenFolderAction, IrtzPhotoUpdateDataAction, IrtzPhotoCreateCardAction]);
  if not Result then
    Result := inherited ActnVisible(Actn);
end;

function TrtzPhotoFolderForm.ActnEnabled(Actn: TAction): Boolean;
begin
  Result := SupportIID(Actn, [IrtzPhotoOpenFolderAction, IrtzPhotoUpdateDataAction, IrtzPhotoCreateCardAction]);
  if not Result then
    Result := inherited ActnEnabled(Actn);
end;

function TrtzPhotoFolderForm.ActnExecute(Actn: TAction): Boolean;
begin
  if SupportIID(Actn, IrtzPhotoOpenFolderAction) then
    Result := ExecOpenFolder
  else
  if SupportIID(Actn, IrtzPhotoUpdateDataAction) then
    Result := ExecUpdateData
  else
  if SupportIID(Actn, IrtzPhotoCreateCardAction) then
    Result := ExecCreateCard
  else
    Result := inherited ActnExecute(Actn);
end;

function TrtzPhotoFolderForm.ExecOpenFolder: Boolean;
var
  Dlg: TOpenPictureDialog;
begin
  Result := False;
  Dlg := TOpenPictureDialog.Create(Self);
  try
    Dlg.DefaultExt := '*.jpg';
    Dlg.Filter     := 'фотокартки|*.jpg';
    Dlg.InitialDir := FolderSet.FieldByName('FOLDER').AsString;
    if Dlg.Execute(Self.Handle) then
    begin
      FolderSet.Edit;
      FolderSet.FieldByName('FOLDER').AsVariant := ExtractFilePath(Dlg.FileName);
      FolderSet.Post;
      Result := LoadPhotos;
    end;
  finally
    FreeAndNil(Dlg);
  end;
end;

function TrtzPhotoFolderForm.ExecUpdateData: Boolean;
var
  ViewInfo: TmdoControlInfoList;
begin
  ViewInfo := TmdoControlInfoList.Create;
  try
    ViewInfo.Caption := 'Редагування даних';
    ViewInfo.DataSource := FolderSrc;
    ViewInfo.AddNew('ADRESS',      'Адреса правопорушення',          'STRING', True);
    ViewInfo.AddNew('DEVICE_NAME', 'Назва спеціального тех. засобу', 'STRING', True);
    ViewInfo.AddNew('DEVICE_CODE', 'Номер спеціального тех. засобу', 'STRING', True);
    ViewInfo.AddNew('DEVICE_DATE', 'Метрологічна повірка дійсна до', 'DATE', True);
    Result := ExecActionUpdate(FolderSet, ViewInfo);
  finally
    FreeAndNil(ViewInfo);
  end;
end;

function TrtzPhotoFolderForm.ExecCreateCard: Boolean;
var
  ID: Int64;
  St: TMemoryStream;
  FileName: string;
begin
  St := TMemoryStream.Create;
  try
    FileName := TrtzListItem(ListView.Selected).FileName;
    St.LoadFromFile(FileName);
    St.Position := 0;
    ID := ExecWrite(MDO_DB_IID, sql_ap_photo_decision_create, procedure (const AParams: IQueryParams)
      begin
        AParams['DNZ_NUMBER'].AsVariant   := FolderSet.FieldByName('DNZ_NUMBER').AsVariant;
        AParams['ACTUAL_SPEED'].AsVariant := FolderSet.FieldByName('ACTUAL_SPEED').AsVariant;
        AParams['LIMIT_SPEED'].AsVariant  := FolderSet.FieldByName('LIMIT_SPEED').AsVariant;
        AParams['PENALTY'].AsVariant      := FolderSet.FieldByName('PENALTY').AsVariant;
        AParams['VIOLATION_DATE'].AsVariant := TrtzListItem(ListView.Selected).DateTime;
        AParams['PHOTO'].LoadFromStream(St);
      end).Fields[0].AsInt64;
    if ID <> 0 then
      OpenDocument(ID);
  finally
    St.Free;
  end;
end;

procedure TrtzPhotoFolderForm.OpenDocument(AID: Int64);
begin
  OpenDocumentCard(IrtzPhotoCardComp, AID);
end;

function TrtzPhotoFolderForm.GetFolderSet: TDataSet;
begin
  Result := nil;
  if Assigned(Comp) and (Comp is TrtzPhotoFolderComp)then
    Result := TrtzPhotoFolderComp(Comp).FolderSet;
end;

function TrtzPhotoFolderForm.GetFolderSrc: TDataSource;
begin
  Result := nil;
  if Assigned(Comp) and Assigned(FolderSet) then
    Result := Comp.Data.FindDataSrc(FolderSet);
end;

procedure TrtzPhotoFolderForm.ListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  Slider.ItemIndex := Item.Index;
end;

function TrtzPhotoFolderForm.LoadPhotos: Boolean;
begin
  StopThread;
  ClearImages;

  FThread := TrtzPhotoLoadThread.Create(True);
  FThread.Form := Self;
  FThread.Path := ExtractFilePath(FolderSet.FieldByName('FOLDER').AsString);
  FThread.Start;
end;

procedure TrtzPhotoFolderForm.AddImage(AFileName: string; ADateTime: TDateTime);
begin
  Slider.AddImage(AFileName);
  ListView.AddImage(AFileName, ADateTime);
end;

procedure TrtzPhotoFolderForm.ClearImages;
begin
  Slider.Images.Items.Clear;
  ListView.Items.Clear;
end;

procedure TrtzPhotoFolderForm.SliderChange(Sender: TObject);
begin
  ListView.SetListItemSelected(ListView.Items[Slider.ItemIndex]);
  ListView.SetFocus;
end;

procedure TrtzPhotoFolderForm.StopThread;
begin
  FThread.Terminate;
  while FThread.Working do
  begin
    Sleep(10);
    Application.ProcessMessages;
  end;
  FreeAndNil(FThread);
end;

{ TrtzPhotoLoadThread }

procedure TrtzPhotoLoadThread.AddImage;
begin
  FForm.AddImage(FFileName, FDateTime);
end;

procedure TrtzPhotoLoadThread.AfterConstruction;
begin
  inherited AfterConstruction;
  FreeOnTerminate := False;
end;

procedure TrtzPhotoLoadThread.BeforeDestruction;
begin
  inherited BeforeDestruction;
end;

procedure TrtzPhotoLoadThread.Execute;
var
  FileMask: WideString;
  Data: TWIN32FindData;
  HFnd: THandle;
begin
  FWorking := True;
  try
    Fpath := IncludeTrailingPathDelimiter(FPath);
    FileMask := FPath + '*.jpg';
    HFnd := Windows.FindFirstFile(PWideChar(FileMask), Data);
    if HFnd <> Windows.INVALID_HANDLE_VALUE then
      try
        repeat
          if Terminated then Break;
          FFileName := FPath + string(Data.cFileName);
          FDateTime := FileTimeToDateTime(Data.ftLastWriteTime);
          if Terminated then Break;
          Synchronize(AddImage);
          if Terminated then Break;
        until not Windows.FindNextFile(HFnd, Data);
      finally
        Windows.FindClose(HFnd);
      end;
  finally
    FWorking := False;
  end;
end;

{ TrtzListItem }

procedure TrtzListItem.SetFileName(AValue: string);
begin
  FFileName := AValue;
  Caption := ExtractFileName(FFileName);
end;

{ TrtzListView }

procedure TrtzListView.AddImage(AFileName: string; ADateTime: TDateTime);
var
  li: TrtzListItem;
  oc: TLVChangeEvent;
begin
  // create listitem
  oc := OnChange;
  OnChange := nil;
  //
  li := TrtzListItem(Items.Add);
  li.FileName := AFileName;
  li.DateTime := ADateTime;
  li.ImageIndex := AddImageToList(AFileName);
  li.StateIndex := li.ImageIndex;
  if Items.Count = 1 then
    SetListItemSelected(li);
  //
  OnChange := oc;
end;

function TrtzListView.AddImageToList(AFileName: string): Integer;
var
  bmp: TBitmap;
  pic: TPicture;
begin
  Pic := TPicture.Create;
  Bmp := TBitmap.Create;
  try
    Pic.LoadFromFile(AFileName);
    Bmp.SetSize(LargeImages.Width, LargeImages.Height);
    Bmp.Canvas.StretchDraw(Rect(0, 0, LargeImages.Width, LargeImages.Height), Pic.Graphic);
    Result := ImageList_Add(LargeImages.Handle, bmp.Handle, 0);
  finally
    Bmp.Free;
    Pic.Free;
  end;
end;

procedure TrtzListView.AfterConstruction;
begin
  inherited AfterConstruction;
  Width := 310;
  HideSelection := False;
  IconOptions.AutoArrange := True;
  LargeImages := TImageList.Create(Self);
  LargeImages.Height := 205;
  LargeImages.Width := 250;
  OnCreateItemClass := DoOnCreateItemClass;
end;

procedure TrtzListView.DoOnCreateItemClass(Sender: TCustomListView; var ItemClass: TListItemClass);
begin
  ItemClass := TrtzListItem;
end;

procedure TrtzListView.SetListItemSelected(AItem: TListItem);
begin
  AItem.MakeVisible(False);
  AItem.Selected := True;
  AItem.Focused  := True;
end;

initialization

  IDEDesigner.RegisterClasses([
    TrtzPhotoFolderComp,
    TrtzPhotoFolderForm,
    TrtzPhotoFolderAction,
    TrtzPhotoOpenFolderAction,
    TrtzPhotoUpdateDataAction,
    TrtzPhotoCreateCardAction
  ], PROTECTION_MODE_FREE);

end.
