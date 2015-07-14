#define _publ "Morion"
#define _copy "Copyright (©) 2009-2015 Morion. All Rights Reserved."
#define _mail "public@morion.ua"
#define _http "http://www.morion.ua"

#define _installid  "SRV3050_2.0"
#define _appid      "SRV3050"
#define _appname    "Сервер ПК ''АПТЕКА''"
#define _version    "2"
#define _exefile    "ide3050main.exe"
#define _icofile    "srv.ico"
#define _urlfile    "website.url"
#define _mutex      "MDS_RUNNING"

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

WizardImageFile      = setup-large.bmp
WizardSmallImageFile = setup-small.bmp
SetupIconFile        = setup-icon.ico
UninstallDisplayIcon = {app}\img\{#_icofile}
UninstallDisplayName = {#_appname}
PrivilegesRequired   = none
AllowNoIcons         = yes

SolidCompression     = yes
#ifdef UPDATE_MODE
Compression          = lzma/ultra
#endif

OutputDir          = {#_setup}


AppComments     =
AppContact      = {#_mail}
AppPublisher    = {#_publ}
AppPublisherURL = {#_http}
AppReadmeFile   =
AppSupportPhone =
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

[Files]
Source: "{#_distr}\*"; DestDir: "{app}"; Excludes: "*.fdb"; Flags: ignoreversion recursesubdirs createallsubdirs; 
Source: "{#_distr}\..\_kit\_cron\*"; DestDir: "{app}\..\_cron"; Excludes: "cron.tab,cron.ini"; Flags: onlyifdoesntexist recursesubdirs createallsubdirs; AfterInstall: DoAfterCronInstall
Source: "{#_distr}\..\_kit\_cron\cron.tab"; DestDir: "{app}\..\_cron"; Flags: ignoreversion; AfterInstall: DoAfterCronInstall
Source: "{#_distr}\..\_kit\_cron\cron.ini"; DestDir: "{app}\..\_cron"; Flags: ignoreversion;
Source: "{#_distr}\..\..\_kit\_lib\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs;

[INI]
Filename: "{app}\{#_urlfile}"; Section: "InternetShortcut"; Key: "URL"; String: {#_http}
Filename: "{app}\{#_urlfile}"; Section: "InternetShortcut"; Key: "IconFile"; String: "{app}\img\morion.ico"
Filename: "{app}\{#_urlfile}"; Section: "InternetShortcut"; Key: "IconIndex"; String: "0"

[Icons]
Name: "{group}\{#_appname}";                       Filename: "{app}\bin\{#_exefile}"; IconFilename: "{app}\img\{#_icofile}"; WorkingDir: "{app}\bin\"
;Name: "{group}\{cm:ProgramOnTheWeb,{#_appname}}";  Filename: "{app}\{#_urlfile}"; IconFilename: "{app}\img\morion.ico";
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
function DefaultDirPath(Param: string): string;
begin
  Result := ExpandConstant('{sd}');
end;

procedure DoAfterCronInstall();
var
  ArrStr: TArrayOfString;
  I: Integer;
begin
  if CompareText(CurrentFileName, '{app}\..\_cron\cron.tab') = 0 then
  begin
    if LoadStringsFromFile(ExpandConstant(CurrentFileName), ArrStr) then
    begin
      for I := 0 to GetArrayLength(ArrStr) - 1 do
        if Pos('SET PathSkyNet', ArrStr[I]) > 0 then
        begin          
          ArrStr[I] := Format('SET PathSkyNet = "%s"', [ExpandConstant('{app}\bin')]);
          SaveStringsToFile(ExpandConstant(CurrentFileName), ArrStr, False);
          Break;
        end;
      for I := 0 to GetArrayLength(ArrStr) - 1 do
        if Pos('SET PathMdsTask', ArrStr[I]) > 0 then
        begin
          ArrStr[I] := Format('SET PathMdsTask = "%s"', [ExpandConstant('{app}\bin')]);
          SaveStringsToFile(ExpandConstant(CurrentFileName), ArrStr, False);
          Break;
        end;
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
//var
//  ResultCode: Integer;
begin

//  #2750: Установка Cron как службы Windows осуществляется ТС-ом вручную путем выполнения bat-файла install_svc.bat в зависимости от согласия клиента на передачу данных.
//  if CurStep =  ssDone then  
//    Exec(ExpandConstant('{app}\..\_cron\install_svc.bat'), '', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);      
end;
