.PHONY: all debug release lib

all: release

debug: lib
	[ -d build ] || mkdir build
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	cd build && cmake -DCMAKE_BUILD_TYPE=debug ..
	$(MAKE) -C build

release: lib
	[ -d build ] || mkdir build
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	cd build && cmake -DCMAKE_BUILD_TYPE=release ..
	$(MAKE) -C build

lib:
	../../Tools/build-scripts/build_lib_linux.sh
