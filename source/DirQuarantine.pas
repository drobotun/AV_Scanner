unit DirQuarantine;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ShellCtrls;

type
  TDirQuarantineForm = class(TForm)
    Image1: TImage;
    ShellTreeViewQuarantine: TShellTreeView;
    Bevel: TBevel;
    QuarantineDirLabel_1: TLabel;
    ApplayQuarantineDirButton: TButton;
    CancelQuarantineDirButton: TButton;
    procedure CancelQuarantineDirButtonClick(Sender: TObject);
    procedure ApplayQuarantineDirButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShellTreeViewQuarantineClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DirQuarantineForm: TDirQuarantineForm;

implementation

uses
  avConfig, Config;

{$R *.dfm}

procedure TDirQuarantineForm.CancelQuarantineDirButtonClick(
  Sender: TObject);
begin
  Close;
end;

procedure TDirQuarantineForm.ApplayQuarantineDirButtonClick(
  Sender: TObject);
begin
  ConfigForm.PathQuarantineEdit.Text := ShellTreeViewQuarantine.Path;
  ScannerConfig.PathQuarantine := ShellTreeViewQuarantine.Path;
  Close;
end;

procedure TDirQuarantineForm.FormShow(Sender: TObject);
begin
  ApplayQuarantineDirButton.Enabled := false;
end;

procedure TDirQuarantineForm.ShellTreeViewQuarantineClick(Sender: TObject);
begin
  if DirectoryExists(ShellTreeViewQuarantine.Path + '\') then
    ApplayQuarantineDirButton.Enabled := True else
    ApplayQuarantineDirButton.Enabled := False;
end;

end.
