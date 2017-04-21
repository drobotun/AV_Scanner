unit avEngine;

interface

uses
  Windows, SysUtils, Classes, Dialogs, ShellApi, avMessages, avBase, avConfig,
  avMD5Hash;
type
  TAction = (TScanFile,TScanDir);

type
  TScanner = class(TThread)
  private
  protected
    procedure Execute; override;
    Procedure AVScanDir;
    Procedure AVScanFile;
  public
    DirName,
    FileName  : String;
    DirList   : TStringList;
    AVAction  : TAction;
  end;

const
  EngineVersion = '2.0.1';
  EngineDate    = '18.09.2014';
  MAX_FILE_SIZE = 6000000;

  WIN_32 = 0032;
  WIN_64 = 0064;

function GetEngineVersion : string;
function GetEngineDate : string;

function GetOSVersion : string;
function GetBitWin : integer;

function GetVirName(VirNumber : integer) : string;
function GetFileSizeEx(FileName : string) : int64;

procedure InitEngine(AvEngineMessage : TEnginMessage);

function IsWow64Process(hProcess : THandle;
                        var Wow64Process : BOOL) : BOOL;
                        stdcall; external 'kernel32.dll';

var
  AVScanner    : TScanner;
  ScanComplete : boolean;

implementation

procedure InitEngine(AvEngineMessage : TEnginMessage);
begin
  EngineMessage := AvEngineMessage;
  LoadConfig(ConfigFileName);
  LoadBase(ScannerConfig.PathBase);
end;

function GetFileSizeEx(FileName : string) : int64;
var
  F: TFileStream;
begin
  try
    F := TFileStream.Create(FileName, fmOpenRead);
    Result := F.Size;
    F.Free;
  except
    result := 0;
  end;

end;

procedure ScanFile(FileName : string);
var
  index    : integer;
  FileHash : string;
begin
  try
    FileHash := MD5DigestToStr(MD5File(FileName));
    EngineMessage(MES_FILE_OK, GetFileSizeEx(FileName), FileName);
  except
    EngineMessage(MES_FILE_ERROR, 0, FileName);
    exit;
  end;
  for index := 0 to RecordCount-1 do
    begin
      if lstrcmpi(PChar(Records[index].HashMD5), PChar(FileHash)) = 0 then
        begin
          EngineMessage(MES_FILE_INFECTED, index, FileName);
          exit;
        end;
    end;
    EngineMessage(MES_FILE_NOTINFECTED, 0, FileName);
end;

procedure TScanner.AVScanFile;
begin
  ScanFile(FileName);
end;

procedure ScanDir(DirName : string);
var
  SearchRec : TSearchRec;
  FindRes   : integer;
  FileExt,
  SysExt,
  DllExt    : string;
begin
  if ScannerConfig.ExeOnly then
    begin
      SysExt := '';
      DllExt := '';
    end
  else
    begin
      SysExt := '.sys';
      DllExt := '.dll';
    end;
  ScanComplete := false;
  FindRes := FindFirst(DirName + '*.*',faAnyFile,SearchRec);
  While FindRes = 0 do
   begin
    if ScanComplete then exit;
    if ((SearchRec.Attr and faDirectory) = faDirectory) and
    ((SearchRec.Name='.')or(SearchRec.Name='..')) then
      begin
        FindRes:=FindNext(SearchRec);
        Continue;
      end;         
    if ((SearchRec.Attr and faDirectory) = faDirectory) then
      begin
        ScanDir(DirName + SearchRec.Name+'/');
        FindRes := FindNext(SearchRec);
        Continue;
      end;
    FileExt := ExtractFileExt(DirName + SearchRec.Name);
    if  (lowercase(FileExt) = lowercase('.exe')) or
        (lowercase(FileExt) = lowercase(SysExt)) or
        (lowercase(FileExt) = lowercase(DllExt)) then
      begin
        if SearchRec.Size < MAX_FILE_SIZE then
          ScanFile(DirName + SearchRec.Name)
        else
          EngineMessage(MES_FILE_SKIP, 0, DirName + SearchRec.Name);
      end;
    FindRes := FindNext(SearchRec);
  end;
  FindClose(SearchRec);
end;

procedure TScanner.AVScanDir;
var
  index : integer;
begin
  for index := 0 to DirList.Count-1 do
  begin
    if ScanComplete then break;
    ScanDir(DirList[index]);
  end;
end;

procedure TScanner.Execute;
begin
  ScanComplete := false;
  FreeOnTerminate := True;
  EngineMessage(MES_SCAN_EXECUTE);
  if AVAction = TScanFile then AVScanFile;
  if AVAction = TScanDir then AVScanDir;
  EngineMessage(MES_SCAN_COMPLETE);
  ScanComplete := true;
end;

function GetVirName(VirNumber : integer) : string;
begin
  Result := Records[VirNumber].VirName;
end;

function GetEngineVersion : string;
begin
  Result := EngineVersion;
end;

function GetEngineDate : string;
begin
  Result := EngineDate;
end;

function GetOSVersion : string;
var
  OSVersion : string;
  BitWin   : string;
begin
  case GetBitWin of
    WIN_32 : BitWin := '32-bit';
    WIN_64 : BitWin := '64-bit';
  end;
  case Win32MajorVersion of
    5 :
      case Win32MinorVersion of
        0 : OSVersion := 'Win 2000 ' + ' (сборка ' +
          inttostr(Win32BuildNumber) + ') ' + Win32CSDVersion;
        1 : OSVersion := 'Win XP ' + BitWin + ' (сборка ' +
          inttostr(Win32BuildNumber) + ') ' + Win32CSDVersion;
        2 : OSVersion := 'Win XP 64-Bit' +
          ' (сборка ' + inttostr(Win32BuildNumber) + ') ' + Win32CSDVersion;
        else OSVersion := 'Unknown version';
      end;
    6 :
      case Win32MinorVersion of
        0 : OSVersion := 'Win Vista ' + BitWin +
          ' (сборка ' + inttostr(Win32BuildNumber) + ') ' + Win32CSDVersion;
        1 : OSVersion := 'Win 7 ' + BitWin +
          ' (сборка ' + inttostr(Win32BuildNumber) + ') ' + Win32CSDVersion;
        2 : OSVersion := 'Win 8 ' + BitWin +
          ' (сборка ' + inttostr(Win32BuildNumber) + ') ' + Win32CSDVersion;
        3 : OSVersion := 'Win 8.1 ' + BitWin +
          ' (сборка ' + inttostr(Win32BuildNumber) + ') ' + Win32CSDVersion;
      end;
    else OSVersion := 'Unknown version';
  end;
  Result := OSVersion;
end;

//определяет разрядность Windows
function GetBitWin : integer;
var
  Wow64Process   : BOOL;
begin
  IsWow64Process(GetCurrentProcess, Wow64Process);
  if Wow64Process then Result := WIN_64
  else Result := WIN_32;
end;
  
end.
