(* $Id: udf_header.pas 1812 2009-01-16 10:11:51Z Smike $
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

unit udf_header;

interface

uses
  udf_ibase,
  udf_blob,
  udf_string,
  udf_guid,
  udf_float;

exports
  // udf_blob.pas
  udf_BlobToStr         name 'UDF_BLOB2STR',         // BLOB, CSTRING(1024) RETURNS PARAMETER 2
  udf_StrToBlob         name 'UDF_STR2BLOB',         // CSTRING(1024), BLOB RETURNS PARAMETER 2
  // udf_string.pas
  udf_UpLowerCase       name 'UDF_UPLOWERCASE',      // CSTRING(1024), CSTRING(1024) RETURNS PARAMETER 2
  udf_DateTimeToStr     name 'UDF_DT2STR',           // TIMESTAMP, CSTRING(1024), CSTRING(1024) RETURNS PARAMETER 3
  udf_Fmt               name 'UDF_FMT',              // CSTRING(4096), CSTRING(4096), CSTRING(4096) RETURNS PARAMETER 2
  udf_UAHToStr          name 'UDF_UAHTOSTR',         // DOUBLE PRECISION, CSTRING(1024) RETURNS PARAMETER 2
  udf_Int_Quant         name 'UDF_INT_QUANT',        // BIGINT, BIGINT, BIGINT RETURNS BIGINT BY VALUE
  udf_Frac_Quant        name 'UDF_FRAC_QUANT',       // BIGINT, BIGINT, BIGINT, CSTRING(100) RETURNS PARAMETER 4
  udf_JSONToStr         name 'UDF_JSON2STR',         // CSTRING(1024), CSTRING(1024) RETURNS PARAMETER 2
  udf_StrToJSON         name 'UDF_STR2JSON',         // CSTRING(1024), CSTRING(1024) RETURNS PARAMETER 2

  // udf_guid.pas
  udf_GUIDAsString      name 'UDF_GUID',             // CSTRING(38) RETURNS PARAMETER 1
  udf_UUIDAsString      name 'UDF_UUID',
  udf_GUIDAsBigint      name 'UDF_GUID_SHA',         // RETURNS BIGINT BY VALUE

  // udf_float
  udf_Int               name 'UDF_INT',              // DOUBLE PRECISION RETURNS DOUBLE PRECISION BY VALUE
  udf_Frac              name 'UDF_FRAC',             // DOUBLE PRECISION RETURNS DOUBLE PRECISION BY VALUE
  udf_Round             name 'UDF_ROUND',            // DOUBLE PRECISION RETURNS DOUBLE PRECISION BY VALUE
  udf_RoundToScale      name 'UDF_ROUND_TO_SCALE',   // DOUBLE PRECISION, INTEGER RETURNS DOUBLE PRECISION BY VALUE
  udf_RoundUp           name 'UDF_ROUND_UP',         // DOUBLE PRECISION RETURNS DOUBLE PRECISION BY VALUE
  udf_RoundDown         name 'UDF_ROUND_DOWN',       // DOUBLE PRECISION RETURNS DOUBLE PRECISION BY VALUE
  udf_Trunc             name 'UDF_TRUNC',            // DOUBLE PRECISION RETURNS BIGINT BY VALUE

  udf_Div               name 'UDF_DIV',              // BIGINT, BIGINT RETURNS BIGINT BY VALUE
  udf_Mod               name 'UDF_MOD',              // BIGINT, BIGINT RETURNS BIGINT BY VALUE
  udf_GCD               name 'UDF_GCD',              // BIGINT, BIGINT RETURNS BIGINT BY VALUE
  udf_LCM               name 'UDF_LCM',              // BIGINT, BIGINT RETURNS BIGINT BY VALUE
  udf_RNM               name 'UDF_RNM',              // INTEGER, INTEGER RETURNS INTEGER BY VALUE

  // Correct Price & Sum Calculation
  udf_Price            name 'UDF_PRICE',             // DOUBLE PRECISION, DOUBLE PRECISION RETURNS DOUBLE PRECISION BY VALUE
  udf_Vat              name 'UDF_VAT',               // DOUBLE PRECISION, DOUBLE PRECISION RETURNS DOUBLE PRECISION BY VALUE
  udf_Sum              name 'UDF_SUM',               // DOUBLE PRECISION, BIGINT, BIGINT, BIGINT RETURNS DOUBLE PRECISION BY VALUE
  udf_SumDiv           name 'UDF_SUM_DIV',           // DOUBLE PRECISION, BIGINT, BIGINT RETURNS DOUBLE PRECISION BY VALUE
  udf_Quant            name 'UDF_QUANT',             // BIGINT, BIGINT, BIGINT RETURNS DOUBLE PRECISION BY VALUE

  udf_Hash             name 'UDF_HASH',              // CSTRING(1024), RETURNS BIGINT BY VALUE
  udf_BlobToHash       name 'UDF_BLOB2HASH';         // BLOB, RETURNS BIGINT BY VALUE

implementation

end.
