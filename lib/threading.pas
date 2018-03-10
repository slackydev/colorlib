unit Threading;
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
  SysUtils, Classes, Header;

type
  TThreadMethod = procedure(params:PParamArray); 
  TThreadId = Int32;
  
  TExecThread = class(TThread)
  protected
    FMethod: TThreadMethod;
    FParams: TParamArray;
    procedure Execute; override;
  public
    Executed: Boolean;
    constructor Create();
    procedure SetMethod(Method: TThreadMethod); inline;
    procedure SetArgument(argId:Int32; arg:Pointer); inline;
  end;
  
  TThreadArray = array of record
    Thread: TExecThread;
    Available: Boolean;
    Initialized: Boolean;
  end;


  TThreadPool = class(TObject)
    FMaxThreads: SizeInt;
    FThreads: TThreadArray;

    constructor Create(MaxThreads: SizeInt);
    destructor Free();

    function GetAvailableThread(): TThreadId;
    function  NewThread(method: TThreadMethod): TThreadId;
    procedure SetArgument(t:TThreadId; argId:Int32; arg:Pointer); inline;
    procedure SetArguments(t:TThreadId; args:array of Pointer);
    procedure Start(t:TThreadId);
    function  Executed(t:TThreadId): Boolean; inline;
    procedure Release(t:TThreadId);

    procedure MatrixFunc(Method:TThreadMethod; Args: array of Pointer; W,H:Int32; nThreads:UInt8; fallback:Int32=256*256);
  end;



  
//--------------------------------------------------
implementation
uses
  Math;


(*----| WorkThread |----------------------------------------------------------*)
constructor TExecThread.Create();
begin
  FreeOnTerminate := True;
  Executed := False;
  inherited Create(True);
end;

procedure TExecThread.Execute;
begin
  FMethod(@FParams);
  Executed := True;
end;

procedure TExecThread.SetMethod(Method: TThreadMethod);
begin
  FMethod := Method;
end;

procedure TExecThread.SetArgument(argId:Int32; arg:Pointer);
begin
  Self.FParams[argId] := arg;
end;


(*----| ThreadPool |----------------------------------------------------------*)
constructor TThreadPool.Create(MaxThreads:SizeInt);
var i:Int32;
begin
  Self.FMaxThreads := MaxThreads;
  SetLength(self.FThreads, FMaxThreads);
  for i:=0 to High(self.FThreads) do
  begin
    self.FThreads[i].Available   := True;
    self.FThreads[i].Initialized := False;
  end;
end;

destructor TThreadPool.Free();
var i:Int32;
begin
  for i:=0 to High(self.FThreads) do
    self.Release(i);
end;

function TThreadPool.GetAvailableThread(): TThreadId;
var i:Int32;
begin
  for i:=0 to High(self.FThreads) do
    if self.FThreads[i].Available then
      Exit(TThreadId(i));
  raise Exception.Create('TThreadPool.GetAvailableThread: No free execution threads'); 
end;

function TThreadPool.NewThread(method: TThreadMethod): TThreadId;
begin
  result := GetAvailableThread();
  if self.FThreads[result].Thread <> nil then
    Self.Release(result);

  self.FThreads[result].Thread := TExecThread.Create();
  self.FThreads[result].Available := False;
  self.FThreads[result].Thread.SetMethod(method);
end;

procedure TThreadPool.SetArgument(t:TThreadId; argid:Int32; arg:Pointer);
begin
  self.FThreads[t].Thread.SetArgument(argid, arg);
end;

procedure TThreadPool.SetArguments(t:TThreadId; args:array of Pointer);
var arg:Int32;
begin
  for arg:=0 to High(args) do
    self.FThreads[t].Thread.SetArgument(arg, args[arg]);
end;

procedure TThreadPool.Start(t:TThreadId);
begin
  self.FThreads[t].Thread.Start;
end;

function TThreadPool.Executed(t:TThreadId): Boolean;
begin
  if (self.FThreads[t].Thread = nil) or (self.FThreads[t].Available) then
     Result := False
  else
    Result := self.FThreads[t].Thread.Executed = True;
end;

procedure TThreadPool.Release(t:TThreadId);
begin
  self.FThreads[t].Available := True;
  if self.FThreads[t].Thread <> nil then
  begin
    self.FThreads[t].Thread.Terminate();
    self.FThreads[t].Thread := nil;
  end;
end;

(*----| Functions |----------------------------------------------------------*)
procedure TThreadPool.MatrixFunc(Method:TThreadMethod; Args: array of Pointer; W,H:Int32; nThreads:UInt8; fallback:Int32=256*256);
var
  i,lo,hi,step: Int32;
  thread: array of record id: TThreadId; box: TBox; end;
  params: TParamArray;
  area: TBox;
begin
  if (W*H < fallback) or (nThreads=1) then
  begin
    area := Box(0,0,W-1,H-1);
    params := args;
    params[length(args)] := @area;
    Method(@params);
    Exit();
  end;

  nThreads := Max(1, nThreads);
  SetLength(thread, nThreads);
  
  lo := 0;
  step := (H-1) div nThreads; 
  for i:=0 to nThreads-1 do
  begin
    hi := Min(H-1, lo + step);
    
    thread[i].box := Box(0, lo, w-1, hi);
    thread[i].id := Self.NewThread(Method);
    Self.SetArguments(thread[i].id, Args);
    Self.SetArgument(thread[i].id, length(args), @thread[i].box);
    Self.Start(thread[i].id);
	
    if hi = H-1 then
    begin
      nThreads := i+1;
      Break;
    end;
    lo := hi + 1;
  end;

  for i:=0 to nThreads-1 do
  begin
    while not Self.Executed(thread[i].id) do Sleep(0);
    Self.Release(thread[i].id);
  end;
end;


end.
