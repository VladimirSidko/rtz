(* $Id: udf_ibase.pas 4 2008-03-25 18:24:03Z runningmaster $
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

unit udf_ibase;

interface

uses
  SysUtils, Windows;


const
   const_cstring_0255 = 255 - 1;
   const_cstring_1024 = 1024 - 1;
   
resourcestring
   str_blob_info = 'SEG_COUNT: %d  MAX_SEG_LEN: %d  TOTAL_LEN: %d';

type
  PLongint = ^Longint;

  TIBBlobGetSegment = function(Handle: PLongint; Buffer: PAnsiChar;
    BufferSize: Longint; var ResultLength: Longint): Smallint; cdecl;

  TIBBlobPutSegment = procedure(Handle: PLongint; Buffer: PAnsiChar;
    BufferLength: Smallint); cdecl;

  TIBBlob = packed record
    GetSegment:       TIBBlobGetSegment;
    Handle:           PLongint;
    SegmentCount:     Longint;
    MaxSegmentLength: Longint;
    TotalLength:      Longint;
    PutSegment:       TIBBlobPutSegment;
  end;
  PIBBlob = ^TIBBlob;

  TIBDate = Integer;
  TIBTime = Cardinal;
  TIBDateTime = packed record
   Date: TIBDate;
   Time: TIBTime;
  end;
  PIBDate     = ^TIBDate;
  PIBTime     = ^TIBTime;
  PIBDateTime = ^TIBDateTime;

  TISCDate  = Longint;
  TISCTime  = DWord;
  TISCTimeStamp = packed record
    timestamp_date: TISCDate;
    timestamp_time: TISCTime;
  end;
  PISCDate = ^TISCDate;
  PISCTime = ^TISCTime;
  PISCTimeStamp = ^TISCTimeStamp;

  TGDSQuad = packed record
   gds_quad_high: Longint;
   gds_quad_low: DWord;
  end;
  TISCQuad = TGDSQuad;
  PISCQuad = ^TISCQuad;

  { C Date/Time Structure }
  TCTimeStructure = packed record
    tm_sec: Longint;   // Seconds
    tm_min: Longint;   // Minutes
    tm_hour: Longint;  // Hour (0--23)
    tm_mday: Longint;  // Day of month (1--31)
    tm_mon: Longint;   // Month (0--11)
    tm_year: Longint;  // Year (calendar year minus 1900)
    tm_wday: Longint;  // Weekday (0--6) Sunday = 0)
    tm_yday: Longint;  // Day of year (0--365)
    tm_isdst: Longint; // 0 if daylight savings time is not in effect)
  end;
  PCTimeStructure = ^TCTimeStructure;
  TM = TCTimeStructure;
  PTM = ^TM;

procedure isc_decode_sql_date(ib_date: PISCDate; tm_date: PCTimeStructure); cdecl; external 'fbclient.dll' name 'isc_decode_sql_date';
procedure isc_decode_sql_time(ib_time: PISCTime; tm_date: PCTimeStructure); cdecl; external 'fbclient.dll' name 'isc_decode_sql_time';
procedure isc_decode_timestamp(ib_timestamp: PISCTimeStamp; tm_date: PCTimeStructure); cdecl; external 'fbclient.dll' name 'isc_decode_timestamp';
procedure isc_decode_date(ib_date: PISCQuad; tm_date: PCTimeStructure); cdecl; external 'fbclient.dll' name 'isc_decode_date';

procedure isc_encode_sql_date(tm_date: PCTimeStructure; ib_date: PISCDate); cdecl; external 'fbclient.dll' name 'isc_encode_sql_date';
procedure isc_encode_sql_time(tm_date: PCTimeStructure; ib_time: PISCTime); cdecl; external 'fbclient.dll' name 'isc_encode_sql_time';
procedure isc_encode_timestamp(tm_date: PCTimeStructure; ib_timestamp: PISCTimeStamp); cdecl; external 'fbclient.dll' name 'isc_encode_timestamp';
procedure isc_encode_date (tm_date: PCTimeStructure; ib_date: PISCQuad); cdecl; external 'fbclient.dll' name 'isc_encode_date';

procedure InitTM(var tm_date: TM);

implementation

procedure InitTM(var tm_date: TM);
begin
  with tm_date do
  begin
    tm_sec := 0;
    tm_min := 0;
    tm_hour := 0;
    tm_mday := 0;
    tm_mon := 0;
    tm_year := 0;
    tm_wday := 0;
    tm_yday := 0;
    tm_isdst := 0;
  end;
end;

end.
