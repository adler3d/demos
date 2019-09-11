unit GameApp;
{<|Модуль от игры Gtavity|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface

uses
  eXgine,GameUtils,Scene,GameMenu,GameRes,GameSystem,OpenGL;
const
  UPS=100;
  Concurs='Landing';
  AppName='Gravity';
  AppVer='0.7';
  VSync:Boolean=True;
type
  TApp=class(TScene)
  private
    Debug:Boolean;
    Tag:Integer;
  public
    constructor Create;
    procedure Init;
    procedure Run;
    procedure ShutDown;
    procedure Render; override;
    procedure Update; override;
  end;
var
  App:TApp;
implementation
uses
  GameVar;
{ TApp }

constructor TApp.Create;
begin
  eX.SetProc(PROC_UPDATE,@Scene.Update);
  eX.SetProc(PROC_RENDER,@Scene.Render);
  eX.SetProc(PROC_MESSAGE,@Scene.UseMessage);
  eX.ActiveUpdate(True);
  if ParamCount=1 then Debug:=ParamStr(1)='-Debug' else Debug:=False;
end;

procedure TApp.Init;
var
  SM:TScreenMode;
begin
  ActivScene:=Self; SM:=GetScreenMode;
  wnd.Create(AppName,not Debug);
  wnd.Mode(True,SM.X,SM.Y,SM.BPP,SM.Freg);
  ogl.VSync(VSync); inp.MCapture(True);
  LoadRes; InitMenu; InitGame; Tag:=Round(UPS*3);
end;

procedure TApp.Render;
begin
  ogl.Clear(True,True); ogl.Set2D(0,0,wnd.Width,wnd.Height); ogl.Blend(BT_SUB);
  if Tag<UPS*2 then
    with wnd do
    begin
      if Tag<UPS then
      begin
        GMenu.DrawBack;
        glColor4d(0,0,0,(Tag/UPS)); DrawRect(0,0,Width,Height);
      end;
      if Tag>UPS then glColor4d(1,1,1,2-(Tag/UPS)) else
      begin
        glColor4d(1,1,1,(Tag/UPS)); ogl.Blend(BT_ADD);
      end;
      tex.Enable(IGDC); DrawQuads(Width/2,Height/2,512,512); tex.Disable;
    end;
end;

procedure TApp.Run;
begin
  eX.MainLoop(UPS);
end;

procedure TApp.ShutDown;
begin
  GMenu.Free;
  GSys.Free;
end;

procedure TApp.Update;
begin
  if Tag=0 then ActivScene:=GMenu;
  Dec(Tag); if Tag<UPS then GMenu.MoveBack;
end;

end.

