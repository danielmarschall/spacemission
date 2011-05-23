unit CnvMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Gauges, ShellAPI, ExtCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    Run: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    comb: TComboBox;
    gauge: TProgressBar;
    procedure RunClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  public
    FDirectory: string;
    procedure c02t03(von, an: string);
    procedure c03t04(von, an: string);
    procedure c04t10(von, an: string);
  end;

var
  MainForm: TMainForm;
  m: array[1..5] of tstrings;

implementation

{$R *.DFM}

{$R WindowsXP.res}

procedure TMainForm.RunClick(Sender: TObject);
var
  i: integer;
begin
  if comb.ItemIndex = -1 then
  begin
    MessageDLG('Bitte Umwandlungsmethode wählen!', mtError, [mbOK], 0);
    exit;
  end;
  if not DirectoryExists(FDirectory+'Temp') then CreateDir(FDirectory+'Temp');
  if not DirectoryExists(FDirectory+'Temp\1') then CreateDir(FDirectory+'Temp\1');
  if not DirectoryExists(FDirectory+'Temp\2') then CreateDir(FDirectory+'Temp\2');
  if not DirectoryExists(FDirectory+'Eingabe') then CreateDir(FDirectory+'Eingabe');
  if not DirectoryExists(FDirectory+'Ausgabe') then CreateDir(FDirectory+'Ausgabe');
  for i := 1 to 999 do
  begin
    if fileexists(FDirectory+'Temp\1\Lev'+inttostr(i)+'A1.sav') then DeleteFile(FDirectory+'Temp\1\Lev'+inttostr(i)+'A1.sav');
    if fileexists(FDirectory+'Temp\2\Lev'+inttostr(i)+'A1.sav') then DeleteFile(FDirectory+'Temp\2\Lev'+inttostr(i)+'A1.sav');
    if fileexists(FDirectory+'Temp\1\Lev'+inttostr(i)+'A2.sav') then DeleteFile(FDirectory+'Temp\1\Lev'+inttostr(i)+'A2.sav');
    if fileexists(FDirectory+'Temp\2\Lev'+inttostr(i)+'A2.sav') then DeleteFile(FDirectory+'Temp\2\Lev'+inttostr(i)+'A2.sav');
    if fileexists(FDirectory+'Temp\1\Lev'+inttostr(i)+'A3.sav') then DeleteFile(FDirectory+'Temp\1\Lev'+inttostr(i)+'A3.sav');
    if fileexists(FDirectory+'Temp\2\Lev'+inttostr(i)+'A3.sav') then DeleteFile(FDirectory+'Temp\2\Lev'+inttostr(i)+'A3.sav');
    if fileexists(FDirectory+'Temp\1\Lev'+inttostr(i)+'A4.sav') then DeleteFile(FDirectory+'Temp\1\Lev'+inttostr(i)+'A4.sav');
    if fileexists(FDirectory+'Temp\2\Lev'+inttostr(i)+'A4.sav') then DeleteFile(FDirectory+'Temp\2\Lev'+inttostr(i)+'A4.sav');
    if fileexists(FDirectory+'Temp\1\Lev'+inttostr(i)+'A5.sav') then DeleteFile(FDirectory+'Temp\1\Lev'+inttostr(i)+'A5.sav');
    if fileexists(FDirectory+'Temp\2\Lev'+inttostr(i)+'A5.sav') then DeleteFile(FDirectory+'Temp\2\Lev'+inttostr(i)+'A5.sav');
    if fileexists(FDirectory+'Temp\1\Level '+inttostr(i)+'.lev') then DeleteFile(FDirectory+'Temp\1\Level '+inttostr(i)+'.lev');
    if fileexists(FDirectory+'Temp\2\Level '+inttostr(i)+'.lev') then DeleteFile(FDirectory+'Temp\2\Level '+inttostr(i)+'.lev');
  end;
  if comb.ItemIndex = 0 then c02t03(FDirectory+'Eingabe', FDirectory+'Ausgabe');
  if comb.ItemIndex = 1 then
  begin
    c02t03(FDirectory+'Eingabe', FDirectory+'Temp\1');
    c03t04(FDirectory+'Temp\1', FDirectory+'Ausgabe');
  end;
  if comb.ItemIndex = 2 then c03t04(FDirectory+'Eingabe', FDirectory+'Ausgabe');
  if comb.ItemIndex = 3 then c04t10(FDirectory+'Eingabe', FDirectory+'Ausgabe');
  if comb.ItemIndex = 4 then
  begin
    c02t03(FDirectory+'Eingabe', FDirectory+'Temp\1');
    c03t04(FDirectory+'Temp\1', FDirectory+'Test\2');
    c04t10(FDirectory+'Temp\2', FDirectory+'Ausgabe');
  end;
  if comb.ItemIndex = 5 then
  begin
    c03t04(FDirectory+'Eingabe', FDirectory+'Temp\1');
    c04t10(FDirectory+'Temp\1', FDirectory+'Ausgabe');
  end;
end;

procedure TMainForm.c02t03(von, an: string);
var
  daten: textfile;
  lev, i, j: integer;
  ergebnis, temp: string;
begin
  for lev := 1 to 999 do
  begin
    gauge.Position := gauge.Position + 1;
    if fileexists(von+'\Lev'+inttostr(lev)+'A1.sav') then
    begin
      m[1].loadfromfile(von+'\Lev'+inttostr(lev)+'A1.sav');
      m[2].loadfromfile(von+'\Lev'+inttostr(lev)+'A2.sav');
      m[3].loadfromfile(von+'\Lev'+inttostr(lev)+'A3.sav');
      m[4].loadfromfile(von+'\Lev'+inttostr(lev)+'A4.sav');
      m[5].loadfromfile(von+'\Lev'+inttostr(lev)+'A5.sav');
      m[1].strings[0]:='-624';
      if fileexists(an+'\Lev'+inttostr(lev)+'A6.sav') then
      begin
        assignfile(daten, an+'\Lev'+inttostr(lev)+'A6.sav');
        reset(daten);
        readln(daten, ergebnis);
        temp:=ergebnis;
        closefile(daten);
      end
      else
      begin
        temp:='30000';
      end;
      assignfile(daten, an+'\Level '+inttostr(lev)+'.lev');
      rewrite(daten);
      append(daten);
      writeln(daten, '; SpaceMission 0.3');
      writeln(daten, temp);
      for j := 0 to m[1].count-2 do
      begin
        for i := 0 to m[1].count-2 do
        begin
          if strtoint(m[1].strings[i]) > strtoint(m[1].strings[i+1]) then
          begin
            m[1].exchange(i, i+1);
            m[2].exchange(i, i+1);
            m[3].exchange(i, i+1);
            m[4].exchange(i, i+1);
            m[5].exchange(i, i+1);
          end;
        end;
      end;
      for i := 0 to m[3].count-1 do
      begin
        for j := 1 to 4 do
        begin
          if j = 1 then writeln(daten, m[3].strings[i]);
          if j = 2 then writeln(daten, m[1].strings[i]);
          if j = 3 then writeln(daten, m[2].strings[i]);
          if j = 4 then writeln(daten, m[4].strings[i]);
        end;
      end;
      closefile(daten);
    end;
  end;
  gauge.Position := 0;
end;

procedure TMainForm.c03t04(von, an: string);
var
  daten, daten2: textfile;
  lev: integer;
  ergebniss: string;
begin
  for lev := 1 to 999 do
  begin
    gauge.Position := gauge.Position + 1;
    if fileexists(von+'\Level '+inttostr(lev)+'.lev') then
    begin
      assignfile(daten, von+'\Level '+inttostr(lev)+'.lev');
      reset(daten);
      assignfile(daten2, an+'\Level '+inttostr(lev)+'.lev');
      rewrite(daten2);
      while not seekeof(daten) do
      begin
        readln(daten, ergebniss);
        if ergebniss = '; SpaceMission 0.3' then
        begin
          writeln(daten2, '; SpaceMission 0.4');
          writeln(daten2, '; LEV-File');
        end
        else
        begin
          writeln(daten2, ergebniss);
        end;
      end;
      closefile(daten2);
      closefile(daten);
    end;
  end;
  gauge.Position := 0;
end;

procedure TMainForm.c04t10(von, an: string);
var
  daten, daten2: textfile;
  lev, z, act: integer;
  ergebnis: string;
begin
  for lev := 1 to 999 do
  begin
    gauge.Position := gauge.Position + 1;
    if fileexists(von+'\Level '+inttostr(lev)+'.lev') then
    begin
      assignfile(daten, von+'\Level '+inttostr(lev)+'.lev');
      reset(daten);
      assignfile(daten2, an+'\Level '+inttostr(lev)+'.lev');
      rewrite(daten2);
      z := 0;
      act := 0;
      while not seekeof(daten) do
      begin
        inc(z);
        if z > 2 then inc(act);
        if act = 5 then act := 1;
        readln(daten, ergebnis);
        if ergebnis = '; SpaceMission 0.4' then
          writeln(daten2, '; SpaceMission 1.0')
        else
        begin
          if (ergebnis = '30000') and (z = 3) then
            writeln(daten2, '1200')
          else
          begin
            //if not (((ergebnis = '0') and (z = 4)) or ((ergebnis = '-624') and (z = 5)) or ((ergebnis = '222') and (z = 6)) or ((ergebnis = '3') and (z = 7))) then
            if (z < 4) or (z > 7) then
            begin
              if act = 4 then
                writeln(daten2, inttostr(strtoint(ergebnis) + 32 - (5 * (strtoint(ergebnis) div 37))))
              else
                writeln(daten2, ergebnis);
            end;
          end;
        end;
      end;
      closefile(daten2);
      closefile(daten);
    end;
  end;
  gauge.Position := 0;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FDirectory := extractfilepath(paramstr(0));
  m[1] := TStringList.create;
  m[2] := TStringList.create;
  m[3] := TStringList.create;
  m[4] := TStringList.create;
  m[5] := TStringList.create;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  m[1].Free;
  m[2].Free;
  m[3].Free;
  m[4].Free;
  m[5].Free;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  shellexecute(handle, 'open', pchar(FDirectory+'Eingabe\'), '', '', 1);
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  shellexecute(handle, 'open', pchar(FDirectory+'Ausgabe\'), '', '', 1);
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  shellexecute(handle, 'open', pchar(FDirectory+'Levels\'), '', '', 1);
end;

end.

