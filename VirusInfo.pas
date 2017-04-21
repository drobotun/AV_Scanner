unit VirusInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ShellApi;

type
  TVirusInfoForm = class(TForm)
    Image1: TImage;
    ScanDirLabel_1: TLabel;
    Bevel: TBevel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MD5HashEdit: TEdit;
    FileSizeEdit: TEdit;
    FileNameEdit: TEdit;
    GroupBox2: TGroupBox;
    VirusNameEdit: TEdit;
    OpenDirButton: TSpeedButton;
    Label4: TLabel;
    VirInfoExitButton: TButton;
    VirusDelButton: TButton;
    procedure OpenDirButtonClick(Sender: TObject);
    procedure VirInfoExitButtonClick(Sender: TObject);
    procedure VirusDelButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VirusInfoForm: TVirusInfoForm;

implementation

uses
  avProcess;

{$R *.dfm}

procedure TVirusInfoForm.OpenDirButtonClick(Sender: TObject);
begin
  ShellExecute(Self.Handle, 'explore', PAnsiChar(GetPathName(FileNameEdit.Text)),
              nil, nil, SW_SHOWNORMAL);
end;

procedure TVirusInfoForm.VirInfoExitButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TVirusInfoForm.VirusDelButtonClick(Sender: TObject);
begin
  if DeleteFile(VirusInfoForm.FileNameEdit.Text) then
    MessageBox(0,'Вредоносный объект удален', 'AV Scanner',
      MB_OK or MB_ICONINFORMATION)
  else
    MessageBox(0,'Ошибка удаления объекта', 'AV Scanner',
      MB_OK or MB_ICONINFORMATION);
end;

end.
