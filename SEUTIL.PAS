unit SEUtil;

interface

function Trim(S: String) : String;
function LowerCase(S : String) : string;

implementation

function Trim(S: String) : String;
var
  i, startPos, endPos : integer;

begin
  startPos := 1;
  while (startPos <= Length(S)) and (S[startPos] = ' ') do
    Inc(startPos);

  endPos := Length(S);
  while (endPos >= startPos) and (S[endPos] = ' ') do
    Dec(endPos);

  Trim := Copy(S, startPos, endPos - startPos + 1);

end;

function LowerCase(S : String) : string;
var
  I : Integer;

begin
  for i := 1 to Length(S) do
    begin
      if (S[i] >= 'A') and (S[i]<= 'Z') then
        S[i] := chr(ord(S[i]) + 32);
    end;
  LowerCase := S;
end;

end.