(* $Id: udf_string.pas 1726 2008-12-27 23:13:24Z smike $
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

unit udf_string;

interface

uses
  SysUtils, StrUtils, Classes, Windows,
  udf_ibase, udf_sha1;

procedure udf_UpLowerCase(Source, Result: PAnsiChar); cdecl;

procedure udf_DateTimeToStr(var IBDateTime: TIBDateTime; FormatDT, Result: PAnsiChar); cdecl;

procedure udf_UAHToStr(var Value: Double; Result: PAnsiChar); cdecl;

function udf_Int_Quant(var QuantInt, QuantNum, QuantDiv: Int64): Int64; cdecl;
procedure udf_Frac_Quant(var QuantInt, QuantNum, QuantDiv: Int64; Result: PAnsiChar); cdecl;

procedure udf_Fmt(AFmt, AArgs, Result: PAnsiChar); cdecl;

function udf_Hash(Source: PAnsiChar): Int64; cdecl;

procedure udf_JSONToStr(Source, Result: PAnsiChar); cdecl;
procedure udf_StrToJSON(Source, Result: PAnsiChar); cdecl;

implementation

uses Character;

procedure udf_UpLowerCase(Source, Result: PAnsiChar);
var
  S: string;
begin
  S := AnsiLowerCase(String(Source));
  if Length(S) > 0 then S[1] := ToUpper(S[1]);
  StrPCopy(Result, AnsiString(S));
end;

procedure udf_DateTimeToStr(var IBDateTime: TIBDateTime; FormatDT, Result: PAnsiChar);
const
  MSecsPerDay10 = MSecsPerDay * 10;
  IBDateDelta = 15018;
var
  DateTime: TDateTime;
  StrFormatDT: string;
begin
  StrFormatDT := String(FormatDT);
  if Length(StrFormatDT) = 0 then StrFormatDT := 'dd.mm.yyyy hh:mm:ss';
  if not ((IBDateTime.Date = 0) and (IBDateTime.Time = 0)) then
  begin
    DateTime := IBDateTime.Date - IBDateDelta + IBDateTime.Time / MSecsPerDay10;
    StrPCopy(Result, AnsiString(FormatDateTime(StrFormatDT, DateTime)));
  end else
    StrPCopy(Result, '');
end;

const
{ Константы для параметра FmtFlags (их можно объединять с помощью "or"): }

  nsMale    = 1;    {  Мужской род  }
  nsFemale  = 2;    {  Женский род  }
  nsMiddle  = 3;    {  Средний род  }

  nsFull    = 0;    {  Полное название триад:  тысяча, миллион, ... }
  nsShort   = 4;    {  Краткое название триад:  тыс., млн., ... }

{ Возвращаемые значения функции Q_NumToStr: }

  rfmFirst  = 1;    {  Первая форма: "один слон" или "двадцать одна кошка"  }
  rfmSecond = 2;    {  Вторая форма: "три слона" или "четыре кошки"  }
  rfmThird  = 3;    {  Третья форма: "шесть слонов" или "восемь кошек"  }

function ModDiv10(var X: Integer): Integer;
const
  Base10: Integer = 10;
asm
        MOV     ECX,EAX
        MOV     EAX,[EAX]
        XOR     EDX,EDX
        DIV     Base10
        MOV     [ECX],EAX
        MOV     EAX,EDX
end;

{ NumToStr сохраняет в строке S число, переданное параметром N, записанное
  словами (по-русски). Параметр FmtFlags задает способ преобразования числа
  в строку. Функция NumToStr возвращает номер формы, в которой должно стоять
  следующее за данным числом слово (см. комментарии к константам rfmXXXX).
  Строка S всегда заканчивается пробелом. }

function NumToStrRus(N: Int64; var S: string; FmtFlags: LongWord): Integer;

const
  M_Ed: array [1..9] of string =
    ('один ','два ','три ','четыре ','пять ','шесть ','семь ','восемь ','девять ');
  W_Ed: array [1..9] of string =
    ('одна ','две ','три ','четыре ','пять ','шесть ','семь ','восемь ','девять ');
  S_Ed: array [1..9] of string =
    ('одно ','два ','три ','четыре ','пять ','шесть ','семь ','восемь ','девять ');
  E_Ds: array [0..9] of string =
    ('десять ','одиннадцать ','двенадцать ','тринадцать ','четырнадцать ',
     'пятнадцать ','шестнадцать ','семнадцать ','восемнадцать ','девятнадцать ');
  D_Ds: array [2..9] of string =
    ('двадцать ','тридцать ','сорок ','пятьдесят ','шестьдесят ','семьдесят ',
     'восемьдесят ','девяносто ');
  U_Hd: array [1..9] of string =
    ('сто ','двести ','триста ','четыреста ','пятьсот ','шестьсот ','семьсот ',
     'восемьсот ','девятьсот ');
  M_Tr: array[1..6,0..3] of string =
    (('тыс. ','тысяча ','тысячи ','тысяч '),
     ('млн. ','миллион ','миллиона ','миллионов '),
     ('млрд. ','миллиард ','миллиарда ','миллиардов '),
     ('трлн. ','триллион ','триллиона ','триллионов '),
     ('квадр. ','квадриллион ','квадриллиона ','квадриллионов '),
     ('квинт. ','квинтиллион ','квинтиллиона ','квинтиллионов '));
var
  V1: Int64;
  VArr: array[0..6] of Integer;
  I,E,D,H,Cnt: Integer;
begin
  Result := 3;
  if N <> 0 then
  begin
    if N < 0 then
    begin
      if N <> $8000000000000000 then
      begin
        N := -N;
        S := 'минус ';
      end else
      begin                                 { -9.223.372.036.854.775.808 }
        if FmtFlags and nsShort = 0 then
          S := 'минус девять квинтиллионов двести двадцать три квадриллиона'+
            ' триста семьдесят два триллиона тридцать шесть миллиардов'+
            ' восемьсот пятьдесят четыре миллиона семьсот семьдесят пять'+
            ' тысяч восемьсот восемь '
        else
          S := 'минус девять квинт. двести двадцать три квадр. триста'+
            ' семьдесят два трлн. тридцать шесть млрд. восемьсот пятьдесят'+
            ' четыре млн. семьсот семьдесят пять тыс. восемьсот восемь ';
        Exit;
      end;
    end else
      S := '';
    Cnt := 0;
    repeat
      V1 := N div 1000;
      VArr[Cnt] := N-(V1*1000);
      N := V1;
      Inc(Cnt);
    until V1 = 0;
    for I := Cnt-1 downto 0 do
    begin
      H := VArr[I];
      Result := 3;
      if H <> 0 then
      begin
        E := ModDiv10(H);
        D := ModDiv10(H);
        if D <> 1 then
        begin
          if E = 1 then
            Result := 1
          else if (E>=2) and (E<=4) then
            Result := 2;
          if (H<>0) and (D<>0) then
            S := S + U_Hd[H] + D_Ds[D]
          else if H <> 0 then
            S := S + U_Hd[H]
          else if D <> 0 then
            S := S + D_Ds[D];
          if E <> 0 then
            if I = 0 then
              case FmtFlags and 3 of
                1: S := S + M_Ed[E];
                2: S := S + W_Ed[E];
                3: S := S + S_Ed[E];
              else
                S := S + '#### ';
              end
            else if I = 1 then
              S := S + W_Ed[E]
            else
              S := S + M_Ed[E];
        end else
          if H = 0 then
            S := S + E_Ds[E]
          else
            S := S + U_Hd[H] + E_Ds[E];
        if I <> 0 then
        begin
          if FmtFlags and nsShort = 0 then
            S := S + M_Tr[I,Result]
          else
            S := S + M_Tr[I,0];
        end;
      end;
    end;
  end else
    S := 'ноль ';
end;

function NumToStrUkr(N: Int64; var S: string; FmtFlags: LongWord): Integer;

const
  M_Ed: array [1..9] of string =
    ('один ','два ','три ','чотири ','п`ять ','шість ','сім ','вісім ','дев`ять ');
  W_Ed: array [1..9] of string =
    ('одна ','дві ','три ','чотири ','п`ять ','шість ','сім ','вісім ','дев`ять ');
  S_Ed: array [1..9] of string =
    ('одно ','два ','три ','чотири ','п`ять ','шість ','сім ','вісім ','дев`ять ');
  E_Ds: array [0..9] of string =
    ('десять ','одинадцять ','дванадцять ','тринадцять ','чотирнадцять ',
     'п`ятнадцять ','шістнадцять ','сімнадцять ','вісімнадцять ','дев`ятнадцять ');
  D_Ds: array [2..9] of string =
    ('двадцять ','тридцять ','сорок ','п`ятдесят ','шістдесят ','сімдесят ',
     'вісімдесят ','дев`яносто ');
  U_Hd: array [1..9] of string =
    ('сто ','двісті ','триста ','чотириста ','п`ятсот ','шістсот ','сімсот ',
     'вісімсот ','дев`ятсот ');
  M_Tr: array[1..6,0..3] of string =
    (('тис. ','тисяча ','тисячі ','тисяч '),
     ('млн. ','мільйон ','мільйона ','мільйонів '),
     ('млрд. ','мільярд ','мільярда ','мільярдів '),
     ('трлн. ','трильйон ','трильйона ','трильйонів '),
     ('квадр. ','квадрілліон ','квадрілліона ','квадрілліонів '),
     ('квинт. ','квінтилліон ','квінтилліона ','квінтилліонів '));
var
  V1: Int64;
  VArr: array[0..6] of Integer;
  I,E,D,H,Cnt: Integer;
begin
  Result := 3;
  if N <> 0 then
  begin
    if N < 0 then
    begin
      if N <> $8000000000000000 then
      begin
        N := -N;
        S := 'минус ';
      end else
      begin                                 { -9.223.372.036.854.775.808 }
        if FmtFlags and nsShort = 0 then
          S := 'минус девять квинтиллионов двести двадцать три квадриллиона'+
            ' триста семьдесят два триллиона тридцать шесть миллиардов'+
            ' восемьсот пятьдесят четыре миллиона семьсот семьдесят пять'+
            ' тысяч восемьсот восемь '
        else
          S := 'минус девять квинт. двести двадцать три квадр. триста'+
            ' семьдесят два трлн. тридцать шесть млрд. восемьсот пятьдесят'+
            ' четыре млн. семьсот семьдесят пять тыс. восемьсот восемь ';
        Exit;
      end;
    end else
      S := '';
    Cnt := 0;
    repeat
      V1 := N div 1000;
      VArr[Cnt] := N-(V1*1000);
      N := V1;
      Inc(Cnt);
    until V1 = 0;
    for I := Cnt-1 downto 0 do
    begin
      H := VArr[I];
      Result := 3;
      if H <> 0 then
      begin
        E := ModDiv10(H);
        D := ModDiv10(H);
        if D <> 1 then
        begin
          if E = 1 then
            Result := 1
          else if (E>=2) and (E<=4) then
            Result := 2;
          if (H<>0) and (D<>0) then
            S := S + U_Hd[H] + D_Ds[D]
          else if H <> 0 then
            S := S + U_Hd[H]
          else if D <> 0 then
            S := S + D_Ds[D];
          if E <> 0 then
            if I = 0 then
              case FmtFlags and 3 of
                1: S := S + M_Ed[E];
                2: S := S + W_Ed[E];
                3: S := S + S_Ed[E];
              else
                S := S + '#### ';
              end
            else if I = 1 then
              S := S + W_Ed[E]
            else
              S := S + M_Ed[E];
        end else
          if H = 0 then
            S := S + E_Ds[E]
          else
            S := S + U_Hd[H] + E_Ds[E];
        if I <> 0 then
        begin
          if FmtFlags and nsShort = 0 then
            S := S + M_Tr[I,Result]
          else
            S := S + M_Tr[I,0];
        end;
      end;
    end;
  end else
    S := 'нуль ';
end;

{ NumToRub возвращает денежную сумму прописью. Параметр V должен содержать
  численное значение денежной суммы в рублях. Сотые доли выражают копейки.
  Параметры RubFormat и CopFormat определяют формат записи соответственно
  рублей и копеек. Если CopFormat = nrNone, то сумма округляется до рублей и
  копейки не выводятся. Если RubFormat = nrNone, то рубли не выводятся, а к
  копейкам прибавляется число рублей, умноженное на 100. Если оба параметра
  равны nrNone, просто возвращается строка, содержащая число V. Константа
  nrShTriad комбинируется с другими константами с помощью побитовой операции
  "or". Возвращаемая строка начинается с большой буквы. Если денежная сумма
  отрицательная, строка заключается в круглые скобки. Эта функция написана
  после ознакомления с процедурой num_to_rub (N2R.pas) Николая Глушнева. }

const
  nrNumShort  = 1; {  Краткий числовой формат: "475084 руб." или "15 коп."  }
  nrShort     = 3; {  Краткий строчный формат: "Пять руб." или "десять коп."  }
  nrNumFull   = 0; {  Полный числовой формат: "342 рубля" или "25 копеек"  }
  nrFull      = 2; {  Полный строчный формат: "Один рубль" или "две копейки"  }
  nrShTriad   = 4; {  Краткая запись названий триад: тыс., млн., ...  }
  nrNone      = 8; {  Нет рублей, нет копеек или простая числовая запись  }

function Q_UIntToStrL(N: LongWord; Digits: Integer): string;
begin
  Result := IntToStr(N);
  if Length(Result) > Digits then
    Delete(Result, 1, Length(Result) - Digits)
  else
    Result := StringOfChar('0', Digits - Length(Result)) + Result;
end;

function NumToRub(V: Currency; RubFormat, CopFormat: LongWord): string;

var
  V1: Int64;
  S1,S2,S3,S4: string;
  Cp,I: Integer;
  Negative: Boolean;
begin
  if V >= 0 then
    Negative := False
  else
  begin
    Negative := True;
    V := -V;
  end;
  if RubFormat <> nrNone then
  begin
    if CopFormat <> nrNone then
    begin
      V1 := Trunc(V);
      Cp := Round(Frac(V)*100);
      if V1 <> 0 then
      begin
        if RubFormat and 1 = 0 then
        begin
          if RubFormat and 2 <> 0 then
          begin
            case NumToStrRus(V1,S1, nsFemale or (RubFormat and 4)) of
              1: S2 := 'гривна ';
              2: S2 := 'гривны ';
              3: S2 := 'гривен ';
            end;
          end else
          begin
            S1 := IntToStr(V1);
            I := V1 mod 100;
            if (I<10) or (I>20) then
            begin
              case I mod 10 of
                1: S2 := ' гривна ';
                2,3,4: S2 := ' гривны ';
              else
                S2 := ' гривен ';
              end;
            end else
              S2 := ' гривен ';
          end;
        end else
        begin
          if RubFormat and 2 <> 0 then
          begin
            NumToStrRus(V1,S1, nsFemale or (RubFormat and 4));
            S2 := 'грн. ';
          end else
          begin
            S1 := IntToStr(V1);
            S2 := ' грн. ';
          end;
        end;
      end else
      begin
        S1 := '';
        S2 := '';
      end;
      if CopFormat and 1 = 0 then
      begin
        if CopFormat and 2 <> 0 then
        begin
          case NumToStrRus(Cp,S3,nsFemale) of
            1: S4 := 'копейка';
            2: S4 := 'копейки';
            3: S4 := 'копеек';
          end;
        end else
        begin
          S3 := Q_UIntToStrL(Cp,2);
          I := Cp mod 100;
          if (I<10) or (I>20) then
          begin
            case I mod 10 of
              1: S4 := ' копейка';
              2,3,4: S4 := ' копейки';
            else
              S4 := ' копеек';
            end;
          end else
            S4 := ' копеек';
        end;
      end else
      begin
        if CopFormat and 2 <> 0 then
        begin
          NumToStrRus(Cp,S3,nsFemale);
          S4 := 'коп.';
        end else
        begin
          S3 := Q_UIntToStrL(Cp,2);
          S4 := ' коп.';
        end;
      end;
      if not Negative then
      begin
        Result := S1+S2+S3+S4;
        Result[1] := ToUpper(Result[1]);
      end
      else
      begin
        Result := '('+S1+S2+S3+S4+')';
        Result[2] := ToUpper(Result[2]);
      end;
    end else
    begin
      V1 := Round(V);
      if V1 <> 0 then
      begin
        if RubFormat and 1 = 0 then
        begin
          if RubFormat and 2 <> 0 then
          begin
            case NumToStrRus(V1,S1,nsFemale or (RubFormat and 4)) of
              1: S2 := 'гривна';
              2: S2 := 'гривны';
              3: S2 := 'гривен';
            end;
          end else
          begin
            S1 := IntToStr(V1);
            I := V1 mod 100;
            if (I<10) or (I>20) then
            begin
              case I mod 10 of
                1: S2 := ' гривна';
                2,3,4: S2 := ' гривны';
              else
                S2 := ' гривен';
              end;
            end else
              S2 := ' гривен';
          end;
        end else
        begin
          if RubFormat and 2 <> 0 then
          begin
            NumToStrRus(V1,S1,nsFemale or (RubFormat and 4));
            S2 := 'грн.';
          end else
          begin
            S1 := IntToStr(V1);
            S2 := ' грн.';
          end;
        end;
        S1[1] := ToUpper(S1[1]);
        if not Negative then
          Result := S1+S2
        else
          Result := '('+S1+S2+')';
      end else
        Result := '';
    end;
  end
  else if CopFormat <> nrNone then
  begin
    V1 := Round(V*100);
    if CopFormat and 1 = 0 then
    begin
      if CopFormat and 2 <> 0 then
      begin
        case NumToStrRus(V1,S1,nsFemale or (CopFormat and 4)) of
          1: S2 := 'копейка';
          2: S2 := 'копейки';
          3: S2 := 'копеек';
        end;
      end else
      begin
        S1 := IntToStr(V1);
        I := V1 mod 100;
        if (I<10) or (I>20) then
        begin
          case I mod 10 of
            1: S2 := ' копейка';
            2,3,4: S2 := ' копейки';
          else
            S2 := ' копеек';
          end;
        end else
          S2 := ' копеек';
      end;
    end else
    begin
      if CopFormat and 2 <> 0 then
      begin
        NumToStrRus(V1,S1,nsFemale or (CopFormat and 4));
        S2 := 'коп.';
      end else
      begin
        S1 := IntToStr(V1);
        S2 := ' коп.';
      end;
    end;
    S1[1] := ToUpper(S1[1]);
    if not Negative then
      Result := S1+S2
    else
      Result := '('+S1+S2+')';
  end
  else if not Negative then
    Result := FormatFloat('0.00',V)
  else
    Result := '('+FormatFloat('0.00',V)+')';
end;

function NumToGrn(V: Currency; RubFormat, CopFormat: LongWord): string;

var
  V1: Int64;
  S1,S2,S3,S4: string;
  Cp,I: Integer;
  Negative: Boolean;
begin
  if V >= 0 then
    Negative := False
  else
  begin
    Negative := True;
    V := -V;
  end;
  if RubFormat <> nrNone then
  begin
    if CopFormat <> nrNone then
    begin
      V1 := Trunc(V);
      Cp := Round(Frac(V)*100);
      if V1 <> 0 then
      begin
        if RubFormat and 1 = 0 then
        begin
          if RubFormat and 2 <> 0 then
          begin
            case NumToStrUkr(V1,S1, nsFemale or (RubFormat and 4)) of
              1: S2 := 'гривня ';
              2: S2 := 'гривні ';
              3: S2 := 'гривень ';
            end;
          end else
          begin
            S1 := IntToStr(V1);
            I := V1 mod 100;
            if (I<10) or (I>20) then
            begin
              case I mod 10 of
                1: S2 := ' гривня ';
                2,3,4: S2 := ' гривні ';
              else
                S2 := ' гривень ';
              end;
            end else
              S2 := ' гривень ';
          end;
        end else
        begin
          if RubFormat and 2 <> 0 then
          begin
            NumToStrUkr(V1,S1, nsFemale or (RubFormat and 4));
            S2 := 'грн. ';
          end else
          begin
            S1 := IntToStr(V1);
            S2 := ' грн. ';
          end;
        end;
      end else
      begin
        S1 := '';
        S2 := '';
      end;
      if CopFormat and 1 = 0 then
      begin
        if CopFormat and 2 <> 0 then
        begin
          case NumToStrUkr(Cp,S3,nsFemale) of
            1: S4 := 'копійка';
            2: S4 := 'копійки';
            3: S4 := 'копійок';
          end;
        end else
        begin
          S3 := Q_UIntToStrL(Cp,2);
          I := Cp mod 100;
          if (I<10) or (I>20) then
          begin
            case I mod 10 of
              1: S4 := ' копійка';
              2,3,4: S4 := ' копійки';
            else
              S4 := ' копійок';
            end;
          end else
            S4 := ' копійок';
        end;
      end else
      begin
        if CopFormat and 2 <> 0 then
        begin
          NumToStrUkr(Cp,S3,nsFemale);
          S4 := 'коп.';
        end else
        begin
          S3 := Q_UIntToStrL(Cp,2);
          S4 := ' коп.';
        end;
      end;
      if not Negative then
      begin
        Result := S1+S2+S3+S4;
        Result[1] := ToUpper(Result[1]);
      end
      else
      begin
        Result := '('+S1+S2+S3+S4+')';
        Result[2] := ToUpper(Result[2]);
      end;
    end else
    begin
      V1 := Round(V);
      if V1 <> 0 then
      begin
        if RubFormat and 1 = 0 then
        begin
          if RubFormat and 2 <> 0 then
          begin
            case NumToStrUkr(V1,S1,nsFemale or (RubFormat and 4)) of
              1: S2 := 'гривня';
              2: S2 := 'гривні';
              3: S2 := 'гривень';
            end;
          end else
          begin
            S1 := IntToStr(V1);
            I := V1 mod 100;
            if (I<10) or (I>20) then
            begin
              case I mod 10 of
                1: S2 := ' гривня';
                2,3,4: S2 := ' гривні';
              else
                S2 := ' гривень';
              end;
            end else
              S2 := ' гривень';
          end;
        end else
        begin
          if RubFormat and 2 <> 0 then
          begin
            NumToStrUkr(V1,S1,nsFemale or (RubFormat and 4));
            S2 := 'грн.';
          end else
          begin
            S1 := IntToStr(V1);
            S2 := ' грн.';
          end;
        end;
        S1[1] := ToUpper(S1[1]);
        if not Negative then
          Result := S1+S2
        else
          Result := '('+S1+S2+')';
      end else
        Result := '';
    end;
  end
  else if CopFormat <> nrNone then
  begin
    V1 := Round(V*100);
    if CopFormat and 1 = 0 then
    begin
      if CopFormat and 2 <> 0 then
      begin
        case NumToStrUkr(V1,S1,nsFemale or (CopFormat and 4)) of
          1: S2 := 'копійка';
          2: S2 := 'копійки';
          3: S2 := 'копійок';
        end;
      end else
      begin
        S1 := IntToStr(V1);
        I := V1 mod 100;
        if (I<10) or (I>20) then
        begin
          case I mod 10 of
            1: S2 := ' копійка';
            2,3,4: S2 := ' копійки';
          else
            S2 := ' копійок';
          end;
        end else
          S2 := ' копійок';
      end;
    end else
    begin
      if CopFormat and 2 <> 0 then
      begin
        NumToStrUkr(V1,S1,nsFemale or (CopFormat and 4));
        S2 := 'коп.';
      end else
      begin
        S1 := IntToStr(V1);
        S2 := ' коп.';
      end;
    end;
    S1[1] := ToUpper(S1[1]);
    if not Negative then
      Result := S1+S2
    else
      Result := '('+S1+S2+')';
  end
  else if not Negative then
    Result := FormatFloat('0.00',V)
  else
    Result := '('+FormatFloat('0.00',V)+')';
end;

procedure udf_UAHToStr(var Value: Double; Result: PAnsiChar); cdecl;
begin
  StrPCopy(Result, AnsiString(NumToGrn(Value, nrFull, nrNumFull)));
end;

function udf_Int_Quant(var QuantInt, QuantNum, QuantDiv: Int64): Int64; cdecl;
begin
  if QuantDiv <> 0 then
    Result := QuantInt + QuantNum div QuantDiv else
    Result := 0;
end;

procedure udf_Frac_Quant(var QuantInt, QuantNum, QuantDiv: Int64; Result: PAnsiChar); cdecl;
var
  I: Integer;
begin
  if QuantDiv <> 0 then
  begin
    I := (QuantInt * QuantDiv + QuantNum) mod QuantDiv;

    if I = 0 then
      StrPCopy(Result, EmptyAnsiStr)
    else
      StrPCopy(Result, AnsiString(Format('%d / %d', [I, QuantDiv])));
  end else
    StrPCopy(Result, EmptyAnsiStr);
end;

procedure udf_Fmt(AFmt, AArgs, Result: PAnsiChar); cdecl;
var
  LFmt: String;
  LString: TStringList;
  LArgsArray: array of TVarRec;
  I: Integer;
  LResult: string;
begin
  try
    LString := TStringList.Create;
    LString.Delimiter := '~';
    LString.StrictDelimiter := True;
    LString.DelimitedText := String(AArgs);
    try
      SetLength(LArgsArray, LString.Count);
      try
        for I := 0 to Pred(LString.Count) do
        begin
          LArgsArray[I].VType := vtAnsiString;
          AnsiString(LArgsArray[I].VAnsiString) := AnsiString(LString[I]);
        end;
        LFmt := String(AFmt);
        LResult := Format(LFmt, LArgsArray);
        StrPCopy(Result, AnsiString(LResult));
      finally
        SetLength(LArgsArray, 0);
        LArgsArray := nil;
      end;
    finally
      FreeAndNil(LString);
    end;
  except
    on E: Exception do
      StrPCopy(Result, AnsiString(E.Message));
  end;
end;

function udf_Hash(Source: PAnsiChar): Int64;
var
  Context: TSHA1Context;
  Digest: TSHA1Digest;
begin
  SHA1Init(Context);
  SHA1Update(Context, Source, StrLen(Source));
  SHA1Final(Context, Digest);
  Result := PInt64(@Digest)^;
end;

function StrReplace(Source: PAnsiChar; const StrOld, StrNew: PAnsiChar): PAnsiChar;
var
  StrOldLen: Integer;
  FoundStr: PAnsiChar;
  Temp: array[0..4096] of AnsiChar;
begin
  if StrComp(StrOld, StrNew) <> 0 then
  begin
    StrOldLen := StrLen(StrOld);

    FoundStr := StrPos(Source, StrOld);
    while FoundStr <> nil do
    begin
      StrCopy(Temp, PAnsiChar(FoundStr + StrOldLen));
      StrCopy(FoundStr, StrNew);
      StrCat(Source, Temp);
      FoundStr := StrPos(Source, StrOld);
    end;
  end;

  Result := Source;
end;

procedure udf_JSONToStr(Source, Result: PAnsiChar);
var
  Len: Integer;
begin
  Result^ := #0;
  Len := StrLen(Source);

  if Len > 0 then
  begin
    StrCopy(Result, Source);

    StrReplace(Result, '\"', '"');
    StrReplace(Result, '\b', #8#0);
    StrReplace(Result, '\f', #12#0);
    StrReplace(Result, '\n', #10#0);
    StrReplace(Result, '\r', #13#0);
    StrReplace(Result, '\t', #9#0);
    StrReplace(Result, '\\', '\');
  end;
end;

procedure udf_StrToJSON(Source, Result: PAnsiChar);
var
  I, Len: Integer;
  SubStr: array[0..2] of AnsiChar;
  Temp: array[0..4096] of AnsiChar;
begin
  Result^ := #0;
  Len := StrLen(Source);

  if Len > 0 then
  begin
    udf_JSONToStr(Source, Temp);

    for I := 0 to Len - 1 do
    begin
      FillChar(SubStr, SizeOf(SubStr), 0);

      case Temp[I] of
        '"': StrCopy(SubStr, '\"');
        '\': StrCopy(SubStr, '\\');
         #8: StrCopy(SubStr, '\b');
        #12: StrCopy(SubStr, '\f');
        #10: StrCopy(SubStr, '\n');
        #13: StrCopy(SubStr, '\r');
         #9: StrCopy(SubStr, '\t');
        else SubStr[0] := Temp[I];
      end;

      StrCat(Result, SubStr);
    end;
  end;
end;

end.

