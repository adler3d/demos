unit GenImage;
{<|Вспомогательный модуль|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface
uses
  eXgine,GameUtils,OpenGL;
const
  GL_RGB8=$8051;
  GL_RGBA8=$8058;
  GL_BGR=$80E0;
  GL_BGRA=$80E1;
type
  TDrawMethod=(dmNone,dmAdd,dmNot);

  TATF=class
  private
    function BytesPerScanline(PixelsPerScanline,BitsPerPixel,
      Alignment:Integer):Longint;
    function GetScanLine(Row:Integer):Pointer;
    function GetPixels(X,Y:Integer):PRGBA;
  public
    Name:string;
    W:Integer;
    H:Integer;
    BPP:Integer;
    TexMem:Pointer;
    TexImage:TTexture;
    procedure DrawRect(X,Y,R:Integer; Color:TRGBA; Method:TDrawMethod=
      dmNone);
    constructor Create(Size:Integer);
    destructor Destroy; override;
    property Pixels[X,Y:Integer]:PRGBA read GetPixels;
  end;

function Gen(F:TATF):TTexture;
function BoolImage(Size:Integer):TATF;
function BoolPathImage(Size:Integer):TATF;
function BackImage(Size:Integer):TATF;

implementation

function BackImage(Size:Integer):TATF;
var
  I,J:Integer;
  Temp:Real;
  M:PWrapRGBA;
  Color:TRGBA;
begin
  Result:=TATF.Create(Size); Result.Name:='Back.ASD';
  with Result do
  begin
    for I:=0 to Size-1 do
      for J:=0 to Size-1 do
        with Pixels[I,J]^ do
        begin
          B:=Round(Sin((I*Pi)/Size)*255);
          G:=Round(Sin((J*Pi)/Size)*255);
          R:=0;
          A:=255;
        end;
  end;
end;

function BoolPathImage(Size:Integer):TATF;
const
  cR=1/25;
  cD=3/9; N=7;
var
  I,R:Integer;
  SD2,D:Real;
begin
  Result:=BoolImage(Size); Result.Name:='BoolPath.ASD';
  SD2:=Size/2; R:=Round(Size*cR); D:=cD*Size;
  for I:=1 to N do
    Result.DrawRect(Round(SD2+D*Cos(I*Pi*2/N)),Round(SD2+D*Sin(I*Pi*2/N)),R,clBlack);
end;

function BoolImage(Size:Integer):TATF;
var
  I,J:Integer;
  Temp:Real;
  M:^TWrapRGBA;
  Color:TRGBA;
begin
  Result:=TATF.Create(Size); Result.Name:='Bool.ASD';
  with Result do
  begin
    for I:=0 to Size-1 do
      for J:=0 to Size-1 do
        with Pixels[I,J]^ do
        begin
          A:=0;
          Temp:=(Sqrt(Sqr(I-(Size div 2))+Sqr(J-(Size div 2)))*2/
            Size);
          if Temp>1 then
            Continue;
          R:=255-Round(255*Temp*Temp);
          G:=R;
          B:=R;
          A:=255-Round(255*IntPower(Temp,20));
        end;
  end;
end;

function Gen(F:TATF):TTexture;
begin                       
  Result:=Tex.Create(PChar(F.Name),GL_RGBA8,GL_BGRA,F.W,F.H,F.TexMem);
end;

{ TATF }

constructor TATF.Create(Size:Integer);
begin
  W:=Size;
  H:=Size;
  BPP:=32;
  GetMem(TexMem,Size*Size*4);
end;

function TATF.BytesPerScanline(PixelsPerScanline,BitsPerPixel,
  Alignment:Longint):Longint;
begin
  Dec(Alignment);
  Result:=((PixelsPerScanline*BitsPerPixel)+Alignment)and not Alignment;
  Result:=Result div 8;
end;

function TATF.GetScanLine(Row:Integer):Pointer;
begin
  if H>0 then
    Row:=H-Row-1;
  Integer(Result):=Integer(TexMem)+Row*BytesPerScanline(W,BPP,32);
end;

destructor TATF.Destroy;
begin
  FreeMem(TexMem);
  inherited;
end;

function TATF.GetPixels(X,Y:Integer):PRGBA;
begin
  Result:=@PWrapRGBA(GetScanLine(Y))^[X];
end;

procedure TATF.DrawRect(X,Y,R:Integer; Color:TRGBA; Method:TDrawMethod);
var
  I,J:Integer;
begin
  R:=R-1;
  case Method of
    dmNone:
      for I:=X-R to X+R do
        for J:=Y-R to Y+R do
          Pixels[I,J]^:=Color;
    dmAdd:
      for I:=X-R to X+R do
        for J:=Y-R to Y+R do
          with Pixels[I,J]^ do
          begin
            R:=(R+Color.R)div 2;
            G:=(G+Color.G)div 2;
            B:=(B+Color.B)div 2;
            A:=(A+Color.A)div 2;
          end;
    dmNot:
      for I:=X-R to X+R do
        for J:=Y-R to Y+R do
          with Pixels[I,J]^ do
          begin
            R:=not R;
            G:=not G;
            B:=not B;
          end;
  end;
end;

end.

