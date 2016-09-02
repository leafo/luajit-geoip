
# LuaJIT bindings to the C MaxMind GeoIP library

In order to use this library you'll need luajit, libGeoIP, and some geoip
databases installed. (Note: libGeoIP is the older C library, that should be
already available in most package managers)

## Install

```bash
luarocks install 
```

## Reference

The module is named `geoip`

```lua
local geoip = require "geoip"
```

GeoIP has support for many different database types.  The available lookup
databases are automatically loaded from the system location.

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

### Controlling database caching

You can control how the databases are loaded by manually instantiating a
`GeoIP` object and calling the `load_databases` method directly. `lookup_addr`
will automatically load databases only if they haven't been loaded yet.

```lua
local geoip = require("geoip")

local gi = geoip.GeoIP()
gi:load_databases("memory")

local res = gi:lookup_addr("8.8.8.8")
```

> By default the STANDARD mode is used, which reads from disk for each lookup


# Contact

Author: Leaf Corcoran (leafo) ([@moonscript](http://twitter.com/moonscript))  
Email: leafot@gmail.com  
Homepage: <http://leafo.net>  

