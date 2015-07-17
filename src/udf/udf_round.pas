(* $Id: udf_round.pas 4 2008-03-25 18:24:03Z runningmaster $
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

unit udf_round;

(* *****************************************************************************

 ROUTINES FOR ROUNDING IEEE-754 FLOATS TO SPECIFIED NUMBER OF DECIMAL FRACTIONS

  These routines round input values to fit as closely as possible to an
  output number with desired number of decimal fraction digits.

  Because, in general, numbers with decimal fractions cannot be exactly
  represented in IEEE-754 floating binary point variables, error limits
  are used to determine if the input numbers are intended to represent an
  exact decimal fraction rather than a nearby value.   Thus an error limit
  will be taken into account when deciding that a number input such as
  1.295, which internally is represented 1.29499 99999 Å, really should
  be considered exactly 1.295 and that 0.29999 99999 ... really should
  be interpreted as 0.3 when applying the rounding rules.

  Some terminology:
    "NDFD" is used for Number of Decimal Fraction Digits.  If NDFD is
        negative, then the inputs will be rounded so that there are zeros
        on the left of the decimal point.  I.E. if NDFD = -3, then the
        output will be rounded to an integral multiple of a thousand.
    "MaxRelError" designates the maximum relative error to be allowed in the
        input values when deciding they are supposed to represent exact
        decimal fractions (as mentioned above).
    "Ctrl" determines the type of rounding to be done.  Nine kinds of
        rounding (plus no rounding) are defined.  They include almost
        every kind of rounding known.  See the definition of
        tDecimalRoundingCtrl below for the specific types.

 Rev. 2002.01.14 by John Herbster to add overloaded IsNaN() functions to
     solve problem with invalid operation when loading values for test.
 Rev. 2001.11.24 by John Herbster to add KnownErrorLimit, SafetyFactor,
     and MaxRelErrXxx constants. Also corrected DecimalRoundingCtrlStrs
     and comments per feedback from Marjan Venema.
 Pgm. 2001.09.19 by John Herbster.  Please send feedback and suggestions
     to author at herb-sci@swbell.net.

 Dedicated to the participants in the borland.public.delphi.objectpascal
     forum.  With special thanks to Brad White for his proofing and
     suggestions.

***************************************************************************** *)

interface

//uses
//  Classes;

type
  { The defined rounding methods }
  tDecimalRoundingCtrl = (
    drNone,    { No rounding. }
    drHalfEven,{ Round to nearest or to even whole number. (a.k.a Bankers) }
    drHalfPos, { Round to nearest or toward positive. }
    drHalfNeg, { Round to nearest or toward negative. }
    drHalfDown,{ Round to nearest or toward zero. }
    drHalfUp,  { Round to nearest or away from zero. }
    drRndNeg,  { Round toward negative. (a.k.a. Floor) }
    drRndPos,  { Round toward positive. (a.k.a. Ceil ) }
    drRndDown, { Round toward zero. (a.k.a. Trunc) }
    drRndUp);  { Round away from zero. }


{ The following DecimalRound function is for doing the best possible job of
  rounding floating binary point numbers to the specified NDFD.  MaxRelError
  is the maximum relative error that will be allowed when determining the
  cut points for applying the rounding rules. }

function DecimalRound(
  Value: Extended;     {Input value to be rounded.}
  NDFD: Integer;       {Number decimal fraction digits to figure in result.}
  MaxRelErr: Double;   {Maximum relative error to assume in input value.}
  Ctrl: tDecimalRoundingCtrl = drHalfEven  {Optional rounding rule}
  ): Extended;

{ The following functions have a two times "epsilon" error built in for the
  single, double, and extended argument respectively: }

function DecimalRoundSgl(Value: Single; NDFD: integer; Ctrl: tDecimalRoundingCtrl = drHalfEven): Extended;
function DecimalRoundDbl(Value: Double; NDFD: integer; Ctrl: tDecimalRoundingCtrl = drHalfEven): Extended;
function DecimalRoundExt(Value: Extended; NDFD: integer; Ctrl: tDecimalRoundingCtrl = drHalfEven): Extended;

{----- The following are utility functions and constants ----------------------}

{ The following "epsilon" values are representative of the resolution of the
  floating point numbers divided by the number being represented.
  These constants are supplied to the rounding routines to determine how much
  correction should be allowed for the natural errors in representing
  decimal fractions.  Using 2 times or higher multiples of these values may
  be advisable if the data have been massaged through arithmetic
  calculations. }
const
  SglEps = 1.1920928955e-07;
  DblEps = 2.2204460493e-16;
  ExtEps = 1.0842021725e-19;
{ These epsilon values are smallest for which "1 + epsilon <> 1".
      For "1 - epsilon <> 1", divide the following values by 2. }

const
  KnownErrorLimit = 1.234375;
  SafetyFactor = 2;
  MaxRelErrSgl = SglEps * KnownErrorLimit * SafetyFactor;
  MaxRelErrDbl = DblEps * KnownErrorLimit * SafetyFactor;
  MaxRelErrExt = ExtEps * KnownErrorLimit * SafetyFactor;

{ If MaxRelErr < XxxEps * KnownErrorLimit then errors can occur. }

{ This procedure loads the tDecimalRoundingCtrl descriptions and ordinals
  into the string list for such use as using a TCombobox to make rounding
  type selection. }
//procedure LoadDecimalRoundingCtrlAbbrs(const Strings: TStrings);

{ This procedure was used to compute the values SglEps, DblEps, and ExtEps: }
procedure CalcEpsValues(var SglEps, DblEps, ExtEps: Double);

{ Each returns true if the value passed is not-a-number. }
function IsNAN (const Sgl: Single): Boolean; overload;
function IsNAN (const Dbl: Double): Boolean; overload;
function IsNAN (const Ext: Extended): Boolean; overload;

{ Returns the FPU control word (which indicates interrupt masks and
  precision and rounding modes). }
function GetX87CW: Word;

{ Returns true if floating point processor (FPU) is correctly set
    (1) to allow conversion from extended to double and double to single
        without creating the the loss-of-precision interrupt or exception,
    (2) to do arithmetic internal to FPU in extended precision, and
    (3) to internally use halves-to-even (a.k.a. bankers) rounding. }
function IsFpuCwOkForRounding: Boolean;

const
  DecimalRoundingCtrlStrs: array [tDecimalRoundingCtrl] of
      record Abbr: string[9]; Dscr: string[59]; end = (
    (Abbr: 'None'    ; Dscr: 'No rounding.'),
    (Abbr: 'HalfEven'; Dscr: 'Round to nearest or to even whole number'+
                             ' (a.k.a Bankers) '),
    (Abbr: 'HalfPos' ; Dscr: 'Round to nearest or toward positive'),
    (Abbr: 'HalfNeg' ; Dscr: 'Round to nearest or toward negative'),
    (Abbr: 'HalfDown'; Dscr: 'Round to nearest or toward zero'),
    (Abbr: 'HalfUp'  ; Dscr: 'Round to nearest or away from zero'),
    (Abbr: 'RndNeg'  ; Dscr: 'Round toward negative. (a.k.a. Floor)'),
    (Abbr: 'RndPos'  ; Dscr: 'Round toward positive. (a.k.a. Ceil)'),
    (Abbr: 'RndDown' ; Dscr: 'Round toward zero. (a.k.a. Trunc)'),
    (Abbr: 'RndUp'   ; Dscr: 'Round away from zero.') );

const
{ These FPU Control Word bit masks prevent interrupt when present: }
  IM = $0001; {Invalid op interrupt Mask}
  DM = $0002; {Denormalized op interrupt Mask}
  ZM = $0004; {Zero divide interrupt Mask}
  OM = $0008; {Overflow interrupt Mask}
  UM = $0010; {Underflow interrupt Mask}
  PM = $0020; {Loss of precision interrupt Mask}
{ The "pending interrupt" flags in status word have matching positions. }
  IntrM = IM or DM or ZM or OM or UM or PM;

{ These FPU Control Word bit fields change operation: }
  PC = $0300; {Precision Control mask}
  RC = $0C00; {Rounding Control mask}
  pcSingle  = $0000; pcDouble = $0200; pcExtended = $0300;
  rcBankers = $0000; rcFloor  = $0400; rcCeil     = $0800; rcChop = $0C00;

implementation

{ The DecimalRounding function is for doing the best possible job of rounding
  floating binary point numbers to the specified (NDFD) number of decimal
  fraction digits.  MaxRelErr is the maximum relative error that will allowed
  when determining when to apply the rounding rule. }

function DecimalRound(Value: Extended; NDFD: Integer; MaxRelErr: Double;
  Ctrl: tDecimalRoundingCtrl = drHalfEven): Extended;
var
  i64, j64: Int64; j: Integer;
  m, ScaledVal, ScaledErr: Extended;
begin
  if IsNaN(Value) or (Ctrl = drNone) then
  begin
    Result := Value;
    Exit;
  end;

{ Compute 10^NDFD and scale the Value and MaxError: }
  m := 1;
  for j := 1 to Abs(NDFD) do
    m := m * 10;

  if NDFD >= 0 then
  begin
    ScaledVal := Value * m;
    ScaledErr := Abs(MaxRelErr * Value) * m;
  end else
  begin
    ScaledVal := Value / m;
    ScaledErr := Abs(MaxRelErr * Value) / m;
  end;

{ Do the diferent basic types separately: }
  case Ctrl of
    drHalfEven:
    begin
      i64 := Round((ScaledVal - ScaledErr));
      j64 := Round((ScaledVal + ScaledErr));
      if Odd(i64) then i64 := j64;
    end;
    drHalfDown:  {Round to nearest or toward zero.}
      i64 := Round((abs(ScaledVal) - ScaledErr));
    drHalfUp:    {Round to nearest or away from zero.}
      i64 := Round((abs(ScaledVal) + ScaledErr));
    drHalfPos:   {Round to nearest or toward positive.}
      i64 := Round((ScaledVal + ScaledErr));
    drHalfNeg:   {Round to nearest or toward negative.}
      i64 := Round((ScaledVal - ScaledErr));
    drRndNeg:    {Truncate toward negative. (a.k.a. Floor)}
      i64 := Round((ScaledVal + (ScaledErr - 1 / 2)));
    drRndPos:    {Truncate toward positive. (a.k.a. Ceil)}
      i64 := Round((ScaledVal - (ScaledErr - 1 / 2)));       {}
    drRndDown:   {Truncate toward zero (a.k.a. Trunc).}
      i64 := Round((abs(ScaledVal) + (ScaledErr - 1 / 2)));
    drRndUp:     {Truncate away from zero.}
      i64 := Round((abs(ScaledVal) - (ScaledErr - 1 / 2)));
    else i64 := Round(ScaledVal);
  end; {cases}

{ Finally convert back to the right order: }
  if NDFD >= 0 then Result := i64 / m else Result := i64 * m;

  if (Ctrl in [drHalfDown, drHalfUp, drRndDown, drRndUp]) and (Value < 0) then
    Result := - Result;

end; {DecimalRound}

function DecimalRoundSgl(Value: Single; NDFD: Integer; Ctrl: tDecimalRoundingCtrl = drHalfEven): Extended;
begin
  Result := DecimalRound(Value, NDFD, MaxRelErrSgl, Ctrl);
end;

function DecimalRoundDbl(Value: Double; NDFD: integer; Ctrl: tDecimalRoundingCtrl = drHalfEven): Extended;
begin
  Result := DecimalRound(Value, NDFD, MaxRelErrDbl, Ctrl);
end;

function DecimalRoundExt(Value: Extended; NDFD: integer; Ctrl: tDecimalRoundingCtrl = drHalfEven): Extended;
begin
  Result := DecimalRound(Value, NDFD, MaxRelErrExt, Ctrl);
end;

procedure CalcEpsValues(var SglEps, DblEps, ExtEps: Double);
{ Compute smallest 1/(2^n) epsilon values for which "1 + epsilon <> 1".
  For "1 - epsilon <> 1", divide these computed values by 2. }
var
  s: Single;
  D: double;
  e,f: Extended;
begin
{ Compute for single, s: }
  f := 1;
  repeat
    f := f / 2;
    s := 1 + f / 2;
  until s = 1;
  SglEps := f;

{ Compute for double, d: }

  f := 1;
  repeat
    f := f / 2;
    d := 1 + f / 2;
  until d = 1;
  DblEps := f;

{ Compute with extended, e: }

  f := 1;
  repeat
    f := f / 2;
    e := 1 + f/2;
  until e = 1;
  ExtEps := f;
end;

{$WRITEABLECONST OFF}

type
  TExtPackedRec = packed record
    Man: Int64;
    Exp: word
  end;

const SglExpBits: LongInt = $7F800000;          { 8 bits}
      DblExpBits: Int64   = $7FF0000000000000;  {11 bits}
      ExtExpBits: word    = $7FFF;              {15 bits}

function IsNAN(const Sgl: single): Boolean;
var
  InputX: LongInt absolute Sgl;
begin
  Result := (InputX <> 0) and ((InputX and SglExpBits) = SglExpBits);
end;

function IsNAN(const Dbl: Double): Boolean;
var
  InputX: Int64 absolute Dbl;
begin
  Result := (InputX <> 0) and ((InputX and DblExpBits) = DblExpBits);
end;

function IsNAN(const Ext: Extended): Boolean;
var
  InputX: TExtPackedRec absolute Ext;
begin
  Result := (InputX.Man <> 0) and ((InputX.Exp and ExtExpBits) = ExtExpBits);
end;

function GetX87CW: word;
{ Returns the FPU control word (which indicates interrupt masks and
      precision and rounding modes). }
asm
  FStCW [Result]
end;

function IsFpuCwOkForRounding: Boolean;
{ Checks to see that floating point processor (FPU) is correctly set to
    (1) allow conversion from extended to double and double to single
        without creating the the loss of precision interrupt or exception,
    (2) do arithmetic internal to FPU in extended precision, and
    (3) use round halves-to-even (a.k.a. bankers rounding) internally. }
var
  CW: Word;
begin
  CW := GetX87CW;
  Result := ((CW and (PC or RC or PM)) = (rcBankers or pcExtended or PM));
end;

//procedure LoadDecimalRoundingCtrlAbbrs(const Strings: tStrings);
//var
//  dr: tDecimalRoundingCtrl;
//begin
//  Assert(Strings <> nil);
//  Strings.Clear;
//  for dr := Low(dr) to High(dr) do
//    Strings.AddObject(DecimalRoundingCtrlStrs[dr].Abbr, Pointer(dr));
//end;

end.

