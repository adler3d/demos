unit ASDVector;
{<|Модуль библиотеки ASDEngine|>}
{<|Дата создания 08.07.07|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 22.03.08|>}
interface
{$D-}
Uses Windows;

type
  PVector = ^TVector;
  TVector = record
    X, Y: Real;
  end;

  PVectorAngle = ^TVectorAngle;
  TVectorAngle = record
    Alfa, Dlina: Real;
  end;

  PLine = ^TLine;
  TLine = record
    A, B: TVector;
  end;

function MakeVector(X, Y: Real): TVector;
function MakeVectorAngle(Alfa, Dlina: Real): TVectorAngle;
function MakeLine(A, B: TVector): TLine;

function VectorAdd(A, B: TVector): TVector;
function VectorMul(V: TVector; Value: Real): TVector;
function VectorDiv(V: TVector; Value: Real): TVector;
function VectorSub(A, B: TVector): TVector;

function VectorMagnitude(V: TVector): Real;
function VectorGetAlfa(V: TVector): Real;

function VectorAngleToVector(V: TVectorAngle): TVector;
function VectorToVectorAngle(V: TVector): TVectorAngle;

function VectorNormal(V: TVector): TVector;

function VectorSetAlfa(V: TVector; Alfa: Real): TVector;
function VectorAddAlfa(V: TVector; Alfa: Real): TVector;
function VectorSetDlina(V: TVector; Dlina: Real): TVector;
function VectorAddDlina(V: TVector; Dlina: Real): TVector;

function VectorEquel(V1, V2: TVector): Boolean;

function Prompting(A, B: TVector; const Vector: TVector; AddAlfa: Real):
  TVector;
function PromptingAlfa(A, B: TVector; const Vector: TVector; AddAlfa: Real):
  Real;

function RndReal(Min, Max: Real; Step: Real = 0.1): Real;
function RndVector(MaxMag:Real=1; MinMag:Real=0; Step:Real=0.001):TVector;

function VectorToPoint(V: TVector): TPoint;
function PointToVector(P: TPoint): TVector;

{function VectorToStr(V: TVector): string;
function StrToVector(S: string): TVector;}

function VectorCompareAlfa(VA, VB: TVector): Real;
function VectorCompareDlina(VA, VB: TVector): Real;

function VectorABDlina(A,B:TVector):Real;

function VectorRot(Vec, Base: TVector): TVector;
function VectorUnRot(Vec, Base: TVector): TVector;

function ArcTan2(const Y, X: Extended): Extended;
procedure SinCos(const Theta: Extended; var Sin, Cos: Extended);

const
  NulVectorAngle: TVectorAngle = (Alfa: 0; Dlina: 0);
  NulVector: TVector = (X: 0.000; Y: 0.000);
implementation

function VectorRot(Vec, Base: TVector): TVector;
var
  M:Real;
begin
  M:=Sqrt((Base.X)*(Base.X) + (Base.Y)*(Base.Y));
  Result.X := ((Vec.X * Base.X) + (Vec.Y * Base.Y))/M;
  Result.Y := ((Vec.X * -Base.Y) + (Vec.Y * Base.X))/M;
end;

function VectorUnRot(Vec, Base: TVector): TVector;
var
  M:Real;
begin
  Result:=NulVector;
  M:=Sqrt((Base.X)*(Base.X) + (Base.Y)*(Base.Y));
  if M=0 then Exit;
  Result.X := ((Vec.X * Base.X) + (Vec.Y * -Base.Y))/M;
  Result.Y := ((Vec.X * Base.Y) + (Vec.Y * Base.X))/M;
end;

procedure SinCos(const Theta: Extended; var Sin, Cos: Extended);
asm
        FLD     Theta
        FSINCOS
        FSTP    tbyte ptr [edx]    // Cos
        FSTP    tbyte ptr [eax]    // Sin
        FWAIT
end;

function ArcTan2(const Y, X: Extended): Extended;
asm
        FLD     Y
        FLD     X
        FPATAN
        FWAIT
end;

function VectorABDlina(A,B:TVector):Real;
begin
  Result := ((A.X - B.X) * (A.X - B.X) + (A.Y - B.Y) * (A.Y - B.Y));
end;

function RndReal(Min, Max: Real; Step: Real = 0.1): Real;
begin
  Result := Random(Round((Max - Min) / Step)) * Step + Min;
end;

function RndVector(MaxMag,MinMag,Step:Real):TVector;
var
  A,M:Real;
begin
  A:=RndReal(0,Pi*2,Step); M:=RndReal(MinMag,MaxMag,Step);
  Result.X:=M*Cos(A); Result.Y:=M*Sin(A);
end;

function VectorToPoint(V: TVector): TPoint;
begin
  Result.X := Round(V.X);
  Result.Y := Round(V.Y);
end;

function PointToVector(P: TPoint): TVector;
begin
  Result.X := P.X;
  Result.Y := P.Y;
end;

{function PromptingAlfa(A, B: TVector; const Vector: TVector; AddAlfa: Real):
  Real;
  function Moderne(mode, dive: real): Real;
  begin
    Result := mode - (dive * trunc(mode / dive));
  end;
var
  Z, Go: Real;
  V: TVectorAngle;
const
  Rg: Real = (Pi / 180);
begin
  Result:=0;
  V := VectorToVectorAngle(Vector);
  V.Alfa := V.Alfa / Rg;
  Z := Arctan2((B.Y - A.Y), (B.X - A.X)) / Rg;
  Go := Moderne((ABS(Z - V.Alfa)), 360);
  if (Z >= V.Alfa) and (Go <= 180) then
    Result := +AddAlfa;
  if (Z < V.Alfa) and (Go < 180) then
    Result := -AddAlfa;
  if (Z >= V.Alfa) and (Go > 180) then
    Result := -AddAlfa;
  if (Z < V.Alfa) and (Go > 180) then
    Result := +AddAlfa;
end;}

function PromptingAlfa(A, B: TVector; const Vector: TVector; AddAlfa: Real):
  Real;
  function Moderne(mode, dive: real): Real;
  begin
    Result := mode - (dive * trunc(mode / dive));
  end;
var
  TAlfa, SAlfa: Real;
  V: TVector;
begin
  V := VectorSub(A, B);
  TAlfa := VectorGetAlfa(V);
  SAlfa := VectorGetAlfa(Vector);
  if Abs(TAlfa - SAlfa) > Pi then
  begin
    if TAlfa < SAlfa then
      TAlfa := TAlfa + (2 * Pi)
    else
      SAlfa := SAlfa + (2 * Pi);
  end;
  if Abs(TAlfa - SAlfa) >= AddAlfa then
  begin
    if TAlfa < SAlfa then
      Result := +AddAlfa
    else
      Result := -AddAlfa;
  end
  else
    Result := 0;
end;

function Prompting(A, B: TVector; const Vector: TVector; AddAlfa: Real):
  TVector;
  function Moderne(mode, dive: real): Real;
  begin
    Result := mode - (dive * trunc(mode / dive));
  end;
var
  PAlfa, Alfa, AddReal: Real;
  V: TVectorAngle;
const
  Rg: Real = (Pi / 180);
begin
  AddReal := 0;
  V := VectorToVectorAngle(Vector);
  V.Alfa := V.Alfa / Rg;
  PAlfa := Arctan2((B.Y - A.Y), (B.X - A.X)) / Rg;
  Alfa := Moderne((ABS(PAlfa - V.Alfa)), 360);
  if (PAlfa >= V.Alfa) and (Alfa <= 180) then
    AddReal := +AddAlfa;
  if (PAlfa < V.Alfa) and (Alfa < 180) then
    AddReal := -AddAlfa;
  if (PAlfa >= V.Alfa) and (Alfa > 180) then
    AddReal := -AddAlfa;
  if (PAlfa < V.Alfa) and (Alfa > 180) then
    AddReal := +AddAlfa;
  V.Alfa := V.Alfa * Rg;
  V.Alfa := V.Alfa + AddReal;
  Result := VectorAngleToVector(V);
end;

function VectorEquel(V1, V2: TVector): Boolean;
begin
  Result := (V1.X = V2.X) and (V1.Y = V2.Y);
end;

function VectorSetDlina(V: TVector; Dlina: Real): TVector;
var
  K: Real;
begin
  K := Dlina / Sqrt((V.X * V.X) + (V.Y * V.Y));
  Result.X := V.X*K;
  Result.Y := V.Y*K;
end;

function VectorAddDlina(V: TVector; Dlina: Real): TVector;
var
  K: Real;
begin
  K := Dlina / Sqrt((V.X * V.X) + (V.Y * V.Y));
  Result.X := V.X+(V.X*K);
  Result.Y := V.Y+(V.Y*K);
end;

function VectorSetAlfa(V: TVector; Alfa: Real): TVector;
var
  M: Real;
  S,C:Extended;
begin
  M := Sqrt((V.X * V.X) + (V.Y * V.Y));
  SinCos(Alfa,S,C);
  Result.X := M * C;
  Result.Y := M * S;
end;

function VectorAddAlfa(V: TVector; Alfa: Real): TVector;
Var
  S,C:Extended;
begin
  SinCos(Alfa,S,C);
  Result.X := V.X * C - V.Y * S;
  Result.Y := V.X * S + V.Y * C;
end;

function VectorNormal(V: TVector): TVector;
begin
  Result.Y := Sqrt((V.X * V.X) + (V.Y * V.Y));
  if Result.Y = 0 then
  begin
    Result.X := 0;
    Exit;
  end;
  Result.X := V.X / Result.Y;
  Result.Y := V.Y / Result.Y;
end;

function MakeVectorAngle(Alfa, Dlina: Real): TVectorAngle;
begin
  Result.Alfa := Alfa;
  Result.Dlina := Dlina;
end;

function VectorAngleToVector(V: TVectorAngle): TVector;
begin
  Result.X := Cos(V.Alfa) * V.Dlina;
  Result.Y := Sin(V.Alfa) * V.Dlina;
end;

function VectorToVectorAngle(V: TVector): TVectorAngle;
begin
  Result.Alfa := ArcTan2(V.Y, V.X);
  Result.Dlina := Sqrt((V.Y * V.Y) + (V.X * V.X));
end;

function MakeVector(X, Y: Real): TVector;
begin
  Result.X := X;
  Result.Y := Y;
end;

function VectorAdd(A, B: TVector): TVector;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

function VectorMul(V: TVector; Value: Real): TVector;
begin
  Result.X := V.X * Value;
  Result.Y := V.Y * Value;
end;

function VectorDiv(V: TVector; Value: Real): TVector;
begin
  Result.X := V.X / Value;
  Result.Y := V.Y / Value;
end;

function VectorMagnitude(V: TVector): Real;
begin
  Result := Sqrt((V.X * V.X) + (V.Y * V.Y));
end;

function VectorGetAlfa(V: TVector): Real;
begin
  Result := ArcTan2(V.Y, V.X);
end;

function VectorSub(A, B: TVector): TVector;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

{function VectorToStr(V: TVector): string;
begin
  Result := 'X:' + FloatToStrF(V.X, ffFixed, 8, 16);
  Result := Result + ' Y:' + FloatToStrF(V.Y, ffNumber, 8, 16);
end;

function StrToVector(S: string): TVector;
var
  P: Integer;
  S1, S2: string;
begin
  P := Pos(' ', S);
  S1 := Copy(S, 3, P - 3);
  S2 := Copy(S, P + 3, 128);
  Result.X := StrToFloat(S1);
  Result.Y := StrToFloat(S2);
end;}

function VectorCompareAlfa(VA, VB: TVector): Real;
var
  A, B: Real;
begin
  A := ArcTan2(VA.Y, VA.X);
  B := ArcTan2(VB.Y, VB.X);
  if Abs(A - B) >= Pi then
  begin
    if A < B then
      A := A + (2 * Pi)
    else
      B := B + (2 * Pi);
  end;
  Result := A - B;
end;

function VectorCompareDlina(VA, VB: TVector): Real;
var
  A, B: Real;
begin
  A := VectorMagnitude(VA);
  B := VectorMagnitude(VB);
  Result := A - B;
end;

function MakeLine(A, B: TVector): TLine;
begin
  Result.A := A;
  Result.B := B;
end;

end.
