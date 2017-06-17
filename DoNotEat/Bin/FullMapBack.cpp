//Статистика:
//PhysCam = 1 шт.
//GP_Color = 1 шт.
//GP_TextureQuad = 2 шт.
//Заголовок функции
//public:
static void InitFullMapBack(QapList*Owner,QapTexFile*background(v8),QapTexFile*BallTex)
//тут куча define'ов
#define MACRO_GEN_ITEM(OWNER,EX,TYPE)TYPE *EX=(TYPE*)Qap::T##TYPE->Init(OWNER);CurItem=EX;
#define PUSH_NODE()QapList *StackList=CurList; CurList=(QapList*)CurItem;
#define POP_NODE()CurList=StackList;
#define GEN_PhysCam(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*pos*/PARAM_8,/*angle*/PARAM_9,/*zoom*/PARAM_10,/*debug*/PARAM_11,/*xf*/PARAM_12){MACRO_GEN_ITEM(OWNER,EX,PhysCam);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->pos=PARAM_8;EX->angle=PARAM_9;EX->zoom=PARAM_10;EX->debug=PARAM_11;EX->xf=PARAM_12;};
#define GEN_GP_Color(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Color*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,GP_Color);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Color=PARAM_8;};
#define GEN_GP_TextureQuad(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Source*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,GP_TextureQuad);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Source.SetSID(PARAM_8);};
{
  IntArray Arr; QapList *Res,*CurList=Owner; QapItem *CurItem=NULL;
//тут куча GEN'ов
GEN_PhysCam(/*PhysCam_2*/CurList,"FullMapBack",true,false,2,0,3,1,vec2d(256,-256),0,4,false,b2Transform(vec2d(1023,-1024),b2Mat22(0)));
Res=(QapList*)CurItem;
{
PUSH_NODE();
GEN_GP_Color(/*FullMapBack*/CurList,"GP_Color_0",true,true,3,0,0,0,0xFFFFFFFF);
GEN_GP_TextureQuad(/*FullMapBack*/CurList,"GP_TQ_background(v8)",true,true,4,0,0,0,/*background(v8)*/0x00000000);
GEN_GP_TextureQuad(/*FullMapBack*/CurList,"GP_TQ_BallTex",false,false,5,0,0,0,/*BallTex*/0x00000001);
POP_NODE();
}
{
//тут код пост-загрузки
Arr.push_back((int)background(v8));
Arr.push_back((int)BallTex);
Res->GrabID(Arr);
Res->RestoreLink(Arr);
}
}
#undef GEN_GP_TextureQuad
#undef GEN_GP_Color
#undef GEN_PhysCam
#undef POP_NODE
#undef PUSH_NODE
#undef MACRO_GEN_ITEM
//тут куча undef'ов
