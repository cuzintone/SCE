unit HeapView;

interface

uses Objects, Views;

type
  PHeapView = ^THeapView;
  THeapView = object(TView)
    OldMem : LongInt;
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure Update;
  end;

implementation

uses Drivers;

{------ Heap Window object ----------}

constructor THeapView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  OldMem := 0;
end;

procedure THeapView.Draw;
var
  S: String;
  B: TDrawBuffer;
  C: Byte;
begin
  OldMem := MemAvail;
  Str(OldMem:Size.X, S);
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, S, C);
  WriteLine(0, 0, Size.X, 1, B);
end;


procedure THeapView.Update;
begin
  if (OldMem <> MemAvail) then DrawView;
end;
end.