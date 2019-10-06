unit About;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi;

type
  TAboutForm = class(TForm)
    Image1: TImage;
    Logo_1: TLabel;
    Logo_3: TLabel;
    Logo_2l: TLabel;
    Logo_4: TLabel;
    CopyrightLabel_2: TLabel;
    VersionInfoBox: TGroupBox;
    VersionLabel_1: TLabel;
    VersionLabel_2: TLabel;
    VersionLabel_3: TLabel;
    VersionLabel_4: TLabel;
    InfoLabel_1: TLabel;
    AboutOkButton: TButton;
    Bevel: TBevel;
    MailLabel: TLabel;
    procedure AboutOkButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MailLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses
  avBase, avEngine;

{$R *.dfm}

procedure TAboutForm.AboutOkButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TAboutForm.FormShow(Sender: TObject);
begin
  VersionLabel_1.Caption := 'Количество записей в антивирусной базе - ' +
  inttostr(GetRecordCount);
  VersionLabel_2.Caption := 'Дата создания антивирусной базы - ' +
  GetDateOfBase;
  VersionLabel_3.Caption := 'Версия ядра - ' +
  GetEngineVersion;
  VersionLabel_4.Caption := 'Дата сборки ядра - ' +
  GetEngineDate;
  InfoLabel_1.Caption := 'Версия ОС - ' +
  GetOSVersion;
end;

procedure TAboutForm.MailLabelClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open',
               'mailto:drobotun@xaker.ru?subject=AV Scanner',
               nil, nil, SW_SHOW);
end;

end.
