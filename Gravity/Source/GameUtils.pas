unit GameUtils;
{<|Модуль от игры Gtavity|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface
uses
  Windows,eXgine,OpenGL;
type
  PRGBA=^TRGBA;
  PWrapRGB=^TWrapRGB;
  PWrapRGBA=^TWrapRGBA;

  TWrapRGB=array[0..0] of TRGB;
  TWrapRGBA=array[0..0] of TRGBA;
  TScreenMode=record
    X,Y,BPP,Freg:Integer;
  end;
function GetScreenMode:TScreenMode;
procedure DrawRect(X,Y,W,H:Real; Mode:GLenum=GL_QUADS);
procedure DrawRectEx(X,Y,W,H:Real; ScaledX:Real=0; ScaledY:Real=0);
procedure DrawQuads(X,Y,W,H:Real; A:Real=0);
function CursorPos:TPoint;
function UserName:string;
function IntPower(const Base:Extended; const Exponent:Integer):Extended;
const
  clRed:TRGBA=(R:255; G:0; B:0; A:255);
  clLime:TRGBA=(R:0; G:255; B:0; A:255);
  clBlue:TRGBA=(R:0; G:0; B:255; A:255);
  clWhite:TRGBA=(R:255; G:255; B:255; A:255);
  clBlack:TRGBA=(R:0; G:0; B:0; A:255);
implementation

function UserName:string;
var
  P:array[1..255] of Char;
  T:Cardinal;
begin
  FillChar(P,SizeOf(P),0); T:=SizeOf(P);
  GetUserName(@P,T);
  Result:=P;
end;

function Point(AX,AY:Integer):TPoint;
begin
  Result.X:=AX;
  Result.Y:=AY;
end;

function CursorPos:TPoint;
begin
  GetCursorPos(Result);
end;

function GetScreenMode:TScreenMode;
var
  DC:HDC;
begin
  DC:=GetDC(Wnd.Handle);
  Result.X:=GetDeviceCaps(DC,HORZRES);
  Result.Y:=GetDeviceCaps(DC,VERTRES);
  Result.BPP:=GetDeviceCaps(DC,BITSPIXEL);
  Result.Freg:=GetDeviceCaps(DC,VREFRESH);
end;

procedure DrawRect(X,Y,W,H:Real; Mode:GLenum);
begin
  glPushMatrix;
  glTranslated(X,Y,0);
  glBegin(Mode);
  glTexCoord2d(0,0); glVertex2f(0,0);
  glTexCoord2d(1,0); glVertex2f(W,0);
  glTexCoord2d(1,1); glVertex2f(W,H);
  glTexCoord2d(0,1); glVertex2f(0,H);
  glEnd;
  glPopMatrix;
end;

procedure DrawRectEx(X,Y,W,H:Real; ScaledX:Real=0; ScaledY:Real=0);
begin
  if ScaledX=0 then ScaledX:=1 else ScaledX:=W/ScaledX;
  if ScaledY=0 then ScaledY:=1 else ScaledY:=H/ScaledY;
  glPushMatrix;
  glTranslated(X,Y,0);
  glBegin(GL_QUADS);
  glTexCoord2d(0,ScaledY); glVertex2f(0,0);
  glTexCoord2d(ScaledX,ScaledY); glVertex2f(W,0);
  glTexCoord2d(ScaledX,0); glVertex2f(W,H);
  glTexCoord2d(0,0); glVertex2f(0,H);
  glEnd;
  glPopMatrix;
end;

procedure DrawQuads(X,Y,W,H:Real; A:Real=0);
begin
  W:=W/2;
  H:=H/2;
  glPushMatrix;
  glTranslated(X,Y,0);
  glRotated(A,0,0,1);
  glBegin(GL_QUADS);
  glTexCoord2d(0,0); glVertex2f(-W,-H);
  glTexCoord2d(1,0); glVertex2f(W,-H);
  glTexCoord2d(1,1); glVertex2f(W,H);
  glTexCoord2d(0,1); glVertex2f(-W,H);
  glEnd;
  glPopMatrix;
end;

function IntPower(const Base:Extended; const Exponent:Integer):Extended;
asm
        mov     ecx, eax
        cdq
        fld1                      { Result := 1 }
        xor     eax, edx
        sub     eax, edx          { eax := Abs(Exponent) }
        jz      @@3
        fld     Base
        jmp     @@2
@@1:    fmul    ST, ST            { X := Base * Base }
@@2:    shr     eax,1
        jnc     @@1
        fmul    ST(1),ST          { Result := Result * X }
        jnz     @@1
        fstp    st                { pop X from FPU stack }
        cmp     ecx, 0
        jge     @@3
        fld1
        fdivrp                    { Result := 1 / Result }
@@3:
        fwait
end;

end.

