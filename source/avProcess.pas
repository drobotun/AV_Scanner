unit avProcess;

interface

uses Windows, Classes, SysUtils, ComCtrls, Messages, Dialogs, PsApi, TlHelp32,
  avJobs, avEngine;

type
  NTSTATUS = Cardinal;

const
  SystemProcessesAndThreadsInformation = 5;
  STATUS_SUCCESS = NTSTATUS($00000000);

  THREAD_TERMINATE = $0001;

  MIN_WAIT_REASON = 0;
  MAX_WAIT_REASON = 26;

  MIN_THREAD_STATE = 0;
  MAX_THREAD_STATE = 7;

type
PUnicodeString = ^TUnicodeString;
  TUnicodeString = packed record
    Length        : WORD;
    MaximumLength : WORD;
    Buffer        : PWideChar;
end;

SYSTEM_PROCESS_IMAGE_NAME_INFORMATION = packed record
    ProcessId : Cardinal;
    ImageName : TUnicodeString;
end;
PSYSTEM_PROCESS_IMAGE_NAME_INFORMATION = ^SYSTEM_PROCESS_IMAGE_NAME_INFORMATION;

PClientID = ^TClientID;
TClientID = packed record
  UniqueProcess : cardinal;
  UniqueThread  : cardinal;
end;

PSYSTEM_THREADS = ^SYSTEM_THREADS;
  SYSTEM_THREADS  = packed record
    KernelTime    : LARGE_INTEGER;
    UserTime      : LARGE_INTEGER;
    CreateTime    : LARGE_INTEGER;
    WaitTime      : ULONG;
    StartAddress  : Pointer;
    ClientID      : TClientID;
    Priority      : Integer;
    BasePriority  : Integer;
    ContextSwitchCount : ULONG;
    State         : Longint;
    WaitReason    : Longint;
    Reserved      : ULONG;
end;

PVM_COUNTERS = ^VM_COUNTERS;
VM_COUNTERS = packed record
   PeakVirtualSize,
   VirtualSize,
   PageFaultCount,
   PeakWorkingSetSize,
   WorkingSetSize,
   QuotaPeakPagedPoolUsage,
   QuotaPagedPoolUsage,
   QuotaPeakNonPagedPoolUsage,
   QuotaNonPagedPoolUsage,
   PagefileUsage,
   PeakPagefileUsage : DWORD;
end;

PIO_COUNTERS = ^IO_COUNTERS;
IO_COUNTERS = packed record
   ReadOperationCount,
   WriteOperationCount,
   OtherOperationCount,
   ReadTransferCount,
   WriteTransferCount,
   OtherTransferCount : LARGE_INTEGER;
end;

PSYSTEM_PROCESSES = ^SYSTEM_PROCESSES;
SYSTEM_PROCESSES = packed record
   NextEntryDelta,
   ThreadCount      : DWORD;
   Reserved1        : array [0..5] of dword;
   CreateTime,
   UserTime,
   KernelTime       : LARGE_INTEGER;
   ProcessName      : TUnicodeString;
   BasePriority     : DWORD;
   ProcessId,
   InheritedFromProcessId,
   HandleCount      : DWORD;
   Reserved2        : array [0..1] of dword;
   VmCounters       : VM_COUNTERS;
   PrivatePageCount : ULONG;
   IoCounters       : IO_COUNTERS;
   ThreadInfo       : array [0..0] of SYSTEM_THREADS;
end;

PTOKEN_USER = ^TOKEN_USER;
TOKEN_USER = record
  User : TSidAndAttributes;
end;

TProcessInfo = packed record
  ProcessName  : string;
  ProcessId    : cardinal;
  Path         : string;
  User         : string;
  ThreadCount  : DWORD;
  HandleCount  : DWORD;
  BasePriority : DWORD;
  ParentId     : DWORD;
  CreateTime,
  UserTime,
  KernelTime   : LARGE_INTEGER;
  PrivatePage  : ULONG;
end;


procedure EnableDebugPrivileges;
procedure DisableDebugPrivileges;
function GetProcessesList(var ProcessList : TListView) : integer;
function GetThreadList(ProcessId : cardinal; var ThreadList : TListView): integer;
function GetFileName(ProcessId : cardinal) : string;
function GetFileNameEx(ProcessId : cardinal) : string;
function GetNamebySID(destSystem: PChar; sid : PSID) : PChar;
function GetProcessUserName(ProcessId : cardinal) : PChar;

function ZwQuerySystemInformation(dwSystemInformationClass: DWORD;
                                  pSystemInformation: Pointer;
                                  dwSystemInformationLength: DWORD;
                                  var iReturnLength : DWORD): NTSTATUS;
                                  stdcall; external 'ntdll.dll';

function OpenThread(dwDesiredAccess : DWORD;
                    bInheritHandle : BOOL;
                    dwThreadId : DWORD) : THandle;
                    stdcall; external 'kernel32.dll';

function GetProcessInfo(ProcessId : cardinal) : TProcessInfo;

function GetPathName(FullFileName : string) : string;

function KillProcessTP(ProcessId : cardinal) : boolean;
function KillProcessTJ(ProcessId : cardinal) : boolean;
function KillProcessTE(ProcessId : cardinal) : boolean;
function KillProcessWQ(ProcessId : cardinal) : boolean;
function KillProcessWC(ProcessId : cardinal) : boolean;
function KillProcessTT(ProcessId : cardinal) : boolean;

function Is64Process(ProcessId : cardinal) : integer;

implementation

procedure EnableDebugPrivileges;
var
  hToken : THandle;
  tp     : TTokenPrivileges;
  DebugNameValue : Int64;
  ret            : Cardinal;
begin
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
  LookupPrivilegeValue(nil,'SeDebugPrivilege', DebugNameValue);
  tp.PrivilegeCount := 1;
  tp.Privileges[0].Luid := DebugNameValue;
  tp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
  AdjustTokenPrivileges(hToken, False, tp, sizeof(tp), nil, ret);
end;

procedure DisableDebugPrivileges;
var
  hToken : THandle;
  tp     : TTokenPrivileges;
  DebugNameValue : Int64;
  ret            : Cardinal;
begin
  OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
  LookupPrivilegeValue(nil, 'SeDebugPrivilege', DebugNameValue);
  tp.PrivilegeCount := 1;
  tp.Privileges[0].Luid := DebugNameValue;
  tp.Privileges[0].Attributes := 0;
  AdjustTokenPrivileges(hToken, False, tp, sizeof(tp), nil, ret);
end;

function GetProcessesList(var ProcessList: TListView): integer;
var
  ret           : NTSTATUS;
  pBuffer, pCur : PSYSTEM_PROCESSES;
  ReturnLength  : DWORD;
  ProcessName   : String;
  index         : integer;
  ProcessItem   : TListItem;
begin
  ProcessList.Clear;
  Result := 0;
  ReturnLength := 0;
  ZwQuerySystemInformation(SystemProcessesAndThreadsInformation,
                                  nil,
                                  0,
                                  ReturnLength);
  pBuffer := AllocMem(ReturnLength);
  ret := ZwQuerySystemInformation(SystemProcessesAndThreadsInformation,
                                  pBuffer,
                                  ReturnLength,
                                  ReturnLength);
  if ret = STATUS_SUCCESS then
  begin
    index := 0;
    pCur := pBuffer;
    while true do begin
    inc(index);
      if pCur.ProcessName.Length = 0 then ProcessName := 'System Idle Process'
        else ProcessName := WideCharToString(pCur.ProcessName.Buffer);
      with ProcessList do
        begin
          ProcessItem := Items.Add;
          ProcessItem.Caption := ProcessName;
          ProcessItem.SubItems.Add(IntToStr(pCur.ProcessId));
          ProcessItem.SubItems.Add(string(GetProcessUserName(pCur.ProcessId)));
          ProcessItem.SubItems.Add(GetFileNameEx(pCur.ProcessId));
        end;
      if pCur.NextEntryDelta = 0 then Break;
      pCur := Ptr(DWORD(pCur) + pCur.NextEntryDelta);
      end;
    Result := index;
  end;
  FreeMem(pBuffer);
end;

function GetThreadList(ProcessId : cardinal; var ThreadList : TListView): integer;
const
  ThreadStates : array[MIN_THREAD_STATE..MAX_THREAD_STATE] of String =
  ('Init', 'Ready', 'Running', 'Standby', 'Term', 'Wait', 'Trans', 'Unknown');
  WaitReasons : array[MIN_WAIT_REASON..MAX_WAIT_REASON] of String =
  ('Executive', 'FreePage', 'PageIn', 'PoolAlloc', 'DelayExec', 'Suspend',
  'UserRequest', 'WrExecutive', 'WrFreePage', 'WrPageIn', 'WrPoolAlloc',
  'WrDelayExec', 'WrSuspend', 'WrUserRequest', 'WrEventPair', 'WrQueue',
  'LpcReceive', 'WrLpcReply', 'WrVirtualMem', 'WrPageOut', 'WrRendezvous',
  'Spare2', 'Spare3', 'Spare4', 'Spare5', 'Spare6', 'WrKernel');
var
  ret           : NTSTATUS;
  pBuffer, pCur : PSYSTEM_PROCESSES;
  ReturnLength  : DWORD;
  index         : integer;
  hThread       : THandle;
  ThreadItem    : TListItem;
begin
  ThreadList.Clear;
  ReturnLength := 0;
  ZwQuerySystemInformation(SystemProcessesAndThreadsInformation,
                            nil,
                            0,
                            ReturnLength);
  GetMem(pBuffer, ReturnLength);
  ret := ZwQuerySystemInformation(SystemProcessesAndThreadsInformation,
                                  pBuffer,
                                  ReturnLength,
                                  ReturnLength);
  if ret = STATUS_SUCCESS then
  begin
    pCur := pBuffer;
    while true do begin
      if pCur.ProcessId = ProcessId then
        begin
          Result := pCur.ThreadCount;
          for index := 0 to pCur.ThreadCount-1 do
            with ThreadList do
              begin
                ThreadItem := Items.Add;
                ThreadItem.Caption := inttostr(pCur.ThreadInfo[index].ClientID.UniqueThread);
                ThreadItem.SubItems.Add('0x' +
                    inttohex(integer(pCur.ThreadInfo[index].StartAddress), 8));
                ThreadItem.SubItems.Add(inttostr(pCur.ThreadInfo[index].BasePriority));
                ThreadItem.SubItems.Add(inttostr(pCur.ThreadInfo[index].Priority));
                ThreadItem.SubItems.Add(ThreadStates[pCur.ThreadInfo[index].State]);
                if pCur.ThreadInfo[index].WaitReason < 27 then
                  ThreadItem.SubItems.Add(WaitReasons[pCur.ThreadInfo[index].WaitReason]);
                end;
        end;
      if pCur.NextEntryDelta = 0 then Break;
      pCur := Ptr(DWORD(pCur) + pCur.NextEntryDelta);
      end;
  end;
  FreeMem(pBuffer);
end;

function GetFileName(ProcessId : cardinal) : string;
var
  hProcess : THandle;
begin
  Result := '';
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, False, ProcessId);
  if hProcess <> 0 then
    try
      SetLength(Result, MAX_PATH);
      if GetModuleFileNameEx(hProcess, 0, PChar(Result), MAX_PATH) = 0 then
        Result := '';
    finally
      CloseHandle(hProcess);
    end;
end;

function DOSFileName(lpDeviceFileName: PWideChar): WideString;
var
  lpDeviceName : array[0..1024] of WideChar;
  lpDrive      : WideString;
  actDrive     : WideChar;
  FileName     : WideString;
begin
  FileName := '';
  for actDrive := 'A' to 'Z' do
  begin
    lpDrive := WideString(actDrive) + ':';
    if (QueryDosDeviceW(PWideChar(lpDrive), lpDeviceName, 1024) <> 0) then
    begin
      if (CompareStringW(LOCALE_SYSTEM_DEFAULT, NORM_IGNORECASE, lpDeviceName, lstrlenW(lpDeviceName),
        lpDeviceFileName, lstrlenW(lpDeviceName)) = CSTR_EQUAL) then
      begin
        FileName := WideString(lpDeviceFileName);
        Delete(FileName, 1, lstrlenW(lpDeviceName));
        FileName := WideString(lpDrive) + FileName;
        Result := FileName;
      end;
    end;
  end;
end;

function GetFileNameEx(ProcessId : cardinal) : string;
var
  ReturnLength  : DWORD;
  ret : NTSTATUS;
  ImageNameInformation : SYSTEM_PROCESS_IMAGE_NAME_INFORMATION;
begin
  ImageNameInformation.ProcessId := ProcessId;
  ImageNameInformation.ImageName.Length := 0;
  ImageNameInformation.ImageName.MaximumLength := $1000;
  GetMem(ImageNameInformation.ImageName.Buffer, $1000);
  ret :=  ZwQuerySystemInformation(88,
                                  @ImageNameInformation,
                                  SizeOf(ImageNameInformation),
                                  ReturnLength);
  try
    if ret = STATUS_SUCCESS then
      Result := (DOSFileName(ImageNameInformation.ImageName.Buffer))
    else
      Result := '';
  finally
    FreeMem(ImageNameInformation.ImageName.Buffer);
    ImageNameInformation.ImageName.Buffer := nil;
  end;
end;

function GetPathName(FullFileName : string) : string;
var
  StringLength : integer;
begin
  StringLength := length(FullFileName);
  while FullFileName[StringLength] <> '\' do
    dec(StringLength);
  Result := copy(FullFileName, 1, StringLength);
end;

function GetNamebySID(destSystem: PChar; sid: PSID):PChar;
var
  Domain   : PChar;
  Needed   : DWORD;
  DomLen   : DWORD;
  use      : SID_NAME_USE;
begin 
  Result := 0;
  Needed := 0;
  DomLen := 0;
  LookupAccountSid(destSystem, sid, 0, Needed, 0, DomLen,  use);
  if GetLastError = ERROR_INSUFFICIENT_BUFFER then
   begin
    Result := HeapAlloc(GetProcessHeap, 0, Needed);
    Domain := GetMemory(DomLen);
    LookupAccountSid(destSystem, sid, Result, Needed, Domain, DomLen, use);
    FreeMemory(Domain);
   end; 
end;

function GetProcessUserName(ProcessId : cardinal) : PChar;
var
  Token  : THandle;
  Info   : PTOKEN_USER;
  Needed : DWORD;
begin 
  Result := 0;
  if not OpenProcessToken(OpenProcess(PROCESS_ALL_ACCESS, FALSE, ProcessId),
    TOKEN_QUERY, Token) then
    exit;
  Needed:=0;
  GetTokenInformation(Token, TokenUser, 0, 0, Needed);
  if GetLastError = ERROR_INSUFFICIENT_BUFFER then
   begin 
   Info := HeapAlloc(GetProcessHeap, 0, Needed);
    if GetTokenInformation(Token, TokenUser, Info, Needed, Needed) then
     Result:=GetNamebySID(0, Info^.User.Sid);
    HeapFree(GetProcessHeap,0, Info);
   end; 
end;

function GetProcessInfo(ProcessId : cardinal) : TProcessInfo;
var
  ret           : NTSTATUS;
  pBuffer, pCur : PSYSTEM_PROCESSES;
  ReturnLength  : DWORD;
  ProcessName   : String;
  index         : integer;
  ProcessItem   : TListItem;
begin
  ReturnLength := 0;
  ZwQuerySystemInformation(SystemProcessesAndThreadsInformation,
                                  nil,
                                  0,
                                  ReturnLength);
  pBuffer := AllocMem(ReturnLength);
  ret := ZwQuerySystemInformation(SystemProcessesAndThreadsInformation,
                                  pBuffer,
                                  ReturnLength,
                                  ReturnLength);
  if ret = STATUS_SUCCESS then
  begin
    pCur := pBuffer;
    while true do begin
      if pCur.ProcessId = ProcessId then
        begin
          Result.ProcessId := pCur.ProcessId;
          Result.Path := GetFileNameEx(pCur.ProcessId);
          Result.User := string(GetProcessUserName(pCur.ProcessId));
          Result.ThreadCount := pCur.ThreadCount;
          Result.HandleCount := pCur.HandleCount;
          Result.BasePriority := pCur.BasePriority;
          Result.ParentId := pCur.InheritedFromProcessId;
          Result.CreateTime := pCur.CreateTime;
          Result.UserTime := pCur.UserTime;
          Result.KernelTime := pCur.KernelTime;
          Result.PrivatePage := pCur.PrivatePageCount;
          if pCur.ProcessName.Length = 0 then Result.ProcessName := 'System Idle Process'
            else Result.ProcessName := WideCharToString(pCur.ProcessName.Buffer);
        end;
      if pCur.NextEntryDelta = 0 then Break;
      pCur := Ptr(DWORD(pCur) + pCur.NextEntryDelta);
      end;
  end;
  FreeMem(pBuffer);
end;

//завершение процесса с помощью API TrminateProcess
function KillProcessTP(ProcessId : cardinal) : boolean;
var
  hProcess : THandle;
begin
  hProcess := OpenProcess(PROCESS_TERMINATE, false, ProcessId);
    if hProcess <> 0  then
      begin
        if TerminateProcess(hProcess, DWORD(-1)) then
          Result := true
        else
          Result := false;
      end
    else
      Result := false;
  CloseHandle(hProcess);
end;

//завершение процесса последовательным вызовом API- функций 
//CreateJobObject, AssignProcessToJobObject и TerminateJobObject
function KillProcessTJ(ProcessId : cardinal) : boolean;
var
  hProcess,
  hJob : THandle;
begin
  hProcess := OpenProcess(PROCESS_SET_QUOTA or PROCESS_TERMINATE, false, ProcessId);
  if hProcess <> 0 then
    begin
      hJob := CreateJobObject(nil, nil);
      if hJob <> 0 then
        begin
          if (AssignProcessToJobObject(hJob, hProcess)) then
            if (TerminateJobObject(hJob, DWORD(-1))) then
              Result := true
            else
              Result := false
          else
            Result := false;
        end
      else
        Result := false;
    end
  else
    Result := false;
  CloseHandle(hProcess);
  CloseHandle(hJob);
end;

//Завершение процесса созданием удаленного
//потока с вызовом API-функции ExitProcess
function KillProcessTE(ProcessId : cardinal) : boolean;
var
  hLibrary,
  hProcess : THandle;
  RtlCreateUserThread,
  ExitProcessAddr,
  Flag : DWORD;
begin
  hLibrary := LoadLibrary('ntdll.dll');
  RtlCreateUserThread := DWORD(GetProcAddress(hLibrary,	'RtlCreateUserThread'));
  hLibrary := LoadLibrary('kernel32.dll');
  ExitProcessAddr := DWORD(GetProcAddress(hLibrary,	'ExitProcess'));
  hProcess := OpenProcess(PROCESS_ALL_ACCESS, false, ProcessId);
  if hProcess <> 0 then
    begin
      asm
        push 0
			  push 0
			  push 0
			  push ExitProcessAddr
			  push 0
			  push 0
			  push 0
			  push 0
			  push 0
			  push hProcess
			  call RtlCreateUserThread
		  	mov Flag, eax
      end;
      if Flag = 0 then
        Result := true
      else
        Result := false;
    end
  else
    Result := false;
  CloseHandle(hProcess);
end;

//Функция обратного вызова для KillProcessWQ
function QuitWindowsProc(Wnd : HWND; Param : LPARAM) : BOOL; stdcall;
var
  ProcessId : cardinal;
begin
  GetWindowThreadProcessId(Wnd, ProcessId);
  if ProcessId = ULONG(Param) then
    PostMessage(Wnd, WM_QUIT, 0, 0);
  Result := true;
end;

//Завершение процесса путем отправки сообщения
//VM_QUIT окну процесса
function KillProcessWQ(ProcessId : cardinal) : boolean;
begin
  EnumWindows(@QuitWindowsProc, LPARAM(ProcessId));
  Result := true;
end;

//Функция обратного вызова для KillProcessWC
function CloseWindowsProc(Wnd : HWND; Param : LPARAM) : BOOL; stdcall;
var
  ProcessId : cardinal;
begin
  GetWindowThreadProcessId(Wnd, ProcessId);
  if ProcessId = ULONG(Param) then
    PostMessage(Wnd, WM_CLOSE, 0, 0);
  Result := true;
end;

//Завершение процесса путем отправки сообщения
//VM_CLOSE окну процесса
function KillProcessWC(ProcessId : cardinal) : boolean;
begin
  EnumWindows(@CloseWindowsProc, LPARAM(ProcessId));
  Result := true;
end;

//Завершение процесса путем уничтожения всех
//его потоков API-функцией TerminateThread
function KillProcessTT(ProcessId : cardinal) : boolean;
var
  ret           : NTSTATUS;
  pBuffer, pCur : PSYSTEM_PROCESSES;
  ReturnLength  : DWORD;
  index   : integer;
  hThread : THandle;
begin
  ReturnLength := 0;
  Result := true;
  ZwQuerySystemInformation(SystemProcessesAndThreadsInformation,
                            nil,
                            0,
                            ReturnLength);
  GetMem(pBuffer, ReturnLength);
  ret := ZwQuerySystemInformation(SystemProcessesAndThreadsInformation,
                                  pBuffer,
                                  ReturnLength,
                                  ReturnLength);
  if ret = STATUS_SUCCESS then
  begin
    pCur := pBuffer;
    while true do begin
      if pCur.ProcessId = ProcessId then
        for index := 0 to pCur.ThreadCount-1 do
          begin
            hThread := OpenThread(THREAD_TERMINATE,
                                  false,
                                  pCur.ThreadInfo[index].ClientID.UniqueThread);
              TerminateThread(hThread, DWORD(-1))
          end;
      if pCur.NextEntryDelta = 0 then Break;
      pCur := Ptr(DWORD(pCur) + pCur.NextEntryDelta);
      end;
  end;
  FreeMem(pBuffer);
end;

//определяет разрядность приложения в 64-разрядной Windows
//0 - не определено
//1 - 32-разрядное
//2 - 64-разрядное
function Is64Process(ProcessId : cardinal) : integer;
var
  hProcess       : THandle;
  Wow64Process   : BOOL;
begin
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION, false, ProcessId);
  if hProcess <> 0 then
    begin
      IsWow64Process(hProcess, Wow64Process);
        if Wow64Process then Result := 1
        else Result := 2;
    end
    else
      Result := 0;
end;

end.
