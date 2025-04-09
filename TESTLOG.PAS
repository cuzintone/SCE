uses EventLog, Crt;

var
  Logger : PEventLog;

begin
  Logger := New(PEventLog, Init('eventlog.txt', false));

  with Logger^ do
    begin
      LogEvent(elInfo, 'Application started');
      Writeln('Logging events with levels ...');
      Delay(1000);
      LogEvent(elWarning,' Low memory warning');
      Delay(1000);
      LogEvent(elError, 'Unhandled exception occured');
      Delay(1000);
      LogEvent(elInfo,'Application Terminated');
    end;
    Writeln('Events logged to ',Logger^.LogFileName);
    Dispose(Logger, Done);
    Readln;
end.