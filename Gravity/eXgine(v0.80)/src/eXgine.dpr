library eXgine_dll;
//=====================================//
//  Created by XProger                 //
//  mail : XProger@list.ru             //
//  site : http://xproger.mirgames.ru  //
//=====================================//
uses
  Windows,
// ������� � �������� ����������
  sys_main, eXgine in '..\eXgine.pas',
  log, eng;

procedure Copyright;
begin
//  "eXgine" �� ���� �������� ����������� ��� ����� API
//  ����� ��� �� ������� ����� ��� ����, � ����� - ������� ���
// ����� ���������� ���������� � ��������� ���� ����� ����� ��������.
//
// ������ ���������. �������� ������� �� ������� ����� ����� � help.html
//
//  ������� ������ ��� ���������: ������ � �������������� ����� �� ��� ������
// ��� ����� ���� �����������, �� ��� ������� ���������� ����� ���������� ����� ;)
end;

procedure exInit(out Engine: IEngine; LogFile: PChar = nil; LogProc: TLogProc = nil);
begin
  if oeng = nil then
  begin
    olog := TLog.CreateEx;
    if (LogFile <> nil) or (@LogProc <> nil) then
      olog.Create(LogFile, LogProc);
    oeng := TEng.CreateEx;
    Engine := oeng;
  end;
end;

exports
  Copyright name #13#10#13#10'<<< ' + ENG_NAME + ' ' + ENG_VER + ' by XProger >>>'#13#10#13#10,
  exInit;

begin
end.
