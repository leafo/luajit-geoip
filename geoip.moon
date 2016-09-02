

NUM_DB_TYPES  = 38 + 1

ffi = require "ffi"
bit = require "bit"

ffi.cdef [[
  typedef struct GeoIP {} GeoIP;

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
]]

lib = ffi.load "GeoIP"

ip = "85.17.20.205"

dbs = {
  lib.GEOIP_COUNTRY_EDITION
  lib.GEOIP_ASNUM_EDITION
}

country_by_id = (gi, id) ->
  if id < 0 or id >= lib.GeoIP_num_countries!
    return

  code = ffi.string lib.GeoIP_code_by_id id
  country = ffi.string lib.GeoIP_country_name_by_id gi, id
  code, country

for i in *dbs
  available = 1 == lib.GeoIP_db_avail(i)
  continue unless available
  gi = lib.GeoIP_open_type i, bit.bor lib.GEOIP_STANDARD, lib.GEOIP_SILENCE
  continue if gi == nil
  ffi.gc gi, ffi.GeoIP_delete
  lib.GeoIP_set_charset gi, lib.GEOIP_CHARSET_UTF8

  switch i
    when lib.GEOIP_COUNTRY_EDITION
      print "counrty"
      cid = lib.GeoIP_id_by_addr gi, ip
      print country_by_id gi, cid
    when lib.GEOIP_ASNUM_EDITION
      print "asnum"
      res = ffi.string lib.GeoIP_name_by_addr gi, ip
      print res


