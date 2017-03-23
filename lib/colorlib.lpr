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
  math,
  header,
  finder,
  utils;

{$I SimbaPlugin.inc}

//----------------------------------------------------------------------------\\

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

procedure TFinder_SetMultipliers(var Finder:TFinder; Mul:TChannelMultiplier); cdecl;
begin
  Finder.SetMultipliers(Mul);
end;

function TFinder_GetMultipliers(var Finder:TFinder): TChannelMultiplier; cdecl;
begin
  Result := Finder.GetMultipliers();
end;

procedure TFinder_MatchColor(var Finder:TFinder; src:TIntMatrix; var dest:TFloatMatrix; color:Int32); cdecl;
begin
  Finder.MatchColor(src, dest, color);
end;

function TFinder_FindColor(var Finder:TFinder; src:TIntMatrix; out dest:TPointArray; color:TColor; tolerance:header.Float): Boolean; cdecl;
begin
  Result := Finder.FindColor(src, dest, color, Tolerance);
end;

//----------------------------------------------------------------------------\\


function _GetRawMatrix(constref _:Pointer; data:PInt32; x1,y1,x2,y2:Int32; W,H:Int32): TIntMatrix; cdecl;
begin
  Result := GetRawMatrix(data,x1,y1,x2,y2,W,H);
end;

function _Where(constref _:Pointer; Matrix:TBoolMatrix): TPointArray; cdecl;
begin
  Result := Where(Matrix);
end;

function _MatrixLT(constref _:Pointer; Left:TFloatMatrix; Right:Double): TBoolMatrix; cdecl;
begin Result := MatrixLT(Left, Right); end;

function _MatrixLT(constref _:Pointer; Left:Double; Right:TFloatMatrix): TBoolMatrix; cdecl;
begin Result := MatrixLT(Left, Right); end;

function _MatrixGT(constref _:Pointer; Left:TFloatMatrix; Right:Double): TBoolMatrix; cdecl;
begin Result := MatrixGT(Left, Right); end;

function _MatrixGT(constref _:Pointer; Left:Double; Right:TFloatMatrix): TBoolMatrix; cdecl;
begin Result := MatrixGT(Left, Right); end;

function _MatrixEQ(constref _:Pointer; Left:TFloatMatrix; Right:Double): TBoolMatrix; cdecl;
begin Result := MatrixEQ(Left, Right); end;

function _MatrixEQ(constref _:Pointer; Left:Double; Right:TFloatMatrix): TBoolMatrix; cdecl;
begin Result := MatrixEQ(Left, Right); end;

function _MatrixNE(constref _:Pointer; Left:TFloatMatrix; Right:Double): TBoolMatrix; cdecl;
begin Result := MatrixNEQ(Left, Right); end;

function _MatrixNE(constref _:Pointer; Left:Double; Right:TFloatMatrix): TBoolMatrix; cdecl;
begin Result := MatrixNEQ(Left, Right); end;


//----------------------------------------------------------------------------\\


initialization
  ExportType('TBoolMatrix',        'array of array of LongBool;');
  ExportType('TIntMatrix',         'array of array of Int32;');
  ExportType('TFloatMatrix',       'array of array of '+FLOATSTR+';');
  ExportType('EDistanceFormula',   '(dfRGB, dfHSV, dfXYZ, dfLAB, dfLCH, dfDeltaE);');
  ExportType('TChannelMultiplier', 'array [0..2] of '+FLOATSTR+';');
  ExportType('TColorlib',          'type Pointer');

  ExportType('TFinder',  'packed record                ' + #13#10 +
                         '  FCompareFunc:Pointer;      ' + #13#10 +
                         '  FNumThreads: UInt8;        ' + #13#10 +
                         '  FCacheSize: UInt8;         ' + #13#10 +
                         '  FColorInfo : Pointer;      ' + #13#10 +
                         '  FFormula: EDistanceFormula;' + #13#10 +
                         '  FChMul: TChannelMultiplier;' + #13#10 +
                         '  FThreadPool: TObject;      ' + #13#10 +
                         'end;');


  ExportMethod(@TFinder_Init, 'procedure TFinder.Init(Formula:EDistanceFormula=dfRGB; NumThreads:UInt8=2; CacheSize:UInt8=3);');
  ExportMethod(@TFinder_Free, 'procedure TFinder.Free();');
  ExportMethod(@TFinder_SetFormula,     'procedure TFinder.SetFormula(ComparePreset: EDistanceFormula);');
  ExportMethod(@TFinder_GetFormula,     'function  TFinder.GetGormula(): EDistanceFormula;');
  ExportMethod(@TFinder_SetNumThreads,  'procedure TFinder.SetNumThreads(N: UInt8);');
  ExportMethod(@TFinder_GetNumThreads,  'function  TFinder.GetNumThreads(): UInt8;');
  ExportMethod(@TFinder_SetMultipliers, 'procedure TFinder.SetMultiplier(Mul: TChannelMultiplier);');
  ExportMethod(@TFinder_GetMultipliers, 'function  TFinder.GetMultiplier(): TChannelMultiplier;');
  ExportMethod(@TFinder_MatchColor,     'procedure TFinder.MatchColor(Src:TIntMatrix; var Dest:TFloatMatrix; Color:TColor);');
  ExportMethod(@TFinder_FindColor,      'function TFinder.FindColor(src:TIntMatrix; out dest:TPointArray; color:TColor; tolerance:'+FLOATSTR+'): Boolean;');

  ExportMethod(@_GetRawMatrix, 'function TColorlib.GetRawMatrix(data:Pointer; x1,y1,x2,y2:Int32; W,H:Int32): TIntMatrix; constref;');
  ExportMethod(@_Where,        'function TColorlib.Where(Matrix:TBoolMatrix): TPointArray; constref;');

  ExportMethod(@_MatrixLT,  'function TColorlib.LessThan(Left:TFloatMatrix; Right:Double): TBoolMatrix; constref; overload;');
  ExportMethod(@_MatrixLT,  'function TColorlib.LessThan(Left:Double; Right:TFloatMatrix): TBoolMatrix; constref; overload;');
  ExportMethod(@_MatrixGT,  'function TColorlib.GreaterThan(Left:TFloatMatrix; Right:Double): TBoolMatrix; constref; overload;');
  ExportMethod(@_MatrixGT,  'function TColorlib.GreaterThan(Left:Double; Right:TFloatMatrix): TBoolMatrix; constref; overload;');
  ExportMethod(@_MatrixEQ,  'function TColorlib.EqualTo(Left:TFloatMatrix; Right:Double): TBoolMatrix; constref; overload;');
  ExportMethod(@_MatrixEQ,  'function TColorlib.EqualTo(Left:Double; Right:TFloatMatrix): TBoolMatrix; constref; overload;');
  ExportMethod(@_MatrixNE,  'function TColorlib.NotEqualTo(Left:TFloatMatrix; Right:Double): TBoolMatrix; constref; overload;');
  ExportMethod(@_MatrixNE,  'function TColorlib.NotEqualTo(Left:Double; Right:TFloatMatrix): TBoolMatrix; constref; overload;');
end.
