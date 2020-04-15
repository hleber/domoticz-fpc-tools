unit iodata;

{$mode objfpc}{$H+}
{$M+}

interface

uses
  Classes, SysUtils,
  fpjson, fpjsonrtti,
  smtpsend,ssl_openssl,
  ioconfig;



type
{ TIOData }
 TIOData = class(TPersistent)
  private
    fEStoerung_Pumpe1:boolean;
    fEStoerung_Pumpe2:boolean;
    fEStoerung_StromVS:boolean;
    fEWassermangel:boolean;
    fEPumpe1_Lauf:boolean;
    fEPumpe2_Lauf:boolean;
    fESteuerspannung:boolean;
    function SendMail( User, Password, MailFrom, MailTo, SMTPHost, SMTPPort: string; MailData: string): Boolean;
    function HtmlPara( _Signal:boolean; _UserTrueStr, _UserFalseStr, _TagTrue, _TagFalse:string ):string;
  published
    property EStoerung_Pumpe1:boolean read fEStoerung_Pumpe1 write fEStoerung_Pumpe1;
    property EStoerung_Pumpe2:boolean read fEStoerung_Pumpe2 write fEStoerung_Pumpe2;
    property EStoerung_StromVS:boolean read fEStoerung_StromVS write fEStoerung_StromVS;
    property EWassermangel:boolean read fEWassermangel write fEWassermangel;
    property EPumpe1_Lauf:boolean read fEPumpe1_Lauf write fEPumpe1_Lauf;
    property EPumpe2_Lauf:boolean read fEPumpe2_Lauf write fEPumpe2_Lauf;
    property ESteuerspannung:boolean read fESteuerspannung write fESteuerspannung;
  public
    function AsString:string;
    procedure DoMail;

end;


implementation


{ TIOData }

function TIOData.AsString: string;
var
  jsoSerialize: TJSONStreamer;
begin
  jsoSerialize := TJSONStreamer.Create(nil);
  try
    Result := jsoSerialize.ObjectToJSONString(TIOData(self));
  finally
    jsoSerialize.Free;
  end;
end;

procedure TIOData.DoMail;
var
  mailcont:string;
  fStoerung:boolean;
  SubAdd:string;
begin
  fStoerung := EStoerung_Pumpe1 OR EStoerung_StromVS OR EStoerung_Pumpe2 OR EWassermangel;
  if fStoerung then begin
    SubAdd := 'Störung';
  end else begin
    SubAdd := 'Info';
  end;


  MailCont :=
'Subject: Wasserversorgung '+SubAdd+#13+
// 'Content-Transfer-Encoding: quoted-printable'+#13+
'Content-Type: text/html; charset=UTF-8'+#13+
// 'Mime-Version: 1.0;'+#13+
// 'Content-Type: text/html; charset="UTF-8";'+#13+
// 'Content-Transfer-Encoding: UTF-8;'+#13+#13+
// '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"'+#13+
// '"http://www.w3.org/TR/html4/transitional.dtd">'+#13+
// '<meta name="viewport" content="width=device-width, initial-scale=0.95">'+#13+
// '<meta charset="utf-8">'+#13+
'<style>'+#13+
'html,'+#13+
'body {padding: 0;margin: 0;}'+#13+
'main'+#13+
'h2 {color: black;background:none;border: 0px solid;border-radius:0;margin:5;padding:3;}'+#13+
'h3 {color: blue;background:gray;border: 1px solid;border-radius:1em;margin:5;padding:3;}'+#13+
'ptop {align:center;color: white;background-color:grey;margin:1em;padding:10px;}'+#13+
'pwhite {width:100px;color: black;background-color:white;border:2px solid blue; border-radius: 5px 5px 5px 5px;margin:1em;padding:8px;}'+#13+
'pred {width:100px;color: white;background-color:red;border:2px solid blue; border-radius: 0 5px 0em 5px;margin:1em;padding:8px;}'+#13+
'pgreen {width:100px;color:white;background-color:green;border:2px solid blue;border-radius: 0 5px 0em 5px;margin:1em;padding: 8px;}'+#13+
'p {width: 80%;color: blue;background-color: white;border: 2px solid blue;border-radius: 0 1em 0em 1em;margin: 1em;padding: 1em;margin-left: auto; margin-right: auto;}'+#13+
'h1.blocktext { text-align: center; }'+#13+
'h1.art { color: red; text-align: center; }'+#13+
'</style>'+#13+
'<div id=''body''>'+#13+
'<main>'+#13+
'<h2 class="blocktext">Wasserversorgung</h2>'+#13+
'<h3 class="art">'+SubAdd+'</h3>'+#13+
'<hr>'+#13+
'<ptop>Zeitpunkt: '+FormatDatetime ( 'YYYY-MM-DD hh:nn:ss.zzz', Now)+'</ptop>'+#13+
'<p>'+#13+
'  <nbr>Pumpenstörung</nbr>'+#13+
HtmlPara( EStoerung_Pumpe1, '1 Störung', '1 OK', 'pred', 'pwhite' )+ #13+
HtmlPara( EStoerung_Pumpe2, '2 Störung', '2 OK', 'pred', 'pwhite' )+ #13+
'</p>'+#13+
'<p>'+#13+
'  <nbr>Pumpen-Laufmeldung</nbr>'+#13+
HtmlPara( EPumpe1_Lauf, '[Läuft 1]','1 Steht', 'pgreen', 'pwhite' )+ #13+
HtmlPara( EPumpe2_Lauf, '[Läuft 2]','2 Steht', 'pgreen', 'pwhite' )+ #13+
'</p>'+#13+
'<p>'+#13+
'  <nbr>Wasser</nbr>'+#13+
HtmlPara( EWassermangel, 'Wassermangel', 'Stand I.O.', 'pred', 'pgreen'  )+ #13+
'</p>'+#13+
'<p>'+#13+
'  <nbr>Steuerspannung  </nbr>'+#13+
HtmlPara( ESteuerspannung, 'OK', 'keine Steuerspannung', 'pgreen', 'pwhite'  )+ #13+
HtmlPara( EStoerung_StromVS, 'Störung', '', 'pred', 'pwhite'  )+ #13+
'</p>'+#13+
'</main>'+#13+
'</div>'+#13;

  SendMail ( cMailUser, cMailPass, cMailFrom, cMailTo , cMailSrv, cMailPort, MailCont );

end;

function TIOData.SendMail(  User, Password,  MailFrom, MailTo,  SMTPHost, SMTPPort: string;  MailData: string): Boolean;
var
  SMTP: TSMTPSend;
  sl:TStringList;
  rcc:integer;
  MailToS:TStringArray;
begin

  Result:=False;
  SMTP:=TSMTPSend.Create;
  sl:=TStringList.Create;
  MailToS := MailTo.Split( ';' );
  try
    sl.text:=Maildata;
    SMTP.UserName:=User;
    SMTP.Password:=Password;
    SMTP.TargetHost:=SMTPHost;
    SMTP.TargetPort:=SMTPPort;
    SMTP.AutoTLS:=FALSE;
    if Trim(SMTPPort)<>'25' then
      SMTP.FullSSL:=true; // if sending to port 25, don't use encryption
    if SMTP.Login then begin
      result:= SMTP.MailFrom(MailFrom, Length(MailData));
      for rcc := 0 to length(MailToS)-1 do begin
        Result := Result AND SMTP.MailTo(MailToS[rcc]);
      end;
      Result := Result and SMTP.MailData(sl);
      SMTP.Logout;
    end;
  finally
    SMTP.Free;
    sl.Free;
    MailToS := nil;
  end;
end;

function TIOData.HtmlPara(_Signal: boolean; _UserTrueStr, _UserFalseStr,
  _TagTrue, _TagFalse: string): string;
begin
  Result := '';
  if _Signal then begin
    if _UserTrueStr <> '' then begin
      Result := '<'+_TagTrue+'>'+_UserTrueStr+'</'+_TagTrue+'>';
    end;
  end else begin
    if _UserFalseStr <> '' then begin
      Result := '<'+_TagFalse+'>'+_UserFalseStr+'</'+_TagFalse+'>';
    end;
  end;
end;



end.

