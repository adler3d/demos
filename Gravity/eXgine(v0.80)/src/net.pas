unit net;

interface

uses
  Windows, WinSock,
  sys_main, eXgine;

const
  BUF_SIZE = 1024 * 64;

type
  PPacket = ^TPacket;
  TPacket = record
    Size   : Integer;
    Data   : Pointer;
    From   : sockaddr_in;
    Next   : PPacket;
    Remove : Boolean;
  end;

  PSockObj = ^TSockObj;
  TSockObj = record
    Address : sockaddr_in;
    Socket  : TSocket;
    Thread  : LongWord;
    Buffer  : array [0..BUF_SIZE - 1] of Byte;
    Packets : PPacket;
  end;

  TProtocol = class(TObject, IProtocol)
    destructor Destroy; override;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
   public
    procedure Close(Socket: TSocket);
    procedure Clear;
    function Write(var Buf; Count: Integer): Integer;
   private
    Buffer  : array [0..BUF_SIZE - 1] of Byte;
    BufLen  : Integer;
    SockObj : array of PSockObj;
    function NewSockID: Integer;
    function GetSockID(Socket: TSocket): Integer;
  end;

  TUDP = class(TProtocol, IUDP)
    function Open(Port: Integer): TSocket;
    function Send(Socket: TSocket; IP: TNetIP; Port: Integer): Boolean;
    function Recv(Socket: TSocket): TNetMessage;
   public
    procedure log(const Text: string);
  end;

  TTCP = class(TProtocol, ITCP)
    function Host(Port: Integer): TSocket;
    function Join(IP: PChar; Port: Integer): TSocket;
    function Send(Socket: TSocket): Boolean;
    function Recv(Socket: TSocket; Buf: Pointer; Count: Integer; var IP: PChar; var Port: Integer): Integer;
   public
    procedure log(const Text: string);
  end;

  TNet = class(TInterface, INetwork)
    constructor CreateEx;
    destructor Destroy; override;
   private
    FUDP : TUDP;
    FTCP : TTCP;
   public
    function IP(idx: Integer): PChar;
    function udp: IUDP;
    function tcp: ITCP;
   public
    procedure log(const Text: string);
  end;

implementation

uses
  eng;

procedure ThreadUDP(Sock: PSockObj); stdcall;
var
  i   : Integer;
  p, l   : PPacket;
  buf : array [0..BUF_SIZE - 1] of Byte;
begin
  i := SizeOf(sockaddr_in);
  with Sock^ do
  begin
    New(p);
    FillChar(p^, SizeOf(TPacket), 0);
    Packets := p;
    while True do
    begin
      with p^ do
      begin
        Size := recvfrom(Socket, buf[0], BUF_SIZE, 0, From, i);
        if Size = NET_ERROR then
          break;
        GetMem(Data, Size);
        Move(buf[0], Data^, Size);
      end;
      New(l);
      FillChar(l^, SizeOf(TPacket), 0);
      p^.Next := l;
      p := l;
    end;
  end;
end;

procedure ThreadTCP(Sock: PSockObj); stdcall;
begin
  //
end;

//>>> Base protocol
destructor TProtocol.Destroy;
var
  i : Integer;
begin
  for i := 0 to Length(SockObj) - 1 do
    Close(SockObj[i].Socket);
  inherited;
end;

procedure TProtocol.Close(Socket: TSocket);
var
  i : Integer;
  p : PPacket;
begin
  for i := 0 to Length(SockObj) - 1 do
    if SockObj[i].Socket = Socket then
      with SockObj[i]^ do
      begin
      // мочим поток!
        if Thread <> 0 then
        begin
          TerminateThread(Thread, 0);
          CloseHandle(Thread);
        end;
      // очистка очереди пакетов
        if Packets <> nil then
        begin
          p := Packets;
          while p <> nil do
          begin
            if p^.Data <> nil then
              FreeMem(p^.Data);
            Dispose(Packets);
            p := p^.Next;
            Packets := p;
          end;
        end;
      // удаляем сокет
        Dispose(SockObj[i]);
        SockObj[i] := SockObj[High(SockObj)];
        SetLength(SockObj, High(SockObj));
        closesocket(Socket);
        break;
      end;
end;

procedure TProtocol.Clear;
begin
  BufLen := 0;
end;

function TProtocol.Write(var Buf; Count: Integer): Integer;
begin
  if BufLen + Count >= BUF_SIZE then
    Count := BUF_SIZE - BufLen;
  Move(Buf, Buffer[BufLen], Count);
  BufLen := BufLen + Count;
  Result := Count;
end;

function TProtocol.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := -1;
end;

function TProtocol._AddRef: Integer;
begin
  Result := 0;
end;

function TProtocol._Release: Integer;
begin
  Result := 0;
end;

function TProtocol.NewSockID: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to Length(SockObj) - 1 do
    if SockObj = nil then
    begin
      Result := i;
      break;
    end;
  if Result = 0 then
  begin
    SetLength(SockObj, Length(SockObj) + 1);
    Result := High(SockObj);
    SockObj[Result] := New(PSockObj);
    FillChar(SockObj[Result]^, SizeOf(TSockObj), 0);
  end;
end;

function TProtocol.GetSockID(Socket: TSocket): Integer;
var
  i : Integer;
begin
  Result := NET_ERROR;
  for i := 0 to Length(SockObj) - 1 do
    if SockObj[i]^.Socket = Socket then
    begin
      Result := i;
      break;
    end;
end;

//>>> UDP protocol >>>>>>>>>>>>>>>>>>>>>>>>>>
function TUDP.Open(Port: Integer): TSocket;
var
  i    : Integer;
  Sock : PSockObj;
  TID  : LongWord;
begin
// Create socket
  log('bla');
  Result := socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
  if Result > SOCKET_ERROR then
  begin
    log('bla 2');

    Sock := SockObj[NewSockID];
    with Sock^ do
    begin
      Socket := Result;
    // Setting and Binding socket on port
      Address.sin_addr.S_addr := INADDR_ANY;
      Address.sin_port        := htons(Port);
      Address.sin_family      := AF_INET;
      i := 1;
      if not setsockopt(Socket, SOL_SOCKET, SO_BROADCAST, PChar(@i), SizeOf(i)) = NET_ERROR then
        if not bind(Socket, Address, SizeOf(Address)) = NET_ERROR then
        begin
          log('Socket has been initialized on port (' + IntToStr(Port) + ')');
          Thread := CreateThread(nil, 0, @ThreadUDP, Sock, 0, TID);
          Exit;
        end else
          log('Error binding socket on port')
      else
        log('Error setting broadcast socket');
      Close(Result);
    end;
  end;
  log('Can''t create socket on port (' + IntToStr(Port) + ')');
end;

function TUDP.Send(Socket: TSocket; IP: TNetIP; Port: Integer): Boolean;
var
  DstAddr : sockaddr_in;
begin
  FillChar(DstAddr.sin_zero, SizeOf(DstAddr.sin_zero), 0);
  DstAddr.sin_addr.S_addr := INADDR_ANY;
  DstAddr.sin_port        := htons(Port);
  DstAddr.sin_family      := AF_INET;
  DstAddr.sin_addr.S_addr := LongWord(IP);
  Result := sendto(Socket, Buffer[0], BufLen, 0, DstAddr, SizeOf(DstAddr)) > 0;
  if not Result then
    log('Error sending');
end;

function TUDP.Recv(Socket: TSocket): TNetMessage;
var
  id : Integer;
  p  : PPacket;
begin
  id := GetSockID(Socket);
  if id <> NET_ERROR then
    with SockObj[id]^ do
      if Packets <> nil then
        if Packets^.Next <> nil then
        begin
        // free old packet
          if Packets^.Remove then
          begin
            p := Packets;
            Packets := Packets^.Next;
            FreeMem(p^.Data);
            Dispose(p);
          end;
        // return new
          with Packets^ do
            if Next <> nil then
            begin
              Remove := True;
              Result.Size := Size;
              Result.Data := Data;
              Result.IP   := LongWord(From.sin_addr);
              Result.Port := ntohs(From.sin_port);
              Exit;
            end;
        end;
  FillChar(Result, SizeOf(Result), 0);
end;

procedure TUDP.log(const Text: string);
begin
  olog.Print(PChar('Network : UDP > ' + Text));
end;

//>>> TCP protocol >>>>>>>>>>>>>>>>>>>>>>>>>>
function TTCP.Host(Port: Integer): TSocket;
begin
  Result := NET_ERROR;
end;

function TTCP.Join(IP: PChar; Port: Integer): TSocket;
begin
  Result := NET_ERROR;
end;

function TTCP.Send(Socket: TSocket): Boolean;
begin
  Result := False;
end;

function TTCP.Recv(Socket: TSocket; Buf: Pointer; Count: Integer; var IP: PChar; var Port: Integer): Integer;
begin
  Result := NET_ERROR;
end;

procedure TTCP.log(const Text: string);
begin
  olog.Print(PChar('Network : TCP > ' + Text));
end;

//>>> Network class >>>>>>>>>>>>>>>>>>>>>>>>>>
constructor TNet.CreateEx;
var
  WSData : WSADATA;
begin
  if WSAStartup($0101, WSData) = 0 then
  begin
    log('Initialized');
    FUDP := TUDP.Create;
    FTCP := TTCP.Create;
    log('Description : ' + WSData.szDescription);
    log('MaxSockets  : ' + IntToStr(WSData.iMaxSockets));
    log('MaxSize UDP : ' + IntToStr(WSdata.iMaxUdpDg));
  end else
    log('not initialized');
end;

destructor TNet.Destroy;
begin
  FUDP.Free;
  FTCP.Free;
  WSACleanup;
end;

function TNet.IP(idx: Integer): PChar;
begin
  Result := nil;
end;

function TNet.udp: IUDP;
begin
  Result := FUDP;
end;

function TNet.tcp: ITCP;
begin
  Result := FTCP;
end;

procedure TNet.log(const Text: string);
begin
  olog.Print(PChar('Network : ' + Text));
end;

end.