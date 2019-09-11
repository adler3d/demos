unit vbo;

interface
{$I cfg.pas}
uses
  OpenGL, sys_main, eXgine;

const
  DT_MAX = 5;

type
  PVector = ^TVector3f;
  PVector2D = ^TVector2f;

  TWordArray = array [0..1] of Word;
  PWordArray = ^TWordArray;

  TLongWordArray = array [0..1] of LongWord;
  PLongWordArray = ^TLongWordArray;

  TVectorArray = array [0..1] of TVector3f;
  PVectorArray = ^TVectorArray;

  TVector2DArray = array [0..1] of TVector2f;
  PVector2DArray = ^TVector2DArray;

  TVBOdata = record
    Count : LongWord;
    Data  : Pointer;
  end;

  PVBOunit = ^TVBOunit;
  TVBOunit = record
    Ready    : Boolean;
    Name     : string;
    pData    : array [0..DT_MAX] of array of TVBOdata;
    use      : array [0..DT_MAX] of Boolean;
    Enabled  : array [0..DT_MAX] of Boolean;
  // информация о буфере VBO
    I_Fmt    : LongWord;
    V_Fmt    : LongWord;
    I_Buf    : LongWord;
    V_Buf    : LongWord;
  // размеры компонент
    I_Size   : LongWord;
    V_Size   : LongWord;
  // количество
    I_Count  : LongWord;
    V_Count  : LongWord;
  // данные
    I_Data   : Pointer;
    V_Data   : Pointer;
  // другое
    Base     : array [0..DT_MAX] of LongWord; // базовые смещения (указатели)
    Offset   : array [0..DT_MAX] of LongWord; // смещение относительно базового
  end;

  TVBO = class(TInterface, IVBuffer)
    constructor CreateEx;
    destructor Destroy; override;
   public
    procedure Clear;
    procedure Add(DataType: LongWord; Count: LongWord; Data: Pointer);
    function  Compile: TVBOid;
    procedure Free(ID: TVBOid);
    procedure Offset(ID: TVBOid; DataType: LongWord; Offset: LongWord);
    procedure Render(ID: TVBOid; mode: LongWord; Count: Integer);
    procedure Enable(ID: TVBOid; DataType: LongWord);
    procedure Disable(ID: TVBOid; DataType: LongWord);
    procedure Update_Begin(ID: TVBOid);
    procedure Update_End;
   private
    UpdID   : TVBOid;
    I_UPtr  : Pointer;
    V_UPtr  : Pointer;
    CurID   : TVBOid;
    VBOunit : array of PVBOunit;
    procedure log(const Text: string);
    function Valid(ID: TVBOid): Boolean;
    function NewID: TVBOid;
  end;

implementation

uses
  eng, ogl;

const
  DataSize : array [0..DT_MAX] of LongWord =
    (SizeOf(LongWord),    // VBO_INDEX
     SizeOf(TVector3f),     // VBO_VERTEX
     SizeOf(TVector3f),     // VBO_NORMAL
     SizeOf(TRGBA),       // VBO_COLOR
     SizeOf(TVector2f),   // VBO_TEXCOORD (1)
     SizeOf(TVector2f));  // VBO_TEXCOORD (2)

constructor TVBO.CreateEx;
begin
  UpdID := -1;
end;
     
destructor TVBO.Destroy;
var
  i : Integer;
begin
  for i := 0 to Length(VBOunit) - 1 do
    Free(i);
  VBOunit := nil;
  inherited;
end;

procedure TVBO.Clear;
var
  i, j : Integer;
begin
  if not Valid(CurID) then
    Exit;
  with VBOunit[CurID]^ do
    for i := 0 to DT_MAX do
      for j := 0 to Length(pData[i]) - 1 do
      begin
        if pData[i][j].Data <> nil then
        try
          FreeMem(pData[i][j].Data);
        except
          log('Error while clear buffer');
        end;
        pData[i] := nil;
      end;
    log('clear');
  FillChar(VBOunit[CurID], SizeOf(TVBOunit), 0);
end;

procedure TVBO.Add(DataType: LongWord; Count: LongWord; Data: Pointer);
var
  i : Integer;
  p : Pointer;
begin
  if (Count = 0) or (Data = nil) then
    Exit;

  if UpdID = -1 then
  begin
    if not Valid(CurID) then
      CurID := NewID;
    if DataType in [0..DT_MAX] then
      with VBOunit[CurID]^ do
      begin
        SetLength(pData[DataType], Length(pData[DataType]) + 1);
        pData[DataType][High(pData[DataType])].Count := Count;
        try
          GetMem(pData[DataType][High(pData[DataType])].Data, Count * DataSize[DataType]);
          Move(Data^, pData[DataType][High(pData[DataType])].Data^, Count * DataSize[DataType]);
          use[DataType] := True;
        except
          SetLength(pData[DataType], High(pData[DataType]));
          log('Error while writing data (' + IntToStr(DataType) + ')');
        end;
      end;
  end else // Обновление содержимого в буфере
    with VBOunit[UpdID]^ do
      if DataType = VBO_INDEX then
      begin
        if I_UPtr = nil then
          if GL_ARB_vertex_buffer_object then
          begin
            glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, I_Buf);
            I_UPtr := glMapBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, GL_WRITE_ONLY_ARB);
            if I_UPtr = nil then
            begin
              log('Can''t map index buffer #' + IntToStr(UpdID));
              Exit;
            end;
          end else
            I_UPtr := nil; // Pointer(Base[...]) = V_Data[...]
        p := Pointer(Base[DataType] + Offset[DataType] * I_Size + LongWord(I_UPtr));
        if I_Size = SizeOf(LongWord) then
          Move(Data^, p^, Count * DataSize[DataType])
        else
          if I_Size = SizeOf(Word) then
            for i := 0 to Count - 1 do
              PWordArray(p)[i] := PLongWordArray(Data)[i]
          else
            for i := 0 to Count - 1 do
              PByteArray(p)[i] := PLongWordArray(Data)[i];
        inc(Offset[DataType], Count);
      end else
      begin
        if V_UPtr = nil then
          if GL_ARB_vertex_buffer_object then
          begin
            glBindBufferARB(GL_ARRAY_BUFFER_ARB, V_Buf);
            V_UPtr := glMapBufferARB(GL_ARRAY_BUFFER_ARB, GL_WRITE_ONLY_ARB);
            if V_UPtr = nil then
            begin
              log('Can''t map vertex buffer #' + IntToStr(UpdID));
              Exit;
            end;
          end else
            V_UPtr := nil; // Pointer(Base[...]) = V_Data[...]
        Move(Data^, Pointer(Base[DataType] + Offset[DataType] * DataSize[DataType] + LongWord(V_UPtr))^, Count * DataSize[DataType]);
        inc(Offset[DataType], Count);
      end;
end;

function TVBO.Compile: TVBOid;
var
  i, j  : LongWord;
  max_i : LongWord;
  str   : String;
  Data  : array [0..DT_MAX] of TVBOdata;
begin
  Result := -1;
  if UpdID > -1 then // идёт обновление буфера
  begin
    log('end updating before compile new buffer');
    Exit;
  end;

  if not Valid(CurID) then
  begin
    log('VBOid is not created');
    Exit;
  end;

  FillChar(Data, SizeOf(Data), 0);
  with VBOunit[CurID]^ do
  begin
    for i := 0 to DT_MAX do
      if use[i] then
        with Data[i] do
        begin
          Enabled[i] := True;
        // вычисление размера буфера
          for j := 0 to Length(pData[i]) - 1 do
            inc(Count, pData[i][j].Count);
        // собираем итоговый массив
          GetMem(Data, Count * DataSize[i]);
          Count := 0;
          for j := 0 to Length(pData[i]) - 1 do
          begin
            Move(pData[i][j].Data^, PByteArray(Data)[Count * DataSize[i]], pData[i][j].Count * DataSize[i]);
            inc(Count, pData[i][j].Count);
            FreeMem(pData[i][j].Data);
          end;
          pData[i] := nil;
         end;

    I_Count := Data[VBO_INDEX].Count;
    V_Count := Data[VBO_VERTEX].Count;
  // индексы вершин и их координаты должны быть обязательно
    if Data[VBO_VERTEX].Data = nil then
    begin
      log('Not has vertex arrays');
      Exit;
    end;

    if use[VBO_INDEX] then
    begin
    // вычисление максимального индекса
      max_i := 0;
      for i := 0 to I_Count - 1 do
        if PLongWordArray(Data[VBO_INDEX].Data)[i] > max_i then
          max_i := PLongWordArray(Data[VBO_INDEX].Data)[i];

    // расчёт размера и формата индекса
      if max_i <= High(Byte) then
      begin
        I_Fmt  := GL_UNSIGNED_BYTE;
        I_Size := SizeOf(Byte);
      end else
        if max_i <= High(Word) then
        begin
          I_Fmt  := GL_UNSIGNED_SHORT;
          I_Size := SizeOf(Word);
        end else
        begin
          I_Fmt  := GL_UNSIGNED_INT;
          I_Size := SizeOf(LongWord);
        end;
    end;
  // вычисление размера вершины в буфере
    V_Size := 0;
    for i := VBO_VERTEX to DT_MAX do
      if Data[i].Data <> nil then
        V_Size := V_Size + DataSize[i];
  // сборка массивов
    try
      if use[VBO_INDEX] then
      begin
        GetMem(I_Data, I_Count * I_Size);
      // индексы
        if I_Size = SizeOf(LongWord) then
          Move(Data[VBO_INDEX].Data^, I_Data^, I_Count * I_Size)
        else
          if I_Size = SizeOf(Word) then
            for i := 0 to I_Count - 1 do
              PWordArray(I_Data)[i] := PLongWordArray(Data[VBO_INDEX].Data)[i]
          else
            for i := 0 to I_Count - 1 do
              PByteArray(I_Data)[i] := PLongWordArray(Data[VBO_INDEX].Data)[i];
        FreeMem(Data[VBO_INDEX].Data);
      end;
    // вершины/нормали/цвета/текстурные координаты
      GetMem(V_Data, V_Count * V_Size);
      V_Size := 0;
      for i := VBO_VERTEX to DT_MAX do
        if Data[i].Data <> nil then
        begin
          Base[i] := LongWord(V_Data) + V_Count * V_Size;
          Move(Data[i].Data^, Pointer(Base[i])^, V_Count * DataSize[i]);
          V_Size := V_Size + DataSize[i];
          FreeMem(Data[i].Data);
        end;
    except
      if I_Data <> nil then FreeMem(I_Data);
      FreeMem(V_Data);
      I_Data := nil;
      V_Data := nil;
      log('Error while compiling'); // ЖЕСТЬ!
      Exit;
    end;
  // если есть поддерка VBO - создаём буфер и передаём него данные
    if GL_ARB_vertex_buffer_object then
    begin
      if use[VBO_INDEX] then
      begin
      // массив индексов
        glGenBuffersARB(1, @I_Buf);
        glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, I_Buf);
        glBufferDataARB(GL_ELEMENT_ARRAY_BUFFER_ARB, I_Count * I_Size, I_Data, GL_STATIC_DRAW_ARB);
        glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, 0);
      end;
    // вершинный массив
      glGenBuffersARB(1, @V_Buf);
      glBindBufferARB(GL_ARRAY_BUFFER_ARB, V_Buf);
      glBufferDataARB(GL_ARRAY_BUFFER_ARB, V_Count * V_Size, V_Data, GL_STATIC_DRAW_ARB);
      glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
    // вычисление базовых смещений отоносительно VBO буфера
      for i := VBO_VERTEX to DT_MAX do
        Base[i] := Base[i] - LongWord(V_Data);
    // т.к. массивы скопированы в видеопамять...
      if I_Data <> nil then FreeMem(I_Data);
      FreeMem(V_Data);
      I_Data := nil;
      V_Data := nil;
    end;
    Base[VBO_INDEX] := LongWord(I_Data);

    Result := CurID;
    CurID  := -1;
    Ready  := True;
    str := '';
    for i := 0 to DT_MAX do
      if use[i] then
        str := str + ' ' + IntToStr(i) + ': ' + IntToStr(Data[i].Count); 
    log('Compile #' + IntToStr(Result) + #9 + '(' + str + ' )');
  end;
end;

procedure TVBO.Free(ID: TVBOid);
begin
  if Valid(ID) and VBOunit[ID].Ready then
    with VBOunit[ID]^ do
    begin
      if UpdID = ID then
        Update_End;
      if GL_ARB_vertex_buffer_object then
      begin
        if I_Buf <> 0 then glDeleteBuffersARB(1, @I_Buf);
        if V_Buf <> 0 then glDeleteBuffersARB(1, @V_Buf);
      end;
      if I_Data <> nil then FreeMem(I_Data);
      if V_Data <> nil then FreeMem(V_Data);

      Dispose(VBOunit[ID]);
      VBOunit[ID] := nil;
      log('Free #' + IntToStr(ID));
    end;
end;

procedure TVBO.Offset(ID: TVBOid; DataType: LongWord; Offset: LongWord);
begin
  if Valid(ID) and VBOunit[ID].Ready then
    if DataType in [0..DT_MAX] then
      VBOunit[ID].Offset[DataType] := Offset;
end;

procedure TVBO.Render(ID: TVBOid; mode: LongWord; Count: Integer);
begin
  if UpdID > -1 then Exit; // идёт обновление буфера
  
  if Valid(ID) and VBOunit[ID].Ready then
    with VBOunit[ID]^ do
    begin
      if use[VBO_INDEX] then
      begin
        if Count = 0 then
          Count := I_Count - Offset[VBO_INDEX];
      end else
        if Count = 0 then
          Count := V_Count - Offset[VBO_VERTEX];

      if GL_ARB_vertex_buffer_object then
      begin
        glBindBufferARB(GL_ARRAY_BUFFER_ARB, V_Buf);
        glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, I_Buf);
      end;

    // normal
      if use[VBO_NORMAL] and Enabled[VBO_NORMAL] then
      begin
        glEnableClientState(GL_NORMAL_ARRAY);
        glNormalPointer(GL_FLOAT, 0, Pointer(Base[VBO_NORMAL] + Offset[VBO_NORMAL] * DataSize[VBO_NORMAL]));
      end;
    // color
      if use[VBO_COLOR] and Enabled[VBO_COLOR] then
      begin
        glEnableClientState(GL_COLOR_ARRAY);
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, Pointer(Base[VBO_COLOR] + Offset[VBO_COLOR] * DataSize[VBO_COLOR]));
      end;

    // texcoord 1
      if use[VBO_TEXCOORD1] and Enabled[VBO_TEXCOORD1] then
      begin
        glClientActiveTextureARB(GL_TEXTURE0_ARB);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2, GL_FLOAT, 0, Pointer(Base[VBO_TEXCOORD1] + Offset[VBO_TEXCOORD] * DataSize[VBO_TEXCOORD1]));
      end;
    // texcoord 2
      if use[VBO_TEXCOORD2] and Enabled[VBO_TEXCOORD2] then
      begin
        glClientActiveTextureARB(GL_TEXTURE1_ARB);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glTexCoordPointer(2, GL_FLOAT, 0, Pointer(Base[VBO_TEXCOORD2] + Offset[VBO_TEXCOORD2] * DataSize[VBO_TEXCOORD2]));
      end;

      glEnableClientState(GL_VERTEX_ARRAY);
      glVertexPointer(3, GL_FLOAT, 0, Pointer(Base[VBO_VERTEX] + Offset[VBO_VERTEX] * DataSize[VBO_VERTEX]));

      try
        if use[VBO_INDEX] then
          glDrawElements(mode, Count, I_Fmt, Pointer(Base[VBO_INDEX] + Offset[VBO_INDEX] * I_Size))
        else
          glDrawArrays(mode, 0, Count);
      except
        log('Access Violation on Render (' + IntToStr(ID) + ')'); // просто ЖЕСТЬ!
      end;

      glDisableClientState(GL_VERTEX_ARRAY);

      if use[VBO_TEXCOORD2] and Enabled[VBO_TEXCOORD2] then
      begin
        glClientActiveTextureARB(GL_TEXTURE1_ARB);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      end;
      if use[VBO_TEXCOORD1] and Enabled[VBO_TEXCOORD1] then
      begin
        glClientActiveTextureARB(GL_TEXTURE0_ARB);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      end;
      if use[VBO_COLOR] and Enabled[VBO_COLOR] then glDisableClientState(GL_COLOR_ARRAY);
      if use[VBO_NORMAL] and Enabled[VBO_NORMAL] then glDisableClientState(GL_NORMAL_ARRAY);

      if GL_ARB_vertex_buffer_object then
      begin
        if use[VBO_INDEX] and Enabled[VBO_INDEX] then glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, 0);
        glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
      end;
    end;
end;

procedure TVBO.Enable(ID: TVBOid; DataType: LongWord);
begin
  if Valid(ID) then
    with VBOunit[ID]^ do
      if Ready then
        Enabled[DataType] := True;
end;

procedure TVBO.Disable(ID: TVBOid; DataType: LongWord);
begin
  if Valid(ID) then
    with VBOunit[ID]^ do
      if Ready then
        Enabled[DataType] := False;
end;

procedure TVBO.Update_Begin(ID: TVBOid);
begin
  if Valid(ID) then
    with VBOunit[ID]^ do
      if Ready then
      begin
        FillChar(Offset, SizeOf(Offset), 0); // обнуляем сдвиг относительно начала массивов
        UpdID := ID;
      end;
end;

procedure TVBO.Update_End;
begin
  if Valid(UpdID) then
    with VBOunit[UpdID]^ do
      if Ready then
      begin
      // UnMap Index Array
        if I_UPtr <> nil then
        begin
           glUnmapBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB);
           glBindBufferARB(GL_ELEMENT_ARRAY_BUFFER_ARB, 0);
           I_UPtr := nil;
        end;
      // UnMap Vertex Array
        if V_UPtr <> nil then
        begin
           glUnmapBufferARB(GL_ARRAY_BUFFER_ARB);
           glBindBufferARB(GL_ARRAY_BUFFER_ARB, 0);
           V_UPtr := nil;
        end;
        FillChar(Offset, SizeOf(Offset), 0); // обнуляем сдвиг относительно начала массивов
        UpdID := -1;
      end;
end;

procedure TVBO.log(const Text: string);
begin
  olog.Print(PChar('VBuffer : ' + Text));
end;

function TVBO.Valid(ID: TVBOid): Boolean;
begin
  Result := (ID >= 0) and (ID < Length(VBOunit)) and (VBOunit[ID] <> nil);
end;

function TVBO.NewID: TVBOid;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to Length(VBOunit) - 1 do
    if VBOunit[i] = nil then
    begin
      Result := i;
      break;
    end;
  if Result = -1 then
  begin
    SetLength(VBOunit, Length(VBOunit) + 1);
    Result := Length(VBOunit) - 1;
  end;
  New(VBOunit[Result]);
  FillChar(VBOunit[Result]^, SizeOf(TVBOunit), 0);
end;

end.

