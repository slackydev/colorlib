unit ColorDist;
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

function DistanceRGB(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single; inline;
function DistanceHSV(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single; inline;
function DistanceHSL(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single; inline;
function DistanceXYZ(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single; inline;
function DistanceLAB(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single; inline;
function DistanceLCH(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single; inline;
function DistanceDeltaE(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single; inline;

function DistanceRGB_Max(mul: TMultiplier): Single; inline;
function DistanceHSV_Max(mul: TMultiplier): Single; inline;
function DistanceHSL_Max(mul: TMultiplier): Single; inline;
function DistanceXYZ_Max(mul: TMultiplier): Single; inline;
function DistanceLAB_Max(mul: TMultiplier): Single; inline;
function DistanceLCH_Max(mul: TMultiplier): Single; inline;
function DistanceDeltaE_Max(mul: TMultiplier): Single; inline;

implementation

uses
  Math, SysUtils, ColorConversion;

// ----| RGB |-----------------------------------------------------------------
function DistanceRGB(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single;
var
  C1,C2: ColorRGB;
begin
  C1 := PColorRGB(Color1)^;
  C2 := ColorToRGB(Color2);
  Result := Sqrt(Sqr((C1.R-C2.R) * mul[0]) + Sqr((C1.G-C2.G) * mul[1]) + Sqr((C1.B-C2.B) * mul[2]));
end;

function DistanceRGB_Max(mul: TMultiplier): Single;
begin
  Result := Sqrt(Sqr(255 * mul[0]) + Sqr(255 * mul[1]) + Sqr(255 * mul[2]));
end;

// ----| HSV |-----------------------------------------------------------------
// Hue is weighted based on max saturation of the two colors:
// The "simple" solution causes a problem where two dark slightly saturated gray colors can have 
// completely different hue's, causing the distance measure to be larger than what it should be.
function DistanceHSV(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single;
var
  C1,C2: ColorHSV;
  deltaH: Single;
begin
  C1 := PColorHSV(Color1)^;
  C2 := ColorToHSV(Color2);

  if (C1.S < 1.0e-10) or (C2.S < 1.0e-10) then // no saturation = gray (hue has no value here)
    deltaH := 0
  else begin
    deltaH := Abs(C1.H - C2.H);
    if deltaH >= 180 then deltaH := 360 - deltaH;
    deltaH *= Max(C1.S, C2.S) / 100;
  end;
  Result := Sqrt(Sqr(deltaH * mul[0]) + Sqr((C1.S-C2.S) * mul[1]) + Sqr((C1.V-C2.V) * mul[2]));
end;

function DistanceHSV_Max(mul: TMultiplier): Single;
begin
  Result := Sqrt(Sqr(180 * mul[0]) + Sqr(100 * mul[1]) + Sqr(100 * mul[2]));
end;

// ----| HSL |-----------------------------------------------------------------
// Hue is weighted based on max saturation of the two colors:
// The "simple" solution causes a problem where two dark slightly saturated gray colors can have 
// completely different hue's, causing the distance measure to be larger than what it should be.
function DistanceHSL(Color1: Pointer; Color2: TColor; mul: TMultiplier): Single;
var
  C1,C2: ColorHSL;
  deltaH: Single;
begin
  C1 := PColorHSL(Color1)^;
  C2 := ColorToHSL(Color2);

  if (C1.S < 1.0e-10) or (C2.S < 1.0e-10) then // no saturation = gray (hue has no value here)
    deltaH := 0
  else begin
    deltaH := Abs(C1.H - C2.H);
    if deltaH >= 180 then deltaH := 360 - deltaH;
    deltaH *= Max(C1.S, C2.S) / 100;
  end;
  Result := Sqrt(Sqr(deltaH * mul[0]) + Sqr((C1.S-C2.S) * mul[1]) + Sqr((C1.L-C2.L) * mul[2]));
end;

function DistanceHSL_Max(mul: TMultiplier): Single;
begin
  Result := Sqrt(Sqr(180 * mul[0]) + Sqr(100 * mul[1]) + Sqr(100 * mul[2]));
end;


// ----| XYZ |-----------------------------------------------------------------
function DistanceXYZ(Color1:Pointer; Color2:TColor; mul:TMultiplier): Single;
var C1,C2: ColorXYZ;
begin
  C1 := PColorXYZ(Color1)^;
  C2 := ColorToXYZ(Color2);
  Result := Sqrt(Sqr((C1.X-C2.X) * mul[0]) + Sqr((C1.Y-C2.Y) * mul[1]) + Sqr((C1.Z-C2.Z) * mul[2]));
end;

function DistanceXYZ_Max(mul:TMultiplier): Single;
begin
  Result := Sqrt(Sqr(255 * mul[0]) + Sqr(255 * mul[1]) + Sqr(255 * mul[2]));
end;


// ----| LAB |-----------------------------------------------------------------
function DistanceLAB(Color1:Pointer; Color2:TColor; mul:TMultiplier): Single;
var C1,C2: ColorLAB;
begin
  C1 := PColorLAB(Color1)^;
  C2 := ColorToLAB(Color2);
  Result := Sqrt(Sqr((C1.L-C2.L) * mul[0]) + Sqr((C1.A-C2.A) * mul[1]) + Sqr((C1.B-C2.B) * mul[2]));
end;

function DistanceLAB_Max(mul:TMultiplier): Single;
begin
  Result := Sqrt(Sqr(100 * mul[0]) + Sqr(200 * mul[1]) + Sqr(200 * mul[2]));
end;


// ----| LCH |-----------------------------------------------------------------
// Hue is weighted based on Chroma:
// The "simple" solution causes a problem where two dark slightly saturated gray colors can have 
// completely different hue's, causing the distance measure to be larger than what it should be.
function DistanceLCH(Color1:Pointer; Color2:TColor; mul:TMultiplier): Single;
var
  C1,C2: ColorLCH;
  deltaH: Single;
begin
  C1 := PColorLCH(Color1)^;
  C2 := ColorToLCH(Color2);
  
  deltaH := Abs(C1.H - C2.H);
  if deltaH >= 180 then deltaH := 360 - deltaH;
  deltaH *= Max(C1.C, C2.C) / 100;
  
  if (C1.C < 0.4) or (C2.C < 0.4) then // no chromaticity = gray (hue has no value here)
    deltaH := 0
  else begin
    deltaH := Abs(C1.H - C2.H);
    if deltaH >= 180 then deltaH := 360 - deltaH;
    deltaH *= Max(C1.C, C2.C) / 100;
  end;
  
  Result := Sqrt(Sqr((C1.L-C2.L) * mul[0]) + Sqr((C1.C - C2.C) * mul[1]) + Sqr(deltaH * mul[2]));
end;

function DistanceLCH_Max(mul:TMultiplier): Single;
begin
  Result := Sqrt(Sqr(100 * mul[0]) + Sqr(100 * mul[1]) + Sqr(180 * mul[2]));
end;


// ----| DeltaE |--------------------------------------------------------------
function DistanceDeltaE(Color1:Pointer; Color2:TColor; mul:TMultiplier): Single;
var
  C1,C2: ColorLAB;
  xc1,xc2,xdl,xdc,xde,xdh,xsc,xsh: Single;
begin
  C1 := PColorLAB(Color1)^;
  C2 := ColorToLAB(Color2);

  xc1 := Sqrt(Sqr(C1.a) + Sqr(C1.b));
  xc2 := Sqrt(Sqr(C2.a) + Sqr(C2.b));
  xdl := c2.L - c1.L;
  xdc := xc2 - xc1;
  xde := Sqrt(Sqr(c1.L - c2.L) + Sqr(c1.a - c2.A) + Sqr(c1.b - c2.B));

  if Sqrt(xDE) > Sqrt(Abs(xDL)) + Sqrt(Abs(xDC))  then
     xDH := Sqrt(Sqr(xDE) - Sqr(xDL) - Sqr(xDC))
  else
     xDH := 0;

  xSC := 1 + (0.045 * (xC1+xC2)/2);
  xSH := 1 + (0.015 * (xC1+xC2)/2);

  xDC /= xSC;
  xDH /= xSH;
  Result := Sqrt(Sqr(xDL * mul[0]) + Sqr(xDC * mul[1]) + Sqr(xDH * mul[2]));
end;

function DistanceDeltaE_Max(mul:TMultiplier): Single;
var
  c1,c2: ColorLAB;
  xc1,xc2,xdl,xdc,xde,xdh,xsc,xsh: Single;
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

  if Sqrt(xDE) > Sqrt(Abs(xDL)) + Sqrt(Abs(xDC))  then
     xDH := Sqrt(Sqr(xDE) - Sqr(xDL) - Sqr(xDC))
  else
     xDH := 0;

  xSC := 1 + (0.045 * (xC1+xC2)/2);
  xSH := 1 + (0.015 * (xC1+xC2)/2);

  xDC /= xSC;
  xDH /= xSH;
  Result := Sqrt(Sqr(xDL * mul[0]) + Sqr(xDC * mul[1]) + Sqr(xDH * mul[2]));
end;

end.

