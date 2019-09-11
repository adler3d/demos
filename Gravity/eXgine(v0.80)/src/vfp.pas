unit vfp;

interface

uses
  Windows, OpenGL,
  sys_main, eXgine;

type
  TVFP = class(TInterface, IShader)
    destructor Destroy; override;
   public
    procedure Clear;
    function Add(FileName: PChar; Name: PChar): Boolean; overload;
    function Add(Mem: Pointer; Size: Integer; Name: PChar): Boolean; overload;
    function Compile: TShader;
    procedure Free(Shader: TShader);
    function GetAttrib(Shader: TShader; Name: PChar): TShAttrib;
    function GetUniform(Shader: TShader; Name: PChar): TShUniform; 
    procedure Attrib(a: TShAttrib; x: Single); overload; 
    procedure Attrib(a: TShAttrib; x, y: Single); overload; 
    procedure Attrib(a: TShAttrib; x, y, z: Single); overload; 
    procedure Uniform(u: TShUniform; i: Integer); overload;
    procedure Uniform(u: TShUniform; p: Pointer; ShUniType: TShUniType; Count: Integer); overload;
    procedure Enable(Shader: TShader);
    procedure Disable;
   private
    Shader : TShader;
   public
    procedure log(const Text: string);
    function Error(Handle: TShader; Param: DWORD): Boolean;
    function Read(Stream: TStream; Name: PChar): Boolean;
  end;

implementation

uses
  eng, ogl;

destructor TVFP.Destroy;
begin
  Clear;
end;

procedure TVFP.Clear;
begin
  if not GL_ARB_shading_language then Exit;
  glDeleteObjectARB(Shader);
  Shader := 0;
end;

function TVFP.Add(FileName: PChar; Name: PChar): Boolean;
var
  Stream : TFileStream;
begin
  Stream := TFileStream.Create(FileName);
  Result := Read(Stream, Name);
  Stream.Free;
end;

function TVFP.Add(Mem: Pointer; Size: Integer; Name: PChar): Boolean;
var
  Stream : TMemoryStream;
begin
  Stream := TMemoryStream.Create(Mem, Size);
  Result := Read(Stream, Name);
  Stream.Free;
end;

function TVFP.Compile: TShader;
var
  p : PChar;
  wr : Integer;
begin
  Result := 0;
  if not GL_ARB_shading_language then Exit;

  glLinkProgramARB(Shader);
  if not Error(Shader, GL_OBJECT_LINK_STATUS_ARB) then
  begin
    log('Compile #' + IntToStr(Shader));
    Result := Shader;
    Shader := 0;
  end else
  begin
    log('Error while compiling');
    GetMem(p, 1024 * 64);
    glGetInfoLogARB(Shader, 64 * 1024, wr, p);
    log(p);                       
    FreeMem(p);
  end;
end;

procedure TVFP.Free(Shader: TShader);
begin
  if not GL_ARB_shading_language then Exit;
  glDeleteObjectARB(Shader);
  log('Free #' + IntToStr(Shader));
end;

function TVFP.GetAttrib(Shader: TShader; Name: PChar): TShAttrib;
begin
  Result := 0;
  if not GL_ARB_shading_language then Exit;
  Result := glGetAttribLocationARB(Shader, Name);
end;

function TVFP.GetUniform(Shader: TShader; Name: PChar): TShUniform;
begin
  Result := 0;
  if not GL_ARB_shading_language then Exit;
  Result := glGetUniformLocationARB(Shader, Name);
end;

procedure TVFP.Attrib(a: TShAttrib; x: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glVertexAttrib1fARB(a, x);
end;

procedure TVFP.Attrib(a: TShAttrib; x, y: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glVertexAttrib2fARB(a, x, y);
end;

procedure TVFP.Attrib(a: TShAttrib; x, y, z: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glVertexAttrib3fARB(a, x, y, z);
end;

procedure TVFP.Uniform(u: TShUniform; i: Integer);
begin
  if not GL_ARB_shading_language then Exit;
  glUniform1iARB(u, i);
end;

procedure TVFP.Uniform(u: TShUniform; p: Pointer; ShUniType: TShUniType; Count: Integer);
begin
  if not GL_ARB_shading_language then Exit;
  case ShUniType of
    SU_I1 : glUniform1ivARB(u, Count, p);
    SU_I2 : glUniform2ivARB(u, Count, p);
    SU_I3 : glUniform3ivARB(u, Count, p);
    SU_I4 : glUniform4ivARB(u, Count, p);
    SU_F1 : glUniform1fvARB(u, Count, p);
    SU_F2 : glUniform2fvARB(u, Count, p);
    SU_F3 : glUniform3fvARB(u, Count, p);
    SU_F4 : glUniform4fvARB(u, Count, p);
    SU_M2 : glUniformMatrix2fvARB(u, Count, False, p);
    SU_M3 : glUniformMatrix3fvARB(u, Count, False, p);
    SU_M4 : glUniformMatrix4fvARB(u, Count, False, p);
  end;
end;

procedure TVFP.Enable(Shader: TShader);
begin
  if not GL_ARB_shading_language then Exit;
  glUseProgramObjectARB(Shader);
end;

procedure TVFP.Disable;
begin
  if not GL_ARB_shading_language then Exit;
  glUseProgramObjectARB(0);
end;

procedure TVFP.log(const Text: string);
begin
  olog.Print(PChar('Shader  : ' + Text));
end;

function TVFP.Error(Handle: TShader; Param: DWORD): Boolean;
var
  Status : Integer;
begin
  glGetObjectParameterivARB(Handle, Param, @Status);
  Result := Status <> 1;
end;

function TVFP.Read(Stream: TStream; Name: PChar): Boolean;
const
  mode : array [Boolean] of string = ('fragment', 'vertex');
var
  sh   : TShader;
  Text : string;
  str  : string;
  line : string;
  txt  : PChar;
  p    : Integer;
  SMode : Boolean;
  SName : string;
  This  : Boolean;
begin
  Result := False;
  if GL_ARB_shading_language and Stream.Valid and (Stream.Size > 0) then
  begin
    if Shader = 0 then
    begin
      Shader := glCreateProgramObjectARB;
      if Shader = 0 then
      begin
        log('Error creating shader object');
        Exit;
      end;
    end;
  This := False;

    SetLength(Text, Stream.Size);
    Stream.Read(Text[1], Stream.Size);
    str := '';
    SMode := True;
    SName := '';
    while Text <> '' do
    begin
      p := Pos(#13#10, Text);
      if p = 0 then
        line := Text
      else
        line := Copy(Text, 1, p - 1);
      Delete(Text, 1, p + 1);
      if (Pos('[VP', line) = 1) or (Pos('[FP', line) = 1) or (Text = '') then
      begin
        if Text = '' then
          str := str + line;
        if This and (str <> '') then
        begin
          if SMode then
            sh := glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB)
          else
            sh := glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
          txt := @str[1];
          glShaderSourceARB(sh, 1, @txt, nil);
          glCompileShaderARB(sh);
          if not Error(sh, GL_OBJECT_COMPILE_STATUS_ARB) then
          begin
            Result := True;
            glAttachObjectARB(Shader, sh);
          end else
          begin
            Result := False;
            glDeleteObjectARB(sh);
            log('Can''t add ' + mode[SMode] + ' shader "' + Name + '"');
            Exit;
          end;
          glDeleteObjectARB(sh);
        end;
        str := '';
        SMode := Pos('[VP', line) = 1;
        SName := Copy(line, 5, Pos(']', line) - 5);
        This  := SName = string(Name);
      end else
        if Name = nil then
          str := str + line + #13#10
        else
          if This then
            str := str + line + #13#10;
    end;
  end;
end;


end.
