unit Config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Buttons;

type
  TConfigForm = class(TForm)
    Image1: TImage;
    InfoLabel: TLabel;
    Bevel: TBevel;
    Bevel1: TBevel;
    OptionsOkButton: TButton;
    OptionsCancelButton: TButton;
    SettingPageControl: TPageControl;
    GeneralTabSheet: TTabSheet;
    AdditionalTabSheet: TTabSheet;
    PathBaseEdit: TEdit;
    PathBaseLabel: TLabel;
    PathLogLabel: TLabel;
    PathLogSpeedButton: TSpeedButton;
    PathBaseSpeedButton: TSpeedButton;
    PathLogEdit: TEdit;
    PathLabel: TLabel;
    OpenPathLog: TOpenDialog;
    OpenPathBase: TOpenDialog;
    PathQuarantineEdit: TEdit;
    DirQuarantineLabel: TLabel;
    PathQuarantineSpeedButton: TSpeedButton;
    ActionFileRadioGroup: TRadioGroup;
    ShowFileCheckBox: TCheckBox;
    PriorityRadioGroup: TRadioGroup;
    AutoLogCheckBox: TCheckBox;
    ExeOnlyCheckBox: TCheckBox;
    procedure OptionsCancelButtonClick(Sender: TObject);
    procedure PathBaseSpeedButtonClick(Sender: TObject);
    procedure PathLogSpeedButtonClick(Sender: TObject);
    procedure PathQuarantineSpeedButtonClick(Sender: TObject);
    procedure OptionsOkButtonClick(Sender: TObject);
    procedure ShowFileCheckBoxClick(Sender: TObject);
    procedure AutoLogCheckBoxClick(Sender: TObject);
    procedure PriorityRadioGroupClick(Sender: TObject);
    procedure ActionFileRadioGroupClick(Sender: TObject);
    procedure ExeOnlyCheckBoxClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConfigForm: TConfigForm;

implementation

uses avConfig, DirQuarantine;

{$R *.dfm}

procedure TConfigForm.OptionsCancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TConfigForm.PathBaseSpeedButtonClick(Sender: TObject);
begin
  if OpenPathBase.Execute then
    ScannerConfig.PathBase := OpenPathBase.FileName;
    PathBaseEdit.Text := OpenPathBase.FileName;
end;

procedure TConfigForm.PathLogSpeedButtonClick(Sender: TObject);
begin
  if OpenPathLog.Execute then
    ScannerConfig.PathLog := OpenPathLog.FileName;
    PathLogEdit.Text := OpenPathLog.FileName;
end;

procedure TConfigForm.PathQuarantineSpeedButtonClick(Sender: TObject);
begin
  DirQuarantineForm.ShowModal;
end;

procedure TConfigForm.OptionsOkButtonClick(Sender: TObject);
begin
  if (PathBaseEdit.Text <> '') and
     (PathLogEdit.Text <> '') and
     (PathQuarantineEdit.Text <> '')then begin
      SaveConfig(ConfigFileName);
      Close;
    end
  else
    MessageBox(0,'Неверные параметры конфигурации', 'AV Scanner',
      MB_OK or MB_ICONWARNING);
end;

procedure TConfigForm.ShowFileCheckBoxClick(Sender: TObject);
begin
  ScannerConfig.ShowFile := ShowFileCheckBox.Checked;
end;

procedure TConfigForm.AutoLogCheckBoxClick(Sender: TObject);
begin
  ScannerConfig.AutoSave := AutoLogCheckBox.Checked;
end;

procedure TConfigForm.PriorityRadioGroupClick(Sender: TObject);
begin
  case PriorityRadioGroup.ItemIndex of
    0 : ScannerConfig.Priority := PRIORITY_NORMAL;
    1 : ScannerConfig.Priority := PRIORITY_HIGHT;
  end;
end;

procedure TConfigForm.ActionFileRadioGroupClick(Sender: TObject);
begin
  case ActionFileRadioGroup.ItemIndex of
    0 : ScannerConfig.FileAction := FILE_SKIP;
    1 : ScannerConfig.FileAction := FILE_QUARANTIN;
    2 : ScannerConfig.FileAction := FILE_DELETE;
  end;
end;

procedure TConfigForm.ExeOnlyCheckBoxClick(Sender: TObject);
begin
  ScannerConfig.ExeOnly := ExeOnlyCheckBox.Checked;
end;

end.
