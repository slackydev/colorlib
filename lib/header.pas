unit header;
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
  Float = Single;
  PFloat = Float;

  PFloatArray = ^TFloatArray;
  TFloatArray = array of Float;
  PFloatMatrix = ^TFloatMatrix;
  TFloatMatrix = array of TFloatArray;
  
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

  PChannelMultiplier = ^TChannelMultiplier;
  TChannelMultiplier = array [0..2] of Float;

  PColor = ^TColor;
  TColor = Int32;
  
  ColorXYZ = record X,Y,Z: Float; end;
  ColorLAB = record L,A,B: Float; end;
  ColorLCH = record L,C,H: Float; end;
  ColorHSV = record H,S,V: Float; end;
  ColorHSL = record H,S,L: Float; end;
  ColorRGB = record R,G,B: Byte; end;

  PColorXYZ = ^ColorXYZ;
  PColorLAB = ^ColorLAB;
  PColorLCH = ^ColorLCH;
  PColorHSV = ^ColorHSV;
  PColorHSL = ^ColorHSL;
  PColorRGB = ^ColorRGB;
  
  EDistanceFormula = (dfRGB, dfHSV, dfXYZ, dfLAB, dfLCH, dfDeltaE);

const
  FLOATSTR = {$If SizeOf(Float) = SizeOf(Single)}'Single'{$ElseIf SizeOf(Float) = SizeOf(Double)}'Double'{$ENDIF};

  
function Modulo(X,Y: Float): Float; inline;
function Modulo(X,Y: Int32): Int32; inline;
function Modulo(X,Y: Int64): Int64; inline;
function Box(X1,Y1,X2,Y2: Int32): TBox; inline;
function Point(X,Y: Int32): TPoint; inline;

implementation

uses math;

function Modulo(X,Y: Float): Float; begin Result := X - Floor(X / Y) * Y; end;
function Modulo(X,Y: Int32): Int32; begin Result := X - Floor(X / Y) * Y; end;
function Modulo(X,Y: Int64): Int64; begin Result := X - Floor(X / Y) * Y; end;

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
