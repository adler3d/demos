//Статистика:
//GP_Point = 1 шт.
//QapNode = 7 шт.
//QapItem = 18 шт.
//VarScope_string = 1 шт.
//Заголовок функции
//public:
static void InitLastPoint(QapList*Owner)
  //тут куча define'ов
#define MACRO_GEN_ITEM(OWNER,EX,TYPE)TYPE *EX=(TYPE*)Qap::T##TYPE->Init(OWNER);CurItem=EX;
#define PUSH_NODE()QapList *StackList=CurList; CurList=(QapList*)CurItem;
#define POP_NODE()CurList=StackList;
#define GEN_GP_Point(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*pos*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,GP_Point);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->pos=PARAM_8;};
#define GEN_QapNode(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7){MACRO_GEN_ITEM(OWNER,EX,QapNode);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;};
#define GEN_QapItem(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5){MACRO_GEN_ITEM(OWNER,EX,QapItem);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;};
#define GEN_VarScope_string(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Arr*/PARAM_6,/*Begin*/PARAM_7,/*End*/PARAM_8,/*It*/PARAM_9,/*Buff*/PARAM_10){MACRO_GEN_ITEM(OWNER,EX,VarScope_string);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Arr=PARAM_6;EX->Begin=PARAM_7;EX->End=PARAM_8;EX->It=PARAM_9;EX->Buff=PARAM_10;};
{
  IntArray Arr; QapList *Res,*CurList=Owner; QapItem *CurItem=NULL;
  //тут куча GEN'ов
  GEN_GP_Point(/*Node*/CurList,"LastPoint",true,true,0,0,21,1,vec2d(0,0));
  Res=(QapList*)CurItem;
  {
    PUSH_NODE();
    GEN_QapNode(/*LastPoint*/CurList,"QapNode_20",true,true,1,0,0,1);
    {
      PUSH_NODE();
      GEN_QapItem(/*QapNode_20*/CurList,"QapItem_19",true,true,2,0);
      GEN_QapItem(/*QapNode_20*/CurList,"QapItem_7",true,true,3,0);
      GEN_QapNode(/*QapNode_20*/CurList,"QapNode_15",true,true,4,0,3,1);
      {
        PUSH_NODE();
        GEN_QapNode(/*QapNode_15*/CurList,"QapNode_17",true,true,5,0,0,1);
        {
          PUSH_NODE();
          GEN_QapItem(/*QapNode_17*/CurList,"QapItem_9",true,true,6,0);
          GEN_QapItem(/*QapNode_17*/CurList,"QapItem_12",true,true,7,0);
          POP_NODE();
        }
        GEN_QapItem(/*QapNode_15*/CurList,"QapItem_8",true,true,8,0);
        GEN_QapNode(/*QapNode_15*/CurList,"QapNode_0",true,true,9,0,3,1);
        {
          PUSH_NODE();
          GEN_QapNode(/*QapNode_0*/CurList,"QapNode_1",true,true,10,0,0,1);
          {
            PUSH_NODE();
            GEN_QapItem(/*QapNode_1*/CurList,"QapItem_14",true,true,11,0);
            GEN_QapItem(/*QapNode_1*/CurList,"QapItem_6",true,true,12,0);
            POP_NODE();
          }
          GEN_QapItem(/*QapNode_0*/CurList,"QapItem_11",true,true,13,0);
          GEN_QapItem(/*QapNode_0*/CurList,"QapItem_0",true,true,14,0);
          GEN_QapItem(/*QapNode_0*/CurList,"QapItem_1",true,true,15,0);
          GEN_QapItem(/*QapNode_0*/CurList,"QapItem_2",true,true,16,0);
          POP_NODE();
        }
        GEN_QapNode(/*QapNode_15*/CurList,"QapNode_2",true,true,17,0,1,1);
        {
          PUSH_NODE();
          GEN_VarScope_string(/*QapNode_2*/CurList,
            "VarScope_string_0",
            true,
            true,
            18,
            0,
            Make_vector_string(
              4,
              "SomeShit_Value",
              "Another text",
              "cool stroy bro",
              "I'm robot"
            ),
            -1,
            134217727,
            0,
            ""
          );
          POP_NODE();
        }
        GEN_QapItem(/*QapNode_15*/CurList,"QapItem_18",true,true,19,0);
        POP_NODE();
      }
      GEN_QapNode(/*QapNode_20*/CurList,"QapNode_16",true,true,20,0,0,1);
      {
        PUSH_NODE();
        GEN_QapItem(/*QapNode_16*/CurList,"QapItem_2",true,true,21,0);
        GEN_QapItem(/*QapNode_16*/CurList,"QapItem_13",true,true,22,0);
        GEN_QapItem(/*QapNode_16*/CurList,"QapItem_10",true,true,23,0);
        GEN_QapItem(/*QapNode_16*/CurList,"QapItem_5",true,true,24,0);
        POP_NODE();
      }
      GEN_QapItem(/*QapNode_20*/CurList,"QapItem_4",true,true,25,0);
      GEN_QapItem(/*QapNode_20*/CurList,"QapItem_3",true,true,26,0);
      POP_NODE();
    }
    POP_NODE();
  }
  {
    //тут код пост-загрузки
    Res->GrabID(Arr);
    Res->RestoreLink(Arr);
  }
}
#undef GEN_VarScope_string
#undef GEN_QapItem
#undef GEN_QapNode
#undef GEN_GP_Point
#undef POP_NODE
#undef PUSH_NODE
#undef MACRO_GEN_ITEM
//тут куча undef'ов
