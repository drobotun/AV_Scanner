unit DBT;

interface

uses Windows;

type
  TWMDeviceChange = record
    Msg    : cardinal;
    Event  : UINT;
    dwData : pointer;
    Result : longint;
  end;

type
  PDevBroadcastHdr = ^TDevBroadcastHdr;
  TDevBroadcastHdr = packed record
    dbcd_size: integer;
    dbcd_devicetype: DWORD;
    dbcd_reserved: DWORD;
  end;

type
  PDevBroadcastVolume = ^TDevBroadcastVolume;
  TDevBroadcastVolume = packed record
    dbcv_size: DWORD;
    dbcv_devicetype: DWORD;
    dbcv_reserved: DWORD;
    dbcv_unitmask: DWORD;
    dbcv_flags: Word;
  end;

const
  DBT_DEVICEARRIVAL              = $8000;
  DBT_DEVICEQUERYREMOVE          = $8001;
  DBT_DEVICEQUERYREMOVEFAILED    = $8002;
  DBT_DEVICEREMOVEPENDING        = $8003;
  DBT_DEVICEREMOVECOMPLETE       = $8004;
  DBT_DEVICETYPESPECIFIC         = $8005;

  DBT_DEVTYP_OEM                = $00000000;
  DBT_DEVTYP_DEVNODE            = $00000001;
  DBT_DEVTYP_VOLUME             = $00000002;
  DBT_DEVTYP_PORT               = $00000003;
  DBT_DEVTYP_NET                = $00000004;
  DBT_DEVTYP_DEVICEINTERFACE    = $00000005;
  DBT_DEVTYP_HANDLE             = $00000006;

function GetDiskName(UnitMask : longint) : string;

implementation

function GetDiskName(UnitMask : longint) : string;
var
  index : integer;
begin
  for index := 0 to 26 do begin
    if ((UnitMask and 1) <> 0) then break;
    UnitMask := UnitMask shr 1;
  end;
  Result := Char(integer('A')+index);
end;

end.
 