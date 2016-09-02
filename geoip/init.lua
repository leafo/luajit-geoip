local ffi = require("ffi")
local bit = require("bit")
ffi.cdef([[  typedef struct GeoIP {} GeoIP;

  typedef enum {
    GEOIP_STANDARD = 0,
    GEOIP_MEMORY_CACHE = 1,
    GEOIP_CHECK_CACHE = 2,
    GEOIP_INDEX_CACHE = 4,
    GEOIP_MMAP_CACHE = 8,
    GEOIP_SILENCE = 16,
  } GeoIPOptions;


  typedef enum {
    GEOIP_COUNTRY_EDITION = 1,
    GEOIP_ASNUM_EDITION = 9,
  } GeoIPDBTypes;

  typedef enum {
    GEOIP_CHARSET_ISO_8859_1 = 0,
    GEOIP_CHARSET_UTF8 = 1
  } GeoIPCharset;

  int GeoIP_db_avail(int type);
  GeoIP * GeoIP_open_type(int type, int flags);

  void GeoIP_delete(GeoIP * gi);
  char *GeoIP_database_info(GeoIP * gi);

  int GeoIP_charset(GeoIP * gi);
  int GeoIP_set_charset(GeoIP * gi, int charset);

  unsigned long _GeoIP_lookupaddress(const char *host);

  char *GeoIP_name_by_addr(GeoIP * gi, const char *addr);
  int GeoIP_id_by_addr(GeoIP * gi, const char *addr);

  unsigned GeoIP_num_countries(void);
  const char * GeoIP_code_by_id(int id);
  const char * GeoIP_country_name_by_id(GeoIP * gi, int id);
]])
local lib = ffi.load("GeoIP")
local DATABASE_TYPES = {
  lib.GEOIP_COUNTRY_EDITION,
  lib.GEOIP_ASNUM_EDITION
}
local country_by_id
country_by_id = function(gi, id)
  if id < 0 or id >= lib.GeoIP_num_countries() then
    return 
  end
  local code = ffi.string(lib.GeoIP_code_by_id(id))
  local country = ffi.string(lib.GeoIP_country_name_by_id(gi, id))
  return code, country
end
local GeoIP
do
  local _class_0
  local _base_0 = {
    load_databases = function(self, mode)
      if mode == nil then
        mode = lib.GEOIP_STANDARD
      end
      if self.databases then
        return 
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = dbs
        for _index_0 = 1, #_list_0 do
          local _continue_0 = false
          repeat
            local i = _list_0[_index_0]
            if not (1 == lib.GeoIP_db_avail(i)) then
              _continue_0 = true
              break
            end
            local gi = lib.GeoIP_open_type(i, bit.bor(mode, lib.GEOIP_SILENCE))
            if gi == nil then
              _continue_0 = true
              break
            end
            ffi.gc(gi, ffi.GeoIP_delete)
            lib.GeoIP_set_charset(gi, lib.GEOIP_CHARSET_UTF8)
            local _value_0 = {
              type = i,
              gi = gi
            }
            _accum_0[_len_0] = _value_0
            _len_0 = _len_0 + 1
            _continue_0 = true
          until true
          if not _continue_0 then
            break
          end
        end
        self.databases = _accum_0
      end
      return true
    end,
    lookup_addr = function(self, ip)
      self:load_databases()
      local out = { }
      for _des_0 in self.databases do
        local type, gi
        type, gi = _des_0.type, _des_0.gi
        local _exp_0 = i
        if lib.GEOIP_COUNTRY_EDITION == _exp_0 then
          local cid = lib.GeoIP_id_by_addr(gi, ip)
          out.country_code, out.country_name = country_by_id(gi, cid)
        elseif lib.GEOIP_ASNUM_EDITION == _exp_0 then
          out.asnum = ffi.string(lib.GeoIP_name_by_addr(gi, ip))
        end
      end
      return out
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self) end,
    __base = _base_0,
    __name = "GeoIP"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  GeoIP = _class_0
end
return {
  GeoIP = GeoIP,
  lookup_addr = (function()
    local _base_0 = GeoIP()
    local _fn_0 = _base_0.lookup_addr
    return function(...)
      return _fn_0(_base_0, ...)
    end
  end)()
}
