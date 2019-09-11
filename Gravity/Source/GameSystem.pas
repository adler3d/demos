unit GameSystem;
{<|Модуль от игры Gtavity|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface
uses
  Windows,Menu,Scene,eXgine,OpenGL,ASDVector,SysUtils,GameSprites,GameUtils,
  PhysicSprites;

type
  TPlayer=record
    Wheel1,Wheel2:TBot;
    Connect:TConnectBot;
    Tag:Integer;
  end;
  TCamera=record
    P,V:TVector;
    A:Real;
  end;
  TMapHeader=record
    Magic:string[3];
    AppVer:Integer;
    Date,Time:TDateTime;
    MapName:string[32];
    MeshCount:Integer;
    Scale:Real;
    Start,Finish:TVector;
  end;
  TGameSys=class(TScene)
  private
    PE:TPhysicEngine;
    SP:TSpriteEngine;
    Player:TPlayer;
    Camera:TCamera;
    FStart,FFinish:TVector;
    FLife:Integer;
    LavelName:string;
    FWin:Boolean;
    procedure MakeMoped;
    procedure AddPart(P:TVector; MS:Real; Color:TRGB);
    procedure InitEffect;
  protected
    procedure Render; override;
    procedure Update; override;
    procedure GoMenu;
    procedure GoGameEnd;
  public
    constructor Create;
    procedure InitMap;
    procedure InitBot;
    procedure NewLife;
    procedure NewGame;
    procedure LoadMap(FileName:string);
    function LoadMapHeader(FileName:string):TMapHeader;
  end;

  TPart=class(TSprite)
  private
    FP,FV,FCP,FCV:TVector;
    FA,FT,FO,FLT,FMS:Real;
    FC:TRGB;
    FLoop:Boolean;
    FTex:TTexture;
  protected
    procedure DoDraw; override;
    procedure DoMove; override;
  public
    constructor Init(Owner:TSpriteEngine; P,V:TVector; T,MS:Real; C:TRGB;
      Loop:Boolean=False);
  end;

procedure InitGame;

implementation
uses
  GameVar,GameApp,GameMouse;
const
  Gravity:TVector=(X:0; Y:0.020);
  Friction=0.0005;

procedure RNDShar(const ABot:TBot);
const
  pr=1;
  Kof=0.5;
  Rot=100;
  E_Pb=15.0;
var
  aH,aW:Integer;
  cR,cG,cB:Byte;
begin
  aH:=Wnd.Height;
  aW:=Wnd.Width;
  with ABot do
  begin
    if R=0 then
      R:=RndReal(16,16);
    Texture:=Bool;
    V:=MakeVector(RndReal(-pr,pr),RndReal(-pr,pr));
    P:=MakeVector(RndReal(R+Rot,aW-R-Rot),RndReal(R+Rot,aH-R-
      Rot));
    M:=Pi*R*R*Kof;
    E:=E_Pb*M/8;
    W:=RndReal(-Pi,Pi,0.0001)/64;
    I:=(M*R*R)*Kof;
    K:=1;
    A:=RndReal(-Pi,Pi,0.0001);
    C:=RGBA(255,255,255,255);
  end;
end;

procedure InitGame;
begin
  GSys:=TGameSys.Create; //GSys.NewGame;
end;

{ TGameSys }

constructor TGameSys.Create;
begin
  PE:=TPhysicEngine.Init;
  PE.Bots.Friction:=Friction;
  PE.Bots.Gravity:=Gravity;
  SP:=TSpriteEngine.Create(PE);
end;

procedure TGameSys.GoMenu;
begin
  ActivScene:=GMenu; inp.Reset; GMenu.Select:=0;
end;

procedure TGameSys.InitBot;
const
  C:Integer=0;
var
  I,J,ReSetupCount,Count:integer;
  Bot:TBot;
label
  ReSetup;
begin
  PE.Bots.Friction:=Friction;
  PE.Bots.Gravity:=Gravity;
  ReSetupCount:=C*55;
  for J:=1 to 3 do
    for I:=1 to C do
    begin
      Bot:=TBot.Init(PE);
      ReSetup:
      RNDShar(Bot);
      Bot.P:=MakeVector(I*30,300+50*J);
      {for J:=0 to PE.Bots.Count-2 do
      begin
        if TestCollisionBot(Bot,PE.Bots[J]) then
        begin
          Dec(ReSetupCount);
          if ReSetupCount<=0 then
            Exit;
          goto ReSetup;
        end;
      end;}
    end;
end;

procedure TGameSys.InitMap;
var
  Mesh:TMeshObject;
begin
  {Mesh:=TMeshObject.Init(PE);
  Mesh.C:=RGBA(50,50,255,200);
  Mesh.P:=MakeVector(0,0);
  Mesh.AddVertex(MakeVector(10,50));
  Mesh.AddVertex(MakeVector(10,708));
  Mesh.AddVertex(MakeVector(1014,758));
  Mesh.AddVertex(MakeVector(1014,10));}
  LoadMap('Maps\Best.ASD');
end;

procedure TGameSys.AddPart(P:TVector; MS:Real; Color:TRGB);
begin
  TPart.Init(SP,P,RndVector(0.2),UPS,MS,Color,True).FTex:=flame;
end;

procedure TGameSys.NewGame;
begin
  GMenu.Items[0].Enabled:=True; Player.Wheel1:=nil; Player.Wheel2:=nil;
  Camera.P:=FStart; Camera.V:=MakeVector(0,0); Camera.A:=0; InitEffect;
  FLife:=3; NewLife; FWin:=False;
end;

procedure TGameSys.Render;
begin
  with wnd do
  begin
    glClearColor(0,0,0,0);
    OGL.Clear;
    OGL.Set2D(0,0,Width,Height);
    with Camera do
    begin
      glTranslated(-P.X+wnd.Width/2,-P.Y+wnd.Height/2,0);
      glRotated(A,0,0,1);
    end;
    OGL.Blend(BT_SUB);
    PE.Draw;
    OGL.Set2D(0,0,Width,Height);
    if ((Player.Connect=nil)and(Player.Wheel1<>nil))or(Player.Tag<0)or(FWin)
      then
    begin
      if Player.Tag>0 then glColor4d(0,0,0,1-Player.Tag/(UPS*2)) else
        glColor4d(0,0,0,Abs(Player.Tag/(UPS*2)));
      OGL.Blend(BT_SUB);
      glBegin(GL_QUADS);
      glVertex2f(-wnd.Width,-wnd.Height);
      glVertex2f(+wnd.Width,-wnd.Height);
      glVertex2f(+wnd.Width,+wnd.Height);
      glVertex2f(-wnd.Width,+wnd.Height);
      glEnd;
    end;
    RenderMouse(Cursor);
    GMenu.DrawFPS;
    ogl.TextOut(0,wnd.Width-200,16,PChar('Life : '+IntToStr(FLife)));
    ogl.TextOut(0,wnd.Width-200,32,PChar('MapName : '+LavelName));
  end;
end;

procedure TGameSys.Update;
const
  CMove:Real=5;
var
  T:TVector;
  Bot:TBot;
begin
  PE.Move; PE.Collision; PE.CollisionMap;
  with Camera,Player do
  begin
    if Player.Wheel1<>nil then
    begin
      T:=VectorDiv(VectorAdd(Wheel2.P,Wheel1.P),2);
      V:=VectorSub(V,VectorDiv(V,100));
      V:=VectorAdd(V,VectorDiv(VectorSub(VectorSub(T,P),V),1000));
    end;
    P:=VectorAdd(P,V);
  end;
  UpdateMouse;
  if inp.Down(27) then GoMenu;
  {if inp.Down(Ord('A')) then
  begin
    inp.Reset;
    Bot:=TBot.Init(PE);
    RNDShar(Bot);
    Bot.P:=FStart;
  end;}
  if Player.Tag<=0 then
  begin
    Inc(Player.Tag);
    if Player.Tag=0 then MakeMoped;
  end;
  if not FWin then
  begin
    with Player,Camera,inp do
      if Connect=nil then
      begin
        {if Down(VK_LEFT) then P:=VectorAdd(P,MakeVector(-CMove,0));
        if Down(VK_RIGHT) then P:=VectorAdd(P,MakeVector(+CMove,0));
        if Down(VK_UP) then P:=VectorAdd(P,MakeVector(0,-CMove));
        if Down(VK_DOWN) then P:=VectorAdd(P,MakeVector(0,+CMove));}
        if Wheel1<>nil then
        begin
          Dec(Tag);
          if (Tag mod 2)=0 then
          begin
            TPart.Init(SP,Wheel1.P,RndVector(0.3),UPS,UPS/4,RGB(255,255,255)).FTex:=Smoke;
            TPart.Init(SP,Wheel2.P,RndVector(0.3),UPS,UPS/4,RGB(255,255,255)).FTex:=Smoke;
          end;
          if Tag<=0 then GoGameEnd;
        end;
      end else
      begin
        if (Connect.Deaded)or Down(Ord('D')) then
        begin
          Tag:=UPS*2; Connect:=nil;
        end else Inc(Tag);
        if TestCollisionVertex(Wheel1,FFinish)or
          TestCollisionVertex(Wheel2,FFinish) then
        begin
          FWin:=True; Tag:=UPS*2;
        end;
        if (Tag mod 2)=0 then
        begin
          TPart.Init(SP,Wheel1.P,RndVector(0.3),UPS,UPS/4,RGB(255,255,255)).FTex:=flame;
          TPart.Init(SP,Wheel2.P,RndVector(0.3),UPS,UPS/4,RGB(255,255,255)).FTex:=Smoke;
        end;
        if Down(VK_LEFT) then Wheel1.AddW(-0.005);
        if Down(VK_RIGHT) then Wheel1.AddW(+0.005);
        if Down(VK_SPACE) then Wheel2.ClearAccum;
      end;
  end else
  begin
    Dec(Player.Tag);
    if (Player.Tag=0)and(not GMenu.Map.NextMap) then
    begin
      GMenu.GoCredits(nil); GMenu.Items[0].Enabled:=False; GMenu.Select:=1;
    end;
  end;
  PE.Dead;
end;

procedure TGameSys.MakeMoped;
var
  Pos:TVector;
begin
  Pos:=FStart;
  with Player do
  begin
    Wheel1:=TBot.Init(PE);
    //DefBot:=Wheel1;
    with Wheel1 do
    begin
      R:=40; RNDShar(Wheel1);
      P:=MakeVector(0,100); P:=VectorAdd(P,Pos);
      V:=MakeVector(0.2,0);
      C:=RGBA(255,255,0,255); I:=(M*R*R)/10;
    end;
    Wheel2:=TBot.Init(PE);
    with Wheel2 do
    begin
      R:=40; RNDShar(Wheel2);
      P:=MakeVector(0,-100); P:=VectorAdd(P,Pos);
      V:=MakeVector(0.2,0);
      C:=RGBA(255,255,0,255); I:=(M*R*R)/10;
    end;
    Player.Connect:=TConnectBot.Init(PE,Wheel1,Wheel2);
    Camera.P:=Pos; Camera.V:=NulVector;
  end;
end;

procedure TGameSys.LoadMap(FileName:string);
  function LoadTex(FileName:string):TTexture;
  begin
    Result:=Tex.Load(PChar(TexPath+FileName));
  end;
var
  F:file;
  H:TMapHeader;
  MH:record
    VC:Integer; //Vertex Count
    C:TRGBA;
    Tex:string[32];
  end;
  I,J:Integer;
  Temp:Pointer;
begin
  PE.Clear;
  H:=LoadMapHeader(FileName);
  with H do
  begin
    if H.Magic<>'Map' then
    begin
      log.Print(PChar('Error : File "'+FileName+'" not identify'));
      CloseFile(F); Exit;
    end;
    AssignFile(F,FileName); Reset(F,1); Seek(F,SizeOf(H));
    FStart:=VectorMul(H.Start,H.Scale); FFinish:=VectorMul(H.Finish,H.Scale);
    LavelName:=H.MapName;
    for I:=1 to MeshCount do
    begin
      BlockRead(F,MH,SizeOF(MH));
      with TMeshObject.Init(PE) do
      begin
        GetMem(Temp,SizeOf(TVector)*MH.VC);
        BlockRead(F,Temp^,SizeOf(TVector)*MH.VC);
        LoadFromMem(MH.VC,Temp,H.Scale); FreeMem(Temp);
        C:=RGBA(255,255,255,255); //MH.C;
        Texture:=LoadTex(MH.Tex);
      end;
    end;
  end;
  CloseFile(F);
  NewGame;
end;

function TGameSys.LoadMapHeader(FileName:string):TMapHeader;
var
  F:file;
begin
{$I-}
  AssignFile(F,FileName); Reset(F,1);
{$I+}
  if IOResult<>0 then
  begin
    log.Print(PChar('Error : File "'+FileName+'" not found')); Exit;
  end;
  BlockRead(F,Result,SizeOf(Result)); CloseFile(F);
end;

procedure TGameSys.InitEffect;
var
  I:Integer;
begin
  //for I:=0 to 10 do AddPart(FStart,80,RGB(255,64,16));
  for I:=0 to 10 do AddPart(FFinish,80,RGB(64,128,255));
  for I:=0 to 10 do AddPart(FStart,80,RGB(255,128,64));
end;

procedure TGameSys.GoGameEnd;
begin
  Dec(FLife);
  if FLife>=0 then
  begin
    NewLife; Exit;
  end;
  GoMenu; GMenu.Items[0].Enabled:=False; GMenu.Select:=1;
end;

procedure TGameSys.NewLife;
begin
  Player.Wheel1:=nil; Player.Wheel2:=nil; Player.Connect:=nil;
  Player.Tag:=-2*UPS; Camera.P:=FStart; Camera.V:=NulVector;
end;

{ TPart }

procedure TPart.DoDraw;
begin
  glPushMatrix;
  ogl.Blend(BT_ADD);
  tex.Enable(FTex);
  glColor4ub(FC.R,FC.G,FC.B,Round(FLT*255/FT));
  DrawQuads(FP.X,FP.Y,(FLT-FT)/FT*FMS,(FLT-FT)/FT*FMS,FA);
  tex.Disable;
  glPopMatrix;
end;

constructor TPart.Init(Owner:TSpriteEngine; P,V:TVector; T,MS:Real; C:TRGB;
  Loop:Boolean);
begin
  inherited Create(Owner);
  FP:=P; FV:=V; FT:=T; FC:=C; FA:=RndReal(0,360); FO:=RndReal(-1,1,0.001);
  FCP:=FP; FCV:=FV; FLoop:=Loop; FMS:=MS;
  if FLoop then FLT:=RndReal(1,FT) else FLT:=FT;
end;

procedure TPart.DoMove;
const
  G:TVector=(X:0; Y:-0.003);
begin
  FP:=VectorAdd(FP,FV); FV:=VectorAdd(FV,G);
  FLT:=FLT-1; FA:=FA+FO;
  if FLT<0 then
    if FLoop then
    begin
      FLT:=FT; FV:=FCV; FP:=FCP;
    end else Dead;
end;

end.

