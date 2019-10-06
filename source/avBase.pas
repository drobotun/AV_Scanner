unit avBase;

interface

uses
  Windows, SysUtils, Classes, avMessages;

//������ � ������������ ����
type TRecords = record
  VirName : string;//��� ������
  HashMD5 : string; //MD5 - ���������
end;

var

  RecordCount  : integer;//���������� ������� � ������������ ����
  DateOfBase   : string;//���� ���������� ������������ ����
  Records      : array of TRecords;//������ � ������������ ����
  BaseOK       : boolean;

procedure LoadBase(FileName : string);
function GetRecordCount : integer;
function GetDateOfBase : string;

implementation

procedure LoadBase(FileName : string);
var
  index : integer;
  BaseFile : TStrings;
begin
  try
    BaseFile := TStringList.Create;
    BaseFile.LoadFromFile(Filename);
    RecordCount := strtoint(BaseFile.Strings[0]);
    DateOfBase := BaseFile.Strings[1];
    setlength(Records,RecordCount);
    for index := 0 to RecordCount - 1 do
      begin
        Records[index].VirName := BaseFile.Strings[2 + index * 2];
        Records[index].HashMD5 := BaseFile.Strings[3 + index * 2];
      end;
    BaseFile.Free;
    EngineMessage(MES_LOADBASE_OK);
    BaseOK := true;
  except
    EngineMessage(MES_LOADBASE_ERROR);
    BaseOK := false;
  end;
end;

function GetRecordCount : integer;
begin
  Result := RecordCount;
end;

function GetDateOfBase : string;
begin
  if BaseOK then
    Result := DateOfBase
  else
    Result := '������ ��������';
end;
end.
 