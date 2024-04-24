unit GamCheat;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellAPI{$IF CompilerVersion >= 23.0}, System.UITypes{$IFEND};

type
  TCheatForm = class(TForm)                                                                    
    Label1: TLabel;
    CheatEdit: TEdit;
    OKBtn: TButton;
    AbbBtn: TButton;
    GroupBox1: TGroupBox;
    CheatBox: TListBox;
    Label2: TLabel;
    Label3: TLabel;
    procedure AbbBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure CheatEditKeyPress(Sender: TObject; var Key: Char);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
  public
    procedure SearchCheats;
  end;

var
  CheatForm: TCheatForm;

implementation

uses
  GamMain, Global;

{$R *.DFM}

procedure TCheatForm.AbbBtnClick(Sender: TObject);
begin
  close;
end;

procedure TCheatForm.SearchCheats;
begin
  Cheatbox.Items.Clear;
  if ctInfiniteLives in mainform.FCheats then Cheatbox.Items.Append(Cheat1Text);
end;

procedure TCheatForm.OKBtnClick(Sender: TObject);
resourcestring
  SCheatUnlocked = 'Dieser Cheat wurde freigeschaltet!';
  SCheckAlreadyUnlocked = 'Dieser Cheat wurde bereits freigeschaltet!';
  SNoCheat = 'Dies ist kein offizieller Cheat!';
var
  temp: string;
  i, j: integer;
begin
  temp := '';
  j := 0;

  if CheatEdit.text = '' then
  begin
    Close;
    Exit;
  end;

  for i := 1 to length(CheatEdit.text) do
  begin
    inc(j);
    temp := temp + chr(byte(copy(CheatEdit.text, i, 1)[1]) xor j);
  end;
  {$REGION 'Check and unlock Cheat 1 (Infinite lives)'}
  if lowercase(temp) = lowercase(Cheat1) then
  begin
    if ctInfiniteLives in mainform.FCheats then
      showmessage(SCheckAlreadyUnlocked)
    else
    begin
      showmessage(SCheatUnlocked);
      Include(mainform.FCheats, ctInfiniteLives);
      SearchCheats;
    end;
    close;
  end
  {$ENDREGION}
  else
  begin
    showmessage(SNoCheat);
    CheatEdit.text := '';
    CheatEdit.setfocus;
  end;
end;

procedure TCheatForm.FormShow(Sender: TObject);
begin
  mainform.dxtimer.enabled := false;
  SearchCheats;
  CheatEdit.text := '';
  CheatEdit.setfocus;
end;

procedure TCheatForm.FormHide(Sender: TObject);
begin
  if not mainform.gamepause.checked then mainform.dxtimer.enabled := true;
end;

procedure TCheatForm.CheatEditKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
  begin
    // key := #0;
    OKBtn.click;
  end;
end;

procedure TCheatForm.Label2Click(Sender: TObject);
resourcestring
  SDisableCheat = 'Diesen Cheat wirklich deaktivieren?';
  SCheatDisabled = 'Dieser Cheat wurde deaktiviert!';
begin
  {$REGION 'Disable Cheat 1 (Infinite lives)'}
  if not CheatBox.items.IndexOf(Cheat1Text) = -1 then
  begin
    if CheatBox.Selected[CheatBox.items.IndexOf(Cheat1Text)] then
    begin
      if MessageDlg(SDisableCheat, mtConfirmation, mbYesNoCancel, 0) = mrYes then
      begin
        Exclude(mainform.FCheats, ctInfiniteLives);
        showmessage(SCheatDisabled);
        SearchCheats;
      end;
    end;
  end;
  {$ENDREGION}
end;

procedure TCheatForm.Label3Click(Sender: TObject);
begin
  shellexecute(handle, 'open', pchar('mailto:daniel-marschall@viathinksoft.de?subject=Cheats für SpaceMission '+ProgramVersion), '', '', 1); // do not localize
end;

end.

