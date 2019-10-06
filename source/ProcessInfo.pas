unit ProcessInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Menus, Buttons, ShellApi;
type
  TProcessInfoForm = class(TForm)
    Bevel: TBevel;
    Image1: TImage;
    Bevel1: TBevel;
    InfoLabel: TLabel;
    ThreadPopup: TPopupMenu;
    Restore: TMenuItem;
    ProcInfoExitButton: TButton;
    ProcessInfoPage: TPageControl;
    MainTab: TTabSheet;
    ProcessGroupBox: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ProcNameEdit: TEdit;
    ProcessIdEdit: TEdit;
    UserNameEdit: TEdit;
    ThreadEdit: TEdit;
    HandleEdit: TEdit;
    FileGroupBox: TGroupBox;
    Label1: TLabel;
    OpenDirButton: TSpeedButton;
    Label2: TLabel;
    Label3: TLabel;
    FileNameEdit: TEdit;
    FileSizeEdit: TEdit;
    MD5HashEdit: TEdit;
    ThreadTab: TTabSheet;
    ThreadList: TListView;
    ThreadStatusBar: TStatusBar;
    AdditionalTab: TTabSheet;
    ParentEdit: TEdit;
    Label9: TLabel;
    CpuGroupBox: TGroupBox;
    KernelTimeEdit: TEdit;
    UserTimeEdit: TEdit;
    TotalTimeEdit: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    InfoGroupBox: TGroupBox;
    CreateEdit: TEdit;
    Label13: TLabel;
    PrivatePageEdit: TEdit;
    Label14: TLabel;
    TypeEdit: TEdit;
    Label15: TLabel;
    procedure FormShow(Sender: TObject);
    procedure RestoreClick(Sender: TObject);
    procedure ProcInfoExitButtonClick(Sender: TObject);
    procedure OpenDirButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProcessInfoForm: TProcessInfoForm;

implementation

uses
  Process, avProcess, avEngine, avMD5Hash, avTime;

{$R *.dfm}

var
  ProcInfo : TProcessInfo;

procedure TProcessInfoForm.FormShow(Sender: TObject);
var
  GetProcessInfoIndex : integer;
  FileSize : int64;
  FileHash : string;
  TotalTime : LARGE_INTEGER;
begin
  if GetBitWin = WIN_32 then
    begin
      label15.Visible := false;
      TypeEdit.Visible := false;
    end;
  GetProcessInfoIndex := ProcessForm.ProcessList.ItemFocused.Index;
  ProcInfo := GetProcessInfo(strtoint
                (ProcessForm.ProcessList.Items[GetProcessInfoIndex].SubItems[0]));
  ProcNameEdit.Text := ProcInfo.ProcessName;
  ProcessIdEdit.Text := inttostr(ProcInfo.ProcessId);
  UserNameEdit.Text := ProcInfo.User;
  ThreadEdit.Text := inttostr(ProcInfo.ThreadCount);
  HandleEdit.Text := inttostr(ProcInfo.HandleCount);
  ParentEdit.Text := inttostr(ProcInfo.ParentId);
  CreateEdit.Text := FormatUTCTime(ProcInfo.CreateTime);
  PrivatePageEdit.Text := inttostr(ProcInfo.PrivatePage);
  KernelTimeEdit.Text := FormatDateTimeInterval
                          (TimeIntervalToDateTime(ProcInfo.KernelTime));
  UserTimeEdit.Text := FormatDateTimeInterval
                          (TimeIntervalToDateTime(ProcInfo.UserTime));
  TotalTime.QuadPart := ProcInfo.UserTime.QuadPart + ProcInfo.KernelTime.QuadPart;
  TotalTimeEdit.Text := FormatDateTimeInterval
                          (TimeIntervalToDateTime(TotalTime));
  case Is64Process(ProcInfo.ProcessId) of
    0 : TypeEdit.Text := '';
    1 : TypeEdit.Text := '32-bit';
    2 : TypeEdit.Text := '64-bit';
  end;
  FileNameEdit.Text := ProcInfo.Path;
  FileSize := GetFileSizeEx(FileNameEdit.Text);
  if FileSize <> 0 then
    FileSizeEdit.Text := inttostr(FileSize div 1024) + ' кб'
  else
    FileSizeEdit.Text := '';
  try
    FileHash := MD5DigestToStr(MD5File(FileNameEdit.Text));
  except
    FileHash := '';
  end;
  MD5HashEdit.Text := FileHash;
  if ProcInfo.Path = '' then
    OpenDirButton.Enabled := false
  else
    OpenDirButton.Enabled := true;
  ThreadStatusBar.Panels.Items[1].Text := 'Потоков: ' +
                inttostr(GetThreadList(strtoint
                (ProcessForm.ProcessList.Items[GetProcessInfoIndex].SubItems[0]),
                ThreadList));
  ThreadStatusBar.Panels.Items[0].Text := 'PID: ' +
                ProcessForm.ProcessList.Items[GetProcessInfoIndex].SubItems[0];
end;

procedure TProcessInfoForm.RestoreClick(Sender: TObject);
var
  GetProcessInfoIndex : integer;
begin
  GetProcessInfoIndex := ProcessForm.ProcessList.ItemFocused.Index;
  ThreadStatusBar.Panels.Items[1].Text := 'Потоков: ' +
                inttostr(GetThreadList(strtoint
                (ProcessForm.ProcessList.Items[GetProcessInfoIndex].SubItems[0]),
                ThreadList));
  ThreadStatusBar.Panels.Items[0].Text := 'PID: ' +
                ProcessForm.ProcessList.Items[GetProcessInfoIndex].SubItems[0];
end;

procedure TProcessInfoForm.ProcInfoExitButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TProcessInfoForm.OpenDirButtonClick(Sender: TObject);
begin
  ShellExecute(Self.Handle, 'explore', PAnsiChar(GetPathName(FileNameEdit.Text)),
              nil, nil, SW_SHOWNORMAL);
end;

end.
