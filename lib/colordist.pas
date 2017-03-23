unit colordist;
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
  header;

function DistanceRGB(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): Float; inline;
function DistanceHSV(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): Float; inline;
function DistanceXYZ(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): Float; inline;
function DistanceLAB(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): Float; inline;
function DistanceLCH(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): Float; inline;
function DistanceDeltaE(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): Float; inline;

function DistanceRGB_Max(mul:TChannelMultiplier): Float; inline;
function DistanceHSV_Max(mul:TChannelMultiplier): Float; inline;
function DistanceXYZ_Max(mul:TChannelMultiplier): Float; inline;
function DistanceLAB_Max(mul:TChannelMultiplier): Float; inline;
function DistanceLCH_Max(mul:TChannelMultiplier): Float; inline;
function DistanceDeltaE_Max(mul:TChannelMultiplier): Float; inline;

implementation

uses
  Math, sysutils, colorconversion;

//----| RGB |-----------------------------------------------------------------//
function DistanceRGB(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): header.Float;
var
  C1,C2: ColorRGB;
begin
  C1 := PColorRGB(Color1)^;
  C2 := ColorToRGB(Color2);
  Result := Sqrt(Sqr(C1.R-C2.R)*mul[0] + Sqr(C1.G-C2.G)*mul[1] + Sqr(C1.B-C2.B)*mul[2]);
end;

function DistanceRGB_Max(mul:TChannelMultiplier): header.Float;
begin
  Result := Sqrt(Sqr(255)*mul[0] + Sqr(255)*mul[1] + Sqr(255)*mul[2]);
end;

//----| HSV |-----------------------------------------------------------------//
function DistanceHSV(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): header.Float;
var
  C1,C2: ColorHSV;
  deltaH: header.Float;
begin
  C1 := PColorHSV(Color1)^;
  C2 := ColorToHSV(Color2);

  deltaH := Abs(C1.H - C2.H);
  if deltaH >= 180 then deltaH := 360 - deltaH;
  Result := Sqrt(Sqr(deltaH)*mul[0] + Sqr(C1.S-C2.S)*mul[1] + Sqr(C1.V-C2.V)*mul[2]);
end;

function DistanceHSV_Max(mul:TChannelMultiplier): header.Float;
begin
  Result := Sqrt(Sqr(180)*mul[0] + Sqr(100)*mul[1] + Sqr(100)*mul[2]);
end;


//----| XYZ |-----------------------------------------------------------------//
function DistanceXYZ(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): header.Float;
var C1,C2: ColorXYZ;
begin
  C1 := PColorXYZ(Color1)^;
  C2 := ColorToXYZ(Color2);
  Result := Sqrt(Sqr(C1.X-C2.X)*mul[0] + Sqr(C1.Y-C2.Y)*mul[1] + Sqr(C1.Z-C2.Z)*mul[2]);
end;

function DistanceXYZ_Max(mul:TChannelMultiplier): header.Float;
begin
  Result := Sqrt(Sqr(255)*mul[0] + Sqr(255)*mul[1] + Sqr(255)*mul[2]);
end;


//----| LAB |-----------------------------------------------------------------//
function DistanceLAB(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): header.Float;
var C1,C2: ColorLAB;
begin
  C1 := PColorLAB(Color1)^;
  C2 := ColorToLAB(Color2);
  Result := Sqrt(Sqr(C1.L-C2.L)*mul[0] + Sqr(C1.A-C2.A)*mul[1] + Sqr(C1.B-C2.B)*mul[2]);
end;

function DistanceLAB_Max(mul:TChannelMultiplier): header.Float;
begin
  Result := Sqrt(Sqr(100)*mul[0] + Sqr(200)*mul[1] + Sqr(200)*mul[2]);
end;


//----| LCH |-----------------------------------------------------------------//
function DistanceLCH(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): header.Float;
var
  C1,C2: ColorLCH;
  deltaH: header.Float;
begin
  C1 := PColorLCH(Color1)^;
  C2 := ColorToLCH(Color2);
  if (C2.L > 100) or (C2.L < -0.01) or (C2.C > 100) or (C2.C < -0.01) or (C2.H > 360) or (C2.H < -0.01) then
    WriteLn(Format('(%.3f,%.3f,%.3f)', [C2.L,C2.C,C2.H]));

  deltaH := Abs(C1.H - C2.H);
  if deltaH >= 180 then deltaH := 360 - deltaH;
  Result := Sqrt(Sqr(C1.L-C2.L)*mul[0] + Sqr(C1.C-C2.C)*mul[1] + Sqr(deltaH)*mul[2]);
end;

function DistanceLCH_Max(mul:TChannelMultiplier): header.Float;
begin
  Result := Sqrt(Sqr(100)*mul[0] + Sqr(100)*mul[1] + Sqr(180)*mul[2]);
end;


//----| DeltaE |--------------------------------------------------------------//
function DistanceDeltaE(Color1:Pointer; Color2:TColor; mul:TChannelMultiplier): header.Float;
var
  C1,C2:ColorLAB;
  xc1,xc2, xdl,xdc,xde,xdh,xsc,xsh: header.Float;
begin
  C1 := PColorLAB(Color1)^;
  C2 := ColorToLAB(Color2);

  xc1 := Sqrt(Sqr(C1.a) + Sqr(C1.b));
  xc2 := Sqrt(Sqr(C2.a) + Sqr(C2.b));
  xdl := c2.L - c1.L;
  xdc := xc2 - xc1;
  xde := Sqrt(Sqr(c1.L - c2.L) + Sqr(c1.a - c2.A) + Sqr(c1.b - c2.B));

  if Sqrt(xDE) > Sqrt(Abs(xDL)) + Sqrt(Abs( xDC ))  then
     xDH := Sqrt(Sqr(xDE) - Sqr(xDL) - Sqr(xDC))
  else
     xDH := 0;

  xSC := 1 + (0.045 * (xC1+xC2)/2);
  xSH := 1 + (0.015 * (xC1+xC2)/2);

  xDC /= xSC;
  xDH /= xSH;
  Result := Sqrt(Sqr(xDL)*mul[0] + Sqr(xDC)*mul[1] + Sqr(xDH)*mul[2]);
end;

function DistanceDeltaE_Max(mul:TChannelMultiplier): header.Float;
var
  c1,c2:ColorLAB;
  xc1,xc2, xdl,xdc,xde,xdh,xsc,xsh: header.Float;
begin
  c1.L := 0;
  c1.A := -100;
  c1.B := -100;

  c2.L := 100;
  c2.A := 100;
  c2.B := 100;

  xc1 := Sqrt(Sqr(C1.a) + Sqr(C1.b));
  xc2 := Sqrt(Sqr(C2.a) + Sqr(C2.b));
  xdl := c2.L - c1.L;
  xdc := xc2 - xc1;
  xde := Sqrt(Sqr(c1.L - c2.L) + Sqr(c1.a - c2.A) + Sqr(c1.b - c2.B));

  if Sqrt(xDE) > Sqrt(Abs(xDL)) + Sqrt(Abs( xDC ))  then
     xDH := Sqrt(Sqr(xDE) - Sqr(xDL) - Sqr(xDC))
  else
     xDH := 0;

  xSC := 1 + (0.045 * (xC1+xC2)/2);
  xSH := 1 + (0.015 * (xC1+xC2)/2);

  xDC /= xSC;
  xDH /= xSH;
  Result := Sqrt(Sqr(xDL)*mul[0] + Sqr(xDC)*mul[1] + Sqr(xDH)*mul[2]);
end;

end.

