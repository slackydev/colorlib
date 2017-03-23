{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]
 Copyright (c) 2014, Jarl K. <Slacky> Holta || http://github.com/WarPie
 All rights reserved.
[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}
var
  methods: array of record ProcAddr: Pointer; ProcDef: PChar; end;
  typeDefs: array of record TypeName, TypeDef: PChar; end;
  
  oldMemoryManager: TMemoryManager;
  memIsset: Boolean = False;


procedure ExportMethod(ProcAddr: Pointer; ProcDef: PChar);
var len: Int32;
begin
  len := Length(methods);
  SetLength(methods, len + 1);
  methods[len].ProcAddr := ProcAddr;
  methods[len].ProcDef := ProcDef;
end;

procedure ExportNativeMethod(ProcAddr: Pointer; ProcDef: AnsiString);
begin
  ExportMethod(ProcAddr, PChar(ProcDef + ' native;'));
end;

procedure ExportType(TypeName, TypeDef: PChar);
var len: Int32;
begin
  len := Length(typeDefs);
  SetLength(typeDefs, len + 1);
  typeDefs[len].TypeName := TypeName;
  typeDefs[len].TypeDef := TypeDef;
end;

function GetPluginABIVersion: Int32; cdecl; export;
begin
  Result := 2;
end;

procedure SetPluginMemManager(memMgr: TMemoryManager); cdecl; export;
begin
  if memisset then
    exit;
  GetMemoryManager(oldMemoryManager);
  SetMemoryManager(memMgr);
  memisset := True;
end;


procedure OnDetach; cdecl; export;
begin
  SetMemoryManager(oldMemoryManager);
end;


function GetFunctionCount: Int32; cdecl; export;
begin
  Result := Length(methods);
end;

function GetFunctionInfo(x: Int32; var ProcAddr: Pointer; var ProcDef: PChar): Int32; cdecl; export;
begin
  Result := x;
  if (x > -1) and InRange(x, 0, High(methods)) then
  begin
    ProcAddr := methods[x].procAddr;
    StrPCopy(ProcDef, methods[x].ProcDef);
  end;
end;

function GetTypeCount: Int32; cdecl; export;
begin
  Result := Length(typeDefs);
end;

function GetTypeInfo(x: Int32; var TypeName, TypeDef: PChar): Int32; cdecl; export;
begin
  Result := x;
  if (x > -1) and InRange(x, 0, High(typeDefs)) then
  begin
    StrPCopy(TypeName, typeDefs[x].TypeName);
    StrPCopy(TypeDef,  typeDefs[x].TypeDef);
  end;
end;


exports GetPluginABIVersion;
exports SetPluginMemManager;
exports GetTypeCount;
exports GetTypeInfo;
exports GetFunctionCount;
exports GetFunctionInfo;
exports OnDetach;
