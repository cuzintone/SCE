(*
        System Editor
        Version 1.00

        Copyright (C) AGE Software
        All rights reserved

        Purpose: Event Logger. A simple logging utility that logs to a file
        FILENAME: EVENTLOG.PAS

*)
unit EventLog;

interface

type
  TLogLevel = (elInfo, elWarning, elError);

  PEventLog = ^TEventLog;
  TEventLog = object
    LogAppend : Boolean;
    LogFile : Text;
    LogFileName : string;
    constructor Init(fn: string; _append : boolean);
    function LogLevelToStr(Level : TLogLevel) : string;
    procedure LogEvent ( Level : TLogLevel; EventMessage : string);
    function GetDateTimeStr : string;
    destructor Done;
  end;

implementation

uses Dos;

function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;

constructor TEventLog.Init(fn : string; _append :boolean);
begin
  LogFileName := fn;
  LogAppend := _append;
  Assign(LogFile, LogFileName);
  If LogAppend then
    begin
     {$I-}Append(LogFile); {$I+}
     If IOResult <> 0 then ReWrite(LogFile);
    end
  else
    ReWrite(LogFile);
end;

function TEventLog.GetDateTimeStr : string;
var
  y, m, d, h, min, sec, hund, dow : word;
  TempStr, S : string;

begin
  GetDate(y, m, d, dow);
  GetTime(h, min, sec, hund);
  Str(y,TempStr);
  S := TempStr+'/'+LeadingZero(m) + '/' + LeadingZero(d)+ ' '
    +LeadingZero(h) + ':' + LeadingZero(m) + ':' + LeadingZero(sec);

  GetDateTimeStr := S;
end;


function TEventLog.LogLevelToStr(Level : TLogLevel) : string;
begin
  case Level of
    elInfo : LogLevelToStr := '[INFO]';
    elWarning : LogLevelToStr := '[WARNING]';
    elError : LogLevelToStr := '[ERROR]';
  end;
end;

procedure TEventLog.LogEvent(Level : TLogLevel; EventMessage : string);
var
 LevelStr, DateTimeStr : String;

begin
  DateTimeStr := GetDateTimeStr;
  LevelStr := LogLevelToStr(Level);
  Writeln(LogFile, DateTimeStr, ' ',LevelStr,' - ',EventMessage);
end;

destructor TEventLog.Done;
begin
  Close(LogFile);
end;

end.