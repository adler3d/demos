unit Menu;
{<|Вспомогательный модуль|>}
{<|Дата создания 18.03.08|>}
{<|Автор Adler3D|>}
{<|e-mail : Adler3D@Mail.ru|>}
{<|Дата последнего изменения 31.03.08|>}
interface
uses
  Windows,Scene,eXgine,OpenGL,GameUtils,Classes,ASDVector;
const
  FontSize=16;
type
  TMenuItem=class;
  TMenu=class(TScene)
  private
    FFont:TFont;
    FName:string;
    FOwner:TScene;
    FItems:TList;
    FSelect:Integer;
    FSelectColor:TRGBA;
    FDisColor:TRGBA;
    FCursor:TTexture;
    FSelTex:TTexture;
    FLastML:Real;
    function GetItems(I:Integer):TMenuItem;
    procedure SetItems(I:Integer; const Value:TMenuItem);
    function GetItemsCount:Integer;
    procedure SetSelect(const Value:Integer);
  protected
    function ItemFromPoint(P:TVector):Integer;
  public
    constructor Create(AName:string; AOwner:TScene=nil);
    function Add(Name:string; Action:TNotifyEvent;
      Enabled:Boolean=True):TMenuItem;
    Procedure Clear;
    procedure AddItem(Item:TMenuItem);
    procedure Render; override;
    procedure Update; override;
    property SelectColor:TRGBA read FSelectColor write FSelectColor;
    property DisColor:TRGBA read FDisColor write FDisColor;
    property Items[I:Integer]:TMenuItem read GetItems write SetItems;
    property ItemsCount:Integer read GetItemsCount;
    property Font:TFont read FFont;
    property Select:Integer read FSelect write SetSelect;
    property Owner:TScene read FOwner;
    property Cursor:TTexture read FCursor write FCursor;
    property SelTex:TTexture read FSelTex write FSelTex;
  end;

  TMenuItem=class(TObject)
  private
    FEnabled:Boolean;
    FName:string;
    FColor:TRGBA;
    FOnAction,FOnSelect:TNotifyEvent;
    FOwner:TMenu;
    FDisColor:TRGBA;
  protected
    procedure Action; Virtual;
    procedure Select; Virtual;
  public
    constructor Create(AOwner:TMenu);
    property Owner:TMenu read FOwner;
    property Name:string read FName write FName;
    property Color:TRGBA read FColor write FColor;
    property DisColor:TRGBA read FDisColor write FDisColor;
    property Enabled:Boolean read FEnabled write FEnabled;
    property OnAction:TNotifyEvent read FOnAction write FOnAction;
    property OnSelect:TNotifyEvent read FOnSelect write FOnSelect;
  end;
implementation
uses
  {GameVar,}GameMouse;

function TMenu.Add(Name:string; Action:TNotifyEvent; Enabled:Boolean):TMenuItem;
begin
  Result:=TMenuItem.Create(Self); AddItem(Result);
  Result.Name:=Name;
  Result.OnAction:=Action;
  Result.Enabled:=Enabled;
  if Enabled and(Select=-1) then Select:=FItems.Count-1;
end;

procedure TMenu.AddItem(Item:TMenuItem);
begin
  FItems.Add(Item);
end;

procedure TMenu.Clear;
var
  I:Integer;
begin
  for I:=FItems.Count-1 downto 0 do Items[I].Free;
  FItems.Clear;
end;

constructor TMenu.Create(AName:string; AOwner:TScene);
begin
  InitMouse(wnd.Width/2,wnd.Height/2);
  if AOwner=nil then
  begin
    FOwner:=AOwner;
    FFont:=ogl.Font.Create('Comic Sans MS',FontSize);
  end else
  begin
    FOwner:=AOwner;
    if FOwner is TMenu then
    begin
      FFont:=TMenu(FOwner).FFont;
      FSelTex:=TMenu(FOwner).FSelTex;
      FCursor:=TMenu(FOwner).FCursor;
    end;
  end;
  FName:=AName;
  FSelect:=-1;
  FDisColor:=RGBA(64,64,64,255);
  FSelectColor:=RGBA(0,128,255,230);
  FItems:=TList.Create;
end;

function TMenu.GetItems(I:Integer):TMenuItem;
begin
  Result:=FItems[I];
end;

function TMenu.GetItemsCount:Integer;
begin
  Result:=FItems.Count;
end;

function TMenu.ItemFromPoint(P:TVector):Integer;
var
  I:Integer;
  H:Real;
begin
  Result:=-1;
  H:=(wnd.Height-FontSize*2*ItemsCount)/2;
  I:=Trunc((P.Y-H)/(FontSize*2));
  if not((I>=0)and(I<FItems.Count)) then Exit;
  if ((P.X-wnd.Width/2)>-FLastML/2)and((P.X-wnd.Width/2)<FLastML/2) then
    Result:=I;
end;

procedure TMenu.Render;
const
  Ot:Real=50;
var
  I:Integer;
  MI:TMenuItem;
  H,L,ML:Real;
begin
  with wnd do
  begin
    //ogl.Clear(True,True); ogl.Set2D(0,0,wnd.Width,wnd.Height);
    H:=(Height-FontSize*2*ItemsCount)/2;
    ML:=-1;
    for I:=0 to ItemsCount-1 do
    begin
      MI:=FItems[I];
      L:=ogl.TextLen(FFont,PChar(MI.Name));

      if MI.Enabled then
      begin
        if Select=I then glColor4ubv(@FSelectColor) else
          glColor4ubv(@Items[I].Color);
      end else glColor4ubv(@Items[I].DisColor);
      ogl.TextOut(FFont,(Width-L)/2,H+I*FontSize*2,PChar(MI.Name));
      if ML<L then ML:=L;
    end;
    tex.Enable(FSelTex); ogl.Blend(BT_SUB); glColor4d(1,1,1,0.2);
    DrawRect((Width-ML-Ot)/2,(Height-FontSize*2*ItemsCount)/2+Select*FontSize*2,ML+Ot,FontSize*2);
    tex.Disable; FLastML:=ML+Ot;
  end;
  RenderMouse(FCursor);
end;

procedure TMenu.SetItems(I:Integer; const Value:TMenuItem);
begin
  FItems[I]:=Value;
end;

procedure TMenu.SetSelect(const Value:Integer);
begin
  if (Value=FSelect)or(Value<0)or(Value>=ItemsCount) then Exit;
  //if not Items[Value].Enabled then Exit; Блин как бы так по лучше сделать. 
  FSelect:=Value; Items[Value].Select;
end;

procedure TMenu.Update;
var
  I,F,MI:Integer;
begin
  UpdateMouse; MI:=ItemFromPoint(GetMousePos);
  if MI>=0 then
  begin
    if inp.Down(M_BTN_1) then
    begin
      Items[MI].Action; inp.Reset;
    end;
    if MouseMoved and Items[MI].Enabled then Select:=MI;
  end;
  if inp.Down(27) then if FOwner<>nil then ActivScene:=FOwner else eX.Quit;
  if inp.Down(VK_DOWN) then
  begin
    F:=Select;
    repeat
      if Select=ItemsCount-1 then Select:=0 else Select:=Select+1;
    until (Select=F)or Items[Select].Enabled;
  end;
  if inp.Down(VK_UP) then
  begin
    F:=Select;
    repeat
      if Select=0 then Select:=ItemsCount-1 else Select:=Select-1;
    until (Select=F)or Items[Select].Enabled;
  end;
  if inp.Down(VK_RETURN) then Items[Select].Action;
  inp.Reset;
end;

{ TMenuItem }

procedure TMenuItem.Action;
begin
  if Assigned(FOnAction)and FEnabled then FOnAction(Self);
end;

procedure TMenuItem.Select;
begin
  if Assigned(FOnSelect) then FOnSelect(Self);
end;

constructor TMenuItem.Create(AOwner:TMenu);
begin
  inherited Create;
  FOwner:=AOwner;
  FColor:=RGBA(255,128,0,255);
  FDisColor:=Owner.FDisColor;
  FOnAction:=nil; FOnSelect:=nil;
end;

end.

