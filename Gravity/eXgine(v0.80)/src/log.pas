unit log;

interface

uses
  Windows, sys_main, eXgine;

type
  TLog = class(TInterface, ILog)
    constructor CreateEx;
    destructor Destroy; override;
   public
    function Create(FileName: PChar; LogProc: TLogProc = nil): Boolean;
    procedure Print(Text: PChar); 
    function Msg(Caption, Text: PChar; ID: Cardinal): Integer; 
    procedure TimeStamp(Active: Boolean);
    procedure ResetTimer;
    procedure Flush(Active: Boolean);
    procedure Free;
   private
    F          : LongWord;
    ForceStamp : Boolean; // Time Stamp
    ForceFlush : Boolean; // Active Flush
    Time       : Integer;
    LogProc    : TLogProc;
  end;

implementation

uses
  eng;

constructor TLog.CreateEx;
begin
  inherited CreateEx;
  F := NULL_FILE;
  ForceStamp := True;
  ForceFlush := False;
end;

destructor TLog.Destroy;
begin
  Print('"' + ENG_NAME + ' ' + ENG_VER + '" log close');
  Free;
  inherited;
end;
 
function TLog.Create(FileName: PChar; LogProc: TLogProc): Boolean;
begin
  Free;
  if @LogProc <> nil then
    Self.LogProc := LogProc;
  F := FileOpen(FileName, True);
  Result := FileValid(F);
  Time := GetTime;
  Print('"' + ENG_NAME + ' ' + ENG_VER + '" log start');
end;

procedure TLog.Print(Text: PChar);
var
  str : string;
  i   : Integer;
begin
  if (FileValid(F)) or (@LogProc <> nil) then
  begin
    if ForceStamp then
    begin
    // тайминг с предыдущего вызова Print
      i    := GetTime;
      str  := IntToStr(i - Time);
      Time := i;
      for i := 0 to 6 - Length(str) do
        str := '-' + str;
      str := '[' + str + '] ' + Text + #13#10
    end else
      str := Text + #13#10;

    if FileValid(F) then
    begin
      FileWrite(F, str[1], Length(str));
      if ForceFlush then
        FileFlush(F);
    end;

    if @LogProc <> nil then
      LogProc(PChar(str));
  end;
end;

function TLog.Msg(Caption, Text: PChar; ID: Cardinal): Integer; 
begin
  Result := MessageBox(0, Text, Caption, ID);
end;

procedure TLog.TimeStamp(Active: Boolean);
begin
  ForceStamp := Active;
end;

procedure TLog.ResetTimer;
begin
  Time := GetTime;
end;

procedure TLog.Flush(Active: Boolean);
begin
  ForceFlush := Active;
end;

procedure TLog.Free;
begin
  if FileValid(F) then
    FileClose(F);
end;

end.
