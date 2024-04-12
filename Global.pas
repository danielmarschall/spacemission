unit Global;

interface

const
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
