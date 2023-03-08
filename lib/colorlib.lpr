library colorlib;
{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2013, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
 For more info see: Copyright.txt
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
{$mode objfpc}{$H+}

uses
  SysUtils,
  Classes,
  Math,
  Header,
  Finder,
  Utils,
  ColorConversion;

{$I SimbaPlugin.inc}

// -----------------------------------------------------------------------------------------
// Finder exports

procedure TFinder_Init(var Finder:TFinder; ComparePreset: EDistanceFormula; NumThreads, CacheSize:UInt8); cdecl;
begin
  Finder.Init(ComparePreset, NumThreads, CacheSize);
end;

procedure TFinder_Free(var Finder:TFinder); cdecl;
begin
  Finder.Free();
end;

procedure TFinder_SetFormula(var Finder:TFinder; ComparePreset: EDistanceFormula); cdecl;
begin
  Finder.SetFormula(ComparePreset);
end;

function TFinder_GetFormula(var Finder:TFinder): EDistanceFormula; cdecl;
begin
  Result := Finder.GetFormula();
end;

procedure TFinder_SetNumThreads(var Finder:TFinder; Threads:Uint8); cdecl;
begin
  Finder.SetNumThreads(Threads);
end;

function TFinder_GetNumThreads(var Finder:TFinder): UInt8; cdecl;
begin
  Result := Finder.GetNumThreads();
end;

procedure TFinder_SetMultipliers(var Finder:TFinder; const Mul: TMultiplier); cdecl;
begin
  Finder.SetMultipliers(Mul);
end;

procedure TFinder_GetMultipliers(var Finder:TFinder; out Result: TMultiplier); cdecl;
begin
  Result := Finder.GetMultipliers();
end;

function TFinder_GetMaxDistance(var Finder:TFinder): Single; cdecl;
begin
  Result := Finder.GetMaxDistance();
end;

function TFinder_SimilarColors(var Finder:TFinder; Color1, Color2: TColor; Tolerance: Single): LongBool; cdecl;
begin
  Result := Finder.SimilarColors(Color1, Color2, Tolerance);
end;

function TFinder_ColorDistance(var Finder:TFinder; color1, color2: TColor): Single; cdecl;
begin
  Result := Finder.ColorDistance(Color1, Color2);
end;

procedure TFinder_MatchColor(var Finder:TFinder; src:TIntMatrix; var dest:TSingleMatrix; color:Int32); cdecl;
begin
  Finder.MatchColor(src, dest, color);
end;

function TFinder_FindColor(var Finder:TFinder; src:TIntMatrix; out dest:TPointArray; color:TColor; tolerance:Single): Boolean; cdecl;
begin
  Result := Finder.FindColor(src, dest, color, Tolerance);
end;

// -----------------------------------------------------------------------------------------
// Matrix exports

function _GetRawMatrix(var _:Pointer; data:PInt32; x1,y1,x2,y2:Int32; W,H:Int32): TIntMatrix; cdecl;
begin Result := GetRawMatrix(data,x1,y1,x2,y2,W,H); end;

procedure _Where(const Params: PParamArray; const Result:Pointer); cdecl;
begin TPointArray(Result^) := Where(TBoolMatrix(Params^[1]^)); end;

procedure _MatrixLT_MatVal(const Params: PParamArray; const Result:Pointer); cdecl;
begin TBoolMatrix(Result^) := MatrixLT(TSingleMatrix(Params^[1]^), Single(Params^[2]^)); end;

procedure _MatrixLT_ValMat(const Params: PParamArray; const Result:Pointer); cdecl;
begin TBoolMatrix(Result^) := MatrixLT(Single(Params^[1]^), TSingleMatrix(Params^[2]^)); end;

procedure _MatrixGT_MatVal(const Params: PParamArray; const Result:Pointer); cdecl;
begin TBoolMatrix(Result^) := MatrixGT(TSingleMatrix(Params^[1]^), Single(Params^[2]^)); end;

procedure _MatrixGT_ValMat(const Params: PParamArray; const Result:Pointer); cdecl;
begin TBoolMatrix(Result^) := MatrixGT(Single(Params^[1]^), TSingleMatrix(Params^[2]^)); end;

procedure _MatrixEQ_MatVal(const Params: PParamArray; const Result:Pointer); cdecl;
begin TBoolMatrix(Result^) := MatrixEQ(TSingleMatrix(Params^[1]^), Single(Params^[2]^)); end;

procedure _MatrixEQ_ValMat(const Params: PParamArray; const Result:Pointer); cdecl;
begin TBoolMatrix(Result^) := MatrixEQ(Single(Params^[1]^), TSingleMatrix(Params^[2]^)); end;

procedure _MatrixNE_MatVal(const Params: PParamArray; const Result:Pointer); cdecl;
begin TBoolMatrix(Result^) := MatrixNE(TSingleMatrix(Params^[1]^), Single(Params^[2]^)); end;

procedure _MatrixNE_ValMat(const Params: PParamArray; const Result:Pointer); cdecl;
begin TBoolMatrix(Result^) := MatrixNE(Single(Params^[1]^), TSingleMatrix(Params^[2]^)); end;


// -----------------------------------------------------------------------------------------
// Color conversion exports

procedure _ColorToGray(const Params: PParamArray; const Result:Pointer); cdecl;
begin PByte(Result)^ := ColorToGray(PColor(Params^[0])^); end;

procedure _ColorIntensity(const Params: PParamArray; const Result:Pointer); cdecl;
begin PByte(Result)^ := ColorIntensity(PColor(Params^[0])^); end;

procedure _ColorToRGB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorRGB(Result)^ := ColorToRGB(PColor(Params^[0])^); end;

procedure _ColorToXYZ(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorXYZ(Result)^ := ColorToXYZ(PColor(Params^[0])^); end;

procedure _ColorToLAB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorLAB(Result)^ := ColorToLAB(PColor(Params^[0])^); end;

procedure _ColorToLCH(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorLCH(Result)^ := ColorToLCH(PColor(Params^[0])^); end;

procedure _ColorToHSV(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorHSV(Result)^ := ColorToHSV(PColor(Params^[0])^); end;

procedure _ColorToHSL(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorHSL(Result)^ := ColorToHSL(PColor(Params^[0])^); end;


procedure _RGBToColor(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColor(Result)^ := RGBToColor(PColorRGB(Params^[0])^); end;

procedure _RGBToXYZ(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorXYZ(Result)^ := ColorToXYZ(RGBToColor(PColorRGB(Params^[0])^)); end;

procedure _RGBToLAB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorLAB(Result)^ := ColorToLAB(RGBToColor(PColorRGB(Params^[0])^)); end;

procedure _RGBToLCH(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorLCH(Result)^ := ColorToLCH(RGBToColor(PColorRGB(Params^[0])^)); end;

procedure _RGBToHSV(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorHSV(Result)^ := ColorToHSV(RGBToColor(PColorRGB(Params^[0])^)); end;

procedure _RGBToHSL(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorHSL(Result)^ := ColorToHSL(RGBToColor(PColorRGB(Params^[0])^)); end;


procedure _XYZToColor(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColor(Result)^ := XYZToColor(PColorXYZ(Params^[0])^); end;

procedure _XYZToRGB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorRGB(Result)^ := XYZToRGB(PColorXYZ(Params^[0])^); end;

procedure _XYZToLAB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorLAB(Result)^ := XYZToLAB(PColorXYZ(Params^[0])^); end;

procedure _XYZToLCH(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorLCH(Result)^ := XYZToLCH(PColorXYZ(Params^[0])^); end;


procedure _LABToColor(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColor(Result)^ := LABToColor(PColorLAB(Params^[0])^); end;

procedure _LABToRGB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorRGB(Result)^ := LABToRGB(PColorLAB(Params^[0])^); end;

procedure _LABToXYZ(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorXYZ(Result)^ := LABToXYZ(PColorLAB(Params^[0])^); end;

procedure _LABToLCH(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorLCH(Result)^ := LABToLCH(PColorLAB(Params^[0])^); end;


procedure _LCHToColor(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColor(Result)^ := LCHToColor(PColorLCH(Params^[0])^); end;

procedure _LCHToRGB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorRGB(Result)^ := LCHToRGB(PColorLCH(Params^[0])^); end;

procedure _LCHToXYZ(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorXYZ(Result)^ := LCHToXYZ(PColorLCH(Params^[0])^); end;

procedure _LCHToLAB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorLAB(Result)^ := LCHToLAB(PColorLCH(Params^[0])^); end;


procedure _HSVToColor(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColor(Result)^ := HSVToColor(PColorHSV(Params^[0])^); end;

procedure _HSVToRGB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorRGB(Result)^ := HSVToRGB(PColorHSV(Params^[0])^); end;


procedure _HSLToColor(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColor(Result)^ := HSLToColor(PColorHSL(Params^[0])^); end;

procedure _HSLToRGB(const Params: PParamArray; const Result:Pointer); cdecl;
begin PColorRGB(Result)^ := HSLToRGB(PColorHSL(Params^[0])^); end;


// -----------------------------------------------------------------------------------------


initialization
  ExportType('TBoolMatrix',        'array of array of LongBool;');
  ExportType('TIntMatrix',         'array of array of Int32;');
  ExportType('EDistanceFormula',   '(dfRGB, dfHSV, dfHSL, dfXYZ, dfLAB, dfLCH, dfDeltaE);');
  ExportType('TChMultiplier',      'array [0..2] of Single;');
  ExportType('TColorlib',          'type Pointer');

  ExportType('TFinder',  'packed record                ' + #13#10 +
                         '  FCompareFunc: Pointer;     ' + #13#10 +
                         '  FNumThreads: UInt8;        ' + #13#10 +
                         '  FCacheSize: UInt8;         ' + #13#10 +
                         '  FColorInfo : Pointer;      ' + #13#10 +
                         '  FFormula: EDistanceFormula;' + #13#10 +
                         '  FChMul: TChMultiplier;     ' + #13#10 +
                         '  FThreadPool: TObject;      ' + #13#10 +
                         'end;');


  ExportMethod(@TFinder_Init, 'procedure TFinder.Init(Formula:EDistanceFormula=dfRGB; NumThreads:UInt8=2; CacheSize:UInt8=3);');
  ExportMethod(@TFinder_Free, 'procedure TFinder.Free();');
  ExportMethod(@TFinder_SetFormula,     'procedure TFinder.SetFormula(ComparePreset: EDistanceFormula);');
  ExportMethod(@TFinder_GetFormula,     'function  TFinder.GetFormula(): EDistanceFormula;');
  ExportMethod(@TFinder_SetNumThreads,  'procedure TFinder.SetNumThreads(N: UInt8);');
  ExportMethod(@TFinder_GetNumThreads,  'function  TFinder.GetNumThreads(): UInt8;');
  ExportMethod(@TFinder_SetMultipliers, 'procedure TFinder.SetMultipliers(const Mul: TChMultiplier);');
  ExportMethod(@TFinder_GetMultipliers, 'procedure TFinder.GetMultipliers(out Mul: TChMultiplier);');
  ExportMethod(@TFinder_GetMaxDistance, 'function  TFinder.GetMaxDistance(): Single;');
  ExportMethod(@TFinder_SimilarColors,  'function  TFinder.SimilarColors(Color1, Color2: TColor; Tolerance: Single): LongBool;');
  ExportMethod(@TFinder_ColorDistance,  'function  TFinder.ColorDistance(Color1, Color2: TColor): Single;');
  ExportMethod(@TFinder_MatchColor,     'procedure TFinder.MatchColor(Src: TIntMatrix; var Dest: TSingleMatrix; Color: TColor);');
  ExportMethod(@TFinder_FindColor,      'function  TFinder.FindColor(Src: TIntMatrix; out Dest: TPointArray; color: TColor; Tolerance: Single): Boolean;');

  ExportMethod(@_GetRawMatrix, 'function TColorlib.GetRawMatrix(data:Pointer; x1,y1,x2,y2:Int32; W,H:Int32): TIntMatrix; constref;');
  ExportMethod(@_Where,        'function TColorlib.Where(Matrix:TBoolMatrix): TPointArray; constref; native;');

  ExportMethod(@_MatrixLT_MatVal,  'function TColorlib.LessThan(Left:TSingleMatrix; Right:Single): TBoolMatrix; constref; overload; native;');
  ExportMethod(@_MatrixLT_ValMat,  'function TColorlib.LessThan(Left:Single; Right:TSingleMatrix): TBoolMatrix; constref; overload; native;');
  ExportMethod(@_MatrixGT_MatVal,  'function TColorlib.GreaterThan(Left:TSingleMatrix; Right:Single): TBoolMatrix; constref; overload; native;');
  ExportMethod(@_MatrixGT_ValMat,  'function TColorlib.GreaterThan(Left:Single; Right:TSingleMatrix): TBoolMatrix; constref; overload; native;');
  ExportMethod(@_MatrixEQ_MatVal,  'function TColorlib.EqualTo(Left:TSingleMatrix; Right:Single): TBoolMatrix; constref; overload; native;');
  ExportMethod(@_MatrixEQ_ValMat,  'function TColorlib.EqualTo(Left:Single; Right:TSingleMatrix): TBoolMatrix; constref; overload; native;');
  ExportMethod(@_MatrixNE_MatVal,  'function TColorlib.NotEqualTo(Left:TSingleMatrix; Right:Single): TBoolMatrix; constref; overload; native;');
  ExportMethod(@_MatrixNE_ValMat,  'function TColorlib.NotEqualTo(Left:Single; Right:TSingleMatrix): TBoolMatrix; constref; overload; native;');

  // -----------------------------------------------------------------------------------
  // Color conversions
  
  ExportType('ColorRGB', 'record R,G,B: Byte;   end;');
  ExportType('ColorXYZ', 'record X,Y,Z: Single; end;');
  ExportType('ColorLAB', 'record L,A,B: Single; end;');
  ExportType('ColorLCH', 'record L,C,H: Single; end;');
  ExportType('ColorHSV', 'record H,S,V: Single; end;');
  ExportType('ColorHSL', 'record H,S,L: Single; end;');
  
  ExportMethod(@_ColorToGray,    'function TColor.ToGray(): Byte; constref; native;');
  ExportMethod(@_ColorIntensity, 'function TColor.Intensity(): Byte; constref; native;');
  ExportMethod(@_ColorToRGB,   'function TColor.ToRGB(): ColorRGB; constref; native;');
  ExportMethod(@_ColorToXYZ,   'function TColor.ToXYZ(): ColorXYZ; constref; native;');
  ExportMethod(@_ColorToLAB,   'function TColor.ToLAB(): ColorLAB; constref; native;');

  ExportMethod(@_ColorToLCH, 'function TColor.ToLCH(): ColorLCH; constref; native;');
  ExportMethod(@_ColorToHSV, 'function TColor.ToHSV(): ColorHSV; constref; native;');
  ExportMethod(@_ColorToHSL, 'function TColor.ToHSL(): ColorHSL; constref; native;');

  ExportMethod(@_RGBToColor, 'function ColorRGB.ToColor(): TColor; constref; native;');
  ExportMethod(@_RGBToXYZ,   'function ColorRGB.ToXYZ(): ColorXYZ; constref; native;');
  ExportMethod(@_RGBToLAB,   'function ColorRGB.ToLAB(): ColorLAB; constref; native;');
  ExportMethod(@_RGBToLCH,   'function ColorRGB.ToLCH(): ColorLCH; constref; native;');
  ExportMethod(@_RGBToHSV,   'function ColorRGB.ToHSV(): ColorHSV; constref; native;');
  ExportMethod(@_RGBToHSL,   'function ColorRGB.ToHSL(): ColorHSL; constref; native;');
  
  ExportMethod(@_XYZToColor, 'function ColorXYZ.ToColor(): TColor; constref; native;');
  ExportMethod(@_XYZToRGB,   'function ColorXYZ.ToRGB(): ColorRGB; constref; native;');
  ExportMethod(@_XYZToLAB,   'function ColorXYZ.ToLAB(): ColorLAB; constref; native;');
  ExportMethod(@_XYZToLCH,   'function ColorXYZ.ToLCH(): ColorLCH; constref; native;');
  
  ExportMethod(@_LABToColor, 'function ColorLAB.ToColor(): TColor; constref; native;');
  ExportMethod(@_LABToRGB,   'function ColorLAB.ToRGB(): ColorRGB; constref; native;');
  ExportMethod(@_LABToXYZ,   'function ColorLAB.ToXYZ(): ColorXYZ; constref; native;');
  ExportMethod(@_LABToLCH,   'function ColorLAB.ToLCH(): ColorLCH; constref; native;');
  
  ExportMethod(@_LCHToColor, 'function ColorLCH.ToColor(): TColor; constref; native;');
  ExportMethod(@_LCHToRGB,   'function ColorLCH.ToRGB(): ColorRGB; constref; native;');
  ExportMethod(@_LCHToLAB,   'function ColorLCH.ToLAB(): ColorLAB; constref; native;');
  ExportMethod(@_LCHToXYZ,   'function ColorLCH.ToXYZ(): ColorXYZ; constref; native;');
  
  ExportMethod(@_HSVToColor, 'function ColorHSV.ToColor(): TColor; constref; native;');
  ExportMethod(@_HSVToRGB,   'function ColorHSV.ToRGB(): ColorRGB; constref; native;');
  
  ExportMethod(@_HSLToColor, 'function ColorHSL.ToColor(): TColor; constref; native;');
  ExportMethod(@_HSLToRGB,   'function ColorHSL.ToRGB(): ColorRGB; constref; native;');
end.

