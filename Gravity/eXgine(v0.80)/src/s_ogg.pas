{==============================}
{= Ogg Vorbis player class    =}
{= with DirectSound output... =}
{==============================}
{= by XProger                 =}
{= mail: XProger@list.ru      =}
{= http://xproger.mirgames.ru =}
{==============================}
unit s_ogg;

interface

uses
  Windows, sys_main, snd;

const
  OGG_BUFFER_SIZE = 64 * 1024;
  OGG_FILL_TIME   = 100;

type
  TOGG = class
    constructor Create(Stream: TStream);
    destructor Destroy; override;
   private
    FReady   : Boolean;
    FLoop    : Boolean;
    FDone    : Boolean;
    FAllDone : Boolean;
    FStream  : TStream;
    OggFile  : Pointer;
    Buffer   : IDirectSoundBuffer;
    Thread   : LongWord;
    LastPos  : LongWord;
    function GetVolume: Integer;
    procedure SetVolume(Value: Integer);
    procedure Update;
   public
    procedure Play(Loop: Boolean);
    procedure Pause;
    procedure Stop;
    function Playing: Boolean;
    property Ready: Boolean read FReady;
    property Volume: Integer read GetVolume write SetVolume;
  end;

  function OggInit: Boolean;
  
var
  OggMusic    : TOGG;
implementation

uses
  eng;

//=====> OGG VORBIS TYPES HEADER <=====//
type
  p_vorbis_info = ^vorbis_info;
  vorbis_info = record
    version         : Integer;
    channels        : Integer;
    rate            : Integer;
    bitrate_upper   : Integer;
    bitrate_nominal : Integer;
    bitrate_lower   : Integer;
    bitrate_window  : Integer;
    codec_setup     : Pointer;
  end;

  OggVorbis_File = record
    some_data1 : array [0..17] of Integer;
    vi         : p_vorbis_info;
    some_data2 : array [0..160] of Integer;
  end;

  ov_callbacks = record
    read_func  : function(var Ptr; Size: LongWord; Mmemb: LongWord; const Stream): LongWord; cdecl;
    seek_func  : function(const Stream; Offset: Int64; Whence: Integer): Integer; cdecl;
    close_func : function(const Stream): Integer; cdecl;
    tell_func  : function(const Stream): Integer; cdecl;
  end;

var
  ops_callbacks : ov_callbacks;

  ov_clear          : function (oggFile: Pointer): Integer; cdecl;
  ov_open_callbacks : function (const Stream; oggFile: Pointer; Initial: PChar; ibytes: Integer; callbacks: ov_callbacks): Integer; cdecl;
  ov_pcm_seek       : function (oggFile: Pointer; pos: Int64): Integer; cdecl;
  ov_read           : function (oggFile: Pointer; const Buf; Len: Integer; Bigendianp: Integer; word: Integer; Sgned: Integer; BitStream: Pointer): Integer; cdecl;
//=====================================//

function ops_read_func(var Ptr; Size, Mmemb: LongWord; const Stream): LongWord; cdecl;
begin
  if (Size = 0) or (Mmemb = 0) then
  begin
    Result := 0;
    Exit;
  end;

  try
    Result := Int64(TStream(Stream).Read(Ptr, Size * Mmemb));
  except
    Result := 0;
  end;
end;

function ops_seek_func(const Stream; Offset: Int64; Whence: Integer): Integer; cdecl;
begin
  try
    with TStream(Stream) do
      case Whence of
        0: Seek(Offset);
        1: Seek(Pos + Offset);
        2: Seek(Size - Offset);
      end;
    Result := 0;
  except
    Result := -1;
  end;
end;

function ops_close_func(const Stream): Integer; cdecl;
begin
  Result := 0;
end;

function ops_tell_func(const Stream): Integer; cdecl;
begin
  try
    Result := TStream(Stream).Pos;
  except
    Result := -1;
  end;
end;

var
  DSready : Boolean;

function OggInit: Boolean;
begin
  if not DSReady then
    if (osnd.snd_ready) and
       (@ov_clear <> nil) and (@ov_open_callbacks <> nil) and
       (@ov_pcm_seek <> nil) and (@ov_read <> nil) then
      DSReady := True;
  Result := DSReady;
end;

function OggThreadProc(OGG: TOGG): Integer; stdcall;
begin
  Result := 0;
  try
    OGG.Buffer.Play(0, 0, DSBPLAY_LOOPING);
   	while (OGG.Buffer <> nil) and OGG.Playing do
	  begin
      OGG.Update;
      Sleep(OGG_FILL_TIME);
    end;
  except
    // :)
  end;
end;

//===== OGG Vorbis =====>
constructor TOGG.Create(Stream: TStream);
var
  BufferDesc : TDSBufferDesc;
  Format     : packed record
                 wFormatTag      : Word;
                 nChannels       : Word;
                 nSamplesPerSec  : LongWord;
                 nAvgBytesPerSec : LongWord;
                 nBlockAlign     : Word;
                 wBitsPerSample  : Word;
                 cbSize          : Word;
               end;
label
  ext;
begin
  FStream := Stream;
  GetMem(OggFile, SizeOf(OggVorbis_File));
  if (not DSReady) or (not FStream.Valid) then
    goto ext;
    
// reading hearer
  if ov_open_callbacks(FStream, OggFile, nil, 0, ops_callbacks) < 0 then
    goto ext;

// fill DSound PCM format structures
  with Format do
  begin
    wFormatTag      := 1;
    nChannels       := OggVorbis_File(OggFile^).vi^.channels;
    nSamplesPerSec  := OggVorbis_File(OggFile^).vi^.rate;
    wBitsPerSample  := 16;
    nBlockAlign     := (wBitsPerSample div 8) * nChannels;
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize          := SizeOf(Format);
  end;

// DSound buffer description
  ZeroMemory(@BufferDesc, SizeOf(BufferDesc));
  with BufferDesc do
  begin
    dwSize        := SizeOf(BufferDesc);
    dwFlags       := DSBCAPS_GETCURRENTPOSITION2 or
                     DSBCAPS_CTRLFREQUENCY or
                     DSBCAPS_CTRLVOLUME;
    dwBufferBytes := OGG_BUFFER_SIZE;
    lpwfxFormat   := @Format.wFormatTag;
  end;

// Create DirectSound buffer
  if DSMain.CreateSoundBuffer(BufferDesc, Buffer, nil) <> DS_OK then
    goto ext;

  Volume := 100;
  FReady := True;
  Exit;
ext:
  FStream.Free;
  FreeMem(OggFile);
end;

destructor TOGG.Destroy;
begin
  if not Ready then Exit;
  Stop;
  if Buffer <> nil then
    Buffer := nil;
  FStream.Free;
  ov_clear(OggFile);
  FreeMem(OggFile);
  inherited;
end;

function TOGG.GetVolume: Integer;
begin
  Result := 0;
  if not Ready then Exit;
  Buffer.GetVolume(Result);
  Result := Trunc(100 * exp(ln(10) * (Result / 33.22 / 100)));
end;

procedure TOGG.SetVolume(Value: Integer);
var
  db : Integer;
begin
  if not Ready then Exit;
  if Value > 100 then Value := 100;
  if Value < 0   then Value := 0;
  if Value = 0 then
    db := DSBVOLUME_MIN
  else
    db := Trunc(33.22 * 100 * ln(Value/100)/ln(10));
  Buffer.SetVolume(db);
end;

procedure TOGG.Update;
var
  Status    : LongWord;
  Pos, Size : LongWord;
  p   : array [0..1] of Pointer;
  s   : array [0..1] of LongWord;
  Ret : LongWord;
  i   : Integer;
begin
  Buffer.GetStatus(Status);
  if Status and DSBSTATUS_BUFFERLOST <> 0 then
    if Buffer.Restore = 0 then
      Exit;

  Buffer.GetCurrentPosition(Pos, nil);
  if Pos > LastPos then
    Size := Pos - LastPos
  else
    if Pos < LastPos then
      Size := Integer(OGG_BUFFER_SIZE - LastPos + Pos)
    else
      Exit;

  Buffer.Lock(LastPos, Size, p[0], s[0], p[1], s[1], 0);
  LastPos := Pos;
  for i := 0 to 1 do
    if s[i] <> 0 then
    begin
      Pos := 0;
      repeat
        Ret := ov_read(oggFile, Pointer(LongWord(p[i]) + Pos)^, s[i] - Pos, 0, 2, 1, nil);
        Pos := Pos + Ret;
      until (Ret = 0) or (Pos = s[i]);

      if Ret = 0 then
        if not FLoop then
        begin
          FillChar(Pointer(LongWord(p[i]) + Pos)^, s[i] - Pos, 0);
          FAllDone := True;
        end else
          ov_pcm_seek(oggFile, 0);
    end;
  Buffer.Unlock(p[0], s[0], p[1], s[1]);
end;

procedure TOGG.Play(Loop: Boolean);
var
  ThreadID : LongWord;
begin
  if not Ready then Exit;
  if Playing then Stop;
  if FDone then
  begin
    FDone    := False;
    FAllDone := False;
    ov_pcm_seek(oggFile, 0);
  end;
  FLoop   := Loop;

// First fill
  Buffer.SetCurrentPosition(OGG_BUFFER_SIZE);
  LastPos := 0;
  Update;
  Buffer.SetCurrentPosition(0);

  Thread  := CreateThread(nil, 0, @OggThreadProc, Self, 0, ThreadID);
end;

procedure TOGG.Pause;
begin
  if not Ready then Exit;
  Buffer.Stop;
end;

procedure TOGG.Stop;
begin
  if not Ready then Exit;
  TerminateThread(Thread, 0);
  CloseHandle(Thread);
  Buffer.Stop;
  Buffer.SetCurrentPosition(0);
  FDone    := True;
  FAllDone := True;
end;

function TOGG.Playing: Boolean;
var
  Status : LongWord;
begin
  Result := False;
  if not Ready then Exit;
  if Buffer <> nil then
    Buffer.GetStatus(Status);
  Result := Status and DSBSTATUS_PLAYING <> 0;
end;

const
  OggLib        = 'ogg.dll';
  VorbisLib     = 'vorbis.dll';
  VorbisFileLib = 'vorbisfile.dll';
var
  VorbisFileDll : HMODULE;
initialization
// проверка наличия соответствующих dll :)
  if not(FileExists(OggLib) and FileExists(VorbisLib) and FileExists(VorbisFileLib)) then
    Exit;
  VorbisFileDll := LoadLibrary(VorbisFileLib);
  if VorbisFileDll <> 0 then
  begin
    ov_clear          := GetProcAddress(VorbisFileDll, 'ov_clear');
    ov_open_callbacks := GetProcAddress(VorbisFileDll, 'ov_open_callbacks');
    ov_pcm_seek       := GetProcAddress(VorbisFileDll, 'ov_pcm_seek');
    ov_read           := GetProcAddress(VorbisFileDll, 'ov_read');
    ops_callbacks.read_func  := ops_read_func;
    ops_callbacks.seek_func  := ops_seek_func;
    ops_callbacks.close_func := ops_close_func;
    ops_callbacks.tell_func  := ops_tell_func;
  end;
finalization
  FreeLibrary(VorbisFileDll);
end.
