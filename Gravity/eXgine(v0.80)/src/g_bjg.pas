unit g_bjg;

interface

uses
  Windows, sys_main;

  function LoadBJG(const FileName: PChar; var Width, Height, BPP: Integer; var Data: PByteArray): Boolean;
  function LoadBJGmem(mem: Pointer; Size: Integer; var Width, Height, BPP: Integer; var Data: PByteArray): Boolean;

implementation

const
  IID_IPicture : TGUID = '{7BF80980-BF32-101A-8BBB-00AA00300CAB}';

type
  OLE_HANDLE = LongWord;
  OLE_XPOS_HIMETRIC  = Longint;
  OLE_YPOS_HIMETRIC  = Longint;
  OLE_XSIZE_HIMETRIC = Longint;
  OLE_YSIZE_HIMETRIC = Longint;

  PCLSID = PGUID;
  TCLSID = TGUID;

  TOleChar = WideChar;
  POleStr  = PWideChar;
  PPOleStr = ^POleStr;
  Largeint = Int64;

  TVarData = packed record
    VType     : Word;
    Reserved1 : Word;
    Reserved2 : Word;
    Reserved3 : Word;
    varOleStr : PWideChar;
    Reserved4 : Word;
    Reserved5 : Word;
  end;

  PStatStg = ^TStatStg;
  tagSTATSTG = record
    pwcsName: POleStr;
    dwType: Longint;
    cbSize: Largeint;
    mtime: TFileTime;
    ctime: TFileTime;
    atime: TFileTime;
    grfMode: Longint;
    grfLocksSupported: Longint;
    clsid: TCLSID;
    grfStateBits: Longint;
    reserved: Longint;
  end;
  TStatStg = tagSTATSTG;
  {$EXTERNALSYM STATSTG}
  STATSTG = TStatStg;

  ISequentialStream = interface(IUnknown)
    ['{0c733a30-2a1c-11ce-ade5-00aa0044773d}']
    function Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HResult;
      stdcall;
    function Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HResult;
      stdcall;
  end;

  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}']
    function Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HResult; stdcall;
    function SetSize(libNewSize: Largeint): HResult; stdcall;
    function CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
      out cbWritten: Largeint): HResult; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
      stdcall;
    function Clone(out stm: IStream): HResult; stdcall;
  end;

  IPicture = interface
    ['{7BF80980-BF32-101A-8BBB-00AA00300CAB}']
    function get_Handle(out handle: OLE_HANDLE): HResult;  stdcall;
    function get_hPal(out handle: OLE_HANDLE): HResult; stdcall;
    function get_Type(out typ: Smallint): HResult; stdcall;
    function get_Width(out width: OLE_XSIZE_HIMETRIC): HResult; stdcall;
    function get_Height(out height: OLE_YSIZE_HIMETRIC): HResult; stdcall;
    function Render(dc: HDC; x, y, cx, cy: Longint;
      xSrc: OLE_XPOS_HIMETRIC; ySrc: OLE_YPOS_HIMETRIC;
      cxSrc: OLE_XSIZE_HIMETRIC; cySrc: OLE_YSIZE_HIMETRIC;
      rcWBounds: Pointer): HResult; stdcall;
    function set_hPal(hpal: OLE_HANDLE): HResult; stdcall;
    function get_CurDC(out dcOut: HDC): HResult; stdcall;
    function SelectPicture(dcIn: HDC; out hdcOut: HDC;
      out bmpOut: OLE_HANDLE): HResult; stdcall;
    function get_KeepOriginalFormat(out fkeep: BOOL): HResult; stdcall;
    function put_KeepOriginalFormat(fkeep: BOOL): HResult; stdcall;
    function PictureChanged: HResult; stdcall;
    function SaveAsFile(const stream: IStream; fSaveMemCopy: BOOL;
      out cbSize: Longint): HResult; stdcall;
    function get_Attributes(out dwAttr: Longint): HResult; stdcall;
  end;

  function OleLoadPictureFile(varFileName: TVarData; var lpdispPicture:
                                 IDispatch): HResult; stdcall; external 'oleaut32.dll';
  function OleLoadPicture(stream: IStream; lSize: Longint; fRunmode: BOOL;
                                 const iid: TGUID; out vObject): HResult; stdcall; external 'olepro32.dll';
  function CreateStreamOnHGlobal(hglob: HGlobal; fDeleteOnRelease: BOOL;
                                 out stm: IStream): HResult; stdcall; external 'ole32.dll';
                                 
// Основная функция модуля, создание изображение по OLE интерфейсу
procedure CreateBitmap(pPicture: IPicture; var Width, Height, BPP: Integer; var Data: PByteArray);
var
  bi   : BITMAPINFO;
  bmp  : HBITMAP;
  DC   : HDC;
  p    : Pointer;
  w, h : Integer;
begin
// считываем данные изображения
  DC := CreateCompatibleDC(GetDC(0));
  pPicture.get_Width(W);
  pPicture.get_Height(H);
  Width  := MulDiv(W, GetDeviceCaps(DC, LOGPIXELSX), 2540);
  Height := MulDiv(H, GetDeviceCaps(DC, LOGPIXELSY), 2540);
  BPP    := 24;
  ZeroMemory(@bi, SizeOf(bi));
  bi.bmiHeader.biSize        := SizeOf(BITMAPINFOHEADER);
  bi.bmiHeader.biBitCount    := 24;
  bi.bmiHeader.biWidth       := Width;
  bi.bmiHeader.biHeight      := Height;
  bi.bmiHeader.biCompression := BI_RGB;
  bi.bmiHeader.biPlanes      := 1;
  bmp := CreateDIBSection(DC, bi, DIB_RGB_COLORS, p, 0, 0);
  SelectObject(DC, bmp);
  pPicture.Render(DC, 0, 0, Width, Height, 0, H, W, -H, nil);
  GetMem(Data, Width * Height * 3);
  GetBitmapBits(bmp, Width * Height * 3, Data);
  DeleteObject(bmp);
  DeleteDC(DC);
end;

// Загрузка из файла
function LoadBJG(const FileName: PChar; var Width, Height, BPP: Integer; var Data: PByteArray): Boolean;
var
  v         : TVarData;
  pPicture  : IPicture;
  pDispatch : IDispatch;
begin
// Инициализация и получение процедуры загрузки изображения из "oleaut32.dll"
  Result := False;
  try
  // Загружаем графический файл
    ZeroMemory(@v, SizeOf(v));
    v.VType     := varOleStr;
    v.varOleStr := StringToOleStr(FileName);
    if OleLoadPictureFile(v, pDispatch) = 0 then
    begin
    // Получение HBITMAP
      pDispatch.QueryInterface(IID_IPicture, pPicture);
      CreateBitmap(pPicture, Width, Height, BPP, Data);
      Result := True;
    end;
  except
  end;
end;      

// Загрузка из памяти
function LoadBJGmem(mem: Pointer; Size: Integer; var Width, Height, BPP: Integer; var Data: PByteArray): Boolean;
var
  m        : Pointer;
  g        : HGLOBAL;
  Stream   : IStream;
  pPicture : IPicture;
begin
// Инициализация и получение процедуры загрузки изображения из "oleaut32.dll"
  Result := False;
  g := 0;
  try
  // Другого способа получения HGlobal по указателю не нашёл
  // пришлось выделять память, копировать туда Mem и грузить через OLE... %)
    g := GlobalAlloc(GMEM_FIXED, Size);
    m := GlobalLock(g);
    Move(mem^, m^, Size);
    GlobalUnlock(g);
  // Загружаем графический файл
    if (CreateStreamOnHGlobal(Cardinal(m), False, Stream) = 0) and
       (OleLoadPicture(Stream, 0, False, IID_IPicture, pPicture) = 0) then
    begin
      CreateBitmap(pPicture, Width, Height, BPP, Data);
      Result := True;
    end;
  finally
    if g <> 0 then
      GlobalFree(g);  
  end;
end;

end.
