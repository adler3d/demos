program Gtavity;
{<|Игра Gtavity|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
uses
  OpenGL,
  SysUtils,
  eXgine in'..\eXgine(v0.80)\eXgine.pas',
  Scene in'Scene.pas',
  GameApp in'GameApp.pas',
  GameUtils in'GameUtils.pas',
  Menu in'Menu.pas',
  GameMenu in'GameMenu.pas',
  GameVar in'GameVar.pas',
  GameSprites in'GameSprites.pas',
  GameRes in'GameRes.pas',
  GameMouse in'GameMouse.pas',
  GameSystem in'GameSystem.pas',
  PhysicSprites in'PhysicSprites.pas',
  GenImage in'GenImage.pas';

begin
  Randomize; App:=TApp.Create; App.Init; App.Run; App.ShutDown;
end.

