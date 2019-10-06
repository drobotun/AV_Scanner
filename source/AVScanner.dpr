program AVScanner;

uses
  Forms,
  Windows,
  Main in 'Main.pas' {MainForm},
  Config in 'Config.pas' {ConfigForm},
  Scan in 'Scan.pas' {ScanForm},
  avMD5Hash in 'avMD5Hash.pas',
  avBase in 'avBase.pas',
  avMessages in 'avMessages.pas',
  avEngine in 'avEngine.pas',
  avConfig in 'avConfig.pas',
  DirQuarantine in 'DirQuarantine.pas' {DirQuarantineForm},
  About in 'About.pas' {AboutForm},
  DirScan in 'DirScan.pas' {DirScanForm},
  AutoRun in 'AutoRun.pas' {AutoRunForm},
  avLog in 'avLog.pas',
  TrayIcon in 'TrayIcon.pas',
  DBT in 'DBT.pas',
  avProcess in 'avProcess.pas',
  Process in 'Process.pas' {ProcessForm},
  avJobs in 'avJobs.pas',
  ProcessInfo in 'ProcessInfo.pas' {ProcessInfoForm},
  avTime in 'avTime.pas',
  VirusInfo in 'VirusInfo.pas' {VirusInfoForm};

{$R *.res}
var
  ScannerMutex : THandle;
  ErrorCode    : integer;

begin
  ScannerMutex := 0;
  ScannerMutex := CreateMutex(nil,false,'AVScanner');
  ErrorCode := GetLastError;
  if (ErrorCode = ERROR_ALREADY_EXISTS)or(ErrorCode = ERROR_ACCESS_DENIED) then
    begin
      MessageBox(0,'AV Scanner уже запущен', 'AV Scanner',
    MB_OK or MB_ICONINFORMATION);
      Application.Terminate;
      Exit;
    end;

  Application.Initialize;
  Application.Title := 'AV Scanner free antivirus';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TConfigForm, ConfigForm);
  Application.CreateForm(TScanForm, ScanForm);
  Application.CreateForm(TDirQuarantineForm, DirQuarantineForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TDirScanForm, DirScanForm);
  Application.CreateForm(TAutoRunForm, AutoRunForm);
  Application.CreateForm(TProcessForm, ProcessForm);
  Application.CreateForm(TProcessInfoForm, ProcessInfoForm);
  Application.CreateForm(TVirusInfoForm, VirusInfoForm);
  InitScanner;

  Application.Run;
end.
