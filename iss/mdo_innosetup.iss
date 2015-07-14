#define _publ  "Morion"
#define _copy  "Copyright (©) 2009-2015 Morion. All Rights Reserved."
#define _mail  "public@morion.ua"
#define _phone "+38 (044) 585-97-12"
#define _http  "http://www.morion.ua"

#define _installid  "MDS3050_2.0"
#define _appid      "MDS3050\MDO"
#define _appname    "Фармзаказ ''АПТЕКА''"
#define _version    "2"
#define _exefile    "ide3050main.exe"
#define _icofile    "mdo.ico"
#define _urlfile    "website.url"
#define _mutex      "MDO_RUNNING"

;source dir for setup is defined from outside through compiler param /d
;#define _distr   "..\user-distr"

#define _setup   "..\user-setup"

[Setup]
AppId      = {#_installid}
AppName    = {#_appname}
AppVersion = {#_version}
AppVerName = {#_appname}
AppMutex   = {#_mutex}

DefaultDirName={code:DefaultDirPath}\{#_publ}\{#_appid}
DefaultGroupName = {#_publ}\{#_appname}
LicenseFile          = mdo_license.txt
WizardImageFile      = setup-large.bmp
WizardSmallImageFile = mdo_setup_small.bmp
SetupIconFile        = mdo_setup.ico
UninstallDisplayIcon = {app}\img\{#_icofile}
UninstallDisplayName = {#_appname}
PrivilegesRequired   = none
AllowNoIcons         = yes

SolidCompression     = yes
#ifdef UPDATE_MODE
Compression          = lzma/ultra
#endif

OutputDir          = {#_setup}


AppComments     = {#_appname}
AppContact      = {#_mail}
AppPublisher    = {#_publ}
AppPublisherURL = {#_http}
AppReadmeFile   =
AppSupportPhone = {#_phone}
AppSupportURL   = {#_http}
AppUpdatesURL   = {#_http}



VersionInfoCompany     =
VersionInfoDescription =
VersionInfoTextVersion =
VersionInfoVersion     =

#ifdef UPDATE_MODE
CreateUninstallRegKey = no
#endif

[Messages]
BeveledLabel = {#_copy}

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Dirs]

[InstallDelete]
Type: filesandordirs; Name: "{app}\sql-mds3050"  
Type: filesandordirs; Name: "{app}\src"
Type: filesandordirs; Name: "{app}\tst"

Type: files; Name: "{app}\bin\*test.bpl"

[Files]
#ifdef UPDATE_MODE
Source: "{#_distr}\*"; DestDir: "{app}"; Excludes: "*.fdb"; Flags: ignoreversion recursesubdirs createallsubdirs; 
#else
; with backup of databases
Source: "{#_distr}\*"; DestDir: "{app}"; Excludes: "*.fdb"; Flags: ignoreversion recursesubdirs createallsubdirs; 
Source: "{#_distr}\fdb\*.fdb"; DestDir: "{app}\fdb"; Flags: ignoreversion recursesubdirs createallsubdirs; BeforeInstall: CreateBackup;
#endif

[Dirs]
Name: "{app}\log\";

[INI]
Filename: "{app}\{#_urlfile}"; Section: "InternetShortcut"; Key: "URL"; String: {#_http}
Filename: "{app}\{#_urlfile}"; Section: "InternetShortcut"; Key: "IconFile"; String: "{app}\img\morion.ico"
Filename: "{app}\{#_urlfile}"; Section: "InternetShortcut"; Key: "IconIndex"; String: "0"


[Icons]
Name: "{group}\{#_appname}";                       Filename: "{app}\bin\{#_exefile}"; IconFilename: "{app}\img\{#_icofile}"; WorkingDir: "{app}\bin\"
Name: "{group}\{cm:ProgramOnTheWeb,{#_appname}}";  Filename: "{app}\{#_urlfile}"; IconFilename: "{app}\img\morion.ico";
Name: "{group}\{cm:UninstallProgram,{#_appname}}"; Filename: "{uninstallexe}"

Name: "{userdesktop}\{#_appname}";                  Filename: "{app}\bin\{#_exefile}"; IconFilename: "{app}\img\{#_icofile}"; WorkingDir: "{app}\bin\"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#_appname}"; Filename: "{app}\bin\{#_exefile}"; IconFilename: "{app}\img\{#_icofile}"; WorkingDir: "{app}\bin\"; Tasks: quicklaunchicon

[Tasks]
Name: "desktopicon";     Description: "{cm:CreateDesktopIcon}";     GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\bin\{#_exefile}"; Description: "{cm:LaunchProgram, {#_appname}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\{#_urlfile}"

Type: filesandordirs; Name: "{app}\dbg"


[Code]
var
  NeedConfirmExit: Boolean;

function DefaultDirPath(Param: string): string;
begin
  Result := ExpandConstant('{sd}');
end;

procedure CreateBackup(); 
var
  BkpDir: string;
  DBFile: string;
begin 
  BkpDir :=  ExpandConstant('{app}\fdb.bkp\');
  DBFile :=  ExpandConstant(CurrentFileName);
  
  ForceDirectories(BkpDir);

  if CompareText(ExtractFileExt(DBFile), '.fdb')=0 then
    RenameFile(DBFile, BkpDir + ExtractFileName(DBFile));
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  V: Integer;
  ResultCode: Integer;
  MDOPath: string;
  Page: TWizardPage;
  StaticText : TNewStaticText;
begin
  Result := True;
  if (CurPageID = wpSelectDir) and (not WizardSilent()) then
  begin
  if (FileExists(ExpandConstant('{app}\bin\{#_exefile}'))) then
  begin
   V := MsgBox(ExpandConstant('Обнаружена установленная копия {#_appname}! Запустить?'), mbInformation, MB_YESNO); //Custom Message if App installed
    if V = IDYES then
    begin
      if Exec(ExpandConstant('{app}\bin\{#_exefile}'), '', '', SW_SHOW, ewNoWait, ResultCode) then
      begin
        Result := False;
        NeedConfirmExit := False;
        WizardForm.Close;
      end;
    end else
    begin
      Page := CreateCustomPage(wpSelectDir, 'Внимание!', 'Предупреждение о замене файлов!');
      StaticText := TNewStaticText.Create(Page);
      StaticText.Caption := '  Данная установка полностью перезапишет все файлы в рабочей папке, включая базу данных. '+#13#10#13#10+
                            '  Старый файл базы данных ("mdo.fdb") перед заменой будет скопирован в папку "..\fdb.bkp\" '+ #13#10#13#10+
                            '  При этом в новой базе будет отсутствовать предыдущая работа пользователя (например, загруженные спецпрайсы, сформированная потребность, '+
                            'реестр сформированных заказов, личные настройки и пр.) '+#13#10#13#10+
                            '  Если Вы уверенны в дальнейших действиях, нажмите "ДАЛЕЕ".';
      StaticText.WordWrap := True;
      StaticText.Width := Page.SurfaceWidth;
      StaticText.Parent := Page.Surface;
    end;
  end;
  end;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
 Confirm := NeedConfirmExit;
end;

procedure InitializeWizard();
begin
  NeedConfirmExit := True;
end;
