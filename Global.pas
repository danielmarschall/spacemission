unit Global;

interface

const
  FCompVersion = '1.0';
  ProgramVersion = '1.1e';

function FDirectory: string;

implementation

uses
  SysUtils;

function FDirectory: string;
begin
  result := extractfilepath(paramstr(0));
end;

end.
