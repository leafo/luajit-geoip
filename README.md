
# LuaJIT bindings to the C MaxMind GeoIP library

In order to use this library you'll need luajit, libGeoIP, and some
geoip databases installed.


## Install

```bash
luarocks install 
```

## Reference

The module is named `geoip`

```lua
local geoip = require "geoip"
```

GeoIP has support for many different database types. At the moment, this librar
will automatically load the databases available in the system location when
first trying to look up an address.

Only the country and ASNUM databases are supported. Feel free to create a pull
request with support for more.

### `lookup_addr(ip_address)`

Look up information about an address. Returns an table with properties about
that address extracted from all available databases.


```lua
local geoip = require "geoip"
local res = geoip.lookup_addr("8.8.8.8")

print(res.country_code)
```

The structure of the return value looks like this:

```lua
{
  country_code = "US",
  country_name = "United States",
  asnum = "AS15169 Google Inc."
}
```



