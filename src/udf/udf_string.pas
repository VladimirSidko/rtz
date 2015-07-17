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
{ ��������� ��� ��������� FmtFlags (�� ����� ���������� � ������� "or"): }

  nsMale    = 1;    {  ������� ���  }
  nsFemale  = 2;    {  ������� ���  }
  nsMiddle  = 3;    {  ������� ���  }

  nsFull    = 0;    {  ������ �������� �����:  ������, �������, ... }
  nsShort   = 4;    {  ������� �������� �����:  ���., ���., ... }

{ ������������ �������� ������� Q_NumToStr: }

  rfmFirst  = 1;    {  ������ �����: "���� ����" ��� "�������� ���� �����"  }
  rfmSecond = 2;    {  ������ �����: "��� �����" ��� "������ �����"  }
  rfmThird  = 3;    {  ������ �����: "����� ������" ��� "������ �����"  }

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

{ NumToStr ��������� � ������ S �����, ���������� ���������� N, ����������
  ������� (��-������). �������� FmtFlags ������ ������ �������������� �����
  � ������. ������� NumToStr ���������� ����� �����, � ������� ������ ������
  ��������� �� ������ ������ ����� (��. ����������� � ���������� rfmXXXX).
  ������ S ������ ������������� ��������. }

function NumToStrRus(N: Int64; var S: string; FmtFlags: LongWord): Integer;

const
  M_Ed: array [1..9] of string =
    ('���� ','��� ','��� ','������ ','���� ','����� ','���� ','������ ','������ ');
  W_Ed: array [1..9] of string =
    ('���� ','��� ','��� ','������ ','���� ','����� ','���� ','������ ','������ ');
  S_Ed: array [1..9] of string =
    ('���� ','��� ','��� ','������ ','���� ','����� ','���� ','������ ','������ ');
  E_Ds: array [0..9] of string =
    ('������ ','����������� ','���������� ','���������� ','������������ ',
     '���������� ','����������� ','���������� ','������������ ','������������ ');
  D_Ds: array [2..9] of string =
    ('�������� ','�������� ','����� ','��������� ','���������� ','��������� ',
     '����������� ','��������� ');
  U_Hd: array [1..9] of string =
    ('��� ','������ ','������ ','��������� ','������� ','�������� ','������� ',
     '��������� ','��������� ');
  M_Tr: array[1..6,0..3] of string =
    (('���. ','������ ','������ ','����� '),
     ('���. ','������� ','�������� ','��������� '),
     ('����. ','�������� ','��������� ','���������� '),
     ('����. ','�������� ','��������� ','���������� '),
     ('�����. ','����������� ','������������ ','������������� '),
     ('�����. ','����������� ','������������ ','������������� '));
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
        S := '����� ';
      end else
      begin                                 { -9.223.372.036.854.775.808 }
        if FmtFlags and nsShort = 0 then
          S := '����� ������ ������������� ������ �������� ��� ������������'+
            ' ������ ��������� ��� ��������� �������� ����� ����������'+
            ' ��������� ��������� ������ �������� ������� ��������� ����'+
            ' ����� ��������� ������ '
        else
          S := '����� ������ �����. ������ �������� ��� �����. ������'+
            ' ��������� ��� ����. �������� ����� ����. ��������� ���������'+
            ' ������ ���. ������� ��������� ���� ���. ��������� ������ ';
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
    S := '���� ';
end;

function NumToStrUkr(N: Int64; var S: string; FmtFlags: LongWord): Integer;

const
  M_Ed: array [1..9] of string =
    ('���� ','��� ','��� ','������ ','�`��� ','����� ','�� ','��� ','���`��� ');
  W_Ed: array [1..9] of string =
    ('���� ','�� ','��� ','������ ','�`��� ','����� ','�� ','��� ','���`��� ');
  S_Ed: array [1..9] of string =
    ('���� ','��� ','��� ','������ ','�`��� ','����� ','�� ','��� ','���`��� ');
  E_Ds: array [0..9] of string =
    ('������ ','���������� ','���������� ','���������� ','������������ ',
     '�`��������� ','����������� ','��������� ','���������� ','���`��������� ');
  D_Ds: array [2..9] of string =
    ('�������� ','�������� ','����� ','�`������� ','��������� ','������� ',
     '�������� ','���`������ ');
  U_Hd: array [1..9] of string =
    ('��� ','���� ','������ ','��������� ','�`����� ','������� ','����� ',
     '������ ','���`����� ');
  M_Tr: array[1..6,0..3] of string =
    (('���. ','������ ','������ ','����� '),
     ('���. ','������ ','������� ','������� '),
     ('����. ','������ ','������� ','������� '),
     ('����. ','�������� ','��������� ','��������� '),
     ('�����. ','��������� ','���������� ','���������� '),
     ('�����. ','��������� ','���������� ','���������� '));
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
        S := '����� ';
      end else
      begin                                 { -9.223.372.036.854.775.808 }
        if FmtFlags and nsShort = 0 then
          S := '����� ������ ������������� ������ �������� ��� ������������'+
            ' ������ ��������� ��� ��������� �������� ����� ����������'+
            ' ��������� ��������� ������ �������� ������� ��������� ����'+
            ' ����� ��������� ������ '
        else
          S := '����� ������ �����. ������ �������� ��� �����. ������'+
            ' ��������� ��� ����. �������� ����� ����. ��������� ���������'+
            ' ������ ���. ������� ��������� ���� ���. ��������� ������ ';
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
    S := '���� ';
end;

{ NumToRub ���������� �������� ����� ��������. �������� V ������ ���������
  ��������� �������� �������� ����� � ������. ����� ���� �������� �������.
  ��������� RubFormat � CopFormat ���������� ������ ������ ��������������
  ������ � ������. ���� CopFormat = nrNone, �� ����� ����������� �� ������ �
  ������� �� ���������. ���� RubFormat = nrNone, �� ����� �� ���������, � �
  �������� ������������ ����� ������, ���������� �� 100. ���� ��� ���������
  ����� nrNone, ������ ������������ ������, ���������� ����� V. ���������
  nrShTriad ������������� � ������� ����������� � ������� ��������� ��������
  "or". ������������ ������ ���������� � ������� �����. ���� �������� �����
  �������������, ������ ����������� � ������� ������. ��� ������� ��������
  ����� ������������ � ���������� num_to_rub (N2R.pas) ������� ��������. }

const
  nrNumShort  = 1; {  ������� �������� ������: "475084 ���." ��� "15 ���."  }
  nrShort     = 3; {  ������� �������� ������: "���� ���." ��� "������ ���."  }
  nrNumFull   = 0; {  ������ �������� ������: "342 �����" ��� "25 ������"  }
  nrFull      = 2; {  ������ �������� ������: "���� �����" ��� "��� �������"  }
  nrShTriad   = 4; {  ������� ������ �������� �����: ���., ���., ...  }
  nrNone      = 8; {  ��� ������, ��� ������ ��� ������� �������� ������  }

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
              1: S2 := '������ ';
              2: S2 := '������ ';
              3: S2 := '������ ';
            end;
          end else
          begin
            S1 := IntToStr(V1);
            I := V1 mod 100;
            if (I<10) or (I>20) then
            begin
              case I mod 10 of
                1: S2 := ' ������ ';
                2,3,4: S2 := ' ������ ';
              else
                S2 := ' ������ ';
              end;
            end else
              S2 := ' ������ ';
          end;
        end else
        begin
          if RubFormat and 2 <> 0 then
          begin
            NumToStrRus(V1,S1, nsFemale or (RubFormat and 4));
            S2 := '���. ';
          end else
          begin
            S1 := IntToStr(V1);
            S2 := ' ���. ';
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
            1: S4 := '�������';
            2: S4 := '�������';
            3: S4 := '������';
          end;
        end else
        begin
          S3 := Q_UIntToStrL(Cp,2);
          I := Cp mod 100;
          if (I<10) or (I>20) then
          begin
            case I mod 10 of
              1: S4 := ' �������';
              2,3,4: S4 := ' �������';
            else
              S4 := ' ������';
            end;
          end else
            S4 := ' ������';
        end;
      end else
      begin
        if CopFormat and 2 <> 0 then
        begin
          NumToStrRus(Cp,S3,nsFemale);
          S4 := '���.';
        end else
        begin
          S3 := Q_UIntToStrL(Cp,2);
          S4 := ' ���.';
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
              1: S2 := '������';
              2: S2 := '������';
              3: S2 := '������';
            end;
          end else
          begin
            S1 := IntToStr(V1);
            I := V1 mod 100;
            if (I<10) or (I>20) then
            begin
              case I mod 10 of
                1: S2 := ' ������';
                2,3,4: S2 := ' ������';
              else
                S2 := ' ������';
              end;
            end else
              S2 := ' ������';
          end;
        end else
        begin
          if RubFormat and 2 <> 0 then
          begin
            NumToStrRus(V1,S1,nsFemale or (RubFormat and 4));
            S2 := '���.';
          end else
          begin
            S1 := IntToStr(V1);
            S2 := ' ���.';
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
          1: S2 := '�������';
          2: S2 := '�������';
          3: S2 := '������';
        end;
      end else
      begin
        S1 := IntToStr(V1);
        I := V1 mod 100;
        if (I<10) or (I>20) then
        begin
          case I mod 10 of
            1: S2 := ' �������';
            2,3,4: S2 := ' �������';
          else
            S2 := ' ������';
          end;
        end else
          S2 := ' ������';
      end;
    end else
    begin
      if CopFormat and 2 <> 0 then
      begin
        NumToStrRus(V1,S1,nsFemale or (CopFormat and 4));
        S2 := '���.';
      end else
      begin
        S1 := IntToStr(V1);
        S2 := ' ���.';
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
              1: S2 := '������ ';
              2: S2 := '����� ';
              3: S2 := '������� ';
            end;
          end else
          begin
            S1 := IntToStr(V1);
            I := V1 mod 100;
            if (I<10) or (I>20) then
            begin
              case I mod 10 of
                1: S2 := ' ������ ';
                2,3,4: S2 := ' ����� ';
              else
                S2 := ' ������� ';
              end;
            end else
              S2 := ' ������� ';
          end;
        end else
        begin
          if RubFormat and 2 <> 0 then
          begin
            NumToStrUkr(V1,S1, nsFemale or (RubFormat and 4));
            S2 := '���. ';
          end else
          begin
            S1 := IntToStr(V1);
            S2 := ' ���. ';
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
            1: S4 := '������';
            2: S4 := '������';
            3: S4 := '������';
          end;
        end else
        begin
          S3 := Q_UIntToStrL(Cp,2);
          I := Cp mod 100;
          if (I<10) or (I>20) then
          begin
            case I mod 10 of
              1: S4 := ' ������';
              2,3,4: S4 := ' ������';
            else
              S4 := ' ������';
            end;
          end else
            S4 := ' ������';
        end;
      end else
      begin
        if CopFormat and 2 <> 0 then
        begin
          NumToStrUkr(Cp,S3,nsFemale);
          S4 := '���.';
        end else
        begin
          S3 := Q_UIntToStrL(Cp,2);
          S4 := ' ���.';
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
              1: S2 := '������';
              2: S2 := '�����';
              3: S2 := '�������';
            end;
          end else
          begin
            S1 := IntToStr(V1);
            I := V1 mod 100;
            if (I<10) or (I>20) then
            begin
              case I mod 10 of
                1: S2 := ' ������';
                2,3,4: S2 := ' �����';
              else
                S2 := ' �������';
              end;
            end else
              S2 := ' �������';
          end;
        end else
        begin
          if RubFormat and 2 <> 0 then
          begin
            NumToStrUkr(V1,S1,nsFemale or (RubFormat and 4));
            S2 := '���.';
          end else
          begin
            S1 := IntToStr(V1);
            S2 := ' ���.';
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
          1: S2 := '������';
          2: S2 := '������';
          3: S2 := '������';
        end;
      end else
      begin
        S1 := IntToStr(V1);
        I := V1 mod 100;
        if (I<10) or (I>20) then
        begin
          case I mod 10 of
            1: S2 := ' ������';
            2,3,4: S2 := ' ������';
          else
            S2 := ' ������';
          end;
        end else
          S2 := ' ������';
      end;
    end else
    begin
      if CopFormat and 2 <> 0 then
      begin
        NumToStrUkr(V1,S1,nsFemale or (CopFormat and 4));
        S2 := '���.';
      end else
      begin
        S1 := IntToStr(V1);
        S2 := ' ���.';
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

