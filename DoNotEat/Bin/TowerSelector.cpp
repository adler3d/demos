//Статистика:
//TD_TowerSelector = 1 шт.
//TD_GridNode = 1 шт.
//TD_TowerUpdater = 1 шт.
//QapNode = 11 шт.
//QapMethod = 2 шт.
//QapField = 22 шт.
//PhysKeyVisor = 2 шт.
//QapCmd = 6 шт.
//GP_Color = 2 шт.
//TD_GridPos = 2 шт.
//PhysCam = 1 шт.
//GP_TextureQuad = 2 шт.
//InternalNode = 1 шт.
//Simple_real = 5 шт.
//TD_CirclZoom = 1 шт.
//QapItem = 4 шт.
//RedirectItem = 1 шт.
//GMultiFields = 2 шт.
//LastKeyItem = 1 шт.
//Заголовок функции
//public:
static void InitTowerSelector(QapList*Owner,GP_Point*LocalMousePos,TD_GridNode*Towers,TD_Tower*TD_Tower(1911),QapTexFile*SelectRectTex,QapTexFile*CircleTex)
//тут куча define'ов
#define MACRO_GEN_ITEM(OWNER,EX,TYPE)TYPE *EX=(TYPE*)Qap::T##TYPE->Init(OWNER);CurItem=EX;
#define PUSH_NODE()QapList *StackList=CurList; CurList=(QapList*)CurItem;
#define POP_NODE()CurList=StackList;
#define GEN_TD_TowerSelector(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Radius*/PARAM_8,/*LocalPoint*/PARAM_9,/*Towers*/PARAM_10,/*Select*/PARAM_11,/*OutPos*/PARAM_12){MACRO_GEN_ITEM(OWNER,EX,TD_TowerSelector);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Radius=PARAM_8;EX->LocalPoint.SetSID(PARAM_9);EX->Towers.SetSID(PARAM_10);EX->Select.SetSID(PARAM_11);EX->OutPos.SetSID(PARAM_12);};
#define GEN_TD_GridNode(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7){MACRO_GEN_ITEM(OWNER,EX,TD_GridNode);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;};
#define GEN_TD_TowerUpdater(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Tower*/PARAM_8,/*OnNotMoney*/PARAM_9,/*OnNotAllow*/PARAM_10,/*OnDone*/PARAM_11){MACRO_GEN_ITEM(OWNER,EX,TD_TowerUpdater);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Tower.SetSID(PARAM_8);EX->OnNotMoney.SetSID(PARAM_9);EX->OnNotAllow.SetSID(PARAM_10);EX->OnDone.SetSID(PARAM_11);};
#define GEN_QapNode(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7){MACRO_GEN_ITEM(OWNER,EX,QapNode);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;};
#define GEN_QapMethod(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*MethodName*/PARAM_6,/*Object*/PARAM_7){MACRO_GEN_ITEM(OWNER,EX,QapMethod);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->MethodName=PARAM_6;EX->Object.SetSID(PARAM_7);};
#define GEN_QapField(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*FieldName*/PARAM_6,/*FieldType*/PARAM_7,/*Object*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,QapField);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->FieldName=PARAM_6;EX->FieldType=PARAM_7;EX->Object.SetSID(PARAM_8);};
#define GEN_PhysKeyVisor(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Key*/PARAM_6,/*Down*/PARAM_7,/*OnUp*/PARAM_8,/*OnMove*/PARAM_9,/*OnDown*/PARAM_10){MACRO_GEN_ITEM(OWNER,EX,PhysKeyVisor);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Key=PARAM_6;EX->Down=PARAM_7;EX->OnUp.SetSID(PARAM_8);EX->OnMove.SetSID(PARAM_9);EX->OnDown.SetSID(PARAM_10);};
#define GEN_QapCmd(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Cmd*/PARAM_6,/*Result*/PARAM_7,/*Op1*/PARAM_8,/*Op2*/PARAM_9){MACRO_GEN_ITEM(OWNER,EX,QapCmd);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Cmd=PARAM_6;EX->Result.SetSID(PARAM_7);EX->Op1.SetSID(PARAM_8);EX->Op2.SetSID(PARAM_9);};
#define GEN_GP_Color(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Color*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,GP_Color);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Color=PARAM_8;};
#define GEN_TD_GridPos(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Debug*/PARAM_8,/*Pos*/PARAM_9){MACRO_GEN_ITEM(OWNER,EX,TD_GridPos);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Debug=PARAM_8;EX->Pos=PARAM_9;};
#define GEN_PhysCam(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*pos*/PARAM_8,/*angle*/PARAM_9,/*zoom*/PARAM_10,/*debug*/PARAM_11,/*xf*/PARAM_12){MACRO_GEN_ITEM(OWNER,EX,PhysCam);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->pos=PARAM_8;EX->angle=PARAM_9;EX->zoom=PARAM_10;EX->debug=PARAM_11;EX->xf=PARAM_12;};
#define GEN_GP_TextureQuad(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Source*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,GP_TextureQuad);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Source.SetSID(PARAM_8);};
#define GEN_InternalNode(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Debug*/PARAM_8){MACRO_GEN_ITEM(OWNER,EX,InternalNode);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Debug=PARAM_8;};
#define GEN_Simple_real(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Buff*/PARAM_6){MACRO_GEN_ITEM(OWNER,EX,Simple_real);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Buff=PARAM_6;};
#define GEN_TD_CirclZoom(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*AddCount*/PARAM_6,/*ListBits*/PARAM_7,/*Debug*/PARAM_8,/*Zoom*/PARAM_9,/*AutoZoom*/PARAM_10,/*Select*/PARAM_11,/*CircleTex*/PARAM_12){MACRO_GEN_ITEM(OWNER,EX,TD_CirclZoom);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->AddCount=PARAM_6;EX->ListBits=PARAM_7;EX->Debug=PARAM_8;EX->Zoom=PARAM_9;EX->AutoZoom=PARAM_10;EX->Select.SetSID(PARAM_11);EX->CircleTex.SetSID(PARAM_12);};
#define GEN_QapItem(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5){MACRO_GEN_ITEM(OWNER,EX,QapItem);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;};
#define GEN_RedirectItem(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Target*/PARAM_6){MACRO_GEN_ITEM(OWNER,EX,RedirectItem);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Target.SetSID(PARAM_6);};
#define GEN_GMultiFields(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*Source*/PARAM_6,/*Node*/PARAM_7){MACRO_GEN_ITEM(OWNER,EX,GMultiFields);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->Source.SetSID(PARAM_6);EX->Node.SetSID(PARAM_7);};
#define GEN_LastKeyItem(OWNER,/*Caption*/PARAM_1,/*Visible*/PARAM_2,/*Moved*/PARAM_3,/*SaveID*/PARAM_4,/*Tag*/PARAM_5,/*LastKey*/PARAM_6){MACRO_GEN_ITEM(OWNER,EX,LastKeyItem);EX->Caption=PARAM_1;EX->Visible=PARAM_2;EX->Moved=PARAM_3;EX->SaveID=PARAM_4;EX->Tag=PARAM_5;EX->LastKey=PARAM_6;};
{
  IntArray Arr;
  QapList *Res,*CurList=Owner;
  QapItem *CurItem=NULL;
//тут куча GEN'ов
  GEN_TD_TowerSelector(/*FirstUser*/CurList,"TowerSelector",true,true,5,0,2,1,16,/*LocalMousePos*/0x00000000,/*Towers*/0x00000001,NULL_ID,/*TD_GridPos_2*/0x00000010);
  Res=(QapList*)CurItem;
  {
    PUSH_NODE();
    GEN_TD_GridNode(/*TowerSelector*/CurList,"TowerUpgradeScript",false,true,6,0,1,0);
    {
      PUSH_NODE();
      GEN_TD_TowerUpdater(/*TowerUpgradeScript*/CurList,"TowUpgrad",false,true,7,0,1,1,/*TD_Tower(1911)*/0x00000002,NULL_ID,NULL_ID,NULL_ID);
      {
        PUSH_NODE();
        GEN_QapNode(/*TowUpgrad*/CurList,"Protected",false,false,8,0,9,1);
        {
          PUSH_NODE();
          GEN_QapMethod(/*Protected*/CurList,"TowUpgrad_TryUpdate",false,false,9,0,"TryUpdate",/*TowUpgrad*/0x00000007);
          GEN_QapField(/*Protected*/CurList,"TowUpgrad_Tower",false,false,10,0,"Tower","QapPtr",/*TowUpgrad*/0x00000007);
          POP_NODE();
        }
        POP_NODE();
      }
      POP_NODE();
    }
    GEN_PhysKeyVisor(/*TowerSelector*/CurList,"KeyVisot_Upgrade",true,true,11,0,85,false,NULL_ID,NULL_ID,/*TowUpgrad_TryUpdate*/0x00000009);
    GEN_PhysKeyVisor(/*TowerSelector*/CurList,"LMB_Visor",true,true,12,0,257,false,NULL_ID,NULL_ID,/*DoOnDown*/0x00000038);
    GEN_QapCmd(/*TowerSelector*/CurList,"CmdEX_SelectScript",false,true,13,0,"bool=QapPtr",/*LastKey_Moved*/0x00000043,/*TowerSelector_Select*/0x00000044,NULL_ID);
    GEN_QapCmd(/*TowerSelector*/CurList,"CmdEX_SelectCircle",false,true,14,0,"bool=QapPtr",/*LongSelect_Visible*/0x00000042,/*CircleZoom_Select*/0x0000003B,NULL_ID);
    GEN_GP_Color(/*TowerSelector*/CurList,"GP_Color_0",false,true,15,0,3,0,0xFFFFFF00);
    {
      PUSH_NODE();
      GEN_TD_GridPos(/*GP_Color_0*/CurList,"TD_GridPos_2",true,true,16,0,1,1,false,vec2d(1776,-944));
      {
        PUSH_NODE();
        GEN_PhysCam(/*TD_GridPos_2*/CurList,"ZoomCam",true,true,17,0,3,1,vec2d(0,0),0,0.799855,false,b2Transform(vec2d(0,0),b2Mat22(0)));
        {
          PUSH_NODE();
          GEN_GP_TextureQuad(/*ZoomCam*/CurList,"GP_TextureQuad_3",true,false,18,0,4,1,/*SelectRectTex*/0x00000003);
          POP_NODE();
        }
        POP_NODE();
      }
      GEN_InternalNode(/*GP_Color_0*/CurList,"IRotator",false,true,19,0,4,0,false);
      {
        PUSH_NODE();
        GEN_QapNode(/*IRotator*/CurList,"SysFields",false,false,20,0,8,1);
        {
          PUSH_NODE();
          GEN_QapField(/*SysFields*/CurList,"IRotator_Caption",true,true,21,0,"Caption","string",/*IRotator*/0x00000013);
          GEN_QapField(/*SysFields*/CurList,"IRotator_Visible",true,true,22,0,"Visible","bool",/*IRotator*/0x00000013);
          GEN_QapField(/*SysFields*/CurList,"IRotator_Moved",true,true,23,0,"Moved","bool",/*IRotator*/0x00000013);
          GEN_QapField(/*SysFields*/CurList,"IRotator_SaveID",true,true,24,0,"SaveID","int",/*IRotator*/0x00000013);
          GEN_QapField(/*SysFields*/CurList,"IRotator_Tag",true,true,25,0,"Tag","int",/*IRotator*/0x00000013);
          GEN_QapField(/*SysFields*/CurList,"IRotator_AddCount",true,true,26,0,"AddCount","int",/*IRotator*/0x00000013);
          GEN_QapField(/*SysFields*/CurList,"IRotator_ListBits",true,true,27,0,"ListBits","int",/*IRotator*/0x00000013);
          GEN_QapField(/*SysFields*/CurList,"IRotator_Debug",true,true,28,0,"Debug","bool",/*IRotator*/0x00000013);
          GEN_QapField(/*SysFields*/CurList,"dValue",true,true,29,0,"Buff","real",/*DynVal*/0x00000022);
          POP_NODE();
        }
        GEN_QapNode(/*IRotator*/CurList,"SysMethods",false,false,30,0,1,1);
        {
          PUSH_NODE();
          GEN_QapMethod(/*SysMethods*/CurList,"IRotator_SysRelay",true,true,31,0,"SysRelay",/*IRotator*/0x00000013);
          POP_NODE();
        }
        GEN_QapNode(/*IRotator*/CurList,"SysInternal",false,true,32,0,4,1);
        {
          PUSH_NODE();
          GEN_QapNode(/*SysInternal*/CurList,"Protected",false,false,33,0,0,1);
          GEN_Simple_real(/*SysInternal*/CurList,"DynVal",false,false,34,0,0.05);
          GEN_QapCmd(/*SysInternal*/CurList,"QapCmd_0",false,true,35,0,"",NULL_ID,NULL_ID,NULL_ID);
          GEN_QapCmd(/*SysInternal*/CurList,"QapCmd_3",false,true,36,0,"real+=real",/*Angle_Buff*/0x00000026,/*dValue*/0x0000001D,NULL_ID);
          POP_NODE();
        }
        GEN_QapNode(/*IRotator*/CurList,"SysItems",true,true,37,0,5,1);
        {
          PUSH_NODE();
          GEN_QapField(/*SysItems*/CurList,"Angle_Buff",false,false,38,0,"Buff","real",/*Angle*/0x00000027);
          GEN_Simple_real(/*SysItems*/CurList,"Angle",false,false,39,0,160355);
          GEN_Simple_real(/*SysItems*/CurList,"tmp",false,false,40,0,0.099855);
          GEN_QapField(/*SysItems*/CurList,"tmp_Buff",false,false,41,0,"Buff","real",/*tmp*/0x00000028);
          GEN_QapField(/*SysItems*/CurList,"ZoomCam_zoom",false,false,42,0,"zoom","real",/*ZoomCam*/0x00000011);
          GEN_Simple_real(/*SysItems*/CurList,"NormZoom",false,false,43,0,0.7);
          GEN_QapField(/*SysItems*/CurList,"NormZoom_Buff",false,false,44,0,"Buff","real",/*NormZoom*/0x0000002B);
          GEN_Simple_real(/*SysItems*/CurList,"dZ",false,false,45,0,0.1);
          GEN_QapField(/*SysItems*/CurList,"dZ_Buff",false,false,46,0,"Buff","real",/*dZ*/0x0000002D);
          POP_NODE();
        }
        POP_NODE();
      }
      GEN_QapCmd(/*GP_Color_0*/CurList,"SinCalc",true,true,47,0,"real=real*sin(real)",/*tmp_Buff*/0x00000029,/*dZ_Buff*/0x0000002E,/*Angle_Buff*/0x00000026);
      GEN_QapCmd(/*GP_Color_0*/CurList,"SetZoom",true,true,48,0,"real=real+real",/*ZoomCam_zoom*/0x0000002A,/*NormZoom_Buff*/0x0000002C,/*tmp_Buff*/0x00000029);
      POP_NODE();
    }
    GEN_TD_GridPos(/*TowerSelector*/CurList,"LongSelect",true,true,49,0,1,1,false,vec2d(1776,-944));
    {
      PUSH_NODE();
      GEN_GP_Color(/*LongSelect*/CurList,"GP_Color_1",true,true,50,0,1,1,0x3FFFFFA8);
      {
        PUSH_NODE();
        GEN_TD_CirclZoom(/*GP_Color_1*/CurList,"CircleZoom",true,true,51,0,0,1,true,1.5,true,/*TD_Tower(1911)*/0x00000002,/*CircleTex*/0x00000004);
        {
          PUSH_NODE();
          GEN_GP_TextureQuad(/*CircleZoom*/CurList,"GP_TQ_CircleTex",true,false,52,0,1,1,/*CircleTex*/0x00000004);
          POP_NODE();
        }
        POP_NODE();
      }
      POP_NODE();
    }
    GEN_QapNode(/*TowerSelector*/CurList,"Protected",false,false,53,0,8,1);
    {
      PUSH_NODE();
      GEN_QapItem(/*Protected*/CurList,"QapItem_0",true,true,54,0);
      GEN_QapItem(/*Protected*/CurList,"QapItem_1",true,true,55,0);
      GEN_RedirectItem(/*Protected*/CurList,"DoOnDown",false,false,56,0,/*OnDown*/0x00000039);
      GEN_QapNode(/*Protected*/CurList,"OnDown",false,true,57,0,2,1);
      {
        PUSH_NODE();
        GEN_QapNode(/*OnDown*/CurList,"CopySelect",true,true,58,0,1,1);
        {
          PUSH_NODE();
          GEN_QapField(/*CopySelect*/CurList,"CircleZoom_Select",false,false,59,0,"Select","QapPtr",/*CircleZoom*/0x00000033);
          GEN_QapField(/*CopySelect*/CurList,"TowUpgrad_Tower",false,false,60,0,"Tower","QapPtr",/*TowUpgrad*/0x00000007);
          GEN_GMultiFields(/*CopySelect*/CurList,"COPY",false,true,61,0,/*TowerSelector_Select*/0x00000044,/*CopySelect*/0x0000003A);
          POP_NODE();
        }
        GEN_QapNode(/*OnDown*/CurList,"CopyPos",true,true,62,0,0,1);
        {
          PUSH_NODE();
          GEN_QapField(/*CopyPos*/CurList,"LongSelect_Pos",true,true,63,0,"Pos","vec2d",/*LongSelect*/0x00000031);
          GEN_GMultiFields(/*CopyPos*/CurList,"COPY",false,true,64,0,/*TD_GridPos_2_Pos*/0x00000045,/*CopyPos*/0x0000003E);
          POP_NODE();
        }
        POP_NODE();
      }
      GEN_QapNode(/*Protected*/CurList,"QapNode_6",true,true,65,0,1,1);
      {
        PUSH_NODE();
        GEN_QapField(/*QapNode_6*/CurList,"LongSelect_Visible",false,false,66,0,"Visible","bool",/*LongSelect*/0x00000031);
        GEN_QapField(/*QapNode_6*/CurList,"LastKey_Moved",false,false,67,0,"Visible","bool",/*GP_Color_0*/0x0000000F);
        GEN_QapField(/*QapNode_6*/CurList,"TowerSelector_Select",false,false,68,0,"Select","QapPtr",/*TowerSelector*/0x00000005);
        GEN_QapField(/*QapNode_6*/CurList,"TD_GridPos_2_Pos",false,false,69,0,"Pos","vec2d",/*TD_GridPos_2*/0x00000010);
        POP_NODE();
      }
      GEN_QapItem(/*Protected*/CurList,"QapItem_4",true,true,70,0);
      GEN_QapItem(/*Protected*/CurList,"QapItem_5",true,true,71,0);
      POP_NODE();
    }
    GEN_LastKeyItem(/*TowerSelector*/CurList,"LastKey",true,false,72,0,17);
    POP_NODE();
  }
  {
//тут код пост-загрузки
    Arr.push_back((int)LocalMousePos);
    Arr.push_back((int)Towers);
    Arr.push_back((int)TD_Tower(1911));
    Arr.push_back((int)SelectRectTex);
    Arr.push_back((int)CircleTex);
    Res->GrabID(Arr);
    Res->RestoreLink(Arr);
  }
}
#undef GEN_LastKeyItem
#undef GEN_GMultiFields
#undef GEN_RedirectItem
#undef GEN_QapItem
#undef GEN_TD_CirclZoom
#undef GEN_Simple_real
#undef GEN_InternalNode
#undef GEN_GP_TextureQuad
#undef GEN_PhysCam
#undef GEN_TD_GridPos
#undef GEN_GP_Color
#undef GEN_QapCmd
#undef GEN_PhysKeyVisor
#undef GEN_QapField
#undef GEN_QapMethod
#undef GEN_QapNode
#undef GEN_TD_TowerUpdater
#undef GEN_TD_GridNode
#undef GEN_TD_TowerSelector
#undef POP_NODE
#undef PUSH_NODE
#undef MACRO_GEN_ITEM
//тут куча undef'ов
