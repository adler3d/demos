//Статистика:
//QapNode = 1 шт.
//GP_Point = 3 шт.
//QapItem = 3 шт.
//Заголовок функции
//public:
static void InitNode(QapList*Owner)
//тут куча define'ов
#define MACRO_GEN_ITEM(OWNER,EX,TYPE)TYPE *EX=(TYPE*)Qap::T##TYPE->Init(OWNER);CurItem=EX;
#define PUSH_NODE()QapList *StackList=CurList; CurList=(QapList*)CurItem;
#define POP_NODE()CurList=StackList;
#define GEN_QapNode(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7){MACRO_GEN_ITEM(OWNER,EX,QapNode);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;};
#define GEN_GP_Point(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*pos*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,GP_Point);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->pos=PARAM_8;};
#define GEN_QapItem(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5){MACRO_GEN_ITEM(OWNER,EX,QapItem);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;};
{
  IntArray Arr; QapList *Res,*CurList=Owner; QapItem *CurItem=NULL;
//тут куча GEN'ов
GEN_QapNode(/*Root*/CurList,"Node",true,true,0,0,6,1);
Res=(QapList*)CurItem;
{
PUSH_NODE();
GEN_GP_Point(/*Node*/CurList,"FirstPoint",true,true,1,0,1,0,vec2d(0,0));
GEN_GP_Point(/*Node*/CurList,"NextPoint",true,true,2,0,0,0,vec2d(0,0));
GEN_GP_Point(/*Node*/CurList,"LastPoint",true,true,3,0,0,0,vec2d(0,0));
GEN_QapItem(/*Node*/CurList,"SuperItem",true,true,4,0);
GEN_QapItem(/*Node*/CurList,"PuperItem",true,true,5,0);
GEN_QapItem(/*Node*/CurList,"TuperItem",true,true,6,0);
POP_NODE();
}
{
//тут код пост-загрузки
Res->GrabID(Arr);
Res->RestoreLink(Arr);
}
}
#undef GEN_QapItem
#undef GEN_GP_Point
#undef GEN_QapNode
#undef POP_NODE
#undef PUSH_NODE
#undef MACRO_GEN_ITEM
//тут куча undef'ов
