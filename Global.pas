unit Global;

interface

const
  ProgramVersion = '1.2';

function FDirectory: string;

implementation

uses
  SysUtils;

function FDirectory: string;
begin
  result := extractfilepath(paramstr(0));
end;

end.
