program dmzmail;

{$mode objfpc}{$H+}

{$M+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  fphttpclient, fpjson, jsonparser,
  fpjsonrtti, iodata,
  ioconfig;

type
  { TDomoMail }
  TDomoMail = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TDomoMail }

procedure TDomoMail.DoRun;
var
  DomInfo : TStringList;
  DtJ: TJSonData;
  DataArray: TJSONArray;
  k:integer;
  xName, xData :string;
  IoData : TIOData;

begin
  ReadConfig ( ChangeFileExt( ParamStr(0), '.ini'));

  // writeln ( 'Start DomoMail' );
  DomInfo := TStringList.Create;
  try
    TFPCustomHTTPClient.SimpleGet( domoticzURL, DomInfo );
    // writeln ( DomInfo.text );
    try
      DtJ := GetJSON( DomInfo.text );
      try
        DataArray := TJSONArray ( DtJ.FindPath('result'));
        if Assigned ( DataArray ) then begin
          // writeln ( DataArray.Count );
          IoData := TIOData.Create;
          try
            for k := 0 to DataArray.Count-1 do begin
              xName := TJSonData(DataArray[k]).FindPath('Name').Value;
              xData := Uppercase(TJSonData(DataArray[k]).FindPath('Data').Value);
              // xValid := TJSonData(DataArray[k]).FindPath('LastUpdate').Value;
              // writeln ( xName + ':' + xData + ',' + xValid );
              if      xName = 'E.Stoerung.Pumpe1' then IoData.EStoerung_Pumpe1 := xData = 'OFF'
              else if xName = 'E.Stoerung.Pumpe2' then IoData.EStoerung_Pumpe2 := xData = 'OFF'
              else if xName = 'E.Stoerung.StromVS' then IoData.EStoerung_StromVS := xData = 'ON'
              else if xName = 'E.Wassermangel' then IoData.EWassermangel := xData = 'ON'
              else if xName = 'E.Pumpe1.Lauf' then IoData.EPumpe1_Lauf := xData = 'ON'
              else if xName = 'E.Pumpe2.Lauf' then IoData.EPumpe2_Lauf := xData = 'ON'
              else if xName = 'E.Steuerspannung' then IoData.ESteuerspannung := xData = 'ON'
            end;

            IoData.DoMail;

          finally

            IoData.Free;
          end;
        end;
      finally
        Dtj.Free;
      end;
    except
      on e:exception do begin
        writeln ( e.message );
      end;
    end;
  finally
    DomInfo.Free;
  end;

  Terminate;
end;

constructor TDomoMail.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
end;

destructor TDomoMail.Destroy;
begin
  inherited Destroy;
end;

var
  Application: TDomoMail;
begin
  Application:=TDomoMail.Create(nil);
  Application.Title:='DomoticzMail';
  Application.Run;
  Application.Free;
end.

