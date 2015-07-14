#define _publ  "Morion"
#define _copy  "Copyright (©) 2009-2015 Morion. All Rights Reserved."
#define _mail  "support@pharmbase.com.ua"
#define _phone "+38 (044) 585-97-12"
#define _http  "http://pharmbase.com.ua/"

#define _installid  "MDS3050_MDS"
#define _appid      "MDS3050\MDS"
#define _appname    "Программный комплекс ''Аптека''"
#define _version    "2.0"
#define _exefile    "ide3050main.exe"
#define _icofile    "mds.ico"
#define _urlfile    "website.url"
#define _mutex      "MDS_RUNNING"
#define _setup      "..\user-setup"


[Setup]
AppId      = {#_installid}
AppName    = {#_appname}
AppVersion = {#_version}
AppVerName = {#_appname}
AppMutex   = {#_mutex}

DefaultDirName={code:DefaultDirPath}\{#_publ}\{#_appid}
DefaultGroupName = {#_publ}\{#_appname}

;LicenseFile          = mds_license.txt
;InfoBeforeFile       = mds_readme.txt
WizardImageFile      = setup-large.bmp
WizardSmallImageFile = setup-small.bmp
SetupIconFile        = setup-icon.ico
UninstallDisplayIcon = {app}\img\{#_icofile}
UninstallDisplayName = {#_appname}
PrivilegesRequired   = none
AllowNoIcons         = yes

SolidCompression     = yes
Compression          = lzma/ultra

OutputDir               = {#_setup}

AppComments     = {#_appname}
AppContact      = {#_mail}
AppPublisher    = {#_publ}
AppPublisherURL = {#_http}
AppReadmeFile   =
AppSupportPhone = {#_phone}
AppSupportURL   = {#_http}
AppUpdatesURL   = {#_http}


VersionInfoCompany      = {#_publ}
VersionInfoDescription  = {#_appname}
VersionInfoVersion      = {#_version}
VersionInfoTextVersion  = {#_version}

[Messages]
BeveledLabel = {#_copy}

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Dirs]
Name: "{app}\log\";

[Files]
Source: "{#_distr}\*";         DestDir: "{app}";     Excludes: "*.fdb"; Flags: ignoreversion recursesubdirs createallsubdirs; 
Source: "{#_distr}\fdb\*.fdb"; DestDir: "{app}\fdb";                    Flags: onlyifdoesntexist recursesubdirs createallsubdirs

[InstallDelete]

[Icons]
Name: "{group}\{#_appname}";                       Filename: "{app}\bin\{#_exefile}"; IconFilename: "{app}\img\{#_icofile}"; WorkingDir: "{app}\bin\"
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
