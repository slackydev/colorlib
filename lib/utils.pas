unit Utils;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2014, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
{$mode objfpc}{$H+}
{$macro on}
{$inline on}
interface
uses 
  Header;

function GetRawMatrix(src:PInt32; x1,y1,x2,y2:Int32; W,H:Int32): TIntMatrix;
function Where(Matrix:TBoolMatrix): TPointArray;

function MatrixLT(Matrix: TSingleMatrix; value: Single): TBoolMatrix;
function MatrixGT(Matrix: TSingleMatrix; value: Single): TBoolMatrix;
function MatrixEQ(Matrix: TSingleMatrix; value: Single): TBoolMatrix;
function MatrixNE(Matrix: TSingleMatrix; value: Single): TBoolMatrix;

function MatrixLT(value: Single; Matrix: TSingleMatrix): TBoolMatrix;
function MatrixGT(value: Single; Matrix: TSingleMatrix): TBoolMatrix;
function MatrixEQ(value: Single; Matrix: TSingleMatrix): TBoolMatrix;
function MatrixNE(value: Single; Matrix: TSingleMatrix): TBoolMatrix;

implementation

uses 
  math;

function GetRawMatrix(src:PInt32; x1,y1,x2,y2:Int32; W,H:Int32): TIntMatrix;
var
  y,resw,resh: Int32;
begin
  if (x2 < 0) then x2 := W+x2;
  if (y2 < 0) then y2 := H+y2;

  if (not InRange(x1, 0,W-1)) or (not InRange(x2, 0,W-1)) or (not InRange(y1, 0,H-1)) or (not InRange(y2, 0,H-1)) then
    Exit();

  resW := (x2 - x1) + 1;
  resH := (y2 - y1) + 1;
  SetLength(Result, resH, resW);
  for y:=0 to resH-1 do
    Move(src[(y+y1)*W + x1], Result[y][0], resW*SizeOf(Int32));
end;


function Where(Matrix: TBoolMatrix): TPointArray;
var 
  W,H,c,x,y:Int32;
begin
  H := High(Matrix);
  if H < 0 then Exit;
  W := High(Matrix[0]);
  SetLength(Result, 512);

  c := 0;
  for y:=0 to H do
    for x:=0 to W do
      if Matrix[y,x] then
      begin
        if c = Length(Result) then
          SetLength(Result, Length(result) * 2);

        Result[c] := Point(x,y);
        Inc(c);
      end;
  SetLength(Result, c);
end;


{$DEFINE MATRIX_COMPARE := 
  var
    W,H,x,y:Int32;
  begin
    H := High(Matrix);
    if H < 0 then Exit;
    W := High(Matrix[0]);

    SetLength(Result, H+1,W+1);
    for y:=0 to H do
      for x:=0 to W do
        Result[y,x] := LEFT_VAR CMPOP RIGHT_VAR;
  end
}


{$DEFINE LEFT_VAR  := Matrix[y,x]} {$DEFINE RIGHT_VAR := value} 
{$DEFINE CMPOP := <}  function MatrixLT(Matrix: TSingleMatrix; value: Single): TBoolMatrix; MATRIX_COMPARE;
{$DEFINE CMPOP := >}  function MatrixGT(Matrix: TSingleMatrix; value: Single): TBoolMatrix; MATRIX_COMPARE;
{$DEFINE CMPOP := =}  function MatrixEQ(Matrix: TSingleMatrix; value: Single): TBoolMatrix; MATRIX_COMPARE;
{$DEFINE CMPOP := <>} function MatrixNE(Matrix: TSingleMatrix; value: Single): TBoolMatrix; MATRIX_COMPARE;


{$DEFINE LEFT_VAR  := value} {$DEFINE RIGHT_VAR := Matrix[y,x]} 
{$DEFINE CMPOP := <}  function MatrixLT(value: Single; Matrix: TSingleMatrix): TBoolMatrix; MATRIX_COMPARE;
{$DEFINE CMPOP := >}  function MatrixGT(value: Single; Matrix: TSingleMatrix): TBoolMatrix; MATRIX_COMPARE;
{$DEFINE CMPOP := =}  function MatrixEQ(value: Single; Matrix: TSingleMatrix): TBoolMatrix; MATRIX_COMPARE;
{$DEFINE CMPOP := <>} function MatrixNE(value: Single; Matrix: TSingleMatrix): TBoolMatrix; MATRIX_COMPARE;
end.
