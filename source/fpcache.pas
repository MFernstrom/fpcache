unit fpcache;

{
  Author    Marcus Fernström
  License   MIT
  Version   0.1
  GitHub    https://github.com/MFernstrom/fpcache/
}

{$mode objfpc}{$H+}

{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
{$WARN 3018 off : Constructor should be public}

 interface

 uses
   Classes, SysUtils, fgl;

 type
   { TCache }
   TCache = class
     private
       class var throwOnMissingKey: Boolean;
       class procedure cleanupOnDemand(name: String);
       constructor Init;
     public
       class function Create: TCache;
       class function put(name, data: String): Boolean;
       class function put(name, data: String; lifeTime: Integer): Boolean;
       class function put(name: String; data: Integer): Boolean;
       class function put(name: String; data: Integer; lifeTime: Integer): Boolean;
       class function getInt(name: String):Integer;
       class function getStr(name: String):String;
       class function delete(name: String):Boolean;
       class property throwOnMissing: boolean read throwOnMissingKey write throwOnMissingKey;
   end;

  { TCacheRecord }
  TCacheRecord = record
    strData: String;
    intData: Integer;
    useEol: Boolean;
    eol: Comp;
	end;

  TCacheRecords = specialize TFPGMap<String,TCacheRecord>;

 implementation
 var
   Singleton : TCache = nil;
   cacheRecords: TCacheRecords;

// Clean up an item before it's used
class procedure TCache.cleanupOnDemand(name: String);
var
  index: Integer;
  cRecord: TCacheRecord;
begin
  index := cacheRecords.IndexOf(name);
  if index > -1 then begin
    cRecord := cacheRecords.Data[index];
    if cRecord.useEol = true then begin
      if cRecord.eol < TimeStampToMSecs(DateTimeToTimeStamp(now)) then
        cacheRecords.Remove(name);
    end;
  end;

  index := cacheRecords.IndexOf(name);
  if (index = -1) and (throwOnMissing = true) then
    raise exception.create('Missing record');
end;

constructor TCache.Init;
begin
  inherited Create;
  cacheRecords := TCacheRecords.Create;
end;

class function TCache.Create: TCache;
begin
  if Singleton = nil then
    Singleton := TCache.Init;
  Result := Singleton;
end;

 // Add String with no EOL
 class function TCache.put(name, data: String): Boolean;
 var
  cRecord: TCacheRecord;
begin
  try
    cRecord.strData := data;
    cRecord.useEol := false;
    cacheRecords.Add(name, cRecord);
    result := true;
  except
    on Exception do
      raise exception.create('Couldn''t add data to cache');
  end;
end;

// Add String with EOL
class function TCache.put(name, data: String; lifeTime: Integer): Boolean;
var
  cRecord: TCacheRecord;
begin
  try
    cRecord.strData := data;
    cRecord.eol := TimeStampToMSecs(DateTimeToTimeStamp(now)) + lifeTime;
    cRecord.useEol := true;
    cacheRecords.Add(name, cRecord);
    result := true;
  except
    on Exception do
      raise exception.create('Couldn''t add data to cache');
  end;
end;

// Add an integer with no EOL
class function TCache.put(name: String; data: Integer): Boolean;
var
  cRecord: TCacheRecord;
begin
  try
    cRecord.intData := data;
    cRecord.useEol := false;
    cacheRecords.Add(name, cRecord);
    result := true;
  except
    on Exception do
      raise exception.create('Couldn''t add data to cache');
  end;
end;

// Add integer with EOL
class function TCache.put(name: String; data: Integer; lifeTime: Integer): Boolean;
var
  cRecord: TCacheRecord;
begin
  try
    cRecord.intData := data;
    cRecord.useEol := true;
    cRecord.eol := TimeStampToMSecs(DateTimeToTimeStamp(now)) + lifeTime;
    cacheRecords.Add(name, cRecord);
    result := true;
  except
    on Exception do
      raise exception.create('Couldn''t add data to cache');
  end;
end;

// Get an integer
class function TCache.getInt(name: String):Integer;
var
  cRecord: TCacheRecord;
begin
  cleanupOnDemand(name);
  cacheRecords.TryGetData(name, cRecord);
  Result := cRecord.intData;
end;

// Get a string
class function TCache.getStr(name: String):String;
var
  cRecord: TCacheRecord;
begin
  cleanupOnDemand(name);
  cacheRecords.TryGetData(name, cRecord);
  Result := cRecord.strData;
end;

// Remove an item from the cache
class function TCache.delete(name: String): Boolean;
begin
  try
    cacheRecords.Remove(name);
    Result := true;
  except
    on Exception do
      Result := false;
  end;
end;

end.
