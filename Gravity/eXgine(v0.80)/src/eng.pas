unit eng;

interface

{$I cfg.pas}

uses
  Windows, sys_main, eXgine,
  {$IFNDEF NO_INP}inp,{$ENDIF}
  {$IFNDEF NO_VBO}vbo,{$ENDIF}
  {$IFNDEF NO_TEX}tex,{$ENDIF}
  {$IFNDEF NO_VFP}vfp,{$ENDIF}
  {$IFNDEF NO_SND}snd,{$ENDIF}
  {$IFNDEF NO_NET}net,{$ENDIF}
  {$IFNDEF NO_VEC}vec,{$ENDIF}
  log, wnd, ogl;

const
  ENG_NAME = 'eXgine';
  ENG_VER  = '0.80';

type
  TEng = class(TInterface, IEngine)
    constructor CreateEx;
   public
    function log: ILog; overload; 
    function wnd: IWindow; 
    function ogl: IOpenGL;
    {$IFNDEF NO_INP}function inp: IInput;{$ENDIF}
    {$IFNDEF NO_VBO}function vbo: IVBuffer;{$ENDIF}
    {$IFNDEF NO_TEX}function tex: ITexture;{$ENDIF}
    {$IFNDEF NO_VFP}function vfp: IShader;{$ENDIF}
    {$IFNDEF NO_SND}function snd: ISound;{$ENDIF}
    {$IFNDEF NO_NET}function net: INetwork;{$ENDIF}
    {$IFNDEF NO_VEC}function vec: IVector;{$ENDIF}
    function Version: PChar;
    procedure SetProc(ID: Integer; Proc: Pointer);
    procedure ActiveUpdate(OnlyActive: Boolean);
    function  GetTime: Integer;
    procedure ResetTimer;
    procedure MainLoop(UPS: Integer);
    procedure Update;
    procedure Render;
    procedure Quit;
   public
   // procedures
    ProcUpdate  : TProcUpdate;
    ProcRender  : TProcRender;
    ProcMessage : TProcMessage;
    ProcActive  : TProcActive;
    ProcInit    : TProcInit;
    ProcFree    : TProcFree;
  // fps - frames per second
    fps_time     : Integer;
    fps_cur      : Integer;
    FPS          : Integer;
    Timer_Freq   : LARGE_INTEGER;
  // ups - updates per second
    ups_time_old : Integer;  // Время с последнего вызова eng_update
    ups_time     : Integer;  // Время предыдущего замера ups
    Time, Time_Delta : Integer;
    OnlyActive   : Boolean;
    procedure log(const Text: string); overload;
    procedure onActive;
  end;

var
  eng_isquit : Boolean;
  oeng : TEng;
  olog : TLog;
  ownd : TWnd;
  oogl : TOGL;
  {$IFNDEF NO_INP}oinp : TInp;{$ENDIF}
  {$IFNDEF NO_VBO}ovbo : TVBO;{$ENDIF}
  {$IFNDEF NO_TEX}otex : TTex;{$ENDIF}
  {$IFNDEF NO_VFP}ovfp : TVFP;{$ENDIF}
  {$IFNDEF NO_SND}osnd : TSnd;{$ENDIF}
  {$IFNDEF NO_NET}onet : TNet;{$ENDIF}
  {$IFNDEF NO_VEC}ovec : TVec;{$ENDIF}

implementation

constructor TEng.CreateEx;
var
  SysInfo : _SYSTEM_INFO;
begin
  inherited;
  ProcUpdate  := nil;
  ProcRender  := nil;
  ProcMessage := nil;
  ProcActive  := nil;
  eng_isquit := False;
  OnlyActive := False;
// установка языка ввода (English)
  LoadKeyboardLayout('00000409', KLF_ACTIVATE);

// Нет смысла брать частоту системного таймера каждый раз...
  QueryPerformanceFrequency(Int64(Timer_Freq));

// На многоядерных и многопроцессорных компьютерах наблюдается
// неприятный глюк с таймером. Этот код переводит выполнение процесса на одно ядро/процессор
  GetSystemInfo(SysInfo);
  SetProcessAffinityMask(GetCurrentProcess, SysInfo.dwActiveProcessorMask);

// Создание основных объектов
  {$IFNDEF NO_VEC}ovec := TVec.CreateEx;{$ENDIF}
  {$IFNDEF NO_NET}onet := TNet.CreateEx;{$ENDIF}
  {$IFNDEF NO_SND}osnd := TSnd.CreateEx;{$ENDIF}
  {$IFNDEF NO_INP}oinp := TInp.CreateEx;{$ENDIF}
  oogl := TOGL.CreateEx;
  {$IFNDEF NO_VBO}ovbo := TVBO.CreateEx;{$ENDIF}
  {$IFNDEF NO_TEX}otex := TTex.CreateEx;{$ENDIF}
  ownd := TWnd.CreateEx;
  {$IFNDEF NO_VFP}ovfp := TVFP.CreateEx;{$ENDIF}
end;

function TEng.log: ILog;
begin
  Result := olog;
end;

function TEng.wnd: IWindow;
begin
  Result := ownd;
end;

function TEng.ogl: IOpenGL;
begin
  Result := oogl;
end;

{$IFNDEF NO_INP}
function TEng.inp: IInput;
begin
  Result := oinp;
end;
{$ENDIF}

{$IFNDEF NO_VBO}
function TEng.vbo: IVBuffer;
begin
  Result := ovbo;
end;
{$ENDIF}

{$IFNDEF NO_TEX}
function TEng.tex: ITexture;
begin
  Result := otex;
end;
{$ENDIF}

{$IFNDEF NO_VFP}
function TEng.vfp: IShader;
begin
  Result := ovfp;
end;
{$ENDIF}

{$IFNDEF NO_SND}
function TEng.snd: ISound;
begin
  Result := osnd;
end;
{$ENDIF}

{$IFNDEF NO_NET}
function TEng.net: INetwork;
begin
  Result := onet;
end;
{$ENDIF}

{$IFNDEF NO_VEC}
function TEng.vec: IVector;
begin
  Result := ovec;
end;
{$ENDIF}

function TEng.Version: PChar;
begin
  Result := PChar(ENG_NAME + ' ' + ENG_VER);
end;

procedure TEng.SetProc(ID: Integer; Proc: Pointer);
begin
  case ID of
    PROC_UPDATE  : ProcUpdate  := Proc;
    PROC_RENDER  : ProcRender  := Proc;
    PROC_MESSAGE : ProcMessage := Proc;
    PROC_ACTIVE  : ProcActive  := Proc;
    PROC_INIT    : ProcInit    := Proc;
    PROC_FREE    : ProcFree    := Proc;
  end;
end;

procedure TEng.ActiveUpdate(OnlyActive: Boolean);
begin
  self.OnlyActive := OnlyActive;
end;

function TEng.GetTime: Integer;
var
  T : LARGE_INTEGER;
begin
  QueryPerformanceCounter(Int64(T));
  Result := Trunc(1000 * T.QuadPart / Timer_Freq.QuadPart);
end;

procedure TEng.ResetTimer;
begin
  // Сброс состояния таймера
  ups_time_old := GetTime;
end;

procedure TEng.MainLoop(UPS: Integer);
var
  msg : TMsg;
begin
  try
    if @ProcInit <> nil then
      ProcInit;
  except
    log('Error in ProcInit');
  end;

  log('Main Loop start');
// Инициализация таймера
  ups_time_old := GetTime - 1000 div UPS;
  ups_time     := GetTime;
  fps_time     := GetTime;

//== ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ СООБЩЕНИЙ И ТАЙМИНГА ==//
  while not eng_isquit do
  begin
  // обработка Windows сообщений
    while PeekMessage(msg, ownd.Handle, 0, 0, PM_REMOVE) do
    begin
      TranslateMessage(msg);
      DispatchMessage(msg);
    end;
  // Тайминг
    if (ownd.wnd_active and OnlyActive) or (not OnlyActive) then
    begin
      while GetTime - ups_time_old >= (1000 div UPS) do
      begin
        Update;
        inc(ups_time_old, 1000 div UPS);
      end;
      Render;
    end else
      WaitMessage;
  end;
  log('Main Loop stop');

  try
    if @ProcFree <> nil then
      ProcFree;
  except
    log('Error in ProcFree');
  end;
end;

procedure TEng.Update;
begin
  if eng_isquit then Exit;
{$IFNDEF NO_INP}oinp.Update;{$ENDIF}
  try
    if @ProcUpdate <> nil then
      ProcUpdate;
  except
    log('Error in ProcUpdate');
  end;
{$IFNDEF NO_SND}osnd.Update;{$ENDIF}
// Сбрасываем хначения в Input
{$IFNDEF NO_INP}
  oinp.v_klast   := -1;
  oinp.m_wdelta  := 0;
  oinp.m_delta.X := 0;
  oinp.m_delta.Y := 0;
{$ENDIF}
end;

procedure TEng.Render;
begin
  if eng_isquit then Exit;
  try
    if @ProcRender <> nil then
      ProcRender;
  except
    log('Error in ProcRender');
  end;
  oogl.Swap;
end;

procedure TEng.Quit;
begin
  eng_isquit := True;
end;

procedure TEng.log(const Text: string);
begin
  olog.Print(PChar('Engine  : ' + Text));
end;

procedure TEng.onActive;
begin
  try
    if @ProcActive <> nil then
      ProcActive(ownd.Active);
  except
    log('Error in ProcActive');
  end;
end;

end.
