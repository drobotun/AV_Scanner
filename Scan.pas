unit Scan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ImgList;

type
  TScanForm = class(TForm)
    Image1: TImage;
    InfoLabel: TLabel;
    Bevel: TBevel;
    ReportList: TListView;
    ScanStatusBar: TStatusBar;
    ScanExitButton: TButton;
    SaveLogButton: TButton;
    ImageReport: TImageList;
    ScanStopButton: TButton;
    HideModeButton: TButton;
    procedure AddReport(ReportText: String; IndexIcon: integer);
    procedure ScanExitButtonClick(Sender: TObject);
    procedure SaveLogButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ScanStopButtonClick(Sender: TObject);
    procedure HideModeButtonClick(Sender: TObject);
    procedure ReportListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ScanForm: TScanForm;

implementation

uses
  Main, Config, avEngine, avConfig, avLog, TrayIcon, VirusInfo, avMD5Hash;

{$R *.dfm}

procedure TScanForm.AddReport(ReportText: String; IndexIcon: integer);
begin
  With ScanForm.ReportList.Items.Add do begin
    Caption := ReportText;
    ImageIndex := IndexIcon;
  end;
end;

procedure TScanForm.ScanExitButtonClick(Sender: TObject);
begin
  if ConfigForm.AutoLogCheckBox.Checked and ScanForm.SaveLogButton.Enabled then
    SaveLogFile(ScannerConfig.PathLog);
  Close;
end;

procedure TScanForm.SaveLogButtonClick(Sender: TObject);
begin
  SaveLogFile(ScannerConfig.PathLog);
  ScanForm.SaveLogButton.Enabled := false;
end;

procedure TScanForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainForm.ScanButton.Enabled := true;
end;

procedure TScanForm.ScanStopButtonClick(Sender: TObject);
begin
  ScanComplete := true;
  ScanForm.ScanExitButton.Enabled := true;
  ScanForm.ScanStopButton.Enabled := false;
end;

procedure TScanForm.HideModeButtonClick(Sender: TObject);
begin
  MainForm.Hide;
  ScanForm.Hide;
  if not ScanComplete then
    begin
      AVScanner.Priority := tpLowest;
      ShowBalloonTrayIcon(WndHandle, 0, 10, 'Сканирование в фоновом режиме',
           'AV Scanner',bitInfo);
    end;
end;

function GetFileString(StringValue : string) : string;
var
  StringLength : integer;
begin
  StringLength := length(StringValue);
  while StringValue[StringLength] <> ' ' do
    dec(StringLength);
  Result := copy(StringValue, 6, StringLength - 18);
end;

function GetVirNameString(StringValue : string) : string;
var
  index,
  StringLength : integer;
begin
  StringLength := length(StringValue);
  index := 1;
  while StringValue[StringLength] <> ' ' do
    begin
      inc(index);
      dec(StringLength);
    end;
      Result := copy(StringValue, StringLength, index);
end;

procedure TScanForm.ReportListDblClick(Sender: TObject);
var
  FileSize : int64;
  FileHash : string;
begin
  if (ReportList.Selected.ImageIndex = 5) and (ScannerConfig.FileAction = FILE_SKIP) then
    begin
      VirusInfoForm.FileNameEdit.Text :=
      GetFileString(ReportList.Selected.Caption);
      VirusInfoForm.VirusNameEdit.Text :=
      GetVirNameString(ReportList.Selected.Caption);
      FileSize := GetFileSizeEx(GetFileString(ReportList.Selected.Caption));
      if FileSize <> 0 then
        VirusInfoForm.FileSizeEdit.Text := inttostr(FileSize div 1024) + ' кб'
      else
        VirusInfoForm.FileSizeEdit.Text := '';
      try
        FileHash := MD5DigestToStr(MD5File(GetFileString(ReportList.Selected.Caption)));
      except
        FileHash := '';
      end;
      VirusInfoForm.MD5HashEdit.Text := FileHash;
      VirusInfoForm.ShowModal;
    end;
end;

end.
