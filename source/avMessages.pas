unit avMessages;

interface

uses
  Windows, SysUtils, Classes;

const

  MES_LOADBASE_OK    = 1000;
  MES_LOADBASE_ERROR = 1001;

  MES_LOADCONFIG_OK    = 2000;
  MES_LOADCONFIG_ERROR = 2001;
  MES_SAVECONFIG_OK    = 2002;
  MES_SAVECONFIG_ERROR = 2003;

  MES_FILE_OK          = 3000;
  MES_FILE_ERROR       = 3001;
  MES_FILE_INFECTED    = 3002;
  MES_FILE_NOTINFECTED = 3003;
  MES_FILE_SKIP        = 3004;
  MES_FILE_DELETED     = 3005;
  MES_FILE_QUARANTINE  = 3006;

  MES_SCAN_EXECUTE     = 4000;
  MES_SCAN_COMPLETE    = 4001;

type
  TEnginMessage = procedure(Mes: Integer; const Pr_0: Integer = 0; Pr_1: String = '');

var
  EngineMessage : TEnginMessage;

implementation

end.
 