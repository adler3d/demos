unit sys_main;

interface

{
  Данный модуль является частичной заменой стандартного SysUtils
  Зачем заменять? Чтобы не таскать за собой всякий не нужный хлам...
  Реализовано:
   - высокоточный таймер
   - Перевод Integer в String и обратно
   - Перехват исключений (try except finally)
   - Потоки работы с файлами и памятью
}

uses
  Windows;

const
  NULL_FILE = INVALID_HANDLE_VALUE;

type
  TFile = DWORD;
  TByteArray = array [0..1023] of Byte;
  PByteArray = ^TByteArray;

// Time
  function GetTime: Integer;
// Int convert
  function IntToStr(Value: Integer): string;
  function StrToInt(const S: string): Integer;
  function StrToIntDef(const S: string; Default: Integer): Integer;
// strings
  function LowerCase(const s: string): string;
// FileNames
  function ExtractFileExt(const FileName: string): string;

  function FileOpen(FileName: PChar; Rewrite: Boolean = False): TFile;
  function FileValid(F: TFile): Boolean;
  procedure FileClose(var F: TFile);
  procedure FileFlush(F: TFile);
  function FileWrite(F: TFile; const Buf; Count: DWORD): DWORD;
  function FileRead(F: TFile; var Buf; Count: DWORD): DWORD;
  procedure FileSeek(F: TFile; Pos: Integer);
  function FileSize(F: TFile): DWORD;
  function FilePos(F: TFile): DWORD;
  function FileExists(FileName: PChar): Boolean;

type
  TInterface = class(TInterfacedObject)
    constructor CreateEx;
  end;

  TIntStatic = class(TInterface)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TStream = class
    procedure Seek(Pos: Integer); virtual; abstract;
    function Valid: Boolean; virtual; abstract;
    function Read(var Buf; Count: Integer): Integer; virtual; abstract;
    function Size: Integer; virtual; abstract;
    function Pos: Integer; virtual; abstract;
  end;

  TFileStream = class(TStream)
    constructor Create(FileName: string);
    destructor Destroy; override;
   private
    F : TFile;
   public
    procedure Seek(Pos: Integer); override;
    function Valid: Boolean; override;
    function Read(var Buf; Count: Integer): Integer; override;
    function Size: Integer; override;
    function Pos: Integer; override;
  end;

  TMemoryStream = class(TStream)
    constructor Create(Mem: Pointer; Size: Integer);
   private
    FMem  : Pointer;
    FSize : Integer;
    FPos  : Integer;
   public
    procedure Seek(Pos: Integer); override;
    function Valid: Boolean; override;
    function Read(var Buf; Count: Integer): Integer; override;
    function Size: Integer; override;
    function Pos: Integer; override;
  end;

implementation

//== Получение точного системного времени
function GetTime: Integer;
var
  T : LARGE_INTEGER;
  F : LARGE_INTEGER;
begin
  QueryPerformanceFrequency(Int64(F));
  QueryPerformanceCounter(Int64(T));
  Result := Trunc(1000 * T.QuadPart / F.QuadPart);
end;

//== Int
function IntToStr(Value: Integer): string;
begin
  Str(Value, Result);
end;

function StrToInt(const S: string): Integer;
var
  er : Integer;
begin
  Val(S, Result, er);
end;

function StrToIntDef(const S: string; Default: Integer): Integer;
var
  er : Integer;
begin
  Val(S, Result, er);
  if er = 0 then
    Result := Default;
end;

function LowerCase(const s: string): string;
var
  i, l   : integer;
  Rc, Sc : PChar;
begin
  l := Length(s);
  SetLength(Result, l);
  Rc := Pointer(Result);
  Sc := Pointer(s);
  for i := 1 to l do
  begin
    if s[i] in ['A'..'Z', 'А'..'Я'] then
      Rc^ := Char(Byte(Sc^) + 32)
    else
      Rc^ := Sc^;
    inc(Rc);
    inc(Sc);
  end;
end;

function ExtractFileExt(const FileName: string): string;
var
  i : Integer;
begin
  for i := Length(FileName) downto 1 do
    if FileName[i] = '.' then
    begin
      Result := Copy(FileName, i + 1, Length(FileName));
      Exit;
    end;
  Result := '';
end;

//=== Работа с файлами ===--------------------------------------------
// открыть файл
function FileOpen(FileName: PChar; Rewrite: Boolean): TFile;
begin
  if Rewrite then
    Result := CreateFile(FileName, GENERIC_ALL, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0)
  else
    Result := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
end;

// является ли F - верным указателем на файл
function FileValid(F: TFile): Boolean;
begin
  Result := F <> NULL_FILE;
end;

// закрыть файл
procedure FileClose(var F: TFile);
begin
  if FileValid(F) then
  begin
    CloseHandle(F);
    F := NULL_FILE;
  end;
end;

// сбросить содержимое буфера в файл
procedure FileFlush(F: TFile);
begin
  FlushFileBuffers(F);
end;

// запись данных в файл
function FileWrite(F: TFile; const Buf; Count: DWORD): DWORD;
begin
  WriteFile(F, Buf, Count, Result, nil);
end;

// чтение данных из файла
function FileRead(F: TFile; var Buf; Count: DWORD): DWORD;
begin
  ReadFile(F, Buf, Count, Result, nil);
end;

procedure FileSeek(F: TFile; Pos: Integer);
begin
  SetFilePointer(F, Pos, nil, FILE_BEGIN);
end;

function FileSize(F: TFile): DWORD;
begin
  Result := GetFileSize(F, nil);
end;

function FilePos(F: TFile): DWORD;
begin
  Result := SetFilePointer(F, 0, nil, FILE_CURRENT);
end;

function FileExists(FileName: PChar): Boolean;
var
  F : TFile;
begin
  F := FileOpen(FileName, False);
  Result := FileValid(F);
  if Result then
    FileClose(F);
end;

// TInterface
constructor TInterface.CreateEx;
begin
  inherited Create;
end;

// TIntStatic
function TIntStatic.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := 0;
end;

function TIntStatic._AddRef: Integer;
begin
  Result := 0;
end;

function TIntStatic._Release: Integer;
begin
  Result := 0;
end;

// TFileStream
constructor TFileStream.Create(FileName: string);
begin
  F := FileOpen(PChar(FileName));
end;

destructor TFileStream.Destroy;
begin
  if Valid then
    FileClose(F);
end;

function TFileStream.Valid: Boolean;
begin
  Result := FileValid(F);
end;

procedure TFileStream.Seek(Pos: Integer);
begin
  FileSeek(F, Pos);
end;

function TFileStream.Read(var Buf; Count: Integer): Integer;
begin
  try
    Result := FileRead(F, Buf, Count);
  except
    Result := 0;
  end;
end;

function TFileStream.Size: Integer;
begin
  Result := FileSize(F);
end;

function TFileStream.Pos: Integer;
begin
  Result := FilePos(F);
end;

// TMemoryStream
constructor TMemoryStream.Create(Mem: Pointer; Size: Integer);
begin
  FMem  := Mem;
  FSize := Size;
end;

function TMemoryStream.Valid: Boolean;
begin
  Result := FMem <> nil;
end;

procedure TMemoryStream.Seek(Pos: Integer);
begin
  FPos := Pos;
end;

function TMemoryStream.Read(var Buf; Count: Integer): Integer;
begin
  if FSize - FPos < Count then
    Result := FSize - FPos
  else
    Result := Count;

  try
    Move(Pointer(Integer(FMem) + FPos)^, Buf, Result);
    FPos := FPos + Result;
  except
    Result := 0;
  end;
end;

function TMemoryStream.Size: Integer;
begin
  Result := FSize;
end;

function TMemoryStream.Pos: Integer;
begin
  Result := FPos;
end;

//=== Обработка / перехват исключений ===-----------------------------
function GetExceptionObject(P: PExceptionRecord): TObject;
begin
  Result := TObject.Create;
end;

procedure ErrorHandler(ErrorCode: Byte; ErrorAddr: Pointer); export;
begin
  raise TObject.Create at ErrorAddr;
end;

procedure ExceptHandler(ExceptObject: TObject; ExceptAddr: Pointer); far;
begin
  //
end;

initialization
  ErrorProc      := ErrorHandler;
  ExceptProc     := @ExceptHandler;
  ExceptionClass := TObject;
  ExceptObjProc  := @GetExceptionObject;
end.
