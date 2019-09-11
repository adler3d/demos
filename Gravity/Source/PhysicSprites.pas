unit PhysicSprites;
{<|Вспомогательный модуль|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface

uses
  Windows,OpenGL,eXgine,GameUtils,ASDVector,GameSprites;

type
  TPhysicEngine=class;
  TBot=class;
  TMapEngine=class;
  TBotEngine=class;
  TSysEngine=class;

  TPhysicEngine=class(TSpriteEngine)
  private
    FBots:TBotEngine;
    FMap:TMapEngine;
    FSys:TSysEngine;
  protected
  public
    constructor Init;
    procedure Collision;
    procedure CollisionMap;
    procedure Dead; override;
    procedure Draw; override;
    property Bots:TBotEngine read FBots;
    property Map:TMapEngine read FMap;
    property Sys:TSysEngine read FSys;
  end;

  TBotEngine=class(TSpriteEngine)
  private
    FSharTexture:TTexture;
    FFriction:Real;
    FGravity:TVector;
    function GetBots(Index:Integer):TBot;
  protected
  public
    constructor Create(AParent:TSprite); override;
    procedure Collision;
    property Items[Index:Integer]:TBot read GetBots; default;
    property Gravity:TVector read FGravity write FGravity;
    property Friction:Real read FFriction write FFriction;
  end;

  TBot=class(TSprite)
  private
    FGame:TPhysicEngine;
    FBots:TBotEngine;
    FA:Real; //Угол поворота
    FR:Real; //Радиус
    FW:Real; //Угловая скорость
    FI:Real; //Момент инерции I=M*R^2
    FK:Real; //Коэфициент трения
    FM:Real; //Масса
    FC:TRGBA; //Цвет
    FP:TVector; //Позиция
    FV:TVector; //Скорости
    FE:Real; //Модуль юнга(упругости)
    FAddW:Real;
    FAddV:TVector;
    FTexture:TTexture;
  protected
    procedure DoMove; override;
    procedure DoAccum;
  public
    constructor Create(AParent:TSprite); override;
    constructor Init(AEngine:TPhysicEngine);
    destructor Destroy; override;
    procedure DoDraw; override;
    procedure AddForce(F:TVector);
    procedure AddW(W:Real);
    procedure ClearAccum;
    property Game:TPhysicEngine read FGame;
    property Bots:TBotEngine read FBots;
    property P:TVector read FP write FP;
    property V:TVector read FV write FV;
    property R:Real read FR write FR;
    property M:Real read FM write FM;
    property A:Real read FA write FA;
    property W:Real read FW write FW;
    property I:Real read FI write FI;
    property E:Real read FE write FE;
    property K:Real read FK write FK;
    property C:TRGBA read FC write FC;
    property Texture:TTexture read FTexture write FTexture;
  end;

  TMapEngine=class(TSpriteEngine)
  private
    //FTexture: ITexImage;
    FMapTexture:TTexture;
    FGame:TPhysicEngine;
    function DoCollision(const A,B:TVector; const Bot:TBot):Boolean;
  protected
    procedure DoMove; override;
  public
    constructor Create(AParent:TSprite); override;
    property Game:TPhysicEngine read FGame;
    property MapTexture:TTexture read FMapTexture write FMapTexture;
    procedure Collision;
  end;

  TMeshObject=class(TSprite)
  private
    FVertex:TQuickList;
    FMap:TMapEngine;
    FP:TVector;
    FTexture:TTexture;
    FC:TRGBA;
    function GetVertex(Index:Integer):TVector;
    function GetVertexCount:Integer;
  protected
    procedure DoDraw; override;
  public
    constructor Create(AParent:TSprite); override;
    constructor Init(AEngine:TPhysicEngine);
    destructor Destroy; override;
    property VertexCount:Integer read GetVertexCount;
    property Vertex[Index:Integer]:TVector read GetVertex; default;
    property Map:TMapEngine read FMap;
    property P:TVector read FP write FP;
    property Texture:TTexture read FTexture write FTexture;
    property C:TRGBA read FC write FC;
    procedure AddVertex(V:TVector);
    procedure LoadFromMem(Count:Integer; Mem:Pointer; Scale:Real);
  end;

  TSysEngine=class(TSpriteEngine)
  private
    FTexture:TTexture;
    FMapTexture:TTexture;
    FGame:TPhysicEngine;
  public
    property Game:TPhysicEngine read FGame;
  end;

  TConnectBot=class(TSprite)
  private
    FB2:TBot;
    FB1:TBot;
    FE:Real;
    FNL:Real;
    FM:Real;
    FSys:TSysEngine;
    FMaxF:Real;
  protected
    procedure DoDraw; override;
    procedure DoMove; override;
  public
    constructor Init(AEngine:TPhysicEngine; A,B:TBot);
    property Bot1:TBot read FB1 write FB1;
    property Bot2:TBot read FB2 write FB2;
    property NormL:Real read FNL write FNL;
    property E:Real read FE write FE;
    property MaxF:Real read FMaxF write FMaxF;
  end;

const
  C_LineWidth:Real=1;
var
  BotImage:TTexture;

function TestCollisionBot(const A,B:TBot):Boolean;
function TestCollisionVertex(const A:TBot; const V:TVector):Boolean;
function RndVector(Mag:Real):TVector;
procedure DrawLine(Size:Real; A,B:TVector);

implementation

procedure DrawLine(Size:Real; A,B:TVector);
var
  D:TVector;
  V:array[1..4] of TVector;
  E:Real;
begin
  E:=VectorGetAlfa(VectorSub(A,B))+(Pi/2);
  D.X:=Size*Cos(E); D.Y:=Size*Sin(E);
  V[1]:=VectorSub(A,D); V[2]:=VectorSub(B,D);
  V[3]:=VectorAdd(B,D); V[4]:=VectorAdd(A,D);
  glBegin(GL_QUADS);
  glVertex2dv(@V[1]); glVertex2dv(@V[2]);
  glVertex2dv(@V[3]); glVertex2dv(@V[4]);
  glEnd;
end;

function RndVector(Mag:Real):TVector;
var Alfa:Real;
begin
  Alfa:=RndReal(-Pi,Pi,0.001); Result.X:=Mag*Cos(Alfa); Result.Y:=Mag*Sin(Alfa);
end;

function TestCollisionBot(const A,B:TBot):Boolean;
begin
  Result:=((A.FP.X-B.FP.X)*(A.FP.X-B.FP.X)+(A.FP.Y-B.FP.Y)*(A.FP.Y
    -B.FP.Y))<=((A.FR+B.FR)*(A.FR+B.FR));
end;

function TestCollisionVertex(const A:TBot; const V:TVector):Boolean;
begin
  Result:=((A.FP.X-V.X)*(A.FP.X-V.X)+(A.FP.Y-V.Y)*(A.FP.Y-V.Y))<=((A.FR+C_LineWidth/2)*(A.FR+C_LineWidth/2));
end;

procedure CollisionVertex(var A:TBot; B:TVector);
var
  M,L,V,D,E,H,Er,K,Vp,dV,F,Ft,Vr,MaxF:Real;
  OX,Vox:TVector;
const
  C_F:Real=1;
begin
  E:=A.FE; M:=A.FM;
  OX:=VectorSub(A.FP,B);
  H:=(A.FR+C_LineWidth/2-VectorMagnitude(OX)); D:=A.FR-(H*H/2);
  Er:=(E*E)/(E+E); F:=Er*(H*H)/(A.FR+C_LineWidth/2);
  Vox:=VectorRot(A.FV,OX); K:=A.FK; Ft:=K*F; V:=(D*-A.FW)+Vox.Y;
  Vp:=(C_F/M)+(C_F*D*D/A.FI); dV:=(Vp)/C_F; Vr:=(V*dV)/(dV+dV);
  MaxF:=Abs((V-Vr)/dV); if Ft<MaxF then MaxF:=Ft else MaxF:=MaxF;
  if V>0 then
  begin
    A.FAddW:=A.FAddW+(MaxF*D/A.FI); Vox.Y:=-MaxF/M;
  end else
  begin
    A.FAddW:=A.FAddW-(MaxF*D/A.FI); Vox.Y:=+MaxF/M;
  end;
  Ft:=Ft/25; if Vox.X>0 then Ft:=-Ft;
  Vox.X:=+(F+Ft)/M;
  A.FAddV:=VectorAdd(A.FAddV,VectorUnRot(Vox,OX));
end;

procedure CollisionShar(var A,B:TBot);
var
  M1,M2:Real; //Массы тел
  L1,L2:Real; //Момент импульса для 1-го и 2-го Шара
  V1,V2:Real; //Линейные скорости шаров
  D1,D2:Real; //Плечо силы общее
  E1,E2:Real; //Модули упругости
  H:Real; //Деформация
  F,Ft:Real; //Сила упругости,трения
  OX:TVector;
  AOX,K:Real;
  Vox1,Vox2:TVector;
  Vp1,Vp2:Real;
  dV1,dV2:Real;
  Vr:Real;
  MaxF,Mag,Er:Real;
const
  C_F:Real=1;
begin
  E1:=A.FE;
  E2:=B.FE;
  M1:=A.FM;
  M2:=B.FM;
  OX:=VectorSub(A.FP,B.FP);
  Mag:=VectorMagnitude(OX);

  H:=(A.FR+B.FR-Mag);
  D1:=A.FR-(H*H/2);
  D2:=B.FR-(H*H/2);

  Er:=(E2*E1)/(E1+E2);

  F:=Er*(H*H)/(A.FR+B.FR);

  AOX:=VectorGetAlfa(OX);

  Vox1:=VectorAddAlfa(A.FV,-AOX);
  Vox2:=VectorAddAlfa(B.FV,-AOX);

  K:=(A.FK+B.FK)/2;
  Ft:=K*F;

  V1:=(D1*-A.FW)+Vox1.Y;
  V2:=(D2*+B.FW)+Vox2.Y;

  Vp1:=(C_F/M1)+(C_F*D1*D1/A.FI);
  Vp2:=(C_F/M2)+(C_F*D2*D2/B.FI);

  dV1:=(Vp1)/C_F;
  dV2:=(Vp2)/C_F;

  Vr:=((V1*dV2)+(V2*dV1))/(dV1+dV2);
  MaxF:=Abs((V1-Vr)/dV1);

  if Ft<MaxF then
    MaxF:=Ft
  else
    MaxF:=MaxF;

  Vox1.Y:=0;
  Vox2.Y:=0;

  if V1>V2 then
  begin
    A.FAddW:=A.FAddW+(MaxF*D1/A.FI);
    B.FAddW:=B.FAddW+(MaxF*D2/B.FI);

    Vox1.Y:=-MaxF/M1;
    Vox2.Y:=+MaxF/M2;
  end
  else
  begin
    A.FAddW:=A.FAddW-(MaxF*D1/A.FI);
    B.FAddW:=B.FAddW-(MaxF*D2/B.FI);

    Vox1.Y:=+MaxF/M1;
    Vox2.Y:=-MaxF/M2;
  end;

  Ft:=Ft/25;
  if (Vox1.X-Vox2.X)>0 then
    Ft:=-Ft;

  Vox1.X:=+(F+Ft)/M1;
  Vox2.X:=-(F+Ft)/M2;

  A.FAddV:=VectorAdd(A.FAddV,VectorAddAlfa(Vox1,AOX));
  B.FAddV:=VectorAdd(B.FAddV,VectorAddAlfa(Vox2,AOX));
end;

function PointInRect(const Point:TVector; const Rect:TRect):Boolean;
begin
  Result:=(Point.X>=Rect.Left)and
    (Point.X<=Rect.Right)and
    (Point.Y>=Rect.Top)and
    (Point.Y<=Rect.Bottom);
end;

{ TGameEngine }

procedure TPhysicEngine.CollisionMap;
begin
  FMap.Collision;
end;

procedure TPhysicEngine.Collision;
begin
  FBots.Collision;
  FMap.Collision;
end;

constructor TPhysicEngine.Init;
begin
  inherited Create(nil);
  FMap:=TMapEngine.Create(Self); //Карта
  FSys:=TSysEngine.Create(Self);
  FBots:=TBotEngine.Create(Self); //Боты
end;

procedure TPhysicEngine.Dead;
var
  I:Integer;
begin
  for I:=0 to Count-1 do
  begin
    Items[I].Dead;
  end;
end;

procedure TPhysicEngine.Draw;
var
  I:Integer;
begin
  for I:=0 to Count-1 do
    Items[I].Draw;
end;

{ TBot }

procedure TBot.AddForce(F:TVector);
begin
  FAddV:=VectorSub(FAddV,VectorDiv(F,FM));
end;

procedure TBot.AddW(W:Real);
begin
  FAddW:=FAddW+W;
end;

procedure TBot.ClearAccum;
begin
  FAddW:=0; FW:=0;
end;

constructor TBot.Create(AParent:TSprite);
begin
  inherited;
  if AParent=nil then Exit;
  if (Engine is TPhysicEngine) then
  begin
    FGame:=TPhysicEngine(Engine);
  end;
  if (Engine.Engine is TPhysicEngine) then
  begin
    FGame:=TPhysicEngine(Engine.Engine);
  end;
end;

destructor TBot.Destroy;
begin
end;

procedure TBot.DoAccum;
begin
  FW:=FAddW+FW;
  FV:=VectorAdd(FAddV,FV);
  FAddW:=0;
  FAddV:=NulVector;
end;

procedure TBot.DoDraw;
const
  RG:Real=180/Pi;
  //GR:Real = Pi/180;
begin
  tex.Enable(FTexture); glColor4ubv(@FC);
  DrawQuads(FP.X,FP.Y,FR*2,FR*2,FA*RG);
end;

procedure TBot.DoMove;
begin
  inherited;
  DoAccum;
  FP:=VectorAdd(FP,FV);
  FA:=FA+FW-FBots.FFriction*FW;
  if not VectorEquel(FV,NulVector) then
    FAddV:=VectorSub(FAddV,VectorSetDlina(FV,FBots.FFriction));
  FAddV:=VectorAdd(FAddV,FBots.FGravity);
end;

constructor TBot.Init(AEngine:TPhysicEngine);
begin
  FBots:=TPhysicEngine(AEngine).Bots;
  Create(FBots);
  FTexture:=BotImage;
end;

{ TMapEngine }

function TMapEngine.DoCollision(const A,B:TVector; const Bot:TBot):Boolean;
var
  LA,LB:Real;
  AB,AC,CA,C,Vox,Temp:TVector;
  L,H,DB,MAB,MAC,Er,E:Real;
  Q,R,Ft,D,dVi,MaxF,Vp,MV:Real;
begin
  R:=Bot.FR; C:=Bot.FP; E:=Bot.FE;
  AC:=VectorSub(C,A); AB:=VectorSub(B,A); MAB:=VectorMagnitude(AB);
  Temp:=VectorRot(AC,AB); L:=Temp.X; H:=Temp.Y; D:=C_LineWidth/2;
  Result:=(Abs(H)<=R+D)and((L>{D} 0)and(L<MAB{-D}));
  if not Result then Exit;
  L:=H; H:=Abs(H)-(R+C_LineWidth/2); D:=Abs(L)-H;
  Vox:=VectorRot(Bot.FV,AB); Er:=(E*E)/(E+E);
  Q:=Er*Abs(H*H)/Bot.FR; Ft:=Bot.FK*Q;
  dVi:=(1/Bot.FM)+(D*D/Bot.FI);
  Vp:=Vox.X+Bot.FW*D;
  MaxF:=Abs(Vp/dVi);
  if MaxF>Ft then MaxF:=Ft;
  if (Vp>0) then
  begin
    Bot.AddW(-MaxF*D/Bot.FI); Vox.X:=-MaxF/Bot.FM;
  end else
  begin
    Bot.AddW(+MaxF*D/Bot.FI); Vox.X:=+MaxF/Bot.FM;
  end;                   //Ft:=0;
  if Vox.Y>0 then Ft:=-Ft; Ft:=Ft;
  if ((Ft+Q)/Bot.FM)>Vox.Y then Ft:=Vox.Y-(Q/Bot.FM);
  Vox.Y:=(+Ft+Q)/Bot.FM;
  Bot.FAddV:=VectorAdd(Bot.FAddV,VectorUnRot(Vox,AB));
end;

procedure TMapEngine.Collision;
var
  I,X,Y:Integer;
  Mesh:TMeshObject;
  Bot:TBot;
  A,B:TVector;
begin
  for I:=0 to Count-1 do
  begin
    Mesh:=TMeshObject(Items[I]);
    if Mesh.VertexCount=0 then Continue;
    B:=Mesh[Mesh.VertexCount-1];
    for X:=0 to Mesh.VertexCount-1 do
    begin
      A:=Mesh[X];
      for Y:=0 to Game.Bots.Count-1 do
      begin
        Bot:=Game.Bots[Y];
        if DoCollision(A,B,Bot) then else if TestCollisionVertex(Bot,B) then
          CollisionVertex(Bot,B);
      end;
      B:=A;
    end;
  end;
end;

constructor TMapEngine.Create(AParent:TSprite);
begin
  inherited;
  FGame:=TPhysicEngine(AParent);
end;

procedure TMapEngine.DoMove;
begin
  //Not Action
end;

{ TBotEngine }

procedure TBotEngine.Collision;
var
  I,J,C:Integer;
  A,B:TBot;
begin
  for I:=0 to Count-1 do
  begin
    A:=Items[I];
    //C:=0;
    for J:=I+1 to Count-1 do
    begin
      B:=Items[J];
      if TestCollisionBot(A,B) then
      begin
        CollisionShar(A,B);
        {Inc(C);
        if C>6 then
          Break;}
      end;
    end;
  end;
end;

constructor TBotEngine.Create(AParent:TSprite);
begin
  inherited;
end;

function TBotEngine.GetBots(Index:Integer):TBot;
begin
  Result:=TBot(inherited Items[Index]);
end;

{ TMeshObject }

procedure TMeshObject.AddVertex(V:TVector);
var
  PV:PVector;
begin
  New(PV);
  PV^:=V;
  FVertex.Add(PV);
end;

constructor TMeshObject.Create(AParent:TSprite);
begin
  inherited;
  FVertex:=TQuickList.Create;
end;

destructor TMeshObject.Destroy;
begin
  FVertex.Free;
  inherited;
end;

procedure TMeshObject.DoDraw;
const
  C_TexSize=128;
var
  I:Integer;
  A{,B}:TVector;
begin
  glPushMatrix;
  glColor4ubv(@FC);
  glTranslatef(FP.X,FP.Y,0);
  //B:=Vertex[FVertex.Count-1]; Tex.Disable;
  Tex.Enable(FTexture);
  glBegin(GL_POLYGON);
  for I:=0 to FVertex.Count-1 do
  begin
    A:=Vertex[I];
    glTexCoord2d(A.X/C_TexSize,A.Y/C_TexSize); glVertex3dv(@A);
    //DrawLine(C_LineWidth/2,A,B); B:=A;
  end;
  glEnd; Tex.Disable;
  glPopMatrix;
end;

function TMeshObject.GetVertex(Index:Integer):TVector;
begin
  Result:=PVector(FVertex[Index])^;
end;

function TMeshObject.GetVertexCount:Integer;
begin
  Result:=FVertex.Count;
end;

constructor TMeshObject.Init(AEngine:TPhysicEngine);
begin
  FMap:=TPhysicEngine(AEngine).Map;
  Create(FMap);
end;

procedure TMeshObject.LoadFromMem(Count:Integer; Mem:Pointer; Scale:Real);
type
  PWarpVector=^TWarpVector;
  TWarpVector=array[0..0] of TVector;
var
  I:Integer;
begin
  for I:=0 to Count-1 do AddVertex(VectorMul(PWarpVector(Mem)^[I],Scale));
end;

{ TConnectBot }

procedure TConnectBot.DoDraw;
begin
  glColor3d(1,1,1); DrawLine(1,FB1.FP,FB2.FP);
end;

procedure TConnectBot.DoMove;
var
  D,Ft,A:Real;
  F,V:TVector;
begin
  F:=VectorSub(FB2.FP,FB1.FP);
  D:=VectorMagnitude(F);
  D:=D-FNL;
  A:=VectorGetAlfa(F);
  V:=VectorAddAlfa(VectorSub(FB2.FV,FB1.FV),-A);
  Ft:=(FB1.FK+FB1.FK)/2;
  if V.X>0 then
    Ft:=-Ft;
  if VectorMagnitude(VectorMul(F,(-FE*D)+Ft))>FMaxF then Dead;
  FB1.AddForce(VectorMul(F,(-FE*D)+Ft));
  FB2.AddForce(VectorMul(F,(+FE*D)-Ft));
end;

constructor TConnectBot.Init(AEngine:TPhysicEngine; A,B:TBot);
begin
  FSys:=TPhysicEngine(AEngine).FSys;
  Create(FSys);
  FB1:=A;
  FB2:=B;
  FNL:=VectorMagnitude(VectorSub(FB2.FP,FB1.FP));
  FM:=FB1.FM+FB2.FM;
  FE:=0.1;
  FMaxF:=E*FM*2;
end;

end.

