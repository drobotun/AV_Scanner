unit DirScan;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ShellCtrls, ExtCtrls;

type
  TDirScanForm = class(TForm)
    Image1: TImage;
    ShellTreeViewScan: TShellTreeView;
    ScanDirLabel_1: TLabel;
    CancelScanDirButton: TButton;
    ApplayScanDirButton: TButton;
    Bevel: TBevel;
    procedure CancelScanDirButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShellTreeViewScanClick(Sender: TObject);
    procedure ApplayScanDirButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DirScanForm: TDirScanForm;

implementation

uses
  Main;

{$R *.dfm}

procedure TDirScanForm.CancelScanDirButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TDirScanForm.FormShow(Sender: TObject);
begin
  ApplayScanDirButton.Enabled := false;
end;

procedure TDirScanForm.ShellTreeViewScanClick(Sender: TObject);
begin
  if DirectoryExists(ShellTreeViewScan.Path + '\') then
    ApplayScanDirButton.Enabled := True else
    ApplayScanDirButton.Enabled := False;
end;

procedure TDirScanForm.ApplayScanDirButtonClick(Sender: TObject);
begin
  with MainForm.PathList.Items.Add do
  begin
    Caption := ShellTreeViewScan.Path + '\';
    ImageIndex := 4;
  end;
  Close;
end;

end.
