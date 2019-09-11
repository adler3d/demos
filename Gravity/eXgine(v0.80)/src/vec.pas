unit vec;

interface

uses
  sys_main, eXgine;

type
  TVec = class(TInterface, IVector)
    function Create(X, Y, Z: Single): TVector3f; overload;
    function Create(X, Y: Single): TVector2f; overload;
    function Add(v1, v2: TVector3f): TVector3f;
    function Sub(v1, v2: TVector3f): TVector3f; 
    function Mult(v: TVector3f; x: Single): TVector3f; 
    function Length(v: TVector3f): Single; 
    function LengthQ(v: TVector3f): Single; 
    function Normalize(v: TVector3f): TVector3f; 
    function Dot(v1, v2: TVector3f): Single; 
    function Cross(v1, v2: TVector3f): TVector3f; 
    function Angle(v1, v2: TVector3f): Single; 
  end;

implementation

function ArcTan2(Y, X: Single): Single;
asm
  FLD     Y
  FLD     X
  FPATAN
  FWAIT
end;

function ArcCos(X: Single): Single;
begin
  if abs(X) > 1 then
    Result := 0
  else
    Result := ArcTan2(Sqrt(1 - X * X), X);
end;

function TVec.Create(X, Y, Z: Single): TVector3f;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
end;

function TVec.Create(X, Y: Single): TVector2f;
begin
  Result.X := X;
  Result.Y := Y;
end;

function TVec.Add(v1, v2: TVector3f): TVector3f;
begin
  Result.X := v1.X + v2.X;
  Result.Y := v1.Y + v2.Y;
  Result.Z := v1.Z + v2.Z;
end;

function TVec.Sub(v1, v2: TVector3f): TVector3f;
begin
  Result.X := v1.X - v2.X;
  Result.Y := v1.Y - v2.Y;
  Result.Z := v1.Z - v2.Z;
end;

function TVec.Mult(v: TVector3f; x: Single): TVector3f;
begin
  Result.X := v.X * x;
  Result.Y := v.Y * x;
  Result.Z := v.Z * x;
end;

function TVec.Length(v: TVector3f): Single;
begin
  Result := sqrt(sqr(v.X) + sqr(v.Y) + sqr(v.Z));
end;

function TVec.LengthQ(v: TVector3f): Single;
begin
  Result := sqr(v.X) + sqr(v.Y) + sqr(v.Z);
end;

function TVec.Normalize(v: TVector3f): TVector3f;
var
  len : Single;
begin
  len := Length(v);
  if len <> 0 then
    Result := Mult(v, 1/len)
  else
    Result := v;
end;

function TVec.Dot(v1, v2: TVector3f): Single;
begin
  Result := v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z;
end;

function TVec.Cross(v1, v2: TVector3f): TVector3f;
begin
  Result.X := v1.Y * v2.Z - v1.Z * v2.Y;
  Result.Y := v1.Z * v2.X - v1.X * v2.Z;
  Result.Z := v1.X * v2.Y - v1.Y * v2.X;
end;

function TVec.Angle(v1, v2: TVector3f): Single;
begin
  Result := ArcCos(Dot(Normalize(v1), Normalize(v2)));
end;

end.
