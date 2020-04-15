unit ioconfig;

{$mode objfpc}{$H+}

interface

uses classes;

const
  domoticzURL : string = 'http://localhost:8080/json.htm?type=devices&filter=all&used=true&order=Name';
  cMailSrv    : string = 'your-mail-server';
  cMailPort   : string = '25';
  cMailUser   : string = 'iot@example.com';
  cMailPass   : string = 'a-strong-password';
  cMailFrom   : string = 'iot@example.com';
  cMailTo     : string = 'first-info@example.com;second-info@example.com';
  
procedure ReadConfig ( _ConfigFileName:string);
  

implementation

uses inifiles;

procedure ReadConfig ( _ConfigFileName:string);
var ConfigFile : TIniFile;
begin
  ConfigFile := TIniFile.Create ( _ConfigFileName );
  try
    domoticzURL := ConfigFile.ReadString ( 'DOMOTICZ', 'URL', 'http://localhost:8080/json.htm?type=devices&filter=all&used=true&order=Name');
    
    cMailSrv  := ConfigFile.ReadString ( 'MAIL', 'Server', '');
    cMailPort := ConfigFile.ReadString ( 'MAIL', 'Port', '25');
    cMailUser := ConfigFile.ReadString ( 'MAIL', 'User', '');
    cMailPass := ConfigFile.ReadString ( 'MAIL', 'Passwd', '');
    cMailFrom := ConfigFile.ReadString ( 'MAIL', 'From', '' );
    cMailTo   := ConfigFile.ReadString ( 'MAIL', 'To', '' );
  except
    ConfigFile.Free;
  end;
end;


begin
end.
