(*
*  MDS User Define Functions
*
* Copyright (c) 2006 Dmitriy Kovalenko (runningmaster@gmail.com)
* and all contributors signed below.
*
* All Rights Reserved.
* Contributor(s): ______________________________________.
*
*)

unit udf_guid;

interface

uses
  SysUtils, StrUtils, ActiveX, udf_sha1;

procedure udf_UUIDAsString(P: PAnsiChar); cdecl; export;

procedure udf_GUIDAsString(Result: PAnsiChar); cdecl;
function udf_GUIDAsBigint: Int64; cdecl;

implementation


function CreateClassID: string;
var
  ClassID: TCLSID;
  P: PWideChar;
begin
  CoCreateGuid(ClassID);
  StringFromCLSID(ClassID, P);
  Result := P;
  CoTaskMemFree(P);
end;

{
  DECLARE EXTERNAL FUNCTION UDF_UUID
  cstring(36)
  RETURNS PARAMETER 1
  ENTRY_POINT 'udf_UUIDAsString' MODULE_NAME 'mdo_udfs.dll';}
procedure udf_UUIDAsString(P: PAnsiChar); cdecl; export;
var
  S: AnsiString;
begin
  S := AnsiString(Copy(CreateClassID, 2, 36));
  StrPCopy(P, S);
end;

procedure udf_GUIDAsString(Result: PAnsiChar);
var
  GUID: TGUID;
begin
  CreateGUID(GUID);
  StrCopy(Result, PAnsiChar(AnsiString(GUIDToString(GUID))));
end;

function udf_GUIDAsBigint: Int64;
var
  GUID: TGUID;
  Context: TSHA1Context;
  Digest: TSHA1Digest;
  S: AnsiString;
begin
  CreateGUID(GUID);
  SHA1Init(Context);
  S := AnsiString(GUIDToString(GUID));
  SHA1Update(Context, PAnsiChar(S), Length(S));
  SHA1Final(Context, Digest);
  Result := PInt64(@Digest)^;
end;

end.

