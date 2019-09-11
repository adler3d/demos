unit Scene;
{<|Вспомогательный модуль|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface
uses
  Windows,eXgine,SysUtils,Messages;
type
  TScene=class(TObject)
  public
    procedure Render; virtual; abstract;
    procedure Update; virtual; abstract;
  end;

procedure Update;
procedure Render;
procedure UseMessage(Msg:LongWord; wP,lP:Integer);

var
  ActivScene:TScene;

implementation

uses GameApp;

procedure Update;
begin
  if ActivScene<>nil then ActivScene.Update else if inp.Down(27) then eX.Quit;
end;

procedure Render;
begin
  if ActivScene<>nil then ActivScene.Render;
end;

procedure UseMessage(Msg:LongWord; wP,lP:Integer);
begin
  if (msg=WM_KEYUP)then
  if (wp=VK_SNAPSHOT) then
  begin
    if not DirectoryExists('..\ScreenShots') then MkDir('..\ScreenShots');
    ogl.ScreenShot(PChar('..\ScreenShots\'+AppName+FormatDateTime('hh-mm-ss-zzz',Time)+'.bmp'));
    inp.Reset;
  end;
end;

end.

