x86_64:
	git clone --branch dora https://github.com/pigpigyyy/bgfx.git
	git clone https://github.com/pigpigyyy/bimg.git
	git clone https://github.com/pigpigyyy/bx.git
	cd bgfx && ../bx/tools/bin/linux/genie --gcc=linux-gcc gmake
	$(MAKE) -R -C bgfx/.build/projects/gmake-linux config=release64
	mkdir libs
	cp -r bgfx/.build/linux64_gcc/bin/* libs

arm:
	git clone --branch dora https://github.com/pigpigyyy/bgfx.git
	git clone https://github.com/pigpigyyy/bimg.git
	git clone https://github.com/pigpigyyy/bx.git
	git clone --branch linux-arm https://github.com/pigpigyyy/GENie.git
	$(MAKE) -C GENie
	cp GENie/bin/linux/genie bx/tools/bin/linux/genie
	cd bgfx && ../bx/tools/bin/linux/genie --gcc=linux-arm-gcc gmake
	$(MAKE) -R -C bgfx/.build/projects/gmake-linux-arm-gcc/ config=release
	mkdir libs
	cp -r bgfx/.build/linux32_arm_gcc/bin/* libs

