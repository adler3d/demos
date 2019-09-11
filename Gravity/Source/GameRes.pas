unit GameRes;
{<|Модуль от игры Gtavity|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface
uses eXgine;

procedure LoadRes;
procedure Load(out Img:TTexture; FileName:string);
implementation

uses GenImage,GameVar;

procedure Load(out Img:TTexture; FileName:string);
begin
  Img:=Tex.Load(PChar(TexPath+FileName));
end;

procedure LoadRes;
begin
  Load(Cursor,'Cursor.tga');
  Load(Logo,'Logo.tga');
  Load(Smoke,'Smoke.tga');
  Load(Cell,'Cell.bmp');
  Load(Light,'Light.tga');
  Load(flame,'flame.tga');
  Load(IGDC,'IGDC.jpg');
  Bool:=Gen(BoolPathImage(256));
end;

end.

