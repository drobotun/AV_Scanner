unit Process;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Menus;

type
  TProcessForm = class(TForm)
    Image1: TImage;
    Bevel: TBevel;
    ProcessList: TListView;
    ProcessExitButton: TButton;
    RestoreProcessButton: TButton;
    InfoLabel: TLabel;
    ProcessMenu: TPopupMenu;
    KillProcess: TMenuItem;
    ProcessInfo: TMenuItem;
    ProcessStatusBar: TStatusBar;
    TP: TMenuItem;
    erminateJobObject1: TMenuItem;
    TE: TMenuItem;
    WQ: TMenuItem;
    TT: TMenuItem;
    WC: TMenuItem;
    N1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure RestoreProcessList;
    procedure ProcessExitButtonClick(Sender: TObject);
    procedure RestoreProcessButtonClick(Sender: TObject);
    procedure TPClick(Sender: TObject);
    procedure erminateJobObject1Click(Sender: TObject);
    procedure TEClick(Sender: TObject);
    procedure WQClick(Sender: TObject);
    procedure TTClick(Sender: TObject);
    procedure WCClick(Sender: TObject);
    procedure ProcessInfoClick(Sender: TObject);
    procedure ProcessListDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProcessForm : TProcessForm;

implementation

uses
  avProcess, ProcessInfo;

{$R *.dfm}

procedure TProcessForm.RestoreProcessList;
begin
  ProcessStatusBar.Panels.Items[0].Text := 'Процессов: ' +
    inttostr(GetProcessesList(ProcessList));
end;

procedure TProcessForm.FormShow(Sender: TObject);
begin
  EnableDebugPrivileges;
  RestoreProcessList;
end;

procedure TProcessForm.ProcessExitButtonClick(Sender: TObject);
begin
  DisableDebugPrivileges;
  Close;
end;

procedure TProcessForm.RestoreProcessButtonClick(Sender: TObject);
begin
  RestoreProcessList;
end;

procedure TProcessForm.TPClick(Sender: TObject);
var
  KillProcessIndex : integer;
begin
  if ProcessList.ItemFocused.Selected then
    if MessageBox(0,'Завершить выбранный процесс?', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                KillProcessIndex := ProcessList.ItemFocused.Index;
                if KillProcessTP(strtoint(ProcessList.Items[KillProcessIndex].
                SubItems[0])) then
                  begin
                    sleep(100);
                    RestoreProcessList;
                  end
                else
                  MessageBox(0,'Ошибка завершения процесса', 'AV Scanner',
                    MB_OK or MB_ICONINFORMATION);
              end;
end;

procedure TProcessForm.erminateJobObject1Click(Sender: TObject);
var
  KillProcessIndex : integer;
begin
  if ProcessList.ItemFocused.Selected then
    if MessageBox(0,'Завершить выбранный процесс?', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                KillProcessIndex := ProcessList.ItemFocused.Index;
                if KillProcessTJ(strtoint(ProcessList.Items[KillProcessIndex].
                SubItems[0])) then
                  begin
                    sleep(100);
                    RestoreProcessList;
                  end
                else
                  MessageBox(0,'Ошибка завершения процесса', 'AV Scanner',
                    MB_OK or MB_ICONINFORMATION);
              end;
end;

procedure TProcessForm.TEClick(Sender: TObject);
var
  KillProcessIndex : integer;
begin
  if ProcessList.ItemFocused.Selected then
    if MessageBox(0,'Завершить выбранный процесс?', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                KillProcessIndex := ProcessList.ItemFocused.Index;
                if KillProcessTE(strtoint(ProcessList.Items[KillProcessIndex].
                SubItems[0])) then
                  begin
                    sleep(100);
                    RestoreProcessList;
                  end
                else
                  MessageBox(0,'Ошибка завершения процесса', 'AV Scanner',
                    MB_OK or MB_ICONINFORMATION);
              end;
end;

procedure TProcessForm.WQClick(Sender: TObject);
var
  KillProcessIndex : integer;
begin
  if ProcessList.ItemFocused.Selected then
    if MessageBox(0,'Завершить выбранный процесс?', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                KillProcessIndex := ProcessList.ItemFocused.Index;
                if KillProcessWQ(strtoint(ProcessList.Items[KillProcessIndex].
                SubItems[0])) then
                  begin
                    sleep(100);
                    RestoreProcessList;
                  end
                else
                  MessageBox(0,'Ошибка завершения процесса', 'AV Scanner',
                    MB_OK or MB_ICONINFORMATION);
              end;
end;
 
procedure TProcessForm.TTClick(Sender: TObject);
var
  KillProcessIndex : integer;
begin
  if ProcessList.ItemFocused.Selected then
    if MessageBox(0,'Завершить выбранный процесс?', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                KillProcessIndex := ProcessList.ItemFocused.Index;
                if KillProcessTT(strtoint(ProcessList.Items[KillProcessIndex].
                SubItems[0])) then
                  begin
                    sleep(100);
                    RestoreProcessList;
                  end
                else
                  MessageBox(0,'Ошибка завершения процесса', 'AV Scanner',
                    MB_OK or MB_ICONINFORMATION);
              end;
end;

procedure TProcessForm.WCClick(Sender: TObject);
var
  KillProcessIndex : integer;
begin
  if ProcessList.ItemFocused.Selected then
    if MessageBox(0,'Завершить выбранный процесс?', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                KillProcessIndex := ProcessList.ItemFocused.Index;
                if KillProcessWC(strtoint(ProcessList.Items[KillProcessIndex].
                SubItems[0])) then
                  begin
                    sleep(100);
                    RestoreProcessList;
                  end
                else
                  MessageBox(0,'Ошибка завершения процесса', 'AV Scanner',
                    MB_OK or MB_ICONINFORMATION);
              end;
end;

procedure TProcessForm.ProcessInfoClick(Sender: TObject);
begin
  ProcessInfoForm.ShowModal;
end;

procedure TProcessForm.ProcessListDblClick(Sender: TObject);
begin
  ProcessInfoForm.ShowModal;
end;

end.
