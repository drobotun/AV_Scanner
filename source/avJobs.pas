unit avJobs;

interface

uses
  Windows;

type
  PSECURITY_ATTRIBUTES = ^SECURITY_ATTRIBUTES;
  _SECURITY_ATTRIBUTES = record
    nLength: DWORD;
    lpSecurityDescriptor: Pointer;
    bInheritHandle: BOOL;
  end;
  SECURITY_ATTRIBUTES = _SECURITY_ATTRIBUTES;
  LPSECURITY_ATTRIBUTES = ^SECURITY_ATTRIBUTES;
  TSecurityAttributes = SECURITY_ATTRIBUTES;
  PSecurityAttributes = PSECURITY_ATTRIBUTES;

function CreateJobObjectA(lpJobAttributes: PSecurityAttributes; lpName: PChar): THandle; stdcall;
function CreateJobObjectW(lpJobAttributes: PSecurityAttributes; lpName: PWideChar): THandle; stdcall;
function CreateJobObject(lpJobAttributes: PSecurityAttributes; lpName: PChar): THandle; stdcall;

function AssignProcessToJobObject(hJob, hProcess: THandle): BOOL; stdcall;
function TerminateJobObject(hJob: THandle; uExitCode: UINT): BOOL; stdcall;

implementation

const
  kernel32 = 'kernel32.dll';

function CreateJobObjectA; external kernel32 name 'CreateJobObjectA';
function CreateJobObjectW; external kernel32 name 'CreateJobObjectW';
function CreateJobObject; external kernel32 name 'CreateJobObjectA';

function AssignProcessToJobObject; external kernel32 name 'AssignProcessToJobObject';
function TerminateJobObject; external kernel32 name 'TerminateJobObject'; 


end.
