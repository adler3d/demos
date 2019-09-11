unit inp;

interface

{$I cfg.pas}

uses
  Windows, {$IFNDEF NO_JOY}MMSystem,{$ENDIF} sys_main, eXgine;

type
  TKey = Boolean;
  
{$IFNDEF NO_JOY}
  TJoy = record
    ID    : Cardinal;
    Caps  : TJoyCaps;
    Info  : TJoyInfoEx;
    Axis  : TJoyAxis;
    POV   : Single;
  end;
{$ENDIF}

  TInp = class(TInterface, IInput)
    constructor CreateEx;
    destructor Destroy; override;
   public
    procedure Reset;
    function Down(Key: Integer): Boolean;
    function LastKey: Integer;
    function MDelta: TVector2f;
    function WDelta: Integer;
   {$IFNDEF NO_JOY}
    function JCount: Integer;
    function JAxis(ID: Integer): TJoyAxis;
    function JPOV(ID: Integer): Single;
   {$ENDIF}
    procedure MCapture(Active: Boolean);
  public
   {$IFNDEF NO_JOY}
    joy_ready : Boolean;
    Joy       : array of TJoy;
   {$ENDIF}
    Key       : array of TKey;
  public
    m_delta  : TVector2f;
    m_wdelta : Integer;
    m_cap    : Boolean;
    v_klast  : Integer;
    procedure log(const Text: string);
    procedure Update;
    procedure SetKey(Key: Integer; Value: Boolean = True);
  end;

implementation

uses
  eng;

constructor TInp.CreateEx;
{$IFNDEF NO_JOY}
var
  i       : Integer;
  cps     : TJoyCaps;
  joy_num : Integer;
{$ENDIF}
begin
  inherited;
  log('Keyboard ready');
// Мышь
  m_delta.X := 0;
  m_delta.Y := 0;
  m_cap     := False;
  log('Mouse    ready');
{$IFNDEF NO_JOY}
// Джойстик
  joy_num := joyGetNumDevs;
  if joy_num <> 0 then
  begin
  // Ищем активный
    for i := 0 to joy_num - 1 do
      if joyGetDevCaps(i, @cps, SizeOf(cps)) = JOYERR_NOERROR then
      begin
        SetLength(Joy, Length(Joy) + 1);
        with Joy[High(Joy)] do
        begin
          ID   := i;
          Caps := cps;
          Info.dwSize  := SizeOf(Info);
          Info.dwFlags := JOY_RETURNALL or JOY_CAL_READ6 or JOY_USEDEADZONE;
          if Caps.wCaps and JOYCAPS_POVCTS > 0 then
            Info.dwFlags := Info.dwFlags or JOY_RETURNPOVCTS;
          if joyGetPosEx(ID, @Info) <> JOYERR_NOERROR then
          begin
            SetLength(Joy, Length(Joy) - 1);
            log('- Joystick (' + IntToStr(ID) + ') init error');
          end else
            with Caps do
            begin
            // Если джойстик найден - получаем о нём информацию
              log('- Joystick (' + IntToStr(ID) + ') found');
              log('-- Driver  : ' + szPname);
              log('-- Buttons : ' + IntToStr(wNumButtons));
              log('-- Axis    : ' + IntToStr(wNumAxes));
            end
        end;
      end;
  end;

  joy_ready := Length(Joy) > 0; 
  if joy_ready then
    log('Joystick ready')
  else
    log('Joystick not ready');

  SetLength(Key, 263 + Length(Joy) * 32);
{$ELSE}
  SetLength(Key, 263);
{$ENDIF}
  Reset;
end;

destructor TInp.Destroy;
begin
  {$IFNDEF NO_JOY}Joy := nil;{$ENDIF}
  Key := nil;
  inherited;
end;

procedure TInp.Reset;
begin
  if Length(Key) > 0 then
    FillChar(Key[0], Length(Key) * SizeOf(ShortInt), 0);
end;

function TInp.Down(Key: Integer): Boolean;
begin
  if (Key < 0) or (Key > High(Self.Key)) then
    Result := False
  else
    Result := Self.Key[Key];
end;

function TInp.LastKey: Integer;
begin
  Result := v_klast;
end;

function TInp.MDelta: TVector2f;
begin
  Result := m_delta;
end;

function TInp.WDelta: Integer;
begin
  Result := m_wdelta;
end;

{$IFNDEF NO_JOY}
function TInp.JCount: Integer;
begin
  Result := Length(Joy);
end;

function TInp.JAxis(ID: Integer): TJoyAxis;
begin
  if (ID < 0) or (ID > High(Joy)) then
    FillChar(Result, SizeOf(TJoyAxis), 0)
  else
    Result := Joy[ID].Axis;
end;

function TInp.JPOV(ID: Integer): Single;
begin
  if (ID < 0) or (ID > High(Joy)) then
    Result := 0
  else
    Result := Joy[ID].POV;
end;
{$ENDIF}

procedure TInp.MCapture(Active: Boolean);
begin
  if m_cap <> Active then
    ShowCursor(m_cap);
  m_cap := Active;
  Update;
  m_delta.X := 0;
  m_delta.Y := 0;
end;

procedure TInp.log(const Text: string);
begin
  olog.Print(PChar('Input   : ' + Text));
end;

procedure TInp.Update;
var
{$IFNDEF NO_JOY}
  i, j : Integer;
{$ENDIF}
  Rect : TRect;
  Pos  : Windows.TPoint;
begin
// вычисление смещения мыши
  if ownd.Active and m_cap then
  begin
    GetWindowRect(ownd.wnd_handle, Rect);
    GetCursorPos(Pos);
    m_delta.X := Pos.X - Rect.Left - (Rect.Right - Rect.Left) div 2;
    m_delta.Y := Pos.Y - Rect.Top  - (Rect.Bottom - Rect.Top) div 2;
    SetCursorPos(Rect.Left + (Rect.Right - Rect.Left) div 2, Rect.Top + (Rect.Bottom - Rect.Top) div 2);
  end;
  
{$IFNDEF NO_JOY}
// Ввод с джойстика
  if joy_ready then
    for i := 0 to Length(Joy) - 1 do
      with Joy[i] do
        if joyGetPosEx(id, @Info) = JOYERR_NOERROR then
        begin
        // Вычисление смещения рукояти/крестовины/штурвала... называйте как хотите
          Axis.X := (Info.wXpos + Caps.wXmin)/(Caps.wXmax - Caps.wXmin) * 200 - 100;
          Axis.Y := (Info.wYpos + Caps.wYmin)/(Caps.wYmax - Caps.wYmin) * 200 - 100;

          if Caps.wCaps and JOYCAPS_HASZ > 0 then
            Axis.Z := (Info.wZpos + Caps.wZmin)/(Caps.wZmax - Caps.wZmin) * 200 - 100
          else
            Axis.Z := 0;

          if Caps.wCaps and JOYCAPS_HASR > 0 then
            Axis.R := (Info.dwRpos + Caps.wRmin)/(Caps.wRmax - Caps.wRmin) * 200 - 100
          else
            Axis.R := 0;

          if Caps.wCaps and JOYCAPS_HASU > 0 then
            Axis.U := (Info.dwUpos + Caps.wUmin)/(Caps.wUmax - Caps.wUmin) * 200 - 100
          else
            Axis.U := 0;

          if Caps.wCaps and JOYCAPS_HASV > 0 then
            Axis.V := (Info.dwVpos + Caps.wVmin)/(Caps.wVmax - Caps.wVmin) * 200 - 100
          else
            Axis.V := 0;
            
        // Point-Of-View
          if (Caps.wCaps and JOYCAPS_HASPOV > 0) and (Info.dwPOV and $FFFF <> $FFFF) then
            POV := Info.dwPOV and $FFFF / 100
          else
            POV := -1;

        // Проверка и обновление состояния клавиш
          for j := 0 to Integer(Caps.wNumButtons) - 1 do
            if (Info.wButtons and (1 shl j) <> 0) and (not Key[J_BTN_1 + i * 32 + j]) then
              SetKey(J_BTN_1 + i * 32 + j) // нажали
            else
              if (not (Info.wButtons and (1 shl j) <> 0)) and Key[J_BTN_1 + i * 32 + j] then
                SetKey(J_BTN_1 + i * 32 + j, False); // отпустили
        end else
        begin
        // джойстик разбили об пол! ;)
          POV := 0;
          FillChar(Axis, SizeOf(TJoyAxis), 0);
          FillChar(Key[J_BTN_1 + i * 32], 32 * SizeOf(TKey), 0);
        end;
{$ENDIF}        
end;

procedure TInp.SetKey(Key: Integer; Value: Boolean);
begin
  // Т.к. эта процедура вызывается только из движка
  // ошибки криворукого вызова исключены ;)
  // следовательно, key проверять диапозон не стоит ;)
  Self.Key[key] := Value;
  if Value then
    v_klast := Key;
end;

end.
