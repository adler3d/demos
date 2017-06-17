//Статистика:
//QapNode = 1 шт.
//QapItem = 2 шт.
//VarScope_real = 1 шт.
//QapCmd = 1 шт.
//QapField = 3 шт.
//Simple_real = 1 шт.
//Заголовок функции
//public:
static void InitMassDetector(QapList*Owner,Phys2DGravityPoint*Plus)
//тут куча define'ов
#define MACRO_GEN_ITEM(OWNER,EX,TYPE)TYPE *EX=(TYPE*)Qap::T##TYPE->Init(OWNER);CurItem=EX;
#define PUSH_NODE()QapList *StackList=CurList; CurList=(QapList*)CurItem;
#define POP_NODE()CurList=StackList;
#define GEN_QapNode(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7){MACRO_GEN_ITEM(OWNER,EX,QapNode);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;};
#define GEN_QapItem(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5){MACRO_GEN_ITEM(OWNER,EX,QapItem);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;};
#define GEN_VarScope_real(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Arr*/PARAM_6,/*Begin*/PARAM_7,/*End*/PARAM_8,/*It*/PARAM_9,/*Buff*/PARAM_10){MACRO_GEN_ITEM(OWNER,EX,VarScope_real);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Arr=PARAM_6;EX->Begin=PARAM_7;EX->End=PARAM_8;EX->It=PARAM_9;EX->Buff=PARAM_10;};
#define GEN_QapCmd(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Cmd*/PARAM_6,/*Result*/PARAM_7,/*Op1*/PARAM_8,/*Op2*/PARAM_9){MACRO_GEN_ITEM(OWNER,EX,QapCmd);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Cmd=PARAM_6;EX->Result.SetSID(PARAM_7);EX->Op1.SetSID(PARAM_8);EX->Op2.SetSID(PARAM_9);};
#define GEN_QapField(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*FieldName*/PARAM_6,/*FieldType*/PARAM_7,/*Object*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,QapField);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->FieldName=PARAM_6;EX->FieldType=PARAM_7;EX->Object.SetSID(PARAM_8);};
#define GEN_Simple_real(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Buff*/PARAM_6){MACRO_GEN_ITEM(OWNER,EX,Simple_real);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Buff=PARAM_6;};
{
  IntArray Arr; QapList *Res,*CurList=Owner; QapItem *CurItem=NULL;
//тут куча GEN'ов
GEN_QapNode(/*Phys2D_Core*/CurList,"MassDetector",false,false,1,0,3,1);
Res=(QapList*)CurItem;
{
PUSH_NODE();
GEN_QapItem(/*MassDetector*/CurList,"ToolsBegin",false,false,2,0);
GEN_VarScope_real(/*MassDetector*/CurList,"Dest",false,false,3,0,Make_vector_real(2,1000,-300),0,10,0,1000);
GEN_QapCmd(/*MassDetector*/CurList,"QapCmd_3",false,true,4,0,"real=real*real",/*Dest_Buff*/0x00000007,/*Plus_mass*/0x00000006,/*mul1000_Buff*/0x00000005);
GEN_QapField(/*MassDetector*/CurList,"mul1000_Buff",false,false,5,0,"Buff","real",/*mul1000*/0x00000008);
GEN_QapField(/*MassDetector*/CurList,"Plus_mass",false,false,6,0,"mass","real",/*Plus*/0x00000000);
GEN_QapField(/*MassDetector*/CurList,"Dest_Buff",false,false,7,0,"Buff","real",/*Dest*/0x00000003);
GEN_Simple_real(/*MassDetector*/CurList,"mul1000",false,false,8,0,1e+006);
GEN_QapItem(/*MassDetector*/CurList,"ToolsEnd",false,false,9,0);
POP_NODE();
}
{
//тут код пост-загрузки
Arr.push_back((int)Plus);
Res->GrabID(Arr);
Res->RestoreLink(Arr);
}
}
#undef GEN_Simple_real
#undef GEN_QapField
#undef GEN_QapCmd
#undef GEN_VarScope_real
#undef GEN_QapItem
#undef GEN_QapNode
#undef POP_NODE
#undef PUSH_NODE
#undef MACRO_GEN_ITEM
//тут куча undef'ов
