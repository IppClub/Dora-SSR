.PHONY: all debug release lib lib-debug lib-release

all: release

debug: lib-debug
	[ -d build ] || mkdir build
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	cd build && cmake -DCMAKE_BUILD_TYPE=debug ..
	$(MAKE) -C build

release: lib-release
	[ -d build ] || mkdir build
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	cd build && cmake -DCMAKE_BUILD_TYPE=release ..
	$(MAKE) -C build

lib: lib-release

lib-debug:
	../../Tools/build-scripts/build_lib_linux.sh debug

lib-release:
	../../Tools/build-scripts/build_lib_linux.sh release
