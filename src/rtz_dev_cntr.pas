unit rtz_dev_cntr;

interface

uses
  Windows, Dialogs, Graphics, Classes, Controls, ExtCtrls, Forms, DB, SysUtils, Menus,
  ComCtrls, TypInfo, Generics.Collections, Variants, Messages, IniFiles, StdCtrls,
  TB2Item,
  pFIBProps, FIBDatabase,
  cxControls, cxGraphics, cxSplitter, dxdbtree, cxListView, cxCheckBox, cxLookAndFeelPainters, cxContainer,
  cxGrid, cxEdit,  cxGridLevel, cxGridDBTableView, cxGridBandedTableView, cxDBData,
  cxGridDBBandedTableView,  cxTextEdit, cxSpinEdit, cxCalc, cxCalendar, cxTimeEdit,
  cxCustomData, cxDBEdit,  cxDropDownEdit, cxButtons, cxGridDBDataDefinitions,
  cxGridCustomTableView,  dxLayoutControl, dxLayoutContainer, dxLayoutLookAndFeels,
  cxDBLookupComboBox,  cxGridTableView, cxGridCustomView, cxCheckListBox, cxLookAndFeels, cxScrollBox, dxBevel,
  cxGridExportLink, cxDBLabel, cxLabel, cxButtonEdit, dxPSCore, dxPScxGridLnk, cxCurrencyEdit,
  dxTileControl, dxSkinsCore, dxCustomTileControl, dxCore, dxImageSlider,
  dxSkinOffice2010Silver,
  ide3050_intf, ide3050_intf_register, ide3050_core_register, ide3050_core_level3,
  idf3050_intf, idf3050_fibp, idf3050_core_comp, idf3050_core_form,
  rtz_const_sql, rtz_const;

type
  IUIItem2 = interface ['{873A436B-7421-4B0F-B3B7-2DD32C7C937D}']
    function GetID: Int64;
    function GetUseInPopup: Boolean;
    function GetOrderPopup: Integer;
    property UseInPopup: Boolean read GetUseInPopup;
    property OrderPopup: Integer read GetOrderPopup;
  end;

{
  todo: расшарить в 120 ветке
  TmdoUIItem = class(TUIItem, IUIItem2)
  private
    FID: Int64;
    FUseInPopup: Boolean;
    FOrderPopup: Integer;
    function UITypeByName(AName: string): TUIObjectType;
  protected
    function GetID: Int64;
    function GetUseInPopup: Boolean;
    function GetOrderPopup: Integer;
    procedure LoadFromQuery(AQuery: TIDFDataSet);
    procedure LoadChilds(AQuery: TIDFDataSet);
  public
    constructor Create;
    procedure Load(AIID: TGUID);
    class function CreateIID(AIID: TGUID): TmdoUIItem;
    property UseInPopup: Boolean read GetUseInPopup write FUseInPopup;
    property OrderPopup: Integer read GetOrderPopup write FOrderPopup;
  end;
}
  TmdoControlInfoList = class;
  TmdoFormRecordEdit = class;
  TmdoFormRecordEditClass = class of TmdoFormRecordEdit;

  TmdoComp = class(TIDFCompDB)
  private
    FMetaQuery: IQueryProvider;
    FDataSet: TDataSet;
    function GetDataSrc: TDataSource;
  protected
    function GetFDB_IID: TGUID; override;
    function GetMetaProc: string; virtual;

    // AddDataSet
    function AddDataSet(AQuery: IQueryProvider; APrefix: string; AMaster: TDataSource; AForceMasterRefresh: Boolean): TDataSet; overload;

    procedure DesignData; virtual;
  public
    procedure AfterConstruction; override;

    property MetaQuery: IQueryProvider read FMetaQuery;
    property DataSet: TDataSet read FDataSet write FDataSet;
    property DataSource: TDataSource read GetDataSrc;

    function MetaQueryFieldExists(AFieldName: string): Boolean;
    function CanLive(const ACaption: string): Boolean; override;
    function ExecAction(AGUID: TGUID): Boolean;
  end;

  TmdoCompWithParams = class(TmdoComp)
  private
    FParamSet: TDataSet;
  protected
    procedure DesignData; override;
  public
    procedure AfterConstruction; override;
    procedure RptParamLst(List: TStrings); override;
    function  RptParamVal(const Name: string): Variant; override;
    property ParamSet: TDataSet read FParamSet write FParamSet;
  end;

  TmdoForm = class(TIDEForm, IIDFFormDB)
  private
    FDataID: string;
    FDataInsID: string;
    FDataUpdID: string;
    FDataSet: TDataSet;
    FDataSource: TDataSource;
    FControlInfoList: TmdoControlInfoList;
    function GetmdoComp: TmdoComp;
    procedure FillNewRecord(ADataSet: TDataSet; AInfoList: TObject);
  protected
    function GetDataID: string; virtual;
    function GetDataInsID: string; virtual;
    function GetDataUpdID: string; virtual;
    function GetDataSource: TDataSource; virtual;
    function ImmediatlyOpen: Boolean; virtual;

    function ActnVisible(Actn: TAction): Boolean; override;
    function ActnEnabled(Actn: TAction): Boolean; override;
    function ActnExecute(Actn: TAction): Boolean; override;

    function ExecActionInsert(ADataSet: TDataSet; AViewInfo: TObject): Boolean; virtual;
    function ExecActionUpdate(ADataSet: TDataSet; AViewInfo: TObject): Boolean; virtual;
    function ExecActionDelete(ADataSet: TDataSet): Boolean; virtual;

    procedure DoPostData(ADataSet: TDataSet);
    procedure DoCancelData(ADataSet: TDataSet);

    function DeleteCount: Integer; virtual;
    procedure FillDeleteList(AList: TList<Int64>); virtual;

    procedure EventBeforeInsert(ADataSet: TDataSet); virtual;
    procedure EventAfterInsert(ADataSet: TDataSet); virtual;
    procedure EventBeforeEdit(ADataSet: TDataSet); virtual;
    procedure EventAfterEdit(ADataSet: TDataSet); virtual;
    procedure EventBeforePost(ADataSet: TDataSet); virtual;
    procedure EventAfterPost(ADataSet: TDataSet); virtual;
    procedure EventBeforeCancel(ADataSet: TDataSet); virtual;
    procedure EventAfterCancel(ADataSet: TDataSet); virtual;
    procedure EventBeforeDelete(ADataSet: TDataSet; var CanDelete: Boolean); virtual;
    procedure EventAfterDelete(ADataSet: TDataSet); virtual;
    procedure EventBeforeShowEditForm(AForm: TmdoFormRecordEdit; AEditState: TDataSetState); virtual;
    procedure EventAfterShowEditForm(AForm: TmdoFormRecordEdit; AEditState: TDataSetState; AIsResultOK: Boolean); virtual;

    procedure Refresh; virtual;

    // IIDFFormDB
    function GetCompDB: IIDFCompDB;
    function GetDataSet: TDataSet; virtual;
    function GetGridSet: TDataSet; virtual;
    function GetEditing: Boolean;
    function GetLooking: Boolean;
    function GetData: IIDFDataContainer;

    function GetEditFormClass: TmdoFormRecordEditClass; virtual;
    function GetEditForm(AViewInfo: TObject): TmdoFormRecordEdit; virtual;

    function GetControlInfoList: TmdoControlInfoList; virtual;
    function GetDBGridControlInfoList(AGridID: string; ACaption: string = ''; APrefics: string = ''): TmdoControlInfoList; virtual;
    function GetDateEditControlInfoList(ACaption: string = ''): TmdoControlInfoList; virtual;

    // AddDataSet
    function AddDataSet(AQuery: IQueryProvider; APrefix: string; AMaster: TDataSource; AForceMasterRefresh: Boolean): TDataSet; overload;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure StayForeground; override;

    function ExecAction(AGUID: TGUID): Boolean;

    function FindDataSource(ADataSet: TDataSet): TDataSource;
    function GetMetaID(APrefix: string): string;
    property DataID: string read GetDataID;
    property DataInsID: string read GetDataInsID;
    property DataUpdID: string read GetDataUpdID;
  published
    property Comp: TmdoComp read GetmdoComp;
    property DataSet: TDataSet read GetDataSet write FDataSet;
    property DataSource: TDataSource read GetDataSource write FDataSource;
  end;

  TmdoFormClass = class of TmdoForm;

  TmdoDBGrid = class;

  TmdoFormWithGrid = class(TmdoForm)
  private
    FGrid: TmdoDBGrid;
    procedure EditOnDblClick(Sender: TObject; ACellViewInfo: TObject; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
  protected
    procedure DesignControls; override;
    procedure Refresh; override;
    function DeleteCount: Integer; override;
    procedure FillDeleteList(AList: TList<Int64>); override;
  public
    property Grid: TmdoDBGrid read FGrid;
  end;

  TmdoParamPanel = class;

  TmdoFormWithGridAndParamPanel = class(TmdoFormWithGrid)
  private
    FParamID: string;
    FParamSet: TDataSet;
    FParamSource: TDataSource;
    FParamPanel: TmdoParamPanel;
    function GetmdoComp: TmdoCompWithParams;
  protected
    function GetParamID: string; virtual;
    function GetParamSet: TDataSet; virtual;
    function GetParamSource: TDataSource; virtual;
    procedure ParamFieldChange(Sender: TField); virtual;
    procedure DoSearchClick(Sender: TObject); virtual;
    procedure DesignControls; override;
    procedure Refresh; override;
  public
    property ParamPanel: TmdoParamPanel read FParamPanel;
    property ParamID: string read GetParamID;
  published
    property Comp: TmdoCompWithParams read GetmdoComp;
    property ParamSet: TDataSet read GetParamSet write FParamSet;
    property ParamSource: TDataSource read GetParamSource write FParamSource;
  end;

  TmdoControlInfo = class
  private
    FDataType: string;
    FCaption: string;
    FFieldName: string;
    FVisible: Boolean;
    FRequired: Boolean;
    FCloneAble: Boolean;
    FNameFieldName: string;
    FLookupKeyFieldName: string;
    FLookupListFieldName: string;
    FLookupIID: string;
    FLookupSQL: string;
    FLookupSQLName: string;
    FLookupSQLMaster: string;
    FWidth: Integer;
    FOnChange: TNotifyEvent;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Clear;
    procedure Assign(Source: TmdoControlInfo); virtual;
    procedure ReadFromQuery(ARec: TQueryRecord);

    function CreateControl(AOwner: TComponent; ADataSource: TDataSource): TControl; virtual;
    function LabelCaption: string;
    function LabelWidth: Integer;
    function ControlWidth: Integer;

    property DataType: string read FDataType write FDataType;
    property Caption: string read FCaption write FCaption;
    property FieldName: string read FFieldName write FFieldName;
    property Visible: Boolean read FVisible write FVisible;
    property Required: Boolean read FRequired write FRequired;
    property CloneAble: Boolean read FCloneAble write FCloneAble;
    property CheckFieldName: string read FNameFieldName write FNameFieldName;
    property NameFieldName: string read FNameFieldName write FNameFieldName;
    property LookupKeyFieldName: string read FLookupKeyFieldName write FLookupKeyFieldName;
    property LookupListFieldName: string read FLookupListFieldName write FLookupListFieldName;
    property LookupIID: string read FLookupIID write FLookupIID;
    property LookupSQL: string read FLookupSQL write FLookupSQL;
    property LookupSQLName: string read FLookupSQLName write FLookupSQLName;
    property LookupSQLMaster: string read FLookupSQLMaster write FLookupSQLMaster;

    property Width: Integer read FWidth write FWidth;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TmdoControlInfoList = class(TObjectList<TmdoControlInfo>)
  private
    FCaption: string;
    FDataSource: TDataSource;
    FButtonClick: TNotifyEvent;
    FFieldChange: TFieldNotifyEvent;
    FColor: TColor;
    FPrefics: string;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Clear;
    procedure Assign(Source: TmdoControlInfoList); virtual;

    property Color: TColor read FColor write FColor;
    property Caption: string read FCaption write FCaption;
    property DataSource: TDataSource read FDataSource write FDataSource;
    property ButtonClick: TNotifyEvent read FButtonClick write FButtonClick;
    property FieldChange: TFieldNotifyEvent read FFieldChange write FFieldChange;
    property Prefics: string read FPrefics write FPrefics;

    function AddNew(AFieldName: string; ACaption: string; ADataType: string; ARequired: Boolean;
      ANameFieldName: string = ''; ALookupKeyFieldName: string = ''; ALookupListFieldName: string = '';
      ALookupIID: string = ''; ALookupSQL: string = ''; ALookupSQLName: string = '';
      ACloneAble: Boolean = False; AVisible: Boolean = True): TmdoControlInfo;
    function AddFromQuery(ARec: TQueryRecord): TmdoControlInfo;
    procedure FillList(AKey: string);
  end;

  TmdoCustomDesignMethod = procedure(AForm: TObject) of object;
  TmdoCustomDesigner = class
  private
    FCustomDesignMethod: TmdoCustomDesignMethod;
  public
    property CustomDesignMethod: TmdoCustomDesignMethod read FCustomDesignMethod write FCustomDesignMethod;
    procedure ExecDesign(AForm: TObject);
  end;

  TmdoLayoutItem  = class;
  TmdoLayoutControl = class;
  TmdoOnControlCreatedEvent = procedure(Sender: TObject; AControl: TControl; AInfo: TObject) of Object;
  TmdoCaptionLayout = TdxCaptionLayout;
  TmdoButton = class;
  TmdoButtonList = class;

  TmdoFormRecordEdit = class(TForm)
  private
    type
      TmdoControlListInner = class(TStringList);
  private
    FViewInfo: TObject;
    FDataSource: TDataSource;
    FControlList: TmdoControlListInner;
    FOnControlCreatedEvent: TmdoOnControlCreatedEvent;
    FOKBtn: TmdoButton;
    FCancelBtn: TmdoButton;
    FPostData: TDataSetNotifyEvent;
    FCancelData: TDataSetNotifyEvent;
    function GetEditControlCount: Integer;
    function GetEditControls(Index: Integer): TControl;
    function GetDataSet: TDataSet;
    function CheckRequired: Boolean;
    procedure DesignView_ControlInfoList(ALayoutControl: TmdoLayoutControl; AInfoList: TmdoControlInfoList);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnOKUpdate(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    procedure ControlCreated(AInfo: TObject; AControl: TControl; Item: TmdoLayoutItem); virtual;
    procedure DesignButtons(AList: TmdoButtonList); virtual;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure DesignView(AViewInfo: TObject);
    procedure DesignControls(ADataID: string; ADataSource: TDataSource; ACaption: string);
    procedure CloneData(ASrcDataSet, ADstDataSet: TDataSet);

    function ShowModal: Integer; override;
    function FindControl(AFieldName: string; AClass: TCLass = nil): TControl;
    property EditControlCount: Integer read GetEditControlCount;
    property EditControls[Index: Integer]: TControl read GetEditControls;
    property DataSet: TDataSet read GetDataSet;
    property OKBtn: TmdoButton read FOKBtn;
    property CancelBtn: TmdoButton read FCancelBtn;
  published
    property OnControlCreatedEvent: TmdoOnControlCreatedEvent read FOnControlCreatedEvent write FOnControlCreatedEvent;
    property PostData: TDataSetNotifyEvent read FPostData write FPostData;
    property CancelData: TDataSetNotifyEvent read FCancelData write FCancelData;
  end;

  TmdoActnCPanelGeneric<T: TIDEComp> = class(TIDEActn)
  protected
    procedure EventExecute(Sender: TObject); override;
  end;

  TmdoPanel = class(TPanel)
  public
    procedure AfterConstruction; override;
  end;

  TmdoControl = class(TcxControl);

  TmdoSplitter = class(TcxSplitter)
  private
    function GetAlign: TAlign;
    procedure SetAlign(Value: TAlign);
  public
    procedure AfterConstruction; override;
    property Align: TAlign read GetAlign write SetAlign;
  end;

  TmdoButton = class(TcxButton)
  public
    procedure AfterConstruction; override;
  end;

  TmdoButtonList = class(TObjectList<TmdoButton>);

  TmdoDBTreeNode = class(TdxDBTreeNode);
  TmdoDBTreeNodeClass = class of TmdoDBTreeNode;
  TmdoCreateNodeEvent = procedure(Sender: TObject; DataSet: TDataSet; Node: TTreeNode) of Object;

  TmdoDBTreeView = class(TdxDBTreeView)
  private
    FTreeNodeClass: TmdoDBTreeNodeClass;
    FOnCreateNodeEvent: TmdoCreateNodeEvent;
    procedure InternalCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    function GetKeyField: TField;
    function GetParentField: TField;
  public
    procedure AfterConstruction; override;
    procedure ExpandFirst;
    procedure ExpandFirstLevel;
    procedure SetTreeViewFields(AName: string = 'NAME'; AID: string = 'ID'; AParentID: string = 'ID_PARENT');
    function CreateNode: TTreeNode; override;
    property TreeNodeClass: TmdoDBTreeNodeClass read FTreeNodeClass write FTreeNodeClass;
  published
    property OnCreateNode: TmdoCreateNodeEvent read FOnCreateNodeEvent write FOnCreateNodeEvent;
  end;

  TmdoListView = class(TcxListView)
  public
    procedure AfterConstruction; override;
  end;

  TmdoDBImage = class(TcxDBImage)
  public
    procedure AfterConstruction; override;
  end;

  TmdoImageSlider = class(TdxImageSlider)
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure AddImage(AFileName: string);
  end;

  TmdoPopupMenu = class(TIDEPopupMenu)
  private
    function InternalInsertItem(AItem: TIDEMenuItemCustom; AIndex: Integer): Integer;
  public
    function AddSubmenuItem(AAction: TIDEActn; AIndex: Integer = -1): Integer;
    function AddMenuItem(AAction: TIDEActn; AIndex: Integer = -1): Integer;
    function AddSeparator(AIndex: Integer = -1): Integer;
    procedure AppendSeparator;
  end;

  TmdoDBGridColumnInfo = class
  private
    FFieldName: string;
    FCaption: string;
    FWidth: Integer;
    FCheckBox: Boolean;
    FVisible: Boolean;
    FReadOnly: Boolean;
    FFootFnc: Integer;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Clear;
    procedure ReadFromQuery(ARec: TQueryRecord);

    property FieldName: string read FFieldName write FFieldName;
    property Caption: string read FCaption write FCaption;
    property Width: Integer read FWidth write FWidth;
    property CheckBox: Boolean read FCheckBox write FCheckBox;
    property Visible: Boolean read FVisible write FVisible;
    property FootFnc: Integer read FFootFnc write FFootFnc;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
  end;

  TmdoDBGridColumnInfoList = class(TObjectList<TmdoDBGridColumnInfo>)
  private
    FKeyField: string;
    FDataSource: TDataSource;
    FMasterKeyFieldNames: string;
    FDetailKeyFieldNames: string;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure Clear;

    property DataSource: TDataSource read FDataSource write FDataSource;
    property KeyField: string read FKeyField write FKeyField;
    property MasterKeyFieldNames: string read FMasterKeyFieldNames write FMasterKeyFieldNames;
    property DetailKeyFieldNames: string read FDetailKeyFieldNames write FDetailKeyFieldNames;

    function AddNew(AFieldName: string; ACaption: string; AWidth: Integer;
      ACheckBox: Boolean = False; AVisible: Boolean = True; AReadOnly: Boolean = True; AFootFnc: Integer = 0): TmdoDBGridColumnInfo;
    function AddFromQuery(ARec: TQueryRecord): TmdoDBGridColumnInfo;
    procedure FillList(AKey: string);
  end;

  TmdoDBGridColumn = class(TcxGridDBBandedColumn)
  private
    FBandCaptions: TStrings;
    FKeyCaption: string;
    FKeyColumn: Boolean;
    function GetCaption: string;
    procedure SetCaption(Value: string);
    function GetFullCaption: string;
    function GetBandCaption(Index: Integer): string;
    function GetBandCount: Integer;
    function GetBandID: Integer;
    procedure SetBandID(Value: Integer);
    procedure SetKeyColumn(Value: Boolean);
    function GetBand(Index: Integer): TObject;
    procedure SetBand(Index: Integer; ABand: TObject);
    property Band[Index: Integer]: TObject read GetBand write SetBand;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure ParseCaption(ACaption: string);
    procedure SetBooleanFormat;
    procedure SetMoneyFormat;
    property BandID: Integer read GetBandID write SetBandID;
    property BandCount: Integer read GetBandCount;
    property BandCaption[Index: Integer]: string read GetBandCaption;
  published
    property Caption: string read GetCaption write SetCaption;
    property FullCaption: string read GetFullCaption;
    property KeyColumn: Boolean read FKeyColumn write SetKeyColumn;
  end;

  TmdoDBGridColumnList = class(TList<TmdoDBGridColumn>);

  TmdoGridColumnsCustomizationPopup = class(TcxGridColumnsCustomizationPopup)
  protected
    function GetDropDownCount: Integer; override;
    procedure AddCheckListBoxItems; override;
    procedure ItemClicked(AItem: TObject; AChecked: Boolean); override;
  end;

  TmdoGridDataRow = class(TcxGridDataRow);

  TmdoGridTableController = class(TcxGridBandedTableController)
  private
    function GetSelectedRow(Index: Integer): TmdoGridDataRow;
    function GetSelectedCell(ARow: Integer; ACol: Integer): Variant;
  protected
    function GetItemsCustomizationPopupClass: TcxCustomGridItemsCustomizationPopupClass; override;
  public
    property SelectedRows[Index: Integer]: TmdoGridDataRow read GetSelectedRow;
    property SelectedCell[ARow: Integer; ACol: Integer]: Variant read GetSelectedCell;
  end;

  TmdoGridViewData = class(TcxGridViewData)
  protected
    function GetDataRecordClass(const ARecordInfo: TcxRowInfo): TcxCustomGridRecordClass; override;
  end;

  TmdoDBDataField = class(TcxDBDataField)
  public
    property Field;
  end;

  TmdoDBDataProvider = class(TcxDBDataProvider)
  public
    property DataLink;
  end;

  TmdoGridDBDataController = class(TcxGridDBDataController)
  private
    function GetProvider: TmdoDBDataProvider;
  protected
    function GetDataProviderClass: TcxCustomDataProviderClass; override;
  public
    property Provider: TmdoDBDataProvider read GetProvider;
    property Fields;
    property DBFields;
    property DBSelection;
    property KeyField;
  end;

  TmdoControlSaver = class
  private
    FIni: TMemIniFile;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    function Load(AControlName: string): Boolean;
    procedure Save(AControlName: string);

    property Ini: TMemIniFile read FIni;
  end;

  TmdoStringParser = class(TStringList)
  public
    procedure AfterConstruction; override;
  end;

  TmdoGridTableDataCellViewInfo = class(TcxGridTableDataCellViewInfo);
  TCellDblClickNotify = procedure (Sender: TObject; ACellViewInfo: TObject; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean) of object;
  TDrawGroupCellNotify = procedure (ACanvas: TCanvas) of object;
  TDrawCellNotify = procedure (ACanvas: TCanvas; ACellViewInfo: TmdoGridTableDataCellViewInfo) of object;

  TmdoDBBandedTableView = class(TcxGridDBBandedTableView)
  private
    const
      SectionCommon  = 'ViewCommon';
      SectionColumns = 'ViewColumns';
      IdentColumnCount = 'ColumnCount';
      IdentGroupBoxVisible = 'GroupBoxVisible';
    type
      TmdsCustomGridRecordsViewInfo = class(TcxCustomGridRecordsViewInfo);
      TmdoViewActn = class(TIDEActn)
      private
        FView: TmdoDBBandedTableView;
      public
        property View: TmdoDBBandedTableView read FView write FView;
      end;
    function GetMaxCount: Integer;
  private
    FColumnList: TmdoDBGridColumnList;
    FCellDblClick: TCellDblClickNotify;
    FDrawExpandedGroupCell: TDrawGroupCellNotify;
    FDrawCell: TDrawCellNotify;
    FKeyFieldName: string;
    FGroupSingleExpand: Boolean;
    function GetController: TmdoGridTableController;
    function GetSelectedCount: Integer;
    function GetSelectedRows(Index: Integer): TmdoGridDataRow;
    function GetSelectedCell(ARow: Integer; ACol: Integer): Variant;
    function GetColumnIndexByName(AName: string): Integer;
    function GetKeyFieldIndex: Integer;

    function GetDataController: TmdoGridDBDataController;
    function GetDBGrid: TmdoDBGrid;
    function GetItem(Index: Integer): TmdoDBGridColumn;
    procedure SetItem(Index: Integer; Value: TmdoDBGridColumn);
    procedure SetDataController(Value: TmdoGridDBDataController);
    procedure CreateStandartActions;
    procedure DBGridCopy(Sender: TObject);
    procedure DBGridSelectAll(Sender: TObject);
    procedure DBGridSaveAs(Sender: TObject);
    procedure DBGridGetCount(Sender: TObject);
    procedure DBGridPrint(Sender: TObject);
    procedure DBGridSetFont(Sender: TObject);
    procedure DBGridGetGridID(Sender: TObject);
    procedure DBGridSaveSettings(Sender: TObject);
    procedure CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
    procedure CustomDrawGroupCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableCellViewInfo; var ADone: Boolean);
    procedure CustomGroupRowExpanded(Sender: TcxGridTableView; AGroup: TcxGridGroupRow);
    procedure InnerCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure DoOnColumnPosChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
    procedure CreateColumnBands(APrevColumn, ACurrColumn: TmdoDBGridColumn);
  private
    function GetCaption: string;
    procedure SetCaption(Value: string);
    function GetGroupBoxVisible: Boolean;
    procedure SetGroupBoxVisible(Value: Boolean);
    function GetBandHeaderVisible: Boolean;
    procedure SetBandHeaderVisible(Value: Boolean);
    function GetColumnHeaderVisible: Boolean;
    procedure SetColumnHeaderVisible(Value: Boolean);
    function GetMasterKeyFieldNames: string;
    procedure SetMasterKeyFieldNames(Value: string);
    function GetDetailKeyFieldNames: string;
    procedure SetDetailKeyFieldNames(Value: string);
    function GetLevelIndex: Integer;
    procedure SetLevelIndex(AValue: Integer);
  protected
    function GetItemClass: TcxCustomGridTableItemClass; override;
    function GetControllerClass: TcxCustomGridControllerClass; override;
    function GetDataControllerClass: TcxCustomDataControllerClass; override;
    function GetViewDataClass: TcxCustomGridViewDataClass; override;
    function GetViewInfoClass: TcxCustomGridViewInfoClass; override;
    // Control Saver
    procedure SaverDataLoad(AIni: TMemIniFile); virtual;
    procedure SaverDataFill(AIni: TMemIniFile); virtual;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure CalculateGridContentHeight;
    procedure DesignHeader;
    procedure DesignView(AViewInfo: TObject);
    procedure DesignColumns(AGridID: string; ADataSource: TDataSource);

    function CreateColumn: TmdoDBGridColumn;
    function FindColumnIndex(Value: TmdoDBGridColumn): Integer;
    function FindColumnByName(AName: string): TmdoDBGridColumn;
    procedure FillSelectedKeys(AList: TList<Int64>);

    function AddColumn(AColumnInfo: TmdoDBGridColumnInfo): TmdoDBGridColumn;
    function AddKeyColumn(AFieldName: string): TmdoDBGridColumn;
    procedure AddFootSummary(AColumnInfo: TmdoDBGridColumnInfo); overload;
    procedure AddFootSummary(AColumn: TmdoDBGridColumn; AColumnInfo: TmdoDBGridColumnInfo); overload;
    function AddPopupSubmenuItem(AAction: TIDEActn; AIndex: Integer = -1): Integer;
    function AddPopupMenuItem(AAction: TIDEActn; AIndex: Integer = -1): Integer; overload;
    function AddPopupMenuItem(ACaption, AShortCut, AImageName: string; AProcedure: TNotifyEvent; AIndex: Integer = -1): Integer; overload;
    function AddPopupSeparator(AIndex: Integer = -1): Integer;
    procedure AddPopupItemsFromUIItems(AUIItem: IUIItem);

    property DBGrid: TmdoDBGrid read GetDBGrid;
    property Caption: string read GetCaption write SetCaption;
    property GroupBoxVisible: Boolean read GetGroupBoxVisible write SetGroupBoxVisible;
    property BandHeaderVisible: Boolean read GetBandHeaderVisible write SetBandHeaderVisible;
    property ColumnHeaderVisible: Boolean read GetColumnHeaderVisible write SetColumnHeaderVisible;
    property ColumnList: TmdoDBGridColumnList read FColumnList;
    property Controller: TmdoGridTableController read GetController;
    property SelectedCount: Integer read GetSelectedCount;
    property SelectedRows[Index: Integer]: TmdoGridDataRow read GetSelectedRows;
    property SelectedCell[ARow: Integer; ACol: Integer]: Variant read GetSelectedCell;
    property ColumnIndexByName[AName: string]: Integer read GetColumnIndexByName;
    property MaxCount: Integer read GetMaxCount;
    property Items[Index: Integer]: TmdoDBGridColumn read GetItem write SetItem;
    property MasterKeyFieldNames: string read GetMasterKeyFieldNames write SetMasterKeyFieldNames;
    property DetailKeyFieldNames: string read GetDetailKeyFieldNames write SetDetailKeyFieldNames;
    property KeyFieldName: string read FKeyFieldName;
    property KeyFieldIndex: Integer read GetKeyFieldIndex;
    property LevelIndex: Integer read GetLevelIndex write SetLevelIndex;
  published
    property DataController: TmdoGridDBDataController read GetDataController write SetDataController;
    property CellDblClick: TCellDblClickNotify read FCellDblClick write FCellDblClick;
    property DrawCell: TDrawCellNotify read FDrawCell write FDrawCell;
    property DrawExpandedGroupCell: TDrawGroupCellNotify read FDrawExpandedGroupCell write FDrawExpandedGroupCell;
    property GroupSingleExpand: Boolean read FGroupSingleExpand write FGroupSingleExpand;
  end;

  TmdoGridRootLevel = class(TcxGridRootLevel)
  public
    procedure Clear;
  end;

  TmdsFocusedViewChanged = procedure (AGrid: TControl; APrevFocusedView, AFocusedView: TComponent) of object;

  TmdoDBGrid = class(TcxGrid)
  private
    const
      SectionFont  = 'Font';
      IdentName    = 'Name';
      IdentCharset = 'Charset';
      IdentColor   = 'Color';
      IdentHeight  = 'Height';
      IdentStyle   = 'Style';
  private
    FFocusedViewChanged: TmdsFocusedViewChanged;
    function GetDataSource: TDataSource;
    function GetView: TmdoDBBandedTableView;
    procedure SetView(AView: TmdoDBBandedTableView);
    function GetGroupBoxVisible: Boolean;
    procedure SetGroupBoxVisible(Value: Boolean);
    function GetBandHeaderVisible: Boolean;
    procedure SetBandHeaderVisible(Value: Boolean);
    function GetColumnHeaderVisible: Boolean;
    procedure SetColumnHeaderVisible(Value: Boolean);
  protected
    function GetGridID: string;
    function GetLevelsClass: TcxGridLevelClass; override;
    procedure FocusedViewChanged(APrevFocusedView, AFocusedView: TcxCustomGridView); override;
    // Control Saver
    procedure SaverDataLoad(AIni: TMemIniFile); virtual;
    procedure SaverDataFill(AIni: TMemIniFile); virtual;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    property DataSource: TDataSource read GetDataSource; //write SetDataSource;
    property View: TmdoDBBandedTableView read GetView write SetView;
    property GridID: string read GetGridID;

    property GroupBoxVisible: Boolean read GetGroupBoxVisible write SetGroupBoxVisible;
    property BandHeaderVisible: Boolean read GetBandHeaderVisible write SetBandHeaderVisible;
    property ColumnHeaderVisible: Boolean read GetColumnHeaderVisible write SetColumnHeaderVisible;
    property OnViewChanged: TmdsFocusedViewChanged read FFocusedViewChanged write FFocusedViewChanged;


    procedure DesignView(AViewInfo: TObject);
    procedure DesignColumns(AGridID: string; ADataSource: TDataSource);

    function AddView(AParentView: TObject = nil): TmdoDBBandedTableView;
    function FindColumnByName(AFieldName: string): TmdoDBGridColumn;

    procedure Load;
    procedure Save;
  end;

  TmdoStringEdit = class(TcxTextEdit);
  TmdoIntegerEdit = class(TcxSpinEdit);
  TmdoFloatEdit = class(TcxCalcEdit);
  TmdoDateEdit = class(TcxDateEdit);
  TmdoTimeEdit = class(TcxTimeEdit);
  TmdoCheckBox = class(TcxCheckBox);

  TmdoComboBox = class(TcxComboBox)
  private
    function GetItems: TStrings;
    function GetValue: Integer;
    procedure SetValue(AValue: Integer);
  public
    procedure AfterConstruction; override;
    property Items: TStrings read GetItems;
    property Value: Integer read GetValue write SetValue;
  end;

  TmdoDBLabel = class(TcxDBLabel)
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
  end;

  TmdoDBLabelProperties = class(TcxLabelProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBLabelViewInfo = class(TcxCustomLabelViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoDBText = class(TmdoDBLabel)
  public
    procedure AfterConstruction; override;
  end;

  TmdoDBStringEdit = class(TcxDBTextEdit)
  private
    function GetUpperCase: Boolean;
    procedure SetUpperCase(AValue: Boolean);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property UpperCase: Boolean read GetUpperCase write SetUpperCase;
  end;

  TmdoDBStringEditProperties = class(TcxTextEditProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBStringEditViewInfo = class(TcxCustomTextEditViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoDBIntegerEdit = class(TcxDBSpinEdit)
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
  end;

  TmdoDBIntegerEditProperties = class(TcxSpinEditProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBIntegerEditViewInfo = class(TcxSpinEditViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoDBFloatEdit = class(TcxDBCalcEdit)
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure SetMoneyFormat;
  end;

  TmdoDBFloatEditProperties = class(TcxCalcEditProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    procedure AfterConstruction; override;
  end;

  TmdoDBFloatEditViewInfo = class(TcxCustomTextEditViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoDBDateEdit = class(TcxDBDateEdit)
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure AfterConstruction; override;
  end;

  TmdoDBDateEditProperties = class(TcxDateEditProperties)
  public
    procedure ValidateDisplayValue(var ADisplayValue: TcxEditValue; var AErrorText: TCaption; var AError: Boolean; AEdit: TcxCustomEdit); override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBDateEditViewInfo = class(TcxCustomTextEditViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoDBDateTimeEdit = class(TmdoDBDateEdit)
  public
    procedure AfterConstruction; override;
  end;

  TmdoDBTimeEdit = class(TcxDBTimeEdit)
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
  end;

  TmdoDBTimeEditProperties = class(TcxTimeEditProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBTimeEditViewInfo = class(TcxSpinEditViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoDBCheckBox = class(TcxDBCheckBox)
  public
    procedure AfterConstruction; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
  end;

  TmdoDBCheckBoxProperties = class(TcxCheckBoxProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBCheckBoxViewInfo = class(TcxCustomCheckBoxViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoDBStringCheckEdit = class(TmdoDBStringEdit)
  private
    FCheckBox: TmdoDBCheckBox;
    procedure CheckChange(Sender: TObject);
  protected
    procedure SetControlInfo(Value: TmdoControlInfo);
    procedure Resize; override;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  published
    property ControlInfo: TmdoControlInfo write SetControlInfo;
  end;

  TmdoDBComboBox = class(TcxDBComboBox)
  private
    function GetListItems: TStrings;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure UpdateListStyle;
    property ListItems: TStrings read GetListItems;
  end;

  TmdoDBComboBoxProperties = class(TcxComboBoxProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBComboBoxViewInfo = class(TcxCustomComboBoxViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoDBLookupComboBox = class(TcxDBLookupComboBox)
  private
    FNameFieldName: string;
    FMasterSource: TDataSource;
    procedure ChangeValue(Sender: TObject);
    function GetListSource: TDataSource;
  protected
    procedure SetControlInfo(Value: TmdoControlInfo);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property ControlInfo: TmdoControlInfo write SetControlInfo;
    property MasterSource: TDataSource read FMasterSource write FMasterSource;
    property ListSource: TDataSource read GetListSource;
  end;

  TmdoDBLookupComboBoxProperties = class(TcxLookupComboBoxProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBLookupComboBoxViewInfo = class(TcxCustomComboBoxViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  ImdoLookupForm = interface ['{6078C21B-2E38-4516-AEAC-818EB4101D9F}']
    function GetGridName: string;
    function GetMetaSQL: string;

    procedure SetGridName(Value: string);
    procedure SetMetaSQL(Value: string);

    property GridName: string read GetGridName write SetGridName;
    property MetaSQL: string read GetMetaSQL write SetMetaSQL;

    procedure DesignView;
  end;

  TmdoDBLookupBox = class(TcxDBButtonEdit)
  private
    type
      TLookupForm = class(TmdoForm, ImdoLookupForm)
      private
        FProcQuery: IQueryProvider;
        FParamSet: TDataSet;
        FParamSource: TDataSource;
        FParamPanel: TmdoParamPanel;
        FGridName: string;
        FMetaSQL: string;
        FGrid: TmdoDBGrid;
        FbtnOK: TmdoButton;
        FbtnCansel: TmdoButton;
        function FieldExists(AQuery: IQueryProvider; AFieldName: string): Boolean;
        procedure DoSearchClick(Sender: TObject);
        procedure EditOnDblClick(Sender: TObject; ACellViewInfo: TObject; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
        procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
      protected
        function GetGridName: string;
        function GetMetaSQL: string;
        procedure SetGridName(Value: string);
        procedure SetMetaSQL(Value: string);
        procedure DesignData; override;
        procedure DesignControls; override;
        procedure DesignView;
        procedure CreateParams(var Params: TCreateParams); override;
    public
        procedure BeforeDestruction; override;
      published
        property ParamSet: TDataSet read FParamSet;
      end;
  private
    FKeyField: string;
    FCaption: string;
    FLookupFormIID: string;
    FLookupKeyField: string;
    FLookupListField: string;
    FLookupSQLText: string;
    FLookupSQLName: string;
    FLookupSQLMaster: string;
    FLookupForm: TmdoForm;
    FParamFieldDefs: TDictionary<string, Variant>;
    function GetReadOnly: Boolean;
    procedure SetReadOnly(Value: Boolean);
    procedure ButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure DoubleClick(Sender: TObject);
    procedure ShowLookupForm;
    procedure CreateLookupForm;
  protected
    function GetInnerEditClass: TControlClass; override;
    procedure SetControlInfo(Value: TmdoControlInfo);
    property LookupForm: TmdoForm read FLookupForm;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure AddParamFieldDefs(AKey: string; AValue: Variant);
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property ControlInfo: TmdoControlInfo write SetControlInfo;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
  end;

  TmdoDBLookupBoxProperties = class(TcxButtonEditProperties)
  public
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  TmdoDBLookupBoxViewInfo = class(TcxCustomTextEditViewInfo)
  protected
    procedure InternalPaint(ACanvas: TcxCanvas); override;
  end;

  TmdoLayoutItemControlAlignHorz = (caLeft, caCenter, caRight, caClient);
  TmdoLayoutItem  = class(TdxLayoutItem)
  private
    function GetCaption: string;
    procedure SetCaption(AValue: string);
    function GetControlAlign: TmdoLayoutItemControlAlignHorz;
    procedure SetControlAlign(Value: TmdoLayoutItemControlAlignHorz);
  public
    procedure AfterConstruction; override;
    procedure SetAlign(Value: TAlign);
    property Caption: string read GetCaption write SetCaption;
    property ControlAlign: TmdoLayoutItemControlAlignHorz read GetControlAlign write SetControlAlign;
  end;

  TmdoLayoutDirection = TdxLayoutDirection;

  TmdoLayoutGroup  = class(TdxLayoutGroup)
  private
    FID: Int64;
    function GetmdoItem(Index: Integer): TmdoLayoutItem;
    function GetFirstItem: TmdoLayoutItem;
    function GetCaption: string;
    procedure SetCaption(AValue: string);
  protected
    function GetMdoLayoutDirection: TmdoLayoutDirection;
    procedure SetMdoLayoutDirection(Value: TmdoLayoutDirection);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure SetAlign(Value: TAlign);
    function AddGroup: TmdoLayoutGroup;
    function AddItem(AAlign: TAlign = alNone): TmdoLayoutItem;
    function AddControl(AControl: TControl; AAlign: TAlign = alNone): TmdoLayoutItem;
    property ID: Int64 read FID write FID;
    property mdoItem[Index: Integer]: TmdoLayoutItem read GetmdoItem;
    property FirstItem: TmdoLayoutItem read GetFirstItem;
    property Caption: string read GetCaption write SetCaption;
  published
    property LayoutDirection: TmdoLayoutDirection read GetMdoLayoutDirection write SetMdoLayoutDirection;
  end;

  TmdoLayoutControlContainer = class(TdxLayoutControlContainer)
  protected
    function GetDefaultGroupClass: TdxLayoutGroupClass; override;
  end;

  TmdoLayoutControlViewInfo = class(TdxLayoutControlViewInfo)
  protected
    function GetContentBounds: TRect; override;
  end;

  TmdoLayoutControl = class(TdxLayoutControl)
  private
    function GetRoot: TmdoLayoutGroup;
  protected
    function GetContainerClass: TdxLayoutControlContainerClass; override;
    function GetViewInfoClass: TdxLayoutControlViewInfoClass; override;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure UpdateRootDirection;
    function AddGroup: TmdoLayoutGroup;
    property Root: TmdoLayoutGroup read GetRoot;
  end;

  TmdoParamPanel = class(TmdoLayoutControl)
  private
    FDataSource: TDataSource;
    FList: TObjectList<TControl>;
    FBtn: TmdoButton;
    FOnParamFieldChange: TFieldNotifyEvent;
    FOnButtonClick: TNotifyEvent;
    procedure OnParamChange(Sender: TField);
    procedure OnBtnClick(Sender: TObject);
    procedure OnPanelResize(Sender: TObject);
    function GetReplaceOnResize: Boolean;
    procedure SetReplaceOnResize(AValue: Boolean);
    procedure ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function GetPanelEnabled: Boolean;
    procedure SetPanelEnabled(Value: Boolean);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    procedure PostEditValue;
    procedure DesignView(AViewInfo: TObject);
    procedure DesignControls(AGridID: string; ADataSource: TDataSource; ABtnCkick: TNotifyEvent; AParamFieldChange: TFieldNotifyEvent);

    function AddControl(AControlInfo: TmdoControlInfo): TControl;
    function AddButton(AControlInfoList: TmdoControlInfoList): TmdoButton; overload;
    function AddButton(AButtonClick: TNotifyEvent): TmdoButton; overload;

    property DataSource: TDataSource read FDataSource write FDataSource;
    property ReplaceOnResize: Boolean read GetReplaceOnResize write SetReplaceOnResize;
    property Button: TmdoButton read FBtn;
    property ControlList: TObjectList<TControl> read FList;
  published
    property OnParamFieldChange: TFieldNotifyEvent read FOnParamFieldChange write FOnParamFieldChange;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property Enabled: Boolean read GetPanelEnabled write SetPanelEnabled;
  end;

  // PK 10.04.2015
  TmdoMsgAnimDirection = (msdirOpen, msdirHide);

  TmdoScreenPos = (spLeftTop, spTopLeft, spLeftBottom, spBottomLeft,
                   spRightTop, spTopRight, spRightBottom, spBottomRight,
                   spCenterTop, spCenterLeft, spCenterBottom, spCenterRight, spCenter,
                   spRightFill);
  {
           spTopLeft !             spTopRight !
              |-x----------X----------x-|
  ! spLeftTop x       spCenterTop !     x spRightTop !
              |                         |
              |                         |
!spCenterLeft X        spCenter         X spCenterRight !
              |                         |
              |                         |
!spLeftBottom x      spCenterBottom !   x spRightBottom !
              |-x----------X----------x-|
       spBottomLeft !               spBottomRight !
  }
  type
  TMsgStatus = (mstsDone, mstsNotDone, mstsInWork, mstsWaiting, mstsDeferred, mstsIgnore);// Отработало, Не отработало, в работе-показе, ожидает в очереди, отложено и снова ожидает.
  TdmoLocalAnimState = (animOpening, animStaying, animWaiting, animHiding, animHide, animShowDetail);

  TmdoTileControl = class(TdxTileControl)
  private
    function GetInnerHeightValue: Integer;
    function GetInnerWidthValue: Integer;
  protected
    FLocalState: TdmoLocalAnimState;
    FOwner: TWinControl;     // Initialize property
    FMsgAnimTimer: TTimer;   // For animation: ToOpen, ToHide, ToStay

    tmpItem: TdxTileControlItem; // Temporary variable to MsgItemControl
    tmpStr1, tmpStr2, tmpStr3: String; // Container of StrVariables to safe all MsgTxt(1,2,3) in time show MessageDetails. It need, but othercase it shows in "<- ... ->" block and look's bad
    FMsgDetailPanel: TcxScrollBox; // Panel as Component Container to Build several types of Detail Form for each MessageTypes

    procedure SetDefaultValues; virtual;

    procedure OnTimerEvent(Sender: TObject); virtual;

    procedure OnOpenDetail(Sender: TdxTileControlItem); virtual;
    procedure OnHideDetail(Sender: TdxTileControlItem); virtual;
    procedure OnMouseIn(Sender: TObject);  virtual;
    procedure OnMouseOut(Sender: TObject); virtual;

    procedure ClearDetailChildrenComponent;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure ChangeParent(aParent: TComponent); virtual;

    procedure CreateNewItemByMsgSett(aColorBack, aColorFont: TColor; aImgID: Integer;
      aTxt1, aTxt2, aTxt3, aTxt4: String; aSingleItem: Boolean = TRUE; aShowDetail: Boolean = FALSE);

    procedure ClearItems;

    property LocalState: TdmoLocalAnimState read FLocalState write FLocalState;
    property InnerWidth: Integer read GetInnerWidthValue;
    property InnerHeight: Integer read GetInnerHeightValue;
  end;

  function DefLookAndFeelSkinName: string;
  function DefLayoutLookAndFeel: TdxCustomLayoutLookAndFeel;
  function SetObjectLookAndFeel(AObject: TObject): Boolean;
  procedure SetControlDataBindingProps(AControl: TControl; ADataSource: TDataSource; AFieldName: string);

resourcestring
  DataType_String      = 'STRING';
  DataType_Integer     = 'INTEGER';
  DataType_Boolean     = 'BOOLEAN';
  DataType_Float       = 'FLOAT';
  DataType_Date        = 'DATE';
  DataType_Time        = 'TIME';
  DataType_DateTime    = 'DATE_TIME';
  DataType_List        = 'LIST';
  DataType_Combo       = 'COMBO';
  DataType_LookupCombo = 'LOOKUPCOMBO';
  DataType_Lookup      = 'LOOKUP';
  DataType_StrBool     = 'STR_BOOL';
  DataType_Label       = 'LABEL';
  DataType_Text        = 'TEXT';

type
  TmdoDataType = (dtString, dtInteger, dtBoolean, dtFloat, dtDate, dtTime, dtDateTime, dtList, dtCombo, dtLookupCombo, dtLookup, dtStrBool, dtLabel, dtText, dtNone);

function StrToDataType(ADataTypeStr: string): TmdoDataType;
procedure SetFieldDisplayFormat(AField: TField; ADisplayFormat: string);
procedure SetFieldMoneyFormat(AField: TField);

implementation

procedure SetFieldDisplayFormat(AField: TField; ADisplayFormat: string);
begin
  if IsPublishedProp(AField, 'DisplayFormat') then
    SetStrProp(AField, 'DisplayFormat', ADisplayFormat);
end;

procedure SetFieldMoneyFormat(AField: TField);
begin
  SetFieldDisplayFormat(AField, '# ##0.00');
end;

type
  TmdoLayoutSkinLookAndFeel = class(TdxLayoutSkinLookAndFeel)
  public
    function GetItemPainterClass: TClass; override;
  end;

var
  FLayoutLookAndFeel: TmdoLayoutSkinLookAndFeel;
  FSkinIndex: Byte = 0;

const
  FSkins: array[0..0]of string = ('Office2010Silver');

procedure IncSkinIndex;
begin
  if FSkinIndex = High(FSkins) then
    FSkinIndex := Low(FSkins)
  else
    Inc(FSkinIndex);
end;

function DefLookAndFeelSkinName: string;
begin
  Result := FSkins[FSkinIndex];
end;

function DefLayoutLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  if not Assigned(FLayoutLookAndFeel) then
  begin
    FLayoutLookAndFeel := TmdoLayoutSkinLookAndFeel.Create(nil);
    FLayoutLookAndFeel.LookAndFeel.SkinName := DefLookAndFeelSkinName;
    FLayoutLookAndFeel.LookAndFeel.NativeStyle := False;
  end;
  Result := FLayoutLookAndFeel;
end;


function DefLookAndFeel: TcxLookAndFeel;
begin
  DefLayoutLookAndFeel;
  Result := FLayoutLookAndFeel.LookAndFeel;
end;

function SetObjectLookAndFeel(AObject: TObject): Boolean;
var
  Style: TObject;
  Lf: TcxLookAndFeel;
begin
  Result := False;
  if Assigned(AObject) then
  begin
    if IsPublishedProp(AObject, 'Style') then
    begin
      Style := GetObjectProp(AObject, 'Style');
      if Assigned(Style) and (Style is TcxContainerStyle) then
      begin
        TcxContainerStyle(Style).LookAndFeel.SkinName := DefLookAndFeelSkinName;
        TcxContainerStyle(Style).LookAndFeel.NativeStyle := False;
        Result := True;
      end;
    end;
    if not Result and IsPublishedProp(AObject, 'LookAndFeel') then
    begin
      Lf := GetObjectProp(AObject, 'LookAndFeel') as TcxLookAndFeel;
      if Assigned(Lf) then
      begin
        Lf.SkinName := DefLookAndFeelSkinName;
        Lf.NativeStyle := False;
      end;
    end;
  end;
end;

procedure SetControlDataBindingProps(AControl: TControl; ADataSource: TDataSource; AFieldName: string);
var
  DataBinding: TcxDBEditDataBinding;
begin
  if IsPublishedProp(AControl, 'DataBinding') then
  begin
    DataBinding := GetObjectProp(AControl, 'DataBinding') as TcxDBEditDataBinding;
    if Assigned(DataBinding) then
    begin
      DataBinding.DataField  := AFieldName;
      DataBinding.DataSource := ADataSource;
    end;
  end;
end;

type
  TmdoLayoutItemPainter = class(TdxLayoutItemPainter)
  protected
    function GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass; override;
  end;
  TmdoLayoutItemCaptionPainter = class(TdxLayoutItemCaptionPainter)
  protected
    procedure DoDrawText; override;
  end;
  TmdoCustomLayoutItemCaptionViewInfo = class(TdxCustomLayoutItemCaptionViewInfo);

function TmdoLayoutSkinLookAndFeel.GetItemPainterClass: TClass;
begin
  Result := TmdoLayoutItemPainter;
end;

function TmdoLayoutItemPainter.GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass;
begin
  Result := TmdoLayoutItemCaptionPainter;
end;

// это для того, чтобы рисовать красную звездочку у обязательных полей
procedure TmdoLayoutItemCaptionPainter.DoDrawText;
var
  vText: string;
  vStar: string;
  vTextLen: Integer;
  vStarHeight: Integer;
  vStarWidth: Integer;
  vViewInfo: TmdoCustomLayoutItemCaptionViewInfo;
  vTextFlags: Integer;
  vDrawEnabled: Boolean;
  vRotationAngle: TcxRotationAngle;
  vTextRect: TRect;
  vStarRect: TRect;
begin
  //
  vViewInfo := TmdoCustomLayoutItemCaptionViewInfo(ViewInfo);
  vTextFlags := vViewInfo.CalculateTextFlags;
  vDrawEnabled := True; //DrawEnabled; // чтобы текст не был дизейбленым
  vRotationAngle := vViewInfo.GetRotationAngle;
  //
  vText := ViewInfo.Text;
  vTextLen := Length(vText);
  vTextRect := GetTextRect;
  if vText[vTextLen] <> '*' then
    Canvas.DrawText(vText, vTextRect, vTextFlags, vDrawEnabled, vRotationAngle)
  else
  begin
    //
    Delete(vText, vTextLen, 1);
    vStar := '*';
    //
    vStarRect := vTextRect;
    vStarHeight := Canvas.TextHeight(vStar);
    vStarWidth  := Canvas.TextWidth(vStar);
    vTextRect.Right := vTextRect.Right - vStarWidth;
    vStarRect.Left  := vTextRect.Right;
    vStarRect.Bottom := vStarRect.Top + vStarHeight;
    //
    Canvas.DrawText(vText, vTextRect, vTextFlags, vDrawEnabled, vRotationAngle);
    Canvas.Font.Color := clRed;
    Canvas.DrawText(vStar, vStarRect, vTextFlags, vDrawEnabled, vRotationAngle);
  end;
end;

function StrToDataType(ADataTypeStr: string): TmdoDataType;
const
  DataTypeArrayStr: array[TmdoDataType] of string = (DataType_String, DataType_Integer, DataType_Boolean, DataType_Float, DataType_Date, DataType_Time, DataType_DateTime, DataType_List, DataType_Combo, DataType_LookupCombo, DataType_Lookup, DataType_StrBool, DataType_Label, DataType_Text, '');
begin
  ADataTypeStr := UpperCase(ADataTypeStr);
  for Result := Low(TmdoDataType) to High(TmdoDataType) do
    if DataTypeArrayStr[Result] = ADataTypeStr then
      Break;
  if Result = dtNone then
    raise Exception.Create('StrToDataType: тип "' + ADataTypeStr + '" не поддерживается.');
end;

procedure SetControlEnabledByField(AEdit: TControl);
const
  BackColors: array[Boolean]of TColor = (clBtnFace, clWindow);
var
  Properties,
  DataBinding: TObject;
  DataSource: TDataSource;
  FieldName: string;
  Enable: Boolean;
begin
  if Assigned(AEdit) then
  begin
    Enable := False;
    //
    DataBinding := GetObjectProp(AEdit, 'DataBinding');
    if Assigned(DataBinding) then
    begin
      if IsPublishedProp(DataBinding, 'DataSource') and IsPublishedProp(DataBinding, 'DataField') then
      begin
        DataSource := GetObjectProp(DataBinding, 'DataSource') as TDataSource;
        if Assigned(DataSource) and Assigned(DataSource.DataSet) and DataSource.DataSet.Active then
        begin
          FieldName  := GetStrProp(DataBinding, 'DataField');
          Enable := not DataSource.DataSet.FieldByName(FieldName).ReadOnly;
        end else
          Enable := False;
        AEdit.Enabled := Enable;
      end;
    end;
    //проверим еще свойство ReadOnly
    if Enable and IsPublishedProp(AEdit, 'Properties') then
    begin
      Properties := GetObjectProp(AEdit, 'Properties');
      if (Properties is TcxCustomEditProperties) then
        Enable := not TcxCustomEditProperties(Properties).ReadOnly;
    end;
    if AEdit is TcxContainer then
      if Assigned((AEdit as TcxContainer).InnerControl) then
        (AEdit as TcxContainer).InnerControl.Brush.Color := BackColors[Enable];
  end;
end;

{ TmdoUIItem }
{
constructor TmdoUIItem.Create;
begin
  inherited Create(IDEDesigner.UI);
end;

class function TmdoUIItem.CreateIID(AIID: TGUID): TmdoUIItem;
begin
  Result := Create;
  Result.Load(AIID);
end;

function TmdoUIItem.GetID: Int64;
begin
  Result := FID;
end;

function TmdoUIItem.GetOrderPopup: Integer;
begin
  Result := FOrderPopup;
end;

function TmdoUIItem.GetUseInPopup: Boolean;
begin
  Result := FUseInPopup;
end;

procedure TmdoUIItem.Load(AIID: TGUID);
var
  Query: TIDFDataSet;
  UIItem: IUIItem;
begin
  UIItem := IDEDesigner.UI.Root.ItemByGUID[AIID];
  if Assigned(UIItem) then
    Self.Assign(UIItem)
  else
  begin
    Query := NewDS(MDO_DB_IID, [sql_sys_uiitems_get]);
    try
      Query.Params.Vars[0].AsString := GUIDToString(AIID);
      Query.Open;
      if not Query.Eof then
      begin
        LoadFromQuery(Query);
        LoadChilds(Query);
      end;
    finally
      FreeAndNil(Query);
    end;
    IDEDesigner.UI.Root.Add(Self);
  end;
end;

procedure TmdoUIItem.LoadChilds(AQuery: TIDFDataSet);
var
  Item: TmdoUIItem;
  I: Integer;
begin
  AQuery.First;
  while not AQuery.Eof do
  begin
    if AQuery.FieldByName('ID_PARENT').AsLargeInt = FID then
    begin
      Item := TmdoUIItem.Create;
      Item.LoadFromQuery(AQuery);
      Add(Item);
    end;
    AQuery.Next;
  end;
  for I := 0 to Count - 1 do
    TmdoUIItem(ItemByIndex[I]).LoadChilds(AQuery);
end;

procedure TmdoUIItem.LoadFromQuery(AQuery: TIDFDataSet);
begin
  FID         := AQuery.FieldByName('ID').AsLargeInt;
  AsIID       := AQuery.FieldByName('IID').AsString;
  ObjType     := UITypeByName(AQuery.FieldByName('OBJ_TYPE').AsString);
  Caption     := AQuery.FieldByName('CAPTION').AsString;
  Hint        := AQuery.FieldByName('HINT').AsString;
  ImageName   := AQuery.FieldByName('IMAGE_NAME').AsString;
  ShortCut    := AQuery.FieldByName('SHORT_CUT').AsString;
  DisplayMode := TActionDisplayMode(GetEnumValue(TypeInfo(TActionDisplayMode), Trim(AQuery.FieldByName('DISPLAY_MODE').AsString)));
  UseInPopup  := AQuery.FieldByName('USE_IN_POPUP').AsBoolean;
  OrderPopup  := AQuery.FieldByName('ORDER_POPUP').AsInteger;
end;

function TmdoUIItem.UITypeByName(AName: string): TUIObjectType;
begin
  AName := LowerCase(AName);
  if SameText('comp', AName) then
    Result := otComp
  else
  if SameText('form', AName) then
    Result := otForm
  else
  if SameText('actn', AName) then
    Result := otActn
  else
  if SameText('action', AName) then
    Result := otActn
  else
  if SameText('report', AName) then
    Result := otReport
  else
  if SameText('virtual', AName) then
    Result := otVirtual
  else
  if SameText('root', AName) then
    Result := otRoot
  else
  if SameText('separator', AName) then
    Result := otSeparator
  else
  if SameText('group', AName) then
    Result := otGroup
  else
  if SameText('grid', AName) then
    Result := otGrid
  else
  if SameText('columns', AName) then
    Result := otColumns
  else
  if SameText('col', AName) then
    Result := otCol

  else
    raise Exception.CreateFmt('Unknown node type %s', [AName]);
end;
}

{ TmdoComp }

function TmdoComp.ExecAction(AGUID: TGUID): Boolean;
var
  I: Integer;
  Action: TIDEActn;
begin
  Result := False;
  Action := nil;
  for I := 0 to Actions.Count - 1 do
    if SupportIID(Actions.Items[I], AGUID) then
    begin
      Action := Actions.Items[I] as TIDEActn;
      Break;
    end;
  if Assigned(Action) then
    Result := Action.Execute;
end;

function TmdoComp.GetDataSrc: TDataSource;
begin
  Result := Data.FindDataSrc(FDataSet);
end;

function TmdoComp.GetFDB_IID: TGUID;
begin
  Result := MDO_DB_IID;
end;

function TmdoComp.GetMetaProc: string;
begin
  Result := '';
end;

function TmdoComp.MetaQueryFieldExists(AFieldName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if MetaQuery = nil then
    Exit;

  AFieldName := UpperCase(AFieldName);
  for I := 0 to MetaQuery.FieldCount - 1 do
    if UpperCase(MetaQuery.Fields[I].Name) = AFieldName then
      Exit(True);
end;

function TmdoComp.AddDataSet(AQuery: IQueryProvider; APrefix: string; AMaster: TDataSource; AForceMasterRefresh: Boolean): TDataSet;
begin
  if AQuery = nil then
    Exit(nil);

  Result := Data.AddDataSet(AQuery.FieldByName(APrefix + '_ID').AsString, [
    AQuery.FieldByName(APrefix + '_SEL').AsString,
    AQuery.FieldByName(APrefix + '_REF').AsString,
    AQuery.FieldByName(APrefix + '_INS').AsString,
    AQuery.FieldByName(APrefix + '_UPD').AsString,
    AQuery.FieldByName(APrefix + '_DEL').AsString
    ], AMaster, AForceMasterRefresh);

  if not AForceMasterRefresh  then
    Result.AsIDF.DetailConditions := Result.AsIDF.DetailConditions - [dcForceMasterRefresh];
end;

procedure TmdoComp.AfterConstruction;
begin
  if GetMetaProc <> '' then
    FMetaQuery := ExecRead(FDB_IID, Format('select * from %s', [GetMetaProc]));

  inherited AfterConstruction;

  DesignData;
end;

function TmdoComp.CanLive(const ACaption: string): Boolean;
begin
  Result := inherited CanLive(ACaption);
{
  todo: расшарить в 120 ветке
  if not Assigned(UIItem) then
    UIItem := TmdoUIItem.CreateIID(FirstIID(Self));
}
end;

procedure TmdoComp.DesignData;
begin
  if MetaQuery = nil then
    Exit;
  FDataSet := AddDataSet(MetaQuery, 'DATA', nil, False);
end;

{ TmdoCompWithParams }

procedure TmdoCompWithParams.AfterConstruction;
begin
  inherited AfterConstruction;
  if Assigned(FParamSet) then
    FParamSet.Open;
end;

procedure TmdoCompWithParams.DesignData;
begin
  if MetaQuery = nil then
    Exit;
  FParamSet := AddDataSet(MetaQuery, 'PARAM', nil, False);
  FDataSet  := AddDataSet(MetaQuery, 'DATA', Data.FindDataSrc(FParamSet), False);
  FParamSet.Open;
end;

procedure TmdoCompWithParams.RptParamLst(List: TStrings);
var
  Fld: TField;
begin
  inherited RptParamLst(List);
  for Fld in FParamSet.Fields do
    List.Add(Format('%s=%s', [Fld.FieldName, Fld.FieldName]));
end;

function TmdoCompWithParams.RptParamVal(const Name: string): Variant;
begin
  if ParamSet.FieldExists(Name) then
    Result := ParamSet.FieldValues[Name]
  else
    Result := inherited RptParamVal(Name);
end;

{ TmdoForm }

function TmdoForm.ActnVisible(Actn: TAction): Boolean;
begin
  Result := SupportIID(Actn, [IIDFActnDBInsert, IIDFActnDBUpdate, IIDFActnDBDelete, IIDFActnDBRefreshAll, IIDFActnDBRefreshOne, IIDFActnDBPrint]);
end;

function TmdoForm.ActnEnabled(Actn: TAction): Boolean;
begin
  Result := SupportIID(Actn, [IIDFActnDBInsert, IIDFActnDBRefreshAll, IIDFActnDBPrint]);
  if not Result then
  begin
    if SupportIID(Actn, [IIDFActnDBUpdate, IIDFActnDBDelete, IIDFActnDBRefreshOne]) then
      Result := DataSet.HasData
    else
      Result := inherited ActnEnabled(Actn);
  end;
end;

function TmdoForm.ActnExecute(Actn: TAction): Boolean;
begin
  Result := True;
  if SupportIID(Actn, IIDFActnDBInsert) then
    Result := ExecActionInsert(DataSet, GetDBGridControlInfoList(DataInsID, 'str_mds_record_inserting'))
  else
  if SupportIID(Actn, IIDFActnDBUpdate) then
    Result := ExecActionUpdate(DataSet, GetDBGridControlInfoList(DataUpdID, 'str_mds_record_updating'))
  else
  if SupportIID(Actn, IIDFActnDBDelete) then
    Result := ExecActionDelete(DataSet)
  else
  if SupportIID(Actn, IIDFActnDBRefreshAll) then
    Refresh
  else
  if SupportIID(Actn, IIDFActnDBRefreshOne) then
    DataSet.Refresh
  else
    Result := inherited ActnExecute(Actn);
end;

function TmdoForm.AddDataSet(AQuery: IQueryProvider; APrefix: string; AMaster: TDataSource; AForceMasterRefresh: Boolean): TDataSet;
begin
  if Assigned(Comp) then
    Result := Comp.AddDataSet(AQuery, APrefix, AMaster, AForceMasterRefresh)
  else
    Result := NewDS(MDO_DB_IID, [
      AQuery.FieldByName(APrefix + '_SEL').AsString,
      AQuery.FieldByName(APrefix + '_REF').AsString,
      AQuery.FieldByName(APrefix + '_INS').AsString,
      AQuery.FieldByName(APrefix + '_UPD').AsString,
      AQuery.FieldByName(APrefix + '_DEL').AsString
      ], AMaster, AForceMasterRefresh);

  Result.AsIDF.DatasetID := AQuery.FieldByName(APrefix + '_ID').AsString;

  if not AForceMasterRefresh  then
    Result.AsIDF.DetailConditions := Result.AsIDF.DetailConditions - [dcForceMasterRefresh];
end;

procedure TmdoForm.AfterConstruction;
begin
  FDataID := '';
  FDataInsID := '';
  FDataUpdID := '';
  FDataSet := nil;
  FDataSource := nil;
  inherited AfterConstruction;
  if Self.Parent is TIDELevel3 then
  begin
    TIDELevel3(Self.Parent).TBLeft.Items.Clear;
    TIDELevel3(Self.Parent).TBRight.Items.Clear;
  end;
end;

procedure TmdoForm.BeforeDestruction;
begin
  if Assigned(FControlInfoList) then
    FreeAndNil(FControlInfoList);
  inherited BeforeDestruction;
  FDataSet := nil;
  FDataSource := nil;
end;

procedure TmdoForm.StayForeground;
begin
  inherited StayForeground;
  if FirstShow and ImmediatlyOpen and Assigned(DataSet) then
    DataSet.Open;
end;

function TmdoForm.GetmdoComp: TmdoComp;
begin
  Result := TmdoComp(inherited Comp);
end;

function TmdoForm.GetDataSource: TDataSource;
begin
  if not Assigned(FDataSource) then
    FDataSource := FindDataSource(DataSet);
  Result := FDataSource;
end;

function TmdoForm.GetDateEditControlInfoList(ACaption: string = ''): TmdoControlInfoList;
begin
  Result := GetControlInfoList;
  Result.AddNew('DATE_TIME', 'str_mds_datetime', DataType_Date, False);
  Result.Caption := ACaption;
end;


function TmdoForm.GetDBGridControlInfoList(AGridID: string; ACaption: string = ''; APrefics: string = ''): TmdoControlInfoList;
begin
  Result := GetControlInfoList;
  Result.FillList(AGridID);
  Result.Caption := ACaption;
  Result.Prefics := APrefics;
end;

function TmdoForm.ImmediatlyOpen: Boolean;
begin
  Result := True;
end;

procedure TmdoForm.Refresh;
begin
  if DataSet.Modified then
    DataSet.Post;
  DataSet.Close;
  DataSet.Open;
end;

function TmdoForm.GetEditFormClass: TmdoFormRecordEditClass;
begin
  Result := TmdoFormRecordEdit;
end;

function TmdoForm.GetEditForm(AViewInfo: TObject): TmdoFormRecordEdit;
begin
  Result := GetEditFormClass.CreateNew(Self);
  Result.DesignView(AViewInfo);
  Result.PostData := nil;
end;

procedure TmdoForm.DoPostData(ADataSet: TDataSet);
begin
  if ADataSet.Modified then
  begin
    if ADataSet.IsEditing then
      ADataSet.UpdateRecord;
    EventBeforePost(ADataSet);
    ADataSet.Post;
    EventAfterPost(ADataSet);
  end;
end;

procedure TmdoForm.DoCancelData(ADataSet: TDataSet);
begin
  EventBeforeCancel(ADataSet);
  ADataSet.Cancel;
  EventAfterCancel(ADataSet);
end;

function TmdoForm.ExecActionInsert(ADataSet: TDataSet; AViewInfo: TObject): Boolean;
var
  EditForm: TmdoFormRecordEdit;
begin
  if not Assigned(ADataSet) then
    raise Exception.Create('TmdoForm.ExecActionInsert: ADataSet is not assigned.');

  if TIDFDataSet(ADataSet).InsertSQL.Count = 0 then
    raise Exception.Create('TmdoForm.ExecActionInsert: TIDFDataSet(ADataSet).InsertSQL.Text is empty.');

  EventBeforeInsert(ADataSet);
  ADataSet.Insert;
  FillNewRecord(ADataSet, AViewInfo);
  EventAfterInsert(ADataSet);

  EditForm := GetEditForm(AViewInfo);
  try
    EditForm.PostData := DoPostData;
    EditForm.CancelData := DoCancelData;

    EventBeforeShowEditForm(EditForm, dsInsert);
    Result := EditForm.ShowModal = mrOk;
    EventAfterShowEditForm(EditForm, dsInsert, Result);
  finally
    EditForm.Free;
  end;
end;

function TmdoForm.ExecActionUpdate(ADataSet: TDataSet; AViewInfo: TObject): Boolean;
var
  EditForm: TmdoFormRecordEdit;
begin
  if not Assigned(ADataSet) then
    raise Exception.Create('TmdoForm.ExecActionUpdate: ADataSet is not assigned.');

  if TIDFDataSet(ADataSet).UpdateSQL.Count = 0 then
    raise Exception.Create('TmdoForm.ExecActionInsert: TIDFDataSet(ADataSet).UpdateSQL.Text is empty.');

  EventBeforeEdit(ADataSet);
  ADataSet.Edit;
  EventAfterEdit(ADataSet);

  EditForm := GetEditForm(AViewInfo);
  try
    EditForm.PostData := DoPostData;
    EditForm.CancelData := DoCancelData;

    EventBeforeShowEditForm(EditForm, dsEdit);
    Result := EditForm.ShowModal = mrOk;
    EventAfterShowEditForm(EditForm, dsEdit, Result);
  finally
    EditForm.Free;
  end;
end;

function TmdoForm.ExecAction(AGUID: TGUID): Boolean;
var
  I: Integer;
  Action: TIDEActn;
begin
  Action := nil;
  for I := 0 to Actions.Count - 1 do
    if SupportIID(Actions.Items[I], AGUID) then
    begin
      Action := Actions.Items[I] as TIDEActn;
      Break;
    end;
  if Assigned(Action) then
    Result := Action.Execute
  else
    Result := Comp.ExecAction(AGUID);
end;

function TmdoForm.DeleteCount: Integer;
begin
  Result := 1;
end;

procedure TmdoForm.FillDeleteList(AList: TList<Int64>);
begin
end;

function TmdoForm.ExecActionDelete(ADataSet: TDataSet): Boolean;
var
  CanDelete: Boolean;
  DelCount: Integer;
  List: TList<Int64>;
  ID: Int64;
begin
  if not Assigned(ADataSet) then
    raise Exception.Create('TmdoForm.ExecActnDelete: ADataSet = nil');

  if TIDFDataSet(ADataSet).DeleteSQL.Count = 0 then
    raise Exception.Create('TmdoForm.ExecActionInsert: TIDFDataSet(ADataSet).DeleteSQL.Text is empty.');

  DelCount := DeleteCount;
  if DelCount = 1 then
    Result := IDEDesigner.ShowMessage(str_idf_db_delete_confirm, mtCustom)
  else
    Result := IDEDesigner.ShowMessageFmt(str_idf_db_delete_confirm_multiple, [DelCount], mtCustom);

  if Result then
  begin
    EventBeforeDelete(ADataSet, CanDelete);
    if CanDelete then
    begin
      if DelCount = 1 then
        ADataSet.Delete
      else
      begin
        List := TList<Int64>.Create;
        try
          FillDeleteList(List);
          for ID in List do
            if ADataSet.Locate('ID', ID, []) then
              if CanDelete then
                try
                  ADataSet.Delete;
                except
                  on E: Exception do
                  begin
                    if ADataSet.AsIDF.AutoCommit
                       and Assigned(ADataSet.AsIDF.UpdateTransaction)
                       and (ADataSet.AsIDF.UpdateTransaction.State = tsActive) then
                      ADataSet.AsIDF.UpdateTransaction.Rollback;
                    raise;
                  end;
                end;
        finally
          List.Free;
        end;
      end
    end;
    EventAfterDelete(ADataSet);
  end;
end;

procedure TmdoForm.EventBeforeInsert(ADataSet: TDataSet);
begin
end;

procedure TmdoForm.EventAfterInsert(ADataSet: TDataSet);
begin
end;

procedure TmdoForm.EventBeforeEdit(ADataSet: TDataSet);
begin
end;

procedure TmdoForm.EventAfterEdit(ADataSet: TDataSet);
begin
end;

procedure TmdoForm.EventBeforePost(ADataSet: TDataSet);
begin
end;

procedure TmdoForm.EventAfterPost(ADataSet: TDataSet);
begin
end;

procedure TmdoForm.EventBeforeCancel(ADataSet: TDataSet);
begin
end;

procedure TmdoForm.EventAfterCancel(ADataSet: TDataSet);
begin
end;

procedure TmdoForm.EventBeforeShowEditForm(AForm: TmdoFormRecordEdit; AEditState: TDataSetState);
begin
end;

procedure TmdoForm.EventAfterShowEditForm(AForm: TmdoFormRecordEdit; AEditState: TDataSetState; AIsResultOK: Boolean);
begin
end;

procedure TmdoForm.EventBeforeDelete(ADataSet: TDataSet; var CanDelete: Boolean);
begin
  CanDelete := True;
end;

procedure TmdoForm.EventAfterDelete(ADataSet: TDataSet);
begin
end;

function TmdoForm.GetCompDB: IIDFCompDB;
begin
  Supports(Comp, IIDFCompDB, Result);
end;

function TmdoForm.GetControlInfoList: TmdoControlInfoList;
begin
  if not Assigned(FControlInfoList) then
    FControlInfoList := TmdoControlInfoList.Create
  else
    FControlInfoList.Clear;
  Result := FControlInfoList;
  Result.DataSource := Self.DataSource;
end;

function TmdoForm.GetDataSet: TDataSet;
begin
  if not Assigned(FDataSet) and Assigned(Comp) then
    FDataSet := Comp.DataSet;
  Result := FDataSet;
end;

function TmdoForm.GetGridSet: TDataSet;
begin
  Result := nil;
end;

function TmdoForm.GetEditing: Boolean;
begin
  Result := False;
end;

function TmdoForm.GetLooking: Boolean;
begin
  Result := False;
end;

function TmdoForm.GetData: IIDFDataContainer;
begin
  if Assigned(Comp) then
    Result := Comp.Data
  else
    Result := nil;
end;

function TmdoForm.GetMetaID(APrefix: string): string;
begin
  Result := '';
  if Assigned(Comp) and Assigned(Comp.MetaQuery) then
    if Comp.MetaQueryFieldExists(APrefix + '_ID') then
      Result := Comp.MetaQuery.FieldByName(APrefix + '_ID').AsString;
end;

function TmdoForm.GetDataID: string;
begin
  if (FDataID = '') then
    FDataID := GetMetaID('DATA');
  Result := FDataID;
end;

function TmdoForm.GetDataInsID: string;
begin
  if FDataInsID = '' then
  begin
    FDataInsID := GetMetaID('DATA_INS');
    if FDataInsID = '' then
      FDataInsID := GetDataID;
  end;
  Result := FDataInsID;
end;

function TmdoForm.GetDataUpdID: string;
begin
  if FDataUpdID = '' then
  begin
    FDataUpdID := GetMetaID('DATA_UPD');
    if FDataUpdID = '' then
      FDataUpdID := GetDataID;
  end;
  Result := FDataUpdID;
end;

procedure TmdoForm.FillNewRecord(ADataSet: TDataSet; AInfoList: TObject);
var
  I: Integer;
  Prefics: string;
begin
  if AInfoList is TmdoControlInfoList then
    Prefics := (AInfoList as TmdoControlInfoList).Prefics;
  if Prefics = '' then
    Prefics := 'DATA_NEW'
  else
    Prefics := Prefics + '_NEW';

  if Assigned(Comp) then
    if Comp.MetaQueryFieldExists(Prefics) then
      with ExecRead(MDO_DB_IID, Comp.MetaQuery.FieldByName(Prefics).AsString) do
        for I := 0 to FieldCount - 1 do
          if ADataSet.FieldExists(Fields[I].Name) then
            ADataSet.FieldByName(Fields[I].Name).AsVariant := Fields[I].AsVariant;
end;

function TmdoForm.FindDataSource(ADataSet: TDataSet): TDataSource;
begin
  Result := nil;
  if Assigned(Comp) then
    Result := Comp.Data.FindDataSrc(ADataSet);
end;

{ TmdoActnCPanelGeneric<T> }

procedure TmdoActnCPanelGeneric<T>.EventExecute(Sender: TObject);
var
  AComp: TIDECompClass;
begin
  AComp := T;
  IDEDesigner.CreateAndShowComp(FirstIID(AComp), Caption);
end;

{ TmdoPanel }
procedure TmdoPanel.AfterConstruction;
begin
  inherited AfterConstruction;
  Caption := '';
  BevelOuter := bvNone;
  Align := alClient;
end;

{ TmdoSplitter }

procedure TmdoSplitter.AfterConstruction;
begin
  inherited AfterConstruction;
  if Owner is TWinControl then
    Parent := Owner as TWinControl;
  SetObjectLookAndFeel(Self);
  HotZoneStyleClass := TcxMediaPlayer8Style;
end;

function TmdoSplitter.GetAlign: TAlign;
begin
  case AlignSplitter of
    salBottom: Result := alBottom;
    salRight : Result := alRight;
    salTop   : Result := alTop;
  else
    Result := alLeft;
  end;
end;

procedure TmdoSplitter.SetAlign(Value: TAlign);
const
  ArrCursor: array[TAlign] of TCursor = (crDefault, crVSplit, crVSplit, crHSplit, crHSplit, crDefault, crDefault);

begin
  case Value of
    alTop   : AlignSplitter := salTop;
    alBottom: AlignSplitter := salBottom;
    alLeft  : AlignSplitter := salLeft;
    alRight : AlignSplitter := salRight;
  end;
  Cursor := ArrCursor[Value];
end;

{ TmdoDBTreeView }

procedure TmdoDBTreeView.AfterConstruction;
begin
  inherited AfterConstruction;
  ShowRoot := False;
  ReadOnly := True;
  RowSelect := True;
  HideSelection := False;
  BorderStyle := bsNone;
  FTreeNodeClass := TmdoDBTreeNode;
  OnCreateNodeClass := InternalCreateNodeClass;
end;

function TmdoDBTreeView.CreateNode: TTreeNode;
begin
  if (GetKeyField <> nil) and (GetParentField <> nil) then
    Result := FTreeNodeClass.Create(DBTreeNodes, GetKeyField.Value)
  else
    Result := nil;

  if Assigned(Result) and (SelectedIndex <> -1) then
    Result.SelectedIndex := SelectedIndex;

  if Assigned(FOnCreateNodeEvent) then
    FOnCreateNodeEvent(Self, DataSource.DataSet, Result);
end;

procedure TmdoDBTreeView.InternalCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := FTreeNodeClass;
end;

procedure TmdoDBTreeView.ExpandFirst;
begin
  if Items.Count = 0 then
    RefreshItems;
  if Items.Count > 0 then
    Items[0].Expand(False);
end;

procedure TmdoDBTreeView.ExpandFirstLevel;
var
  Node: TTreeNode;
begin
  ExpandFirst;
  if Items.Count > 0 then
  begin
    Node := Items[0].GetFirstChild;
    while Node <> nil do
    begin
      Node.Expand(False);
      Node := Node.GetNextChild(Node);
    end;
  end;
end;

procedure TmdoDBTreeView.SetTreeViewFields(AName: string = 'NAME'; AID: string = 'ID'; AParentID: string = 'ID_PARENT');
begin
  KeyField := AID;
  ListField := AName;
  ParentField := AParentID;
end;

function TmdoDBTreeView.GetKeyField: TField;
begin
  Result := nil;
  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    Result := DataSource.DataSet.FindField(KeyField);
end;

function TmdoDBTreeView.GetParentField: TField;
begin
  Result := nil;
  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    Result := DataSource.DataSet.FindField(ParentField);
end;

{ TmdoControlInfo }

procedure TmdoControlInfo.AfterConstruction;
begin
  inherited AfterConstruction;
  Clear;
end;

procedure TmdoControlInfo.BeforeDestruction;
begin
  Clear;
  inherited BeforeDestruction;
end;

procedure TmdoControlInfo.Clear;
begin
  FDataType  := '';
  FCaption   := '';
  FFieldName := '';
  FVisible   := False;
  FRequired  := False;
  FCloneAble := False;
  FNameFieldName       := '';
  FLookupKeyFieldName  := '';
  FLookupListFieldName := '';
  FLookupIID     := '';
  FLookupSQL     := '';
  FLookupSQLName := '';
  FLookupSQLMaster := '';
  FWidth := 0;
  FOnChange := nil;
end;

procedure TmdoControlInfo.Assign(Source: TmdoControlInfo);
begin
  FDataType  := Source.DataType;
  FCaption   := Source.Caption;
  FFieldName := Source.FieldName;

  FVisible   := Source.Visible;
  FRequired  := Source.Required;
  FCloneAble := Source.CloneAble;

  FNameFieldName       := Source.NameFieldName;
  FLookupKeyFieldName  := Source.LookupKeyFieldName;
  FLookupListFieldName := Source.LookupListFieldName;

  FLookupIID     := Source.LookupIID;
  FLookupSQL     := Source.LookupSQL;
  FLookupSQLName := Source.LookupSQLName;
  FLookupSQLMaster := Source.LookupSQLMaster;

  FWidth    := Source.Width;
  FOnChange := Source.OnChange;
end;

procedure TmdoControlInfo.ReadFromQuery(ARec: TQueryRecord);
begin
  try
    FDataType  := ARec.Field['CONTROL_TYPE'].AsString;
    FCaption   := ARec.Field['LABEL'].AsString;
    FFieldName := ARec.Field['FIELD'].AsString;

    FVisible   := ARec.Field['VISIBLE'].AsBoolean;
    FRequired  := ARec.Field['REQUIRED'].AsBoolean;
    FCloneAble := ARec.Field['CLONE_ABLE'].AsBoolean;

    FWidth     := ARec.Field['FIELD_WIDTH'].AsInteger;

    FNameFieldName       := ARec.Field['LOOKUP_FIELD_VALUE'].AsString;
    FLookupKeyFieldName  := ARec.Field['LOOKUP_LIST_KEY'].AsString;
    FLookupListFieldName := ARec.Field['LOOKUP_LIST_VALUE'].AsString;

    FLookupIID     := ARec.Field['LOOKUP_IID'].AsString;
    FLookupSQL     := ARec.Field['LOOKUP_SQL'].AsString;
    FLookupSQLName := ARec.Field['LOOKUP_SQL_NAME'].AsString;
    FLookupSQLMaster := ARec.Field['LOOKUP_SQL_MASTER'].AsString;
  except
    Clear;
    raise Exception.Create('TmdoDBGridColumnInfo.ReadFromQuery: Запрос не поддерживает интерфейс описания колонки грида.');
  end;
end;

function TmdoControlInfo.LabelCaption: string;
begin
  Result := IDEDesigner.FindStr(Caption);
  if Required then
    Result := Result + '*';
end;

function TmdoControlInfo.LabelWidth: Integer;
begin
  Result := 150;
end;

function TmdoControlInfo.ControlWidth: Integer;
begin
  Result := FWidth;
  if Result = 0 then
    Result := 170;
end;

function TmdoControlInfo.CreateControl(AOwner: TComponent; ADataSource: TDataSource): TControl;
var
  vDataType: string;
  DataBinding: TObject;
  Properties: TcxCustomEditProperties;
begin
  vDataType := UpperCase(FDataType);
  if vDataType = DataType_Combo then
    Result := TmdoDBComboBox.Create(AOwner)
  else
  if vDataType = DataType_LookupCombo then
    Result := TmdoDBLookupComboBox.Create(AOwner)
  else
  if vDataType = DataType_Lookup then
    Result := TmdoDBLookupBox.Create(AOwner)
  else
  if vDataType = DataType_String then
    Result := TmdoDBStringEdit.Create(AOwner)
  else
  if vDataType = DataType_Integer then
    Result := TmdoDBIntegerEdit.Create(AOwner)
  else
  if vDataType = DataType_Float then
    Result := TmdoDBStringEdit.Create(AOwner)  //  TmdoDBFloatEdit.Create(AOwner)
  else
  if vDataType = DataType_Boolean then
    Result := TmdoDBCheckBox.Create(AOwner)
  else
  if vDataType = DataType_Date then
    Result := TmdoDBDateEdit.Create(AOwner)
  else
  if vDataType = DataType_DateTime then
    Result := TmdoDBDateTimeEdit.Create(AOwner)
  else
  if vDataType = DataType_Time then
    Result := TmdoDBTimeEdit.Create(AOwner)
  else
  if vDataType = DataType_StrBool then
    Result := TmdoDBStringCheckEdit.Create(AOwner)
  else
  if vDataType = DataType_Label then
    Result := TmdoDBLabel.Create(AOwner)
  else
  if vDataType = DataType_Text then
    Result := TmdoDBText.Create(AOwner)
  else
    raise Exception.Create(Format('TmdoParamPanel.AddControl: Unsupported editor class "%s".', [vDataType]));

  if AOwner is TWinControl then
    Result.Parent := AOwner as TWinControl;

  Result.Name := 'ed' + FieldName;

  SetObjectLookAndFeel(Result);

  DataBinding := GetObjectProp(Result, 'DataBinding');
  if Assigned(DataBinding) then
  begin
    if IsPublishedProp(DataBinding, 'DataField') then
      SetStrProp(DataBinding, 'DataField', FFieldName);
    if IsPublishedProp(DataBinding, 'DataSource') then
      SetObjectProp(DataBinding, 'DataSource', ADataSource);
  end;


  Properties := GetObjectProp(Result, 'Properties') as TcxCustomEditProperties;
  if Assigned(Properties) then
  begin
    Properties.ImmediatePost := True;
    Properties.OnChange := FOnChange;
  end;

  if IsPublishedProp(Result, 'ControlInfo') then
    SetObjectProp(Result, 'ControlInfo', Self);

  if IsPublishedProp(Result, 'Caption') then
    SetStrProp(Result, 'Caption', '');

  if FWidth > 0 then
    Result.Width := FWidth;

end;

{ TmdoControlInfoList }

procedure TmdoControlInfoList.AfterConstruction;
begin
  inherited AfterConstruction;
  Clear;
end;

procedure TmdoControlInfoList.BeforeDestruction;
begin
  FDataSource := nil;
  inherited BeforeDestruction;
end;

procedure TmdoControlInfoList.Clear;
begin
  FColor := clBtnFace;
  FPrefics := '';
  FCaption := '';
  FDataSource := nil;
  FButtonClick := nil;
  FFieldChange := nil;
  inherited Clear;
end;

procedure TmdoControlInfoList.Assign(Source: TmdoControlInfoList);
var
  Dst, Src: TmdoControlInfo;
  Obj: TObject;
begin
  Clear;
  FColor      := Source.Color;
  FCaption    := Source.Caption;
  FDataSource := Source.DataSource;
  FButtonClick := Source.ButtonClick;
  FFieldChange := Source.FieldChange;
  FPrefics     := Source.Prefics;

  for Src in Source do
  begin
    Obj := Src.ClassType.Create;
    Dst := Obj as TmdoControlInfo;
    Dst.Assign(Src);
    Add(Dst);
  end;
end;

function TmdoControlInfoList.AddNew(AFieldName: string; ACaption: string; ADataType: string; ARequired: Boolean;
  ANameFieldName: string = ''; ALookupKeyFieldName: string = ''; ALookupListFieldName: string = '';
  ALookupIID: string = ''; ALookupSQL: string = ''; ALookupSQLName: string = '';
  ACloneAble: Boolean = False; AVisible: Boolean = True): TmdoControlInfo;
begin
  Result := TmdoControlInfo.Create;
  Result.FieldName := AFieldName;
  Result.Caption   := ACaption;
  Result.DataType  := ADataType;

  Result.Required  := ARequired;
  Result.CloneAble := ACloneAble;
  Result.Visible   := AVisible;

  Result.NameFieldName       := ANameFieldName;
  Result.LookupKeyFieldName  := ALookupKeyFieldName;
  Result.LookupListFieldName := ALookupListFieldName;

  Result.LookupIID     := ALookupIID;
  Result.LookupSQL     := ALookupSQL;
  Result.LookupSQLName := ALookupSQLName;
  Add(Result);
end;

function TmdoControlInfoList.AddFromQuery(ARec: TQueryRecord): TmdoControlInfo;
begin
  Result := TmdoControlInfo.Create;
  try
    Result.ReadFromQuery(ARec);
    Add(Result);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TmdoControlInfoList.FillList(AKey: string);
var
  Query: IQueryProvider;
  Rec: TQueryRecord;
begin
  Query := ExecRead(MDO_DB_IID, SGET_SYS_GRID_EDIT_2, AKey);
  for Rec in Query do
    AddFromQuery(Rec);
end;

{ TmdoFormRecordEdit }

procedure TmdoFormRecordEdit.AfterConstruction;
begin
  inherited AfterConstruction;
  FDataSource := nil;
  FControlList := TmdoControlListInner.Create;
  OnKeyUp := FormKeyUp;
  KeyPreview := True;
end;

procedure TmdoFormRecordEdit.BeforeDestruction;
begin
  if Assigned(FViewInfo) then
    FreeAndNil(FViewInfo);
  FreeAndNil(FControlList);
  inherited BeforeDestruction;
end;

type
  TmdoLayoutGroupViewInfo = class(TdxLayoutGroupViewInfo)
  public
    property Options;
  end;

procedure TmdoFormRecordEdit.DesignButtons(AList: TmdoButtonList);
begin
end;

function TmdoFormRecordEdit.ShowModal: Integer;
begin
  Result := inherited ShowModal;
  if Result <> mrOk then
    if Assigned(FCancelData) then
      FCancelData(DataSet);
end;

procedure TmdoFormRecordEdit.BtnOKClick(Sender: TObject);
begin
  SetFocusedControl(FOKBtn);
  if Assigned(FPostData) then
    FPostData(DataSet);
  ModalResult := mrOK;
end;

procedure TmdoFormRecordEdit.BtnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TmdoFormRecordEdit.BtnOKUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CheckRequired;
end;

type
  TSelfControl = class(TControl);

function TmdoFormRecordEdit.CheckRequired: Boolean;
var
  Info: TmdoControlInfo;
  Index: Integer;
  Control: TControl;
  Value: Variant;
begin
  Result := True;
  if (FViewInfo is TmdoControlInfoList) then
    for Info in (FViewInfo as TmdoControlInfoList) do
      if Info.Required then
      begin
        Index := FControlList.IndexOf(Info.FieldName);
        if Index > -1 then
        begin
          Control := FControlList.Objects[Index] as TControl;
          Value := TSelfControl(Control).Text;
          if VarIsNull(Value) or (not TextExist(VarToStr(Value))) then
            Exit(False);
        end;
      end;
end;

procedure TmdoFormRecordEdit.DesignControls(ADataID: string; ADataSource: TDataSource; ACaption: string);
var
  Infos: TmdoControlInfoList;
begin
  Infos := TmdoControlInfoList.Create;
  try
    Infos.FillList(ADataID);
    Infos.DataSource := ADataSource;
    Infos.Caption := ACaption;
    DesignView(Infos);
  finally
    Infos.Free;
  end;
end;

procedure TmdoFormRecordEdit.DesignView(AViewInfo: TObject);

  function NewLayoutControl(AAlign: TAlign): TmdoLayoutControl;
  begin
    Result := TmdoLayoutControl.Create(Self);
    Result.Parent := Self;
    Result.Align := AAlign;
    Result.UpdateRootDirection;
    Result.Root.AlignHorz := ahLeft;
    Result.Root.AlignVert := avTop;
  end;

  function NewButton(ACaption: string; AOnExecute: TNotifyEvent; AOnUpdate: TNotifyEvent): TmdoButton;
  var
    Action: TAction;
  begin
    Action := TAction.Create(Self);
    Action.Caption := IDEDesigner.FindStr(ACaption);
    Action.OnExecute := AOnExecute;
    Action.OnUpdate := AOnUpdate;
    Result := TmdoButton.Create(Self);
    Result.Parent := Self;
    Result.Action := Action;
  end;

var
  ItemLayoutControl: TmdoLayoutControl;
  ButtonLayoutControl: TmdoLayoutControl;
  ButtonList: TmdoButtonList;
  Button: TmdoButton;
begin
  ItemLayoutControl   := NewLayoutControl(alTop);
  ButtonLayoutControl := NewLayoutControl(alBottom);

  // если не сделать HandleNeeded, то
  // ItemLayoutControl.ViewInfo.ContentBounds будет AV,
  // т.к. ItemLayoutControl.ViewInfo.ItemsViewInfo = nil
  ItemLayoutControl.Container.Control.HandleNeeded;
  ButtonLayoutControl.Container.Control.HandleNeeded;

  if Assigned(FViewInfo) then
    FViewInfo.Free;

  if AViewInfo is TmdoControlInfoList then
  begin
    FViewInfo := TmdoControlInfoList.Create;
    (FViewInfo as TmdoControlInfoList).Assign(AViewInfo as TmdoControlInfoList);
    DesignView_ControlInfoList(ItemLayoutControl, FViewInfo as TmdoControlInfoList);
  end
  else
  if AViewInfo is TmdoCustomDesigner then
    TmdoCustomDesigner(AViewInfo).ExecDesign(Self)
  else
    raise Exception.Create(ClassName + '.DesignView: класс "' + AViewInfo.ClassName + '" не поддерживается для дизайна.');

  ItemLayoutControl.ParentBackground := True;
  ItemLayoutControl.Anchors := [akLeft,akTop,akRight];

  ButtonLayoutControl.Root.AlignVert := avTop;
  ButtonLayoutControl.Root.AlignHorz := ahClient;

  FOKBtn := NewButton('str_idf_db_post',   BtnOKClick, BtnOKUpdate);
  FOKBtn.Default := True;
  ButtonLayoutControl.Root.AddControl(FOKBtn, alRight);

  FCancelBtn := NewButton('str_idf_db_cancel', BtnCancelClick, nil);
  ButtonLayoutControl.Root.AddControl(FCancelBtn, alRight);

  ButtonList := TmdoButtonList.Create(False);
  try
    DesignButtons(ButtonList);
    for Button in ButtonList do
      ButtonLayoutControl.Root.AddControl(Button, alLeft);
  finally
    FreeAndNil(ButtonList);
  end;

  //
  ItemLayoutControl.Height := ItemLayoutControl.ViewInfo.ContentHeight;
  ButtonLayoutControl.Height := ButtonLayoutControl.ViewInfo.ContentHeight;
  //
  ClientWidth  := ItemLayoutControl.ViewInfo.ContentWidth;
  ClientHeight := ItemLayoutControl.ViewInfo.ContentHeight + ButtonLayoutControl.ViewInfo.ContentHeight;
  //
  Constraints.MinHeight := Height;
  Constraints.MinWidth  := Width;

  Position := poMainFormCenter;
  //
end;

procedure TmdoFormRecordEdit.DesignView_ControlInfoList(ALayoutControl: TmdoLayoutControl; AInfoList: TmdoControlInfoList);

  function AddSplitter: TdxLayoutSplitterItem;
  begin
    Result := ALayoutControl.Root.CreateItem(TdxLayoutSplitterItem) as TdxLayoutSplitterItem;
    Result.LayoutLookAndFeel := DefLayoutLookAndFeel;
  end;

  function NewGroup(ALayoutControl: TmdoLayoutControl): TmdoLayoutGroup;
  begin
    Result := ALayoutControl.Root.AddGroup;
    Result.Caption := '';
    Result.ShowBorder := False;
    AddSplitter;
  end;

var
  InfoList: TmdoControlInfoList;
  Info: TmdoControlInfo;
  I, Middle: Integer;
  Control: TControl;
  Group: TmdoLayoutGroup;
  Item:  TmdoLayoutItem;
begin
  InfoList := AInfoList;

  Caption := IDEDesigner.FindStr(InfoList.Caption);
  Color   := InfoList.Color;
  FDataSource := InfoList.DataSource;

  Middle := 5;
  if InfoList.Count > Middle then
    Middle := InfoList.Count div 2 + InfoList.Count mod 2;

  Group := NewGroup(ALayoutControl);

  for I := 0 to InfoList.Count - 1 do
  begin
    Info := InfoList.Items[I];
    if Info.Visible then
    begin
      Control := Info.CreateControl(Self, FDataSource);

      if I = Middle then
        Group := NewGroup(ALayoutControl);

      Item := Group.AddControl(Control, alTop);

      Item.CaptionOptions.Visible := Info.Caption <> '';
      if Item.CaptionOptions.Visible then
      begin
        Item.Control.Width        := Info.ControlWidth;
        Item.CaptionOptions.Text  := Info.LabelCaption;
        Item.CaptionOptions.Width := Info.LabelWidth;
        Item.CaptionOptions.AlignHorz := taRightJustify;
        Item.CaptionOptions.Layout    := clLeft;
        Item.CaptionOptions.VisibleElements := [cveText];
      end;

      ControlCreated(Info, Control, Item);
      if Assigned(FOnControlCreatedEvent) then
        FOnControlCreatedEvent(Self, Control, Info);

      FControlList.AddObject(UpperCase(Info.FieldName), Control);
    end;
  end;

end;

procedure TmdoFormRecordEdit.CloneData(ASrcDataSet, ADstDataSet: TDataSet);
var
  InfoList: TmdoControlInfoList;
  Info: TmdoControlInfo;
  SrcFld,
  DstFld: TField;
begin
  if FViewInfo is TmdoControlInfoList then
  begin
    InfoList := FViewInfo as TmdoControlInfoList;
    for Info in InfoList do
      if Info.CloneAble then
      begin
        SrcFld := ASrcDataSet.FindField(Info.FieldName);
        DstFld := ADstDataSet.FindField(Info.FieldName);
        if Assigned(SrcFld) and Assigned(DstFld) then
        begin
          if not (ADstDataSet.State in dsWriteModes) then
            ADstDataSet.Edit;
          DstFld.AsVariant := SrcFld.AsVariant;
        end;
      end;
  end;
end;

function TmdoFormRecordEdit.FindControl(AFieldName: string; AClass: TCLass = nil): TControl;
var
  I: Integer;
begin
  Result := nil;
  AFieldName := UpperCase(AFieldName);

  I := FControlList.IndexOf(AFieldName);
  if I >= 0 then
    Result := TControl(FControlList.Objects[I]);

  if (AClass <> nil) and (Result <> nil) then
    if not Result.InheritsFrom(AClass) then
      Result := nil;
end;

procedure TmdoFormRecordEdit.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    FCancelBtn.Click;
end;

function TmdoFormRecordEdit.GetDataSet: TDataSet;
begin
  Result := FDataSource.DataSet;
end;

function TmdoFormRecordEdit.GetEditControlCount: Integer;
begin
  Result := FControlList.Count;
end;

function TmdoFormRecordEdit.GetEditControls(Index: Integer): TControl;
begin
  Result := TControl(FControlList.Objects[Index]);
end;

procedure TmdoFormRecordEdit.ControlCreated(AInfo: TObject; AControl: TControl; Item: TmdoLayoutItem);
begin
end;

procedure TmdoFormRecordEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style - WS_MINIMIZEBOX - WS_MAXIMIZEBOX;
end;

{ TmdoDBGridColumnInfo }

procedure TmdoDBGridColumnInfo.AfterConstruction;
begin
  inherited AfterConstruction;
  Clear;
end;

procedure TmdoDBGridColumnInfo.BeforeDestruction;
begin
  inherited BeforeDestruction;
end;

procedure TmdoDBGridColumnInfo.Clear;
begin
  FFieldName := '';
  FCaption   := '';
  FWidth     := 0;
  FCheckBox  := False;
  FVisible   := True;
  FReadOnly  := True;
  FFootFnc   := 0;
end;

procedure TmdoDBGridColumnInfo.ReadFromQuery(ARec: TQueryRecord);
begin
  try
    FFieldName := ARec.Field['FIELD'].AsString;
    FCaption   := ARec.Field['LABEL'].AsString;
    FWidth     := ARec.Field['WIDTH'].AsInteger;
    FCheckBox  := ARec.Field['CHECKBOX'].AsBoolean;
    FVisible   := ARec.Field['VISIBLE'].AsBoolean;
    FFootFnc   := ARec.Field['FOOT_FNC'].AsInteger;
  except
    Clear;
    raise Exception.Create('TmdoDBGridColumnInfo.ReadFromQuery: Запрос не поддерживает интерфейс описания колонки грида.');
  end;
end;

{ TmdoDBGridColumnInfoList }

procedure TmdoDBGridColumnInfoList.AfterConstruction;
begin
  inherited AfterConstruction;
  FKeyField := '';
end;

procedure TmdoDBGridColumnInfoList.BeforeDestruction;
begin
  FDataSource := nil;
  inherited BeforeDestruction;
end;

procedure TmdoDBGridColumnInfoList.Clear;
begin
  FKeyField := '';
  FDataSource := nil;
  FMasterKeyFieldNames := '';
  FDetailKeyFieldNames := '';
  inherited Clear;
end;

procedure TmdoDBGridColumnInfoList.FillList(AKey: string);
var
  Query: IQueryProvider;
  Rec: TQueryRecord;
begin
  if AKey = '' then
    Exit;
  Query := ExecRead(MDO_DB_IID, SGET_SYS_GRID_COLUMN, AKey);
  for Rec in Query do
    AddFromQuery(Rec);
end;

function TmdoDBGridColumnInfoList.AddFromQuery(ARec: TQueryRecord): TmdoDBGridColumnInfo;
begin
  Result := TmdoDBGridColumnInfo.Create;
  try
    Result.ReadFromQuery(ARec);
    Add(Result);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

function TmdoDBGridColumnInfoList.AddNew(AFieldName: string; ACaption: string; AWidth: Integer;
  ACheckBox: Boolean = False; AVisible: Boolean = True; AReadOnly: Boolean = True; AFootFnc: Integer = 0): TmdoDBGridColumnInfo;
begin
  Result := TmdoDBGridColumnInfo.Create;
  Result.FieldName := AFieldName;
  Result.Caption   := ACaption;
  Result.Width     := AWidth;
  Result.CheckBox  := ACheckBox;
  Result.Visible   := AVisible;
  Result.ReadOnly  := AReadOnly;
  Result.FootFnc   := AFootFnc;
  Add(Result);
end;

{ TmdoDBGridColumn }

procedure TmdoDBGridColumn.AfterConstruction;
begin
  inherited AfterConstruction;
  FBandCaptions := TStringList.Create;
  FKeyColumn := False;
end;

procedure TmdoDBGridColumn.BeforeDestruction;
begin
  FreeAndNil(FBandCaptions);
  inherited BeforeDestruction;
end;

function TmdoDBGridColumn.GetCaption: string;
begin
  Result := inherited Caption;
end;

procedure TmdoDBGridColumn.SetCaption(Value: string);
begin
  FKeyCaption := Value;
  inherited Caption := IDEDesigner.FindStr(Value);
end;

procedure TmdoDBGridColumn.SetKeyColumn(Value: Boolean);
begin
  FKeyColumn := Value;
  Position.BandIndex := -1;
  Visible := False;
end;

function TmdoDBGridColumn.GetFullCaption: string;
var
  str, koma: string;
begin
  Result := '';
  if GridView.OptionsView.BandHeaders then
    for str in FBandCaptions do
    begin
      Result := Format('%s%s%s', [Result, koma, IDEDesigner.FindStr(str)]);
      koma := ' -> ';
    end;
  Result := Format('%s%s%s', [Result, koma, Caption]);
end;

procedure TmdoDBGridColumn.ParseCaption(ACaption: string);
var
  tmp: string;
  ind: Integer;
begin
  tmp := ACaption;
  ind := AnsiPos('|', tmp);
  while ind > 0 do
  begin
    FBandCaptions.Add(Copy(tmp, 1, ind - 1));
    Delete(tmp, 1, ind);
    ind := AnsiPos('|', tmp);
  end;
  Caption := tmp;
end;

function TmdoDBGridColumn.GetBandCaption(Index: Integer): string;
begin
  Result := FBandCaptions.Strings[Index];
end;

function TmdoDBGridColumn.GetBandCount: Integer;
begin
  Result := FBandCaptions.Count;
end;

function TmdoDBGridColumn.GetBandID: Integer;
begin
  Result := Position.BandIndex;
end;

procedure TmdoDBGridColumn.SetBandID(Value: Integer);
begin
  Position.BandIndex := Value;
end;

procedure TmdoDBGridColumn.SetBooleanFormat;
begin
  PropertiesClassName := 'TcxCheckBoxProperties';
  TcxCheckBoxProperties(Properties).ValueChecked := '1';
  TcxCheckBoxProperties(Properties).ValueUnchecked := '0';
  Properties.ImmediatePost := Options.Editing;
end;

procedure TmdoDBGridColumn.SetMoneyFormat;
begin
  PropertiesClassName := 'TcxCurrencyEditProperties';
  TcxCurrencyEditProperties(Properties).DisplayFormat := '0.00';
end;

function TmdoDBGridColumn.GetBand(Index: Integer): TObject;
begin
  Result := FBandCaptions.Objects[Index];
end;

procedure TmdoDBGridColumn.SetBand(Index: Integer; ABand: TObject);
begin
  FBandCaptions.Objects[Index] := ABand;
end;

{ TmdoGridColumnsCustomizationPopup }

procedure TmdoGridColumnsCustomizationPopup.AddCheckListBoxItems;

  procedure SetItemInfo(AItem: TcxCheckListBoxItem; AText: string; AIndex: Integer);
  begin
    AItem.Text := AText;
    AItem.ItemObject := GridView.Items[AIndex];
  end;

var
  ColumnList: TmdoDBGridColumnList;
  Column: TmdoDBGridColumn;
begin
  if GridView.Owner is TmdoDBGrid then
  begin
    ColumnList := (GridView.Owner as TmdoDBGrid).View.ColumnList;
    for Column in ColumnList do
      if not Column.KeyColumn then
        with CheckListBox.Items.Add do
        begin
          Text := Column.FullCaption;
          ItemObject := Column;
          Checked := Column.Visible;
        end;
  end
  else
    inherited AddCheckListBoxItems;
end;

procedure TmdoGridColumnsCustomizationPopup.ItemClicked(AItem: TObject; AChecked: Boolean);
begin
  if GridView.Owner is TmdoDBGrid then
  begin
    TmdoDBGridColumn(AItem).Visible := AChecked;
    TmdoDBBandedTableView(GridView).DesignHeader;
  end
  else
    inherited ItemClicked(AItem, AChecked);
end;

function TmdoGridColumnsCustomizationPopup.GetDropDownCount: Integer;
begin
  if GridView.Owner is TmdoDBGrid then
    Result := (GridView.Owner as TmdoDBGrid).View.ColumnList.Count
  else
    Result := inherited GetDropDownCount;
end;

{ TmdoGridViewData }

function TmdoGridViewData.GetDataRecordClass(const ARecordInfo: TcxRowInfo): TcxCustomGridRecordClass;
begin
  Result := TmdoGridDataRow;
end;

{ TmdoGridTableController }

function TmdoGridTableController.GetItemsCustomizationPopupClass: TcxCustomGridItemsCustomizationPopupClass;
begin
  Result := TmdoGridColumnsCustomizationPopup;
end;

function TmdoGridTableController.GetSelectedCell(ARow, ACol: Integer): Variant;
begin
  Result := GetSelectedRow(ARow).Values[ACol];
end;

function TmdoGridTableController.GetSelectedRow(Index: Integer): TmdoGridDataRow;
begin
  Result := TmdoGridDataRow(inherited SelectedRows[Index]);
end;

{ TmdoDBBandedTableView }

function TmdoDBBandedTableView.AddColumn(AColumnInfo: TmdoDBGridColumnInfo): TmdoDBGridColumn;
begin
  Result := CreateColumn;
  if Assigned(AColumnInfo) then
  begin
    Result.ParseCaption(AColumnInfo.Caption);
    Result.Width := AColumnInfo.Width;
    Result.Options.Editing := not AColumnInfo.ReadOnly;
    Result.DataBinding.FieldName := AColumnInfo.FieldName;
    Result.Visible := AColumnInfo.Visible;
    Result.HeaderAlignmentHorz := taCenter;
    if AColumnInfo.CheckBox then
      Result.SetBooleanFormat;
  end;
  ColumnList.Add(Result);
end;

procedure TmdoDBBandedTableView.AddFootSummary(AColumnInfo: TmdoDBGridColumnInfo);
var
  I: Integer;
begin
  for I := 0 to ColumnCount - 1 do
    if Columns[I].DataBinding.FieldName = AColumnInfo.FieldName then
    begin
      AddFootSummary(TmdoDBGridColumn(Columns[I]), AColumnInfo);
      Break;
    end;
end;

procedure TmdoDBBandedTableView.AddFootSummary(AColumn: TmdoDBGridColumn; AColumnInfo: TmdoDBGridColumnInfo);

  function GetKindValue(AKind: Integer): TcxSummaryKind;
  begin
    case AKind of
      0: Result := skNone;
      1: Result := skSum;
      2: Result := skAverage;
      3: Result := skCount;
      6: Result := skMax;
      7: Result := skMin;
    else
      raise Exception.Create(Format('Summary kind = %d not supported.', [AColumnInfo.FootFnc]));
    end;
  end;

begin
  if AColumnInfo.FootFnc > 0 then
  begin
    DataController.Summary.FooterSummaryItems.Add(AColumn, spFooter, GetKindValue(AColumnInfo.FootFnc));
    OptionsView.Footer := DataController.Summary.FooterSummaryItems.Count > 0;
    OptionsView.FooterAutoHeight := True;
  end;
end;

procedure TmdoDBBandedTableView.AddPopupItemsFromUIItems(AUIItem: IUIItem);

  procedure AddActionsToListFromUIItems(AList: TStrings; AUIItem: IUIItem);
  var
    mdoUIItem: IUIItem2;
    Action: TAction;
    I: Integer;
  begin
    if AUIItem.Count > 0 then
    begin
      for I := 0 to AUIItem.Count - 1 do
        AddActionsToListFromUIItems(AList, AUIItem.ItemByIndex[I]);
    end
    else
    if Supports(AUIItem, IUIItem2, mdoUIItem) then
    begin
      if mdoUIItem.UseInPopup then
      begin
        Action := IDEDesigner.CreateActn(AUIItem.AsGUID, Self, AUIItem.Caption);
        AList.AddObject(IntToStr(mdoUIItem.OrderPopup), Action);
      end;
    end;
  end;

var
  ActList: TStringList;
  I: Integer;
begin
  if not Assigned(AUIItem) then
    Exit;

  ActList := TStringList.Create;
  try
    AddActionsToListFromUIItems(ActList, AUIItem);
    if ActList.Count > 0 then
    begin
      AddPopupSeparator;
      ActList.Sort;
      for I := 0 to ActList.Count - 1 do
        AddPopupMenuItem(TIDEActn(ActList.Objects[I]));
    end;
  finally
    ActList.Free;
  end;
end;

function TmdoDBBandedTableView.AddPopupMenuItem(AAction: TIDEActn; AIndex: Integer = -1): Integer;
begin
  Result := TmdoPopupMenu(PopupMenu).AddMenuItem(AAction, AIndex);
end;

function TmdoDBBandedTableView.AddPopupMenuItem(ACaption, AShortCut, AImageName: string; AProcedure: TNotifyEvent; AIndex: Integer): Integer;
var
  Action: TmdoViewActn;
begin
  Action := TmdoViewActn.Create(nil, nil);
  Action.View := Self;
  Action.Caption := IDEDesigner.FindStr(ACaption);
  Action.ShortCut := TextToShortCut(AShortCut);
  Action.OnExecute := AProcedure;
  Action.ImageIndex := IDEDesigner.FindImg(AImageName);
  Result := AddPopupMenuItem(Action, AIndex);
end;

function TmdoDBBandedTableView.AddPopupSeparator(AIndex: Integer = -1): Integer;
begin
  Result := TmdoPopupMenu(PopupMenu).AddSeparator(AIndex);
end;

function TmdoDBBandedTableView.AddPopupSubmenuItem(AAction: TIDEActn; AIndex: Integer = -1): Integer;
begin
  Result := TmdoPopupMenu(PopupMenu).AddSubmenuItem(AAction, AIndex);
end;

procedure TmdoDBBandedTableView.AfterConstruction;
begin
  FKeyFieldName := '';
  inherited AfterConstruction;
  OnCustomDrawGroupCell := CustomDrawGroupCell;
  OnCustomDrawCell := CustomDrawCell;
  OnCellDblClick := InnerCellDblClick;
  OnGroupRowExpanded := CustomGroupRowExpanded;
  OptionsView.HeaderFilterButtonShowMode := fbmButton;
  OptionsView.ShowColumnFilterButtons := sfbAlways;
  GroupBoxVisible := False;
  FColumnList := TmdoDBGridColumnList.Create;
  //
  PopupMenu := TmdoPopupMenu.Create(Owner);
  CreateStandartActions;
  //
  DataController.Options := DataController.Options + [dcoImmediatePost];
  OptionsView.NoDataToDisplayInfoText := '';
  OptionsCustomize.BandMoving := False;
  OptionsCustomize.ColumnsQuickCustomization := True;
  OptionsSelection.MultiSelect := True;
  OptionsSelection.InvertSelect := False;
  OptionsSelection.HideFocusRectOnExit := False;
  OptionsSelection.UnselectFocusedRecordOnExit := False;
  OnColumnPosChanged := DoOnColumnPosChanged;
  //
end;

procedure TmdoDBBandedTableView.BeforeDestruction;
begin
  FreeAndNil(FColumnList);
  inherited BeforeDestruction;
end;

function TmdoDBBandedTableView.GetBandHeaderVisible: Boolean;
begin
  Result := OptionsView.BandHeaders;
end;

function TmdoDBBandedTableView.GetCaption: string;
begin
  Result := TcxGridLevel(Level).Caption;
end;

function TmdoDBBandedTableView.GetColumnHeaderVisible: Boolean;
begin
  Result := OptionsView.Header;
end;

function TmdoDBBandedTableView.GetColumnIndexByName(AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to ItemCount - 1 do
    if SameText(Items[I].DataBinding.FieldName, AName) then
      Exit(I);
end;

function TmdoDBBandedTableView.GetController: TmdoGridTableController;
begin
  Result := TmdoGridTableController(inherited Controller);
end;

function TmdoDBBandedTableView.GetControllerClass: TcxCustomGridControllerClass;
begin
  Result := TmdoGridTableController;
end;

function TmdoDBBandedTableView.GetDataController: TmdoGridDBDataController;
begin
  Result := inherited DataController as TmdoGridDBDataController;
end;

procedure TmdoDBBandedTableView.SetBandHeaderVisible(Value: Boolean);
begin
  OptionsView.BandHeaders := Value;
end;

procedure TmdoDBBandedTableView.SetCaption(Value: string);
begin
  TcxGridLevel(Level).Caption := Value;
end;

procedure TmdoDBBandedTableView.SetColumnHeaderVisible(Value: Boolean);
begin
  OptionsView.Header := not Value;
end;

procedure TmdoDBBandedTableView.SetDataController(Value: TmdoGridDBDataController);
begin
  inherited DataController := Value;
end;

procedure TmdoDBBandedTableView.SetDetailKeyFieldNames(VAlue: string);
begin
  DataController.DetailKeyFieldNames := Value;
end;

procedure TmdoDBBandedTableView.SetGroupBoxVisible(Value: Boolean);
begin
  OptionsView.GroupByBox := Value;
end;

procedure TmdoDBBandedTableView.SetItem(Index: Integer; Value: TmdoDBGridColumn);
begin
  inherited Items[Index] := Value;
end;

procedure TmdoDBBandedTableView.SetLevelIndex(AValue: Integer);
begin
  TcxGridLevel(Self.Level).Index := AValue;
end;

procedure TmdoDBBandedTableView.SetMasterKeyFieldNames(Value: string);
begin
  DataController.MasterKeyFieldNames := Value;
end;

function TmdoDBBandedTableView.GetDataControllerClass: TcxCustomDataControllerClass;
begin
  Result := TmdoGridDBDataController;
end;

function TmdoDBBandedTableView.GetDBGrid: TmdoDBGrid;
begin
  Result := TmdoDBGrid(Self.Control);
end;

function TmdoDBBandedTableView.GetDetailKeyFieldNames: string;
begin
  Result := DataController.DetailKeyFieldNames;
end;

function TmdoDBBandedTableView.GetGroupBoxVisible: Boolean;
begin
  Result := OptionsView.GroupByBox;
end;

function TmdoDBBandedTableView.GetItem(Index: Integer): TmdoDBGridColumn;
begin
  Result := TmdoDBGridColumn(inherited Items[Index]);
end;

function TmdoDBBandedTableView.GetItemClass: TcxCustomGridTableItemClass;
begin
  Result := TmdoDBGridColumn;
end;

function TmdoDBBandedTableView.GetKeyFieldIndex: Integer;
begin
  Result := ColumnIndexByName[FKeyFieldName];
end;

function TmdoDBBandedTableView.GetLevelIndex: Integer;
begin
  Result := TcxGridLevel(Self.Level).Index;
end;

function TmdoDBBandedTableView.GetMasterKeyFieldNames: string;
begin
  Result := DataController.MasterKeyFieldNames;
end;

function TmdoDBBandedTableView.GetMaxCount: Integer;
begin
  Result := TmdsCustomGridRecordsViewInfo(ViewInfo.RecordsViewInfo).MaxCount;
end;

function TmdoDBBandedTableView.GetSelectedCell(ARow, ACol: Integer): Variant;
begin
  Result := Controller.SelectedCell[ARow, ACol];
end;

function TmdoDBBandedTableView.GetSelectedCount: Integer;
begin
  Result := Controller.SelectedRowCount;
end;

function TmdoDBBandedTableView.GetSelectedRows(Index: Integer): TmdoGridDataRow;
begin
  Result := Controller.SelectedRows[Index];
end;

procedure TmdoDBBandedTableView.CalculateGridContentHeight;
var
  I, H: Integer;
  Grid: TmdoDBGrid;
begin
  Grid := TmdoDBGrid(Control);
  H := Grid.ClientHeight + ViewInfo.ClientBounds.Top - ViewInfo.ClientBounds.Bottom;

  for I := 0 to MaxCount - 1 do
    Inc(H, ViewInfo.RecordsViewInfo.Items[I].MaxHeight);

  if H > Grid.Parent.ClientHeight then
    H := Grid.Parent.ClientHeight;

  Grid.ClientHeight := H;
end;

function TmdoDBBandedTableView.CreateColumn: TmdoDBGridColumn;
begin
  Result := TmdoDBGridColumn(inherited CreateColumn);
end;

procedure TmdoDBBandedTableView.CreateColumnBands(APrevColumn, ACurrColumn: TmdoDBGridColumn);

  function CreateBand(AParent: TcxGridBand; ACaption: string): TcxGridBand;
  begin
    Result := TcxGridBand.Create(Bands);
    Result.Caption := IDEDesigner.FindStr(ACaption);
    if Assigned(AParent) then
      Result.Position.BandIndex := AParent.ID;
  end;

  procedure CreateBands(AParent: TcxGridBand; AColumn: TmdoDBGridColumn; AIndex: Integer);
  var
    I: Integer;
    Band: TcxGridBand;
  begin
    if AColumn.BandCount = 0 then
      raise Exception.Create('Неправильный код. Возможно забыли написать свойство BandHeaderVisible := False; для грида');

    Band := AParent;
    for I := AIndex to ACurrColumn.BandCount - 1 do
    begin
      Band := CreateBand(Band, AColumn.BandCaption[I]);
      AColumn.Band[I] := Band;
    end;
    AColumn.BandID := Band.ID;
  end;

var
  I: Integer;
  Band: TcxGridBand;
begin
  if not Assigned(APrevColumn) then
    CreateBands(nil, ACurrColumn, 0)
  else
  begin
    Band := nil;
    for I := 0 to APrevColumn.BandCount - 1 do
    begin
      if AnsiSameText(APrevColumn.BandCaption[I], ACurrColumn.BandCaption[I]) then
        ACurrColumn.Band[I] := APrevColumn.Band[I]
      else
      begin
        CreateBands(Band, ACurrColumn, I);
        Break;
      end;
      Band := TcxGridBand(APrevColumn.Band[I]);
    end;
    ACurrColumn.BandID := TcxGridBand(ACurrColumn.Band[ACurrColumn.BandCount - 1]).ID;
  end;
end;

procedure TmdoDBBandedTableView.CreateStandartActions;
begin
  AddPopupMenuItem('str_idf_db_grid_copy',  'Ctrl+C', 'idf_copy.bmp',  DBGridCopy);      // копировать
  AddPopupMenuItem('str_idf_db_grid_sall',  'Ctrl+A', '',              DBGridSelectAll); // выделить всё
  AddPopupMenuItem('str_idf_db_grid_count', '',       'idf_sum.bmp',   DBGridGetCount);  // к-во записей
  AddPopupSeparator;
  AddPopupMenuItem('str_idf_db_grid_save',  'Ctrl+S', 'idf_save.bmp',  DBGridSaveAs);    // сохранить
  AddPopupMenuItem('str_idf_db_grid_prnt',  'Ctrl+P', 'idf_print.bmp', DBGridPrint);     // печать
  AddPopupSeparator;
  AddPopupMenuItem('str_idf_db_grid_font',  '',       '',              DBGridSetFont);   // шрифт
  AddPopupMenuItem('str_mdo_save_settings', '',       '',              DBGridSaveSettings); // сохранение настроек
  {$IFDEF DEBUG}
  AddPopupMenuItem('GridID',                '',       '',              DBGridGetGridID); //
  {$ENDIF}
end;

procedure TmdoDBBandedTableView.CustomDrawGroupCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableCellViewInfo; var ADone: Boolean);
begin
  if Assigned(FDrawExpandedGroupCell) then
  begin
    if AViewInfo.GridRecord is TcxGridGroupRow then
      if (AViewInfo.GridRecord as TcxGridGroupRow).Expanded then
        FDrawExpandedGroupCell(ACanvas.Canvas);
  end;
end;

procedure TmdoDBBandedTableView.CustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
begin
  ACanvas.Font.Color := DBGrid.Font.Color;
  if Assigned(FDrawCell) then
    FDrawCell(ACanvas.Canvas, TmdoGridTableDataCellViewInfo(AViewInfo));
end;

procedure TmdoDBBandedTableView.CustomGroupRowExpanded(Sender: TcxGridTableView; AGroup: TcxGridGroupRow);
var
  I: Integer;
  GroupRow: TcxGridGroupRow;
begin
  if FGroupSingleExpand then
  begin
    I := 0;
    while I < Sender.ViewData.RowCount do
    begin
      if (Sender.ViewData.Rows[I] is TcxGridGroupRow) then
      begin
        GroupRow := (Sender.ViewData.Rows[I] as TcxGridGroupRow);
        if GroupRow <> AGroup then
          if GroupRow.Expandable and GroupRow.Expanded then
          begin
            GroupRow.Expanded := False;
            Exit;
          end;
      end;
      Inc(I);
    end;
  end;
end;

procedure TmdoDBBandedTableView.DBGridCopy(Sender: TObject);
begin
  CopyToClipboard(False);
end;

procedure TmdoDBBandedTableView.DBGridGetCount(Sender: TObject);
begin
  IDEDesigner.ShowMessage('Кол-во записей - %d', [ViewData.RecordCount]);
end;

procedure TmdoDBBandedTableView.DBGridGetGridID(Sender: TObject);
begin
  ShowMessage(DBGrid.GridID);
end;

procedure TmdoDBBandedTableView.DBGridPrint(Sender: TObject);
var
  APrinter: TdxComponentPrinter;
  AGridLink: TdxGridReportLink;
begin
  APrinter := TdxComponentPrinter.Create(Self);
  AGridLink := TdxGridReportLink.Create(Self);
  try
    AGridLink.ComponentPrinter := APrinter;
    AGridLink.Component := Self.Control;
    AGridLink.Preview;
  finally
    FreeAndNil(AGridLink);
    FreeAndNil(APrinter);
  end;
end;

procedure TmdoDBBandedTableView.DBGridSelectAll(Sender: TObject);
begin
  DataController.SelectAll;
end;

procedure TmdoDBBandedTableView.DBGridSetFont(Sender: TObject);
var
  FontDialog: TFontDialog;
begin

  FontDialog := TFontDialog.Create(Application);
  try
    FontDialog.Font.Assign(DBGrid.Font);
    if FontDialog.Execute then
      DBGrid.Font.Assign(FontDialog.Font);
  finally
    FreeAndNil(FontDialog);
    if IDEDesigner.ActiveForm.CanFocus then
      IDEDesigner.ActiveForm.SetFocus; // workaround (frozen grid)
  end;
end;

procedure TmdoDBBandedTableView.DesignColumns(AGridID: string; ADataSource: TDataSource);
var
  ColumnInfos: TmdoDBGridColumnInfoList;
begin
  if AGridID = '' then
    Exit;
  ColumnInfos := TmdoDBGridColumnInfoList.Create;
  try
    ColumnInfos.FillList(AGridID);
    if ColumnInfos.Count > 0 then
    begin
      ColumnInfos.DataSource := ADataSource;
      ColumnInfos.KeyField := 'ID';
      DesignView(ColumnInfos);
    end;
  finally
    FreeAndNil(ColumnInfos);
  end;
end;

procedure TmdoDBBandedTableView.DesignHeader;
var
  PrevColumn, Column: TmdoDBGridColumn;
begin
  BeginUpdate;
  try
    Bands.Clear;
    if not BandHeaderVisible then
    begin
      Bands.Add;
      for Column in ColumnList do
        if not Column.KeyColumn then
          Column.BandID := 0;
    end
    else
    begin
      PrevColumn := nil;
      for Column in ColumnList do
        if not Column.KeyColumn then
          if Column.Visible then
          begin
            CreateColumnBands(PrevColumn, Column);
            PrevColumn := Column;
          end;
    end;
  finally
    EndUpdate;
  end;
end;

function TmdoDBBandedTableView.AddKeyColumn(AFieldName: string): TmdoDBGridColumn;
begin
  Result := AddColumn(nil);
  Result.DataBinding.FieldName := AFieldName;
  Result.KeyColumn := True;
end;

procedure TmdoDBBandedTableView.DesignView(AViewInfo: TObject);
var
  InfoList: TmdoDBGridColumnInfoList;
  Info: TmdoDBGridColumnInfo;
  Column: TmdoDBGridColumn;
  BandQty: Integer;
begin
  if AViewInfo is TmdoDBGridColumnInfoList then
  begin
    BandQty := MaxInt;
    InfoList := (AViewInfo as TmdoDBGridColumnInfoList);
    DataController.DataSource := InfoList.DataSource;
    DataController.MasterKeyFieldNames := InfoList.MasterKeyFieldNames;
    DataController.DetailKeyFieldNames := InfoList.DetailKeyFieldNames;

    if InfoList.KeyField <> '' then
    begin
      Info := nil;
      FKeyFieldName := InfoList.KeyField;
      {$IFDEF DEBUG}
      try
        Info := TmdoDBGridColumnInfo.Create;
        Info.FieldName := InfoList.KeyField;
        Info.Caption := 'Key Field|' + FKeyFieldName;
        Info.ReadOnly := True;
        Info.Visible := True;
        Info.Width := 65;
        AddColumn(Info);
      finally
        FreeAndNil(Info);
      end;
      {$ELSE}
        Column := AddKeyColumn(FKeyFieldName);
      {$ENDIF}
    end;

    for Info in InfoList do
    begin
      Column := AddColumn(Info);
      if BandQty > Column.BandCount then
        BandQty := Column.BandCount;
      AddFootSummary(Column, Info);
    end;

    BandHeaderVisible := BandQty > 0;
    DesignHeader;

    DBGrid.Load;
  end
  else
    raise Exception.Create(ClassName + '.DesignView: класс "' + AViewInfo.ClassName + '" не поддерживается для дизайна грида.');
end;

procedure TmdoDBBandedTableView.DoOnColumnPosChanged(Sender: TcxGridTableView; AColumn: TcxGridColumn);
var
  CurPos, NewPos: Integer;
begin
  CurPos := TmdoDBBandedTableView(Sender).ColumnList.IndexOf(TmdoDBGridColumn(AColumn));
  NewPos := AColumn.VisibleIndex;
  {$IFNDEF DEBUG}
  Inc(NewPos);
  {$ENDIF}
  TmdoDBBandedTableView(Sender).ColumnList.Move(CurPos, NewPos);
  DesignHeader;
end;


procedure TmdoDBBandedTableView.FillSelectedKeys(AList: TList<Int64>);
var
  I, KeyInd: Integer;
begin
  AList.Clear;
  KeyInd := KeyFieldIndex;
  if SelectedCount > 0 then
    for I := 0 to SelectedCount - 1 do
      AList.Add(SelectedCell[I, KeyInd])
  else
    AList.Add(Items[KeyInd].DataBinding.Field.Value);
end;

function TmdoDBBandedTableView.FindColumnByName(AName: string): TmdoDBGridColumn;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ItemCount - 1 do
    if SameText(AName, Items[I].DataBinding.FieldName) then
      Exit(Items[I]);
end;

function TmdoDBBandedTableView.FindColumnIndex(Value: TmdoDBGridColumn): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to ItemCount - 1 do
    if Items[I] = Value then
      Exit(I);
end;

procedure TmdoDBBandedTableView.DBGridSaveAs(Sender: TObject);
const
  Filter = 'Text files (*.txt)|*.txt|' +
    'Comma separated values (*.csv)|*.csv|'
    + 'Web Page (*.htm)|*.htm|' + {'Rich Text Format (*.rtf)|*.rtf|' + }
    'Microsoft Excel Workbook (*.xls)|*.xls';
var
  FileName: string;
  FileExt: string;
begin
  if ShowFileDialog(FileName, Filter, '.txt', 'Save As', '', True) then
  begin
    FileExt := ExtractFileExt(FileName);
    try
      IDEDesigner.Wait(str_idf_wait_prepare_data);
      if FileExt = '.txt' then
        ExportGridToText(FileName, DBGrid);

      if FileExt = '.htm' then
        ExportGridToHTML(FileName, DBGrid);

      if FileExt = '.xml' then
        ExportGridToXML(FileName, DBGrid);

      if FileExt = '.xls' then
        ExportGridToExcel(FileName, DBGrid);

      if FileExt = '.csv' then
        ExportGridToFile(FileName, 4, DBGrid, True, True, True, ',', '"', '"', '.csv');
    finally
      IDEDesigner.WaitFree;
    end;
  end;
end;

procedure TmdoDBBandedTableView.DBGridSaveSettings(Sender: TObject);
begin
  if Sender is TmdoViewActn then
    (Sender as TmdoViewActn).View.DBGrid.Save;
end;

function TmdoDBBandedTableView.GetViewDataClass: TcxCustomGridViewDataClass;
begin
  Result := TmdoGridViewData;
end;

function TmdoDBBandedTableView.GetViewInfoClass: TcxCustomGridViewInfoClass;
begin
  Result := inherited GetViewInfoClass;
end;

procedure TmdoDBBandedTableView.InnerCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if Assigned(FCellDblClick) then
    FCellDblClick(Sender, ACellViewInfo, AButton, AShift, AHandled);
end;

procedure TmdoDBBandedTableView.SaverDataLoad(AIni: TMemIniFile);
  function GetColumnIndex(AColumn: TmdoDBGridColumn): Integer;
  var
    Column: TmdoDBGridColumn;
  begin
    Result := -1;
    for Column in ColumnList do
    begin
      if Column.Visible then
        Inc(Result);
      if Column = AColumn then
        Break;
    end;
  end;
var
  Orders, Sorts,
  Columns: TStringList;
  Parser: TmdoStringParser;
  I, Index: Integer;
  Column: TmdoDBGridColumn;
  ColProps: string;
  ColIndex: string;
  ColVisible: Boolean;
  ColSortIndex: string;
  ColSortOrder: TdxSortOrder;
  CurPos: Integer;
begin
  OptionsView.GroupByBox := Boolean(AIni.ReadInteger(SectionCommon, IdentGroupBoxVisible, Byte(OptionsView.GroupByBox)));

  Columns := TStringList.Create;
  Sorts   := TStringList.Create;
  Orders  := TStringList.Create;
  Parser  := TmdoStringParser.Create;
  try
    AIni.ReadSection(SectionColumns, Columns);
    for I := 0 to Columns.Count - 1 do
    begin
      Index := ColumnIndexByName[Columns.Strings[I]];
      if Index <> -1 then
      begin
        Column := ColumnList.Items[Index];
        ColProps := AIni.ReadString(SectionColumns, Columns.Strings[I], '');
        if ColProps <> '' then
        begin
          Parser.DelimitedText := ColProps;
          ColIndex := Parser.Strings[0];
          ColVisible := Boolean(StrToInt(Parser.Strings[1]));
          ColSortIndex := Parser.Strings[2];
          ColSortOrder := TdxSortOrder(StrToInt(Parser.Strings[3]));
          Column.Visible := ColVisible;
          if Column.Visible then
            Orders.AddObject(ColIndex, Column);
          if ColSortIndex <> '-1' then
          begin
            Column.SortOrder := ColSortOrder;
            Sorts.AddObject(ColSortIndex, Column);
          end;
        end;
      end;
    end;
    // Порядок колонок
    Orders.Sort;
    for I := 0 to Orders.Count - 1 do
    begin
      Column := TmdoDBGridColumn(Orders.Objects[I]);
      CurPos := ColumnList.IndexOf(TmdoDBGridColumn(Column));
      if CurPos <> I then
        ColumnList.Move(CurPos, I);
    end;
    // Порядок сортировки
    if Sorts.Count > 0 then
    begin
      Sorts.Sort;
      for I := 0 to Sorts.Count - 1 do
        TmdoDBGridColumn(Sorts.Objects[I]).SortIndex := I;
    end;
  finally
    Parser.Free;
    Sorts.Free;
    Orders.Free;
    Columns.Free;
  end;
end;

procedure TmdoDBBandedTableView.SaverDataFill(AIni: TMemIniFile);
var
  I: Integer;
begin
  AIni.WriteInteger(SectionCommon, IdentGroupBoxVisible, Byte(OptionsView.GroupByBox));

  for I := 0 to ColumnList.Count - 1 do
    AIni.WriteString(
      SectionColumns,
      ColumnList.Items[I].DataBinding.FieldName,
      Format('%d;%d;%d;%d', [
        ColumnList.Items[I].VisibleIndex,
        Byte(ColumnList.Items[I].Visible),
        ColumnList.Items[I].SortIndex,
        Integer(ColumnList.Items[I].SortOrder)
        ]));

end;

{ TmdoDBGrid }

procedure TmdoDBGrid.AfterConstruction;
begin
  inherited AfterConstruction;

  if Owner is TWinControl then
    Parent := Owner as TWinControl;

  LookAndFeel := DefLookAndFeel;

  AddView;

  if Owner is TmdoForm then
    if Assigned(TmdoForm(Owner).Comp) and Assigned(TmdoForm(Owner).Comp.UIItem) then
      View.AddPopupItemsFromUIItems(TmdoForm(Owner).Comp.UIItem);

end;

procedure TmdoDBGrid.BeforeDestruction;
begin
  TmdoGridRootLevel(Levels).Clear;
  inherited BeforeDestruction;
end;

function TmdoDBGrid.GetDataSource: TDataSource;
begin
  Result := View.DataController.DataSource;
end;

function TmdoDBGrid.GetGridID: string;
var
  vParent: TWinControl;
begin
  Result := '';

  if Assigned(DataSource) and Assigned(DataSource.DataSet) then
    Result := DataSource.DataSet.AsIDF.DatasetID;

  if Name <> '' then
    Result := Result + '_' + Name;

  vParent := Self.Parent;
  while Assigned(vParent) do
  begin
    if vParent.InheritsFrom(TmdoForm) then
    begin
      Result := GUIDToString(FirstIID(vParent)) + '_' + Result;
      if  Assigned((vParent as TmdoForm).Comp) then
        Result := GUIDToString(FirstIID((vParent as TmdoForm).Comp)) + '_' + Result;
      Break;
    end;
    vParent := vParent.Parent;
  end;
  Result := ClassName + '_' + Result;
end;

function TmdoDBGrid.GetGroupBoxVisible: Boolean;
begin
  Result := View.GroupBoxVisible;
end;

function TmdoDBGrid.GetLevelsClass: TcxGridLevelClass;
begin
  Result := TmdoGridRootLevel;
end;

function TmdoDBGrid.GetView: TmdoDBBandedTableView;
begin
  Result := TmdoDBBandedTableView(ActiveView);
end;

procedure TmdoDBGrid.SaverDataLoad(AIni: TMemIniFile);
begin
  //Font
  Font.Name    := AIni.ReadString(SectionFont,  IdentName,   Font.Name);
  Font.Height  := AIni.ReadInteger(SectionFont, IdentHeight, Font.Height);
  Font.Charset := TFontCharset(AIni.ReadInteger(SectionFont, IdentCharset, Integer(Font.Charset)));
  Font.Color   := TColor(AIni.ReadInteger(SectionFont, IdentColor, Integer(Font.Color)));
  SetPropValue(Font, 'Style', AIni.ReadString(SectionFont, IdentStyle, GetPropValue(Font, 'Style')));
  // View
  View.SaverDataLoad(AIni);
  View.DesignHeader;
end;

procedure TmdoDBGrid.SaverDataFill(AIni: TMemIniFile);
begin
  //Font
  AIni.WriteString(SectionFont,  IdentName,    Font.Name);
  AIni.WriteInteger(SectionFont, IdentHeight,  Font.Height);
  AIni.WriteInteger(SectionFont, IdentCharset, Integer(Font.Charset));
  AIni.WriteInteger(SectionFont, IdentColor,   Integer(Font.Color));
  AIni.WriteString(SectionFont,  IdentStyle,   GetPropValue(Font, 'Style'));
  // View
  View.SaverDataFill(AIni);
end;

procedure TmdoDBGrid.Load;
var
  Saver: TmdoControlSaver;
begin
  Saver := TmdoControlSaver.Create;
  try
    if Saver.Load(GridID) then
      SaverDataLoad(Saver.Ini);
  finally
    FreeAndNil(Saver);
  end;
end;

procedure TmdoDBGrid.Save;
var
  Saver: TmdoControlSaver;
begin
  Saver := TmdoControlSaver.Create;
  try
    SaverDataFill(Saver.Ini);
    Saver.Save(GridID);
  finally
    FreeAndNil(Saver);
  end;
end;

procedure TmdoDBGrid.SetGroupBoxVisible(Value: Boolean);
begin
  View.GroupBoxVisible := Value;
end;

procedure TmdoDBGrid.SetView(AView: TmdoDBBandedTableView);
begin
  if Assigned(AView) then
    if ActiveLevel <> TcxGridLevel(AView.Level) then
      ActiveLevel := TcxGridLevel(AView.Level);
end;

function TmdoDBGrid.GetBandHeaderVisible: Boolean;
begin
  Result := View.BandHeaderVisible;
end;

procedure TmdoDBGrid.SetBandHeaderVisible(Value: Boolean);
begin
  View.BandHeaderVisible := Value;
end;

function TmdoDBGrid.GetColumnHeaderVisible: Boolean;
begin
  Result := View.ColumnHeaderVisible;
end;

procedure TmdoDBGrid.SetColumnHeaderVisible(Value: Boolean);
begin
  View.ColumnHeaderVisible := not Value;
end;

procedure TmdoDBGrid.DesignColumns(AGridID: string; ADataSource: TDataSource);
begin
  View.DesignColumns(AGridID, ADataSource);
end;

procedure TmdoDBGrid.DesignView(AViewInfo: TObject);
begin
  View.DesignView(AViewInfo);
end;

function TmdoDBGrid.AddView(AParentView: TObject = nil): TmdoDBBandedTableView;
var
  Level: TcxGridLevel;
begin
  if Assigned(AParentView) and (AParentView is TmdoDBBandedTableView) then
    Level := TcxGridLevel((AParentView as TmdoDBBandedTableView).Level)
  else
    Level := Levels;
  Level := Level.Add;
  Level.GridView := TmdoDBBandedTableView.Create(Self);
  if not Assigned(ActiveLevel) then
    ActiveLevel := Level;
  if Levels.Count > 1 then
    RootLevelOptions.DetailTabsPosition := dtpTop
  else
    RootLevelOptions.DetailTabsPosition := dtpNone;
  Result := TmdoDBBandedTableView(Level.GridView);
end;

function TmdoDBGrid.FindColumnByName(AFieldName: string): TmdoDBGridColumn;
var
  Column: TmdoDBGridColumn;
begin
  Result := nil;
  AFieldName := UpperCase(AFieldName);
  for Column in View.ColumnList do
    if UpperCase(Column.DataBinding.FieldName) = AFieldName then
      Exit(Column);
  if not Assigned(Result) then
    raise Exception.Create('Column for field "' + AFieldName + '" not found.');
end;

procedure TmdoDBGrid.FocusedViewChanged(APrevFocusedView, AFocusedView: TcxCustomGridView);
begin
  inherited FocusedViewChanged(APrevFocusedView, AFocusedView);
  if Assigned(FFocusedViewChanged) then
    FFocusedViewChanged(Self, APrevFocusedView, AFocusedView);
end;

{ TmdoListView }

procedure TmdoListView.AfterConstruction;
begin
  inherited AfterConstruction;
  if Owner is TWinControl then
    Parent := Owner as TWinControl;
  SetObjectLookAndFeel(Self);
end;

{  TmdoLayoutItem }

procedure TmdoLayoutItem.AfterConstruction;
begin
  inherited AfterConstruction;
end;

function TmdoLayoutItem.GetCaption: string;
begin
  Result := CaptionOptions.Text;
end;

procedure TmdoLayoutItem.SetCaption(AValue: string);
begin
  CaptionOptions.Text := AValue;
  CaptionOptions.Visible := AValue <> '';
end;

procedure TmdoLayoutItem.SetAlign(Value: TAlign);
begin
  case Value of
    alTop: begin
      AlignHorz := ahParentManaged;
      AlignVert := avTop;
    end;
    alBottom: begin
      AlignHorz := ahParentManaged;
      AlignVert := avBottom;
    end;
    alLeft: begin;
      AlignHorz := ahLeft;
      AlignVert := avParentManaged;
    end;
    alRight: begin;
      AlignHorz := ahRight;
      AlignVert := avParentManaged;
    end;
    alClient: begin;
      AlignHorz := ahClient;
      AlignVert := avClient;
    end;
  end;
end;

function TmdoLayoutItem.GetControlAlign: TmdoLayoutItemControlAlignHorz;
begin
  case ControlOptions.AlignHorz of
    ahLeft:   Result := caLeft;
    ahRight:  Result := caRight;
    ahCenter: Result := caCenter;
  else
    Result := caClient;
  end;
end;

procedure TmdoLayoutItem.SetControlAlign(Value: TmdoLayoutItemControlAlignHorz);
begin
  case Value of
    caLeft:   ControlOptions.AlignHorz := ahLeft;
    caRight:  ControlOptions.AlignHorz := ahRight;
    caCenter: ControlOptions.AlignHorz := ahCenter;
    caClient: ControlOptions.AlignHorz := ahClient;
  end;
end;

{ TmdoLayoutControlContainer }

function TmdoLayoutControlContainer.GetDefaultGroupClass: TdxLayoutGroupClass;
begin
  Result := TmdoLayoutGroup;
end;

{ TmdoLayoutControlViewInfo }

function TmdoLayoutControlViewInfo.GetContentBounds: TRect;
begin
  Result := inherited GetContentBounds;
end;

{ TmdoLayoutGroup }

procedure TmdoLayoutGroup.AfterConstruction;
begin
  inherited AfterConstruction;
end;

procedure TmdoLayoutGroup.BeforeDestruction;
begin
  inherited BeforeDestruction;
end;

function TmdoLayoutGroup.GetCaption: string;
begin
  Result := CaptionOptions.Text;
end;

procedure TmdoLayoutGroup.SetCaption(AValue: string);
begin
  CaptionOptions.Text := AValue;
  CaptionOptions.Visible := AValue <> '';
end;

function TmdoLayoutGroup.AddGroup: TmdoLayoutGroup;
begin
  Result := TmdoLayoutGroup(CreateGroup(TmdoLayoutGroup));
  Result.ShowBorder := True;
  Result.CaptionOptions.Text := '';
end;

function TmdoLayoutGroup.AddItem(AAlign: TAlign = alNone): TmdoLayoutItem;
begin
  Result := TmdoLayoutItem(CreateItem(TmdoLayoutItem));
  Result.SetAlign(AAlign);
  Result.CaptionOptions.Text := '';
  Result.CaptionOptions.Visible := False;
end;

function TmdoLayoutGroup.AddControl(AControl: TControl; AAlign: TAlign = alNone): TmdoLayoutItem;
begin
  Result := AddItem(AAlign);
  Result.Control := AControl;
end;

procedure TmdoLayoutGroup.SetAlign(Value: TAlign);
begin
  case Value of
    alTop: begin
      AlignHorz := ahParentManaged;
      AlignVert := avTop;
    end;
    alBottom: begin
      AlignHorz := ahParentManaged;
      AlignVert := avBottom;
    end;
    alLeft: begin;
      AlignHorz := ahLeft;
      AlignVert := avParentManaged;
    end;
    alRight: begin;
      AlignHorz := ahRight;
      AlignVert := avParentManaged;
    end;
    alClient: begin;
      AlignHorz := ahClient;
      AlignVert := avClient;
    end;
  end;
end;

function TmdoLayoutGroup.GetmdoItem(Index: Integer): TmdoLayoutItem;
begin
  Result := TmdoLayoutItem(Items[Index]);
end;

function TmdoLayoutGroup.GetFirstItem: TmdoLayoutItem;
begin
  if Count = 0 then
    AddItem(alClient);
  Result := mdoItem[0];
end;

function TmdoLayoutGroup.GetMdoLayoutDirection: TmdoLayoutDirection;
begin
  Result := TmdoLayoutDirection(inherited LayoutDirection);
end;

procedure TmdoLayoutGroup.SetMdoLayoutDirection(Value: TmdoLayoutDirection);
begin
  inherited LayoutDirection := TdxLayoutDirection(Value);
end;

{ TmdoLayoutControl }

procedure TmdoLayoutControl.AfterConstruction;
begin
  inherited AfterConstruction;
  if Assigned(Owner) and (Owner is TWinControl) then
    Parent := Owner as TWinControl;
  LookAndFeel := DefLayoutLookAndFeel;
  Root.AlignHorz := ahClient;
  Root.AlignVert := avClient;
end;

procedure TmdoLayoutControl.BeforeDestruction;
begin
  inherited BeforeDestruction;
end;

procedure TmdoLayoutControl.UpdateRootDirection;
begin
  case Align of
    alTop, alBottom: Root.LayoutDirection := ldHorizontal;
    alLeft, alRight: Root.LayoutDirection := ldVertical;
  end;
end;

function TmdoLayoutControl.GetContainerClass: TdxLayoutControlContainerClass;
begin
  Result := TmdoLayoutControlContainer;
end;

function TmdoLayoutControl.GetViewInfoClass: TdxLayoutControlViewInfoClass;
begin
  Result := TdxLayoutControlViewInfo;
end;

function TmdoLayoutControl.AddGroup: TmdoLayoutGroup;
begin
  Result := Root.AddGroup;
  Result.ShowBorder := True;
end;

function TmdoLayoutControl.GetRoot: TmdoLayoutGroup;
begin
  Result := TmdoLayoutGroup(Container.Root);
end;

{ TmdoComboBox }

procedure TmdoComboBox.AfterConstruction;
begin
  inherited AfterConstruction;
  Properties.DropDownListStyle := lsFixedList;
  Properties.ImmediatePost := True;
  Properties.DropDownSizeable := True;
end;

function TmdoComboBox.GetItems: TStrings;
begin
  Result := Properties.Items;
end;

function TmdoComboBox.GetValue: Integer;
begin
  Result := -1;
  if ItemIndex <> -1 then
    Result := Integer(Properties.Items.Objects[ItemIndex]);
end;

procedure TmdoComboBox.SetValue(AValue: Integer);
var
  I: Integer;
  Ind: Integer;
begin
  Ind := -1;
  for I := 0 to Properties.Items.Count - 1 do
    if Integer(Properties.Items.Objects[I]) = AValue then
    begin
      Ind := I;
      Break;
    end;
  ItemIndex := Ind;
end;

{ TmdoParamPanel }

procedure TmdoParamPanel.AfterConstruction;
begin
  inherited AfterConstruction;
  Align := alTop;
  Root.AlignVert := avTop;
  AutoSize := True;
  FList := TObjectList<TControl>.Create(False);
  SetReplaceOnResize(True);
end;

procedure TmdoParamPanel.BeforeDestruction;
begin
  FreeAndNil(FList);
  SetReplaceOnResize(False);
  inherited BeforeDestruction;
end;

procedure TmdoParamPanel.OnBtnClick(Sender: TObject);
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Sender);
end;

procedure TmdoParamPanel.OnPanelResize(Sender: TObject);
begin
end;

procedure TmdoParamPanel.OnParamChange(Sender: TField);
begin
  if Assigned(FOnParamFieldChange) then
    FOnParamFieldChange(Sender);
end;

function TmdoParamPanel.GetPanelEnabled: Boolean;
begin
  Result := inherited Enabled;
end;

function TmdoParamPanel.GetReplaceOnResize: Boolean;
begin
  Result := Assigned(OnResize);
end;

procedure TmdoParamPanel.SetPanelEnabled(Value: Boolean);
var
  Control: TControl;
  DataBinding: TObject;
  DataSource: TDataSource;
  FieldName: string;
begin
  for Control in FList do
  begin
    DataBinding := GetObjectProp(Control, 'DataBinding');
    if Assigned(DataBinding) then
    begin
      if IsPublishedProp(DataBinding, 'DataSource') and IsPublishedProp(DataBinding, 'DataField') then
      begin
        DataSource := GetObjectProp(DataBinding, 'DataSource') as TDataSource;
        if DataSource.DataSet.Active then
        begin
          FieldName  := GetStrProp(DataBinding, 'DataField');
          DataSource.DataSet.FieldByName(FieldName).ReadOnly := not Value;
        end;
      end;
    end;
  end;
  Root.Enabled := Value;
  FBtn.Enabled := Value;
  inherited Enabled := Value;
end;

procedure TmdoParamPanel.SetReplaceOnResize(AValue: Boolean);
begin
  if AValue then
    OnResize := OnPanelResize
  else
    OnResize := nil;
end;

procedure TmdoParamPanel.PostEditValue;
var
  Control: TControl;
begin
  for Control in FList do
    if Control is TcxCustomEdit then
      (Control as TcxCustomEdit).PostEditValue;
end;

procedure TmdoParamPanel.DesignControls(AGridID: string; ADataSource: TDataSource; ABtnCkick: TNotifyEvent; AParamFieldChange: TFieldNotifyEvent);
var
  ControlInfos: TmdoControlInfoList;
begin
  if AGridID = '' then
    Exit;

  ControlInfos := TmdoControlInfoList.Create;
  try
    ControlInfos.FillList(AGridID);
    ControlInfos.DataSource := ADataSource;
    ControlInfos.ButtonClick := ABtnCkick;
    ControlInfos.FieldChange := AParamFieldChange;
    DesignView(ControlInfos);
  finally
    FreeAndNil(ControlInfos);
  end;
end;

procedure TmdoParamPanel.DesignView(AViewInfo: TObject);
var
  InfoList: TmdoControlInfoList;
  Info: TmdoControlInfo;
begin
  Root.LayoutDirection := ldHorizontal;

  if AViewInfo is TmdoControlInfoList then
  begin
    InfoList := AViewInfo as TmdoControlInfoList;
    DataSource := InfoList.DataSource;

    FOnParamFieldChange := InfoList.FieldChange;
    for Info in InfoList do
    begin
      AddControl(Info);
      DataSource.DataSet.FieldByName(Info.FieldName).OnChange := OnParamChange;
    end;

    AddButton(InfoList);
  end
  else
    raise Exception.Create('Error Message');

end;

function TmdoParamPanel.AddControl(AControlInfo: TmdoControlInfo): TControl;
var
  Control: TControl;
  Method: TMethod;
  KeyEvent: TKeyEvent;
  LayItem: TmdoLayoutItem;
begin
  Control := AControlInfo.CreateControl(Self.Owner, DataSource);

  if IsPublishedProp(Control, 'OnKeyDown') then
  begin
    KeyEvent := Self.ControlKeyDown;
    Method.Data := Self;
    Method.Code := @KeyEvent;
    SetMethodProp(Control, 'OnKeyDown', Method);
  end;

  LayItem := Root.AddItem(alLeft);
  LayItem.Control := Control;

  LayItem.Caption := IDEDesigner.FindStr(AControlInfo.Caption);
  LayItem.CaptionOptions.Layout := clTop;

  FList.Add(Control);
  Result := Control;
end;

function TmdoParamPanel.AddButton(AControlInfoList: TmdoControlInfoList): TmdoButton;
begin
  Result := AddButton(AControlInfoList.ButtonClick);
end;

function TmdoParamPanel.AddButton(AButtonClick: TNotifyEvent): TmdoButton;
begin
  FOnButtonClick := AButtonClick;

  FBtn := TmdoButton.Create(Self);
  FBtn.Caption := IDEDesigner.FindStr('SSearch');
  FBtn.OptionsImage.Images := IDEDesigner.Images;
  FBtn.OptionsImage.ImageIndex := IDEDesigner.FindImg('mdo_search.bmp');
  FBtn.OnClick := OnBtnClick;

  Root.AddControl(FBtn, alLeft).AlignVert := avTop;
  Result := FBtn;
end;

procedure TmdoParamPanel.ControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_RETURN) and Assigned(FBtn) then
    FBtn.Click;
end;

{ TmdoDBCheckBox }

procedure TmdoDBCheckBox.AfterConstruction;
begin
  inherited AfterConstruction;
  Caption := '';
  AutoSize := True;
  Properties.ValueChecked   := 1;
  Properties.ValueUnchecked := 0;
  Properties.ValueGrayed    := NULL;
  Properties.Alignment := taLeftJustify;
end;

class function TmdoDBCheckBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBCheckBoxProperties;
end;

{ TmdoDBStringCheckEdit }

procedure TmdoDBStringCheckEdit.AfterConstruction;
begin
  inherited AfterConstruction;
  if Owner is TWinControl then
    Parent := Owner as TWinControl;
  FCheckBox := TmdoDBCheckBox.Create(Owner);
  FCheckBox.Parent := Self;
  FCheckBox.Style.LookAndFeel := DefLookAndFeel;
  FCheckBox.Properties.OnChange := CheckChange;
  Properties.Alignment.Horz := taLeftJustify;
end;

procedure TmdoDBStringCheckEdit.BeforeDestruction;
begin
  FreeAndNil(FCheckBox);
  inherited BeforeDestruction;
end;

procedure TmdoDBStringCheckEdit.CheckChange(Sender: TObject);
begin
  UpdateDisplayValue;
  Properties.ReadOnly := not FCheckBox.Checked;
end;

procedure TmdoDBStringCheckEdit.Resize;
begin
  inherited Resize;;
  FCheckBox.Height := ClientHeight;
  FCheckBox.Width  := ClientHeight - 2;
  FCheckBox.Top := 0;
  FCheckBox.Left := ClientWidth - FCheckBox.Width;
end;

procedure TmdoDBStringCheckEdit.SetControlInfo(Value: TmdoControlInfo);
begin
  FCheckBox.DataBinding.DataSource := DataBinding.DataSource;
  FCheckBox.DataBinding.DataField := Value.CheckFieldName;
end;

{ TmdoDBComboBox }

procedure TmdoDBLookupComboBox.AfterConstruction;
begin
  FMasterSource := nil;
  inherited AfterConstruction;
  Properties.DropDownListStyle := lsFixedList;
  Properties.DropDownSizeable := True;
  Properties.ImmediatePost := True;
  Properties.ListOptions.ShowHeader := False;
end;

procedure TmdoDBLookupComboBox.BeforeDestruction;
begin
  if Assigned(Properties.ListSource) then
  begin
    if Assigned(Properties.ListSource.DataSet) then
    begin
      Properties.ListSource.DataSet.Free;
      Properties.ListSource.DataSet := nil;
    end;
    Properties.ListSource.Free;
    Properties.ListSource := nil;
  end;
  inherited BeforeDestruction;
end;

procedure TmdoDBLookupComboBox.SetControlInfo(Value: TmdoControlInfo);
begin
  FNameFieldName := Value.NameFieldName;

  Properties.ListSource := TDataSource.Create(Self.Owner);
  Properties.ListSource.DataSet := NewDS(MDO_DB_IID, [Value.LookupSQL,
    '', sql_mdo_empty_select, sql_mdo_empty_select, sql_mdo_empty_select],
    FMasterSource);
  Properties.ListSource.DataSet.Open;

  Properties.KeyFieldNames := Value.LookupKeyFieldName;
  Properties.ListFieldNames := Value.LookupListFieldName;

  Properties.OnChange := ChangeValue;
end;

procedure TmdoDBLookupComboBox.ChangeValue(Sender: TObject);
begin
  if (DataBinding.DataSource.DataSet.State in dsWriteModes) and (FNameFieldName <> '') then
    DataBinding.DataSource.DataSet.FieldByName(FNameFieldName).AsVariant := Properties.ListColumns[0].Field.AsVariant;
end;

function TmdoDBLookupComboBox.GetListSource: TDataSource;
begin
  Result := Properties.ListSource;
end;

class function TmdoDBLookupComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBLookupComboBoxProperties;
end;

{ TmdoDBComboBox }

function TmdoDBComboBox.GetListItems: TStrings;
begin
  Result := Properties.Items;
end;

class function TmdoDBComboBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBComboBoxProperties;
end;

procedure TmdoDBComboBox.UpdateListStyle;
begin
  if Properties.Items.Count > 0 then
    Properties.DropDownListStyle := lsFixedList
  else
    Properties.DropDownListStyle := lsEditList;
end;

{ TmdoDBLookupBox }

procedure TmdoDBLookupBox.AddParamFieldDefs(AKey: string; AValue: Variant);
begin
  FParamFieldDefs.Add(AKey, AValue);
end;

procedure TmdoDBLookupBox.AfterConstruction;
begin
  inherited AfterConstruction;
  FParamFieldDefs := TDictionary<string, Variant>.Create;
  FLookupForm := nil;
  FKeyField        := '';
  FLookupFormIID   := '';
  FLookupKeyField  := '';
  FLookupListField := '';
  FLookupSQLText   := '';
  FLookupSQLName   := '';
  FLookupSQLMaster := '';
  ReadOnly := True;
  Properties.Buttons[0].Enabled := True;
end;

procedure TmdoDBLookupBox.BeforeDestruction;
begin
  if Assigned(FLookupForm) then
    FreeAndNil(FLookupForm);
  FParamFieldDefs.Free;
  inherited BeforeDestruction;
end;

procedure TmdoDBLookupBox.SetControlInfo(Value: TmdoControlInfo);
begin
  DataBinding.DataField := Value.NameFieldName;
  FKeyField        := Value.FieldName;
  FCaption         := IDEDesigner.FindStr(Value.Caption);
  FLookupFormIID   := Value.LookupIID;
  FLookupKeyField  := Value.LookupKeyFieldName;
  FLookupListField := Value.LookupListFieldName;
  FLookupSQLText   := Value.LookupSQL;
  FLookupSQLName   := Value.LookupSQLName;
  FLookupSQLMaster := Value.LookupSQLMaster;
  Properties.OnButtonClick := ButtonClick;
  OnDblClick := DoubleClick;
end;

function TmdoDBLookupBox.GetReadOnly: Boolean;
begin
  Result := Properties.ReadOnly;
end;

procedure TmdoDBLookupBox.SetReadOnly(Value: Boolean);
begin
  Properties.ReadOnly := Value;
end;

procedure TmdoDBLookupBox.ButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  ShowLookupForm;
end;

procedure TmdoDBLookupBox.DoubleClick(Sender: TObject);
begin
  ShowLookupForm;
end;

procedure TmdoDBLookupBox.ShowLookupForm;
var
  ParamSet: TDataSet;
  ParamVal: TPair<string, Variant>;
begin
  CreateLookupForm;

  if LookupForm.DataSet.Active then
    LookupForm.DataSet.Close;

  // Устанавливаем мастер, если нужно
  if IsPublishedProp(LookupForm, 'ParamSet') then
  begin
    ParamSet := TDataSet(GetObjectProp(LookupForm, 'ParamSet'));
    if Assigned(ParamSet) then
    begin
      if not (ParamSet.State in dsWriteModes) then
        ParamSet.Edit;
      ParamSet.FieldByName('NAME').AsString := DataBinding.Field.AsString;
      for ParamVal in FParamFieldDefs do
        ParamSet.FieldByName(ParamVal.Key).AsVariant := ParamVal.Value;
      ParamSet.Post;
    end;
  end;

  if (FLookupSQLMaster <> '') and (DataBinding.DataSource.DataSet.AsIDF.DatasetID = FLookupSQLMaster) then
    LookupForm.DataSet.AsIDF.DataSource := DataBinding.DataSource;

  LookupForm.DataSet.Open;

  if LookupForm.ShowModal = mrOK then
  begin
    if DataBinding.DataSource.DataSet.State in dsWriteModes then
    begin
      DataBinding.DataSource.DataSet.FieldByName(FKeyField).AsVariant := LookupForm.DataSet.FieldByName(FLookupKeyField).AsVariant;
      DataBinding.DataSource.DataSet.FieldByName(DataBinding.DataField).AsVariant := LookupForm.DataSet.FieldByName(FLookupListField).AsVariant;
    end;
  end;
end;

function TmdoDBLookupBox.GetInnerEditClass: TControlClass;
begin
  Result := inherited GetInnerEditClass;
end;

class function TmdoDBLookupBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBLookupBoxProperties;
end;

procedure TmdoDBLookupBox.CreateLookupForm;
var
  ComponentClass: TComponentClass;
  ILookupForm: ImdoLookupForm;
  FormWidth,
  FormHeight: Integer;
  Monitor: TMonitor;
begin
  if not  Assigned(LookupForm) then
  begin
    ComponentClass := nil;

//    if FLookupFormIID <> '' then
//      ComponentClass := IDEDesigner.FindClass(StringToGUID(FLookupFormIID));

    if not Assigned(ComponentClass) then
      ComponentClass := TLookupForm;

    if not ComponentClass.InheritsFrom(TmdoForm) then
      raise Exception.Create('Клас формы должен наследоваться от TmdoForm.');

    FLookupForm := TmdoFormClass(ComponentClass).CreateNew(nil);
    FLookupForm.Caption := FCaption;

    // Size
    if Owner is TmdoForm then
    begin
      FormWidth  := (Owner as TmdoForm).Width;
      Monitor := (Owner as TmdoForm).Monitor;
    end
    else
    begin
      FormWidth  := IDEDesigner.ActiveForm.Width div 2;
      Monitor := IDEDesigner.ActiveForm.Monitor;
    end;

    if Monitor.WorkareaRect.Bottom - Monitor.WorkareaRect.Top < 738 then
      FormHeight := ((Monitor.WorkareaRect.Bottom - Monitor.WorkareaRect.Top) * 2) div 3
    else
      FormHeight := (Monitor.WorkareaRect.Bottom - Monitor.WorkareaRect.Top) div 2;

    FLookupForm.Width := FormWidth;
    FLookupForm.Height := FormHeight;

    // Position
    FLookupForm.Position := poScreenCenter;

    // Design
    if Supports(FLookupForm, ImdoLookupForm, ILookupForm) then
    begin
      ILookupForm.MetaSQL := FLookupSQLText;
      ILookupForm.GridName := FLookupSQLName;
      ILookupForm.DesignView;
    end;
  end;
end;

{ TmdoDBLookupBox.TLookupForm }

procedure TmdoDBLookupBox.TLookupForm.BeforeDestruction;
begin
  if Assigned(FParamSource) then
  begin
    FParamSource.DataSet := nil;
    FParamSource.Free;
  end;
  if Assigned(FParamSet) then
    FParamSet.Free;
  inherited BeforeDestruction;
end;

procedure TmdoDBLookupBox.TLookupForm.DesignView;
begin
  if FMetaSQL = '' then
    raise Exception.Create('TmdoDBLookupBox.TLookupForm.MetaSQL is not assigned.');
  FProcQuery := ExecRead(MDO_DB_IID, FMetaSQL);
  FDataID := FProcQuery.FieldByName('DATA_ID').AsString;

  DesignData;
  DesignControls;
end;

procedure TmdoDBLookupBox.TLookupForm.DoSearchClick(Sender: TObject);
begin
  if Assigned(FParamPanel) then
    FParamPanel.PostEditValue;

  if DataSet.Modified then
    DataSet.Post;

  DataSet.Close;
  DataSet.Open;

  FGrid.View.DataController.CheckFocusedSelected;
end;

function TmdoDBLookupBox.TLookupForm.FieldExists(AQuery: IQueryProvider; AFieldName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  AFieldName := UpperCase(AFieldName);
  for I := 0 to AQuery.FieldCount - 1 do
    if UpperCase(AQuery.Fields[I].Name) = AFieldName then
      Exit(True);
end;

procedure TmdoDBLookupBox.TLookupForm.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (FGrid.View.Site = ActiveControl) and (Key = VK_RETURN) then
    FbtnOK.Click;
  if (Key = VK_ESCAPE) then
    FbtnCansel.Click;
end;

procedure TmdoDBLookupBox.TLookupForm.DesignData;
begin
  FParamSet := nil;
  FParamSource := nil;

  if FProcQuery = nil then
    Exit;

  if FieldExists(FProcQuery, 'PARAM_SEL') then
  begin
    FParamSet := AddDataSet(FProcQuery, 'PARAM', nil, False);
    FParamSource := TDataSource.Create(Self);
    FParamSource.DataSet := FParamSet;
    FParamSet.Open;
  end;

  DataSet := AddDataSet(FProcQuery, 'DATA', FParamSource, False);
  DataSource := TDataSource.Create(Self);
  DataSource.DataSet := DataSet;
end;

procedure TmdoDBLookupBox.TLookupForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style - WS_MINIMIZEBOX - WS_MAXIMIZEBOX;
end;

procedure TmdoDBLookupBox.TLookupForm.DesignControls;

  function NewButton(ACaption: string; AModalResult: TModalResult): TmdoButton;
  begin
    Result := TmdoButton.Create(Self);
    Result.Parent := Self;
    Result.Caption := IDEDesigner.FindStr(ACaption);
    Result.ModalResult := AModalResult;
  end;

var
  ParamInfos: TmdoControlInfoList;
  ButtonLayoutControl: TmdoLayoutControl;
begin
  if FProcQuery = nil then
    Exit;

  // ParamPanel

  if FieldExists(FProcQuery, 'PARAM_ID') then
  begin
    FParamPanel := TmdoParamPanel.Create(Self);
    FParamPanel.Parent := Self;
    FParamPanel.Align := alTop;

    ParamInfos := TmdoControlInfoList.Create;
    try
      ParamInfos.FillList(FProcQuery.FieldByName('PARAM_ID').AsString);
      ParamInfos.ButtonClick := DoSearchClick;
      ParamInfos.DataSource := FParamSource;
      FParamPanel.DesignView(ParamInfos);
    finally
      ParamInfos.Free;
    end;
  end;

  // Data Grid

  FGrid := TmdoDBGrid.Create(Self);
  FGrid.Parent := Self;
  FGrid.Align := alClient;
  FGrid.GroupBoxVisible := False;
  FGrid.DesignColumns(FDataID, DataSource);
  FGrid.View.CellDblClick := EditOnDblClick;

  // Buttons

  FbtnOK     := NewButton('str_idf_db_post',   mrOk);
  FbtnCansel := NewButton('str_idf_db_cancel', mrCancel);

  ButtonLayoutControl := TmdoLayoutControl.Create(Self);

  ButtonLayoutControl.Parent := Self;
  ButtonLayoutControl.Align := alBottom;
  ButtonLayoutControl.UpdateRootDirection;
  ButtonLayoutControl.Root.SetAlign(alTop);

  ButtonLayoutControl.Root.AddControl(FbtnOK,     alRight);
  ButtonLayoutControl.Root.AddControl(FbtnCansel, alRight);

  ButtonLayoutControl.Container.Control.HandleNeeded;
  ButtonLayoutControl.Height := ButtonLayoutControl.ViewInfo.ContentHeight;

  // Form

  OnKeyUp := FormKeyUp;
  KeyPreview := True;

end;

function TmdoDBLookupBox.TLookupForm.GetGridName: string;
begin
  Result := FGridName;
end;

function TmdoDBLookupBox.TLookupForm.GetMetaSQL: string;
begin
  Result := FMetaSQL;
end;

procedure TmdoDBLookupBox.TLookupForm.EditOnDblClick(Sender: TObject; ACellViewInfo: TObject; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  FbtnOK.Click;
end;

procedure TmdoDBLookupBox.TLookupForm.SetGridName(Value: string);
begin
  FGridName := Value;
end;

procedure TmdoDBLookupBox.TLookupForm.SetMetaSQL(Value: string);
begin
  FMetaSQL := Value;
end;

{ TmdoGridDBDataController }

function TmdoGridDBDataController.GetDataProviderClass: TcxCustomDataProviderClass;
begin
  Result := TmdoDBDataProvider;
end;

function TmdoGridDBDataController.GetProvider: TmdoDBDataProvider;
begin
  Result := inherited Provider as TmdoDBDataProvider;
end;

{ TmdoPopupMenu }

function TmdoPopupMenu.InternalInsertItem(AItem: TIDEMenuItemCustom; AIndex: Integer): Integer;
begin
  if AIndex = -1 then
    AIndex := Items.Count;
  Items.Insert(AIndex, AItem);
  Result := AIndex;
end;

function TmdoPopupMenu.AddSubmenuItem(AAction: TIDEActn; AIndex: Integer = -1): Integer;
var
  vNewItem: TIDEMenuItemSubmenu;
begin
  vNewItem := TIDEMenuItemSubmenu.Create(Self);
  try
    vNewItem.OnPopup := AAction.OnDropDown;
    vNewItem.DisplayMode := nbdmImageAndText;
    vNewItem.DropdownCombo := AAction.IsExecutable;
    if not AAction.IsExecutable then
      vNewItem.Options := vNewItem.Options + [tboDropdownArrow];

    vNewItem.Action := AAction;

    Result := InternalInsertItem(vNewItem,  AIndex);
  except
    vNewItem.Free;
    raise;
  end;
end;

procedure TmdoPopupMenu.AppendSeparator;
var
  vNewItem: TIDEMenuItemSeparator;
begin
  vNewItem := TIDEMenuItemSeparator.Create(Self);
  try
    Items.Add(vNewItem);
  except
    vNewItem.Free;
    raise;
  end;
end;

function TmdoPopupMenu.AddMenuItem(AAction: TIDEActn; AIndex: Integer = -1): Integer;
var
  vNewItem: TIDEMenuItem;
begin
  vNewItem := TIDEMenuItem.Create(Self);
  try
    vNewItem.DisplayMode := nbdmImageAndText;
    vNewItem.Images := IDEDesigner.Images;

    vNewItem.Action := AAction;

    Result := InternalInsertItem(vNewItem,  AIndex);
  except
    vNewItem.Free;
    raise;
  end;
end;

function TmdoPopupMenu.AddSeparator(AIndex: Integer = -1): Integer;
var
  vNewItem: TIDEMenuItemSeparator;
begin
  vNewItem := TIDEMenuItemSeparator.Create(Self);
  try
    Result := InternalInsertItem(vNewItem,  AIndex);
  except
    vNewItem.Free;
    raise;
  end;
end;

{ TmdoButton }

procedure TmdoButton.AfterConstruction;
begin
  inherited AfterConstruction;
  LookAndFeel.SkinName := DefLookAndFeelSkinName;
end;

{ TmdoDBLookupComboBoxProperties }

class function TmdoDBLookupComboBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBLookupComboBoxViewInfo;
end;

{ TmdoDBLookupComboBoxViewInfo }

procedure TmdoDBLookupComboBoxViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBCheckBoxProperties }

class function TmdoDBCheckBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBCheckBoxViewInfo;
end;

{ TmdoDBCheckBoxViewInfo }

procedure TmdoDBCheckBoxViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBLabel }

class function TmdoDBLabel.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBLabelProperties;
end;

{ TmdoDBLabelProperties }

class function TmdoDBLabelProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBLabelViewInfo;
end;

{ TmdoDBLabelViewInfo }

procedure TmdoDBLabelViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBStringEdit }

class function TmdoDBStringEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBStringEditProperties;
end;

function TmdoDBStringEdit.GetUpperCase: Boolean;
begin
  Result := Properties.CharCase = ecUpperCase;
end;

procedure TmdoDBStringEdit.SetUpperCase(AValue: Boolean);
begin
  if AValue then
    Properties.CharCase := ecUpperCase
  else
    Properties.CharCase := ecNormal;
end;

{ TmdoDBStringEditProperties }

class function TmdoDBStringEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBStringEditViewInfo;
end;

{ TmdoDBStringEditViewInfo }

procedure TmdoDBStringEditViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBIntegerEdit }

class function TmdoDBIntegerEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBIntegerEditProperties;
end;

{ TmdoDBIntegerEditProperties }

class function TmdoDBIntegerEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBIntegerEditViewInfo;
end;

{ TmdoDBIntegerEditViewInfo }

procedure TmdoDBIntegerEditViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBFloatEdit }

class function TmdoDBFloatEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBFloatEditProperties;
end;

procedure TmdoDBFloatEdit.SetMoneyFormat;
begin
  Properties.DisplayFormat := '0.00';
end;

{ TmdoDBFloatEditProperties }

procedure TmdoDBFloatEditProperties.AfterConstruction;
begin
  inherited AfterConstruction;
  Precision := 0;
end;

class function TmdoDBFloatEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBFloatEditViewInfo;
end;

{ TmdoDBFloatEditViewInfo }

procedure TmdoDBFloatEditViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBDateEdit }

procedure TmdoDBDateEdit.AfterConstruction;
begin
  inherited AfterConstruction;
  Properties.Kind := ckDate;
end;

class function TmdoDBDateEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBDateEditProperties;
end;

{ TmdoDBDateEditProperties }

class function TmdoDBDateEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBDateEditViewInfo;
end;

procedure TmdoDBDateEditProperties.ValidateDisplayValue(var ADisplayValue: TcxEditValue; var AErrorText: TCaption; var AError: Boolean; AEdit: TcxCustomEdit);
begin
  inherited ValidateDisplayValue(ADisplayValue, AErrorText, AError, AEdit);
  if AError then
    AErrorText := IDEDesigner.FindStr('str_mdo_invalid_date');
end;

{ TmdoDBDateEditViewInfo }

procedure TmdoDBDateEditViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBDateTimeEdit }

procedure TmdoDBDateTimeEdit.AfterConstruction;
begin
  inherited AfterConstruction;
  Properties.Kind := ckDateTime;
end;

{ TmdoDBTimeEdit }

class function TmdoDBTimeEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TmdoDBTimeEditProperties;
end;

{ TmdoDBTimeEditProperties }

class function TmdoDBTimeEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxSpinEditViewInfo;
end;

{ TmdoDBTimeEditViewInfo }

procedure TmdoDBTimeEditViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBLookupBoxProperties }

class function TmdoDBLookupBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBLookupBoxViewInfo;
end;

{ TmdoDBLookupBoxViewInfo }

procedure TmdoDBLookupBoxViewInfo.InternalPaint(ACanvas: TcxCanvas);
const
  BackColors: array[Boolean]of TColor = (clWindow, $00DEFAFA);
begin
  SetControlEnabledByField(Edit);

  BackgroundColor := BackColors[TmdoDBLookupBox(Edit).Properties.ReadOnly];
  TmdoDBLookupBox(Edit).InnerControl.Brush.Color := BackgroundColor;

  inherited InternalPaint(ACanvas);
end;

{ TmdoDBComboBoxProperties }

class function TmdoDBComboBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TmdoDBComboBoxViewInfo;
end;

{ TmdoDBComboBoxViewInfo }

procedure TmdoDBComboBoxViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  SetControlEnabledByField(Edit);
  inherited InternalPaint(ACanvas);
end;

{ TmdoDBText }

procedure TmdoDBText.AfterConstruction;
begin
  inherited AfterConstruction;
  ParentColor := False;
end;

{ TmdoFormWithGrid }

procedure TmdoFormWithGrid.DesignControls;
begin
  inherited DesignControls;
  FGrid := TmdoDBGrid.Create(Self);
  FGrid.Align := alClient;
  FGrid.DesignColumns(DataID, DataSource);
  FGrid.View.CellDblClick := EditOnDblClick;
end;

procedure TmdoFormWithGrid.EditOnDblClick(Sender: TObject; ACellViewInfo: TObject; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  IDEDesigner.ExecActn(IIDFActnDBUpdate);
end;

function TmdoFormWithGrid.DeleteCount: Integer;
begin
  Result := FGrid.View.SelectedCount;
end;

procedure TmdoFormWithGrid.FillDeleteList(AList: TList<Int64>);
var
  I: Integer;
begin
  if FGrid.View.Columns[0].DataBinding.FieldName = 'ID' then
    for I := 0 to FGrid.View.SelectedCount - 1 do
      AList.Add(VarAsType(FGrid.View.SelectedCell[I, 0], varInt64));
end;

procedure TmdoFormWithGrid.Refresh;
begin
  inherited Refresh;
  FGrid.View.DataController.CheckFocusedSelected;
end;

{ TmdoFormWithGridAndParamPanel }

procedure TmdoFormWithGridAndParamPanel.DesignControls;
begin
  inherited DesignControls;
  FParamPanel := TmdoParamPanel.Create(Self);
  FParamPanel.DesignControls(ParamID, ParamSource, DoSearchClick, ParamFieldChange);
end;

procedure TmdoFormWithGridAndParamPanel.Refresh;
begin
  FParamPanel.PostEditValue;
  inherited Refresh;
end;

procedure TmdoFormWithGridAndParamPanel.DoSearchClick(Sender: TObject);
begin
  Refresh;
end;

function TmdoFormWithGridAndParamPanel.GetmdoComp: TmdoCompWithParams;
begin
  Result := TmdoCompWithParams(inherited Comp);
end;

function TmdoFormWithGridAndParamPanel.GetParamID: string;
begin
  if (FParamID = '') then
    FParamID := GetMetaID('PARAM');
  Result := FParamID;
end;

function TmdoFormWithGridAndParamPanel.GetParamSet: TDataSet;
begin
  if not Assigned(FParamSet) and Assigned(Comp) then
    FParamSet := Comp.ParamSet;
  Result := FParamSet;
end;

function TmdoFormWithGridAndParamPanel.GetParamSource: TDataSource;
begin
  if not Assigned(FParamSource) then
    FParamSource := FindDataSource(ParamSet);
  Result := FParamSource;
end;

procedure TmdoFormWithGridAndParamPanel.ParamFieldChange(Sender: TField);
begin
  DataSet.Close;
end;

{ TmdoTileControl }

procedure TmdoTileControl.AfterConstruction;
begin
  FOwner := TWinControl(Self.Owner);

  FMsgDetailPanel := TcxScrollBox.Create(Self.Owner);
  if Self.Owner is TWinControl
  then FMsgDetailPanel.Parent := TWinControl(Self.Owner);

  FMsgAnimTimer := TTimer.Create(nil);
  SetDefaultValues;

  inherited;
end;

procedure TmdoTileControl.BeforeDestruction;
begin
  FMsgAnimTimer.Enabled := FALSE;
  FMsgAnimTimer.Free;

  ClearDetailChildrenComponent;

  FMsgDetailPanel.Free;

  inherited;
end;

procedure TmdoTileControl.ChangeParent(aParent: TComponent);
begin
  if Assigned(aParent) then
    if aParent is TWinControl then
    begin
      FOwner := TWinControl(aParent);
      FMsgDetailPanel.Parent := FOwner;
      Self.Parent := FOwner;
    end;
end;

procedure TmdoTileControl.ClearDetailChildrenComponent;
var
  _i_: SmallInt;
begin
  if FMsgDetailPanel = nil
  then Exit;

  for _i_ := FMsgDetailPanel.ComponentCount - 1 downto 0 do
    FMsgDetailPanel.Components[_i_].Free;

  FMsgDetailPanel.Align := alNone;
  FMsgDetailPanel.Invalidate;
  FMsgDetailPanel.Width  := 1; // Need to minimized Size, because it is some bad visuality artefact in time build and
  FMsgDetailPanel.Height := 1; // repaint several Items in TileContainer... (Panel in this case will clearing some Screen area)
end;

procedure TmdoTileControl.ClearItems;
var
  _i_: SmallInt;
begin
  for _i_ := 0 to Items.Count - 1 do
    TdxTileControlItem(Items[_i_]).DetailOptions.DetailControl := nil;

  Items.Clear;
end;

procedure TmdoTileControl.CreateNewItemByMsgSett(aColorBack, aColorFont: TColor; aImgID: Integer;
  aTxt1, aTxt2, aTxt3, aTxt4: String; aSingleItem, aShowDetail: Boolean);
var
  tmpMsgShp: TdxTileControlItem;
begin
  Self.BeginUpdate;
  try
    tmpMsgShp := Self.Items.Add;
    Self.Groups[0].Add(tmpMsgShp);
    tmpMsgShp.Size := tcisRegular;
    tmpMsgShp.Style.Gradient := gmHorizontal;
    tmpMsgShp.Style.GradientBeginColor   := aColorBack;
    tmpMsgShp.Style.GradientEndColor     := aColorBack;
    tmpMsgShp.OptionsAnimate.AnimateText := FALSE;
    tmpItem := tmpMsgShp;
    //
    if not aSingleItem then
    begin
      tmpMsgShp.Size := tcisLarge;
      Self.OptionsView.ItemWidth          := Trunc(Self.Width / 2) - 16;
      Self.OptionsBehavior.ItemMoving     := FALSE;
      Self.OptionsItemAnimate.AnimateText := FALSE;
    end;

    tmpMsgShp.Glyph.Images        := IDEDesigner.Images;
    tmpMsgShp.Glyph.ImageIndex    := aImgID;
    tmpMsgShp.Glyph.Align         := oaTopLeft;
    tmpMsgShp.Glyph.AlignWithText := itaLeft;
    tmpMsgShp.Glyph.IndentHorz    := 2;
    tmpMsgShp.Glyph.IndentVert    := 2;

    tmpMsgShp.Text1.TextColor   := aColorFont;
    tmpMsgShp.Text1.Value       := aTxt1;
    tmpMsgShp.Text1.Transparent := TRUE;
    tmpMsgShp.Text1.Font.Style  := [fsBold, fsUnderline];
    tmpMsgShp.Text1.Alignment   := taLeftJustify;
    tmpMsgShp.Text1.IndentHorz  := 2;
    tmpMsgShp.Text1.IndentVert  := 2;

    tmpMsgShp.Text2.TextColor   := aColorFont;
    tmpMsgShp.Text2.Value       := aTxt2;
    tmpMsgShp.Text2.Transparent := TRUE;
    tmpMsgShp.Text2.Align       := oaTopLeft;
    tmpMsgShp.Text2.Alignment   := taLeftJustify;
    tmpMsgShp.Text2.IndentHorz  := 4;
    tmpMsgShp.Text2.IndentVert  := 20;
    tmpMsgShp.Text2.WordWrap    := TRUE;

    if aShowDetail then
    begin
      Cursor := crHandPoint;
      tmpMsgShp.DetailOptions.DetailControl := FMsgDetailPanel;
      FMsgDetailPanel.Align     := alClient;
      tmpMsgShp.Text3.TextColor := aColorFont;
      tmpMsgShp.Text3.Value     := aTxt3;
      tmpMsgShp.Text3.Font.Style  := [fsUnderline];
      tmpMsgShp.Text3.Align       := oaBottomRight;
      tmpMsgShp.Text3.Transparent := TRUE;
      tmpMsgShp.Text3.TextColor   := clBlue;
      tmpMsgShp.Text3.Alignment   := taLeftJustify;
      tmpMsgShp.Text3.IndentHorz  := 6;
      tmpMsgShp.Text3.IndentVert  := 6;

      tmpMsgShp.OnActivateDetail   := OnOpenDetail;
      tmpMsgShp.OnDeactivateDetail := OnHideDetail;
    end;

    tmpMsgShp.Text4.Value      := aTxt4;
    tmpMsgShp.Text4.IndentHorz := -500;
  finally
    Self.EndUpdate;
  end;
end;

function TmdoTileControl.GetInnerHeightValue: Integer;
var
  _i_: SmallInt;
  tmpMaxTop, tmpTop: SmallInt;
begin
  tmpMaxTop := 0;
  for _i_ := 0 to FMsgDetailPanel.ComponentCount - 1 do
    if FMsgDetailPanel.Components[_i_] is TWinControl then
    begin
      tmpTop := TWinControl(FMsgDetailPanel.Components[_i_]).Top + TWinControl(FMsgDetailPanel.Components[_i_]).Height;
      if tmpTop > tmpMaxTop
      then tmpMaxTop := tmpTop;
    end;
  Result := tmpMaxTop;
end;

function TmdoTileControl.GetInnerWidthValue: Integer;
var
  _i_: SmallInt;
  tmpMaxLeft, tmpLeft: SmallInt;
begin
  tmpMaxLeft := 0;
  for _i_ := 0 to FMsgDetailPanel.ComponentCount - 1 do
    if FMsgDetailPanel.Components[_i_] is TWinControl then
    begin
      tmpLeft := TWinControl(FMsgDetailPanel.Components[_i_]).Left + TWinControl(FMsgDetailPanel.Components[_i_]).Width;
      if tmpLeft > tmpMaxLeft
      then tmpMaxLeft := tmpLeft;
    end;
  Result := tmpMaxLeft;
end;

procedure TmdoTileControl.OnHideDetail(Sender: TdxTileControlItem);
begin

end;

procedure TmdoTileControl.OnMouseIn(Sender: TObject);
begin

end;

procedure TmdoTileControl.OnMouseOut(Sender: TObject);
begin

end;

procedure TmdoTileControl.OnOpenDetail(Sender: TdxTileControlItem);
begin
  ClearDetailChildrenComponent;
end;

procedure TmdoTileControl.OnTimerEvent(Sender: TObject);
begin

end;

procedure TmdoTileControl.SetDefaultValues;
begin
  tmpStr1 := '';
  tmpStr2 := '';
  tmpStr3 := '';

  Align := alNone;

  OptionsDetailAnimate.AnimationMode := damFade;
  OptionsBehavior.ItemHotTrackMode := tcihtmFrame;

  OptionsView.GroupLayout := glVertical;
  OptionsView.GroupMaxRowCount := 1000;
  OptionsView.IndentHorz := 2;
  OptionsView.IndentVert := 2;
  OptionsView.ItemIndent := 2;
  OptionsItemAnimate.AnimateText   := FALSE;
  OptionsBehavior.ItemHotTrackMode := tcihtmFrame;
  OptionsBehavior.ItemMoving := FALSE;
  Style.Stretch     := smTile;
  Title.Font.Height := 32;
  Images := IDEDesigner.Images;
  LookAndFeel.NativeStyle := TRUE;
  Title.Color       := clSkyBlue;
  Title.Font.Color  := clMaroon;
  Title.Font.Height := 22;
  Title.Font.Style  := [fsBold, fsItalic];

  Self.OnMouseEnter := OnMouseIn;
  Self.OnMouseLeave := OnMouseOut;

  FMsgDetailPanel.Visible := FALSE;
  FMsgDetailPanel.Left    := -512;
  FMsgDetailPanel.Top     := -512;
  FMsgDetailPanel.Align   := alNone;
  FMsgDetailPanel.Width   := 256;
  FMsgDetailPanel.Height  := 128;

  FMsgAnimTimer.Enabled  := FALSE;
  FMsgAnimTimer.OnTimer  := OnTimerEvent;
  FLocalState := animHide;

  Self.Groups.Add; // One Group Need to contain all MsgItemShapes controls!
end;

{ TmdoControlSaver }

procedure TmdoControlSaver.AfterConstruction;
begin
  inherited AfterConstruction;
  FIni := TMemIniFile.Create('');
end;

procedure TmdoControlSaver.BeforeDestruction;
begin
  FreeAndNil(FIni);
  inherited BeforeDestruction;
end;

function TmdoControlSaver.Load(AControlName: string): Boolean;
var
  List: TStringList;
  Stream: TMemoryStream;
begin
  Result := False;
  Exit;
  {TODO - это на потом}
  List := TStringList.Create;
  Stream := TMemoryStream.Create;
  try
    FIni.Clear;
    with ExecRead(MDO_DB_IID, SSYS_PREF_BINARY_GET, AControlName) do
      if not Eof then
        Fields[0].SaveToStream(Stream);
    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      List.LoadFromStream(Stream);
      FIni.SetStrings(List);
      Result := True;
    end;
  finally
    FreeAndNil(Stream);
    FreeAndNil(List);
  end;
end;

procedure TmdoControlSaver.Save(AControlName: string);
var
  List: TStringList;
  Stream: TMemoryStream;
begin
  List := TStringList.Create;
  Stream := TMemoryStream.Create;
  try
    FIni.GetStrings(List);
    List.SaveToStream(Stream);
    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      ExecWrite(MDO_DB_IID, SSYS_PREF_BINARY_SET, procedure (const AParams: IQueryParams)
        begin
          AParams['NAME'].AsString   := AControlName;
          AParams['PREF_VALUE'].LoadFromStream(Stream);
        end);
    end;
  finally
    FreeAndNil(Stream);
    FreeAndNil(List);
  end;
end;

{ TmdoStringParser }

procedure TmdoStringParser.AfterConstruction;
begin
  inherited AfterConstruction;
  StrictDelimiter := True;
  Delimiter := ';';
end;

{ TmdoGridRootLevel }

procedure TmdoGridRootLevel.Clear;

  procedure ClearLevel(ALevel: TcxGridLevel);
  var
    I: Integer;
    Level: TcxGridLevel;
    View: TmdoDBBandedTableView;
  begin
    for I := 0 to ALevel.Count - 1 do
    begin
      Level := ALevel.Items[I];
      ClearLevel(Level);
      View  := TmdoDBBandedTableView(Level.GridView);
      View.OnColumnPosChanged := nil;
      Level.GridView := nil;
      FreeAndNil(View);
    end;
  end;

begin
  ClearLevel(Self);
end;

{ TmdoCustomDesigner }

procedure TmdoCustomDesigner.ExecDesign(AForm: TObject);
begin
  if Assigned(AForm) and Assigned(FCustomDesignMethod) then
    FCustomDesignMethod(AForm);
end;

{ TmdoImageSlider }

procedure TmdoImageSlider.AddImage(AFileName: string);
var
  Item: TcxImageCollectionItem;
begin
  Item := Images.Items.Add;
  Item.Picture.LoadFromFile(AFileName);
end;

procedure TmdoImageSlider.AfterConstruction;
begin
  inherited AfterConstruction;
  if Owner is TWinControl then
    Parent := Owner as TWinControl;
  SetObjectLookAndFeel(Self);
  ImageFitMode := ifmProportionalStretch;
  Images := TcxImageCollection.Create(nil);
end;

procedure TmdoImageSlider.BeforeDestruction;
begin
  Images.Items.Clear;
  Images.Free;
  Images := nil;
  inherited BeforeDestruction;
end;

{ TmdoDBImage }

procedure TmdoDBImage.AfterConstruction;
begin
  inherited AfterConstruction;
  Style.BorderStyle := ebsNone;
end;

initialization
  FLayoutLookAndFeel := nil;
  DBList.RegisterDB(MDO_DB_IID);

finalization
  if Assigned(FLayoutLookAndFeel) then
    FreeAndNil(FLayoutLookAndFeel);

end.
