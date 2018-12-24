<img src="fpcache_logo.png" />

FPCache is a simple in-memory cache manager for FreePascal with optional data lifespan.

## Usage
<pre>
uses fpcache;

var
	cache: TCache;
	
begin
	cache := TCache.Create
	
	// Put my name into the cache
	cache.put('name', 'Marcus');
	
	// Get and WriteLn my name
	WriteLn(cache.getStr('name'));
	
	// Remove my name from the cache
	cache.delete('name');
	
	// Put my age with a data lifespan of 10 seconds
	cache.put('age', 32, 10000);
	
	// Get and print my age
	WriteLn(cache.getInt('age'));
	
	// Blank string
	WriteLn(cache.getStr('nope'));
	
	// Integer 0
	WriteLn(cache.getInt('nope'));
	
	// throwOnMissing is optional and defaults to false
	cache.throwOnMissing := true;
	
	// Now we get an exception
	WriteLn(cache.getStr('nope'));
end;
</pre>