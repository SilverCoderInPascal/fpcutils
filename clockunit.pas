unit ClockUnit;


{$mode objfpc}{$H+}
{$modeswitch functionreferences}
{$modeswitch anonymousfunctions}


interface

uses
  SysUtils, DateUtils;

type
  TClockFunc = reference to function: TDateTime;

  { TClock }

  TClock = class
  private
    FNowFunc: TClockFunc;

    // private constructor to enforce singleton
    constructor Create;
  public
    function Now: TDateTime; // make it easy to use!
    function EpochSeconds: Int64;

    procedure UseSystemTime;
    procedure UseFixedTime(DateTime: TDateTime); overload;
    procedure UseFixedTime(AEpochSeconds: Int64); overload;
    procedure UseOffsetTime(BaseFunc: TClockFunc; OffsetSeconds: Int64);
    procedure UseOffsetFromSelf(OffsetSeconds: Int64);

    class function Instance: TClock;
  end;

var
  Clock: TClock; // shortcut/global reference

implementation

var
  SingletonClock: TClock;

{ TClock }

constructor TClock.Create;
begin
  inherited Create;
  UseSystemTime; // default
end;

function TClock.Now: TDateTime;
begin
  Result := FNowFunc();
end;

function TClock.EpochSeconds: Int64;
begin
  Result := DateTimeToUnix(FNowFunc());
end;

procedure TClock.UseSystemTime;
begin
  FNowFunc := @SysUtils.Now;
end;

procedure TClock.UseFixedTime(DateTime: TDateTime);
begin
  FNowFunc := function: TDateTime
    begin
      Exit(DateTime);
    end;
end;

procedure TClock.UseFixedTime(AEpochSeconds: Int64);
begin
  UseFixedTime(UnixToDateTime(AEpochSeconds));
end;

procedure TClock.UseOffsetTime(BaseFunc: TClockFunc; OffsetSeconds: Int64);
begin
  FNowFunc := function: TDateTime
    begin
      Exit(IncSecond(BaseFunc(), OffsetSeconds));
    end;
end;

procedure TClock.UseOffsetFromSelf(OffsetSeconds: Int64);
var
  Base: TClockFunc;
begin
  Base := FNowFunc;
  UseOffsetTime(Base, OffsetSeconds);
end;

class function TClock.Instance: TClock;
begin
  if not Assigned(SingletonClock) then
    SingletonClock := TClock.Create;
  Result := SingletonClock;
end;

initialization
  Clock := TClock.Instance;

finalization
  FreeAndNil(SingletonClock);

end.

