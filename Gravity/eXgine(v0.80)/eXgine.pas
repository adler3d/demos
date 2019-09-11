unit eXgine;
////////////////////////////////
//  eXgine v0.80 header file  //
//----------------------------//
// http://xproger.mirgames.ru //
////////////////////////////////
interface

{$I cfg.pas}

// Engine
type
  TProcRender  = procedure;
  TProcUpdate  = procedure;
  TProcMessage = procedure (Msg: LongWord; wP, lP: Integer);
  TProcActive  = procedure (Active: Boolean);
  TProcInit    = procedure;
  TProcFree    = procedure;

  TLogProc = procedure (Text: PChar);

const
  PROC_UPDATE  = 0;
  PROC_RENDER  = 1;
  PROC_MESSAGE = 2;
  PROC_ACTIVE  = 3;
  PROC_INIT    = 4;
  PROC_FREE    = 5;
  
// Input
const
// мышь
  M_BTN_1  = 257;
  M_BTN_2  = 258;
  M_BTN_3  = 259;
  M_BTN_4  = 260;
  M_BTN_5  = 261;
  M_BTN_6  = 262;
  M_BTN_7  = 263;
// джойстик
  J_BTN_1  = 264;
  J_BTN_2  = 265;
  J_BTN_3  = 266;
  J_BTN_4  = 267;
  J_BTN_5  = 268;
  J_BTN_6  = 269;
  J_BTN_7  = 270;
  J_BTN_8  = 271;
  J_BTN_9  = 272;
  J_BTN_10 = 273;
  J_BTN_11 = 274;
  J_BTN_12 = 275;
  J_BTN_13 = 276;
  J_BTN_14 = 277;
  J_BTN_15 = 278;
  J_BTN_16 = 279;
  J_BTN_17 = 280;
  J_BTN_18 = 281;
  J_BTN_19 = 282;
  J_BTN_20 = 283;
  J_BTN_21 = 284;
  J_BTN_22 = 285;
  J_BTN_23 = 286;
  J_BTN_24 = 287;
  J_BTN_25 = 288;
  J_BTN_26 = 289;
  J_BTN_27 = 290;
  J_BTN_28 = 291;
  J_BTN_29 = 292;
  J_BTN_30 = 293;
  J_BTN_31 = 294;
  J_BTN_32 = 295;

// Log
const
  MSG_NONE    = $00000000;
  MSG_ERROR   = $00000010;
  MSG_INFO    = $00000040;
  MSG_WARNING = $00000030;

// Input
type
  TJoyAxis = record
    X, Y, Z, R, U, V : Single;
  end;

// OpenGL
type
  TFont      = LongWord;
  TBlendType = Integer;  // BT
const
  BT_NONE = 0;
  BT_SUB  = 1;
  BT_ADD  = 2;
  BT_MULT = 3;

// Texture
type
  TTexture   = LongWord;
  TTexMode   = Integer;  // TM
const
// Texture Mode
  TM_COLOR = 1;
  TM_DEPTH = 2;
// Filter Type
  FT_NONE       = 0;
  FT_BILINEAR   = 1;
  FT_TRILINEAR  = 2;
  FT_ANISOTROPY = 3;

// Shader
type
  TShader    = LongWord;
  TShAttrib  = Integer;
  TShUniform = Integer;
  TShUniType = Integer;

const
  SU_I1 = 0;   // int
  SU_I2 = 1;   // ivec2
  SU_I3 = 2;   // ivec3
  SU_I4 = 3;   // ivec4

  SU_F1 = 4;   // float
  SU_F2 = 5;   // vec2
  SU_F3 = 6;   // vec3
  SU_F4 = 7;   // vec4

  SU_M2 = 8;   // mat2
  SU_M3 = 9;   // mat3
  SU_M4 = 10;  // mat4

// VBuffer
type
  TVBOid   = Integer;
  
const
  VBO_INDEX     = 0;
  VBO_VERTEX    = 1;
  VBO_NORMAL    = 2;
  VBO_COLOR     = 3;
  VBO_TEXCOORD  = 4;
  VBO_TEXCOORD1 = 4;
  VBO_TEXCOORD2 = 5;

// Sound
type
  TSound     = Integer;
  TChannel   = Integer;
  
// Network
type
  TSocket = Integer;

  TNetMessage = record
    IP   : LongWord;
    Port : Integer;
    Size : Integer;
    Data : Pointer;
  end;

  TNetIP = array [0..3] of Char;

const
  NET_ERROR = -1;
  
// Vector
type
  TVector3f = record
    X, Y, Z: Single;
  end;
  TVector2f = record
    X, Y: Single;
  end;
  TVector   = TVector3f;
  TVector2D = TVector2f;
  TVec2f = TVector2f;
  TVec3f = TVector3f;

const
  deg2rad = pi / 180;
  rad2deg = 180 / pi;

// other
type
  TRGB = record
    R, G, B : Byte;
  end;

  TRGBA = record
    R, G, B, A : Byte;
  end;

// Самое необходимое из новых (> 1.3) версий OpenGL
const
  GL_CLAMP_TO_EDGE = $812F;
  GL_RGB8          = $8051;
  GL_RGBA8         = $8058;
  GL_BGR           = $80E0;
  GL_BGRA          = $80E1;
  GL_TEXTURE0_ARB  = $84C0;

type
//--- log ----------------
  ILog = interface
    function  Create(FileName: PChar; LogProc: TLogProc = nil): Boolean;
    procedure Print(Text: PChar);
    function  Msg(Caption, Text: PChar; ID: LongWord = 0): Integer;
    procedure TimeStamp(Active: Boolean = True);
    procedure ResetTimer;
    procedure Flush(Active: Boolean = True);
    procedure Free; 
  end;

//--- wnd ----------------
  IWindow = interface
    function  Create(Caption: PChar; OnTop: Boolean = True): Boolean; overload;
    function  Create(Handle: LongWord): Boolean; overload;
    function  Handle: LongWord;
    procedure Caption(Text: PChar);
    function  Width: Integer;
    function  Height: Integer;
    function  Mode(FullScreen: Boolean; W, H, BPP, Freq: Integer): Boolean;
    procedure Show(Minimized: Boolean);
    function  Active: Boolean;
  end;

//--- ogl ----------------
  ILight = interface
    procedure Enable(ID: Integer);
    procedure Disable(ID: Integer);
    procedure Position(ID: Integer; Pos: TVector3f);
    procedure Diffuse(ID: Integer; Color: TRGBA);
    procedure Ambient(Color: TRGBA);
  end;
  
  IFont = interface
    function  Create(Name: PChar; Size: Integer; Bold: Boolean = False; TEX_SIZE: Integer = 512): TFont;
    procedure Free(Font: TFont);
  end;

  IOpenGL = interface
    function  FPS: Integer;
    procedure VSync(Active: Boolean); overload;
    function  VSync: Boolean; overload;
    procedure AntiAliasing(Samples: Integer); overload;
    function  AntiAliasing: Integer; overload;    
    procedure Clear(Color: Boolean = True; Depth: Boolean = False; Stencil: Boolean = False);
    procedure Swap;
    procedure Set2D(x, y, w, h: Single);
    procedure Set3D(FOV, zNear, zFar: Single);
    function  Light : ILight;
  {$IFNDEF NO_TEX}
    function  Font  : IFont;
    function  TextLen(Font: TFont; Text: PChar): Integer;
    procedure TextOut(Font: TFont; X, Y: Single; Text: PChar);
  {$ENDIF}
    procedure Blend(BType: TBlendType);
    function  ScreenShot(FileName: PChar): Boolean;
  end;

//--- inp ----------------
{$IFNDEF NO_INP}
  IInput = interface
    procedure Reset;
    function  Down(Key: Integer): Boolean;
    function  LastKey: Integer;
    function  MDelta: TVector2f;
    function  WDelta: Integer;
  {$IFNDEF NO_JOY}
    function  JCount: Integer;
    function  JAxis(ID: Integer = 0): TJoyAxis;
    function  JPOV(ID: Integer = 0): Single;
  {$ENDIF}
    procedure MCapture(Active: Boolean = True);
  end;
{$ENDIF}

//--- vbo ----------------
{$IFNDEF NO_VBO}
  IVBuffer = interface
    procedure Clear;
    procedure Add(DataType: LongWord; Count: LongWord; Data: Pointer);
    function  Compile: TVBOid;
    procedure Free(ID: TVBOid);
    procedure Offset(ID: TVBOid; DataType: LongWord; Offset: LongWord);
    procedure Render(ID: TVBOid; mode: LongWord; Count: Integer = 0);
    procedure Enable(ID: TVBOid; DataType: LongWord);
    procedure Disable(ID: TVBOid; DataType: LongWord);
    procedure Update_Begin(ID: TVBOid);
    procedure Update_End;
  end;
{$ENDIF}

//--- tex ----------------
{$IFNDEF NO_TEX}
  ITexture = interface
    function  Create(Name: PChar; c, f, W, H: Integer; Data: Pointer; Clamp: Boolean = False; MipMap: Boolean = True; Group: Integer = 0): TTexture;
    function  Load(FileName: PChar; Clamp: Boolean = False; MipMap: Boolean = True; Group: Integer = 0): TTexture; overload;
    function  Load(Name: PChar; Mem: Pointer; Size: Integer; Clamp: Boolean = False; MipMap: Boolean = True; Group: Integer = 0): TTexture; overload;
    function  Load(FileName: PChar; var W, H, BPP: Integer; var Data: Pointer): Boolean; overload;
    function  Load(Name: PChar; Mem: Pointer; Size: Integer; var W, H, BPP: Integer; var Data: Pointer): Boolean; overload;
    procedure Free(var Data: Pointer); overload;
    procedure Free(ID: TTexture); overload;
    procedure Enable(ID: TTexture; Channel: Integer = 0);
    procedure Disable(Channel: Integer = 0);
    procedure Update_Begin(Group: Integer);
    procedure Update_End(Group: Integer);
    procedure Filter(FilterType: Integer; Group: Integer = 0);
    procedure Render_Copy(ID: TTexture; X, Y, W, H, Format: Integer; Level: Integer = 0);
  {$IFNDEF NO_FBO}
    function  Render_Init(TexSize: Integer): Boolean;
    procedure Render_Begin(ID: TTexture; Mode: TTexMode = TM_COLOR);
    procedure Render_End;
  {$ENDIF}    
  end;
{$ENDIF}

//--- vfp ----------------
{$IFNDEF NO_VFP}
  IShader = interface
    procedure Clear;
    function  Add(FileName: PChar; Name: PChar = nil): Boolean; overload;
    function  Add(Mem: Pointer; Size: Integer; Name: PChar = nil): Boolean; overload;
    function  Compile: TShader;
    procedure Free(Shader: TShader);
    function  GetAttrib(Shader: TShader; Name: PChar): TShAttrib;
    function  GetUniform(Shader: TShader; Name: PChar): TShUniform;
    procedure Attrib(a: TShAttrib; x: Single); overload;
    procedure Attrib(a: TShAttrib; x, y: Single); overload;
    procedure Attrib(a: TShAttrib; x, y, z: Single); overload;
    procedure Uniform(u: TShUniform; i: Integer); overload;
    procedure Uniform(u: TShUniform; p: Pointer; ShUniType: TShUniType; Count: Integer = 1); overload;
    procedure Enable(Shader: TShader);
    procedure Disable;
  end;
{$ENDIF}

//--- snd ----------------
{$IFNDEF NO_SND}
  ISound = interface
    function  Load(FileName: PChar; Group: Integer = 0): TSound; overload;
    function  Load(Name: PChar; Mem: Pointer; Size: Integer; Group: Integer = 0): TSound; overload;
    function  Free(ID: TSound): Boolean;
    function  Play(ID: TSound; X, Y, Z: Single; Loop: Boolean = False): TChannel;
    procedure Stop(ID: TChannel);
    procedure Update_Begin(Group: Integer);
    procedure Update_End(Group: Integer);
    procedure Volume(Value: Integer);
    procedure Freq(Value: Integer);
    procedure Channel_Pos(ID: TChannel; X, Y, Z: Single);
    procedure Pos(X, Y, Z: Single);
    procedure Dir(dX, dY, dZ, uX, uY, uZ: Single);
    procedure Factor_Pan(Value: Single = 0.1);
    procedure Factor_Rolloff(Value: Single = 0.005);
   {$IF NOT (DEFINED(NO_MCI) AND DEFINED(NO_OGG))}
    procedure PlayFile(FileName: PChar; Loop: Boolean); {$IFNDEF NO_OGG}overload;
    procedure PlayFile(Mem: Pointer; Size: Integer; Loop: Boolean); overload;
    {$ENDIF}
    procedure StopFile;
   {$IFEND}
  end;
{$ENDIF}

//--- net ----------------
{$IFNDEF NO_NET}
  IProtocol = interface
    procedure Close(Socket: TSocket);
    procedure Clear;
    function Write(var Buf; Count: Integer): Integer;
  end;

  IUDP = interface(IProtocol)
    function Open(Port: Integer): TSocket;
    function Send(Socket: TSocket; IP: TNetIP; Port: Integer): Boolean;
    function Recv(Socket: TSocket): TNetMessage;
  end;

  ITCP = interface(IProtocol)
    function Host(Port: Integer): TSocket;
    function Join(IP: PChar; Port: Integer): TSocket;
    function Send(Socket: TSocket): Boolean;
    function Recv(Socket: TSocket; Buf: Pointer; Count: Integer; var IP: PChar; var Port: Integer): Integer;
  end;

  INetwork = interface
    function IP(idx: Integer): PChar;
    function udp: IUDP;
    function tcp: ITCP;
  end;
{$ENDIF}

//--- vec ----------------
{$IFNDEF NO_VEC}
  IVector = interface
    function Create(X, Y, Z: Single): TVec3f; overload;
    function Create(X, Y: Single): TVec2f; overload;
    function Add(v1, v2: TVec3f): TVec3f;
    function Sub(v1, v2: TVec3f): TVec3f;
    function Mult(v: TVec3f; x: Single): TVec3f;
    function Length(v: TVec3f): Single;
    function LengthQ(v: TVec3f): Single;
    function Normalize(v: TVec3f): TVec3f;
    function Dot(v1, v2: TVec3f): Single;
    function Cross(v1, v2: TVec3f): TVec3f;
    function Angle(v1, v2: TVec3f): Single;
  end;
{$ENDIF}

//--- eng ----------------
  IEngine = interface
    function  log: ILog; 
    function  wnd: IWindow; 
    function  ogl: IOpenGL;
    {$IFNDEF NO_INP}function inp: IInput;{$ENDIF}
    {$IFNDEF NO_VBO}function vbo: IVBuffer;{$ENDIF}
    {$IFNDEF NO_TEX}function tex: ITexture;{$ENDIF}
    {$IFNDEF NO_VFP}function vfp: IShader;{$ENDIF}
    {$IFNDEF NO_SND}function snd: ISound;{$ENDIF}
    {$IFNDEF NO_NET}function net: INetwork;{$ENDIF}
    {$IFNDEF NO_VEC}function vec: IVector;{$ENDIF}
    function  Version: PChar; 
    procedure SetProc(ID: Integer; Proc: Pointer);
    procedure ActiveUpdate(OnlyActive: Boolean);
    function  GetTime: Integer;
    procedure ResetTimer;
    procedure MainLoop(UPS: Integer);
    procedure Update;
    procedure Render;
    procedure Quit; 
  end;

const
  eXgine_dll = 'eXgine.dll';

var
  log : ILog;
  eX  : IEngine;
  wnd : IWindow;
  ogl : IOpenGL;
  {$IFNDEF NO_VBO}vbo : IVBuffer;{$ENDIF}
  {$IFNDEF NO_TEX}tex : ITexture;{$ENDIF}
  {$IFNDEF NO_VFP}vfp : IShader;{$ENDIF}
  {$IFNDEF NO_SND}snd : ISound;{$ENDIF}
  {$IFNDEF NO_INP}inp : IInput;{$ENDIF}
  {$IFNDEF NO_NET}net : INetwork;{$ENDIF}
  {$IFNDEF NO_VEC}vec : IVector;{$ENDIF}

// Процедура инициализации eXgine и модулей
  procedure Init(LogFile: PChar = nil; LogProc: TLogProc = nil);

// Вспомогательные функции
  function IntToStr(Value: Integer): string;
  function StrToInt(const Str: string; DefValue: Integer = 0): Integer;
  procedure LogOut(const Text: string);
  function RGB(R, G, B: Byte): TRGB;
  function RGBA(R, G, B, A: Byte): TRGBA;

implementation

{$IFDEF EX_STATIC}
uses
  log, eng;
{$ENDIF}
                  
{$IFNDEF EX_STATIC}
procedure exInit(out Engine: IEngine; LogFile: PChar = nil; LogProc: TLogProc = nil); external eXgine_dll;
{$ELSE}
procedure exInit(out Engine: IEngine; LogFile: PChar = nil; LogProc: TLogProc = nil);
begin
  olog := TLog.CreateEx;
  if (LogFile <> nil) or (@LogProc <> nil) then
    olog.Create(LogFile, LogProc);
  oeng := TEng.CreateEx;
  Engine := oeng;
end;
{$ENDIF}

procedure DeInit;
begin
  {$IFNDEF NO_SND}snd := nil;{$ENDIF}
  {$IFNDEF NO_VEC}vec := nil;{$ENDIF}
  {$IFNDEF NO_NET}net := nil;{$ENDIF}
  {$IFNDEF NO_VFP}vfp := nil;{$ENDIF}
  {$IFNDEF NO_TEX}tex := nil;{$ENDIF}
  {$IFNDEF NO_VBO}vbo := nil;{$ENDIF}
  {$IFNDEF NO_INP}inp := nil;{$ENDIF}
  ogl := nil;
  wnd := nil;
  eX  := nil;
  eXgine.log := nil;
end;

procedure Init;
begin
  if eX <> nil then
    DeInit;
  exInit(eX, LogFile, LogProc);
  eXgine.log := eX.log;
  wnd := eX.wnd;
  ogl := eX.ogl;

  {$IFNDEF NO_INP}inp := eX.inp;{$ENDIF}
  {$IFNDEF NO_VBO}vbo := eX.vbo;{$ENDIF}
  {$IFNDEF NO_TEX}tex := eX.tex;{$ENDIF}
  {$IFNDEF NO_VFP}vfp := eX.vfp;{$ENDIF}
  {$IFNDEF NO_NET}net := eX.net;{$ENDIF}
  {$IFNDEF NO_VEC}vec := eX.vec;{$ENDIF}
  {$IFNDEF NO_SND}snd := eX.snd;{$ENDIF}
end;

function IntToStr;
begin
  Str(Value, Result);
end;

function StrToInt;
var
  er : Integer;
begin
  Val(Str, Result, er);
  if er <> 0 then
    Result := DefValue;
end;

procedure LogOut;
begin
  eXgine.log.Print(PChar(Text));
end;

function RGB;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
end;

function RGBA;
begin
  Result.R := R;
  Result.G := G;
  Result.B := B;
  Result.A := A;
end;

// От создателя.
// Я не настаиваю на обязательном наличии этой записи в exe
// Но надеюсь, что Вам она не помешает, а мне от этого будет приятно :)
procedure Copyright;
begin
end;

exports
  Copyright name #13#10#13#10'<<< Based on eXgine >>>'#13#10#13#10;

initialization
  {$IFNDEF EX_INIT}Init({$IFNDEF NO_LOG}'log.txt'{$ENDIF});{$ENDIF}

finalization
  DeInit;
end.
