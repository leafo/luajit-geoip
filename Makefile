
.PHONY: test local build valgrind

test:
	busted

local: build
	luarocks make --lua-version=5.1 --local geoip-dev-1.rockspec

build:
	moonc geoip

valgrind:
	valgrind --leak-check=yes --trace-children=yes busted

lint::
	git ls-files | grep '\.moon$$' | xargs -n 100 moonc -l
