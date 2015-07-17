(* $Id: udf_float.pas 1928 2009-01-31 13:18:03Z Smike $
*
*  MDS User Define Functions
*
* Copyright (c) 2006 Roman Yaroshenko (roma.yaroshenko@gmail.com)
* and all contributors signed below.
*
* All Rights Reserved.
* Contributor(s): Dmitriy Kovalenko (runningmaster@gmail.com)
*
*)

unit udf_float;

interface

uses
  Math,
  udf_round;

function udf_Frac(var Value: Double): Double; cdecl;
function udf_Int(var Value: Double): Double; cdecl;
function udf_Round(var Value: Double): Double; cdecl;
function udf_RoundToScale(var Value: Double; var Scale: Integer): Double; cdecl;
function udf_RoundUp(var Value: Double): Double; cdecl;
function udf_RoundDown(var Value: Double): Double; cdecl;
function udf_Trunc(var Value: Double): Int64; cdecl;

function udf_Div(var Value1, Value2: Int64): Int64; cdecl;
function udf_Mod(var Value1, Value2: Int64): Int64; cdecl;  // остаток деления
function udf_GCD(var Value1, Value2: Int64): Int64; cdecl;  // наибольший общий делитель
function udf_LCM(var Value1, Value2: Int64): Int64; cdecl;  // наименьшее общее кратное
function udf_RNM(var Value, N: Integer): Integer; cdecl;

function udf_Price(var Value, CoefVat: Double): Double; cdecl;
function udf_Vat(var Value, CoefVat: Double): Double; cdecl;
function udf_Sum(var Price: Double; var QuantInt, QuantNum, QuantDiv: Int64): Double; cdecl;
function udf_SumDiv(var Price: Double; var Quant, CoefDiv: Int64): Double; cdecl;
function udf_Quant(var QuantInt, QuantNum, QuantDiv: Int64): Double; cdecl;

function RoundToMultiple(Value, N: Integer): Integer;

implementation

function udf_Frac(var Value: Double): Double;
begin
  Result := Frac(Value);
end;

function udf_Int(var Value: Double): Double;
begin
  Result := Int(Value);
end;

function udf_Round(var Value: Double): Double;
begin
  Result := DecimalRound(Value, 2, MaxRelErrDbl, drHalfUp);
end;

function udf_RoundToScale(var Value: Double; var Scale: Integer): Double;
begin
  Result := DecimalRound(Value, Scale, MaxRelErrDbl, drHalfUp);
end;

function udf_RoundUp(var Value: Double): Double; cdecl;
begin
  Result := DecimalRound(Value, 2, MaxRelErrDbl, drRndUp);
end;

function udf_RoundDown(var Value: Double): Double; cdecl;
begin
  Result := DecimalRound(Value, 2, MaxRelErrDbl, drRndDown);
end;

function udf_Trunc(var Value: Double): Int64;
begin
  Result := Trunc(Value);
end;

function udf_Div(var Value1, Value2: Int64): Int64;
begin
  if Value2 <> 0 then Result := Value1 div Value2 else Result := 0;
end;

function udf_Mod(var Value1, Value2: Int64): Int64;
begin
  if Value2 <> 0 then Result := Value1 mod Value2 else Result := 0;
end;

function udf_GCD(var Value1, Value2: Int64): Int64;
var
  Val: Int64;
begin
  if Value1 <> 0 then
  begin
    Val := Value2 mod Value1;
    Result := udf_GCD(Val, Value1);
  end else
    Result := Value2;
end;

function udf_LCM(var Value1, Value2: Int64): Int64;
begin
  if Value2 <> 0 then Result := Value1 div udf_GCD(Value1, Value2) * Value2 else Result := 0;
end;

function RoundToMultiple(Value, N: Integer): Integer;
{ **** UBPFD *********** by delphibase.endimus.com ****
>> «Округление» до ближайшего кратного

Функция возвращает ближайшее к Value число, которoе без
остатка делится на N. Если Value находится посередине
между двумя кратными, функция вернёт большее значение.

Зависимости: нет
Автор:       Dimka Maslov, mainbox@endimus.ru, ICQ:148442121, Санкт-Петербург
Copyright:   Dimka Maslov
Дата:        20 февраля 2003 г.
***************************************************** }
asm
   push ebx
   mov ebx, eax
   mov ecx, edx
   cdq
   idiv ecx
   imul ecx

   add ecx, eax
   mov edx, ebx
   sub ebx, eax
   jg @@10
   neg ebx
@@10:
   sub edx, ecx
   jg @@20
   neg edx
@@20:
   cmp ebx, edx
   jl @@30
   mov eax, ecx
@@30:
   pop ebx
end;

function udf_RNM(var Value, N: Integer): Integer;
begin
  Result := RoundToMultiple(Value, N);
end;

function udf_Price(var Value, CoefVat: Double): Double;
begin
  if CoefVat < 0 then
    Result := Value - udf_Vat(Value, CoefVat)
  else
    Result := Value + udf_Vat(Value, CoefVat);
end;

function udf_Vat(var Value, CoefVat: Double): Double;
var
  V: Double;
begin
  if CoefVat > 0 then
  begin
    V := Value * (1 + CoefVat);
    V := udf_Round(V);
  end else
    V := Value;

  Result := V - V / (1 + Abs(CoefVat));

  Result := udf_Round(Result);
end;

function udf_Sum(var Price: Double; var QuantInt, QuantNum, QuantDiv: Int64): Double;
begin
  if QuantDiv > 0 then
    Result := DecimalRound(Price * (QuantInt + QuantNum / QuantDiv), 2, MaxRelErrDbl, drHalfUp)
  else
    Result := 999999999.0; // <- Имитация бесконечности  (mtv's)
end;

function udf_SumDiv(var Price: Double; var Quant, CoefDiv: Int64): Double;
begin
  if CoefDiv > 0 then
  begin
    Result := DecimalRound(Price * Quant / CoefDiv, 2, MaxRelErrDbl, drHalfUp);
  end else
    Result := 999999999.0; // <- Имитация бесконечности  (mtv's)
end;

function udf_Quant(var QuantInt, QuantNum, QuantDiv: Int64): Double; cdecl;
begin
  Result := QuantInt + QuantNum / QuantDiv;
end;

end.
