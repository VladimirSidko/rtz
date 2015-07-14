#define _publ  "Morion"
#define _copy  "Copyright (©) 2009-2015 Morion. All Rights Reserved."
#define _mail  "public@morion.ua"
#define _phone "+38 (044) 585-97-12"
#define _http  "http://www.morion.ua"

#define _installid  "MDO_UPDATE"
#define _appid      "MDO_UPDATE"
#define _appname    "Обновление Фармзаказ ''АПТЕКА''"
#define _version    "2"
#define _exefile    "mds3050cdrun.exe"
#define _icofile    "mdo.ico"
#define _urlfile    "website.url"
#define _mutex      "MDO_RUNNING"
;#define _source_dir  "..\..\MDS3050.UPD_PACK"

;source dir for setup is defined from outside through compiler param /d
;#define _distr   "..\user-distr"
                                                                      
#define _setup   "..\user-setup"

[Setup]
AppId      = {#_installid}
AppName    = {#_appname}
AppVersion = {#_version}
AppVerName = {#_appname}
AppMutex   = {#_mutex}

WizardImageFile      = setup-large.bmp
WizardSmallImageFile = mdo_setup_small.bmp
SetupIconFile        = mdo_setup.ico
PrivilegesRequired   = none
AllowNoIcons         = yes

SolidCompression     = yes
Compression          = lzma/ultra
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
CreateUninstallRegKey = no
Uninstallable=no
DefaultDirName={tmp}\..\{#_appid}
OutputBaseFilename=mdo_upd_pack

DisableWelcomePage=yes
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyMemo=yes
DisableReadyPage=yes
DisableStartupPrompt=yes
DisableFinishedPage=yes

[Languages]
Name: "ru"; MessagesFile: "compiler:Languages\Russian.isl"

[Files]
Source: "{#_source_dir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Run]
Filename: "{app}\bin\{#_exefile}"; Description: "Launch application"; Flags: postinstall nowait

[Code]   

const
  WM_CLOSE = $0010;
  WM_KEYDOWN = $0100;
  WM_KEYUP = $0101;
  VK_RETURN = 13;

procedure InitializeWizard();
begin
  
  WizardForm.BorderStyle := bsNone;
 // WizardForm.Width := 580;
 // WizardForm.Height := 250;
  // Pressing the default "Install" button to continue the silent install
  PostMessage(WizardForm.Handle, WM_KEYDOWN, VK_RETURN, 0);
  PostMessage(WizardForm.Handle, WM_KEYUP, VK_RETURN, 0);
  DelTree(ExpandConstant('{tmp}\..\{#_appid}'), True, True, True);

  // Or can exit the wizard if the user has cancelled installation
  // PostMessage(WizardForm.Handle, WM_CLOSE, 0, 0);
end;
