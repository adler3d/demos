unit wnd;

interface
{$I cfg.pas}
uses
  Windows, Messages, {$IFNDEF NO_MCI}MMSystem,{$ENDIF} OpenGL,
  sys_main, eXgine;

type
  TWnd = class(TInterface, IWindow)
    constructor CreateEx;
    destructor Destroy; override;
   public
    function Create(Caption: PChar; OnTop: Boolean): Boolean; overload;
    function Create(Handle: Cardinal): Boolean; overload;
    function Handle: Cardinal;
    procedure Caption(Text: PChar); 
    function Width: Integer; 
    function Height: Integer; 
    function Mode(FullScreen: Boolean; W, H, BPP, Freq: Integer): Boolean; 
    procedure Show(Minimized: Boolean); 
    function Active: Boolean; 
   public
    wnd_ready  : Boolean;
    wnd_nonex  : Boolean; // окно создано не eXgine
    wnd_handle : DWORD;
    wnd_width  : Integer;
    wnd_height : Integer;
    wnd_active : Boolean;
    wnd_mode   : Boolean;
    BPP, Freq  : Integer;
    DefProc    : function (hWnd: HWND; Msg: Cardinal; wParam: Integer; lParam: Integer): Integer; stdcall;
    procedure log(const Text: string);
    procedure Restore;
  end;


implementation

uses
  eng;

const
  WND_TITLE = ENG_NAME;
  WND_CLASS = ENG_NAME + '_wnd';

//== Процедура обработки сообщений
function WndProc(hWnd: HWND; Msg: Cardinal; wParam: Integer; lParam: Integer): Integer; stdcall;
const
  WM_XBUTTONDOWN = $020B;
  WM_XBUTTONUP   = $020C;
var
  s : string;
  d : TDevMode;
begin
{$IF (NOT DEFINED(NO_SND)) AND (NOT DEFINED(NO_MCI))}
  if (Msg = MM_MCINOTIFY) and (wParam = MCI_NOTIFY_SUCCESSFUL) then
    osnd.ReplayFile;
{$IFEND}

  if not ownd.wnd_nonex then
  case Msg of
	  WM_SYSKEYDOWN:
      case wParam of
        VK_RETURN : with ownd do
                      Mode(wnd_mode, wnd_width, wnd_height, BPP, Freq);
      {$IFNDEF NO_INP}
        VK_SPACE  : with oinp do
                      MCapture(not m_cap);
      {$ENDIF}
      end;

    WM_DESTROY :
      begin
      // Высвобождение занятых ресурсов
        eng_isquit := True;
      // Отправка сообщения WM_QUIT главному окну
//        PostQuitMessage(0);
        Result := 0;
        Exit;
      end;
      
  // Активация/Деактивация главного окна
    WM_ACTIVATEAPP :
      begin
      // Сброс состояний клавиш
        {$IFNDEF NO_INP}oinp.Reset;{$ENDIF}
      // Активация / Деактивация окна
        with ownd do
          if LOWORD(wParam) = WA_ACTIVE then
          begin
            wnd_active := True;
            if not wnd_mode then Show(False);
          // Если не в оконном режиме - переход в полноэкранный
            if not wnd_mode then
              Mode(True, wnd_width, wnd_height, BPP, Freq);
            if oeng.onlyactive then
              oeng.ResetTimer;
          end else
          begin
            wnd_active := False;
            if not wnd_mode then
            begin
              Show(True);
              Mode(False, wnd_width, wnd_height, BPP, Freq);
              wnd_mode := False;
            end;
          end;
        oeng.onActive;
      end;

  // смена графического режима
    WM_DISPLAYCHANGE :
      begin
        s := IntToStr(LOWORD(lParam)) + 'x' +
             IntToStr(HIWORD(lParam)) + 'x' + 
             IntToStr(wParam);
        if EnumDisplaySettings(nil, Cardinal(-1), d) then
          s := s + 'x' + IntToStr(d.dmDisplayFrequency);
        ownd.log(PChar(s));
      end;
  {$IFNDEF NO_INP}
  // клавиатура
    WM_KEYUP   : oinp.SetKey(wParam, False);
    WM_KEYDOWN : oinp.SetKey(wParam);
  // мышь
    WM_LBUTTONUP   : oinp.SetKey(M_BTN_1, False);
    WM_RBUTTONUP   : oinp.SetKey(M_BTN_2, False);
    WM_MBUTTONUP   : oinp.SetKey(M_BTN_3, False);
    WM_XBUTTONUP   : oinp.SetKey(M_BTN_4 + HIWORD(wParam), False);
    WM_LBUTTONDOWN : oinp.SetKey(M_BTN_1);
    WM_RBUTTONDOWN : oinp.SetKey(M_BTN_2);
    WM_MBUTTONDOWN : oinp.SetKey(M_BTN_3);
    WM_XBUTTONDOWN : oinp.SetKey(M_BTN_4 + HIWORD(wParam));
    WM_MOUSEWHEEL  : oinp.m_wdelta := SmallInt(HIWORD(wParam)) div 120;
  {$ENDIF}    
  end;
// Стандартная обработка сообщения
  Result := ownd.DefProc(hWnd, Msg, wParam, lParam);
  try
    if @oeng.ProcMessage <> nil then
      oeng.ProcMessage(Msg, wParam, lParam);
  except
    oeng.log('Error in ProcMessage');
  end;
end;

constructor TWnd.CreateEx;
begin
  inherited;
  wnd_ready  := False;
  wnd_active := False;
  wnd_mode   := True;
  wnd_width  := 640;
  wnd_height := 480;
  BPP        := 16;
  Freq       := 60;
end;

destructor TWnd.Destroy;
begin
  if wnd_ready and (not wnd_nonex) then
  begin
    wnd_ready := False;
    DestroyWindow(wnd_handle);
    log('Destroy main window');
  end;
  inherited;
end;

function TWnd.Create(Caption: PChar; OnTop: Boolean): Boolean;
var
  wnd : TWndClassEx;
begin
  Result := True;
  if wnd_ready then
    Exit;
  if wnd_nonex then
  begin
    log('Setting main window');
    DefProc   := Pointer(SetWindowLong(wnd_handle, GWL_WNDPROC, Integer(@WndProc)));
    wnd_ready := True;
  end else
  begin
    Result := False;
    if oogl.AASamples > 0 then
      oogl.GetPixelFormat; // Узнаём допустимое кол-во сэмплов под AntiAliasing
    log('Create main window');
  //== Создание главного окна программы ==//
  // Регистрация класса главного окна
    ZeroMemory(@wnd, SizeOf(wnd));
    with wnd do
    begin
      cbSize        := SizeOf(wnd);
      lpfnWndProc   := @WndProc;
      hCursor       := LoadCursor(0, IDC_ARROW);
      lpszClassName := WND_CLASS;
    end;

    if RegisterClassEx(wnd) = 0 then
    begin
      log('Fatal Error "RegisterClassEx"');
      Exit;
    end;

  // Создаём окно
    DefProc := DefWindowProc;
    wnd_handle := CreateWindowEx(WS_EX_TOPMOST * Byte(OnTop = True), WND_CLASS, Caption, WS_POPUP,
                                 0, 0, 0, 0, 0, 0, 0, nil);
    wnd_ready := wnd_handle <> 0;
    if wnd_handle = 0 then
    begin
      log('Fatal Error "CreateWindoEx"');
      Exit;
    end;
  end;
// инициализация графического ядра
  if not oogl.Init then
    Exit;
// инициализация звука
  {$IFNDEF NO_SND}osnd.Init;{$ENDIF}
// Показываем окно
  if not wnd_nonex then
  begin
    SetForegroundWindow(wnd_handle);
    ShowWindow(wnd_handle, SW_SHOW);
  end;
  UpdateWindow(wnd_handle);
  Restore;
  {$IFNDEF NO_INP}oinp.MCapture(True){$ENDIF};
  Result := True;
end;

function TWnd.Create(Handle: Cardinal): Boolean;
begin
  Result := False;
  if wnd_ready then
    Exit;
  wnd_nonex  := True;
  wnd_handle := Handle;
  Result := self.Create(nil, False);
end;

function TWnd.Handle: Cardinal;
begin
  Result := wnd_handle;
end;

procedure TWnd.Caption(Text: PChar);
begin
  SetWindowText(wnd_handle, Text);
end;

function TWnd.Width: Integer;
var
  Rect : TRect;
begin
  GetClientRect(Handle, Rect);
  Result := Rect.Right;
end;

function TWnd.Height: Integer;
var
  Rect : TRect;
begin
  GetClientRect(Handle, Rect);
  Result := Rect.Bottom;
end;

function TWnd.Mode(FullScreen: Boolean; W, H, BPP, Freq: Integer): Boolean;

 function ModeStr: string;
 begin
   Result := IntToStr(W) + 'x' + IntToStr(H) + 'x' + IntToStr(BPP) + 'x' + IntToStr(Freq);
 end;

var
  dev  : TDeviceMode;
  res  : DWORD;
  bool : Boolean;
label
  ext;
begin
  Result := False;
  if wnd_nonex then Exit;
  if not FullScreen then
  begin
    ChangeDisplaySettings(_devicemodeA(nil^), CDS_FULLSCREEN);
    wnd_mode := True;
    goto ext;
  end;
  FillChar(dev, SizeOf(dev), 0);
  dev.dmSize := SizeOf(dev);
  EnumDisplaySettings(nil, 0, dev);
  with dev do
  begin
    dmPelsWidth        := W;
    dmPelsHeight       := H;
    dmBitsPerPel       := BPP;
    dmDisplayFrequency := Freq;
    dmFields := DM_BITSPERPEL or
                DM_PELSWIDTH  or
                DM_PELSHEIGHT or
                DM_DISPLAYFREQUENCY;
    res := ChangeDisplaySettings(dev, CDS_TEST or CDS_FULLSCREEN);
    if res = DISP_CHANGE_SUCCESSFUL then
      ChangeDisplaySettings(dev, CDS_FULLSCREEN);
  end;

  if res <> DISP_CHANGE_SUCCESSFUL then
  begin
    bool := False;
    if Freq > 0 then
      bool := Mode(FullScreen, W, H, BPP, 0);
    if not bool then
    begin
      log('Can''t set video mode: ' + ModeStr);
      Mode(False, W, H, self.BPP, self.Freq);
      wnd_mode := True;
      Restore;
      Exit;
    end;
  end;

  wnd_mode  := False;
ext:
  self.BPP   := BPP;
  self.Freq  := Freq;
  wnd_width  := W;
  wnd_height := H;
  Restore;
  Result := True;
end;

procedure TWnd.Show(Minimized: Boolean);
begin
  if not wnd_nonex then
    if Minimized then
      ShowWindow(wnd_handle, SW_SHOWMINIMIZED)
    else
      ShowWindow(wnd_handle, SW_SHOWNORMAL);
end;

function TWnd.Active: Boolean;
begin
  Result := wnd_active;
end;

procedure TWnd.log(const Text: string);
begin
  olog.Print(PChar('Window  : ' + Text));
end;

procedure TWnd.Restore;
var
  Style : DWORD;
  Rect  : TRect;
begin
  glFinish;
// изменение стиля окна в зависимости от режима работы
  if not wnd_nonex then
  begin
    if wnd_mode then
      Style := WS_CAPTION
    else
      Style := WS_OVERLAPPED;
    SetWindowLong(wnd_handle, GWL_STYLE, Style or WS_VISIBLE);
    Rect.Left   := 0;
    Rect.Top    := 0;
    Rect.Right  := wnd_width;
    Rect.Bottom := wnd_height;
    AdjustWindowRect(Rect, Style, False);
    with Rect do
      SetWindowPos(wnd_handle, 0, 0, 0, Right - Left, Bottom - Top, SWP_FRAMECHANGED or SWP_NOOWNERZORDER);
    ShowWindow(wnd_handle, SW_SHOW);
  end;
  glViewport(0, 0, wnd_width, wnd_height);
end;

end.
