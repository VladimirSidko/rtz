(*
*
*  MDO User Define Functions
*
* Copyright (c) 2006 Dmitriy Kovalenko (runningmaster@gmail.com)
* and all contributors signed below.
*
* All Rights Reserved.
* Contributor(s):
*   2009, Mickhael Mostovoy
*   2009, Nikolay Ponomarenko, pnv82g (at) gmail.com
*
*)

library mdo_udfs;

uses
  SysUtils,
  udf_header in '..\udf\udf_header.pas',
  udf_string in '..\udf\udf_string.pas',
  udf_blob in '..\udf\udf_blob.pas',
  udf_float in '..\udf\udf_float.pas',
  udf_guid in '..\udf\udf_guid.pas',
  udf_ibase in '..\udf\udf_ibase.pas',
  udf_round in '..\udf\udf_round.pas',
  udf_sha1 in '..\udf\udf_sha1.pas';

begin
  System.IsMultiThread := True;
end.
