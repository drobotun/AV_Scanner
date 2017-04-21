unit AutoRun;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ImgList, ComCtrls, Registry, Menus, ShlObj;

type
  TAutoRunForm = class(TForm)
    Image1: TImage;
    InfoLabel: TLabel;
    AutoRunExitButton: TButton;
    Bevel: TBevel;
    AutoRunPageControl: TPageControl;
    RegistryTab_1: TTabSheet;
    RegistryTab_2: TTabSheet;
    RegistryList_1: TListView;
    RegistryTab_3: TTabSheet;
    AutoRunTab: TTabSheet;
    RegistryList_2: TListView;
    RegistryList_3: TListView;
    DelRegistryButton: TButton;
    AutoRunList: TListView;
    AutoRunMenu: TPopupMenu;
    Delete: TMenuItem;
    
    procedure AutoRunExitButtonClick(Sender: TObject);
    procedure RegistryTab_1Show(Sender: TObject);
    procedure RegistryTab_2Show(Sender: TObject);
    procedure RegistryTab_3Show(Sender: TObject);
    procedure DelRegistryButtonClick(Sender: TObject);
    procedure AutoRunTabShow(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DeleteClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  KEY_WOW64_64KEY = $0100;

var
  AutoRunForm: TAutoRunForm;

  RegAutoRun  : TRegistry;
  RegInfo     : TRegKeyInfo;
  RegList     : TStringList;
  RegItem     : TListItem;
  RegCount,
  DelRegIndex,
  index       : integer;

implementation

uses
  avEngine;

{$R *.dfm}

procedure TAutoRunForm.AutoRunExitButtonClick(Sender: TObject);
begin
  Close;
end;

function GetAutoRunFolder : string;
var s:  string;
begin
  SetLength(s, MAX_PATH);
  if not SHGetSpecialFolderPath(0, PChar(s), CSIDL_STARTUP, true)
  then s := '';
  result := PChar(s);
end;

procedure TAutoRunForm.RegistryTab_1Show(Sender: TObject);
begin
  try
    RegistryList_1.Items.Clear;
    RegList := TStringList.Create;
    RegAutoRun := TRegistry.Create(KEY_ALL_ACCESS OR KEY_WOW64_64KEY);
    RegAutoRun.RootKey := HKEY_LOCAL_MACHINE;
    RegAutoRun.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
    RegAutoRun.GetValueNames(RegList);
    for index := 0 to RegList.Count-1 do
      with RegistryList_1 do
        begin
          RegItem := Items.Add;
          RegItem.Caption := RegList.Strings[index];
          RegItem.SubItems.Add(RegAutoRun.ReadString(RegList.Strings[index]));
        end;
    finally
      RegAutoRun.Free;
      RegList.Free;
    end;
end;

procedure TAutoRunForm.RegistryTab_2Show(Sender: TObject);
begin
try
    RegistryList_2.Items.Clear;
    RegList := TStringList.Create;
    RegAutoRun := TRegistry.Create(KEY_ALL_ACCESS OR KEY_WOW64_64KEY);
    RegAutoRun.RootKey := HKEY_LOCAL_MACHINE;
    RegAutoRun.OpenKey('\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run', False);
    RegAutoRun.GetValueNames(RegList);
    for index := 0 to RegList.Count-1 do
      with RegistryList_2 do
        begin
          RegItem := Items.Add;
          RegItem.Caption := RegList.Strings[index];
          RegItem.SubItems.Add(RegAutoRun.ReadString(RegList.Strings[index]));
        end;
    finally
      RegAutoRun.Free;
      RegList.Free;
    end;
end;

procedure TAutoRunForm.RegistryTab_3Show(Sender: TObject);
begin
try
    RegistryList_3.Items.Clear;
    RegList := TStringList.Create;
    RegAutoRun := TRegistry.Create(KEY_ALL_ACCESS OR KEY_WOW64_64KEY);
    RegAutoRun.RootKey := HKEY_CURRENT_USER;
    RegAutoRun.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
    RegAutoRun.GetValueNames(RegList);
    for index := 0 to RegList.Count-1 do
      with RegistryList_3 do
        begin
          RegItem := Items.Add;
          RegItem.Caption := RegList.Strings[index];
          RegItem.SubItems.Add(RegAutoRun.ReadString(RegList.Strings[index]));
        end;
    finally
      RegAutoRun.Free;
      RegList.Free;
    end;
end;

procedure TAutoRunForm.DelRegistryButtonClick(Sender: TObject);
begin
  case AutoRunPageControl.ActivePageIndex of
    0 : begin
    try
        if RegistryList_1.ItemFocused.Selected then
          if MessageBox(0,'Удалить выбранный элемент?', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                DelRegIndex := RegistryList_1.ItemFocused.Index;
                  try
                    RegAutoRun := TRegistry.Create(KEY_ALL_ACCESS OR KEY_WOW64_64KEY);
                    RegAutoRun.RootKey := HKEY_LOCAL_MACHINE;
                    RegAutoRun.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', False);
                    if RegAutoRun.DeleteValue(RegistryList_1.Items.Item[DelRegIndex].Caption) then
                      begin
                        MessageBox(0,'Объект автозапуска удален', 'AV Scanner',
                          MB_OK or MB_ICONINFORMATION);
                        AutoRunForm.RegistryTab_1Show(Sender);
                      end
                    else
                      begin
                        MessageBox(0,'Ошибка удаления объекта', 'AV Scanner',
                          MB_OK or MB_ICONINFORMATION);
                        AutoRunForm.RegistryTab_1Show(Sender);
                      end;
                  finally
                    RegAutoRun.Free;
                  end;
              end;
    except
    end;
    end;
    1 : begin
    try
        if RegistryList_2.ItemFocused.Selected then
          if MessageBox(0,'Удалить выбранный элемент', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                DelRegIndex := RegistryList_2.ItemFocused.Index;
                  try
                    RegAutoRun := TRegistry.Create(KEY_ALL_ACCESS OR KEY_WOW64_64KEY);
                    RegAutoRun.RootKey := HKEY_LOCAL_MACHINE;
                    RegAutoRun.OpenKey('\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run', False);
                    if RegAutoRun.DeleteValue(RegistryList_2.Items.Item[DelRegIndex].Caption) then
                      begin
                        MessageBox(0,'Объект автозапуска удален', 'AV Scanner',
                          MB_OK or MB_ICONINFORMATION);
                        AutoRunForm.RegistryTab_2Show(Sender);
                      end
                    else
                      begin
                        MessageBox(0,'Ошибка удаления объекта', 'AV Scanner',
                          MB_OK or MB_ICONINFORMATION);
                        AutoRunForm.RegistryTab_1Show(Sender);
                      end;
                  finally
                    RegAutoRun.Free;
                  end;
              end;
    except
    end;
    end;
    2 : begin
    try
        if RegistryList_3.ItemFocused.Selected then
          if MessageBox(0,'Удалить выбранный элемент', 'AV Scanner',
            MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
              begin
                DelRegIndex := RegistryList_3.ItemFocused.Index;
                  try
                    RegAutoRun := TRegistry.Create(KEY_ALL_ACCESS OR KEY_WOW64_64KEY);
                    RegAutoRun.RootKey := HKEY_CURRENT_USER;
                    RegAutoRun.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', False);
                    if RegAutoRun.DeleteValue(RegistryList_3.Items.Item[DelRegIndex].Caption) then
                      begin
                        MessageBox(0,'Объект автозапуска удален', 'AV Scanner',
                          MB_OK or MB_ICONINFORMATION);
                        AutoRunForm.RegistryTab_3Show(Sender);
                      end
                    else
                      begin
                        MessageBox(0,'Ошибка удаления объекта', 'AV Scanner',
                          MB_OK or MB_ICONINFORMATION);
                        AutoRunForm.RegistryTab_1Show(Sender);
                      end;
                  finally
                    RegAutoRun.Free;
                  end;
              end;
    except
    end;
    end;
    3 : begin
      try
        if AutoRunList.ItemFocused.Selected then
          if MessageBox(0,'Удалить выбранный элемент', 'AV Scanner',
                MB_YESNO or MB_ICONQUESTION or MB_DEFBUTTON2) = mrYes then
            begin
              DelRegIndex := AutoRunList.ItemFocused.Index;
              if DeleteFile(GetAutoRunFolder + '\' + AutoRunList.Items.Item[DelRegIndex].Caption) then
                begin
                  MessageBox(0,'Объект автозапуска удален', 'AV Scanner',
                    MB_OK or MB_ICONINFORMATION);
                  AutoRunForm.AutoRunTabShow(Sender);
                end
              else
                begin
                  MessageBox(0,'Ошибка удаления объекта', 'AV Scanner',
                    MB_OK or MB_ICONINFORMATION);
                  AutoRunForm.AutoRunTabShow(Sender);
                end;
            end;
      except
      end;
      end;
  end;
end;

procedure ShowAutoRunFolder(AutoRunDir : String);
var
  SearchRec: TSearchRec;
begin
  AutoRunForm.AutoRunList.Items.Clear;
  if FindFirst(AutoRunDir + '\*.*', faAnyFile, SearchRec) = 0 then
    repeat
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and (SearchRec.Name <> 'desktop.ini') then
        AutoRunForm.AutoRunList.Items.Add.Caption := SearchRec.name;
    until FindNext(SearchRec) <> 0;
  FindClose(SearchRec);
end;

procedure TAutoRunForm.AutoRunTabShow(Sender: TObject);
begin
  ShowAutoRunFolder(GetAutoRunFolder);
end;

procedure TAutoRunForm.FormShow(Sender: TObject);
begin
  if GetBitWin = WIN_32 then
    RegistryTab_2.TabVisible := false;
end;

procedure TAutoRunForm.DeleteClick(Sender: TObject);
begin
  DelRegistryButtonClick(Sender);
end;

end.
