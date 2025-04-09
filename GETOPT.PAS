(*
        System Editor
        Version 1.00

        Copyright (C) AGE Software
        All rights reserved

        Purpose: GetOpt functionality to use -o and --option for the
                 command line
        FILENAME: GETOPT.PAS

*)

{$X+}
unit GetOpt;

interface

uses Objects;

type
  PGetOpt = ^TGetOpt;
  TGetOpt = object
    Args : PCollection;
    CurrentIndex : Integer;
    constructor Init;
    destructor Done; virtual;
    procedure AddArg( const S : String);
    function NextOption(var Opt, Value : string) : Boolean;
  end;

implementation

constructor TGetOpt.Init;
begin
  Args := New(PStringCollection, Init(10, 10));
  CurrentIndex := 0;
end;

procedure TGetOpt.AddArg(const S : String);
begin
  Args^.Insert(NewStr(S));
end;

function TGetOpt.NextOption(var Opt, Value : string) : Boolean;
var
  Arg : PString;
  EqPos : Integer;

begin
  Opt := '';
  Value := '';
  NextOption := false;
  while CurrentIndex < Args^.Count do
    begin
      Arg := Args^.At(CurrentIndex);
      if Arg = nil then Exit;

      if (Length(Arg^) > 1) and (Arg^[1] = '-') then
        begin
          if (Length(Arg^) > 2) and (Arg^[2] = '-') then
            begin
              EqPos := Pos('=', Arg^);
              if EqPos > 0 then
                begin
                  Opt := Copy(Arg^, 3, EqPos - 3);
                  Value := Copy(Arg^, EqPos + 1, Length(Arg^));
                end
              else
                Opt := Copy(Arg^, 3, Length(Arg^));
            end
          else
            begin
              Opt := Copy(Arg^, 2, Length(Arg^));
              if (CurrentIndex + 1 < Args^.Count) and
                (PString(Args^.At(CurrentIndex + 1))^[1] <> '-') then
                begin
                 Value := PString(Args^.At(CurrentIndex + 1))^;
                  Inc(CurrentIndex);
                end;
            end;

            Inc(CurrentIndex);
            NextOption := true;
            Exit;
        end;
        (* TODO: parsing MS-DOS style command lines with / will go here *)

        Inc(CurrentIndex);
    end;
end;

destructor TGetOpt.Done;
begin
  Dispose(Args, Done);
end;

end.
