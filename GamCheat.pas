unit GamCheat;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellAPI;

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

const
  // Cheat1 = 'Kmkjk'+#39+'Khyc'; {Johnny Cash}
  Cheat1 = #75+#109+#107+#106+#107+#127+#39+#75+#104+#121+#99;
  Cheat1Text = 'Unendlich Leben!';

procedure TCheatForm.AbbBtnClick(Sender: TObject);
begin
  close;
end;

procedure TCheatForm.SearchCheats;
begin
  Cheatbox.Items.Clear;
  if mainform.FCheat then Cheatbox.Items.Append(Cheat1Text);
end;

procedure TCheatForm.OKBtnClick(Sender: TObject);
var
  temp: string;
  i, j: integer;
begin
  temp := '';
  j := 0;
  for i := 1 to length(CheatEdit.text) do
  begin
    inc(j);
    temp := temp + chr(byte(copy(CheatEdit.text, i, 1)[1]) xor j);
  end;
  if lowercase(temp) = lowercase(Cheat1) then
  begin
    if mainform.FCheat then
      showmessage('Dieser Cheat wurde bereits freigeschaltet!')
    else
    begin
      showmessage('Dieser Cheat wurde freigeschaltet!');
      mainform.FCheat := true;
      SearchCheats;
    end;
    close;
  end
  else
  begin
    showmessage('Dies ist kein offizieller Cheat!');
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
begin
  if not CheatBox.items.IndexOf(Cheat1Text) = -1 then
  begin
    if CheatBox.Selected[CheatBox.items.IndexOf(Cheat1Text)] then
    begin
      if MessageDlg('Diesen Cheat wirklich deaktivieren?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        mainform.FCheat := false;
        showmessage('Dieser Cheat wurde deakiviert!');
        SearchCheats;
      end;
    end;
  end;
end;

procedure TCheatForm.Label3Click(Sender: TObject);
begin
  shellexecute(handle, 'open', pchar('mailto:daniel-marschall@viathinksoft.de?subject=Cheats für SpaceMission '+ProgramVersion), '', '', 1);
end;

end.

