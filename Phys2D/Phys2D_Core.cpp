//Статистика:
//Phys2D = 1 шт.
//GP_Color = 2 шт.
//Phys2DGravityPoint = 2 шт.
//Заголовок функции
//public:
static void InitPhys2D_Core(QapList*Owner)
//тут куча define'ов
#define MACRO_GEN_ITEM(OWNER,EX,TYPE)TYPE *EX=(TYPE*)Qap::T##TYPE->Init(OWNER);CurItem=EX;
#define PUSH_NODE()QapList *StackList=CurList; CurList=(QapList*)CurItem;
#define POP_NODE()CurList=StackList;
#define GEN_Phys2D(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*NeedMemoryAlign*/PARAM_8,/*Radius*/PARAM_9,/*Gravity*/PARAM_10){MACRO_GEN_ITEM(OWNER,EX,Phys2D);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->NeedMemoryAlign=PARAM_8;EX->Radius=PARAM_9;EX->Gravity=PARAM_10;};
#define GEN_GP_Color(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Color*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,GP_Color);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Color=PARAM_8;};
#define GEN_Phys2DGravityPoint(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*pos*/PARAM_8,/*mass*/PARAM_9,/*radius*/PARAM_10){MACRO_GEN_ITEM(OWNER,EX,Phys2DGravityPoint);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->pos=PARAM_8;EX->mass=PARAM_9;EX->radius=PARAM_10;};
{
  IntArray Arr; QapList *Res,*CurList=Owner; QapItem *CurItem=NULL;
//тут куча GEN'ов
GEN_Phys2D(/*PhysCam_18*/CurList,"Phys2D_Core",true,true,0,0,2,1,false,4,16);
Res=(QapList*)CurItem;
{
PUSH_NODE();
GEN_GP_Color(/*Phys2D_Core*/CurList,"Color",true,false,1,0,3,0,0xFF00FF00);
GEN_Phys2DGravityPoint(/*Phys2D_Core*/CurList,"Phys2DGravityPoint_0",true,true,2,0,0,0,vec2d(165.714,81.7143),-0.0003,16);
GEN_GP_Color(/*Phys2D_Core*/CurList,"Color_Clon(0)",true,false,3,0,3,0,0xFFFFFF00);
GEN_Phys2DGravityPoint(/*Phys2D_Core*/CurList,"Phys2DGravityPoint_0_Clon(0)",true,true,4,0,0,1,vec2d(137.714,-9.42857),0.001,32);
POP_NODE();
}
{
//тут код пост-загрузки
Res->GrabID(Arr);
Res->RestoreLink(Arr);
}
}
#undef GEN_Phys2DGravityPoint
#undef GEN_GP_Color
#undef GEN_Phys2D
#undef POP_NODE
#undef PUSH_NODE
#undef MACRO_GEN_ITEM
//тут куча undef'ов
