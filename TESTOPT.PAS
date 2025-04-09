uses GetOpt;

var
  Parser : TGetOpt;
  Option, Value : String;
  I : Integer;

begin
  Parser.Init;
  for I := 1 to ParamCount do
    Parser.AddArg(ParamStr(I));
  writeln('Parsing command line arguments');
  while Parser.NextOption(Option, Value) do
    begin
      Writeln('Option: ', Option, ', Value: ', Value);
    end;
  Parser.Done;
  readln;

end.