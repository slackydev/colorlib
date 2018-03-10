unit Header;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2014, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
{$mode objfpc}{$H+}
{$macro on}
{$inline on}
interface

type
  PSingle = ^Single;

  PSingleArray = ^TSingleArray;
  TSingleArray = array of Single;
  PSingleMatrix = ^TSingleMatrix;
  TSingleMatrix = array of TSingleArray;
  
  PIntArray = ^TIntArray;
  TIntArray  = array of Int32;
  PIntMatrix = ^TIntMatrix;
  TIntMatrix = array of TIntArray;
  
  PBoolArray  = ^TBoolArray;
  TBoolArray  = array of LongBool;
  PBoolMatrix = ^TBoolMatrix;
  TBoolMatrix = array of TBoolArray;
  
  PParamArray = ^TParamArray;
  TParamArray = array[Word] of Pointer;

  PBox = ^TBox;
  TBox = record
    X1,Y1,X2,Y2: Int32;
  end;
  
  PPoint = ^TPoint;
  TPoint = packed record
    X,Y: Int32;
  end;
  TPointArray = array of TPoint;

  PMultiplier = ^TMultiplier;
  TMultiplier = array [0..2] of Single;

  PColor = ^TColor;
  TColor = Int32;
  
  ColorRGB = record R,G,B: Byte;  end;
  ColorXYZ = record X,Y,Z: Single; end;
  ColorLAB = record L,A,B: Single; end;
  ColorLCH = record L,C,H: Single; end;
  ColorHSV = record H,S,V: Single; end;
  ColorHSL = record H,S,L: Single; end;

  PColorRGB = ^ColorRGB;
  PColorXYZ = ^ColorXYZ;
  PColorLAB = ^ColorLAB;
  PColorLCH = ^ColorLCH;
  PColorHSV = ^ColorHSV;
  PColorHSL = ^ColorHSL;
  
  EDistanceFormula = (dfRGB, dfHSV, dfHSL, dfXYZ, dfLAB, dfLCH, dfDeltaE);


function Modulo(X,Y: Single): Single; inline;
function Modulo(X,Y: Int32): Int32; inline;
function Modulo(X,Y: Int64): Int64; inline;
function Box(X1,Y1,X2,Y2: Int32): TBox; inline;
function Point(X,Y: Int32): TPoint; inline;

implementation

uses math;

function Modulo(X,Y: Single): Single; begin Result := X - Floor(X / Y) * Y; end;
function Modulo(X,Y: Int32): Int32;   begin Result := X - Floor(X / Y) * Y; end;
function Modulo(X,Y: Int64): Int64;   begin Result := X - Floor(X / Y) * Y; end;

function Box(X1,Y1,X2,Y2: Int32): TBox;
begin
  Result.X1 := X1;
  Result.Y1 := Y1;
  Result.X2 := X2;
  Result.Y2 := Y2;
end;

function Point(X,Y: Int32): TPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

end.
