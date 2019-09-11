unit tex;

interface
{$I cfg.pas}
uses
  Windows, OpenGL,
  sys_main, eXgine;

const
  TEX_MAX = 16;
    
type
  TTexData = record
    ID     : Cardinal;
    Width  : Integer;
    Height : Integer;
    Ref    : Integer;
    Group  : Integer;
    Flag   : Boolean;
    MipMap : Boolean;
    Name   : string;
  end;

  TTex = class(TInterface, ITexture)
    destructor Destroy; override;
   private
   {$IFNDEF NO_FBO}
    fbo_frame   : DWORD;
    fbo_depth   : DWORD;
    fbo_curmode : Byte;
   {$ENDIF}
   public
    function  Create(Name: PChar; c, f, W, H: Integer; Data: Pointer; Clamp, MipMap: Boolean; Group: Integer): TTexture;
    function  Load(FileName: PChar; Clamp, MipMap: Boolean; Group: Integer): TTexture; overload;
    function  Load(Name: PChar; Mem: Pointer; Size: Integer; Clamp, MipMap: Boolean; Group: Integer): TTexture; overload;
    function  Load(FileName: PChar; var W, H, BPP: Integer; var Data: Pointer): Boolean; overload;
    function  Load(Name: PChar; Mem: Pointer; Size: Integer; var W, H, BPP: Integer; var Data: Pointer): Boolean; overload;
    procedure Free(var Data: Pointer); overload;
    procedure Free(ID: TTexture); overload;
    procedure Enable(ID: TTexture; Channel: Integer);
    procedure Disable(Channel: Integer);
    procedure Update_Begin(Group: Integer);
    procedure Update_End(Group: Integer);
    procedure Filter(FilterType: Integer; Group: Integer);
    procedure Render_Copy(ID: TTexture; X, Y, W, H, Format: Integer; Level: Integer);
   {$IFNDEF NO_FBO}
    function  Render_Init(TexSize: Integer): Boolean;
    procedure Render_Begin(ID: TTexture; Mode: TTexMode);
    procedure Render_End;
   {$ENDIF}
   public
  // менеджер текстур :)
    tex_man  : array of TTexData;
    tex_cur  : array [0..TEX_MAX] of TTexture; 
    tex_def  : TTexture; // Текстура по умолчанию

    procedure log(const Text: string);
    function Init: Boolean;
    function GetID(const Name: string): TTexture;
    function NewID(const Name: string; Data: Pointer; c, f, W, H, group: Integer; clamp, mipmap: Boolean; var idx: Integer): TTexture;
  end;

implementation

uses
  {$IFNDEF NO_TGA}g_tga,{$ENDIF}
  {$IFNDEF NO_BJG}g_bjg,{$ENDIF}
  eng, ogl;


destructor TTex.Destroy;
begin
// Удаление всех текстур
  if tex_def <> 0 then
    glDeleteTextures(1, @tex_def);
  Update_Begin(-1);
  Update_End(-1);
  {$IFNDEF NO_FBO}Render_Init(0);{$ENDIF}
  inherited;
end;

//== Создание текстуры по битовом массиву и другим параметрам
function TTex.Create(Name: PChar; c, f, W, H: Integer; Data: Pointer; Clamp, MipMap: Boolean; Group: Integer): TTexture;
var
  idx : Integer;
  str : string;
begin
  Result := GetID(Name);
  if Result = 0 then
  begin
    Result := NewID(Name, Data, c, f, W, H, group, Clamp, MipMap, idx);
    if Name = nil then
      str := 'empty texture ' + IntToStr(W) + 'x' + IntToStr(H)
    else
      str := Name;
    log('Create #' + IntToStr(Result) + #9 + str);
  end;
end;

//== Загрузка текстуры из TGA, BMP, JPG, GIF (без анимации) файлов
function TTex.Load(FileName: PChar; Clamp, MipMap: Boolean; Group: Integer): TTexture;
var
  idx     : Integer;
  W, H, b : Integer;
  Data    : Pointer;
  c, f    : Integer;
begin
  Result := 0;
  if FileName = '' then
    Exit;
  Result := GetID(FileName);
  if Result = 0 then
  try
    // Если текстура не загружена - грузим
    if not Load(FileName, W, H, b, Data) then
      Exit;

    // Любые текстуры на выходе преобразуются 8, 24 или 32 битные
    case b of
      8  : begin
             c := GL_LUMINANCE8;
             f := GL_LUMINANCE;
           end;
      24 : begin
             c := GL_RGB8;
             f := GL_BGR;
           end
    else
      c := GL_RGBA8;
      f := GL_BGRA;
    end;

    Result := NewID(FileName, Data, c, f, W, H, group, Clamp, MipMap, idx);
    Free(Data);

    log('Loaded #' + IntToStr(Result) + #9 + FileName);
  except
    log('Error Loading "' + FileName + '"');
    Result := 0;
  end;
end;

//== Загрузка текстуры из памяти (потока)
function TTex.Load(Name: PChar; Mem: Pointer; Size: Integer; Clamp, MipMap: Boolean; Group: Integer): TTexture;
var
  idx     : Integer;
  W, H, b : Integer;
  Data    : Pointer;
  c, f    : Integer;
begin
  Result := 0;
  if Name = '' then
    Exit;
  Result := GetID(Name);
  if Result = 0 then
  try
    // Если текстура не загружена - грузим
    if not Load(Name, Mem, Size, W, H, b, Data) then
      Exit;

    // Любые текстуры на выходе преобразуются 8, 24 или 32 битные
    case b of
      8  : begin
             c := GL_LUMINANCE8;
             f := GL_LUMINANCE;
           end;
      24 : begin
             c := GL_RGB8;
             f := GL_BGR;
           end
    else
      c := GL_RGBA8;
      f := GL_BGRA;
    end;

    Result := NewID(Name, Data, c, f, W, H, group, Clamp, MipMap, idx);
    Free(Data);

    log('Loaded #' + IntToStr(Result) + #9 + Name);
  except
    log('Error Loading "' + Name + '"');
    Result := 0;
  end;
end;

// Загрузка данных текстуры
function TTex.Load(FileName: PChar; var W, H, BPP: Integer; var Data: Pointer): Boolean;
begin
  if LowerCase(ExtractFileExt(FileName)) = 'tga' then
    Result := {$IFNDEF NO_TGA}LoadTGA(FileName, W, H, BPP, PByteArray(Data)){$ELSE}False{$ENDIF}
  else
    Result := {$IFNDEF NO_BJG}LoadBJG(FileName, W, H, BPP, PByteArray(Data)){$ELSE}False{$ENDIF};
  if not Result then
    log('Error Loading "' + FileName + '"');
end;

function TTex.Load(Name: PChar; Mem: Pointer; Size: Integer; var W, H, BPP: Integer; var Data: Pointer): Boolean;
begin
  if LowerCase(ExtractFileExt(Name)) = 'tga' then
    Result := {$IFNDEF NO_TGA}LoadTGAmem(Mem, Size, W, H, BPP, PByteArray(Data)){$ELSE}False{$ENDIF}
  else
    Result := {$IFNDEF NO_BJG}LoadBJGmem(Mem, Size, W, H, BPP, PByteArray(Data)){$ELSE}False{$ENDIF};
  if not Result then
    log('Error Loading "' + Name + '"');    
end;

procedure TTex.Free(var Data: Pointer);
begin
  try
    if Data <> nil then
      FreeMem(Data);
    Data := nil;
  except
    log('Error free data');
  end;
end;

//== Удаление текстуры (если она никем не занята)
procedure TTex.Free(ID: TTexture);
var
  i : Integer;
  s : string;
begin
  if (tex_def = ID) or not glIsTexture(ID) then
    Exit;
  s := '';
  for i := 0 to Length(tex_man) - 1 do
    if ID = tex_man[i].ID then
      with tex_man[i] do
      begin
        dec(Ref);
        if Ref <= 0 then
        begin
        // Удаляем запись о текстуре из менеджера
          s := tex_man[i].Name;
          tex_man[i] := tex_man[Length(tex_man) - 1];
          SetLength(tex_man, Length(tex_man) - 1);
          break;
        end else
          Exit // Текстура всё ещё используется
      end;
  log('Unload #' + IntToStr(ID) + #9 + s);
  glDeleteTextures(1, @ID);
end;

procedure TTex.Enable(ID: TTexture; Channel: Integer);
begin
  if not (Channel in [0..TEX_MAX]) then
    Exit;
  glActiveTextureARB(GL_TEXTURE0_ARB + Channel);
  glEnable(GL_TEXTURE_2D);
// если текстура не существует - включаем текстуру по умолчанию
  if (ID = 0) or not glIsTexture(ID) then
    ID := tex_def;
  if tex_cur[Channel] <> ID then
  begin
    glBindTexture(GL_TEXTURE_2D, ID);
    tex_cur[Channel] := ID;
  end;
end;

procedure TTex.Disable(Channel: Integer);
begin
  if not (Channel in [0..TEX_MAX]) then
    Exit;
  glActiveTextureARB(GL_TEXTURE0_ARB + Channel);
  glBindTexture(GL_TEXTURE_2D, tex_def);
  tex_cur[Channel] := tex_def;
  glDisable(GL_TEXTURE_2D);
end;

procedure TTex.Update_Begin(Group: Integer);
var
  i : Integer;
begin
//== Если группа = -1, то обновляются все текстуры без исключения
  for i := 0 to Length(tex_man) - 1 do
    if (Group and tex_man[i].Group > 0) or (Group = -1) then
    begin
      tex_man[i].Ref  := 0;
      tex_man[i].flag := True;
    end;
end;

procedure TTex.Update_End(Group: Integer);
var
  i : Integer;
begin
  i := 0;
  while i < Length(tex_man) do
    if ((Group and tex_man[i].Group > 0) or (Group = -1)) and tex_man[i].flag then
      Free(tex_man[i].ID)
    else
      inc(i);
end;

procedure TTex.Filter(FilterType: Integer; Group: Integer);
var
  i: Integer;
begin
  for i := 0 to Length(tex_man) - 1 do
    if (Group and tex_man[i].Group > 0) or (Group = -1) then
    begin
      Enable(tex_man[i].ID, 0);
      if tex_man[i].MipMap then
        case FilterType of
          FT_NONE :
            begin
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_NEAREST);
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1);
            end;
          FT_BILINEAR :
            begin
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1);
            end;
          FT_TRILINEAR :
            begin
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 1);
            end;
          FT_ANISOTROPY :
            begin
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
              glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, oogl.max_aniso);
            end;
        end
      else
        case FilterType of
          FT_NONE :
            begin
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
            end;
          FT_BILINEAR, FT_TRILINEAR, FT_ANISOTROPY : // без мипмапов - никакой нормальной фильтрации ;)
            begin
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
              glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            end;
        end;
    end;
  if (tex_cur[0] = tex_def) or (tex_cur[0] = 0) then
    Disable(0)
  else
    Enable(tex_cur[0], 0);
end;

procedure TTex.Render_Copy(ID: TTexture; X, Y, W, H, Format, Level: Integer);
begin
  Enable(ID, 0);
  glCopyTexImage2D(GL_TEXTURE_2D, Level, Format, X, Y, W, H, 0);
  if (tex_cur[0] = tex_def) or (tex_cur[0] = 0) then
    Disable(0)
  else
    Enable(tex_cur[0], 0);
end;

{$IFNDEF NO_FBO}
function TTex.Render_Init(TexSize: Integer): Boolean;
begin
// инициализация Frame Buffer
  Result := False;
  if GL_EXT_framebuffer_object then
    if TexSize = 0 then
    begin
      if fbo_frame <> 0 then glDeleteRenderbuffersEXT(1, @fbo_frame);
      if fbo_depth <> 0 then glDeleteRenderbuffersEXT(1, @fbo_depth);
      fbo_frame := 0;
      fbo_depth := 0;
    end else
    begin
      Render_Init(0);
      fbo_curmode := 0;
      glGenFramebuffersEXT(1, @fbo_frame);
      glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo_frame);
    // depth
      glGenRenderbuffersEXT(1, @fbo_depth);
      glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, fbo_depth);
      glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT24_ARB, TexSize, TexSize);
	    glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, fbo_depth);
      glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
      Result := True;
    end;
end;

procedure TTex.Render_Begin(ID: TTexture; Mode: TTexMode);
begin
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, fbo_frame);
  case Mode of
    TM_COLOR   : glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, ID, 0);
    TM_DEPTH   : glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, ID, 0);
  end;
  fbo_curmode := fbo_curmode or Byte(Mode);

  if glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT) <> GL_FRAMEBUFFER_COMPLETE_EXT then
  begin
    fbo_curmode := 0;
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
  end;
end;

procedure TTex.Render_End;
begin
  if fbo_curmode and Byte(TM_COLOR) > 0 then
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, 0, 0);
  if fbo_curmode and Byte(TM_DEPTH) > 0 then
    glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_TEXTURE_2D, 0, 0);
  if fbo_curmode > 0 then
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
  fbo_curmode := 0;
end;
{$ENDIF}

procedure TTex.log(const Text: string);
begin
  olog.Print(PChar('Texture : ' + Text));
end;

function TTex.Init: Boolean;
var
  pix    : array [0..15, 0..15] of Byte;
  i      : Integer;
begin
  Result := False;
  if not GL_ARB_multitexture then
  begin
    log('Fatal Error "GL_ARB_multitexture"');
    Exit;
  end;

//== Создаёт Default текстуру
  ZeroMemory(@pix, 16 * 16);
  for i := 0 to 15 do
  begin
    pix[ i,  0] := 255;
    pix[ i, 15] := 255;
    pix[ 0,  i] := 255;
    pix[15,  i] := 255;
    pix[ i,  i] := 255;
    pix[ i,  15 - i] := 255;
  end;

  glGenTextures(1, @tex_def);
  glBindTexture(GL_TEXTURE_2D, tex_def);
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  glTexImage2D(GL_TEXTURE_2D, 0, 1, 16, 16, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, @pix);
  Result := True;
end;

function TTex.GetID(const Name: string): TTexture;
var
  i : Integer;
begin
//== Если текстура с таким именем уже есть - ссылаемся на неё
  Result := 0;
  if Name <> '' then
    for i := 0 to Length(tex_man) - 1 do
      if Name = tex_man[i].Name then
        with tex_man[i] do
        begin
          flag := False;
          inc(Ref);
          Result := ID;
          Exit;
        end;
end;

function TTex.NewID(const Name: string; Data: Pointer; c, f, W, H, Group: Integer; Clamp, MipMap: Boolean; var idx: Integer): TTexture;
begin
//== Создаём новую текстуру в менеджере текстур
  idx := Length(tex_man);
  SetLength(tex_man, idx + 1);
  tex_man[idx].flag   := False;
  tex_man[idx].Ref    := 1;
  tex_man[idx].Name   := Name;
  tex_man[idx].Width  := W;
  tex_man[idx].Height := H;
  tex_man[idx].MipMap := MipMap;
  tex_man[idx].Group  := Group;
  with tex_man[idx] do
  begin
    glGenTextures(1, @ID);
    glBindTexture(GL_TEXTURE_2D, ID);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

    if clamp then
    begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    end else
    begin
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
      glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    end;

    if MipMap then
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
    else
      glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexParameterf(GL_TEXTURE_2D, GENERATE_MIPMAP_SGIS, Byte(MipMap));
    glTexImage2D(GL_TEXTURE_2D, 0, c, W, H, 0, f, GL_UNSIGNED_BYTE, Data);
    glTexParameterf(GL_TEXTURE_2D, GENERATE_MIPMAP_SGIS, 0);

    Result := ID;
  end;
end;

end.
