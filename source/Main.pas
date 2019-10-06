unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ImgList, Menus, XPMan, ShellApi,
  CommCtrl, DBT;
  
type
  TMainForm = class(TForm)
    Image1: TImage;
    AboutTopButton: TLabel;
    Logo_1: TLabel;
    Logo_2: TLabel;
    ScanTopButton: TLabel;
    OptionsTopButton: TLabel;
    PathList: TListView;
    Bevel: TBevel;
    ExitButton: TButton;
    ScanMenu: TPopupMenu;
    SelectFile: TMenuItem;
    ImageDisk: TImageList;
    OpenScanFile: TOpenDialog;
    SelScanDir: TMenuItem;
    ClearMenu: TPopupMenu;
    Clear: TMenuItem;
    N1: TMenuItem;
    ScanBegin: TMenuItem;
    ScanButton: TButton;
    N2: TMenuItem;
    AutoRunObject: TMenuItem;
    TrayMenu: TPopupMenu;
    CloseTray: TMenuItem;
    ProcessMenu: TMenuItem;
    N3: TMenuItem;
    HideTray: TMenuItem;
    RestoreTray: TMenuItem;
    procedure SelectFileClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ExitButtonClick(Sender: TObject);
    procedure OptionsTopButtonClick(Sender: TObject);
    procedure AboutTopButtonClick(Sender: TObject);
    procedure SelScanDirClick(Sender: TObject);
    procedure ScanTopButtonClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure ScanBeginClick(Sender: TObject);
    procedure ScanButtonClick(Sender: TObject);
    procedure AutoRunObjectClick(Sender: TObject);
    procedure WndProc(var Message : TMessage);
    procedure TrayMenuPopup(Sender: TObject);
    procedure CloseTrayClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ProcessMenuClick(Sender: TObject);
    procedure HideTrayClick(Sender: TObject);
    procedure RestoreTrayClick(Sender: TObject);

  private
    procedure WMDeviceChange (var Msg : TWMDeviceChange); message WM_DEVICECHANGE;
    { Private declarations }
  public
    { Public declarations }
  end;

procedure InitScanner;

const
  RetCode = #13#10;

var
  MainForm: TMainForm;

  FileCount,
  InfectCount,
  SkipCount,
  DeleteCount,
  QuarantineCount : integer;
  AllSize         : int64;

  IconTrayMessage : integer = WM_USER + 1;
  WndHandle       : HWnd;

  ScanPathList    : TStringList;
  InTray          : boolean;

implementation

uses
  Config, Scan, avMessages, avBase, avMD5Hash, avEngine, avConfig,
  About, DirScan, AutoRun, TrayIcon, Process;

{$R *.dfm}

procedure TMainForm.WMDeviceChange(var Msg : TWMDeviceChange);
var
  lpdb  : PDevBroadcastHdr;
  lpdbv : PDevBroadCastVolume;
begin
  lpdb := PDevBroadcastHdr(Msg.dwData);
  if Msg.Event = DBT_DEVICEARRIVAL then
      if lpdb^.dbcd_devicetype = DBT_DEVTYP_VOLUME then
        begin
          lpdbv := PDevBroadCastVolume(Msg.dwData);
          ShowBalloonTrayIcon(WndHandle, 0, 10, 'Обнаружено новое' + RetCode +
            'устройство - съемный диск (' + GetDiskName(lpdbv.dbcv_unitmask) + ':)',
            'AV Scanner', bitInfo);
        end;
end;

procedure TMainForm.WndProc(var Message : TMessage);
begin
  if Message.Msg = IconTrayMessage then
    if Message.LParam = WM_LBUTTONUP then
      begin
        MainForm.Show;
        if not ScanButton.Enabled then
          begin
            ScanForm.Show;
            if not ScanComplete then
              case ScannerConfig.Priority of
                PRIORITY_NORMAL : AVScanner.Priority := tpNormal;
                PRIORITY_HIGHT  : AVScanner.Priority := tpHighest;
              end;
          end;
        Application.Restore;
        Application.BringToFront;
        Application.ProcessMessages;
      end;
    if Message.LParam = WM_RBUTTONUP then
      MainForm.TrayMenu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure InitCount;
begin
  FileCount       := 0;
  InfectCount     := 0;
  SkipCount       := 0;
  DeleteCount     := 0;
  QuarantineCount := 0;
  AllSize         := 0;
end;

procedure CreatePathList(ListView: TListView);
var
  Bufer      : array[0..1024] of char;
  RealLen,
  i          : integer;
  S          : string;
begin
  ListView.Clear;
  RealLen := GetLogicalDriveStrings(SizeOf(Bufer),Bufer);
  i := 0;
  S := '';
  while i < RealLen do begin
    if Bufer[i] <> #0 then begin
      S := S + Bufer[i];
      inc(i);
    end
    else begin
      inc(i);
      with ListView.Items.Add do begin
        Caption := S;
        if GetDriveType(PChar(S)) = DRIVE_RAMDISK then ImageIndex := 3;
        if GetDriveType(PChar(S)) = DRIVE_FIXED then ImageIndex := 3;
        if GetDriveType(PChar(S)) = DRIVE_REMOTE then ImageIndex := 0;
        if GetDriveType(PChar(S)) = DRIVE_CDROM then ImageIndex := 1;
        if GetDriveType(PChar(S)) = DRIVE_REMOVABLE then ImageIndex := 2;
      end;
      S := '';
    end;
  end;
end;

function IsSelPath : boolean;
var
  index     : integer;
  PathCount : integer;
begin
  PathCount := 0;
  for index := 0 to MainForm.PathList.Items.Count-1 do
    if MainForm.PathList.Items.Item[index].Checked then
      inc (PathCount);
  if PathCount <> 0 then
    Result := true
  else
    Result := false;
end;

procedure MainEngineMessage(Mes: Integer; const Pr_0: Integer = 0; Pr_1: String = '');
begin
  case Mes of
    MES_LOADCONFIG_ERROR :
      MessageBox(0,'Ошибка загрузки конфигурации', 'AV Scanner',
      MB_OK or MB_ICONWARNING);
    MES_SAVECONFIG_OK :
      MessageBox(0,'Конфигурация сохранена', 'AV Scanner',
      MB_OK or MB_ICONINFORMATION);
    MES_SAVECONFIG_ERROR :
      MessageBox(0,'Ошибка записи конфигурации', 'AV Scanner',
      MB_OK or MB_ICONWARNING);

    MES_LOADBASE_ERROR :
      MessageBox(0,'Ошибка загрузки антивирусной базы', 'AV Scanner',
      MB_OK or MB_ICONWARNING);

    MES_SCAN_EXECUTE :
      begin
        ScanForm.AddReport(FormatDateTime('[hh:mm:ss]',now) +
            ' Cканирование запущено', 1);
        ScanForm.SaveLogButton.Enabled := false;
      end;
    MES_SCAN_COMPLETE :
      begin
        ScanForm.AddReport(FormatDateTime('[hh:mm:ss]',now) +
            ' Cканирование завершено', 1);
        ScanForm.AddReport('', 6);
        ScanForm.AddReport('Проверено файлов: ' + inttostr(FileCount), 0);
        ScanForm.AddReport('Общий объем проверенных файлов: ' +
            inttostr(AllSize div 1024) + ' kб', 0);
        ScanForm.AddReport('Инфицировано файлов: ' + inttostr(InfectCount), 0);
        ScanForm.AddReport('Пропущено файлов: ' + inttostr(SkipCount), 0);
        if ScannerConfig.FileAction = FILE_DELETE then
          ScanForm.AddReport('Удалено файлов: ' + inttostr(DeleteCount), 0);
        if ScannerConfig.FileAction = FILE_QUARANTIN then
          ScanForm.AddReport('Помещено в карантин файлов: ' +
              inttostr(QuarantineCount), 0);
        ScanForm.ScanStatusBar.Panels.Items[0].Text := ('');
        ScanForm.ScanStatusBar.Panels.Items[1].Text := ('');
        ScanForm.ScanStatusBar.Panels.Items[2].Text := ('');
        ScanForm.ScanExitButton.Enabled := true;
        ScanForm.HideModeButton.Enabled := false;
        ScanForm.SaveLogButton.Enabled := true;
        ScanForm.ScanStopButton.Enabled := false;
        if InTray then
          ShowBalloonTrayIcon(WndHandle, 0, 10, 'Сканирование завершено' + RetCode +
            'Проверено файлов: ' + inttostr(FileCount) + RetCode +
            'Инфицировано файлов: ' + inttostr(InfectCount) + RetCode +
            'Пропущено файлов: ' + inttostr(SkipCount) + RetCode +
            'Удалено файлов: ' + inttostr(DeleteCount) + RetCode +
            'Помещено в карантин файлов: ' + inttostr(QuarantineCount) + RetCode +
            'Общий объем проверенных файлов: ' + inttostr(AllSize div 1024) + ' kб',
            'AV Scanner',bitInfo);
      end;

    MES_FILE_OK :
      begin
        inc(FileCount);
        AllSize := AllSize + (Pr_0);
        ScanForm.ScanStatusBar.Panels.Items[0].Text := ('Проверено: ' + Pr_1);
        ScanForm.ScanStatusBar.Panels.Items[1].Text :=
            inttostr(FileCount) + ' файлов';
        ScanForm.ScanStatusBar.Panels.Items[2].Text :=
            inttostr(AllSize div 1048576) + ' мб';
      end;
    MES_FILE_ERROR :
      ScanForm.AddReport('Ошибка открытия файла ' + Pr_1, 3);
    MES_FILE_SKIP :
      begin
        if ScannerConfig.ShowFile then  ScanForm.AddReport('Файл ' + Pr_1 +
            ' пропущен', 4);
        inc(SkipCount);
      end;
    MES_FILE_INFECTED :
      begin
        ScanForm.AddReport('Файл ' + Pr_1 + ' инфицирован: ' + GetVirName(Pr_0), 5);
        if InTray then
          ShowBalloonTrayIcon(WndHandle, 0, 10, 'Файл ' + Pr_1 + ' инфицирован: ' +
            RetCode + GetVirName(Pr_0), 'AV Scanner', bitWarning);
        inc(InfectCount);
        if ScannerConfig.FileAction = FILE_DELETE then
          begin
            if DeleteFile(Pr_1) then
              begin
                ScanForm.AddReport('Файл ' + Pr_1 + ' удален', 2);
                inc(DeleteCount);
              end
            else
              ScanForm.AddReport('Ошибка удаления ' + Pr_1, 2)
          end;
        if ScannerConfig.FileAction = FILE_QUARANTIN then
          begin
            if MoveFile(PChar(Pr_1), PChar(ScannerConfig.PathQuarantine + '\' +
              GetVirName(Pr_0))) then
              begin
                ScanForm.AddReport('Файл ' + Pr_1 + ' помещен в карантин', 2);
                inc(QuarantineCount);
              end
            else
              ScanForm.AddReport('Ошибка перемещения ' + Pr_1, 2)
          end;
      end;
  end;
end;

procedure InitScanner;
begin
  CurrentDir := GetCurrentDir;
  WndHandle := AllocateHWnd(MainForm.WndProc);
  AddTrayIconMsg(WndHandle, 0, GetApplicationIcon, IconTrayMessage, 'AV Scanner');
  InitEngine(MainEngineMessage);
  with ConfigForm do
  begin
    PathBaseEdit.Text := ScannerConfig.PathBase;
    PathLogEdit.Text := ScannerConfig.PathLog;
    PathQuarantineEdit.Text := ScannerConfig.PathQuarantine;
    ShowFileCheckBox.Checked := ScannerConfig.ShowFile;
    AutoLogCheckBox.Checked := ScannerConfig.AutoSave;
    case ScannerConfig.FileAction of
      FILE_SKIP      : ActionFileRadioGroup.ItemIndex := 0;
      FILE_QUARANTIN : ActionFileRadioGroup.ItemIndex := 1;
      FILE_DELETE    : ActionFileRadioGroup.ItemIndex := 2;
    end;
    case ScannerConfig.Priority of
      PRIORITY_NORMAL : PriorityRadioGroup.ItemIndex := 0;
      PRIORITY_HIGHT  : PriorityRadioGroup.ItemIndex := 1;
    end;
    ExeOnlyCheckBox.Checked := ScannerConfig.ExeOnly;
  end;
  CreatePathList(MainForm.PathList);
end;

procedure TMainForm.SelectFileClick(Sender: TObject);
begin
  if OpenScanFile.Execute then
    begin
      InitCount;
      ScanForm.ReportList.Clear;
      ScanForm.Show;
      AVScanner := TScanner.Create(true);
      AVScanner.FileName := OpenScanFile.FileName;
      AVScanner.AVAction := TScanFile;
      case ScannerConfig.Priority of
        PRIORITY_NORMAL : AVScanner.Priority := tpNormal;
        PRIORITY_HIGHT  : AVScanner.Priority := tpHighest;
      end;
      AVScanner.Resume;
    end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if MessageBox(0,'Выйти из AVScanner?', 'AV Scanner',
    MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrNo then
      Action := caNone;
  DeallocateHWnd(WndHandle);
  DeleteTrayIcon(WndHandle, 0);
end;

procedure TMainForm.ExitButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.OptionsTopButtonClick(Sender: TObject);
begin
  ConfigForm.ShowModal;
end;

procedure TMainForm.AboutTopButtonClick(Sender: TObject);
begin
  AboutForm.ShowModal;
end;

procedure TMainForm.SelScanDirClick(Sender: TObject);
begin
  DirScanForm.ShowModal;
end;

procedure TMainForm.ScanTopButtonClick(Sender: TObject);
begin
  if IsSelPath then ScanBegin.Enabled := true
  else ScanBegin.Enabled := false;
  if ScanButton.Enabled then
    ScanMenu.Popup(MainForm.Left + ScanTopButton.Left, MainForm.Top +
    ScanTopButton.Top +40);
end;

procedure TMainForm.ClearClick(Sender: TObject);
begin
  CreatePathList(PathList);
end;

procedure TMainForm.ScanBeginClick(Sender: TObject);
var
  index : integer;
begin
  if BaseOK then begin
    InitCount;
    ScanForm.Show;
    ScanForm.ReportList.Clear;
    ScanForm.ScanExitButton.Enabled := false;
    MainForm.ScanButton.Enabled := false;
    ScanForm.HideModeButton.Enabled := true;
    ScanForm.ScanStopButton.Enabled := true;
    ScanPathList := TStringList.Create;
    for index := 0 to PathList.Items.Count-1 do
      if PathList.Items.Item[index].Checked = true then
        ScanPathList.Add(PathList.Items.Item[index].Caption);
      AVScanner := TScanner.Create(true);
      AVScanner.DirList := ScanPathList;
      AVScanner.AVAction := TScanDir;
      case ScannerConfig.Priority of
        PRIORITY_NORMAL : AVScanner.Priority := tpNormal;
        PRIORITY_HIGHT  : AVScanner.Priority := tpHighest;
      end;
      AVScanner.Resume;
  end
  else
    MessageBox(0,'Антивирусная база не загружена. Сканирование невозможно.',
        'AV Scanner', MB_OK or MB_ICONINFORMATION);
end;

procedure TMainForm.ScanButtonClick(Sender: TObject);
begin
  if IsSelPath then ScanBeginClick(Sender)
  else MessageBox(0,'Не указан путь сканирования', 'AV Scanner',
      MB_OK or MB_ICONINFORMATION);
end;

procedure TMainForm.AutoRunObjectClick(Sender: TObject);
begin
  AutoRunForm.ShowModal;
end;

procedure TMainForm.TrayMenuPopup(Sender: TObject);
begin
  SetForegroundWindow(MainForm.Handle);
end;

procedure TMainForm.CloseTrayClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormHide(Sender: TObject);
begin
  InTray := true;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  InTray := false;
end;

procedure TMainForm.ProcessMenuClick(Sender: TObject);
begin
  ProcessForm.ShowModal; 
end;

procedure TMainForm.HideTrayClick(Sender: TObject);
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

procedure TMainForm.RestoreTrayClick(Sender: TObject);
begin
  MainForm.Show;
  if not ScanButton.Enabled then
    begin
      ScanForm.Show;
      if not ScanComplete then
        case ScannerConfig.Priority of
          PRIORITY_NORMAL : AVScanner.Priority := tpNormal;
          PRIORITY_HIGHT  : AVScanner.Priority := tpHighest;
        end;
    end;
  Application.Restore;
  Application.BringToFront;
  Application.ProcessMessages;
end;

end.

