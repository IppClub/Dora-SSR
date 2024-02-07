all:
	$(MAKE) -C build

dep_x86_64:
	$(MAKE) -C 3rdParty x86_64

x86_64: dep_x86_64
	[ -d build ] || mkdir build
	cd build && cmake -DCMAKE_BUILD_TYPE=Release ..
	$(MAKE) -C build

dep_arm:
	$(MAKE) -C 3rdParty arm

arm: dep_arm
	[ -d build ] || mkdir build
	cd build && cmake -DCMAKE_BUILD_TYPE=Release ..
	$(MAKE) -C build

debug:
	[ -d build ] || mkdir build
	cd build && cmake -DCMAKE_BUILD_TYPE=debug ..
	$(MAKE) -C build

release:
	[ -d build ] || mkdir build
	cd build && cmake -DCMAKE_BUILD_TYPE=release ..
	$(MAKE) -C build

