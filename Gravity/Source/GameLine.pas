unit GameLine;

interface

uses eXgine, ASDVector, GameSprites, OpenGL, Classes, Windows, SysUtils;

type
  TLineFunction = (lfCollision, lfDead, lfStop);
  PLineBot = ^TLineBot;

  TLineBot = record
    F: TLineFunction;
    C: TRGBA;
    case Byte of
      1: (
        L: TLine);
      2: (
        A: TVector;
        B: TVector);
  end;

{  THeaderASD = record
    Magic: string[4];
    LineMem: Integer;
    Count: Integer;
  end;
}
  THeaderASD = record
    Magic: string[4];
    TimeCreate: TDateTime;
    DataCreate: TDateTime;
    UserName: string[16];
    Version: DWORD;
    LineMem: Integer;
    Count: Integer;
  end;


  TLineEngine = class(TSpriteEngine) {MAP}
  private
    FList: TList;
    FChange: Boolean;
    function GetCount: Cardinal;
    function GetLines(Index: Integer): TLine;
    procedure SetLine(Index: Integer; const Value: TLine);
    function GetLineBots(Index: Integer): TLineBot;
    procedure SetLineBots(Index: Integer; const Value: TLineBot);
  protected
    procedure DoDraw; override;
  public
    constructor Create(AParent: TSprite); override;
    destructor Destroy; override;
    property Lines[Index: Integer]: TLine read GetLines write SetLine; default;
    property LineBots[Index: Integer]: TLineBot read GetLineBots write
    SetLineBots;
    property Count: Cardinal read GetCount;
    property Change: Boolean read FChange write FChange;
    procedure Add(Line: TLineBot);
    procedure Clear;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(const Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(const Stream: TStream);
  end;

function DoCollision(Var P,V: TVector; Line: TLine; R: Real): Boolean;

implementation

function DoCollision(Var P,V: TVector; Line: TLine; R: Real): Boolean;
const
  C_LineWidth = 1;
var
  LA, LB: Real;
  AB, AC, CA, C, Vox: TVector;
  H, L, DB, MAB, MAC: Real;
  Q, Ft, D, dVi, MaxF, Vp, MV: Real;
begin
  with Line do
  begin
    C := P;
    AC := VectorSub(C, A);
    AB := VectorSub(B, A);
    LA := VectorCompareAlfa(AC, AB);
    MAB := VectorMagnitude(AB);
    MAC := VectorMagnitude(AC);
    H := MAC * Sin(LA);
    L := MAC * Cos(LA);
    D := C_LineWidth / 2;
    Result := (Abs(H) <= R + D) and ((L > D) and (L < MAB - D));
    if not Result then
      Exit;
    L := H;
    H := Abs(L) - (R + C_LineWidth / 2);
    D := Abs(L) - H;
    LA := VectorGetAlfa(AB);
    Vox := VectorAddAlfa(V, -LA);
    MV := VectorMagnitude(V);

    Vox.Y := -Vox.Y;

    V := VectorAddAlfa(Vox, +LA);
  end;
end;

{ TLineFile }

procedure TLineEngine.Add(Line: TLineBot);
var
  P: PLineBot;
begin
  New(P);
  P^ := Line;
  FList.Add(P);
  FChange := True;
end;

procedure TLineEngine.Clear;
begin
  FList.Clear;
  FChange := True;
end;

constructor TLineEngine.Create(AParent: TSprite);
begin
  inherited;
  FList := TList.Create;
  FChange := False;
end;

destructor TLineEngine.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TLineEngine.DoDraw;
var
  I:Integer;
  L:TLineBot;
begin
  inherited;
  glPushMatrix;
  glLineWidth(3);
  glBegin(GL_LINES);
  for I:=0 to Count-1 do
  begin
    L:=LineBots[I];
    glColor4ubv(@L.C);
    glVertex2dv(@L.A);
    glVertex2dv(@L.B);
  end;
  glEnd;
  glPopMatrix;
end;

function TLineEngine.GetCount: Cardinal;
begin
  Result := FList.Count;
end;

function TLineEngine.GetLineBots(Index: Integer): TLineBot;
begin
  Result := PLineBot(FList[Index])^;
end;

function TLineEngine.GetLines(Index: Integer): TLine;
begin
  Result := PLineBot(FList[Index])^.L;
end;

procedure TLineEngine.LoadFromFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  LoadFromStream(Stream);
  Stream.Free;
  FChange := False;
end;

procedure TLineEngine.LoadFromStream(const Stream: TStream);
const
  C_LoadError: PChar = 'Load Error : "this file is not ASDFile"';
var
  H: THeaderASD;
  I, P, C: Integer;
  PL: PLineBot;
begin
  P := Stream.Position;
  Stream.ReadBuffer(H, SizeOf(H));
  if H.Magic <> 'ASD ' then
    Log.Print(C_LoadError);
  FList.Clear;
  Stream.Position := P;
  Stream.ReadBuffer(H, SizeOf(H));
  Stream.Position := H.LineMem;
  C := H.Count;
  for I := 1 to C do
  begin
    New(PL);
    Stream.ReadBuffer(PL^, SizeOf(TLineBot));
    FList.Add(PL);
  end;
end;

procedure TLineEngine.SaveToFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
  FChange := False;
end;

procedure TLineEngine.SaveToStream(const Stream: TStream);
const
  C_SaveError: PChar = 'Save Error : "this file is not ASDFile"';
var
  H: THeaderASD;
  I, P: Integer;
begin
  P := Stream.Position;
  if Stream.Size <> 0 then
  begin
    Stream.ReadBuffer(H, SizeOf(H));
    if H.Magic <> 'ASD ' then
      Log.Print(C_SaveError);
    Stream.Position := P;
  end
  else
  begin
    H.Magic := 'ASD ';
  end;
  H.LineMem := P + SizeOf(H);
  H.Count := FList.Count;
  Stream.WriteBuffer(H, SizeOf(H));
  Stream.Position := H.LineMem;
  for I := 0 to FList.Count - 1 do
  begin
    Stream.WriteBuffer(PLineBot(FList[I])^, SizeOf(TLineBot));
  end;
end;

procedure TLineEngine.SetLine(Index: Integer; const Value: TLine);
begin
  PLineBot(FList[Index])^.L := Value;
end;

procedure TLineEngine.SetLineBots(Index: Integer; const Value: TLineBot);
begin
  PLineBot(FList[Index])^ := Value;
end;

end.

