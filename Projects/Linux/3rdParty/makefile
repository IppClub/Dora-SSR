x86_64:
	[ -d bgfx ] || git clone --depth=1 --branch dora https://github.com/pigpigyyy/bgfx.git
	[ -d bimg ] || git clone --depth=1 https://github.com/pigpigyyy/bimg.git
	[ -d bx ] || git clone --depth=1 --branch dora https://github.com/pigpigyyy/bx.git
	[ -d GENie ] || git clone --depth=1 --branch linux-arm https://github.com/pigpigyyy/GENie.git
	[ -f GENie/bin/linux/genie ] || ($(MAKE) -C GENie && cp GENie/bin/linux/genie bx/tools/bin/linux/genie && cd bgfx && ../bx/tools/bin/linux/genie --gcc=linux-gcc gmake)
	$(MAKE) -R -C bgfx/.build/projects/gmake-linux-gcc config=release64
	mkdir -p ../../../Source/3rdParty/bgfx/build/linux/x86_64/release
	cp bgfx/.build/linux64_gcc/bin/*.a ../../../Source/3rdParty/bgfx/build/linux/x86_64/release/
	cp bgfx/.build/linux64_gcc/lib/*.a ../../../Source/3rdParty/bgfx/build/linux/x86_64/release/
	[ -d libs ] || mkdir libs
	cp -r bgfx/.build/linux64_gcc/bin/* libs
	cp ../../../Source/3rdParty/Wa/Lib/Linux/amd64/libwa.a libs
	cp ../../../Source/Rust/lib/Linux/x86_64/libdora_runtime.a libs

arm:
	[ -d bgfx ] || git clone --depth=1 --branch dora https://github.com/pigpigyyy/bgfx.git
	[ -d bimg ] || git clone --depth=1 https://github.com/pigpigyyy/bimg.git
	[ -d bx ] || git clone --depth=1 --branch dora https://github.com/pigpigyyy/bx.git
	[ -d GENie ] || git clone --depth=1 --branch linux-arm https://github.com/pigpigyyy/GENie.git
	[ -f GENie/bin/linux/genie ] || ($(MAKE) -C GENie && cp GENie/bin/linux/genie bx/tools/bin/linux/genie && cd bgfx && ../bx/tools/bin/linux/genie --gcc=linux-arm-gcc gmake)
	$(MAKE) -R -C bgfx/.build/projects/gmake-linux-arm-gcc/ config=release
	mkdir -p ../../../Source/3rdParty/bgfx/build/linux/aarch64/release
	cp bgfx/.build/linux32_arm_gcc/bin/*.a ../../../Source/3rdParty/bgfx/build/linux/aarch64/release/
	cp bgfx/.build/linux32_arm_gcc/lib/*.a ../../../Source/3rdParty/bgfx/build/linux/aarch64/release/
	[ -d libs ] || mkdir libs
	cp -r bgfx/.build/linux32_arm_gcc/bin/* libs
	cp ../../../Source/3rdParty/Wa/Lib/Linux/aarch64/libwa.a libs
	cp ../../../Source/Rust/lib/Linux/aarch64/libdora_runtime.a libs
