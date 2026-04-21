all:
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	$(MAKE) -C build

x86_64: lib_x86_64
	[ -d build ] || mkdir build
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	cd build && cmake -DCMAKE_BUILD_TYPE=Release ..
	$(MAKE) -C build

arm: lib_arm
	[ -d build ] || mkdir build
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	cd build && cmake -DCMAKE_BUILD_TYPE=Release ..
	$(MAKE) -C build

debug:
	[ -d build ] || mkdir build
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	cd build && cmake -DCMAKE_BUILD_TYPE=debug ..
	$(MAKE) -C build

release:
	[ -d build ] || mkdir build
	cd ../../Tools/tolua++ && lua tolua++.lua && cd ../../Projects/Linux
	cd build && cmake -DCMAKE_BUILD_TYPE=release ..
	$(MAKE) -C build

lib_x86_64:
	../../Tools/build-scripts/build_lib_linux_x86_64.sh

lib_arm:
	../../Tools/build-scripts/build_lib_linux_aarch64.sh
