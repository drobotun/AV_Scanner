unit avConfig;

interface

uses
  Windows, SysUtils, Classes, avMessages;

const
  FILE_DELETE     = 0000;
  FILE_QUARANTIN  = 0001;
  FILE_SKIP       = 0002;

  PRIORITY_NORMAL = 0003;
  PRIORITY_HIGHT  = 0004;

  ConfigFileName = 'AVSConfig.cfg';

type TConfig = record
  PathBase       : string;//путь к антивирусной базе
  PathLog        : string;//путь к файлу отчета
  PathQuarantine : string;//путь к папке карантина
  AutoSave   : boolean;//признак автосохранения отчета
  ShowFile   : boolean;//отображать проверяемые файлы в отчете
  FileAction : integer;//действие с вредоносным файлов
  Priority   : integer;//приоритет потока сканирования
  ExeOnly    : boolean;//проверять только exe-файлы
end;

var
  CurrentDir : string;//текущий каталог AV Scanner
  ConfigFile : TStrings;//файл конфигурации сканера
  ScannerConfig : TConfig;//текущая конфигурация сканера

procedure LoadConfig(const ConfigFileName : string);
procedure SaveConfig(const ConfigFilename : string);

implementation

procedure LoadConfig(const ConfigFileName : string);
begin
  SetCurrentDir(CurrentDir);
  try
    ConfigFile := TStringList.Create;
    ConfigFile.LoadFromFile(ConfigFileName);
    with ScannerConfig do
    begin
      PathBase := ConfigFile.Strings[0];
      PathLog := ConfigFile.Strings[1];
      PathQuarantine := ConfigFile.Strings[2];
      if ConfigFile.Strings[3] = 'AutoSaveOn' then
        AutoSave := true
      else
        AutoSave := false;
      if ConfigFile.Strings[4] = 'ShowFileOn' then
        ShowFile := true
      else
        ShowFile := false;
      FileAction := strtoint(ConfigFile.Strings[5]);
      Priority := strtoint(ConfigFile.Strings[6]);
      if ConfigFile.Strings[7] = 'ExeOnlyOn' then
        ExeOnly := true
      else
        ExeOnly := false;
    end;
    ConfigFile.Free;
    EngineMessage(MES_LOADCONFIG_OK);
  except
    EngineMessage(MES_LOADCONFIG_ERROR);
  end;
end;

procedure SaveConfig(const ConfigFilename : string);
begin
  SetCurrentDir(CurrentDir);
  try
    ConfigFile := TStringList.Create;
    with ConfigFile do
    begin
      LoadFromFile(ConfigFilename);
      Strings[0] := ScannerConfig.PathBase;
      Strings[1] := ScannerConfig.PathLog;
      Strings[2] := ScannerConfig.PathQuarantine;
      if ScannerConfig.AutoSave then
      Strings[3] := 'AutoSaveOn'
    else
      Strings[3] := 'AutoSaveOff';
    if ScannerConfig.ShowFile then
      Strings[4] := 'ShowFileOn'
    else
      Strings[4] := 'ShowFileOff';
    case ScannerConfig.FileAction of
      FILE_DELETE    : Strings[5] := '0';
      FILE_QUARANTIN : Strings[5] := '1';
      FILE_SKIP      : Strings[5] := '2';
    end;
    case ScannerConfig.Priority of
      PRIORITY_NORMAL : Strings[6] := '3';
      PRIORITY_HIGHT  : Strings[6] := '4';
    end;
    if ScannerConfig.ExeOnly then
      Strings[7] := 'ExeFileOn'
    else
      Strings[7] := 'ExeFileOff';
    end;
    ConfigFile.SaveToFile(ConfigFilename);
    ConfigFile.Free;
    EngineMessage(MES_SAVECONFIG_OK);
  except
    EngineMessage(MES_SAVECONFIG_ERROR);
  end;
end;

end.
 