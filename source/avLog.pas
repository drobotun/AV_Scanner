unit avLog;

interface

uses
  Windows,  SysUtils, Classes, Scan;

procedure SaveLogFile(FileName : string);

var
  LogFile : TStrings;

implementation

procedure SaveLogFile(FileName : string);
var index : integer;
begin
  try
    LogFile := TStringList.Create;
    LogFile.LoadFromFile(Filename);
    Logfile.Add(FormatDateTime('dddddd', Date()));
    for index := 0 to ScanForm.ReportList.Items.Count - 1 do
      LogFile.Add(ScanForm.ReportList.Items[index].Caption);
    LogFile.SaveToFile(FileName);
    LogFile.Free;
  except
    MessageBox(0,'Ошибка сохранения отчета', 'AV Scanner',
      MB_OK or MB_ICONWARNING);
  end;
end;
end.
