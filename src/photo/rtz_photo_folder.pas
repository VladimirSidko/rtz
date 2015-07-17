unit rtz_photo_folder;

interface

uses
  Windows, Controls, Classes, DB, SysUtils, ExtDlgs, Forms, ComCtrls, Graphics, CommCtrl, ExtCtrls,
  ide3050_intf, ide3050_core_level3,
  rtz_dev_cntr, rtz_const_sql;

type
  TrtzPhotoLoadThread = class;

  IrtzPhotoFolderComp = interface ['{89DDD507-3753-4893-95DA-793DC715924D}'] end;
  TrtzPhotoFolderComp = class(TmdoComp, IrtzPhotoFolderComp)
  private
    FFolderSet: TDataSet;
  protected
    procedure DesignData; override;
  public
    function CanDestroy(CheckForClose: Boolean = False): Boolean; override;
    property FolderSet: TDataSet read FFolderSet;
  end;

  IrtzPhotoFolderForm = interface ['{48FBCBDB-6C67-4A11-AE1E-9B8B121FCE21}'] end;
  TrtzPhotoFolderForm = class(TmdoForm, IrtzPhotoFolderForm)
  private
    FParamPanel: TmdoParamPanel;
    edFolder:      TmdoDBStringEdit;
    edAdress:      TmdoDBStringEdit;
    edVisirName:   TmdoDBStringEdit;
    edVisirDate:   TmdoDBDateEdit;
    edDNZNumber:   TmdoDBStringEdit;
    edActualSpeed: TmdoDBStringEdit;
    ImageList: TImageList;
    ListView: TmdoListView;
    Slider:   TmdoImageSlider;
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
    procedure SetListItemSelected(AItem: TListItem);
    procedure EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    procedure DesignControls; override;
    function ActnVisible(Actn: TAction): Boolean; override;
    function ActnEnabled(Actn: TAction): Boolean; override;
    function ActnExecute(Actn: TAction): Boolean; override;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure AddImage(AFileName: string);

    property FolderSet: TDataSet read GetFolderSet;
    property FolderSrc: TDataSource read GetFolderSrc;
  end;

  TrtzPhotoLoadThread = class(TThread)
  private
    FWorking: Boolean;
    FForm: TrtzPhotoFolderForm;
    FPath: string;
    FFileName: string;
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

{ TrtzPhotoFolderComp }

function TrtzPhotoFolderComp.CanDestroy(CheckForClose: Boolean): Boolean;
begin
  Result := True;
end;

procedure TrtzPhotoFolderComp.DesignData;
begin
  inherited DesignData;
  FFolderSet := Data.AddDataSet('FolderSet', [sql_ap_photo_folder_get, sql_ap_photo_folder_get, '', sql_ap_photo_folder_upd, '']);
  FFolderSet.Open;
end;

{ TrtzPhotoFolderForm }

procedure TrtzPhotoFolderForm.AfterConstruction;
begin
  inherited AfterConstruction;
  if Self.Parent is TIDELevel3 then
  begin
    TIDELevel3(Self.Parent).TBLeft.Items.Clear;
    TIDELevel3(Self.Parent).TBRight.Items.Clear;
  end;
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

  function CreateStringEdit(AFieldName: string; AReadOnly: Boolean = True; AWidth: Integer = 300): TmdoDBStringEdit;
  begin
    Result := TmdoDBStringEdit.Create(Self);
    Result.DataBinding.DataSource := FolderSrc;
    Result.DataBinding.DataField  := AFieldName;
    Result.Properties.ReadOnly := AReadOnly;
    Result.Width := AWidth;
  end;

  function CreateDateEdit(AFieldName: string; AReadOnly: Boolean = True; AWidth: Integer = 300): TmdoDBDateEdit;
  begin
    Result := TmdoDBDateEdit.Create(Self);
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
  edFolder    := CreateStringEdit('FOLDER');
  edAdress    := CreateStringEdit('ADRESS');
  edVisirName := CreateStringEdit('DEVICE');
  edVisirDate := CreateDateEdit('DEVICE_DATE');
  //
  edDNZNumber   := CreateStringEdit('DNZ_NUMBER',   False, 100);
  edActualSpeed := CreateStringEdit('ACTUAL_SPEED', False, 100);
  edDNZNumber.OnKeyUp := EditKeyUp;
  edActualSpeed.OnKeyUp := EditKeyUp;
  //
  FParamPanel.Root.LayoutDirection := TmdoLayoutDirection.ldHorizontal;
  Group := FParamPanel.Root.AddGroup;
  Group.AddControl(edFolder, alTop).Caption := 'Папка';
  Group.AddControl(edAdress, alTop).Caption := 'Адреса';
  //
  Group := FParamPanel.Root.AddGroup;
  Group.AddControl(edVisirName, alTop).Caption := 'Спеціальний технічний засіб';
  Group.AddControl(edVisirDate, alTop).Caption := 'Метрологічна повірка дійсна до';
  //
  Group := FParamPanel.Root.AddGroup;
  Group.AddControl(edDNZNumber,   alTop).Caption := 'ДНЗ';
  Group.AddControl(edActualSpeed, alTop).Caption := 'Швидкість';
  // ImageList
  ImageList := TImageList.Create(Self);
  ImageList.Height := 205;
  ImageList.Width := 250;
  // ListView
  ListView := TmdoListView.Create(Self);
  ListView.Align := alLeft;
  ListView.Width := 310;
  ListView.LargeImages := ImageList;
  ListView.HideSelection := False;
  ListView.IconOptions.AutoArrange := True;
  // Splitter
  with TmdoSplitter.Create(Self) do
  begin
    Align := alLeft;
    Control := ListView;
  end;
  // Slider
  Slider := TmdoImageSlider.Create(Self);
  Slider.Align := alClient;
  Slider.OnChange := SliderChange;
end;

procedure TrtzPhotoFolderForm.EditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  edDNZNumber.PostEditValue;
  edActualSpeed.PostEditValue;
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
begin

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

procedure TrtzPhotoFolderForm.AddImage(AFileName: string);
var
  lv: TListItem;
  bmp: TBitmap;
  pic: TPicture;
begin
  // add image to slider
  Slider.AddImage(AFileName);

  // add image to listview
  Pic := TPicture.Create;
  Bmp := TBitmap.Create;
  try
    // load image from the file and draw it in size of imagelist
    Pic.LoadFromFile(AFileName);
    Bmp.SetSize(ImageList.Width, ImageList.Height);
    Bmp.Canvas.StretchDraw(Rect(0, 0, ImageList.Width, ImageList.Height), Pic.Graphic);
    // create listitem
    ListView.OnChange := nil;
    lv := ListView.Items.Add;
    lv.Caption := ExtractFileName(AFileName);
    lv.ImageIndex := ImageList_Add(ImageList.Handle, bmp.Handle, 0);
    lv.StateIndex := lv.ImageIndex;
    if ListView.Items.Count = 1 then
      SetListItemSelected(ListView.Items[0]);
    ListView.OnChange := ListViewChange;
  finally
    Bmp.Free;
    Pic.Free;
  end;

end;

procedure TrtzPhotoFolderForm.ClearImages;
begin
  Slider.Images.Items.Clear;
  ListView.Items.Clear;
  ImageList.Clear;
end;

procedure TrtzPhotoFolderForm.SetListItemSelected(AItem: TListItem);
begin
  AItem.MakeVisible(False);
  AItem.Selected := True;
  AItem.Focused  := True;
end;

procedure TrtzPhotoFolderForm.SliderChange(Sender: TObject);
begin
  SetListItemSelected(ListView.Items[Slider.ItemIndex]);
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
  FForm.AddImage(FFileName);
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
