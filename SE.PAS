(*
        System Editor
        Version 1.00

        Copyright (C) AGE Software
        All rights reserved

        Purpose: Full screen system editor.
        FILENAME: SE.PAS

*)
{$M 8192,8192,655360}
{$X+,S-}


uses Dos, seui, seconst, Strings, Drivers, GetOpt;

var
  Parser : PGetOpt;
  Option, Value, S : String;
  Editor     : TSysEdit;
  Mono, BW   :  Boolean;
  i          : byte;
  progname   : string[8];
  P          : Pchar;

function UpCaseStr(S : String) : String;
var
  I : Integer;

begin
  for I := 1 to Length(s) do
    S[I] := UpCase(S[I]);
  UpCaseStr := S;
end;

procedure Usage;
var
  S : String;

begin
  FormatStr(S, sBanner, VERSION);
  PrintStr(S);
  PrintStr(#9+Copy(RCSRev,2,(Length(RCSRev) - 2)));
  PrintStr(#13#10#13#10'Editor for system configuration files'#13#10#13#10);
  PrintStr(progname+' [/B] [/BW] [/M] [/?]'#13#10#13#10);
  PrintStr('  -b   - turns off the auto backup feature'#13#10);
  PrintStr('  -bw  - show in black and white on a color monitor'#13#10);
  PrintStr('  -m   - force monochrome mode'#13#10);
  PrintStr('  -h   - displays this help screen'#13#10);
end;

function GetProgName(S : String) : string;
var
  D : DirStr;
  N : NameStr;
  E : ExtStr;
begin
  FSplit(S, D, N, E);
  GetProgName := N;
end;


{ Main execution portion }
begin
(*
  Let's make the following assumptions -
     1. You can't directly write to video memory
     2. We are using a color video adapter
     3. We are in color mode
*)
  FormatStr(S, sBanner, VERSION);
  PrintStr(S);
  PrintStr(#9+Copy(RCSRev,2,(Length(RCSRev) - 2))+#13#10);
  Mono := false;
  BW := False;

  if Lo(DosVersion) < 3 then begin
    PrintStr('System Config Editor requires DOS 3.0 or higher'#13#10);
    halt(255);
  end;

  if paramstr(0) <> '' then
    progname := GetProgName(paramstr(0));
  if paramcount > 0 then
    begin
       Parser := New(PGetOpt, Init);
       for I := 1 to ParamCount do
         Parser^.AddArg(ParamStr(I));
       while Parser^.NextOption(Option, Value) do
        begin
          Option := UpCaseStr(Option);
          if (Option = 'H') or (Option = 'HELP') then
            begin
              Usage;
              exit;
            end;
          if Option = 'B' then
            begin
              Writeln(#9' * No Backup Files');
              Editor.ToggleBackupFiles;
            end;
          if Option = 'BW' then
            begin
              Writeln(#9' * Black and White Mode');
              BW := True;
            end;
          if Option = 'M' then
            begin
              Writeln(#9' * Monochrome Mode');
              Mono := True;
            end;
        end;
        Dispose(Parser, Done);
    end;

  Editor.Init(Mono, BW);
  Editor.Run;
  Editor.Done;
end.
