unit GameSprites;
{<|Вспомогательный модуль|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface
uses
  Windows,ASDVector,eXgine;
{$D-}
const
  MaxListSize=Maxint div 16;
type
  TString32=string[32];

  TSprite=class;

  TSpriteEngine=class;

  TSpriteClass=class of TSprite;

  PPointerList=^TPointerList;
  TPointerList=array[0..MaxListSize-1] of Pointer;

  TQuickList=class(TObject)
  private
    FList:PPointerList;
    FCount:Integer;
    FCapacity:Integer;
  protected
    function Get(Index:Integer):Pointer;
    procedure Grow; virtual;
    procedure Put(Index:Integer; Item:Pointer);
    procedure SetCapacity(NewCapacity:Integer);
    function GetCapacity:Integer;
    function GetCount:Integer;
  public
    destructor Destroy; override;
    function Add(Item:Pointer):Integer;
    procedure Clear; virtual;
    procedure Delete(Index:Integer); virtual;
    function First:Pointer;
    function Last:Pointer;
    property Capacity:Integer read FCapacity write SetCapacity;
    property Count:Integer read FCount;
    property Items[Index:Integer]:Pointer read Get write Put; default;
    property List:PPointerList read FList;
  end;

  TAccessObject=class(TObject)
  private
    FLockCount:Integer;
  public
    constructor Create;
    property LockCount:Integer read FLockCount;
    procedure Lock;
    procedure UnLock;
    procedure Free; virtual;
  end;

  TSprite=class(TAccessObject)
  private
    FEngine:TSpriteEngine;
    FParent:TSprite;
    FList:TQuickList;
    FVisible:Boolean;
    FMoved:Boolean;
    FAllCount:Integer;
    FTag:Integer;
    FDeaded:boolean;
    FCaption:TString32;
    function GetCount:integer;
    function GetItems(Index:Integer):TSprite;
    procedure Add(Sprite:TSprite); virtual;
  protected
    procedure DoMove; virtual;
    procedure DoDraw; virtual;
  public
    constructor Create(AParent:TSprite); virtual;
    procedure Free; override;
    procedure Draw; virtual;
    procedure Move; virtual;
    procedure Dead; virtual;
    procedure Clear; virtual;
    property Engine:TSpriteEngine read FEngine;
    property Visible:Boolean read FVisible write FVisible;
    property Moved:Boolean read FMoved write FMoved;
    property Tag:Integer read FTag write FTag;
    property Count:integer read GetCount;
    property Deaded:boolean read FDeaded;
    property Caption:TString32 read FCaption;
    property AllCount:Integer read FAllCount;
    property Parent:TSprite read FParent;
    property Items[Index:Integer]:TSprite read GetItems; default;
  end;

  TSpriteEngine=class(TSprite)
  private
    FDeadList:TQuickList;
  public
    constructor Create(AParent:TSprite); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Dead; override;
  end;

function TestColision(const P1,P2:TVector; const R1,R2:Real):Boolean;
procedure RaiseError(Msg:string);

implementation

uses SysUtils;

function TestColision(const P1,P2:TVector; const R1,R2:Real):Boolean;
var
  X,Y,R:Real;
begin
  Result:=((P1.X-P2.X)*(P1.X-P2.X)+(P1.Y-P2.Y)*(P1.Y-P2.Y))
    <=((R1+R2)*(R1+R2));
end;

procedure RaiseError(Msg:string);
begin
  Log.Print(PChar(Msg));
end;

{ TQuickList }

destructor TQuickList.Destroy;
begin
  Clear;
end;

function TQuickList.Add(Item:Pointer):Integer;
begin
  Result:=FCount;
  if Result=FCapacity then
    Grow;
  FList^[Result]:=Item;
  Inc(FCount);
end;

procedure TQuickList.Clear;
begin
  FreeMem(FList); FList:=nil;
  FCount:=0; FCapacity:=0;
end;

procedure TQuickList.Delete(Index:Integer);
var
  Temp:Pointer;
begin
  if (Index<0)or(Index>=FCount) then
  begin
    RaiseError('List index out of bounds ('+IntToStr(Index)+')');
    Exit;
  end;
  Temp:=Items[Index];
  FList^[Index]:=FList^[FCount-1];
  Dec(FCount);
end;

function TQuickList.First:Pointer;
begin
  Result:=Get(0);
end;

function TQuickList.Get(Index:Integer):Pointer;
begin
  if (Index<0)or(Index>=FCount) then
  begin
    RaiseError('List index out of bounds ('+IntToStr(Index)+')');
    Exit;
  end;
  Result:=FList^[Index];
end;

procedure TQuickList.Grow;
var
  Delta:Integer;
begin
  if FCapacity>64 then
    Delta:=FCapacity div 4
  else if FCapacity>8 then
    Delta:=16
  else
    Delta:=4;
  SetCapacity(FCapacity+Delta);
end;

function TQuickList.Last:Pointer;
begin
  Result:=Get(FCount-1);
end;

procedure TQuickList.Put(Index:Integer; Item:Pointer);
var
  Temp:Pointer;
begin
  if (Index<0)or(Index>=FCount) then
  begin
    RaiseError('List index out of bounds ('+IntToStr(Index)+')');
    Exit;
  end;
  if Item<>FList^[Index] then
  begin
    Temp:=FList^[Index];
    FList^[Index]:=Item;
  end;
end;

procedure TQuickList.SetCapacity(NewCapacity:Integer);
begin
  if (NewCapacity<FCount)or(NewCapacity>MaxListSize) then
  begin
    RaiseError('List capacity out of bounds ('+IntToStr(NewCapacity)+
      ')');
    Exit;
  end;
  if NewCapacity<>FCapacity then
  begin
    ReallocMem(FList,NewCapacity*SizeOf(Pointer));
    FCapacity:=NewCapacity;
  end;
end;

function TQuickList.GetCapacity:Integer;
begin
  Result:=FCapacity;
end;

function TQuickList.GetCount:Integer;
begin
  Result:=FCount;
end;

{ TAccessObject }

constructor TAccessObject.Create;
begin
  FLockCount:=0;
end;

procedure TAccessObject.Free;
begin
  //Not Action
end;

procedure TAccessObject.Lock;
begin
  Inc(FLockCount);
end;

procedure TAccessObject.UnLock;
begin
  Dec(FLockCount);
  if FLockCount=0 then
    inherited Free;
end;

{ TSprite }

procedure TSprite.Add(Sprite:TSprite);
begin
  if FList=nil then
  begin
    FList:=TQuickList.Create;
  end;
  FList.Add(Sprite);
end;

constructor TSprite.Create(AParent:TSprite);
begin
  inherited Create;
  FParent:=AParent;
  if FParent<>nil then
  begin
    FParent.Add(Self);
    if FParent is TSpriteEngine then
      FEngine:=TSpriteEngine(FParent)
    else
      FEngine:=FParent.Engine;
    Inc(FEngine.FAllCount);
    FCaption:=ClassName+' #'+IntToStr(FEngine.AllCount);
  end
  else
    FCaption:=ClassName+' Boss';
  FMoved:=True;
  FVisible:=True;
  Lock;
end;

procedure TSprite.Dead;
begin
  if (FEngine<>nil)and not FDeaded then
    FEngine.FDeadList.Add(Self);
  FDeaded:=True;
end;

procedure TSprite.Clear;
begin
  while Count>0 do
    Items[Count-1].Free;
  if FList<>nil then
  begin
    FList.Free;
    FList:=nil;
  end;
end;

procedure TSprite.Free;
begin
  Clear;
  UnLock;
end;

function TSprite.GetCount:integer;
begin
  if FList<>nil then
    Result:=FList.Count
  else
    Result:=0;
end;

function TSprite.GetItems(Index:Integer):TSprite;
begin
  Result:=FList[Index];
end;

procedure TSprite.Move;
var
  i:integer;
begin
  if FMoved then
  begin
    DoMove;
    for i:=0 to Count-1 do
      Items[i].Move;
  end;
end;

procedure TSprite.DoDraw;
begin
end;

procedure TSprite.DoMove;
begin
end;

procedure TSprite.Draw;
var
  i:integer;
begin
  if FVisible then
  begin
    DoDraw;
    for I:=0 to Count-1 do
      Items[I].Draw;
  end;
end;

{ TSpriteEngine }

procedure TSpriteEngine.Clear;
var
  I:Integer;
begin
  for I:=0 to Count-1 do
  begin
    if Items[I] is TSpriteEngine then Items[I].Clear else Items[I].Dead;
  end;
  Dead;
end;

constructor TSpriteEngine.Create(AParent:TSprite);
begin
  inherited;
  FDeadList:=TQuickList.Create;
end;

procedure TSpriteEngine.Dead;
var
  I,J:Integer;
  S:TSprite;
begin
  for I:=FDeadList.Count-1 downto 0 do
  begin
    S:=TSprite(FDeadList[I]);
    for J:=FList.Count-1 downto 0 do if FList[J]=S then FList.Delete(J);
    FDeadList.Delete(I); S.Free;
  end;
end;

destructor TSpriteEngine.Destroy;
begin
  FDeadList.Free;
  inherited;
end;

end.

