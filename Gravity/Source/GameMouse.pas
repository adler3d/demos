unit GameMouse;
{<|Вспомогательный модуль|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface
uses
  Windows,eXgine,OpenGL,ASDVector,GameUtils;

procedure InitMouse(X,Y:Real);
procedure RenderMouse(Img:TTexture);
procedure UpdateMouse;
function GetMousePos:TVector;
function MouseMoved:Boolean;

implementation
var
  MX,MY:Real;
  Moved:Boolean;

procedure InitMouse(X,Y:Real);
begin
  MX:=X; MY:=Y;
end;

procedure RenderMouse(Img:TTexture);
begin
  ogl.Blend(BT_SUB);
  tex.Enable(Img); glColor3d(1,1,1);
  DrawRect(MX,MY,32,32);
  tex.Disable;
end;

procedure UpdateMouse;
begin
  with wnd,inp.MDelta do
  begin
    Moved:=(X<>Y)or(X<>0);
    MX:=MX+X;
    MY:=MY+Y;
    if MX<0 then MX:=0; if MY<=0 then MY:=0;
    if MX>Width then MX:=Width; if MY>Height then MY:=Height;
  end;
end;

function GetMousePos:TVector;
begin
  Result:=MakeVector(MX,MY);
end;

function MouseMoved:Boolean;
begin
  Result:=Moved;
end;

end.

 