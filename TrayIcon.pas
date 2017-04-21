
{*******************************************************}
{                                                       }
{       Borland Delphi 7                                }
{       Win32 Tray Icon Unit                            }
{                                                       }
{                                                       }
{       Copyright (c) Kolesnev Denis (Poseidon)         }
{                                                       }
{                                                       }
{*******************************************************}

unit TrayIcon;

interface

uses Windows, SysUtils, ShellAPI, Forms, Classes, Messages;


type
  TBalloonTimeout = 10..30;

  TBalloonIconType = (bitNone,    // нет иконки
                      bitInfo,    // информационная иконка (синяя)
                      bitWarning, // иконка восклицания (жёлтая)
                      bitError);  // иконка ошибки (красная)

type
  NotifyIconData_50 = record // определённая в shellapi.h
    cbSize: DWORD;
    Wnd: HWND; 
    uID: UINT; 
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array[0..MAXCHAR] of AnsiChar; 
    dwState: DWORD; 
    dwStateMask: DWORD; 
    szInfo: array[0..MAXBYTE] of AnsiChar; 
    uTimeout: UINT;
    szInfoTitle: array[0..63] of AnsiChar; 
    dwInfoFlags: DWORD; 
  end{record};

const
  NIF_INFO      =       $00000010;
  NIIF_NONE     =       $00000000;
  NIIF_INFO     =       $00000001;
  NIIF_WARNING  =       $00000002;
  NIIF_ERROR    =       $00000003;


function GetApplicationIcon : hIcon; stdcall;

function AddTrayIcon
        (const Window: HWND; const IconID: Byte;
         const Icon: HICON; const Hint: String): Boolean; stdcall;

function AddTrayIconMsg(const Window: HWND; const IconID: Byte;
         const Icon: HICON; const Msg: Cardinal; const Hint: String): Boolean; stdcall;

function DeleteTrayIcon
         (const Window: HWND; const IconID: Byte): Boolean; stdcall;

function ShowBalloonTrayIcon(const Window: HWND; const IconID: Byte;
         const Timeout: TBalloonTimeout; const BalloonText,
         BalloonTitle: String; const BalloonIconType: TBalloonIconType): Boolean; stdcall;

function ModifyTrayIcon(const Window: HWND; const IconID: Byte;
         const Icon: HICON; const Hint: String): Boolean; stdcall;

function AnimateToTray(const Form: TForm):boolean; stdcall;

function AnimateFromTray(const Form: TForm):boolean; stdcall;

implementation

{получение иконки приложения}
function GetApplicationIcon : hIcon;
begin
  Result := CopyIcon(Application.Icon.Handle);
end;

{добавление иконки}
function AddTrayIcon(const Window: HWND; const IconID: Byte; const Icon: HICON; const Hint: String): Boolean;
var
  NID : NotifyIconData;
begin 
  FillChar(NID, SizeOf(NotifyIconData), 0); 
  with NID do begin 
    cbSize := SizeOf(NotifyIconData); 
    Wnd := Window; 
    uID := IconID; 
    if Hint = '' then begin 
      uFlags := NIF_ICON;
    end{if} else begin
      uFlags := NIF_ICON or NIF_TIP;
      StrPCopy(szTip, Hint);
    end{else};
    hIcon := Icon;
  end{with};
  Result := Shell_NotifyIcon(NIM_ADD, @NID);
end;

{добавляет иконку с call-back сообщением}
function AddTrayIconMsg(const Window: HWND; const IconID: Byte; const Icon: HICON; const Msg: Cardinal; const Hint: String): Boolean;
var
  NID : NotifyIconData;
begin 
  FillChar(NID, SizeOf(NotifyIconData), 0);
  with NID do begin
    cbSize := SizeOf(NotifyIconData);
    Wnd := Window;
    uID := IconID;
    if Hint = '' then begin
      uFlags := NIF_ICON or NIF_MESSAGE;
    end{if} else begin
      uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
      StrPCopy(szTip, Hint);
    end{else};
    uCallbackMessage := Msg; 
    hIcon := Icon;
  end{with};
  Result := Shell_NotifyIcon(NIM_ADD, @NID);
end;

{изменяет иконку}
function ModifyTrayIcon(const Window: HWND; const IconID: Byte; const Icon: HICON; const Hint: String): Boolean;
var
  NID : NotifyIconData;
begin
  FillChar(NID, SizeOf(NotifyIconData), 0);
  with NID do
  begin
    cbSize := SizeOf(NotifyIconData);
    Wnd := Window;
    uID := IconID;
    if Hint = ''
    then
      begin
      uFlags := NIF_ICON or NIF_MESSAGE;
      end{if} else
        begin
        uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
        StrPCopy(szTip, Hint);
        end{else};
    hIcon := Icon;
  end{with};
  Result := Shell_NotifyIcon(NIM_MODIFY, @NID);
end;

{удаляет иконку} 
function DeleteTrayIcon(const Window: HWND; const IconID: Byte): Boolean;
var 
  NID : NotifyIconData; 
begin 
  FillChar(NID, SizeOf(NotifyIconData), 0); 
  with NID do begin 
    cbSize := SizeOf(NotifyIconData); 
    Wnd := Window; 
    uID := IconID; 
  end{with}; 
  Result := Shell_NotifyIcon(NIM_DELETE, @NID); 
end;

{показать округлённое окошко подсказки}
function ShowBalloonTrayIcon(const Window: HWND; const IconID: Byte; const Timeout: TBalloonTimeout; const BalloonText, BalloonTitle: String; const BalloonIconType: TBalloonIconType): Boolean;
const
  aBalloonIconTypes : array[TBalloonIconType] of Byte = (NIIF_NONE, NIIF_INFO, NIIF_WARNING, NIIF_ERROR); 
var 
  NID_50 : NotifyIconData_50; 
begin 
  FillChar(NID_50, SizeOf(NotifyIconData_50), 0); 
  with NID_50 do
  begin
    cbSize := SizeOf(NotifyIconData_50); 
    Wnd := Window; 
    uID := IconID; 
    uFlags := NIF_INFO; 
    StrPCopy(szInfo, BalloonText); 
    uTimeout := Timeout * 1000; 
    StrPCopy(szInfoTitle, BalloonTitle);
    dwInfoFlags := aBalloonIconTypes[BalloonIconType];
  end{with}; 
  Result := Shell_NotifyIcon(NIM_MODIFY, @NID_50); 
end;

{анимация сворачивания в трей}
function AnimateToTray(const Form: TForm):boolean;
begin
  DrawAnimatedRects(Form.Handle, IDANI_CAPTION, Form.BoundsRect,
  Rect(Screen.Width,Screen.Height,Screen.Width,Screen.Height));
end;

{анимация восстановления из трея}
function AnimateFromTray(const Form: TForm):boolean;
begin
  DrawAnimatedRects(Form.Handle, IDANI_CAPTION,Rect(Screen.Width,
  Screen.Height,Screen.Width,Screen.Height),Form.BoundsRect,);
end;

End.
