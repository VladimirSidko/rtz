@echo off
set xml_validate=C:\tools\xml_validate\xml_validate.exe

set file_name=elorder_adrr
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% == 1 ECHO ERROR %file_name%.xml

set file_name=elorder_certificate
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% == 1 ECHO ERROR %file_name%.xml

set file_name=elorder_content
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% == 1 ECHO ERROR %file_name%.xml

set file_name=elorder_deficiency
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% == 1 ECHO ERROR %file_name%.xml

set file_name=elorder_login
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% == 1 ECHO ERROR %file_name%.xml

set file_name=elorder_notify
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% NEQ 0 ECHO ERROR %file_name%.xml

set file_name=elorder_order
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% NEQ 0 ECHO ERROR %file_name%.xml

set file_name=elorder_price
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% NEQ 0 ECHO ERROR %file_name%.xml

set file_name=elorder_purch_inv
%xml_validate% %file_name%.xml %file_name%.xsd
if %ERRORLEVEL% NEQ 0 ECHO ERROR %file_name%.xml


