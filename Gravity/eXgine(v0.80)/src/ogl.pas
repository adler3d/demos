unit ogl;

interface
{$I cfg.pas}
uses
  Windows, OpenGL,
  sys_main, eXgine;

type
  GLHandleARB = Integer;

  PFontData = ^TFontData;
  TFontData = record
    Font  : TTexture;
    List  : Cardinal;
    Width : array [0..255] of ShortInt;
  end;

  TLightMan = class(TIntStatic, ILight)
    procedure Enable(ID: Integer);
    procedure Disable(ID: Integer);
    procedure Position(ID: Integer; Pos: TVector3f);
    procedure Diffuse(ID: Integer; Color: TRGBA);
    procedure Ambient(Color: TRGBA);
  end;

{$IFNDEF NO_TEX}
  TFontMan = class(TIntStatic, IFont)
    destructor Destroy; override;
  public
    function  Create(Name: PChar; Size: Integer; Bold: Boolean = False; TEX_SIZE: Integer = 512): TFont;
    procedure Free(Font: TFont);
  private
    Fonts : array of PFontData;
  end;
{$ENDIF}

  TOGL = class(TInterface, IOpenGL)
    constructor CreateEx;
    destructor Destroy; override;
  public
    function  FPS: Integer;
    procedure VSync(Active: Boolean); overload;
    function  VSync: Boolean; overload;
    procedure AntiAliasing(Samples: Integer); overload;
    function  AntiAliasing: Integer; overload;
    procedure Clear(Color, Depth, Stencil: Boolean);
    procedure Swap;
    procedure Set2D(x, y, w, h: Single);
    procedure Set3D(FOV, zNear, zFar: Single);
    function  Light : ILight;
  {$IFNDEF NO_TEX}
    function  Font : IFont;
    procedure TextOut(Font: TFont; X, Y: Single; Text: PChar);
    function  TextLen(Font: TFont; Text: PChar): Integer;
  {$ENDIF}
    procedure Blend(BType: TBlendType);
    function  ScreenShot(FileName: PChar): Boolean;
  public
    DC        : HDC;      // Device Context
    RC        : HGLRC;    // OpenGL Rendering Context
    fnt_debug : Integer;
  // fps - frames per second
    AASamples : Integer;
    AAFormat  : Integer;
    fps_time  : Integer;
    fps_cur   : Integer;
    g_FPS     : Integer;
    g_vsync   : Boolean;
    max_Aniso : Integer;
  {$IFNDEF NO_TEX}
    FontMan   : TFontMan;
  {$ENDIF}
    LightMan  : TLightMan;
    Extension : string; // Строка содержит в себе все доступные OpenGL расширения
    procedure log(const Text: string);
    procedure GetPixelFormat;
    function  Init: Boolean;
    procedure ReadExtensions;
  end;

// Процедурки и константы отсутствующие в стандартном OpenGL.pas
const
// Textures
  GL_MAX_TEXTURE_UNITS_ARB          = $84E2;
  GL_MAX_TEXTURE_SIZE               = $0D33;
  GL_CLAMP_TO_EDGE                  = $812F;
  GL_LUMINANCE8                     = $8040;
  GL_RGB8                           = $8051;
  GL_RGBA8                          = $8058;
  GL_BGR                            = $80E0;
  GL_BGRA                           = $80E1;
  GL_TEXTURE0_ARB                   = $84C0;
  GL_TEXTURE1_ARB                   = $84C1;
  GL_TEXTURE_MAX_ANISOTROPY_EXT     = $84FE;
  GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT = $84FF;
  GENERATE_MIPMAP_SGIS              = $8191;
 
// AA
  WGL_SAMPLE_BUFFERS_ARB = $2041;
  WGL_SAMPLES_ARB	       = $2042;
  WGL_DRAW_TO_WINDOW_ARB = $2001;
  WGL_SUPPORT_OPENGL_ARB = $2010;
  WGL_DOUBLE_BUFFER_ARB  = $2011;
  WGL_COLOR_BITS_ARB     = $2014;
  WGL_DEPTH_BITS_ARB     = $2022;
  WGL_STENCIL_BITS_ARB   = $2023;

// FBO
  GL_FRAMEBUFFER_EXT          = $8D40;
  GL_RENDERBUFFER_EXT         = $8D41;
  GL_DEPTH_COMPONENT24_ARB    = $81A6;
  GL_COLOR_ATTACHMENT0_EXT    = $8CE0;
  GL_DEPTH_ATTACHMENT_EXT     = $8D00;
  GL_FRAMEBUFFER_BINDING_EXT  = $8CA6;
  GL_FRAMEBUFFER_COMPLETE_EXT = $8CD5;

// Shaders
  GL_VERTEX_SHADER_ARB          = $8B31;
  GL_FRAGMENT_SHADER_ARB        = $8B30;
  GL_OBJECT_COMPILE_STATUS_ARB  = $8B81;
  GL_OBJECT_LINK_STATUS_ARB     = $8B82;

// VBO
  GL_ARRAY_BUFFER_ARB         = $8892;
  GL_ELEMENT_ARRAY_BUFFER_ARB = $8893;
  GL_STATIC_DRAW_ARB          = $88E4;
  GL_NORMAL_ARRAY             = $8075;
  GL_COLOR_ARRAY              = $8076;
  GL_VERTEX_ARRAY             = $8074;
  GL_TEXTURE_COORD_ARRAY      = $8078;
  GL_WRITE_ONLY_ARB           = $88B9;

  procedure glGenTextures(n: GLsizei; textures: PGLuint); stdcall; external opengl32;
  procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;
  procedure glDeleteTextures(N: GLsizei; Textures: PGLuint); stdcall; external opengl32;
  function glIsTexture(texture: GLuint): GLboolean; stdcall; external opengl32;
  procedure glCopyTexImage2D(target: GLEnum; level: GLint; internalFormat: GLEnum; x, y: GLint; width, height: GLsizei; border: GLint); stdcall; external opengl32;

var
// VSync
  WGL_EXT_swap_control  : Boolean;
  wglSwapIntervalEXT    : function (interval: GLint): Boolean; stdcall;
  wglGetSwapIntervalEXT : function: GLint; stdcall;

// MultiTexture
  GL_ARB_multitexture      : Boolean;
  glActiveTextureARB       : procedure (texture: Cardinal); stdcall;
  glClientActiveTextureARB : procedure (texture: Cardinal); stdcall;

// FrameBuffer
  GL_EXT_framebuffer_object    : Boolean;
  glGenRenderbuffersEXT        : procedure (n: GLsizei; renderbuffers: PGLuint); stdcall;
  glDeleteRenderbuffersEXT     : procedure (n: GLsizei; const renderbuffers: PGLuint); stdcall;
  glBindRenderbufferEXT        : procedure (target: GLenum; renderbuffer: GLuint); stdcall;
  glRenderbufferStorageEXT     : procedure (target: GLenum; internalformat: GLenum; width: GLsizei; height: GLsizei); stdcall;
  glGenFramebuffersEXT         : procedure (n: GLsizei; framebuffers: PGLuint); stdcall;
  glDeleteFramebuffersEXT      : procedure (n: GLsizei; const framebuffers: PGLuint); stdcall;
  glBindFramebufferEXT         : procedure (target: GLenum; framebuffer: GLuint); stdcall;
  glFramebufferTexture2DEXT    : procedure (target: GLenum; attachment: GLenum; textarget: GLenum; texture: GLuint; level: GLint); stdcall;
  glFramebufferRenderbufferEXT : procedure (target: GLenum; attachment: GLenum; renderbuffertarget: GLenum; renderbuffer: GLuint); stdcall;
  glCheckFramebufferStatusEXT  : function (target: GLenum): GLenum; stdcall;

// Shaders
  GL_ARB_shading_language   : Boolean;
  glDeleteObjectARB         : procedure (Obj: GLHandleARB); stdcall;
  glCreateProgramObjectARB  : function: GLHandleARB; stdcall;
  glCreateShaderObjectARB   : function (shaderType: GLEnum): GLHandleARB; stdcall;
  glShaderSourceARB         : procedure (shaderObj: GLHandleARB; count: GLSizei; src: Pointer; len: Pointer); stdcall;
  glAttachObjectARB         : procedure (programObj, shaderObj:GLhandleARB); stdcall;
  glLinkProgramARB          : procedure (programObj: GLHandleARB); stdcall;
  glUseProgramObjectARB     : procedure (programObj:GLHandleARB); stdcall;
  glCompileShaderARB        : function (shaderObj: GLHandleARB): GLboolean; stdcall;
  glGetObjectParameterivARB : procedure (Obj: GLHandleARB; pname: GLEnum; params: PGLuint); stdcall;
  glGetAttribLocationARB    : function (programObj: GLhandleARB; const char: PChar): GLInt; stdcall;
  glGetUniformLocationARB   : function (programObj:GLhandleARB; const char: PChar): GLInt; stdcall;
  glVertexAttrib1fARB       : procedure (index: GLuint; x: GLfloat); stdcall;
  glVertexAttrib2fARB       : procedure (index: GLuint; x, y: GLfloat); stdcall;
  glVertexAttrib3fARB       : procedure (index: GLuint; x, y, z: GLfloat); stdcall;

  glUniform1iARB            : procedure (location: GLint; v0: GLint); stdcall;
  glUniform1ivARB           : procedure (location: GLint; count: GLsizei; value: PGLint); stdcall;
  glUniform2ivARB           : procedure (location: GLint; count: GLsizei; value: PGLint); stdcall;
  glUniform3ivARB           : procedure (location: GLint; count: GLsizei; value: PGLint); stdcall;
  glUniform4ivARB           : procedure (location: GLint; count: GLsizei; value: PGLint); stdcall;
  glUniform1fvARB           : procedure (location: GLint; count: GLsizei; value: PGLfloat); stdcall;
  glUniform2fvARB           : procedure (location: GLint; count: GLsizei; value: PGLfloat); stdcall;
  glUniform3fvARB           : procedure (location: GLint; count: GLsizei; value: PGLfloat); stdcall;
  glUniform4fvARB           : procedure (location: GLint; count: GLsizei; value: PGLfloat); stdcall;
  glUniformMatrix2fvARB     : procedure (location: GLint; count: GLsizei; transpose: GLboolean; value: PGLfloat); stdcall;
  glUniformMatrix3fvARB     : procedure (location: GLint; count: GLsizei; transpose: GLboolean; value: PGLfloat); stdcall;
  glUniformMatrix4fvARB     : procedure (location: GLint; count: GLsizei; transpose: GLboolean; value: PGLfloat); stdcall;

  glGetInfoLogARB : procedure(shaderObj: GLHandleARB; maxLength: glsizei; var length: glint; infoLog: PChar); stdcall;

// Vertex Buffer Object
  GL_ARB_vertex_buffer_object : Boolean;
  glBindBufferARB    : procedure (target: GLenum; buffer: GLenum); stdcall;
  glDeleteBuffersARB : procedure (n: GLsizei; const buffers: PGLuint); stdcall;
  glGenBuffersARB    : procedure (n: GLsizei; buffers: PGLuint); stdcall;
  glBufferDataARB    : procedure (target: GLenum; size: GLsizei; const data: PGLuint; usage: GLenum); stdcall;
  glBufferSubDataARB : procedure (target: GLenum; offset: GLsizei; size: GLsizei; const data: PGLuint); stdcall;
  glMapBufferARB     : function  (target: GLenum; access: GLenum): Pointer; stdcall;
  glUnmapBufferARB   : function  (target: GLenum): GLboolean; stdcall;

  procedure glNormalPointer(type_: GLenum; stride: Integer; const P: PGLuint); stdcall; external opengl32;
  procedure glColorPointer(size: Integer; _type: GLenum; stride: Integer; const _pointer: PGLuint); stdcall; external opengl32;
  procedure glVertexPointer(size: Integer; _type: GLenum; stride: Integer; const _pointer: PGLuint); stdcall; external opengl32;
  procedure glTexCoordPointer(size: Integer; _type: GLenum; stride: Integer; const _pointer: PGLuint); stdcall; external opengl32;

  procedure glInterleavedArrays  (format: GLenum; stride: GLsizei; const _pointer: PGLuint); stdcall; external opengl32;
  procedure glEnableClientState  (_array: GLenum); stdcall; external opengl32;
  procedure glDisableClientState (_array: GLenum); stdcall; external opengl32;
  procedure glDrawElements       (mode: GLenum; count: GLsizei; _type: GLenum; const indices: PGLuint); stdcall; external opengl32;
  procedure glDrawArrays         (mode: GLenum; first, count: GLsizei); stdcall; external opengl32;

implementation

uses
  eng;

// Light Manager
procedure TLightMan.Enable(ID: Integer);
begin
  glEnable(GL_LIGHT0 + ID);
end;

procedure TLightMan.Disable(ID: Integer);
begin
  glDisable(GL_LIGHT0 + ID);
end;

procedure TLightMan.Position(ID: Integer; Pos: TVector3f);
var
  p : array [0..3] of Single;
begin
  p[0] := Pos.X;
  p[1] := Pos.Y;
  p[2] := Pos.Z;
  p[3] := 1.0;
  glLightfv(GL_LIGHT0 + ID, GL_POSITION, @p);
end;

procedure TLightMan.Diffuse(ID: Integer; Color: TRGBA);
var
  Value : array [0..3] of Single;
begin
  Value[0] := Color.R/255;
  Value[1] := Color.G/255;
  Value[2] := Color.B/255;
  Value[3] := Color.A/255;
  glLightfv(GL_LIGHT0 + ID, GL_DIFFUSE, @Value);
end;

procedure TLightMan.Ambient(Color: TRGBA);
var
  Value : array [0..3] of Single;
begin
  Value[0] := Color.R/255;
  Value[1] := Color.G/255;
  Value[2] := Color.B/255;
  Value[3] := Color.A/255;
  glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @Value);
end;

// Font Manager
{$IFNDEF NO_TEX}
function TFontMan.Create(Name: PChar; Size: Integer; Bold: Boolean; TEX_SIZE: Integer): TFont;
var
  FNT  : HFONT;
  DC   : HDC;
  MDC  : HDC;
  BMP  : HBITMAP;
  BI   : BITMAPINFO;
  pix  : PByteArray;
  i    : Integer;
  cs   : TSize;
  s, t : Single;
  Data : PByteArray;
  Rect : TRect;
begin
  DC  := GetDC(ownd.Handle);
  if Bold then
    i := FW_BOLD
  else
    i := FW_NORMAL;
  FNT := CreateFont(-MulDiv(Size, GetDeviceCaps(DC, LOGPIXELSY), 72), 0, 0, 0, i, 0, 0, 0, RUSSIAN_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                    ANTIALIASED_QUALITY, DEFAULT_PITCH, Name);
  ZeroMemory(@BI, SizeOf(BI));
  with BI.bmiHeader do
  begin
    biSize      := SizeOf(BITMAPINFOHEADER);
    biWidth     := TEX_SIZE;
    biHeight    := TEX_SIZE;
    biPlanes    := 1;
    biBitCount  := 24;
    biSizeImage := biWidth * biHeight * biBitCount div 8;
  end;

  MDC := CreateCompatibleDC(DC);
  BMP := CreateCompatibleBitmap(DC, TEX_SIZE, TEX_SIZE);

  SelectObject(MDC, BMP);
  SetRect(Rect, 0, 0, TEX_SIZE, TEX_SIZE);
  FillRect(MDC, Rect, GetStockObject(BLACK_BRUSH));

  SelectObject(MDC, FNT);
  SetBkMode(MDC, TRANSPARENT);
  SetTextColor(MDC, $FFFFFF);
  for i := 0 to 255 do
    Windows.TextOut(MDC, i mod 16 * (TEX_SIZE div 16), i div 16 * (TEX_SIZE div 16), @Char(i), 1);

  GetMem(pix, TEX_SIZE * TEX_SIZE * 3);
  GetDIBits(MDC, BMP, 0, TEX_SIZE, pix, BI, DIB_RGB_COLORS);

  Result := HIGH(TFont);
  for i := 0 to Length(Fonts) - 1 do
    if Fonts[i] = nil then
    begin
      Result := i;
      break;
    end;
  if Result = HIGH(TFont) then
  begin
    Result := Length(Fonts);
    SetLength(Fonts, Result + 1);
  end;

  New(Fonts[Result]);
  with Fonts[Result]^ do
  begin
    GetMem(Data, TEX_SIZE * TEX_SIZE * 2);
    for i := 0 to TEX_SIZE * TEX_SIZE - 1 do
    begin
      Data[i * 2]     := 255;
      Data[i * 2 + 1] := pix[i * 3];
    end;
    FreeMem(pix);
    Font := otex.Create(PChar('*Font_' + Name + '_' + IntToStr(Result) + '*'),
                        2, GL_LUMINANCE_ALPHA, TEX_SIZE, TEX_SIZE, Data, True, False, 0);
    FreeMem(Data);
    List := glGenLists(256);
    for i := 0 to 255 do
    begin
      glNewList(List + Cardinal(i), GL_COMPILE);
      s := (i mod 16)/16;
      t := (i div 16)/16;
      GetTextExtentPoint32(MDC, @Char(i), 1, cs);
      Width[i] := cs.cx;
      glBegin(GL_QUADS);
        glTexCoord2f(            s,      1 - t);                  glVertex2f(    0,     0);
        glTexCoord2f(s + cs.cx/TEX_SIZE, 1 - t);                  glVertex2f(cs.cx,     0);
        glTexCoord2f(s + cs.cx/TEX_SIZE, 1 - t - cs.cy/TEX_SIZE); glVertex2f(cs.cx, cs.cy);
        glTexCoord2f(            s,      1 - t - cs.cy/TEX_SIZE); glVertex2f(    0, cs.cy);
      glEnd;
      glTranslatef(cs.cx, 0, 0);
      glEndList;
    end;
  end;

  DeleteObject(FNT);
  DeleteObject(BMP);
  DeleteDC(MDC);
  ReleaseDC(ownd.Handle, DC);
end;

procedure TFontMan.Free(Font: TFont);
begin
  if (Font >= Cardinal(Length(Fonts))) or (Fonts[Font] = nil) then
    Exit;
  otex.Free(Fonts[Font]^.Font);
  glDeleteLists(Fonts[Font]^.List, 256);
  Dispose(Fonts[Font]);
  Fonts[Font] := nil;
end;

destructor TFontMan.Destroy;
var
  i : Integer;
begin
  for i := 0 to Length(Fonts) - 1 do
    Free(i);
end;
{$ENDIF}

constructor TOGL.CreateEx;
begin
  inherited;
  fps_time  := 0;
  fps_cur   := 0;
  g_FPS     := 0;
  g_vsync   := False;
  LightMan := TLightMan.CreateEx; 
  {$IFNDEF NO_TEX}
    FontMan := TFontMan.CreateEx;
  {$ENDIF}  
end;

destructor TOGL.Destroy;
begin
  LightMan.Destroy;
{$IFNDEF NO_TEX}
  FontMan.Destroy;
{$ENDIF}
//== Высвобождение ресурсов
  if (DC <> 0) and (RC <> 0) then
  begin
  // Удаляем OpenGL контекст
    if RC <> 0 then
      wglDeleteContext(RC);
  // Удаляем графический контекст окна
    if DC <> 0 then
      ReleaseDC(ownd.wnd_handle, DC);
  end;
  inherited;
end;

function TOGL.FPS: Integer;
begin
  Result := g_FPS;
end;

procedure TOGL.VSync(Active: Boolean);
begin
  g_vsync := Active;
end;

function TOGL.VSync: Boolean;
begin
  Result := g_vsync;
end;

procedure TOGL.Clear(Color, Depth, Stencil: Boolean);
var
  flag : DWORD;
begin
  flag := 0;
  if Color   then flag := flag or GL_COLOR_BUFFER_BIT;
  if Depth   then flag := flag or GL_DEPTH_BUFFER_BIT;
  if Stencil then flag := flag or GL_STENCIL_BUFFER_BIT;
  glClear(flag);
end;

procedure TOGL.Swap;
begin
  if WGL_EXT_swap_control and (wglGetSwapIntervalEXT <> Byte(g_vsync)) then
    wglSwapIntervalEXT(Byte(g_vsync));
  glFlush;
  SwapBuffers(DC);
// Считаем кол-во кадров в секунду
  if fps_time <= GetTime then
  begin
    fps_time := GetTime + 1000;
    g_FPS    := fps_cur;
    fps_cur  := 0;
  end;
  inc(fps_cur);
end;

procedure TOGL.AntiAliasing(Samples: Integer);
begin
  if not ownd.wnd_ready then
    AASamples := Samples;
end;

function TOGL.AntiAliasing: Integer;
begin
  Result := AASamples
end;

procedure TOGL.Set2D(x, y, w, h: Single);
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(x, x + w, y + h, y, -1, 1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

procedure TOGL.Set3D(FOV, zNear, zFar: Single);
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(FOV, ownd.Width / ownd.Height, zNear, zFar);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

function TOGL.Light: ILight;
begin
  Result := LightMan;
end;

{$IFNDEF NO_TEX}
function TOGL.Font: IFont;
begin
  Result := FontMan;
end;

procedure TOGL.TextOut(Font: TFont; X, Y: Single; Text: PChar);
var
  str : string;
  i   : Integer;
begin
  if (Font >= Cardinal(Length(FontMan.Fonts))) or (FontMan.Fonts[Font] = nil) then
    Exit;
  glPushAttrib(GL_ENABLE_BIT);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_CULL_FACE);
  glDisable(GL_LIGHTING);
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GEQUAL, 1/255);
  Blend(BT_SUB);
  glListBase(FontMan.Fonts[Font]^.List);
  otex.Enable(FontMan.Fonts[Font]^.Font, 0);
  glPushMatrix;
    glTranslatef(X, Y, 0);
    str := Text;
    for i := 1 to Length(str) do
      glCallLists(1, GL_UNSIGNED_BYTE, @str[i]);
  glPopMatrix;
  glPopAttrib;
end;

function TOGL.TextLen(Font: TFont; Text: PChar): Integer;
var
  str : string;
  i   : Integer;
begin
  Result := 0;
  if (Font >= Cardinal(Length(FontMan.Fonts))) or (FontMan.Fonts[Font] = nil) then
    Exit;
  str := Text;
  for i := 1 to Length(Text) do
    Result := Result + FontMan.Fonts[Font]^.Width[Byte(str[i])];
end;
{$ENDIF}

procedure TOGL.Blend(BType: TBlendType);
begin
  if BType = BT_NONE then
    glDisable(GL_BLEND)
  else
  begin
    glEnable(GL_BLEND);
    case BType of
    // обычное смешивание
      BT_SUB  : glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // сложение
      BT_ADD  : glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    // умножение
      BT_MULT : glBlendFunc(GL_ZERO, GL_SRC_COLOR);
    end;
  end;
end;

function TOGL.ScreenShot(FileName: PChar): Boolean;
var
  F   : TFile;
  pix : Pointer;
  TGA : packed record
    FileType       : Byte;
    ColorMapType   : Byte;
    ImageType      : Byte;
    ColorMapStart  : Word;
    ColorMapLength : Word;
    ColorMapDepth  : Byte;
    OrigX          : Word;
    OrigY          : Word;
    iWidth         : Word;
    iHeight        : Word;
    iBPP           : Byte;
    ImageInfo      : Byte;
  end;

  BMP : packed record
    bfType          : Word;
    bfSize          : DWORD;
    bfReserved1     : Word;
    bfReserved2     : Word;
    bfOffBits       : DWORD;
    biSize          : DWORD;
    biWidth         : Integer;
    biHeight        : Integer;
    biPlanes        : Word;
    biBitCount      : Word;
    biCompression   : DWORD;
    biSizeImage     : DWORD;
    biXPelsPerMeter : Integer;
    biYPelsPerMeter : Integer;
    biClrUsed       : DWORD;
    biClrImportant  : DWORD;
  end;

begin
  Result := False;

  GetMem(pix, ownd.Width * ownd.Height * 3);
  glReadPixels(0, 0, ownd.Width, ownd.Height, GL_BGR, GL_UNSIGNED_BYTE, pix);

  F := FileOpen(FileName, True);
  if not FileValid(F) then
    Exit;

  if Copy(FileName, Length(FileName) - 2, 3) = 'tga' then
    with TGA, ownd do
    begin
      FileType       := 0;
      ColorMapType   := 0;
      ImageType      := 2;
      ColorMapStart  := 0;
      ColorMapLength := 0;
      ColorMapDepth  := 0;
      OrigX          := 0;
      OrigY          := 0;
      iWidth         := Width;
      iHeight        := Height;
      iBPP           := 24;
      ImageInfo      := 0;
      FileWrite(F, TGA, SizeOf(TGA));
    end
  else
    with BMP, ownd do
    begin
      bfType          := $4D42;
      bfSize          := Width * Height * 3 + SizeOf(BMP);
      bfReserved1     := 0;
      bfReserved2     := 0;
      bfOffBits       := SizeOf(BMP);
      biSize          := SizeOf(BITMAPINFOHEADER);
      biWidth         := Width;
      biHeight        := Height;
      biPlanes        := 1;
      biBitCount      := 24;
      biCompression   := 0;
      biSizeImage     := Width * Height * 3;
      biXPelsPerMeter := 0;
      biYPelsPerMeter := 0;
      biClrUsed       := 0;
      biClrImportant  := 0;
      FileWrite(F, BMP, SizeOf(BMP));
    end;

  FileWrite(F, pix^, ownd.Width * ownd.Height * 3);
  FileClose(F);

  FreeMem(pix);
  Result := True;
end;

procedure TOGL.log(const Text: string);
begin
  olog.Print(PChar('OpenGL  : ' + Text));
end;

procedure TOGL.GetPixelFormat;
var
  wglChoosePixelFormatARB: function(hdc: HDC; const piAttribIList: PGLint; const pfAttribFList: PGLfloat; nMaxFormats: GLuint; piFormats: PGLint; nNumFormats: PGLuint): BOOL; stdcall;
  fAttributes: array [0..1] of Single;
  iAttributes: array [0..17] of Integer;
  pfd  : PIXELFORMATDESCRIPTOR;
  DC   : Cardinal;
  hwnd : Cardinal;
  wnd  : TWndClassEx;

  function GetFormat: Boolean;
  var
    Format     : Integer;
    numFormats : Cardinal;
  begin
    iAttributes[7] := AASamples;
    if wglChoosePixelFormatARB(GetDC(hWnd), @iattributes, @fattributes, 1, @Format, @numFormats) and (numFormats >= 1) then
    begin
      AAFormat := Format;
      Result   := True;
    end else
    begin
      dec(AASamples);
      Result := False;
    end;
  end;
  
label
  ext;
begin
// Эта функция работает мягко говоря - фигово.
// Причину не нашёл пока...
  if AASamples = 0 then
    Exit;

  ZeroMemory(@wnd, SizeOf(wnd));
  with wnd do
  begin
    cbSize        := SizeOf(wnd);
    lpfnWndProc   := @DefWindowProc;
    hCursor       := LoadCursor(0, IDC_ARROW);
    lpszClassName := 'eXAAtest';
  end;
  if RegisterClassEx(wnd) = 0 then Exit;
  
  hwnd := CreateWindow('eXAAtest', nil, WS_POPUP, 0, 0, 0, 0, 0, 0, 0, nil);
  DC := GetDC(hwnd);
  if DC = 0 then goto ext;

  FillChar(pfd, SizeOf(pfd), 0);
  with pfd do
  begin
    nSize        := SizeOf(TPIXELFORMATDESCRIPTOR);
    nVersion     := 1;
    dwFlags      := PFD_DRAW_TO_WINDOW or
                    PFD_SUPPORT_OPENGL or
                    PFD_DOUBLEBUFFER;
    iPixelType   := PFD_TYPE_RGBA;
    cColorBits   := 32;
    cDepthBits   := 24;
    cStencilBits := 8;
    iLayerType   := PFD_MAIN_PLANE;
  end;

  if not SetPixelFormat(DC, ChoosePixelFormat(DC, @pfd), @pfd) then goto ext;
  if not wglMakeCurrent(DC, wglCreateContext(DC)) then goto ext;

  fAttributes[0]  := 0;
  fAttributes[1]  := 0;

  iAttributes[0]  := WGL_DRAW_TO_WINDOW_ARB;
  iAttributes[1]  := 1;
  iAttributes[2]  := WGL_SUPPORT_OPENGL_ARB;
  iAttributes[3]  := 1;
  iAttributes[4]  := WGL_SAMPLE_BUFFERS_ARB;
  iAttributes[5]  := 1;
  iAttributes[6]  := WGL_SAMPLES_ARB;
//  iAttributes[7]  := calc
  iAttributes[8]  := WGL_DOUBLE_BUFFER_ARB;
  iAttributes[9]  := 1;
  iAttributes[10] := WGL_COLOR_BITS_ARB;
  iAttributes[11] := 32;
  iAttributes[12] := WGL_DEPTH_BITS_ARB;
  iAttributes[13] := 24;
  iAttributes[14] := WGL_STENCIL_BITS_ARB;
  iAttributes[15] := 8;
  iAttributes[16] := 0;
  iAttributes[17] := 0;
  
{ WGL_DRAW_TO_WINDOW_ARB,GL_TRUE,
		WGL_SUPPORT_OPENGL_ARB,GL_TRUE,
		WGL_ACCELERATION_ARB,WGL_FULL_ACCELERATION_ARB,
		WGL_COLOR_BITS_ARB,24,
		WGL_ALPHA_BITS_ARB,8,
		WGL_DEPTH_BITS_ARB,16,
		WGL_STENCIL_BITS_ARB,0,
		WGL_DOUBLE_BUFFER_ARB,GL_TRUE,
		WGL_SAMPLE_BUFFERS_ARB,GL_TRUE,
		WGL_SAMPLES_ARB, 4 ,						// Check For 4x Multisampling
		0,0};  

  wglChoosePixelFormatARB := wglGetProcAddress('wglChoosePixelFormatARB');
  if @wglChoosePixelFormatARB = nil then
    Exit;

  while (AASamples > 0) and (not GetFormat) do; // смертельный номер!

ext:
  ReleaseDC(hwnd, DC);
  DestroyWindow(hwnd);
  UnRegisterClass('eXAAtest', 0);
end;

function TOGL.Init: Boolean;
var
  pfd     : PIXELFORMATDESCRIPTOR;
  iFormat : Integer;
begin
  Result := False;
  log('Init graphics core');
  DC := GetDC(ownd.wnd_handle);

  if DC = 0 then
  begin
    log('Fatal Error "GetDC"');
    Exit;
  end;

  FillChar(pfd, SizeOf(pfd), 0);
  with pfd do
  begin
    nSize        := SizeOf(TPIXELFORMATDESCRIPTOR);
    nVersion     := 1;
    dwFlags      := PFD_DRAW_TO_WINDOW or
                    PFD_SUPPORT_OPENGL or
                    PFD_DOUBLEBUFFER;
    iPixelType   := PFD_TYPE_RGBA;
    cColorBits   := 32;
    cDepthBits   := 24;
    cStencilBits := 8;
    iLayerType   := PFD_MAIN_PLANE;
  end;

  if AAFormat > 0 then
    iFormat := AAFormat
  else
    iFormat := ChoosePixelFormat(DC, @pfd);
  if iFormat = 0 then
  begin
    log('Fatal Error "ChoosePixelFormat"');
    Exit;
  end;

  if not SetPixelFormat(DC, iFormat, @pfd) then
  begin
    log('Fatal Error "SetPixelFormat"');
    Exit;
  end;

  RC := wglCreateContext(DC);
  if RC = 0 then
  begin
    log('Fatal Error "wglCreateContext"');
    Exit;
  end;

  if not wglMakeCurrent(DC, RC) then
  begin
    log('Fatal Error "wglCreateContext"');
    Exit;
  end;
// Инициализация доступных расширений
  ReadExtensions;
// Настройка
  glDepthFunc(GL_LESS);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
  glClearColor(0, 0, 0, 0);
  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_ALPHA_TEST);
  glAlphaFunc(GL_GREATER, 1/256);
  glViewport(0, 0, ownd.wnd_width, ownd.wnd_height);
{$IFNDEF NO_TEX}
// Создание default текстуры и т.п.
  if not otex.Init then
    Exit;
// Создание Debug шрифта
  {$IFNDEF NO_FNT}
  fnt_debug := Font.Create('FixedSys', 8);
  {$ENDIF}
{$ENDIF}
// Готово
  Result := True;
end;

procedure TOGL.ReadExtensions;
var
  i : Integer;

  function GetExt(const Text: PChar; var Flag: Boolean): Boolean;
  begin
    Flag := Pos(Text, Extension) <> 0;
    if Flag then
      log(PChar('+ ' + Text))
    else
      log(PChar('- ' + Text));
    Result := Flag;  
  end;

begin
// Получаем адреса дополнительных процедур OpenGL
  log('GL_VENDOR   : ' + glGetString(GL_VENDOR));
  log('GL_RENDERER : ' + glGetString(GL_RENDERER));
  log('GL_VERSION  : ' + glGetString(GL_VERSION));
  glGetIntegerv(GL_MAX_TEXTURE_UNITS_ARB, @i);
  log('MAX_TEX_UNITS  : ' + IntToStr(i));
  glGetIntegerv(GL_MAX_TEXTURE_SIZE, @i);
  log('MAX_TEX_SIZE   : ' + IntToStr(i));
  glGetIntegerv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, @max_aniso);
  log('MAX_ANISOTROPY : ' + IntToStr(max_aniso));
  log('USE_AA_SAMPLES : ' + IntToStr(AASamples));

  log('Reading extensions');
  Extension := glGetString(GL_EXTENSIONS);
//  log('GL_EXTENSIONS  : ' + extension);

 // Управление вертикальной синхронизацией
  if GetExt('WGL_EXT_swap_control', WGL_EXT_swap_control) then
  begin
    wglSwapIntervalEXT    := wglGetProcAddress('wglSwapIntervalEXT');
    wglGetSwapIntervalEXT := wglGetProcAddress('wglGetSwapIntervalEXT');
  end;

{$IFNDEF NO_TEX}
  // Мультитекстурирование
  if GetExt('GL_ARB_multitexture', GL_ARB_multitexture) then
  begin
    glActiveTextureARB       := wglGetProcAddress('glActiveTextureARB');
    glClientActiveTextureARB := wglGetProcAddress('glClientActiveTextureARB');
  end;

  {$IFNDEF NO_FBO}
  // рендер в текстуру
  if GetExt('GL_EXT_framebuffer_object', GL_EXT_framebuffer_object) then
  begin
    glGenRenderbuffersEXT        := wglGetProcAddress('glGenRenderbuffersEXT');
    glDeleteRenderbuffersEXT     := wglGetProcAddress('glDeleteRenderbuffersEXT');
    glBindRenderbufferEXT        := wglGetProcAddress('glBindRenderbufferEXT');
    glRenderbufferStorageEXT     := wglGetProcAddress('glRenderbufferStorageEXT');
    glGenFramebuffersEXT         := wglGetProcAddress('glGenFramebuffersEXT');
    glDeleteFramebuffersEXT      := wglGetProcAddress('glDeleteFramebuffersEXT');
    glBindFramebufferEXT         := wglGetProcAddress('glBindFramebufferEXT');
    glFramebufferTexture2DEXT    := wglGetProcAddress('glFramebufferTexture2DEXT');
    glFramebufferRenderbufferEXT := wglGetProcAddress('glFramebufferRenderbufferEXT');
    glCheckFramebufferStatusEXT  := wglGetProcAddress('glCheckFramebufferStatusEXT');
  end;
  {$ENDIF}
{$ENDIF}

{$IFNDEF NO_VFP}
// шейдеры
  if GetExt('GL_ARB_shading_language', GL_ARB_shading_language) then
  begin
    glDeleteObjectARB         := wglGetProcAddress('glDeleteObjectARB');
    glCreateProgramObjectARB  := wglGetProcAddress('glCreateProgramObjectARB');
    glCreateShaderObjectARB   := wglGetProcAddress('glCreateShaderObjectARB');
    glShaderSourceARB         := wglGetProcAddress('glShaderSourceARB');
    glAttachObjectARB         := wglGetProcAddress('glAttachObjectARB');
    glLinkProgramARB          := wglGetProcAddress('glLinkProgramARB');
    glUseProgramObjectARB     := wglGetProcAddress('glUseProgramObjectARB');
    glCompileShaderARB        := wglGetProcAddress('glCompileShaderARB');
    glGetObjectParameterivARB := wglGetProcAddress('glGetObjectParameterivARB');
    glGetAttribLocationARB    := wglGetProcAddress('glGetAttribLocationARB');
    glGetUniformLocationARB   := wglGetProcAddress('glGetUniformLocationARB');
  // attribs
    glVertexAttrib1fARB := wglGetProcAddress('glVertexAttrib1fARB');
    glVertexAttrib2fARB := wglGetProcAddress('glVertexAttrib2fARB');
    glVertexAttrib3fARB := wglGetProcAddress('glVertexAttrib3fARB');
  // uniforms
    glUniform1iARB   := wglGetProcAddress('glUniform1iARB');
    glUniform1ivARB  := wglGetProcAddress('glUniform1ivARB');
    glUniform2ivARB  := wglGetProcAddress('glUniform2ivARB');
    glUniform3ivARB  := wglGetProcAddress('glUniform3ivARB');
    glUniform4ivARB  := wglGetProcAddress('glUniform4ivARB');
    glUniform1fvARB  := wglGetProcAddress('glUniform1fvARB');
    glUniform2fvARB  := wglGetProcAddress('glUniform2fvARB');
    glUniform3fvARB  := wglGetProcAddress('glUniform3fvARB');
    glUniform4fvARB  := wglGetProcAddress('glUniform4fvARB');
    glUniformMatrix2fvARB := wglGetProcAddress('glUniformMatrix2fvARB');
    glUniformMatrix3fvARB := wglGetProcAddress('glUniformMatrix3fvARB');
    glUniformMatrix4fvARB := wglGetProcAddress('glUniformMatrix4fvARB');
    glGetInfoLogARB := wglGetProcAddress('glGetInfoLogARB');
  end;
{$ENDIF}

{$IFNDEF NO_VBO}
  // VBO :)
  if GetExt('GL_ARB_vertex_buffer_object', GL_ARB_vertex_buffer_object) then
  begin
    glBindBufferARB    := wglGetProcAddress('glBindBufferARB');
    glDeleteBuffersARB := wglGetProcAddress('glDeleteBuffersARB');
    glGenBuffersARB    := wglGetProcAddress('glGenBuffersARB');
    glBufferDataARB    := wglGetProcAddress('glBufferDataARB');
    glBufferSubDataARB := wglGetProcAddress('glBufferSubDataARB');
    glMapBufferARB     := wglGetProcAddress('glMapBufferARB');
    glUnmapBufferARB   := wglGetProcAddress('glUnmapBufferARB');
  end;
{$ENDIF}
end;

end.
