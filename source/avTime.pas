unit avTime;

interface

uses
  Windows, SysUtils;

type

NTSTATUS = Cardinal;

TIME_FIELDS = packed record
  Year,
  Month,
  Day,
  Hour,
  Minute,
  Second,
  Milliseconds,
  Weekday : WORD;
end;
PTIME_FIELDS = ^TIME_FIELDS;

function RtlTimeToTimeFields(pTime : pointer;
                            pTimeFields : pointer) : NTSTATUS;
                            stdcall; external 'ntdll.dll';

//Преобразование интервала времени в стандартном формате
//в тип TDateTime Delphi
function TimeIntervalToDateTime (const ATime : LARGE_INTEGER) : TDateTime;
//Форматирование времени в формате UTC (количество интервалов по 100 наносекунд
//с 1 января 1601 года) в виде hh.mm.ss.zzz dd.mm.yyyy
function FormatUTCTime (const ATime : LARGE_INTEGER) : String;
//Форматирование временного интервала в виде (xxxx day(s)) hh:mm:ss.zzz
//Если число дней равно нулю, то временной интервал представляется
//в виде hh:mm:ss.zzz
function FormatDateTimeInterval (const ATime : TDateTime) : String;

implementation

function TimeIntervalToDateTime (const ATime : LARGE_INTEGER) : TDateTime;
var
  TimeFields : TIME_FIELDS;
begin
  RtlTimeToTimeFields (@ATime, @TimeFields);
  with TimeFields do begin
    Result := Day - 1;
    Result := Result + EncodeTime(Hour, Minute, Second, MilliSeconds);
  end;
end;

function FormatUTCTime (const ATime : LARGE_INTEGER) : String;
var
  TempTime : LARGE_INTEGER;
  Negative : Boolean;
  TimeFields : TIME_FIELDS;
const
  Signs : array[Boolean] of String = ('','-');
begin
  TempTime.QuadPart := ATime.QuadPart;
  Negative := TempTime.QuadPart < 0;
  if Negative then
    TempTime.QuadPart := -TempTime.QuadPart;
  RtlTimeToTimeFields (@TempTime, @TimeFields);
  with TimeFields do
    Result := Format('%s%.2d:%.2d:%.2d.%.3d | %.2d.%.2d.%.4d',
         [Signs[Negative],
          Hour, Minute, Second, MilliSeconds, Day, Month, Year]);
end;

function FormatDateTimeInterval (const ATime : TDateTime) : String;
var
  Days : Integer;
begin
  Days := Trunc(ATime);
  Result := FormatDateTime('hh:nn:ss.zzz', ATime);
  if Days <> 0 then
    Result := Format('(%d day(s)) ', [Days]) + Result;
end;

end.
