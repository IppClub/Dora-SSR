local DORA_ROOT = os.projectdir()

local function runtime_output(name)
    local output_dir = path.join(DORA_ROOT, "build/runtime", get_config("plat"))
    if get_config("plat") == "iphoneos" then
        output_dir = path.join(output_dir,
            get_config("appledev") == "simulator" and "simulator" or "device")
    end
    return path.join(output_dir, get_config("arch"), get_config("mode"), name)
end

local function with_host_path(envs)
    local host_path = os.getenv("PATH")
    if host_path then
        envs.PATH = envs.PATH and (envs.PATH .. path.envsep() .. host_path) or host_path
    end
    return envs
end

if is_plat("android") then
    target("dora-rust-runtime")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        add_packages("dora_rustup")
        on_build(function (target)
            import("core.project.depend")
            import("core.project.config")

            local rust_dir = path.join(DORA_ROOT, "Source/Rust")
            local arches = {
                ["arm64-v8a"] = {"aarch64-linux-android", "aarch64-linux-android"},
                ["armeabi-v7a"] = {"armv7-linux-androideabi", "armv7a-linux-androideabi"},
                ["x86_64"] = {"x86_64-linux-android", "x86_64-linux-android"}
            }
            local selected = assert(arches[target:arch()],
                "unsupported Android Rust architecture: " .. target:arch())
            local triple, clang_prefix = selected[1], selected[2]
            local profile = config.mode() == "release" and "release" or "debug"
            local ndk = assert(get_config("ndk"), "Android Rust build requires configured NDK")
            local sdkver = tostring(get_config("ndk_sdkver") or "28")
            local archivers = os.files(path.join(ndk, "toolchains/llvm/prebuilt/*/bin/llvm-ar"))
            local ar = assert(archivers[1], "Android NDK LLVM archiver not found: " .. ndk)
            local bin = path.directory(ar)
            local cc = path.join(bin, clang_prefix .. sdkver .. "-clang")
            local cxx = cc .. "++"
            assert(os.isfile(cc) and os.isfile(cxx),
                "Android NDK API " .. sdkver .. " compilers not found: " .. cc)
            local output = runtime_output("libdora_runtime.a")
            local cargo_target_dir = path.join(DORA_ROOT, "build/runtime/cargo")
            local inputs = {
                path.join(rust_dir, "Cargo.toml"),
                path.join(rust_dir, "Cargo.lock")
            }
            table.join2(inputs, os.files(path.join(rust_dir, "src/**.rs")))
            table.join2(inputs, os.files(path.join(DORA_ROOT, "Tools/dora-rust/dora/src/**.rs")))
            table.join2(inputs, os.files(path.join(DORA_ROOT, "Tools/dora-rust/dora/Cargo*.toml")))

            depend.on_changed(function ()
                local envs = with_host_path(target:pkgenvs())
                envs.CARGO_TARGET_DIR = cargo_target_dir
                local env_triple = triple:gsub("%-", "_")
                envs["CC_" .. env_triple] = cc
                envs["CXX_" .. env_triple] = cxx
                envs["AR_" .. env_triple] = ar
                envs["CARGO_TARGET_" .. env_triple:upper() .. "_LINKER"] = cc
                os.vrunv("rustup", {"target", "add", triple}, {envs = envs, curdir = rust_dir})
                local argv = {"build", "--locked", "--target", triple}
                if profile == "release" then
                    table.insert(argv, "--release")
                end
                os.vrunv("cargo", argv, {envs = envs, curdir = rust_dir})
                os.mkdir(path.directory(output))
                os.cp(path.join(cargo_target_dir, triple, profile, "libdora_runtime.a"), output)
            end, {
                dependfile = path.join(target:autogendir(), "rules", "dora-rust-runtime.d"),
                files = inputs,
                values = {triple, profile, cc, cxx, ar, sdkver},
                changed = not os.isfile(output)
            })
        end)
    target_end()

    target("dora-wa-android")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        add_packages("dora_go")
        on_build(function (target)
            import("core.project.depend")

            local wa_dir = path.join(DORA_ROOT, "Source/3rdParty/Wa/Source")
            local output = path.join(DORA_ROOT, "build/runtime/android/wa.aar")
            local gomobile_version = "v0.0.0-20250606033058-a2a15c67f36f"
            local inputs = {
                path.join(wa_dir, "go.mod"),
                path.join(wa_dir, "go.sum"),
                path.join(wa_dir, "vendor/modules.txt"),
                path.join(wa_dir, "wa.gomobile")
            }
            table.join2(inputs, os.files(path.join(wa_dir, "**.go")))

            depend.on_changed(function ()
                local tools_dir = path.join(DORA_ROOT, "build/tools/gomobile", gomobile_version)
                local work_dir = path.join(DORA_ROOT, "build/runtime/android/wa-work")
                local source_dir = path.join(work_dir, "wa")
                local unpack_dir = path.join(work_dir, "aar")
                local envs = with_host_path(target:pkgenvs())
                envs.GOBIN = tools_dir
                -- xmake's Go package may omit go.env, so a fresh host has no
                -- module proxy default. Keep explicit user settings, but give
                -- gomobile's network install the standard Go proxy fallback.
                local go_proxy = os.getenv("GOPROXY")
                envs.GOPROXY = go_proxy and #go_proxy > 0 and go_proxy
                    or "https://proxy.golang.org,direct"
                envs.GOSUMDB = os.getenv("GOSUMDB") or "sum.golang.org"
                envs.ANDROID_HOME = os.getenv("ANDROID_HOME")
                    or os.getenv("ANDROID_SDK_ROOT") or get_config("android_sdk")
                if envs.ANDROID_HOME and envs.ANDROID_HOME:sub(1, 2) == "~/" then
                    envs.ANDROID_HOME = path.join(os.getenv("HOME"),
                        envs.ANDROID_HOME:sub(3))
                end
                assert(envs.ANDROID_HOME and os.isdir(envs.ANDROID_HOME),
                    "Android Wa build requires Android SDK")
                envs.ANDROID_NDK_HOME = assert(get_config("ndk"),
                    "Android Wa build requires configured NDK")
                os.mkdir(tools_dir)
                local gomobile = path.join(tools_dir,
                    os.host() == "windows" and "gomobile.exe" or "gomobile")
                if not os.isfile(gomobile) then
                    os.vrunv("go", {"install", "golang.org/x/mobile/cmd/gomobile@" .. gomobile_version}, {
                        envs = envs, curdir = DORA_ROOT
                    })
                end
                os.vrunv(gomobile, {"init"}, {envs = envs, curdir = DORA_ROOT})
                os.rm(work_dir)
                os.mkdir(work_dir)
                os.cp(wa_dir, source_dir)
                os.mv(path.join(source_dir, "wa.gomobile"), path.join(source_dir, "wa.go"))
                os.rm(path.join(source_dir, "main.go"))
                local generated = path.join(source_dir, "wa.aar")
                envs.GOFLAGS = "-mod=mod"
                os.vrunv(gomobile, {
                    "bind", "-androidapi", "21", "-target=android", "-o", generated, "."
                }, {envs = envs, curdir = source_dir})
                os.mkdir(unpack_dir)
                os.vrunv("unzip", {"-q", generated, "-d", unpack_dir})
                os.rm(path.join(unpack_dir, "jni/x86"))
                os.rm(output)
                os.vrunv("zip", {"-qr", output, "."}, {curdir = unpack_dir})
                assert(os.isfile(output), "gomobile completed without wa.aar")
                os.rm(work_dir)
            end, {
                dependfile = path.join(target:autogendir(), "rules", "dora-wa-android.d"),
                files = inputs,
                values = {gomobile_version, get_config("ndk")},
                changed = not os.isfile(output)
            })
        end)
    target_end()
end

if is_plat("windows") then
    target("dora-rust-runtime")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        add_packages("dora_rustup")
        on_build(function (target)
            import("core.project.depend")
            import("core.project.config")

            local rust_dir = path.join(DORA_ROOT, "Source/Rust")
            local triple = "i686-pc-windows-msvc"
            local profile = config.mode() == "release" and "release" or "debug"
            local output = runtime_output("dora_runtime.lib")
            local cargo_target_dir = os.getenv("CARGO_TARGET_DIR")
            if not cargo_target_dir then
                local local_app_data = assert(os.getenv("LOCALAPPDATA"),
                    "Windows Rust build requires LOCALAPPDATA or CARGO_TARGET_DIR")
                cargo_target_dir = path.join(local_app_data, "DoraSSR/cargo-target")
            end
            local inputs = {
                path.join(rust_dir, "Cargo.toml"),
                path.join(rust_dir, "Cargo.lock")
            }
            table.join2(inputs, os.files(path.join(rust_dir, "src/**.rs")))
            table.join2(inputs, os.files(path.join(DORA_ROOT, "Tools/dora-rust/dora/src/**.rs")))
            table.join2(inputs, os.files(path.join(DORA_ROOT, "Tools/dora-rust/dora/Cargo*.toml")))

            depend.on_changed(function ()
                local envs = with_host_path(target:pkgenvs())
                envs.CARGO_TARGET_DIR = cargo_target_dir
                local host_toolchain = envs.RUSTUP_TOOLCHAIN or "stable"
                envs.RUSTUP_TOOLCHAIN = host_toolchain
                os.vrunv("rustup", {
                    "toolchain", "install", host_toolchain, "--profile", "minimal"
                }, {envs = envs, curdir = rust_dir})
                os.vrunv("rustup", {"target", "add", triple}, {envs = envs, curdir = rust_dir})
                local argv = {"build", "--locked", "--target", triple}
                if profile == "release" then
                    table.insert(argv, "--release")
                end
                os.vrunv("cargo", argv, {envs = envs, curdir = rust_dir})
                os.mkdir(path.directory(output))
                os.cp(path.join(cargo_target_dir, triple, profile, "dora_runtime.lib"), output)
            end, {
                dependfile = path.join(target:autogendir(), "rules", "dora-rust-runtime.d"),
                files = inputs,
                values = {triple, profile, cargo_target_dir},
                changed = not os.isfile(output)
            })
        end)
    target_end()

    target("dora-wa-runtime")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        add_packages("dora_go")
        on_build(function (target)
            import("core.project.depend")
            import("lib.detect.find_tool")

            local wa_dir = path.join(DORA_ROOT, "Source/3rdParty/Wa/Source")
            local output = runtime_output("wa.dll")
            local inputs = {
                path.join(wa_dir, "go.mod"),
                path.join(wa_dir, "go.sum"),
                path.join(wa_dir, "vendor/modules.txt")
            }
            table.join2(inputs, os.files(path.join(wa_dir, "**.go")))

            depend.on_changed(function ()
                local cc = os.getenv("CC")
                if not cc then
                    local gcc = find_tool("i686-w64-mingw32-gcc", {force = true})
                        or find_tool("gcc", {force = true})
                    cc = gcc and gcc.program
                end
                assert(cc and os.iorunv(cc, {"-dumpmachine"}):find("i686"),
                    "Windows x86 Wa build requires a 32-bit MinGW GCC; set CC")
                local envs = with_host_path(target:pkgenvs())
                envs.GOOS = "windows"
                envs.GOARCH = "386"
                envs.CGO_ENABLED = "1"
                envs.GOFLAGS = "-buildvcs=false -mod=vendor"
                envs.CC = cc
                os.mkdir(path.directory(output))
                os.vrunv("go", {
                    "build", "-trimpath", "-buildmode=c-shared",
                    "-ldflags=-s -w", "-o", output, "."
                }, {envs = envs, curdir = wa_dir})
            end, {
                dependfile = path.join(target:autogendir(), "rules", "dora-wa-runtime.d"),
                files = inputs,
                values = {"windows", "386", "c-shared"},
                changed = not os.isfile(output)
            })
        end)
    target_end()
end

-- Build native-language archives for the selected target architecture instead
-- of consuming ignored, potentially stale or single-architecture files from
-- the source tree. Android still retains its existing artifacts until its
-- platform-specific runtime packaging is migrated.
if is_plat("macosx", "linux") then
    target("dora-rust-runtime")
        -- xmake 3.1.1's Xcode generator only serializes concrete product
        -- kinds. The generated build phase starts a fresh xmake process and
        -- restores this target's real phony semantics.
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        -- Use rustup's cargo proxy for cross targets. The standalone `rust`
        -- package contains only the host standard library, so mixing its
        -- cargo with rustup-installed target components cannot cross-compile.
        add_packages("dora_rustup")
        on_build(function (target)
            import("core.project.depend")
            import("core.project.config")

            local rust_dir = path.join(DORA_ROOT, "Source/Rust")
            local triple
            if target:is_plat("macosx") then
                triple = target:arch() == "x86_64"
                    and "x86_64-apple-darwin" or "aarch64-apple-darwin"
            else
                triple = target:arch() == "x86_64"
                    and "x86_64-unknown-linux-gnu" or "aarch64-unknown-linux-gnu"
            end
            local profile = config.mode() == "release" and "release" or "debug"
            local output = runtime_output("libdora_runtime.a")
            local cargo_target_dir = path.join(DORA_ROOT, "build/runtime/cargo")
            local inputs = {
                path.join(rust_dir, "Cargo.toml"),
                path.join(rust_dir, "Cargo.lock")
            }
            table.join2(inputs, os.files(path.join(rust_dir, "src/**.rs")))
            table.join2(inputs, os.files(path.join(DORA_ROOT, "Tools/dora-rust/dora/src/**.rs")))
            table.join2(inputs, os.files(path.join(DORA_ROOT, "Tools/dora-rust/dora/Cargo*.toml")))

            depend.on_changed(function ()
                local envs = with_host_path(target:pkgenvs())
                envs.CARGO_TARGET_DIR = cargo_target_dir
                if target:is_plat("macosx") then
                    envs.MACOSX_DEPLOYMENT_TARGET = "12.0"
                elseif target:arch() == "x86_64" then
                    envs.CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER =
                        "x86_64-linux-gnu-gcc"
                else
                    envs.CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER =
                        "aarch64-linux-gnu-gcc"
                end
                os.vrunv("rustup", {"target", "add", triple}, {envs = envs, curdir = rust_dir})
                local argv = {"build", "--locked", "--target", triple}
                if profile == "release" then
                    table.insert(argv, "--release")
                end
                os.vrunv("cargo", argv, {envs = envs, curdir = rust_dir})
                os.mkdir(path.directory(output))
                os.cp(path.join(cargo_target_dir, triple, profile, "libdora_runtime.a"), output)
            end, {
                dependfile = path.join(target:autogendir(), "rules", "dora-rust-runtime.d"),
                files = inputs,
                values = {
                    triple,
                    profile,
                    target:is_plat("macosx") and "macosx-min-12.0" or "linux"
                },
                changed = not os.isfile(output)
            })
        end)
    target_end()

    target("dora-wa-runtime")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        add_packages("dora_go")
        on_build(function (target)
            import("core.project.depend")

            local wa_dir = path.join(DORA_ROOT, "Source/3rdParty/Wa/Source")
            local goos = target:is_plat("macosx") and "darwin" or "linux"
            local goarch = target:arch() == "x86_64" and "amd64" or "arm64"
            local output = runtime_output("libwa.a")
            local inputs = {
                path.join(wa_dir, "go.mod"),
                path.join(wa_dir, "go.sum"),
                path.join(wa_dir, "vendor/modules.txt")
            }
            table.join2(inputs, os.files(path.join(wa_dir, "**.go")))

            depend.on_changed(function ()
                local envs = with_host_path(target:pkgenvs())
                envs.GOOS = goos
                envs.GOARCH = goarch
                envs.CGO_ENABLED = "1"
                envs.GOFLAGS = "-mod=vendor"
                if target:is_plat("macosx") then
                    envs.CGO_CFLAGS = "-mmacosx-version-min=12.0"
                    envs.CGO_LDFLAGS = "-mmacosx-version-min=12.0"
                elseif target:arch() == "x86_64" then
                    envs.CC = "x86_64-linux-gnu-gcc"
                else
                    envs.CC = "aarch64-linux-gnu-gcc"
                end
                os.mkdir(path.directory(output))
                os.vrunv("go", {
                    "build", "-trimpath", "-buildmode=c-archive",
                    "-ldflags=-s -w", "-o", output, "."
                }, {envs = envs, curdir = wa_dir})
            end, {
                dependfile = path.join(target:autogendir(), "rules", "dora-wa-runtime.d"),
                files = inputs,
                values = {
                    goos,
                    goarch,
                    target:is_plat("macosx") and "macosx-min-12.0" or "linux"
                },
                changed = not os.isfile(output)
            })
        end)
    target_end()
end

if is_plat("iphoneos") then
    target("dora-rust-runtime")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        add_packages("dora_rustup")
        on_build(function (target)
            import("core.project.depend")
            import("core.project.config")

            local rust_dir = path.join(DORA_ROOT, "Source/Rust")
            local simulator = get_config("appledev") == "simulator"
            local triple = simulator
                and (target:arch() == "x86_64" and "x86_64-apple-ios" or "aarch64-apple-ios-sim")
                or "aarch64-apple-ios"
            local profile = config.mode() == "release" and "release" or "debug"
            local output = runtime_output("libdora_runtime.a")
            local cargo_target_dir = path.join(DORA_ROOT, "build/runtime/cargo")
            local inputs = {
                path.join(rust_dir, "Cargo.toml"),
                path.join(rust_dir, "Cargo.lock")
            }
            table.join2(inputs, os.files(path.join(rust_dir, "src/**.rs")))
            table.join2(inputs, os.files(path.join(DORA_ROOT, "Tools/dora-rust/dora/src/**.rs")))
            table.join2(inputs, os.files(path.join(DORA_ROOT, "Tools/dora-rust/dora/Cargo*.toml")))

            depend.on_changed(function ()
                local envs = with_host_path(target:pkgenvs())
                envs.CARGO_TARGET_DIR = cargo_target_dir
                envs.IPHONEOS_DEPLOYMENT_TARGET = "13.0"
                os.vrunv("rustup", {"target", "add", triple}, {envs = envs, curdir = rust_dir})
                local argv = {"build", "--locked", "--target", triple}
                if profile == "release" then
                    table.insert(argv, "--release")
                end
                os.vrunv("cargo", argv, {envs = envs, curdir = rust_dir})
                os.mkdir(path.directory(output))
                os.cp(path.join(cargo_target_dir, triple, profile, "libdora_runtime.a"), output)
            end, {
                dependfile = path.join(target:autogendir(), "rules", "dora-rust-runtime.d"),
                files = inputs,
                values = {triple, profile, "ios-min-13.0"},
                changed = not os.isfile(output)
            })
        end)
    target_end()

    target("dora-wa-runtime")
        set_kind(os.getenv("XMAKE_IN_PROJECT_GENERATOR") and "binary" or "phony")
        set_default(false)
        add_packages("dora_go")
        on_build(function (target)
            import("core.project.depend")

            local wa_dir = path.join(DORA_ROOT, "Source/3rdParty/Wa/Source")
            local simulator = get_config("appledev") == "simulator"
            local sdk = simulator and "iphonesimulator" or "iphoneos"
            local goos = "ios"
            local goarch = target:arch() == "x86_64" and "amd64" or "arm64"
            local output = runtime_output("libwa.a")
            local inputs = {
                path.join(wa_dir, "go.mod"),
                path.join(wa_dir, "go.sum"),
                path.join(wa_dir, "vendor/modules.txt")
            }
            table.join2(inputs, os.files(path.join(wa_dir, "**.go")))

            depend.on_changed(function ()
                local envs = with_host_path(target:pkgenvs())
                local sysroot = os.iorunv("xcrun", {"--sdk", sdk, "--show-sdk-path"}):trim()
                local clang = os.iorunv("xcrun", {"--sdk", sdk, "--find", "clang"}):trim()
                local minver = simulator and "-mios-simulator-version-min=13.0"
                    or "-miphoneos-version-min=13.0"
                envs.GOOS = goos
                envs.GOARCH = goarch
                envs.CGO_ENABLED = "1"
                envs.GOFLAGS = "-mod=vendor"
                envs.CC = clang
                envs.CGO_CFLAGS = "-arch " .. target:arch() .. " -isysroot " .. sysroot .. " " .. minver
                envs.CGO_LDFLAGS = envs.CGO_CFLAGS
                os.mkdir(path.directory(output))
                os.vrunv("go", {
                    "build", "-trimpath", "-buildmode=c-archive",
                    "-ldflags=-s -w", "-o", output, "."
                }, {envs = envs, curdir = wa_dir})
            end, {
                dependfile = path.join(target:autogendir(), "rules", "dora-wa-runtime.d"),
                files = inputs,
                values = {sdk, goos, goarch, "ios-min-13.0"},
                changed = not os.isfile(output)
            })
        end)
    target_end()
end
