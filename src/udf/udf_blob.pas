(* $Id: udf_blob.pas 1725 2008-12-27 23:01:19Z smike $
*
*  MDS User Define Functions
*
* Copyright (c) 2006 Dmitriy Kovalenko (runningmaster@gmail.com)
* and all contributors signed below.
*
* All Rights Reserved.
* Contributor(s): ______________________________________.
*
*)

unit udf_blob;

interface

uses
  SysUtils, Windows,
  udf_ibase, udf_sha1;

procedure udf_BlobToStr(var ABlob: TIBBlob; CString: PAnsiChar); cdecl;
procedure udf_StrToBlob(CString: PAnsiChar; var ABlob: TIBBlob); cdecl;
function  udf_BlobToHash(var ABlob: TIBBlob): Int64; cdecl;

implementation

procedure udf_BlobToStr(var ABlob: TIBBlob; CString: PAnsiChar);
var
  SegmLen, CStrLen, BuffLen, LeftLen: Longint;
  EndOfBlob: Boolean;
  S: PAnsiChar;
begin
  CString[0] := #0;
  if not (Assigned(ABlob.Handle) and Assigned(ABlob.GetSegment) and (ABlob.TotalLength <> 0)) then
    Exit;

  S := HeapAlloc(GetProcessHeap, 0, ABlob.TotalLength + 1);
  SegmLen := ABlob.MaxSegmentLength;
  LeftLen := ABlob.TotalLength;
  CStrLen := 0;

  repeat
    EndOfBlob := not Boolean(ABlob.GetSegment(ABlob.Handle, S + CStrLen, SegmLen, BuffLen));
    Inc(CStrLen, BuffLen);
    Dec(LeftLen, BuffLen);
  until EndOfBlob or (LeftLen <= 0);

  S[CStrLen] := #0;
  StrCopy(CString, S);

  HeapFree(GetProcessHeap, 0, S);
end;

procedure udf_StrToBlob(CString: PAnsiChar; var ABlob: TIBBlob);
begin
  if not (Assigned(ABlob.Handle) and Assigned(ABlob.PutSegment)) then
    Exit;

  ABlob.PutSegment(ABlob.Handle, CString, StrLen(CString));
end;

function  udf_BlobToHash(var ABlob: TIBBlob): Int64;
var
  Context: TSHA1Context;
  Digest: TSHA1Digest;
  S: PAnsiChar;
begin
  Result := 0;
  if not (Assigned(ABlob.Handle) and Assigned(ABlob.GetSegment) and (ABlob.TotalLength <> 0)) then
    Exit;

  S := HeapAlloc(GetProcessHeap, 0, ABlob.TotalLength + 1);

  udf_BlobToStr(ABlob, S);

  SHA1Init(Context);
  SHA1Update(Context, S, StrLen(S));
  SHA1Final(Context, Digest);

  HeapFree(GetProcessHeap, 0, S);

  Result := PInt64(@Digest)^;
end;

end.
