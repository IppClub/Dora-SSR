x86_64:
	$(MAKE) -C 3rdParty x86_64
	cd build && cmake -DCMAKE_BUILD_TYPE=Release .
	$(MAKE) -C build

arm: deps
	$(MAKE) -C 3rdParty arm
	cd build && cmake -DCMAKE_BUILD_TYPE=Release .
	$(MAKE) -C build

