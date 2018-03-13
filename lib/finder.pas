unit Finder;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2014, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
{$mode objfpc}{$H+}
{$modeswitch advancedrecords}
{$inline on}
interface
uses
  SysUtils, Classes, Threading, Header;

type
  TColorInfo = Pointer;
  PColorInfo = ^TColorInfo;

  TColorDistFunc = function(Color1:TColorInfo; Color2:TColor; mul: TMultiplier): Single;
  PColorDistFunc = ^TColorDistFunc;


  PFinder = ^TFinder;
  TFinder = packed record
  private
    FCompareFunc: TColorDistFunc;
    FNumThreads: UInt8;
    FCacheSize: UInt8;
    FColorInfo: TColorInfo;
    FFormula: EDistanceFormula;
    FChMul: TMultiplier;
    FThreadPool: TThreadPool;

    function  SetupColorInfo(const Color: TColor): Single;
    procedure FreeColorInfo();
  public
    procedure Init(Formula:EDistanceFormula; NumThreads:UInt8; CacheSize:UInt8);
    procedure Free;

    procedure SetFormula(Formula: EDistanceFormula);
    function  GetFormula(): EDistanceFormula;
    procedure SetNumThreads(NumThreads: UInt8);
    function  GetNumThreads(): Int32;
    procedure SetMultipliers(Mul: TMultiplier);
    function  GetMultipliers(): TMultiplier;

    function GetMaxDistance(): Single;
    function SimilarColors(Color1, Color2: TColor; Tolerance: Single): Boolean;
    function ColorDistance(Color1, Color2: TColor): Single;
    procedure MatchColor(src:TIntMatrix; var dest:TSingleMatrix; color:TColor);
    function FindColor(src:TIntMatrix; out dest:TPointArray; color:TColor; Tolerance:Single): Boolean;
  end;


  TMicroCacheItem = record Color:TColor; Diff:Single; end;
  TMicroCache = record
    High: SizeInt;
    Color: TColorInfo;
    MaxDiff: Single;
    Mods: TMultiplier;
    Diff: TColorDistFunc;
    Cache: array of TMicroCacheItem;

    procedure Init(ASize:UInt8; AColor:TColorInfo; AMaxDiff:Single; AMods:TMultiplier; ADiff: TColorDistFunc);
    function Compare(TestColor: TColor): TMicroCacheItem; inline;
    function DirectCompare(TestColor: TColor): Single; inline;
  end;


//--------------------------------------------------
implementation

uses
  math,
  colordist,
  colorconversion;

procedure TMicroCache.Init(ASize:UInt8; AColor:TColorInfo; AMaxDiff:Single; AMods:TMultiplier; ADiff: TColorDistFunc);
var i:Int32;
begin
  self.Color := AColor;
  self.MaxDiff := AMaxDiff;
  self.Mods := AMods;
  self.Diff := ADiff;
  self.High := ASize-1;

  SetLength(self.Cache, ASize);
  for i:=0 to self.High do
  begin
    self.Cache[i].Diff  := -1;
    self.Cache[i].Color := -1;
  end;
end;

function TMicroCache.Compare(TestColor: TColor): TMicroCacheItem;
var
  i:Int32 = 1;
begin
  if (TestColor = self.cache[0].Color) then
    Exit(self.cache[0]);

  //find the item, move it back to 0
  while i <= self.High do
    if self.cache[i].Color = TestColor then
    begin
      Result := self.cache[i];
      while i > 0 do
      begin
        self.cache[i] := self.cache[i-1];
        Dec(i);
      end;
      self.cache[0] := Result;
      Exit(Result);
    end else
     Inc(i);

  //add item, push old item out of the way
  i := self.High;
  while i >= 0 do
  begin
    self.cache[i] := self.cache[i-1];
    Dec(i);
  end;
  self.cache[0].Color := TestColor;
  self.cache[0].Diff  := 1 - Diff(self.Color, TestColor, self.Mods) / self.MaxDiff;
  Result := self.cache[0];
end;

function TMicroCache.DirectCompare(TestColor: TColor): Single;
begin
  Result  := 1 - Diff(self.Color, TestColor, self.Mods) / self.MaxDiff;
end;

procedure ColorCorrelation(params:PParamArray);
var
  x,y: Int32;
  src: PIntMatrix;
  dest:PSingleMatrix;
  box: TBox;
  uCache: TMicroCache;
begin
  src  := Params^[0];
  dest := Params^[1];

  uCache.Init(
    PUInt8(Params^[6])^,             //cache size
    PColorInfo(Params^[4])^,         //input color
    PSingle(Params^[3])^,            //maximum diff using this colorspace and current mult
    PMultiplier(Params^[2])^,        //channelwise multipliers
    PColorDistFunc(Params^[5])^      //the function needed to compute diff between colors
  );

  box := PBox(Params^[7])^;
  if uCache.High >= 0 then
  begin
    for y:=box.Y1 to box.Y2 do
      for x:=box.X1 to box.X2 do
        dest^[y,x] := uCache.Compare(src^[y,x]).Diff;
  end else
    for y:=box.Y1 to box.Y2 do
      for x:=box.X1 to box.X2 do
        dest^[y,x] := uCache.DirectCompare(src^[y,x]);
end;


(*----| TFinder |-------------------------------------------------------------*)

procedure TFinder.Init(Formula:EDistanceFormula; NumThreads:UInt8; CacheSize:UInt8);
begin
  FNumThreads := Max(1,NumThreads);
  FColorInfo  := nil;
  FFormula    := Formula;
  FCacheSize  := CacheSize;
  FThreadPool := TThreadPool.Create(128);
  FChMul[0] := 1;
  FChMul[1] := 1;
  FChMul[2] := 1;
end;


procedure TFinder.Free;
begin
  if FColorInfo <> nil then FreeMem(FColorInfo);
  FCompareFunc:= nil;
  FFormula    := dfRGB;
  FNumThreads := 1;
  FThreadPool.Free();
end;


(*----| Setup/Unsetup |-------------------------------------------------------*)

function TFinder.SetupColorInfo(const Color: TColor): Single;
begin
  case FFormula of
    dfRGB:
      begin
        FCompareFunc := @DistanceRGB;
        FColorInfo := AllocMem(SizeOf(ColorRGB));
        PColorRGB(FColorInfo)^ := ColorToRGB(Color);
        Result := DistanceRGB_Max(FChMul);
      end;
    dfHSV:
      begin
        FCompareFunc := @DistanceHSV;
        FColorInfo := AllocMem(SizeOf(ColorHSV));
        PColorHSV(FColorInfo)^ := ColorToHSV(Color);
        Result := DistanceHSV_Max(FChMul);
      end;
    dfHSL:
      begin
        FCompareFunc := @DistanceHSL;
        FColorInfo := AllocMem(SizeOf(ColorHSL));
        PColorHSL(FColorInfo)^ := ColorToHSL(Color);
        Result := DistanceHSL_Max(FChMul);
      end;
    dfXYZ:
      begin
        FCompareFunc := @DistanceXYZ;
        FColorInfo := AllocMem(SizeOf(ColorXYZ));
        PColorXYZ(FColorInfo)^ := ColorToXYZ(Color);
        Result := DistanceXYZ_Max(FChMul);
      end;
    dfLAB:
      begin
        FCompareFunc := @DistanceLAB;
        FColorInfo := AllocMem(SizeOf(ColorLAB));
        PColorLAB(FColorInfo)^ := ColorToLAB(Color);
        Result := DistanceLAB_Max(FChMul);
      end;
    dfLCH: begin
        FCompareFunc := @DistanceLCH;
        FColorInfo := AllocMem(SizeOf(ColorLCH));
        PColorLCH(FColorInfo)^ := ColorToLCH(Color);
        Result := DistanceLCH_Max(FChMul);
      end;
    dfDeltaE:
      begin
        FCompareFunc := @DistanceDeltaE;
        FColorInfo := AllocMem(SizeOf(ColorLAB));
        PColorLAB(FColorInfo)^ := ColorToLAB(Color);
        Result := DistanceDeltaE_Max(FChMul);
      end;
  end;
end;

procedure TFinder.FreeColorInfo(); 
begin
  if FColorInfo <> nil then
    FreeMem(FColorInfo);
  FColorInfo := nil;
end;

(*
  Set the compare method used to compute the difference between
  the given color, and each color on the image using a preset.
*)
procedure TFinder.SetFormula(Formula:EDistanceFormula);
begin
  self.FFormula := Formula;
end;

function TFinder.GetFormula(): EDistanceFormula;
begin
  Result := self.FFormula;
end;


(*
  Get & Set the number of threads to be used
*)
procedure TFinder.SetNumThreads(numThreads:UInt8);
begin
  FNumThreads := Min(FThreadPool.FMaxThreads, Max(1, numThreads));
end;

function TFinder.GetNumThreads(): Int32;
begin
  Result := FNumThreads;
end;

(*
  Get & Set the multipliers
*)
procedure TFinder.SetMultipliers(Mul: TMultiplier);
var x:Single;
begin
  x := (Mul[0] + Mul[1] + Mul[2]) / 3;
  FChMul[0] := Mul[0] / x;
  FChMul[1] := Mul[1] / x;
  FChMul[2] := Mul[2] / x;
end;

function TFinder.GetMultipliers(): TMultiplier;
begin
  Writeln(Format('%.3f, %.3f, %.3f', [Self.FChMul[0], Self.FChMul[1],Self.FChMul[2]]));
  Result := Self.FChMul;
end;

function TFinder.GetMaxDistance(): Single;
begin
  Result := Self.SetupColorInfo(0);
  Self.FreeColorInfo();
end;

function TFinder.SimilarColors(Color1, Color2: TColor; Tolerance: Single): Boolean;
var
  maxDist, minSimilarity: Single;
begin
  minSimilarity := (100-(Tolerance+0.00001)) / 100;

  //Color1  := SwapRGBChannels(Color1);
  //Color2  := SwapRGBChannels(Color2);
  maxDist := Self.SetupColorInfo(Color1);
  Result  := 1 - Self.FCompareFunc(FColorInfo, Color2, FChMul) / maxDist > minSimilarity;
  Self.FreeColorInfo();
end;

function TFinder.ColorDistance(Color1, Color2: TColor): Single;
var
  maxDist: Single;
begin
  //Color1  := SwapRGBChannels(Color1);
  //Color2  := SwapRGBChannels(Color2);
  maxDist := Self.SetupColorInfo(Color1);
  Result  := FCompareFunc(FColorInfo, Color2, FChMul) / maxDist * 100;
  Self.FreeColorInfo();
end;


// Threaded cross-correlate a color with an image
procedure TFinder.MatchColor(src:TIntMatrix; var dest:TSingleMatrix; color:TColor);
var
  W,H: Int32;
  maxDist: Single;
begin
  H := Length(src);
  if (H = 0) then Exit;
  W := Length(src[0]);

  //color := SwapRGBChannels(color);
  maxDist := Self.SetupColorInfo(Color);
  SetLength(dest, H,W);
  
  FThreadPool.MatrixFunc(@ColorCorrelation, [@src, @dest, @FChMul, @maxDist, @FColorInfo, @FCompareFunc, @FCacheSize], W,H, FNumThreads);
  Self.FreeColorInfo();
end;

function TFinder.FindColor(src:TIntMatrix; out dest:TPointArray; color:TColor; Tolerance:Single): Boolean;
var
  x,y,c: Int32;
  xcorr: TSingleMatrix;
  MinSimilarity: Single;
begin
  MatchColor(src, xcorr, color);
  MinSimilarity := (100-(Tolerance+0.00001)) / 100;

  SetLength(dest, 512);
  c := 0;
  for y:=0 to High(xcorr) do
    for x:=0 to High(xcorr[y]) do
      if xcorr[y,x] > MinSimilarity then
      begin
        if c = Length(dest) then
          SetLength(dest, Length(dest)*2);

        dest[c].x := x;
        dest[c].y := y;
        Inc(c);
      end;
  SetLength(dest, c);
  Result := c > 0;
end;

end.
